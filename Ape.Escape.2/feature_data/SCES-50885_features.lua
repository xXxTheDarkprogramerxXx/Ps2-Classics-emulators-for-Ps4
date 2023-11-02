-- Lua 5.3
-- Title: Ape Escape 2 - SLES-50885 (EU) v1.00
-- Author: Tim Lindquist
-- Version 1.01
-- Date:   July 11, 2016

-- Changelog:
-- 20160711 Patched "Reset settings" to make 16:9 the default. (Bug 9826)

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.7)	-- need widescreen support

local eeObj		= getEEObject()
local emuObj	= getEmuObject()

local SaveData = emuObj.LoadConfig(0)

if not next(SaveData) then
	SaveData.wide  = 1
end

local USEWIDESCREEN_ADDRESS = 0x003e19b4

eeInsnReplace(0x23C288, 0xA0400044, 0xA0430044) -- Bug 9826
eeInsnReplace(0x23C3C8, 0xA2000B66, 0xA2020B66) -- Bug 9826

local H1 =
	function()
		eeObj.WriteMem8(USEWIDESCREEN_ADDRESS, SaveData.wide)	-- enable widescreen
		if SaveData.wide == 1 then
			emuObj.SetDisplayAspectWide()
		end
		if SaveData.wide == 0 then
			emuObj.SetDisplayAspectNormal()
		end
	end

local H2 =
	function()
		local isWidescreen = eeObj.ReadMem8(USEWIDESCREEN_ADDRESS)
		
		if isWidescreen == 0 then
			emuObj.SetDisplayAspectNormal()
			SaveData.wide  = 0
			emuObj.SaveConfig(0, SaveData)
		end
		if isWidescreen == 1 then
			emuObj.SetDisplayAspectWide()
			SaveData.wide  = 1
			emuObj.SaveConfig(0, SaveData)
		end
	end

local H3 =
	function()
		emuObj.SetDisplayAspectWide()
		SaveData.wide  = 1
		emuObj.SaveConfig(0, SaveData)
	end

local hook1 = eeObj.AddHook(0x0018DE68, 0x3C020050, H1)
local hook2 = eeObj.AddHook(0x0023C970, 0x82230B66, H2)
local hook3 = eeObj.AddHook(0x0023C3CC, 0xAE000B68, H3)
