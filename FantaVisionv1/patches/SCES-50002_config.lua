require("ee-gpr-alias")
require( "ee-hwaddr" )
apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

eeObj = getEEObject()

--
-- Bug#93709 (JP Bugzilla)
-- Same as Parappa the Rapper 2, it's VIF1 vs GIF xfer timing issue.
-- The game expects PATH3 happens before VU1 xgkick, but actually Olympus doesn't do like that.
--	Game kicks  : PATH3(Context1) PATH1(Rendering using Context1&2) PATH3(Context2)
--	Game expects: PATH3(Context1) PATH3(Context2) PATH1(Rendering using Context1&2)
-- Hence VIF1 DMA needs to be delayed.
eeObj.AddHook(0x1b1468,	0xae020000, function()
				 local ee = eeObj
				 local s0 = ee.GetGpr(gpr.s0)

				 if s0 == vif1_hw.CHCR then
					local chcr = ee.GetGpr(gpr.v0)
					if (chcr & 0x05) == 0x05 then
					   local tadr = ee.ReadMem32(vif1_hw.TADR)
					   if tadr == 0x8883e0 or tadr == 0x9f6b60 then
						  ee.SchedulerDelayEvent("vif1.dma", 0x5000)
					   end
					end
				 end
end)


-- Performace fix
local emuObj = getEmuObject()	
-- twIsLess=5 - texture width is less or eq. than 32
emuObj.SetGsTitleFix( "forcePointSampling", "reserved", {alpha = 0x80000048, twIsLess=5, thIsLess=5 } )
