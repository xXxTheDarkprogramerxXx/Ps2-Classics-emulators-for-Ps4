
-- Parappa the Rapper 2  [SCUS-97167]


apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

require( "ee-gpr-alias" )
require( "ee-hwaddr" )

local eeObj = getEEObject()

-- ================================================================================================
-- Title issues racy combination of VIF1 and GIF transfers.  It expects GIF to finish ahead of VU
-- XGKICK (via VIF1), which is atypical among PS2 titles (XGKICK has HW priority over GIF, and so
-- GIF can only finish ahead of XGKICK in certain extreme cases).
--
-- Fixed by delaying the specific VIF1 transfer (identified by MADR) for a long time to ensure GIF
-- gains arbitration and finishes ahead of XGKICKs.
--
local fix01_dma_vif1 = 
	function()
		local ee		= eeObj
		local tgtaddr	= ee.GetGpr(gpr.s0)

		-- print( string.format("success pt.1 : %x %x", vif1_hw.CHCR, tgtaddr ) )

		if tgtaddr == vif1_hw.CHCR then

			-- expected:
			--  # DIR==1 and MOD==1  (chain)
			--  # TADR==0x01C76AA0

			local chcr = ee.GetGPR(gpr.v0)

			if (chcr & 0x05) == 0x05 then
				local tadr = ee.ReadMem32(vif1_hw.TADR);
				if tadr == 0x01C76AA0 then
					-- 0x6000 works fine, 0x6500 adds a little extra cushion.
					ee.SchedulerDelayEvent("vif1.dma", 0x6500)
					-- print( "Parappa fix applied!" )
				end
			end
		end
	end
-- ================================================================================================

eeObj.AddHook(0x0015A008, 0xAE020000, fix01_dma_vif1)

-- ================================================================================================
-- Our emulator has accuracy problems on so many places. In this title, we have problems on VU.
-- To be accurate on VU is quite painful (we won't be able to get reasonable performance with it)
-- So as workaround, we just disable bilinear textures on Render-To-Texture drawing.
-- Bug#8122
eeInsnReplace(0x118084, 0xde260008, 0x24060000) -- 	ld	a2,8(s1)
eeInsnReplace(0x118798,	0xde260008, 0x24060000) -- 	ld	a2,8(s1)
eeInsnReplace(0x118868,	0xde660008, 0x24060000) -- 	ld	a2,8(s3)
eeInsnReplace(0x119d18,	0xdc460008, 0x24060000) -- 	ld	a2,8(v0)
eeInsnReplace(0x119d18,	0xdc460008, 0x24060000) -- 	ld	a2,8(v0)
