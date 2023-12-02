require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])
apiRequest(0.4)

-- Star Wars: Racer Revenge (SLES-50366) [US]

local eeObj		= getEEObject()

eeInsnReplace(0x13d7f0, 0x1000ffff, 0x0804f45d)	-- retry FREAD() for fix #9025,

-- Track#
-- The Grand Reefs 			: 6 
-- Ruins of Carnuss Gorgull : 9
eeObj.AddHook(0x187330,	0x3c010001, function()
				 local track = eeObj.GetGpr(gpr.a1)
				 print(string.format("Track : %d", track))
				 if track == 6 or track == 9 then
					eeObj.Vu1MpgCycles(1000)	-- makes it be 30fps.
				 else
					eeObj.Vu1MpgCycles(100)		-- default value.
				 end
end)

