-- Lua 5.3
-- Title: Primal PS2 - SCES-51135 (Europe)
-- Author: Nicola Salmoria
-- Date: March 21, 2016


local gpr = require( "ee-gpr-alias" )

apiRequest(0.7)

local eeObj		= getEEObject()
local emuObj	= getEmuObject()


local FH1 =	-- initialize the widescreen flag
	function()
		eeObj.SetGpr(gpr.v0, 1)	-- force to enabled
		emuObj.SetDisplayAspectWide()
	end

local function updateAspect(reg)
	local isWidescreen = eeObj.GetGpr(reg)

	if isWidescreen == 0 then
		emuObj.SetDisplayAspectNormal()
	else
		emuObj.SetDisplayAspectWide()
	end
end

local FH2 =	-- set the widescreen flag
	function()
		updateAspect(gpr.a0)
	end

local FH3 =	-- restore the widescreen flag
	function()
		updateAspect(gpr.v0)
	end

local FH4 =	-- initialize display
	function()
		eeObj.SetGpr(gpr.a0, 80)	-- force to progressive
	end

local FH5 =	-- update video mode selection screen
	function()
		local gp = eeObj.GetGpr(gpr.gp)
		eeObj.WriteMem32(gp - 20476, 1)	-- force close
	end


-- register hooks

local hooks = {
	eeObj.AddHook(0x297be4, 0x2c420001, FH1),	-- <CDisplay::Initialise(void)>:
	eeObj.AddHook(0x10f408, 0x27bdffe0, FH2),	-- <COptions::SetTrueWidescreen(bool)>:
	eeObj.AddHook(0x1205fc, 0x0002102b, FH3),	-- <CSaveGame::LoadConfig(CMemFileCompressed &, bool)>:
	eeObj.AddHook(0x2979f0, 0x24040003, FH4),	-- <CDisplay::Initialise(void)>:
	eeObj.AddHook(0x129fec, 0x27bdff90, FH5),	-- <CVideoModeSelect::UpdateChooseScreen(void)>:
}

-- don't render the video mode selection screen
eeInsnReplace(0x12a418, 0x10400096, 0x10000096)	-- <CVideoModeSelect::Render(void)>:	beqz -> b
