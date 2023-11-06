-- Lua 5.3
-- Title: Max Payne - SLUS-20230 (USA) v1.30
-- Author:  Nicola Salmoria


require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.2)	-- request version 0.2 API for throttling control.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()



local TH1A =	-- start of main()
	function()
		emuObj.ThrottleMax()
	end

local TH1B =	-- init loading screen
	function()
		local mode = eeObj.GetGpr(gpr.a0)

		if mode ~= 4 then	-- not sure what mode 4 is, but doesn't precede a real loading
			emuObj.ThrottleMax()
		end
	end

local TH1C =	-- advance progress bar
	function()
		local pct = eeObj.GetFpr(2)

		if pct >= 1.0 then
			emuObj.ThrottleNorm()
		end
	end



-- register hooks

local registeredHooks = {}

maxpayne_features_unregisterHooks = function()	-- global function (called by trophy_data)
	for _, hook in pairs(registeredHooks) do
		eeObj.RemoveHook(hook)
	end
	
	registeredHooks = {}
end

maxpayne_features_registerHooks = function()	-- global function (called by trophy_data)
	registeredHooks = {
		eeObj.AddHook(0x133bd8, 0x24030001, TH1A),	-- <main>:
		eeObj.AddHook(0x15e65c, 0x24030003, TH1B),	-- <MaxPayne_GameMode::initLoadingScreen(void)>:
		eeObj.AddHook(0x132e88, 0xc4a20000, TH1C),	-- <UpdateProgressBarKH(void)>:
	}
end
