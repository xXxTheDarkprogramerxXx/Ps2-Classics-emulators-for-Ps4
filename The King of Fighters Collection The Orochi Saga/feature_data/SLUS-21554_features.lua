-- Lua 5.3
-- Titles: The King of Fighters Collection - The Orochi Saga
-- Features version: 1.00
-- Author: David Haywood, Warren Davis
-- Date: March/April 2017

--[[  

Notes:

The intro sequence (SNK logo, movie) only plays ONCE, on startup, never again, no matter how long you leave things in attract mode
this works to our advantage.  For this reason it's probably easiest to have the current scanlines / bezel options kick in immediately
after the SNK logo.


FEATURE SCRIPT : Rom Base is is set to 0 as soon as you select 'return to main menu' although any music that is playing at the time
continues to play until you confirm the 'save to memory card' choice, this might not work to our advantage.

Rom base is set to 00020000 then the actual value as soon as you select a game from the main menu.

text base and RAM base get set as soon as the actual emulation starts for each game.


Sprites
0 SNK logo
1 Bezel

2 Art Mode notification
3 Scan Mode notification

4 Fight stick notification
5 Fight stick notification
6 Fight stick notification
7 Fight stick notification


Requested volume adjustments

Intro 100% -> 79.43%
Games 100% -> 70.79%

--]]

-- 1 for US
-- 2 for Europe
local Region = 1


apiRequest(2.0)	-- request version 2.0 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()
local gsObj     = getGsObject()

-- hangs on black screen with some other language settings (eg Japanese)
emuObj.SetPs2Lang(1)

local gpr = require("ee-gpr-alias")
local kFilterMode, kWrapMode, kBlendMultiplier, kBlendFunc = require("sprite")
local PadConnectType = require("pad-connect-type")

HIDPad_Enable()

-- NEEDS HOOKING UP
local OptionsMenuActive = 0
local RestoreNewMenus = false		-- WBD keep new menus from reappearing when Player Control menu goes away

-- should these be 1-x ?
local INTROVOLUME = 0.375                  --WBD adjusted, was 0.7943  
local GAMEVOLUME = 0.39                    --WBD adjusted, was 0.7079

local SaveData = emuObj.LoadConfig(0)

if SaveData.vid_mode == nil then
	SaveData.vid_mode       = 0
end

if SaveData.vid_scanlines == nil then
	SaveData.vid_scanlines  = 0
end

local vid_modeOptions = {"NONE", "ART1", "ART2"}
local vid_scanlineOptions = {"OFF", "ON"}
local vid_mode = SaveData.vid_mode
local vid_scanlines = SaveData.vid_scanlines

local snklogo = 0

--print (string.format("_NOTE: STARTING Region %d", Region))

-----------------------
-- Video Options
-----------------------

local sprite_snklogo = getSpriteObject(0)
local sprite_bezel = getSpriteObject(1)
local sprite_artmenu = getSpriteObject(2)
local sprite_scanmenu = getSpriteObject(3)

-- Notifications should be assigned to two unused sprite slots.  Since we want them to
-- be displayed on top of everything else, they should be the highest sprites in the list.
local spr_p1_notify = getSpriteObject(4)
local spr_p2_notify = getSpriteObject(5)
local spr_p1d_notify = getSpriteObject(6)
local spr_p2d_notify = getSpriteObject(7)

-- note: Texture 0 is fixed as the PS2 scanout.
local texture1 = getTextureObject(1)
local texture2 = getTextureObject(2)
local texture3 = getTextureObject(3)
local texture4 = getTextureObject(4)
local texture5 = getTextureObject(5)
local texture6 = getTextureObject(6)
local texture7 = getTextureObject(7)
--local texture8 = getTextureObject(8)	-- WBD not needed

-- ------------------------------------------------------------
local STATE_STOPPED		= 0
local STATE_RUNNING		= 1

local notify_ypos = 24
local notify_p1_xsize = 0
local notify_p2_xsize = 0
local notify_p1d_xsize = 0
local notify_p2d_xsize = 0
local notify_ysize = 0

local notify_frames_p1 = 0
local notify_frames_p2 = 0
local notify_animstate_p1 = STATE_STOPPED
local notify_animstate_p2 = STATE_STOPPED

local connected_p1 = 47
local connected_p2 = 47
local blink_on_p1 = true
local blink_on_p2 = true

--[[ Menu notifications --]]

local texture9 = getTextureObject(9)
local texture10 = getTextureObject(10)
local texture11 = getTextureObject(11)
local texture12 = getTextureObject(12)
local texture13 = getTextureObject(13)


local extra_menu_h = 0
local extra_menu_w = 0

-- adjust these?
local artmenu_ypos = 770		-- adjusted by WBD
local scanmenu_ypos = artmenu_ypos + 36

local menu_xpos = 600			-- adjusted by WBD


HideArtMenu = function()
	sprite_artmenu.Disable()
	--[[ 	WBD  added Disable rather than position offscreen
	sprite_artmenu.SetPosXY(-1 - extra_menu_w, artmenu_ypos)   -- full obscured
	sprite_artmenu.SetSizeXY(extra_menu_w,extra_menu_h)
	sprite_artmenu.SetPosUV(0,0)
	sprite_artmenu.SetSizeUV(extra_menu_w,extra_menu_h)
	sprite_artmenu.SetBlendColorEquation(blendDefaultEquation)
	--]]

end



HideScanMenu = function()
	sprite_scanmenu.Disable()
	--[[ 	WBD  added Disable rather than position offscreen
	sprite_scanmenu.SetPosXY(-1 - extra_menu_w, scanmenu_ypos)   -- full obscured
    sprite_scanmenu.SetSizeXY(extra_menu_w,extra_menu_h)
	sprite_scanmenu.SetPosUV(0,0)
    sprite_scanmenu.SetSizeUV(extra_menu_w,extra_menu_h)
	sprite_scanmenu.SetBlendColorEquation(blendDefaultEquation)
	--]]
end




ShowArtMenu = function()
	sprite_artmenu.BindTexture(SaveData.vid_mode+9)
	sprite_artmenu.SetPosXY(menu_xpos, artmenu_ypos)
    sprite_artmenu.SetSizeXY(extra_menu_w,extra_menu_h)
	sprite_artmenu.SetPosUV(0,0)
    sprite_artmenu.SetSizeUV(extra_menu_w,extra_menu_h)
	sprite_artmenu.SetBlendColorEquation(blendDefaultEquation)
	sprite_artmenu.Enable()
end

ShowScanMenu = function()
	sprite_scanmenu.BindTexture(SaveData.vid_scanlines+12)
	sprite_scanmenu.SetPosXY(menu_xpos, scanmenu_ypos)
    sprite_scanmenu.SetSizeXY(extra_menu_w,extra_menu_h)
	sprite_scanmenu.SetPosUV(0,0)
    sprite_scanmenu.SetSizeUV(extra_menu_w,extra_menu_h)
	sprite_scanmenu.SetBlendColorEquation(blendDefaultEquation)
	sprite_scanmenu.Enable()
end


	




local update_notifications_p1 = function()

	if notify_animstate_p1 == STATE_STOPPED then 
		spr_p1_notify.Disable()
		spr_p1d_notify.Disable()
		return
	end

--	L2()

	local keyframe = 15

	notify_frames_p1 = notify_frames_p1 + 1

	if math.ceil(notify_frames_p1/keyframe) == notify_frames_p1/keyframe then blink_on_p1 = not blink_on_p1 end
	if blink_on_p1 == true then notify_ypos = 24 end
	if blink_on_p1 == false then notify_ypos = -84 end

--	print(string.format("FEATURE SCRIPT : rounded %s, floating %s, blink %s ypos %s", math.ceil(notify_frames_p1/keyframe), notify_frames_p1/keyframe, blink_on_p1, notify_ypos))
--	print(string.format("FEATURE SCRIPT : notify_frames_p1 %s", notify_frames_p1))

	if notify_frames_p1 >= 225 then
		notify_animstate_p1 = STATE_STOPPED
		notify_frames_p1 = 0
		connected_p1 = 47
	end

	if connected_p1 == true then
		spr_p1_notify.SetBlendColor(1.0,1.0,1.0,1.0)
		spr_p1_notify.SetPosXY(math.floor((1920-notify_p1_xsize)/2), notify_ypos)
		spr_p1_notify.Enable()
	end

	if connected_p1 == false then
		spr_p1d_notify.SetBlendColor(1.0,1.0,1.0,1.0)
		spr_p1d_notify.SetPosXY(math.floor((1920-notify_p1d_xsize)/2), notify_ypos)
		spr_p1d_notify.Enable()
	end
end

local update_notifications_p2 = function()

	if notify_animstate_p2 == STATE_STOPPED then 
		spr_p2_notify.Disable()
		spr_p2d_notify.Disable()
		return
	end

--	L2()

	local keyframe = 15

	notify_frames_p2 = notify_frames_p2 + 1

	if math.ceil(notify_frames_p2/keyframe) == notify_frames_p2/keyframe then blink_on_p2 = not blink_on_p2 end
	if blink_on_p2 == true then notify_ypos = 24 + notify_ysize + 8 end
	if blink_on_p2 == false then notify_ypos = -84 - notify_ysize - 8 end

--	print(string.format("FEATURE SCRIPT : rounded %s, floating %s, blink %s ypos %s", math.ceil(notify_frames_p2/keyframe), notify_frames_p2/keyframe, blink_on_p2, notify_ypos))

	if notify_frames_p2 >= 225 then
		notify_animstate_p2 = STATE_STOPPED
		notify_frames_p2 = 0
		connected_p2 = 47
	end

--	print(string.format("FEATURE SCRIPT : connected_p1 %s, connected_p2 %s", connected_p1, connected_p2))

	if connected_p2 == true then
		spr_p2_notify.SetBlendColor(1.0,1.0,1.0,1.0)
		spr_p2_notify.SetPosXY(math.floor((1920-notify_p2_xsize)/2), notify_ypos)
		spr_p2_notify.Enable()
	end

	if connected_p2 == false then
		spr_p2d_notify.SetBlendColor(1.0,1.0,1.0,1.0)
		spr_p2d_notify.SetPosXY(math.floor((1920-notify_p2d_xsize)/2), notify_ypos)
		spr_p2d_notify.Enable()
	end

end

-- slot can range from 0 to 3, for users 1 thru 4.
-- pad_type can be either:  DS4, REMOTE_DS4, REMOTE_VITA, or HID
local onHIDPadEvent = function(slot, connected, pad_type)
	spr_p1_notify.Disable()
	spr_p1d_notify.Disable()
	spr_p2_notify.Disable()
	spr_p2d_notify.Disable()
--	print(string.format("FEATURE SCRIPT : slot %s, connected %s, pad_type %s", slot, connected, pad_type))
	if pad_type == PadConnectType.HID then
		notify_frames_p1 = 0
		notify_frames_p2 = 0
		blink_on_p1 = true
		blink_on_p2 = true
		if slot == 0 then 
			connected_p1 = connected
			notify_animstate_p1 = STATE_RUNNING
		end
		if slot == 1 then 
			connected_p2 = connected 
			notify_animstate_p2 = STATE_RUNNING
		end
	end
end


local scanlineParams = {
	240.0,		-- float scanlineCount
   	0.7,		-- float scanlineHeight;
	1.5,        -- float scanlineBrightScale;
	0.5,        -- float scanlineAlpha;
	0.5         -- float vignetteStrength;
}

-- ---------------------------------------------------
-- Full Screen (480p) NoFX
-- ---------------------------------------------------

local original_mode = function()
	if snklogo == 1 then
		sprite_snklogo.BindTexture(3)
		sprite_snklogo.SetPosXY(0,0)
		sprite_snklogo.SetSizeXY(1920,1080)
		sprite_snklogo.SetPosUV(0,0)
		sprite_snklogo.SetSizeUV(1920,1080)
	else
		sprite_snklogo.BindTexture(0)
		sprite_snklogo.BindFragmentShader(0)
		sprite_snklogo.SetPosXY((1920-1440)/2,0)
		sprite_snklogo.SetSizeXY(1440,1080)
	end
	sprite_snklogo.Enable()
	sprite_bezel.Disable()
end

-- ---------------------------------------------------
-- Full Screen + ScanLines (480p)
-- ---------------------------------------------------

local scanlines_mode = function()
	if snklogo == 1 then
		sprite_snklogo.BindTexture(3)
		sprite_snklogo.SetPosXY(0,0)
		sprite_snklogo.SetSizeXY(1920,1080)
		sprite_snklogo.SetPosUV(0,0)
		sprite_snklogo.SetSizeUV(1920,1080)
	else
		sprite_snklogo.BindTexture(0)
		sprite_snklogo.SetPosXY((1920-1440)/2,0)
		sprite_snklogo.SetSizeXY(1440,1080)
		sprite_snklogo.BindFragmentShader(2)
		sprite_snklogo.SetShaderParams(scanlineParams)
	end
	sprite_snklogo.Enable()
	sprite_bezel.Disable()
end

-- ---------------------------------------------------
-- Bezel NoFX
-- ---------------------------------------------------
local bezel_mode = function(bezel)
	if snklogo == 1 then
		sprite_snklogo.BindTexture(3)
		sprite_snklogo.SetPosXY(0,0)
		sprite_snklogo.SetSizeXY(1920,1080)
		sprite_snklogo.SetPosUV(0,0)
		sprite_snklogo.SetSizeUV(1920,1080)
	else
		sprite_snklogo.BindTexture(0)
		sprite_snklogo.BindFragmentShader(0)
		sprite_snklogo.SetPosXY((1920-1280)/2, (1080-896)/2)
		sprite_snklogo.SetSizeXY(1280,896)
	end
	sprite_snklogo.Enable()

	sprite_bezel.BindTexture(bezel)
	sprite_bezel.SetPosXY(0,0)
	sprite_bezel.SetSizeXY(1920,1080)
	sprite_bezel.SetPosUV(0,0)
	sprite_bezel.SetSizeUV(1920,1080)
	sprite_bezel.Enable()
end

-- ---------------------------------------------------
-- Bezel + ScanLines (480p)
-- ---------------------------------------------------

local bezel_scanlines_mode = function(bezel)
	if snklogo == 1 then
		sprite_snklogo.BindTexture(3)
		sprite_snklogo.SetPosXY(0,0)
		sprite_snklogo.SetSizeXY(1920,1080)
		sprite_snklogo.SetPosUV(0,0)
		sprite_snklogo.SetSizeUV(1920,1080)
	else
		sprite_snklogo.BindTexture(0)
		sprite_snklogo.SetPosXY((1920-1280)/2, (1080-896)/2)
		sprite_snklogo.SetSizeXY(1280,896)
		sprite_snklogo.BindFragmentShader(2)
		sprite_snklogo.SetShaderParams(scanlineParams)
	end
	sprite_snklogo.Enable()

	sprite_bezel.BindTexture(bezel)
	sprite_bezel.SetPosXY(0,0)
	sprite_bezel.SetSizeXY(1920,1080)
	sprite_bezel.SetPosUV(0,0)
	sprite_bezel.SetSizeUV(1920,1080)
	sprite_bezel.Enable()
end






local updateMode = function(mode, scanlines)
	if scanlines == 0 then
		if mode == 0 then
			original_mode()
		else
			bezel_mode(mode)
		end
	else
		if mode == 0 then
			scanlines_mode()
		else
			bezel_scanlines_mode(mode)
		end
	end
	
	local needsSave = (SaveData.vid_mode ~= mode or SaveData.vid_scanlines ~= scanlines)
	
	if needsSave == true then
		SaveData.vid_mode = mode
		SaveData.vid_scanlines = scanlines
		emuObj.SaveConfig(0, SaveData)
	end
end



-- Fight stick
local pad = function()
	updateMode(SaveData.vid_mode, SaveData.vid_scanlines)
	emuObj.AddVsyncHook(update_notifications_p1)
	emuObj.AddVsyncHook(update_notifications_p2)
end

emuObj.AddPadHook(onHIDPadEvent)
emuObj.AddEntryPointHook(pad)



--[[###################################################################################################################
#######################################################################################################################

  Adjusted Memory Read/Write operations

  when data stored in memory differs by a common offset between regions these functions are handy

###################################################################################################################--]]

-- Initial offsets based on European version
local AdjustForRegion = 0

function Adjusted_WM32(base, data)
	eeObj.WriteMem32(base + AdjustForRegion, data)
end

function Adjusted_WM16(base, data)
	eeObj.WriteMem16(base + AdjustForRegion, data)
end

function Adjusted_WM8(base, data)
	eeObj.WriteMem8(base + AdjustForRegion, data)
end

function Adjusted_WMFloat(base, data)
	eeObj.WriteMemFloat(base + AdjustForRegion, data)
end


function Adjusted_RM32(base)
	return eeObj.ReadMem32(base + AdjustForRegion)
end

function Adjusted_RM16(base)
	return eeObj.ReadMem16(base + AdjustForRegion)
end

function Adjusted_RM8(base)
	return eeObj.ReadMem8(base + AdjustForRegion)
end

function Adjusted_RMStr(base)
	return eeObj.ReadMemStr(base + AdjustForRegion)
end

function Adjusted_RMFloat(base)
	return eeObj.ReadMemFloat(base + AdjustForRegion)
end

function Adjusted_W_bitset_8(base, bit)
	local u8val = eeObj.ReadMem8(base + AdjustForRegion)
	local bitmask = 1 << bit
	u8val = u8val | bitmask
	eeObj.WriteMem8(base + AdjustForRegion, u8val)
end

function Adjusted_W_bitclear_8(base, bit)
	local u8val = eeObj.ReadMem8(base + AdjustForRegion)
	local bitmask = 1 << bit
	bitmask = bitmask ~0xff
	
	u8val = u8val & bitmask
	eeObj.WriteMem8(base + AdjustForRegion, u8val)
end

function Adjusted_R_bit_8(base, bit)	
	local u8val = eeObj.ReadMem8(base + AdjustForRegion)
	local bitmask = 1 << bit
	u8val = u8val & bitmask
	u8val = u8val >> bit
						
	return u8val
end


function NeoGeo_WM8(address, data)

	local tempaddress = address & ~3
	
	address = address & 3
	if (address==0) then
		tempaddress = tempaddress + 1
	elseif (address==1) then
		tempaddress = tempaddress + 0
	elseif (address==2) then
		tempaddress = tempaddress + 3
	elseif (address==3) then
		tempaddress = tempaddress + 2
	end
	
	eeObj.WriteMem8(tempaddress, data)
end


function NeoGeo_RM8(address)

	local tempaddress = address & ~3
	
	address = address & 3
	if (address==0) then
		tempaddress = tempaddress + 1
	elseif (address==1) then
		tempaddress = tempaddress + 0
	elseif (address==2) then
		tempaddress = tempaddress + 3
	elseif (address==3) then
		tempaddress = tempaddress + 2
	end
	
	return eeObj.ReadMem8(tempaddress)
end




local currentGame = -1
local lastRomBase = -1
local textVramBase = -1 -- address of text VRAM for emulated NeoGeo
local RamBase = -1; -- address of main ram for emulated NeoGeo


local ActivateOptionsMenu = function()
	OptionsMenuActive = 1
	
	ShowArtMenu()
	ShowScanMenu()
end

local DeActivateOptionsMenu = function()
	OptionsMenuActive = 0
	
	HideArtMenu()
	HideScanMenu()
end

--[[ 	The Player Control menus don't have room for our new bezel and scanline options,
		so remove them if they are present. (They should be present for the main Options screen
		but not for the gameplay options screens)
--]]
local PlayerCtrlMenuOn = function()
	if (OptionsMenuActive == 1) then
		RestoreNewMenus = true
		DeActivateOptionsMenu()
	end
end

--[[ 	When a Player Control menu goes away, we may need to restore our new bezel and scanline
		options. 
--]]
local PlayerCtrlMenuOff = function()
	if (RestoreNewMenus == true) then
		ActivateOptionsMenu()
	end
	RestoreNewMenus = false
end


local lastR1 = -1
local lastL1 = -1
local lastR2 = -1
local lastL2 = -1

local CheckInputs = function()
	
	-- This entire piece of code needs to be blocked out unless the menu is active and displayed
	
	if OptionsMenuActive ~= 1 then
		return
	end	
	
	local pad_bits = emuObj.GetPad()
	
	local UP		= pad_bits &  0x0010
	local DOWN		= pad_bits &  0x0040
	local LEFT		= pad_bits &  0x0080
	local RIGHT		= pad_bits &  0x0020
	local Triangle	= pad_bits &  0x1000
	local Cross		= pad_bits &  0x4000
	local Square	= pad_bits &  0x8000
	local Circle	= pad_bits &  0x2000
	local L1		= pad_bits &  0x0400
	local L2		= pad_bits &  0x0100
	local L3		= pad_bits &  0x0002
	local R1		= pad_bits &  0x0800
	local R2		= pad_bits &  0x0200
	local R3		= pad_bits &  0x0004
	local Select	= pad_bits &  0x0001
	local Start		= pad_bits &  0x0008	

	if (L2 ~= 0) and (L2 ~= lastL2) then
		--print( string.format("L2 Pressed\n" ) )
		
		vid_mode = vid_mode - 1	
		if (vid_mode<0) then vid_mode = 2 end

		updateMode(vid_mode, vid_scanlines)
		ShowArtMenu()
		
		--print( string.format("FEATURE SCRIPT: VIDEO MODE IS NOW %d\n", vid_mode ) )
	
	end
	
	if (R2 ~= 0) and (R2 ~= lastR2) then
		--print( string.format("R2 Pressed\n" ) )
		
		vid_mode = vid_mode + 1	
		if (vid_mode>2) then vid_mode = 0 end
		
		updateMode(vid_mode, vid_scanlines)
		ShowArtMenu()
		
		--print( string.format("FEATURE SCRIPT: VIDEO MODE IS NOW %d\n", vid_mode ) )
	
	end	
	
	if (L1 ~= 0) and (L1 ~= lastL1) then
		--print( string.format("L1 Pressed\n" ) )
		
		vid_scanlines = vid_scanlines - 1	
		if (vid_scanlines<0) then vid_scanlines = 1 end	
		
		updateMode(vid_mode, vid_scanlines)
		ShowScanMenu()
			
		--print( string.format("FEATURE SCRIPT: SCANLINES MODE IS NOW %d\n", vid_scanlines ) )
	
	end		
	
	if (R1 ~= 0) and (R1 ~= lastR1) then
		--print( string.format("R1 Pressed\n" ) )
		
		vid_scanlines = vid_scanlines + 1	
		if (vid_scanlines>1) then vid_scanlines = 0 end	
		
		updateMode(vid_mode, vid_scanlines)
		ShowScanMenu()
		
		--print( string.format("FEATURE SCRIPT: SCANLINES MODE IS NOW %d\n", vid_scanlines ) )	
	
	end		
	

	
	lastL1 = L1
	lastR1 = R1
	lastL2 = L2
	lastR2 = R2
end

local VsyncFunc = function()

	CheckInputs()

	local romBase = -1
	
	if Region == 1 then
		romBase = Adjusted_RM32(0x02d89bc)
	elseif Region == 2 then
		romBase = Adjusted_RM32(0x02d89bc + 0x700)
	end
	
	if (romBase ~= lastRomBase) then
		lastRomBase = romBase	
		--print( string.format("FEATURE SCRIPT : Rom Base %08x\n", romBase ) )
		
		if (romBase == 0) then
			currentGame = -1
			textVramBase = -1
			RamBase = -1
			--print( string.format("FEATURE SCRIPT : unloaded game, disable game specific trophies\n", romBase ) )
		end
		
		if (romBase == 0) then
			--print( string.format("------------------- SETTING VOLUME FOR INTRO\n" ) )
			emuObj.SetVolumes(INTROVOLUME, 1.0, 1.0);
		end
	
		if (romBase == 0x0020000) then
			--print( string.format("------------------- SETTING VOLUME FOR GAMES\n" ) )
			emuObj.SetVolumes(GAMEVOLUME, 1.0, 1.0);
		end		
		
	end
	
	if (currentGame == -1) then
	
		if (romBase ~= 0) then
		
			local checkString1 = eeObj.ReadMem32(romBase+0x100+0x0)
			local checkString2 = eeObj.ReadMem32(romBase+0x100+0x4)
			local checkString3 = eeObj.ReadMem32(romBase+0x100+0x8)
	
			--print( string.format("FEATURE SCRIPT : %08x %08x %08x", checkString1, checkString2, checkString3 ) )
		  		   
			if (checkString1 == 0x4f2d4e45) and (checkString2 == 0x4f004745) and (checkString3 == 0x00100055) then
				--print( string.format("FEATURE SCRIPT : 1994 1994 1994\n" ) )
				currentGame = 94
			end	
	
			if (checkString1 == 0x4f2d4e45) and (checkString2 == 0x4f004745) and (checkString3 == 0x00100084) then
				--print( string.format("FEATURE SCRIPT : looks like we're KOF'95ing\n" ) )
				currentGame = 95
			end	

			if (checkString1 == 0x4f2d4e45) and (checkString2 == 0x4f104745) and (checkString3 == 0x00300214) then
				--print( string.format("FEATURE SCRIPT : Once upon a 1996\n" ) )
				currentGame = 96
			end	

			if (checkString1 == 0x4f2d4e45) and (checkString2 == 0x4f104745) and (checkString3 == 0x00400232) then
				--print( string.format("FEATURE SCRIPT : it's 1997!\n" ) )
				currentGame = 97
			end	

			if (checkString1 == 0x4f2d4e45) and (checkString2 == 0x4f104745) and (checkString3 == 0x00500242) then
				--print( string.format("FEATURE SCRIPT : Slugfest of '98!\n" ) )
				currentGame = 98
			end	
				
		end
	
	end	

end

local TextFunc = function()

	if (currentGame ~= -1) then

		if (textVramBase == -1) then
		
			local base = eeObj.GetGPR(gpr.s0);
			
			local newText = base + 0xe000
			
			if (newText ~= textVramBase) then		
				--print( string.format("FEATURE SCRIPT : text base is %08x?!\n", newText ) )
				textVramBase = newText
				
				if Region==1 then
					RamBase = Adjusted_RM32(0x002d89b0)
				elseif Region==2 then
					RamBase = Adjusted_RM32(0x002d89b0+0x700)
				end
				
				--print( string.format("FEATURE SCRIPT : RAM base is 0x%08x\n", RamBase ) )
				
			end
		
		end

	end

end


local TurnOnScaleAndInterp = function()
	local game = eeObj.ReadMem32(0x32e7f4)
	if (game == 0xffffffff) then	-- can get here from within challenge mode, don't turn on
		--print "_NOTE: Turning On Scale and Interp"
		gsObj.SetUprenderMode("2x2")
		gsObj.SetUpscaleMode("EdgeSmooth")
	end
	
end

local TurnOffScaleAndInterp = function()
	local s2 = eeObj.GetGpr(gpr.s2)
	local choice = eeObj.ReadMem16(s2+0xe8)  -- if choice is to return to main menu, no need to turn off
	if (choice < 3) then
		--print "_NOTE: Turning OFF Scale and Interp"
		gsObj.SetUprenderMode("none")
		gsObj.SetUpscaleMode("point")
	end
end

local EnterChallengeMode = function()
	TurnOffScaleAndInterp()
end

if Region == 1 then		-- US
	-- set Default AutoSave to ON
	eeInsnReplace(0x20f1d0, 0xae200014, 0xae250014)
	
	TextHook = eeObj.AddHook(0x001e0280+8,0x8c648a4c,TextFunc)
	OptOnHook1 = eeObj.AddHook(0x208d0c,0xffb20010,ActivateOptionsMenu)		-- Options menu On
	OptOffHook1 = eeObj.AddHook(0x208d8c,0xffb00000,DeActivateOptionsMenu)	-- Options menu Off
	PlCtrlOnHook = eeObj.AddHook(0x1fc8fc,0xffb20010,PlayerCtrlMenuOn)		-- Plyr Ctrl menu On
	PlCtrlOffHook = eeObj.AddHook(0x1fcbb4,0xffb00000,PlayerCtrlMenuOff)	-- Plyr Ctrl menu Off
	SclIntrpOffHook = eeObj.AddHook(0x211980,0x26b0e7f4,TurnOffScaleAndInterp)	-- Scale and Interp Off
--	SclIntrpOnHook = eeObj.AddHook(0x21a1a4,0xffb00000,TurnOnScaleAndInterp)	-- This is now called from LoadMainMenu_done
	eeObj.AddHook(0x210250, 0x24030001, EnterChallengeMode)

elseif Region == 2 then	-- EU
	eeInsnReplace(0x2107d8, 0xae200014, 0xae250014)

	TextHook = eeObj.AddHook(0x001e09a0+8,0x8c64914c,TextFunc)
	OptOnHook1 = eeObj.AddHook(0x20a10c,0xffb20010,ActivateOptionsMenu)
	OptOffHook1 = eeObj.AddHook(0x20a18c,0xffb00000,DeActivateOptionsMenu)
	PlCtrlOnHook = eeObj.AddHook(0x1fdb84,0xffb20010,PlayerCtrlMenuOn)		-- Plyr Ctrl menu On
	PlCtrlOffHook = eeObj.AddHook(0x1fde3c,0xffb00000,PlayerCtrlMenuOff)	-- Plyr Ctrl menu Off
	SclIntrpOffHook = eeObj.AddHook(0x212fc8,0x26b0eef4,TurnOffScaleAndInterp)	-- Scale and Interp Off
	SclIntrpOnHook = eeObj.AddHook(0x21b9f4,0xffb00000,TurnOnScaleAndInterp)	-- Scale and Interp On
	

end

MainHook = emuObj.AddVsyncHook(VsyncFunc)


local StartSNK = function()
	--print( string.format("FEATURE SCRIPT : ================== BEGIN SNK LOGO DISPLAY ===============\n" ) )
	
	snklogo = 1
	updateMode(SaveData.vid_mode, SaveData.vid_scanlines)
	--print( string.format("------------------- SETTING VOLUME FOR INTRO\n" ) )
	emuObj.SetVolumes(INTROVOLUME, 1.0, 1.0);
	
	emuObj.ThrottleNorm()			-- end of initial load, restore to normal speed
	--print "_NOTE: End of boot load, ThrottleNorm"
end



local StartVideo = function()
	--print( string.format("FEATURE SCRIPT : ================== BEGIN VIDEO ===============\n" ) )
	
	snklogo = 0
	updateMode(SaveData.vid_mode, SaveData.vid_scanlines)
	
end

if Region == 1 then
	emuObj.AddSectorReadHook(776480, 32, StartSNK) 
	emuObj.AddSectorReadHook(200000, 16, StartVideo) 
elseif Region == 2 then
	emuObj.AddSectorReadHook(9696, 32, StartSNK) 
	emuObj.AddSectorReadHook(580324, 16, StartVideo) 
end



-- ---------------------------------------------------
-- the global function 'Global_InitGpuResources()' is invoked by the emulator after
-- the GS has been initialized.  Textures and Shaders must be loaded here.
--
Global_InitGpuResources = function()
	-- # Fragment Shader 0 is fixed as the default no-thrills as-is renderer.
	emuObj.LoadFsShader(1, "./shader_scanlines_any_p.sb")		-- (1) = Scanlines for SNK logo
	emuObj.LoadFsShader(2, "./shader_SL480_p.sb")		-- (2) = 480P ScanLine Sim
	texture1.Load("./PS2_Classics_for_PS4_KOF98_OROCHI_1.png")
	texture2.Load("./PS2_Classics_for_PS4_KOF98_OROCHI_2.png")
	texture3.Load("./SNK_LOGO.png")
	texture4.Load("./p1.png")
	texture5.Load("./p2.png")
	texture6.Load("./p1d.png")
	texture7.Load("./p2d.png")
--	texture8.Load("./SNK_LOGO_sl.png")		WBD not needed

	local p1_w,p1_h = texture4.GetSize()
	local p2_w,p2_h = texture5.GetSize()
	local p1d_w,p1d_h = texture6.GetSize()
	local p2d_w,p2d_h = texture7.GetSize()
	
	notify_p1_xsize = p1_w
	notify_p2_xsize = p2_w
	notify_p1d_xsize = p1d_w
	notify_p2d_xsize = p2d_w
	notify_ysize = p1_h

	spr_p1_notify.BindTexture(4)
	spr_p1_notify.SetPosXY(-1 - notify_p1_xsize, notify_ypos)   -- default position is fully obscured from view
    spr_p1_notify.SetSizeXY(p1_w,p1_h)
	spr_p1_notify.SetPosUV(0,0)
    spr_p1_notify.SetSizeUV(p1_w,p1_h)
	spr_p1_notify.SetBlendColorEquation(blendDefaultEquation)

	spr_p2_notify.BindTexture(5)
	spr_p2_notify.SetPosXY(-1 - notify_p2_xsize, notify_ypos)   -- default position is fully obscured from view
    spr_p2_notify.SetSizeXY(p2_w,p1_h)
	spr_p2_notify.SetPosUV(0,0)
    spr_p2_notify.SetSizeUV(p2_w,p1_h)
	spr_p2_notify.SetBlendColorEquation(blendDefaultEquation)

	spr_p1d_notify.BindTexture(6)
	spr_p1d_notify.SetPosXY(-1 - notify_p1d_xsize, notify_ypos)   -- default position is fully obscured from view
    spr_p1d_notify.SetSizeXY(p1d_w,p1_h)
	spr_p1d_notify.SetPosUV(0,0)
    spr_p1d_notify.SetSizeUV(p1d_w,p1_h)
	spr_p1d_notify.SetBlendColorEquation(blendDefaultEquation)

	spr_p2d_notify.BindTexture(7)
	spr_p2d_notify.SetPosXY(-1 - notify_p2d_xsize, notify_ypos)   -- default position is fully obscured from view
    spr_p2d_notify.SetSizeXY(p2d_w,p1_h)
	spr_p2d_notify.SetPosUV(0,0)
    spr_p2d_notify.SetSizeUV(p2d_w,p1_h)
	spr_p2d_notify.SetBlendColorEquation(blendDefaultEquation)
	
	--[[ Additional graphics for Menu Notifications --]]
	
	texture9.Load("./menuart0.png")
	texture10.Load("./menuart1.png")
	texture11.Load("./menuart2.png")	
	texture12.Load("./menuscanoff.png")
	texture13.Load("./menuscanonn.png")

	-- all menu text replacement files are 720x34 at the moment..
	local menu_w,menu_h = texture9.GetSize()
	
	extra_menu_h = menu_h
	extra_menu_w = menu_w
	
	sprite_artmenu.BindTexture(9) -- default
	sprite_scanmenu.BindTexture(12) -- default

	--HideArtMenu()			WBD not needed
	--HideScanMenu()		WBD not needed

	DeActivateOptionsMenu()
	
end

--[[************************************************************************************

	Attempt to speed up some load times
	
****************************************************************************************  --]]


-- called when initial "Loading..." message is displayed onscreen (after Playstation 2 logo)
--
local BootLoad_start = function()
	local a1 = eeObj.GetGpr(gpr.a1)
	if (a1 == 0x389c90) then
		emuObj.ThrottleFast()
		--print "_NOTE: Start of boot load, Throttle Fast"
	end
end

--[[
--	no longer needed, as this is called from StartSNK when the SNK logo is displayed
--
local BootLoad_done = function()
	emuObj.ThrottleNorm()
	--print "_NOTE: End of boot load, ThrottleNorm"
end
]]--

-- called when the introductory video is killed and the Main Menu is loaded
--
local LoadMainMenu_start = function()
	emuObj.ThrottleFast()
	--print "_NOTE: Start of main menu load, Throttle Fast"
end

-- called when load of Main Menu is done
--
local LoadMainMenu_done = function()
	TurnOnScaleAndInterp()		-- preserve pre-existing hook at this same location
	emuObj.ThrottleNorm()
	--print "_NOTE: End of main menu load, Throttle Normal"
end


-- called when a game is selected from the main menu
--
local LoadGameFromMainMenu_start = function()
	emuObj.ThrottleFast()
	--print "_NOTE: Start game load, Throttle Fast"
end

local LoadGameFromMainMenu_done = function()
	emuObj.ThrottleNorm()
	--print "_NOTE: End of game load, Throttle Normal"
end

-- called after Player Selection when the match is loaded
-- For most games, there will be music playing and the call to ThrottleMax will be ignored.
-- However for KOF09 and Challenge mode, which have some of the longest load times, the music will
-- be killed after Player Selection.
--
local LoadIntoGameplay_start = function()
	local ra = eeObj.GetGpr(gpr.ra)			-- only speed up for a particular calling function
	if (ra == 0x1c11a0) then
		--print "_NOTE: Throttle Max"
		emuObj.ThrottleMax()
	end
end


local music_to_kill = 0xffffffff			-- will contain a handle to bg music that we want to kill during loading

-- This will detect if the Player Selection music is running for KOF98 or Challenge mode
-- We want to allow the music to play during player selection, but be killed before the match is loaded
--
local CheckMusic = function()
	music_to_kill = 0xffffffff
	local s0 = eeObj.GetGpr(gpr.s0)			-- s0 is a pointer to the music filename
	if (s0 ~= 0) then
		local music = eeObj.ReadMemStr(s0)
		--print (string.format("_NOTE: Music starting...  %s", music))
		if (music == "kof98_bgm_23.at3") then	
			music_to_kill = eeObj.GetGpr(gpr.v0)	-- save the bg handle for this music
			--print (string.format("_NOTE: We will kill this handle (%x) later", music_to_kill))
		end
	end
end


-- When the game issues a call to fade out the Player Selection music, it usually takes a very long time. This
-- will kill it quickly so we can use ThrottleMax.
--
local KillMusic = function()
	local a1 = eeObj.GetGpr(gpr.a1)
	local bgmh = eeObj.ReadMem32(0x32e394)
	--print (string.format("_NOTE: should we kill this? bgmh = %x   a1 = %x", bgmh, a1))
	if ((bgmh == a1) and (a1 == music_to_kill)) then	
		--print (string.format("_NOTE: Killing BG Music, handle = %x", bgmh))
		eeObj.SetFpr(13, 0.0)		-- kill this sound immediately
	end
end

eeObj.AddHook(0x18acac, 0x27bdfb40, BootLoad_start)		-- initial load
--eeObj.AddHook(0x1f641c, 0x8e220034, BootLoad_done) 	-- this is done in StartSNK (logo is displayed)

eeObj.AddHook(0x1ced34, 0xffb00000, LoadMainMenu_start)		-- load main menu from start screen
eeObj.AddHook(0x21a1a4, 0xffb00000, LoadMainMenu_done)

eeObj.AddHook(0x20befc, 0xffb00000, LoadGameFromMainMenu_start)		-- load game from main menu
eeObj.AddHook(0x218d2c, 0x3c040033, LoadGameFromMainMenu_done)	


eeObj.AddHook(0x195b68, 0xae42e394, CheckMusic)				-- see if we're starting music we may need to kill later
eeObj.AddHook(0x196134, 0x24060001, KillMusic)				-- force kill player selection music
eeObj.AddHook(0x1ec944, 0x3c030035, LoadIntoGameplay_start)	-- between player selection and gameplay



--[[
--	Fix vertical lines (by forcing gCurrentGamePIXX to be 320). This constant is natively 304, which
--  when divided into 640 gives you not exactly 2. This is apparently causing some rounding errors when 
--  blitting sprites. Forcing the screen width to 320 removes the problem. The side effect is that the
--  screen is horizontally compressed by a very very small amount.

local forceHorzScrnRes = function()
	eeObj.SetGpr(gpr.a3, 0x140)
	print "_NOTE: *******************************> Forcing Horz Scrn Res"
end
eeObj.AddHook(0x1dc3dc, 0x3c050033, forceHorzScrnRes)
]]--




