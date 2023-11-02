-- Lua 5.3
-- Title:   Dark Cloud 2 PS2 - SCUS-97213 (USA) v1.00
-- Author:  Nicola Salmoria

-- Changelog:
-- v0.3 20150901
-- - fixed bug #8945. Pressing R3 to turn Monica into monster form triggers trophy 4.


require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()
local trophyObj	= getTrophyObject()

-- if a print is uncommented, then that trophy trigger is untested.


-- persistent state handling
local userId = 0
local saveData = emuObj.LoadConfig(userId)

local SAVEDATA_COUNT_KILLED_WITHOUT_DYING = "Kills"


local TROPHY_A_MULTI_PURPOSE_TOOL				=  1
local TROPHY_WEAPON_SYNTHESIS					=  2
local TROPHY_TINKERING_AWAY						=  3
local TROPHY_SHAPESHIFTER						=  4
local TROPHY_BIRDS_AND_THE_BEES					=  5
local TROPHY_PLAYING_WITH_TIME					=  6
local TROPHY_A_CLASS_OF_ITS_OWN					=  7
local TROPHY_MECHANICAL_UPGRADES				=  8
local TROPHY_ALTERNATE_ALIAS					=  9
local TROPHY_TO_THE_OUTSIDE_WORLD				= 10
local TROPHY_RESURRECTION_OF_THE_GREAT_ELDER	= 11
local TROPHY_THE_SAGE_OF_THE_STARS				= 12
local TROPHY_GOODBYE_SHINGALA					= 13
local TROPHY_CONFLICT_OF_THE_PAST_AND_FUTURE	= 14
local TROPHY_WHEN_TWO_ERAS_COLLIDE				= 15
local TROPHY_THE_FORGOTTEN_ADVENTURE			= 16
local TROPHY_TAKE_A_PICTURE						= 17
local TROPHY_MONSTER_MASTER						= 18
local TROPHY_CORE_STRENGTH						= 19
local TROPHY_WHAT_YOUR_MONSTER_IS_EVOLVING		= 20
local TROPHY_FIGHTING_FOR_FUN					= 21
local TROPHY_PARTNERS_IN_TIME					= 22
local TROPHY_SUPPORTING_CAST					= 23
local TROPHY_A_ROYAL_ARSENAL					= 24
local TROPHY_LEGENDARY							= 25
local TROPHY_FINNY_FRENZY_FIRST					= 26
local TROPHY_A_TRUE_VISIONARY					= 27
local TROPHY_100_PCT_MEDALS						= 28
local TROPHY_PALACE_OF_FLOWERS					= 29
local TROPHY_GEORAMA_100_PCT					= 30


-- convert unsigned int to signed
local function asSigned(n)
	local MAXINT = 2 ^ 31
	return (n >= MAXINT and n - 2*MAXINT) or n
end

-- count elements in a table
local function tableLength(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end


-- direct access to game's save data in memory
local function getGameSaveData()
	local gp = eeObj.GetGpr(gpr.gp)
	return eeObj.ReadMem32(gp - 29964)
end

local function getSaveDataDungeon()
	return getGameSaveData() + 0x1c5b4
end

local function getUserDataManager()
	return getGameSaveData() + 0x1d2a0
end

local function getGeoramaCompletionFlags(georama)
	return getGameSaveData() + 7204 + 21776 * georama + 20560
end



local H1 =	-- prepare chapter title screen
	function()
		local chapter = eeObj.GetGpr(gpr.a3)

		if chapter == 1 then		-- chapter 2
			local trophy_id = TROPHY_TO_THE_OUTSIDE_WORLD
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif chapter == 2 then	-- chapter 3
			local trophy_id = TROPHY_RESURRECTION_OF_THE_GREAT_ELDER
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif chapter == 3 then	-- chapter 4
			local trophy_id = TROPHY_THE_SAGE_OF_THE_STARS
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif chapter == 4 then	-- chapter 5
			local trophy_id = TROPHY_GOODBYE_SHINGALA
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif chapter == 5 then	-- chapter 6
			local trophy_id = TROPHY_CONFLICT_OF_THE_PAST_AND_FUTURE
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif chapter == 6 then	-- chapter 7
			local trophy_id = TROPHY_WHEN_TWO_ERAS_COLLIDE
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end


local H2 =	-- add an item to the inventory
	function()
		local itemId = eeObj.GetGpr(gpr.a1)
		local count = eeObj.GetGpr(gpr.a2)

		if itemId == 1 then	-- Battle Wrench
			local trophy_id = TROPHY_A_MULTI_PURPOSE_TOOL
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end


local function checkHasAllMedals()
	-- number of floors in each dungeon
	local floorCounts = { 9, 16, 25, 21, 23, 29, 39 }
	-- floors in each dungeon that have time/weapon medals
	local normalFloors = {
		{ 1, 2, 3, 5, 6 },
		{ 1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 13, 14 },
		{ 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 16, 17, 19, 20, 21, 22 },
		{ 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 15, 16, 17, 18, 19 },
		{ 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 17, 18, 19, 20, 21 },
		{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 22, 23, 24, 25, 26 },
		{ 1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14, 15, 17, 18, 19, 20, 22, 23, 24, 25, 28, 29, 30,
				31, 32, 33, 34, 35, 36, 37 }
	}
	-- floors in each dungeon that have Spheda medals
	local sphedaFloors = {
		{ 1, 2, 3, 5, 6 },
		{ 1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 13, 14 },
		{ 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 16, 17, 19, 20, 21, 22 },
		{ 6, 7, 8, 10, 11, 12, 13, 15, 16 },
		{ 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 17, 18, 19, 20, 21 },
		{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 22, 23, 24, 25, 26 },
		{ 1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14, 15, 17, 18, 19, 20, 22, 23, 24, 25, 28, 29, 30,
				31, 32, 33, 34, 35, 36, 37 }
	}
	-- floors in each dungeon that have fishing medals
	local fishingFloors = {
		{ },
		{ 1, 2, 3, 4, 5, 7, 8, 9, 11, 13, 14 },
		{ 19, 20, 21, 22 },
		{ 1, 2, 3, 4, 5, 17, 18, 19 },
		{ },
		{ },
		{ }
	}
	
	local saveDataDungeon = getSaveDataDungeon()
	local floorInfoPtr = saveDataDungeon + 60

	local baseFloor = 0
	for dungeon	= 0,6 do
		-- time/weapon medals
		for _, floor in pairs(normalFloors[dungeon+1]) do
			local flags = eeObj.ReadMem8(floorInfoPtr + 20 * (floor + baseFloor) + 14)
			if (flags & 0x18) ~= 0x18 then
				return false
			end
		end
		-- spheda medals
		for _, floor in pairs(sphedaFloors[dungeon+1]) do
			local flags = eeObj.ReadMem8(floorInfoPtr + 20 * (floor + baseFloor) + 14)
			if (flags & 0x80) ~= 0x80 then
				return false
			end
		end
		-- fishing medals
		for _, floor in pairs(fishingFloors[dungeon+1]) do
			local flags = eeObj.ReadMem8(floorInfoPtr + 20 * (floor + baseFloor) + 14)
			if (flags & 0x20) ~= 0x20 then
				return false
			end
		end

		baseFloor = baseFloor + floorCounts[dungeon+1]
	end

	return true
end

local function checkMedalTrophy()
	if checkHasAllMedals() then	-- got all medals
		local trophy_id = TROPHY_100_PCT_MEDALS
--		print( string.format("trophy_id=%d", trophy_id) )
		trophyObj.Unlock(trophy_id)
	end
end

local H3A =	-- check if beaten time limit in dungeon
	function()
		local beaten = eeObj.GetGpr(gpr.v0)	-- 0 = no, 1 = got medal, 2 = improved time
		
		if beaten == 1 then	-- got medal
			checkMedalTrophy()
		end
	end

local H3B =	-- got medal for weapon/items goal
	function()
		checkMedalTrophy()
	end

local H3C =	-- got medal for fishing
	function()
		checkMedalTrophy()
	end

local H3D =	-- add medals from scripting language (used for Spheda medals)
	function()
		local increment = eeObj.GetGpr(gpr.v0)

		if increment == 1 then	-- got medal
			checkMedalTrophy()
		end
	end


local H4 =	-- change photography level
	function()
		local oldLvl = eeObj.GetGpr(gpr.s0)
		local newLvl = eeObj.GetGpr(gpr.v0)

		if oldLvl ~= newLvl and newLvl >= 7 then	-- Level 8 (NB internal level is 0-based)
			local trophy_id = TROPHY_TAKE_A_PICTURE
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end


local H5 =	-- add created invention to inventory
	function()
		local itemId = eeObj.GetGpr(gpr.a2)

		local trophy_id = TROPHY_TINKERING_AWAY
		--	print( string.format("trophy_id=%d", trophy_id) )
		trophyObj.Unlock(trophy_id)
	end


local H6 =	-- monster killed
	function()
		local monster = eeObj.GetGpr(gpr.s0)
		local monsterInfo = eeObj.ReadMem32(monster + 4432)
		local monsterId = eeObj.ReadMem16(monsterInfo + 0)

		if monsterId == 621	then -- Dark Element
			local trophy_id = TROPHY_PALACE_OF_FLOWERS
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif monsterId == 629	then -- Dark Genie
			local trophy_id = TROPHY_THE_FORGOTTEN_ADVENTURE
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end

		-- ignore some ids which are not proper monsters
		if		monsterId ~= 502 and	-- Butterfly
				monsterId ~= 503 and	-- Butterfly
				monsterId ~= 504 and	-- Butterfly
				monsterId ~= 505 and	-- Butterfly
				monsterId ~= 506 and	-- Butterfly
				monsterId ~= 507 and	-- Butterfly
				monsterId ~= 508 and	-- Butterfly
				monsterId ~= 509 and	-- Lafrescia Pistil
				monsterId ~= 1000 and	-- RoBomb
				monsterId ~= 1002 and	-- Bomb
				monsterId ~= 1003 and	-- Bomb
				monsterId ~= 1004 and	-- Bomb
				monsterId ~= 1005 and	-- Bomb
				monsterId ~= 1006 then	-- Bomb

			if saveData[SAVEDATA_COUNT_KILLED_WITHOUT_DYING] == nil then
				saveData[SAVEDATA_COUNT_KILLED_WITHOUT_DYING] = 0
			end

			saveData[SAVEDATA_COUNT_KILLED_WITHOUT_DYING] = saveData[SAVEDATA_COUNT_KILLED_WITHOUT_DYING] + 1
			emuObj.SaveConfig(userId, saveData)

			if saveData[SAVEDATA_COUNT_KILLED_WITHOUT_DYING] >= 200 then
				local trophy_id = TROPHY_FIGHTING_FOR_FUN
				--	print( string.format("trophy_id=%d", trophy_id) )
				trophyObj.Unlock(trophy_id)
			end
		end
	end


local H7 =	-- character killed
	function()
		local hp = eeObj.GetFpr(0)

		saveData[SAVEDATA_COUNT_KILLED_WITHOUT_DYING] = 0
		emuObj.SaveConfig(userId, saveData)
	end


local H8 =	-- pay for a Ridepod upgrade
	function()
		local expDiff = asSigned(eeObj.GetGpr(gpr.s0))

		if expDiff < 0 then	-- buying something
			local trophy_id = TROPHY_MECHANICAL_UPGRADES
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end


local H9 =	-- after setting invention invented flag
	function()
		local itemId = eeObj.GetGpr(gpr.a2)
		
		if itemId ~= 0 then	-- adding an item (should always be true)

			-- count number of inventions discovered
			local inventUserData = eeObj.GetGpr(gpr.a0) + 1752

			-- we hook BEFORE the new item is added to the table, so start
			-- from 1 instead of 0 to account for that
			local numInvented = 1

			for idx = 0,255 do
				local addr = inventUserData + idx * 4
				local flag = eeObj.ReadMem16(addr)
				if flag ~= 0 then
					numInvented = numInvented + 1
				end
			end

			if numInvented >= 128 then	-- invented all inventions
				local trophy_id = TROPHY_A_TRUE_VISIONARY
--				print( string.format("trophy_id=%d", trophy_id) )
				trophyObj.Unlock(trophy_id)
			end
		end
	end


local H10 =	-- put caught fish in inventory
	function()
		local fishId = eeObj.GetGpr(gpr.a1)

		if fishId == 336 then	-- Baron Garayan
			local trophy_id = TROPHY_A_CLASS_OF_ITS_OWN
--			print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end


local H11 =	-- get the outcome of fish mating
	function()
		local trophy_id = TROPHY_BIRDS_AND_THE_BEES
		--	print( string.format("trophy_id=%d", trophy_id) )
		trophyObj.Unlock(trophy_id)
	end


local H12 =	-- result of weapon synthesis
	function()
		local fusion = eeObj.GetGpr(gpr.v0)

		if fusion ~= 0 then	-- successful synthesis
			local trophy_id = TROPHY_WEAPON_SYNTHESIS
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end


-- check if item matches requested id and wasn't renamed
local function checkItemId(itemPtr, reqItemId)
	local itemId = eeObj.ReadMem16(itemPtr + 2)
	local wasRenamed = eeObj.ReadMem8(itemPtr + 5)

	if itemId == reqItemId and wasRenamed == 0 then
		return true
	else
		return false
	end
end

-- check if item is in inventory
local function checkItemInInventory(reqItemId)
	local userDataMan = getUserDataManager()
	for idx = 0,149 do
		local itemPtr = userDataMan + 108 * idx

		if checkItemId(itemPtr, reqItemId) then
			return true
		end
	end
	return false
end

-- check that the character is equipped with the requested item
-- charaNum = 0 (Max) or 1 (Monica)  NB Ridepod isn't supported
-- handNum = 0 (right) or 1 (left)
local function checkCharaEquip(charaNum, handNum, reqItemId)
	local userDataMan = getUserDataManager()
	local chara = userDataMan + 16200 + 908 * charaNum
	local itemPtr = chara + 368 + 108 * handNum

	if checkItemId(itemPtr, reqItemId) then
		return true
	else
		return false
	end
end

-- check if character acquired both required weapons
local function checkHasBothWeapons(charaNum, reqWeapon0, reqWeapon1, newWeaponId)
	if newWeaponId == reqWeapon0 then
		if		checkCharaEquip(charaNum, 1, reqWeapon1) or	-- other weapon is equipped
				checkItemInInventory(reqWeapon1) then		-- other weapon is in inventory
			return true
		end
	elseif newWeaponId == reqWeapon1 then
		if		checkCharaEquip(charaNum, 0, reqWeapon0) or	-- other weapon is equipped
				checkItemInInventory(reqWeapon0) then		-- other weapon is in inventory
			return true
		end
	end
	
	return false
end

local H13 =	-- after weapon build up
	function()
		local newWeaponId = eeObj.GetGpr(gpr.fp)

		if     checkHasBothWeapons(0,  21,  34, newWeaponId) then	-- Max: LEGEND and Supernova
			local trophy_id = TROPHY_LEGENDARY
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif checkHasBothWeapons(1,  88, 108, newWeaponId) then	-- Monica: Island King and Five-Star Armlet
			local trophy_id = TROPHY_A_ROYAL_ARSENAL
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end


local H14 =	-- recruited a NPC
	function()
		local trophy_id = TROPHY_PARTNERS_IN_TIME
		--	print( string.format("trophy_id=%d", trophy_id) )
		trophyObj.Unlock(trophy_id)

		local questData = eeObj.GetGpr(gpr.a0)
		local allRecruited = true
		-- check if all characters have been recruited
		for idx = 0,19 do
			local addr = questData + 16 * idx + 1	-- quest completed flag
			local completed = eeObj.ReadMem8(addr)
			if completed == 0 then
				allRecruited = false
			end
		end

		if allRecruited then	-- recruited all characters
			local trophy_id = TROPHY_SUPPORTING_CAST
--			print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end


local H15 =	-- renamed an item using the Name-Change Ticket
	function()
		local itemPtr = eeObj.GetGpr(gpr.v0)
		local itemType = eeObj.ReadMem16(itemPtr + 0)
		local itemId = eeObj.ReadMem16(itemPtr + 2)

		if		itemType == 3 and	-- weapon
		 		itemId ~= 302 and	-- not Fishing Rod
				itemId ~= 303 then	-- not Lure Rod
			local trophy_id = TROPHY_ALTERNATE_ALIAS
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end



local function checkAllGeoramaCompleted()
	local completionFlagOffsets = {
		{ 0, 1, 2, 5, 7, 8, 9, 10, 11, 13, 15, 16, 17 },	-- 14 not used; 3, 4, 6, 12 composite
		{ 0, 1, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 },	-- 18 not used; 2, 5, 19 composite
		{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21 },	-- 15 composite
		{ 0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 13, 14, 15, 17, 18, 19, 20, 21, 22, 24, 25 },	-- 16, 23 not used; 8, 12 composite
		{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 }
	}
	for georama = 0,4 do
		local base = getGeoramaCompletionFlags(georama)
		local offsets = completionFlagOffsets[georama+1]

		for _, offs in pairs(offsets) do
			local flag = eeObj.ReadMem8(base + offs)

			if flag == 0 then
				return false
			end
		end
	end

	return true
end

local georamaChanged = false

local H16A =	-- update Georama task completion flags
	function()
		georamaChanged = false
	end

local H16B =	-- update Georama task completion flags
	function()
		local newFlag = eeObj.GetGpr(gpr.a0)
		local addr = eeObj.GetGpr(gpr.v1) + 20560
		local oldFlag = eeObj.ReadMem8(addr)
		if newFlag ~= oldFlag and newFlag ~= 0 then	-- completed a new task
			georamaChanged = true
		end
	end

local H16C =	-- update Georama task completion flags
	function()
		if georamaChanged then
			georamaChanged = false

			local allCompleted = checkAllGeoramaCompleted()

			if allCompleted then	-- 100% in all Georamas
				local trophy_id = TROPHY_GEORAMA_100_PCT
				--	print( string.format("trophy_id=%d", trophy_id) )
				trophyObj.Unlock(trophy_id)
			end
		end
	end


local H17 =	-- buy an item from a shop
	function()
		local itemId = eeObj.GetGpr(gpr.s0)
		local count = eeObj.GetGpr(gpr.a2)

		if itemId == 252 then	-- Master Grade Core.
			local trophy_id = TROPHY_CORE_STRENGTH
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end


local H18 =	-- enable a Monster transformation badge
	function()
		local badgeId = eeObj.GetGpr(gpr.s1)
		local badgeData = eeObj.GetGpr(gpr.s0)
		local badgeBase = badgeData - 188 * (badgeId - 1)	-- badgeId is 1-based

		local allEnabled = true
		for badge = 0,11 do
			local flag = eeObj.ReadMem8(badgeBase + 188 * badge + 10)
			if flag == 0 then
				allEnabled = false
			end
		end

		if allEnabled then	-- enabled all badges
			local trophy_id = TROPHY_MONSTER_MASTER
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end


local H19 =	-- evolve a monster
	function()
		local newStep = eeObj.GetGpr(gpr.v0)

		if newStep == 3 then	-- final form
			local trophy_id = TROPHY_WHAT_YOUR_MONSTER_IS_EVOLVING
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end


local H20A =	-- switch to monster form (from main menu)
	function()
		local trophy_id = TROPHY_SHAPESHIFTER
		--	print( string.format("trophy_id=%d", trophy_id) )
		trophyObj.Unlock(trophy_id)
	end

local H20B =	-- change monster form (with R3 button)
	function()
		local formId = eeObj.GetGpr(gpr.s2)

		if formId == 3 then 	-- Monster
			local trophy_id = TROPHY_SHAPESHIFTER
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end


local H21 =	-- won a game of Spheda
	function()
		local trophy_id = TROPHY_PLAYING_WITH_TIME
		--	print( string.format("trophy_id=%d", trophy_id) )
		trophyObj.Unlock(trophy_id)
	end


local H22 =	-- won Finny Frenzy Master Class tournament
	function()
		local trophy_id = TROPHY_FINNY_FRENZY_FIRST
		--	print( string.format("trophy_id=%d", trophy_id) )
		trophyObj.Unlock(trophy_id)
	end




local DH1a =	-- check if pad2 locked
	function()
		eeObj.SetGpr(gpr.s0, 0)	-- pretend not locked
	end
local DH1b =	-- check if pad2 locked
	function()
		eeObj.SetGpr(gpr.v0, 0)	-- pretend not locked
	end
local DH1c =	-- check if pad2 locked
	function()
		eeObj.SetGpr(gpr.v0, 0)	-- pretend not locked
	end



local CH1 =	-- add value to chara HP
	function()
		eeObj.SetFpr(12, 0.0)	-- don't change
	end

local CH2 =	-- decrement ridepod power
	function()
		eeObj.SetFpr(0, 80.0)	-- keep fixed value
	end

local CH3 =	-- decrement monster HP
	function()
		eeObj.SetGpr(gpr.v1, 0)	-- kill immediately
	end

local CH4 =
	function()
		local mainScene = eeObj.GetGpr(gpr.v0)
		eeObj.WriteMem32(mainScene + 12276, 3)	-- have map and gem
	end



-- register hooks
local hook1  = eeObj.AddHook(0x2aaa20, 0x27bdfea0, H1)	-- <MenuChapterInit(mgCMemory *, int *, int, int)>:
local hook2  = eeObj.AddHook(0x19dff4, 0xffbf0050, H2)	-- <CUserDataManager::GetItem(int, int)>:
local hook3a = eeObj.AddHook(0x2f9a50, 0xdfbf0040, H3A)	-- <CDngFloorManager::IsClearMostFastDestroy(void)>:
local hook3b = eeObj.AddHook(0x2f9d74, 0x0040202d, H3B)	-- <CDngFloorManager::IsClearPractice(int)>:
local hook3c = eeObj.AddHook(0x2fa9c8, 0x0040202d, H3C)	-- <CheckFishingRecord(float)>:
local hook3d = eeObj.AddHook(0x27d128, 0x0200202d, H3D)	-- <_ADD_YARIKOMI_MEDAL(RS_STACKDATA *, int)>:
local hook4  = eeObj.AddHook(0x1ff034, 0x8e220004, H4)	-- <CInventUserData::LevelCheck(USER_PICTURE_INFO *)>:
local hook5  = eeObj.AddHook(0x204d20, 0x0040202d, H5)	-- <CMenuInvent::IsMakeObject(int, int)>:
local hook6  = eeObj.AddHook(0x1df1d0, 0xae031208, H6)	-- <CMonsterMan::CheckDamage(void)>:
local hook7a = eeObj.AddHook(0x1a0138, 0xe4620000, H7)	-- <CBattleCharaInfo::AddHp_Point(float, float)>:
local hook7b = eeObj.AddHook(0x1a0d44, 0xe4c20000, H7)	-- <CBattleCharaInfo::Step(void)>:
local hook8  = eeObj.AddHook(0x291b18, 0x44900000, H8)	-- <CShop::AddMoney(int)>
local hook9  = eeObj.AddHook(0x1ff070, 0x0005082a, H9)	-- <CInventUserData::SetCreateItemFlag(int, int)>:
local hook10 = eeObj.AddHook(0x301e60, 0x0260282d, H10)	-- <InitSuccess(CScene *)>:
local hook11 = eeObj.AddHook(0x20d220, 0x0000302d, H11)	-- <GetChildFishNo(int, int)>:
local hook12 = eeObj.AddHook(0x2395e8, 0x0040902d, H12)	-- <CBaseMenuClass::IsSpectolFusion(int, int)>:
local hook13 = eeObj.AddHook(0x2427d0, 0x8e93001c, H13)	-- <CMenuItemInfo::IsAskExtend(int, int)>:
local hook14 = eeObj.AddHook(0x31aa98, 0xa0650001, H14)	-- <CQuestData::QuestClear(int)>:
local hook15 = eeObj.AddHook(0x30c860, 0xa0430005, H15)	-- <CNameRegiMenu::KeyStep(void)>:
local hook16a= eeObj.AddHook(0x2a9fd0, 0x27bdff90, H16A)-- <CEditData::Analize(int, int *, int *)>:
local hook16b= eeObj.AddHook(0x2aa018, 0x80840000, H16B)-- <CEditData::Analize(int, int *, int *)>:
local hook16c= eeObj.AddHook(0x2aa090, 0x7bb00000, H16C)-- <CEditData::Analize(int, int *, int *)>:
local hook17 = eeObj.AddHook(0x293218, 0x02e0202d, H17)	-- <CShopMenu::KeyStep(void)>:
local hook18 = eeObj.AddHook(0x19acf4, 0x2625ffff, H18)	-- <CMonsterBox::EnableChange(int)>:
local hook19 = eeObj.AddHook(0x2b7cd0, 0x24420001, H19)	-- <CMenuMosSelect::KeyStep(void)>:
local hook20a= eeObj.AddHook(0x2b7430, 0x24020003, H20A)-- <CMenuMosSelect::KeyStep(void)>:
local hook20b= eeObj.AddHook(0x1d19e8, 0x0040902d, H20B)-- <DngMainKey(void)>:
local hook21 = eeObj.AddHook(0x276440, 0x27bdffc0, H21)	-- <_SPHIDA_GET_PRIZE(RS_STACKDATA *, int)>:
local hook22 = eeObj.AddHook(0x21990c, 0x34630020, H22)	-- <SetGyoRaceRanking(int)>:



-- cheats; disable for release
-- enable debug functions (see docs)
--local dbg1a = eeObj.AddHook(0x14adb0, 0x8e020460, DH1a)	-- <CGamePad::UpDate(void)>:
--local dbg1b = eeObj.AddHook(0x14b404, 0x8c820460, DH1b)	-- <CGamePad::On2(int)>:
--local dbg1c = eeObj.AddHook(0x14b484, 0x8c820460, DH1c)	-- <CGamePad::Down2(int)>:
-- invincibility
--local cheat1 = eeObj.AddHook(0x1a00b0, 0x8c820074, CH1)	-- <CBattleCharaInfo::AddHp_Point(float, float)>:
-- infinite power (ridepod)
--local cheat2a = eeObj.AddHook(0x1a0d14, 0x46010001, CH2)-- <CBattleCharaInfo::Step(void)>
--local cheat2b = eeObj.AddHook(0x1a0d24, 0x46010001, CH2)-- <CBattleCharaInfo::Step(void)>
-- one hit kill
--local cheat3 = eeObj.AddHook(0x1dec9c, 0x00621823, CH3)	-- <CMonsterMan::CheckDamage(void)>:
-- always have full map
--local cheat4 = eeObj.AddHook(0x19137c, 0x0040202d, CH4)	-- <MainLoop(void)>:


-- Credits

-- Trophy design and development by SCEA ISD SpecOps
-- David Thach			Senior Director
-- George Weising		Executive Producer
-- Tim Lindquist		Senior Technical PM
-- Clay Cowgill			Engineering
-- Nicola Salmoria		Engineering
-- David Haywood		Engineering
-- Warren Davis			Engineering
-- Ernesto Corvi		Engineering
-- Adam McInnis			Engineering
-- Jenny Murphy			Producer
-- David Alonzo			Assistant Producer
-- Tyler Chan			Associate Producer
-- Karla Quiros			Manager Business Finance & Ops
-- Mayene de la Cruz	Art Production Lead
-- Thomas Hindmarch		Production Coordinator
-- Special thanks to R&D, SWQA, FPQA, GFPQA, studios-all.