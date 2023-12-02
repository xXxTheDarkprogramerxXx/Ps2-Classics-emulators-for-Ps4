-- Lua 5.3
-- Title:   Psychonauts PS2 - SLUS-21120 (USA)
-- Author:  Ernesto Corvi

-- Changelog:
-- v1.2: Removed some intro movies at doublefine request
-- v1.3: Added Widescreen support
-- v1.7: Fixed Widescreen buf (BUG 9445)

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])
require( "ee-cpr0-alias" ) -- for EE CPR

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()

local L1 =  -- main
	function()
		emuObj.ThrottleMax()
	end
	
local L2 =  -- main
	function()
		emuObj.ThrottleNorm()
	end
	
local load1 = eeObj.AddHook(0x2197a8, 0x27bdfff0, L1) -- ELoadingScreen::DisplayLoadingScreen
local load2 = eeObj.AddHook(0x2197e8, 0x27bdfff0, L2) -- ELoadingScreen::HideLoadingScreen

-- remove some intro movies at doublefine request
eeInsnReplace(0x14693c, 0x0c049c0c, 0)

-- widescreen support
eeInsnReplace(0x1e9fe4, 0, 0x3c013f40) -- scale up hFov to 0.75
eeInsnReplace(0x1e9fe8, 0, 0x4481f800)
eeInsnReplace(0x1e9fec, 0x46061983, 0x461f3183)
eeInsnReplace(0x1ea004, 0, 0x46061983)

eeInsnReplace(0x1e873c, 0x962f0038, 0x340f02ab) -- 512 -> 683
eeInsnReplace(0x1292b8, 0x240e0200, 0x240e02ab) -- 512 -> 683

eeInsnReplace(0x1d3604, 0x8def0430, 0x240f0200) -- 683 -> 512
eeInsnReplace(0x1d3968, 0x8def0430, 0x240f0200) -- 683 -> 512

emuObj.SetDisplayAspectWide()
