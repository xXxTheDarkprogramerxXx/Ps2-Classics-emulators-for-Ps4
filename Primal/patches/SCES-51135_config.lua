-- Primal  [EU]

apiRequest(1.1)

local eeObj 	= getEEObject()
local emuObj 	= getEmuObject()

-- Bug 9094 - Title exhibits poor performance due to VU0 spin loops.
-- The spin loops are meant to be an optimizaion on PS2 and the best way of handling them is
-- to remove them from the original code.  This can be done since the VF09 register is unsed by
-- the first portion of the VU0 mpg.
--
-- Insn replacements Summarized:
--   1. NOP the spin loop from VU0.
--   2. NOP the setup code for VI05, which is the reg tested by the VU0 spin loop
--   3. Reorder the vcallms and qmtc2.


-- [$167:520507ff] IBNE vi05, vi00, [$167]
-- [$167:000002ff] NOP
local orig = (0x000002ff << 32) | 0x520507ff

vuInsnReplace(0, 0x167, orig, 0x8000033c | (0x000002ff << 32))		-- NOP / NOP2
vuInsnReplace(0, 0x172, orig, 0x8000033c | (0x000002ff << 32))		-- NOP / NOP2

local region_base = 0x399c5c

eeInsnReplace(region_base + 0x000,	0x24040001, 0x00000000)   	--	li	a0,1			-> NOP
eeInsnReplace(region_base + 0x010,	0x48c42800, 0x00000000)   	--	ctc2.ni	a0,$5       -> NOP
eeInsnReplace(region_base + 0x090,	0x24040001, 0x00000000)   	--	li	a0,1            -> NOP
eeInsnReplace(region_base + 0x0a0,	0x48c42800, 0x00000000)   	--	ctc2.ni	a0,$5       -> NOP

eeInsnReplace(region_base + 0x05c,	0x48c02800, 0x00000000)		-- ctc2.ni	zero,$5		-> NOP
eeInsnReplace(region_base + 0x114,	0x48c02800, 0x00000000)		-- ctc2.ni	zero,$5		-> NOP

eeInsnReplace(region_base + 0x054,  0x4a00d839, 0x48a44800) 	-- vcallmsr	vi27		-> qmtc2	a0,vf9
eeInsnReplace(region_base + 0x058,  0x48a44800, 0x4a00d839) 	-- qmtc2	a0,vf9		-> vcallmsr	vi27
eeInsnReplace(region_base + 0x10c,	0x4a00d839, 0x48a44800)		-- vcallmsr	vi27		-> qmtc2	a0,vf9
eeInsnReplace(region_base + 0x110,	0x48a44800, 0x4a00d839)		-- qmtc2	a0,vf9		-> vcallmsr	vi27

-- remove heat haze distortion ( for performance reason Bug#8827 )
--  reg = 0x42  packedFlags = 3( iip, tme, fst)   packedPrim  = 5(SCE_GS_PRIM_TRIFAN)
emuObj.SetGsTitleFix( "globalSet",  "reserved", { packedRegsLo = 0x42,packedRegsHi = 0, packedRegsNum = 2, packedFlags = 3, packedPrim = 5})
emuObj.SetGsTitleFix( "skipPacked", "reserved", { alpha = 0x80000044, tbp = 0x3a4000 , zmsk=1 })
emuObj.SetGsTitleFix( "skipPacked", "reserved", { alpha = 0x80000044, tbp = 0x348000 , zmsk=1 })


-- NOP out cacheline prefetch instructions.
-- Prefetch might have been a good idea on PS2, but it is entirely unhelpful on the PS4 target.
if 1 then 
	eeInsnReplace(0x381e60, 0x78400040, 0x00000000)		-- 	lq	zero,64(v0)
	eeInsnReplace(0x3822c0, 0x78400040, 0x00000000)		-- 	lq	zero,64(v0)
	eeInsnReplace(0x38ec7c, 0x78800040, 0x00000000)		-- 	lq	zero,64(a0)
	eeInsnReplace(0x38ed78, 0x78600040, 0x00000000)		-- 	lq	zero,64(v1)
	eeInsnReplace(0x38eec0, 0x78a00040, 0x00000000)		-- 	lq	zero,64(a1)
	eeInsnReplace(0x38fe28, 0x7a600040, 0x00000000)		-- 	lq	zero,64(s3)
	eeInsnReplace(0x38fea4, 0x78800040, 0x00000000)		-- 	lq	zero,64(a0)
	eeInsnReplace(0x390da8, 0x78400040, 0x00000000)		-- 	lq	zero,64(v0)
	eeInsnReplace(0x391020, 0x78400040, 0x00000000)		-- 	lq	zero,64(v0)
	eeInsnReplace(0x391174, 0x78a00040, 0x00000000)		-- 	lq	zero,64(a1)
	eeInsnReplace(0x3912b0, 0x78a00040, 0x00000000)		-- 	lq	zero,64(a1)
	eeInsnReplace(0x398790, 0x7a000040, 0x00000000)		-- 	lq	zero,64(s0)
	eeInsnReplace(0x399e60, 0x78400050, 0x00000000)		-- 	lq	zero,80(v0)
	eeInsnReplace(0x399ee8, 0x78400050, 0x00000000)		-- 	lq	zero,80(v0)
end

-- NOP out an idle loop meant to flush some cache lines...
if 1 then
	eeInsnReplace(0x331038, 0x18a00009, 0x00000000)		--  blez	a1,331060 <CDMAStreamIterator::AllocateBlock(unsigned int)+0x110>
	eeInsnReplace(0x33103c, 0x00d41821, 0x00000000)		--  addu	v1,a2,s4
	eeInsnReplace(0x331040, 0xbc5a0000, 0x00000000)		--  cache	0x1a,0(v0)
	eeInsnReplace(0x331044, 0x24a5ffff, 0x00000000)		--  addiu	a1,a1,-1
	eeInsnReplace(0x331054, 0x1ca0fffa, 0x00000000)		--  bgtz	a1,331040 <CDMAStreamIterator::AllocateBlock(unsigned int)+0xf0>
	eeInsnReplace(0x331058, 0x24420040, 0x00000000)		--  addiu	v0,v0,64
end
  
-- perf. fix bug 9094
emuObj.SetGsTitleFix( "globalSet", "reserved", {ignoreUpRenderTimeout=2} )
emuObj.SetGsTitleFix( "ignoreUpRender",  230, {} )
emuObj.SetGsTitleFix( "ignoreAreaUpdate", 0, { alpha=0x00000000 } )
emuObj.SetGsTitleFix( "ignoreAreaUpdate", 0, { alpha=0x80000048 } )
