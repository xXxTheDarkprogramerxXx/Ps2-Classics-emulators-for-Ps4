-- Lua 5.3
-- Title: Harvest Moon Wonderful Life - SLUS-21171_features (US)
-- Version: 1.0.2
-- Date:    January 31, 2017
-- Author:  Warren Davis, warren_davis@playstation.sony.com for SCEA and Tim Lindquist

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

--print "_NOTE: HM:AWL SLUS-21171 Features"

local eeObj			= getEEObject()
local emuObj		= getEmuObject()
local pTime			= 0x1aac1c0


local SaveData = emuObj.LoadConfig(0)

if SaveData.wifeID == nil then
	SaveData.wifeID  = {}
end


local function initsaves_F()
	local doSave = false
	
	local x = 0
	for x = 0, 3 do
		if SaveData.wifeID[x] == nil then
			SaveData.wifeID[x] = -1
			doSave = true
		end
	end
	
	if doSave == true then
		emuObj.SaveConfig(0, SaveData)
		--print "_NOTE: ***** feature initsaves: Saving Config *****"
	end
end


--[[
	This function prevents a pointer from being overwritten 
	with zero after a call to changeModel. 
	
	If changeModel returns a non-zero value, the function does nothing.
	Otherwise it makes sure whatever the pointer value currently is 
	remains unchanged.
]]--
	
local function NullPointerFix()
	local v0Val = eeObj.GetGpr(gpr.v0)
	if (v0Val == 0) then
		local stkPtr = eeObj.GetGpr(gpr.sp) + 0x10
		local charDataMgr = eeObj.ReadMem32(stkPtr)
		local oldVal = eeObj.ReadMem32(charDataMgr + 0xb8)
		--print (string.format("_NOTE: charDataMgr = %x, oldVal = %x", charDataMgr, oldVal))
		
		eeObj.SetGpr(gpr.v0, oldVal)
	end
end

--[[	For debugging only. This is where the wife ID gets saved.
--]]	
local function setWifeID()	-- Informational only
	local wid = eeObj.GetGpr(gpr.a0)
	local time = eeObj.ReadMem32(pTime)		-- time pointer
	--print (string.format("_NOTE: setting wife character ID to %x (time = %x)", wid, time))
end


--[[	aboutToSave

		Just about to save game data to a slot (slot num in a1)
		Save the Wife ID for this slot
		
--]]
local function aboutToSave()
	local slot = eeObj.GetGpr(gpr.a1)
	if (slot < 0 or slot > 3) then
		--print (string.format("_NOTE: SAVING: Slot out of range: %x", slot))
		return
	end
	local pGameData = eeObj.GetGpr(gpr.gp)-0x53cc
	local gameData = eeObj.ReadMem32(pGameData)
	local wID = eeObj.ReadMem32(gameData + 0x14090)
	--local time = eeObj.ReadMem32(pTime)		-- time pointer
	--print (string.format("_NOTE: SAVING to slot %d, setting wife character ID to %x at time %x", slot, wID, time))
	initsaves_F()
	SaveData.wifeID[slot] = wID
	emuObj.SaveConfig(0, SaveData)			
end


--[[ justLoaded()

	We just loaded a saved game from a slot (slot num in *sp(0x30))
	
	We check the loaded wife ID.  If not 0xffffffff do nothing.
	Otherwise, if we're in Chapter 1, do nothing.
	Otherwise, we must restore the wife ID.
	
--]]	 
local function justLoaded()
	--print "_NOTE: Entering justLoaded()"
	local pSlot = eeObj.GetGpr(gpr.sp) + 0x30
	local slot = eeObj.ReadMem32(pSlot)
	if (slot < 0 or slot > 3) then
		--print (string.format("_NOTE: LOADING: Slot out of range: %x", slot))
		return
	end
	--
	--	Check loaded wifeID
	--
	local pGameData = eeObj.GetGpr(gpr.gp)-0x53cc
	local gameData = eeObj.ReadMem32(pGameData)
	local game_wID = eeObj.ReadMem32(gameData + 0x14090)
	--print (string.format("_NOTE: wife ID loaded from slot %d as %x", slot, game_wID))	
	if (game_wID == 0xffffffff) then
		local time = eeObj.ReadMem32(pTime)		-- time pointer
		--print (string.format("_NOTE: time = %x", time))	
		if (time > 0x20f6000) then					-- continue if Chapter 2 or later
			--
			--	ERROR CONDITION: Wife ID should not be 0xffffffff if Chapter 2 or later
			--
			initsaves_F()
			local saved_wID = SaveData.wifeID[slot]	-- get saved Wife ID for this slot
			if (saved_wID < 0) then
				saved_wID = 2					-- EMERGENCY: arbitrarily set a valid wifeID
				SaveData.wifeID[slot] = saved_wID
				emuObj.SaveConfig(0, SaveData)			
			end
			eeObj.WriteMem32(gameData + 0x14090, saved_wID)
			--print (string.format("_NOTE: Changing wife ID to %d", saved_wID))
		end
	end
end



local npfix = eeObj.AddHook(0x21d544, 0x8fa30010, NullPointerFix)
--local wifeID = eeObj.AddHook(0x1942f4, 0x3c010001, setWifeID)
local tosav = eeObj.AddHook(0x3b604c, 0x7fb00000, aboutToSave)
local toload = eeObj.AddHook(0x3b56a4, 0x24020001, justLoaded)

--[[	This is a fix for the Cut Scene Bug where the camera is right
		up against a wall during a couple of shots of the Chapter 4 opening
		
		The fix is triggered when a new Script::cPlayer is loaded. First we
		check to make sure this is the script with the errors.  If so, the camera
		positions for the bad shots are adjusted.
--]]

local function CutSceneFix()
	local sp =  eeObj.GetGpr(gpr.sp)
	local pScriptPlayer = eeObj.ReadMem32(sp+0x10)
	local pStepTable = eeObj.ReadMem32(pScriptPlayer+0x8)
	local test = eeObj.ReadMem32(pStepTable+0x2a04)
	--print (string.format("_NOTE: Cut Scene Fix: 1st test value = %x, Player = %x, table = %x", test,
	--	pScriptPlayer, pStepTable))
	if (test == 0x2ad) then	-- this could be the right script
		test = eeObj.ReadMem32(pStepTable+0x31b4)
		--print (string.format("_NOTE:                2st test value = %x", test))
		if (test == 0x2ad) then -- this is the right script
		--
		--	Overwrite the camera positions stored in the table for the two bad shots
		--
			--print "_NOTE:                SUCCESS... fixing"
			eeObj.WriteMem32(pStepTable+0x2a04, 0x250)	-- 1st shot X
			eeObj.WriteMem32(pStepTable+0x2a1c, 0x146)  -- 1st shot Z
			eeObj.WriteMem32(pStepTable+0x31b4, 0x250)  -- 2nd shot X
			eeObj.WriteMem32(pStepTable+0x31cc, 0x146)  -- 2nd shot Z
		end
	end
end


local cutscnfx = eeObj.AddHook(0x3ea3e8, 0xdfbf0000, CutSceneFix)  -- Script:ScriptPlayer::init()
