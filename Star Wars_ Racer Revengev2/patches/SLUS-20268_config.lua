require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])
apiRequest(0.4)

-- Star Wars: Racer Revenge (SLUS-20268) [US]

local eeObj		= getEEObject()
local emuObj   	= getEmuObject()	

eeInsnReplace(0x13d7c0, 0x1000ffff, 0x0804f451)	-- retry FREAD() for fix #9025,

-- Track#
-- The Grand Reefs 			: 6 
-- Ruins of Carnuss Gorgull : 9
eeObj.AddHook(0x187300,	0x3c010001, function()
				 local track = eeObj.GetGpr(gpr.a1)
				 print(string.format("Track : %d", track))
				 if track == 6 or track == 9 then
					eeObj.Vu1MpgCycles(1000)	-- makes it be 30fps.
				 else
					eeObj.Vu1MpgCycles(100)		-- default value.
				 end
end)

-- Small triangle rejection. Works in conjunction with CLI setting   gs-override-small-tri-area=1
-- keep default area for texture 256x256 ( no blend)  (Anakin face)  
emuObj.SetGsTitleFix( "setRejectionArea", 500,{twIsNot=8, thIsNot=8 } )

-- Set triangle rejection area= 1000  when alpha blend is not 0 ( i.e blend is On)
emuObj.SetGsTitleFix( "setRejectionArea", 1000, {alphaIsNot=0 } )

