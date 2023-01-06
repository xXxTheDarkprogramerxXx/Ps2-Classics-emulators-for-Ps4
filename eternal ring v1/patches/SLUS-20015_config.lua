
apiRequest(1.5)

local PadStick = require("PadStick")

local emuObj = getEmuObject()

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