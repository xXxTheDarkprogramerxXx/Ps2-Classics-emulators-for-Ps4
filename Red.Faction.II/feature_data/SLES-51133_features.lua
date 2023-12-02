-- Lua 5.3
-- Title:   Red Faction II PS2 - SLES-51133 (EUR)
-- Author:  Adam McInnis

-- Changelog:
-- v1.1 - added bugfix for alt-pistol breaking glass causing hang.

apiRequest(1.1)	-- request version 1.1 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()
local gpr = require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

local L1 =  -- main
	function()
		emuObj.ThrottleMax()
	end
	
local L2 =  -- main
	function()
		emuObj.ThrottleNorm()
	end
	
local load1 = eeObj.AddHook(0x1E53B0, 0x27bdfc60, L1) -- loading_init
local load2 = eeObj.AddHook(0x1E63B0, 0x27bdffe0, L2) -- loading_close

-- Widescreen support --
eeInsnReplace(0x18C4B8, 0x00000000, 0x3c013f40) -- gr_setup_3d
eeInsnReplace(0x18C4F8, 0x00000000, 0x4481f000) -- gr_setup_3d
eeInsnReplace(0x18C65C, 0x00000000, 0x461ea502) -- gr_setup_3d
eeInsnReplace(0x18C664, 0x00000000, 0x461ead43) -- gr_setup_3d
eeInsnReplace(0x1A2F5C, 0x44826000, 0x461e0303) -- shadow_ngps_render_and_copy
eeInsnReplace(0x1A3038, 0x3c024334, 0x3c024309) -- shadow_ngps_render_and_copy

emuObj.SetDisplayAspectWide()

-- GAME BUG FIXES --

local B1 = function()
	-- if using Pistol on Glass in Public Information Building, causes to crash when s0 is set incorrectly.
	-- if too big then set s0 to 0 to bypass function.
	local s0 = eeObj.GetGpr(gpr.s0)

	if s0 > 0x1000000 then
		eeObj.SetGpr(gpr.s0, 0)
	end
end
local bugfix = eeObj.AddHook(0x2ae750, 0x8c700018, B1) -- g_decal_add_internal