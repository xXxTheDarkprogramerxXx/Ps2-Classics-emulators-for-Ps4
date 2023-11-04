-- Lua 5.3
-- Title:   Eternal Ring - SLUS-20015_features (US)
-- Version: 1.0.0
-- Date:    January 18, 2017
-- Author:  Warren Davis, warren_davis@playstation.sony.com for SCEA and Tim Lindquist

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(1.5)	-- request version 1.5 API. Calling apiRequest() is mandatory.

local PadStick = require("PadStick")

local eeObj			= getEEObject()
local emuObj		= getEmuObject()

--[[*************************************************************
    *                                                           *
    *   Replace the DUALSHOCK On/Off Option with an Invert Y    *
    *   Axis Option (for the Right Stick only)                  *
    *   The DUALSHOCK Analog option will always be ON.          *
    *                                                           *
    *   Also, remove the Controller option from the Settings    *
    *   menu. Control Scheme A will always be use.              *    
    *                                                           *
    *************************************************************
]]--


local PadStickRemap_EternalRing_NormalY = {
	LR=PadStick.AxisRX_Pos,
	LL=PadStick.AxisRX_Neg,
	LU=PadStick.AxisLY_Neg,
	LD=PadStick.AxisLY_Pos,

	L1=PadStick.AxisLX_Neg,
	R1=PadStick.AxisLX_Pos,
	L2=PadStick.AxisRY_Neg,
	R2=PadStick.AxisRY_Pos,
}


local PadStickRemap_EternalRing_InvertY = {
	LR=PadStick.AxisRX_Pos,
	LL=PadStick.AxisRX_Neg,
	LU=PadStick.AxisLY_Neg,
	LD=PadStick.AxisLY_Pos,

	L1=PadStick.AxisLX_Neg,
	R1=PadStick.AxisLX_Pos,
	L2=PadStick.AxisRY_Pos,
	R2=PadStick.AxisRY_Neg,
}

							
--print "_NOTE: Starting ETERNAL RING features"
	
--  End_of_Load()
--  You get here after a level gets loaded.
--
--  This is where the initialization for the changes 
--  to the Options screen get done.
--
function End_of_Load()

	-- replace "DUALSHOCK 2" heading with "Invert Y Axis"
	eeObj.WriteMem32(0x35541c, 0x65766e49)	
	eeObj.WriteMem32(0x355420, 0x59207472)	
	eeObj.WriteMem32(0x355424, 0x6978412d)
	eeObj.WriteMem32(0x355428, 0x00000073)
	
	-- replace status string for DUALSHOCK On/Off with status for Invert Y Axis
	eeObj.WriteMem32(0x3555bc, 0x61656d37)
	eeObj.WriteMem32(0x3555c0, 0x5520736e)
	eeObj.WriteMem32(0x3555c4, 0x73692050)
	eeObj.WriteMem32(0x3555c8, 0x67654e20)
	eeObj.WriteMem32(0x3555cc, 0x76697461)
	eeObj.WriteMem32(0x3555d0, 0x2e592065)
	
	eeObj.WriteMem32(0x3555fc, 0x656d3737)
	eeObj.WriteMem32(0x355600, 0x20736e61)
	eeObj.WriteMem32(0x355604, 0x69205055)
	eeObj.WriteMem32(0x355608, 0x6f502073)
	eeObj.WriteMem32(0x35560c, 0x69746973)
	eeObj.WriteMem32(0x355610, 0x59206576)
	eeObj.WriteMem32(0x355614, 0x0000002e)
	
	-- replace hint string for DUALSHOCK On/Off with hint for Invert Y Axis
	eeObj.WriteMem32(0x3555d8, 0x65766e49)
	eeObj.WriteMem32(0x3555dc, 0x20737472)
	eeObj.WriteMem32(0x3555e0, 0x78412d59)
	eeObj.WriteMem32(0x3555e4, 0x002e7369)
	eeObj.WriteMem32(0x3555e8, 0x00000000)
	eeObj.WriteMem32(0x3555ec, 0x00000000)

	eeObj.WriteMem32(0x355618, 0x65766e49)
	eeObj.WriteMem32(0x35561c, 0x20737472)
	eeObj.WriteMem32(0x355620, 0x78412d59)
	eeObj.WriteMem32(0x355624, 0x002e7369)
	eeObj.WriteMem32(0x355628, 0x00000000)
	eeObj.WriteMem32(0x35562c, 0x00000000)
	
	-- add "DUALSHOCK 2" before Sensitivity heading
	eeObj.WriteMem32(0x355434, 0x4c415544)	
	eeObj.WriteMem32(0x355438, 0x434f4853)	
	eeObj.WriteMem32(0x35543c, 0x2032204b)
	
	-- Force Sensitivity to always display
	eeObj.WriteMem32(0x173b54, 0x00000000)	-- skip check so header is not greyed out
	eeObj.WriteMem32(0x173cd8, 0x24020001)  -- always load 1 so gauge not greyed out
	
	-- Keep Up/Down from skipping over Sensitivity option
	eeObj.WriteMem32(0x173e4c, 0x24030001)	
	eeObj.WriteMem32(0x173ec0, 0x24030001)	
	
	-- Replace loading of DUALSHOCK On/Off option with loading a 1 (to force it ON)
	eeObj.WriteMem32(0x101548, 0x24020001)
	eeObj.WriteMem32(0x101688, 0x24020001)	
	
	-- Disable "Controller" option on Settings menu
	eeObj.WriteMem8(0x3439a0, 2)			-- mark the Settings menu as having only 2 options

	local curSetting = eeObj.ReadMem16(0x1ade824)	-- which item on the Settings menu will highlight
	if (curSetting == 2) then				-- if highlighted setting is set to #2 (Controller menu)
		eeObj.WriteMem8(0x1ade824, 0)		--   set it to #0 (Options menu)
	end
	
	--
	--	Make sure the correct mapping in in effect after load.
	--	
	local val = eeObj.ReadMem8(0x1ff903)	-- value of the Invert Y option upon loading
	SetPadStickRemap(val)
			
end	


--	Invert_Y()
--	You get here when the Invert Y Option is changed
--
function Invert_Y()
	local val = eeObj.GetGpr(gpr.v0)		-- new value of the Invert Y option
	SetPadStickRemap(val)
end	




function SetPadStickRemap(val)
	if (val == 0) then
		emuObj.PadPressureStickRemap(0, PadStickRemap_EternalRing_NormalY)
	else
		emuObj.PadPressureStickRemap(0, PadStickRemap_EternalRing_InvertY)
	end
end


-- PadInit()
-- You get here when the controller is initialized
--
function PadInit()
	-- Force Controller Scheme A
	eeObj.WriteMem8(0x1ff8af, 0)		-- make sure controller scheme is set to A
end
	
--[[  LimestoneDeathFix

	  This function breaks at a moment where the player's max HP is about to be
	  stored in memory in a location that will later be deducted from their current HP, 
	  resulting in a catastrophic death.
	  
	  It then checks to see if we meet the criteria for the erroneous Limestone
	  Cave bug.
	  
	  The criteria are...
	  1) We need to be in the correct level or "Stage".
	  2) We need to be at the correct position in that level.
	  
	  If these criteria are met, then the catastrophic death is avoided by writing 0 to that
	  memory location, instead of the max HP.
--]]
	  
local function LimestoneDeathFix()
	local stage = eeObj.ReadMem32(0x35b824)				-- location of STAGE (level)
	--print (string.format("_NOTE: STAGE = %x", stage))
	if (stage == 7) then	
		--[[
				we are in the correct stage (limestone cave part 1 == 7)
		--]]
		local plyrY = eeObj.ReadMemFloat(0x1ff344)		-- location of PLAYER HEIGHT
		--print (string.format("_NOTE: Y POSITION = %5.3f", plyrY))
		local yDelta = plyrY + 154.2
		if (yDelta > -6.0 and yDelta < 6.0) then	
			--[[
				 we are at approximately the correct ground value
			--]]
			local plyrX = eeObj.ReadMemFloat(0x1ff340)	-- Location of PLAYER X
			local plyrZ = eeObj.ReadMemFloat(0x1ff348)  -- Location of PLAYER Z
			--print (string.format("_NOTE: X:Z POSITION = %5.3f : %5.3f", plyrX, plyrZ))
			local xDelta = plyrX - 5357.0
			local zDelta = plyrZ - 722.0
			local dist = (xDelta*xDelta + zDelta*zDelta) ^ 0.5 
			--print (string.format("_NOTE: DISTANCE = %5.3f", dist))
			if (dist < 623.0 ) then	
				--[[  
						we are in the right spot.... 
						
						a0 contains the max HP, which is about to be used to 
				        deplete the player's health. By setting a0 to 0, we
				        effectively ignore this catastrophic death.
				--]]
				eeObj.SetGPR(gpr.a0, 0)
			end			
		end
	end
end	
	
--    HOOKS
	
local hook_t1 = eeObj.AddHook(0x1032c4, 0xdfb200c0, End_of_Load)
local hook_t2 = eeObj.AddHook(0x173d90, 0xa2020073, Invert_Y)
local hook_t3 = eeObj.AddHook(0x119c0c, 0x24030001, PadInit)
local limestonefix = eeObj.AddHook(0x11d8a4, 0x24037fff, LimestoneDeathFix)  



