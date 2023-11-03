-- Lua 5.3
-- Title:   Star Wars Jedi Starfighter PS2 - SLES-50371 (EUR)
-- Author:  Ernesto Corvi

-- Changelog:

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()

local L1 =  -- COverseer::UpdateSplashProgress / COverseer::UpdateLoadScreen
	function()
		local progress = eeObj.GetFpr(12)
		
		if progress < 0.2 then
			emuObj.ThrottleMax()
		elseif progress >= 1.0 then
			emuObj.ThrottleNorm()
		end
	end
	
local load1 = eeObj.AddHook(0x39a5c0, 0x27bdffb0, L1)	-- COverseer::UpdateSplashProgress
local load2 = eeObj.AddHook(0x3a01e0, 0x27bdffb0, L1)	-- COverseer::UpdateLoadScreen
