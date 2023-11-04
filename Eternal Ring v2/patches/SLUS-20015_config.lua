local gpr = require("ee-gpr-alias")
local PadStick = require("PadStick")

apiRequest(1.5)

local eeObj = getEEObject()
local emuObj = getEmuObject()

local patcher = function()

--X-Fov - ELF hack
--803f013c 00a88144 0045013c
eeObj.WriteMem32(0x00100fcc,0x3c013f40) --3c013f80

--Memory hack
--eeObj.WriteMem32(0x201FF100,0x43c00000)

end

emuObj.AddVsyncHook(patcher)

if 1 then
	-- bug#10361 (intro slowdown) & bug#9823 (conveyor belt effect)
	-- Use Deferred L2H except for conveyor belt effect.

	-- Unsure if other convery or similar effects are present, so use permissive match for bypassing deferral.
	L2H_SetNonDeferred({TRXREG=0x0000000900000080})		-- match any TRXPOS or BITBLTBUF

	-- Full specification of conveyor belt effect.
	-- L2H_SetNonDeferred({BITBLTBUF=0x0000000013023240,TRXPOS=0x0000000000770000,TRXREG=0x0000000900000080})
end


local PadStickRemap_EternalRing_Default = {
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
	L2=PadStick.AxisRY_Pos,
	R2=PadStick.AxisRY_Neg,
}

emuObj.PadPressureStickRemap(0, PadStickRemap_EternalRing_Default)

-- Supporting Inverted Y Axis requires smoe menu changes, and should be done via features.lua
--emuObj.PadPressureStickRemap(0, PadStickRemap_EternalRing_InvertY)