apiRequest(0.6)	-- request version 0.1 API. Calling apiRequest() is mandatory.

-- bug#8979
-- The game bugged.
-- CStreaming::StreamPedsIntoRandomSlots(int*) expects 8 integers arrray to process,
-- but CCheat::LoveConquersAllCheat() function copies just only 6 integers to the stack.
-- it seems the table of the source is correct, so using lq/sq instead of ld/sd to copy
-- the contents of the table correctly.
eeInsnReplace(0x59fbb0,	0xdca20010, 0x78a20010) -- 	ld	v0,16(a1) => lq
eeInsnReplace(0x59fbb8,	0xfc820010, 0x7c820010) -- 	sd	v0,16(a0) => sq

-- bug#8979, actually different one
-- the game has another bug... see https://pss.usrd.scea.com/bugzilla/show_bug.cgi?id=8979
eeInsnReplace(0x1abdd8,	0x102000d9, 0x102000cf) -- 	beqz	at,1ac140 <CPopulation::AddPed(ePedType, unsigned int, CVector const &, bool)+0x3a0>

-- Performace fix
local emuObj = getEmuObject()	
local thresholdArea = 700
emuObj.SetGsTitleFix( "ignoreUpRender", thresholdArea , {alpha=0x80000044 , zmsk=1 } )
