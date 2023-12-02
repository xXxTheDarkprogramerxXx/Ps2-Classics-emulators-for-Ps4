-- star_ocean sles82028
local gpr = require("ee-gpr-alias")
apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local emuObj		= getEmuObject()	
local eeObj 		= getEEObject()

-- Ignore up-render shift for triangles when writing mask = write alpha only . Will fix shadows (bug# 6724).
emuObj.SetGsTitleFix( "ignoreUpShiftTri", "reserved" , { fbmask = 0x00FFFFFF  } )

--  Performance  fix ( bug# 9474 )
if 0 then 	-- emuObj.IsNeoMode() then	-- neo mode check disabled, due to bug #10442
	emuObj.SetGsTitleFix( "globalSet",  "reserved", { workLoadThreshold = 125000} )
else
	emuObj.SetGsTitleFix( "globalSet",  "reserved", { workLoadThreshold = 100000} )
end

local reduceShadowsToOne = function()
    eeObj.SetGPR(gpr.a3 ,1)
end

if 1 then  	-- not emuObj.IsNeoMode() then	-- neo mode check disabled, due to bug #10443
	-- enable this hook only in base mode.
	-- NEO mode hardware has enough horsepower to render extra shadows. (correction: it doesn't, bug 10443)
	eeObj.AddHook(0x0042d1e0, 0x24c60001, reduceShadowsToOne)
end

-- NOP out some meaningless (M) bits.
-- SO3 uses these as a performance optimization to allow writing next data set regs in parallel
-- to mpg calculating results of current set.  In our emu it's sync always, so just interlock is ok.
vuInsnReplace(0, 0x004, (0x21f809bc<<32) | 0x8000033c, (0x01f809bc<<32) | 0x8000033c)	-- MULAbc.xyzw Acc, vf01, vf24.x (M)
vuInsnReplace(0, 0x016, (0x21f859bc<<32) | 0x8000033c, (0x01f859bc<<32) | 0x8000033c)	-- MULAbc.xyzw Acc, vf11, vf24.x (M)
vuInsnReplace(0, 0x034, (0x21f880bd<<32) | 0x8000033c, (0x01f880bd<<32) | 0x8000033c)	-- MADDAbc.xyzw Acc, Acc, vf16, vf24.y (M)
vuInsnReplace(0, 0x05b, (0x21f81e4a<<32) | 0x8000033c, (0x01f81e4a<<32) | 0x8000033c)	-- MADDbc.xyzw vf25, Acc, vf03, vf24.z (M)
vuInsnReplace(0, 0x06c, (0x210001c3<<32) | 0x8000033c, (0x010001c3<<32) | 0x8000033c)	-- ADDbc.x vf07, vf00, vf00.w (M)
vuInsnReplace(0, 0x15d, (0x21e141bc<<32) | 0x8000033c, (0x01e141bc<<32) | 0x8000033c)	-- MULAbc.xyzw Acc, vf08, vf01.x

-- remove DMA Ch1 kick for audio-vu1.
-- using Native EE processing code.
-- See. SLES82028_cli.conf and eJitExec_NativeHooks.cpp.
eeInsnReplace(0x00109bd4, 0xac239000, 0) -- sw      $v1,-0x7000 (0xffff9000)($at)
eeInsnReplace(0x00109c08, 0xac239000, 0) -- sw      $v1,-0x7000 (0xffff9000)($at)

--Title must always run 50 hz (PAL) even when PRogressive Mode has been enabled.
-- (progressive mode is made possible via ISD LUA patch, it was originally removed from the PAL region
--  release of SO3)
emuObj.ForceRefreshRate(50)
