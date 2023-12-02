require("ee-gpr-alias")
apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

-- bug#8201
-- this game clear sound handlers if something errant situation happened.
-- just remove clearing memory code from the error check-ups.
eeInsnReplace(  0x1f71e8,	0xac400000, 0 ) -- 	sw	zero,0(v0)
eeInsnReplace(  0x1f7200,	0xae000000, 0 ) -- 	sw	zero,0(s0)

local eeObj = getEEObject()
local emuObj = getEmuObject()

local patcher = function()

--16:9 Widescreen

--Title Menu
eeObj.WriteMem32(0x206E1500,0x43BA0000) --43F80000 - Title Menu Master X FOV
eeObj.WriteMem32(0x206E1520,0x3F206D3A) --3EF0A3D7 - Title Menu Master Y FOV

--Crush-O-Rama Camera Distance (normally based on X FOV)
eeObj.WriteMem32(0x2011F52C,0x00000000) --4615BDC2 - Crush-O-Rama Camera Distance Fix #1
eeObj.WriteMem32(0x2011F564,0x00000000) --46020002 - Crush-O-Rama Camera Distance Fix #2

--1 Player
eeObj.WriteMem32(0x206E12C0,0x43900000) --43C00000 - 1P Master X FOV
eeObj.WriteMem32(0x206E12E0,0x3F206D3A) --3EF0A3D7 - 1P Master Y FOV
eeObj.WriteMem32(0x206E1680,0x43900000) --43C00000 - Unified Master X FOV
eeObj.WriteMem32(0x206E16A0,0x3F206D3A) --3EF0A3D7 - Unified Master Y FOV
--eeObj.WriteMem32(0x10143060,0x0000C33A) --3C01C30A - 1P + Unified Master X P1 HUD #1
--eeObj.WriteMem32(0x10143064,0x00006666) --34214A3D - 1P + Unified Master X P1 HUD #2
--eeObj.WriteMem32(0x10144390,0x0000001A) --24050023 - 1P + Unified P1 "WINS #" X Position (35 -> 26)
--eeObj.WriteMem32(0x10145ED4,0x0000001E) --24050028 - 1P + Unified P1 Pickup Notification X Position (40 -> 30)
--eeObj.WriteMem32(0x101D1E4C,0x00000208) --240501E0 - 1P Core Meltdown "#" Timer X Position (480 -> 520)


end

emuObj.AddVsyncHook(patcher)