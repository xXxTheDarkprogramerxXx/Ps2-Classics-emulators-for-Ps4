-- Lua 5.3
-- Title: The Mark of Kri - SCES-51164 (Europe) v1.01
-- Trophies version: 1.06
-- Author: Tim Lindquist
-- Date: January 8, 2015

-- change log
-- bugfix 8693 20150706 TGL.
-- bugfix 8644(a) 20150626 TGL.
-- bugfix 8644(b) 20150630 TGL.
-- bugfix 8691. 20150702 TGL.
-- bugfix 8644(c), 8645(a), 8645(b), 8645(c) 20150707 TGL.
-- change block dectect code (no associated bug report)
-- bugfix 8645(d) 20150707 TGL.
-- bug fix 8690 20150702 TGL.
-- bug fix 8818 20150730 TGL. 
-- bugfix 8952 TGL 20150909.
-- bugfix 8644(b) 20151222 TGL. 
-- bugfix 9274. 20151223 TGL.
-- bugfix 9283. 20150106 TGL. Added more robust object identification.
-- bugfix 9283. 20150108 TGL. SCEE ObjID was different than the other regions. (0x31)

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj			= getEEObject()
local emuObj			= getEmuObject()
local trophyObj		= getTrophyObject()

-- Trophy constants

local	trophy_id							=	0
local	trophy_Fresh_Loincloth				=	1
local	trophy_Relic_Hunter					=	2
local	trophy_Mystic_Strength				=	3
local	trophy_From_the_Shadows				=	4
local	trophy_The_best_offense				=	5
local	trophy_Cheat_Sheet					=	6
local	trophy_Deadeye						=	7
local	trophy_Sharpening_the_Blade			=	8
local	trophy_Help_from_my_friends			=	9
local	trophy_Bully						=	10
local	trophy_Cleared_Ruins_of_Tiru		=	11
local	trophy_Cleared_Tapuroku				=	12
local	trophy_Cleared_Heiadoko				=	13
local	trophy_Cleared_Vaitaku				=	14
local	trophy_Cleared_Meifiti				=	15
local	trophy_Cleared_Rahtutusai			=	16
local	trophy_Undetected					=	17
local	trophy_Unscathed					=	18
local	trophy_Bow_Master					=	19
local	trophy_Your_own_medecine			=	20
local	trophy_Bareknuckle_Brawler			=	21
local	trophy_Quick_Hands					=	22
local	trophy_This_little_piggy			=	23
local	trophy_One_Fell_Swoop				=	24
local	trophy_Arena_Master					=	25
local	trophy_Art_Aficionado				=	26
local	trophy_An_End_to_the_Darkness		=	27
local	trophy_Timber						=	28
local	trophy_Master_of_Weapons			=	29

local vsync = 0

-- Pointers (derived from symbols)

local gLevelManager = 0x3eea9c

-- init tracking veariables

local	usedAxe			= 0
local	usedSword		= 0
local	usedBow			= 0
local	usedSpear		= 0
local	killed			= 0
local	fists			= 0
local 	hitID			= 0
local 	lasthitID		= 0
local 	hitInProgress	= 0
local 	killcount		= 0

local SaveData = emuObj.LoadConfig(0)

if not next(SaveData) then
	SaveData.t  = {}
end

function initsaves()
	local x = 0
	for x = 1, 29 do
		if SaveData.t[x] == nil then
			SaveData.t[x] = 0
			emuObj.SaveConfig(0, SaveData)
		end
	end
end

initsaves()

function getCurrentLevel() -- get the current level ID and translate it to the level number -- change 20150729. There are multiple level numbers per level, d'oh!
	local levelID = eeObj.ReadMem32(0x39967c)
	local save = eeObj.ReadMem32(0x39B3E4) * 10 -- find current save file number
	local x = 0
	if levelID == 0xd then x = 1 + save end
	if levelID >= 0xe and levelID <= 0x0f then x = 2 + save end 
	if levelID >= 0x10 and levelID <= 0x13 then x = 3 + save end 
	if levelID >= 0x14 and levelID <= 0x15 then x = 4 + save end
	if levelID >= 0x16 and levelID <= 0x19 then x = 5 + save end
	if levelID >= 0x1a and levelID <= 0x1c then x = 6 + save end -- change 20150730 TGL. The arena challenges level IDs are >= 0x20.
	return(x)
end

function unlockTrophy(trophy_id)
	if SaveData.t[trophy_id] ~= 1 then
		SaveData.t[trophy_id] = 1
		trophyObj.Unlock(trophy_id)
		emuObj.SaveConfig(0, SaveData)			
	end
end

local H1 = -- Check for challenges complete -- Bugfix 8645(b) 20150707 TGL. There are multiple level numbers per level, d'oh!
	function()
		local level = eeObj.ReadMem32(eeObj.GetGPR(gpr.s0) + 0x7c)
		if level == 0x0d then
			unlockTrophy(trophy_Cleared_Ruins_of_Tiru) -- Complete Baumusu's challenges for the Ruins of Tiru.
		end
		if level >= 0x0e and level <= 0x0f then
			unlockTrophy(trophy_Cleared_Tapuroku) -- Complete Baumusu's challenges for Tapuroku.
		end
		if level >= 0x10 and level <= 0x13 then
			unlockTrophy(trophy_Cleared_Heiadoko) -- Complete Baumusu's challenges for Heiadoko.
		end
		if level >= 0x14 and level <= 0x15 then
			unlockTrophy(trophy_Cleared_Vaitaku) -- Complete Baumusu's challenges for Vaitaku.
		end
		if level >= 0x16 and level <= 0x19 then
			unlockTrophy(trophy_Cleared_Meifiti) -- Complete Baumusu's challenges for Meifiti.
		end
		if level >= 0x1a and level <= 0x1c then -- bug fix 8818 20150730 TGL. The arena challenges level IDs are >= 0x20.
			unlockTrophy(trophy_Cleared_Rahtutusai) -- Complete Baumusu's challenges for Rahtutusai.
		end
	end

local H2 =
	function()
		local script = eeObj.GetGPR(gpr.a1)
		if script == 0x01fa7663 or script == 0x1f423d1 then
			unlockTrophy(trophy_Cheat_Sheet) -- Enter the Recall Hints section of the menu.
		end
	end

local H3 =
	function()
		unlockTrophy(trophy_Fresh_Loincloth) -- Change Rau's outfit.
	end

local H4 =
	function()
		local wimpy = eeObj.GetGPR(gpr.v0)
		if wimpy & 0x1000 == 0 then -- cheat was off so it's being turned on
			unlockTrophy(trophy_Bully) -- Activate the Wimpy Enemies cheat.
		end
	end

local H5 =
	function()
		local movies = eeObj.GetGPR(gpr.v0)
		if movies & 0x7FFFF == 0x7FFFF then
			unlockTrophy(trophy_Art_Aficionado) -- Unlock all movies and art.
		end
	end

local H6 =
	function()
		local arenas = eeObj.ReadMem32(0x3EEAC8)
		if arenas & 0xF00000C0 == 0xF00000C0 then
			unlockTrophy(trophy_Arena_Master) -- Unlock all arenas.
		end
	end

local H6b = -- bugfix 9274. 20151223 TGL.
	function()
		local movies = eeObj.ReadMem32(0x3EEACC)
		if movies & 0x7FFFF == 0x7FFFF then
			unlockTrophy(trophy_Art_Aficionado) -- Unlock all movies and art.
		end
	end

local H7 = -- Check pickup
	function()
		local item = eeObj.GetGPR(gpr.v1)
		local tukus = eeObj.ReadMem32(0x3EEB80)
		if item == 3 then
			unlockTrophy(trophy_Mystic_Strength) -- Collect a Rune of Power.
		end
		if item == 6 then
			unlockTrophy(trophy_Relic_Hunter) -- Find a Tuku.
			if tukus == 5 then
				unlockTrophy(trophy_Master_of_Weapons) -- Collect every Tuku to unlock all weapons for every level.
			end
		end
	end

local H8 = -- Play kill the Dark One movie
	function()
		unlockTrophy(trophy_An_End_to_the_Darkness) -- Kill the Dark One.
	end

local H9 = -- Stealth combo success
	function()
		local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
		level = level - 2
--	print (string.format("level = %s", level))
		if level >= 5 then -- bugfix 8693 20150706 TGL. Make sure it's not training mode.
			unlockTrophy(trophy_From_the_Shadows) -- Perform a group stealth attack.
		end
	end

local H10 = -- Disturb birds with Kuzo
	function()
		local waypoint = eeObj.GetGPR(gpr.a0)
		if waypoint == 0xFEB900 then
			unlockTrophy(trophy_Help_from_my_friends) -- Create a distraction by disturbing a flock of birds with Kuzo.
		end
	end

local H11 =
	function()
		unlockTrophy(trophy_This_little_piggy) -- Stealth kill an enemy after distracting them with a boar.
	end

local H12a = -- Count kills in single hit
	function()
		local objHandle = eeObj.GetGPR(gpr.v1)
		local hitpoints = eeObj.ReadMemFloat(objHandle + 0xa04) -- get object's hp
		local objID = eeObj.ReadMem32(objHandle + 0xa10) -- get object's ID (0x31 = "bones")
		if hitInProgress == 1 then
			if hitpoints <= 0 and objID == 0x31 then
				killcount = killcount + 1
			end
		end
		if killcount >= 3 then
			local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
			level = level - 2
			if level >= 5 then -- Make sure it's not training mode.
				unlockTrophy(trophy_One_Fell_Swoop) -- Kill three enemies with one strike.
				emuObj.RemoveVsyncHook(vsync)
			end
		end
	end

local H12b = -- Using fists?
	function()
		local axe = eeObj.ReadMem32(0x6beb6C) -- axe equipped
		local sword = eeObj.ReadMem32(0x6beb64) -- sword equipped
		local bow = eeObj.ReadMem32(0x6beb70) -- bow equipped
		local spear = eeObj.ReadMem32(0x6beb68) -- spear equipped
		if axe ~= 0 then usedAxe = 1 end
		if sword ~= 0 then usedSword = 1 end
		if bow ~= 0 then usedBow = 1 end
		if spear ~= 0 then usedSpear = 1 end
	end

local H13 =
	function()
		local kills = eeObj.GetGPR(gpr.s5)
		local mode = eeObj.ReadMem32(0x003eeb6c) -- 0 = Body Count, 1 = Time Attack
		if (mode == 0) and (kills >= 60) then
			unlockTrophy(trophy_Timber) -- Achieve a body count of 60 in any Body Count mode.
		end
	end

local H14 = -- Time Attack Finish
	function()
		local arenatime = eeObj.GetFPR(1)
		if arenatime < 40.0 then -- bugfix 8644(a). Float register read behavior changed since originally engineering this set!
			unlockTrophy(trophy_Quick_Hands) -- Complete a Time Attack in under 40 seconds.
		end
	end

local H14b = -- Time Attack Finish -- bugfix 8645(d) 20150707 TGL. Better spot for hook. Old spot didn't work if you had already set the record.
	function()
		if usedAxe + usedSword + usedBow + usedSpear == 0 then
			unlockTrophy(trophy_Bareknuckle_Brawler) -- Complete a Time Attack using only your fists.
		end			
	end

local H15 = -- Time attack begin
	function()
		usedAxe = 0
		usedSword = 0
		usedBow = 0
		usedSpear = 0
	end

local H16 = -- died on this level
	function()
		local x = getCurrentLevel()
		SaveData["diedlevel" .. tostring(x)] = 1
		emuObj.SaveConfig(0, SaveData)
	end

local H17 = -- Level finished
	function()
		local x = getCurrentLevel()
		local died = 0
		if SaveData["diedlevel" .. tostring(x)] == nil then
			SaveData["diedlevel" .. tostring(x)] = 0
		end
		if SaveData["diedlevel" .. tostring(x)] == 1 then
			died = 1
		end
		if died == 0 then
			unlockTrophy(trophy_Unscathed) -- Complete a level without dying.
		end			
	end

local H18 = -- Reset died flags upon save game delete
	function()
		filenum = eeObj.ReadMem32(0x1f2a8c0)
		local x = 0
		if filenum == 0x30 then
			for x = 1, 6
				do SaveData["diedlevel" .. tostring(x)] = 0
				emuObj.SaveConfig(0, SaveData)
			end
		end
		if filenum == 0x31 then
			for x = 11, 16
				do SaveData["diedlevel" .. tostring(x)] = 0
				emuObj.SaveConfig(0, SaveData)
			end
		end
		if filenum == 0x32 then
			for x = 21, 26
				do SaveData["diedlevel" .. tostring(x)] = 0 
				emuObj.SaveConfig(0, SaveData)
			end
		end
	end		

-- init progression data

if SaveData["stealth"] == nil then
   SaveData["stealth"] = 0
end

if SaveData["disarm"] == nil then
	SaveData["disarm"] = 0
end

if SaveData["bow"] == nil then
	SaveData["bow"] = 0
end

if SaveData["head"] == nil then
	SaveData["head"] = 0
end

if SaveData["block"] == nil then
	SaveData["block"] = 0
end

-- progression checks

local S1 =
	function()
		local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
		level = level - 2
	--	print (string.format("level = %s", level))
		if level >= 5 then -- Make sure it's not training mode.
			SaveData["stealth"] = SaveData["stealth"] + 1
			SaveData["disarm"] = 0
			SaveData["bow"] = 0
			SaveData["head"] = 0
			emuObj.SaveConfig(0, SaveData)
			if SaveData["stealth"] >= 10 then
				unlockTrophy(trophy_Undetected) -- Perform 10 consecutive stealth kills.
			end
		end
	end

local S2 =
	function()
		local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
		level = level - 2
	--	print (string.format("level = %s", level))
		if level >= 5 then -- Make sure it's not training mode.
			SaveData["stealth"] = SaveData["stealth"] + 1
			SaveData["disarm"] = 0
			SaveData["bow"] = 0
			SaveData["head"] = 0
			emuObj.SaveConfig(0, SaveData)
			if SaveData["stealth"] >= 10 then
				unlockTrophy(trophy_Undetected) -- Perform 10 consecutive stealth kills.
			end
		end
	end

local S3 =
	function()
		local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
		level = level - 2
	--	print (string.format("level = %s", level))
		if level >= 5 then -- Make sure it's not training mode.
			SaveData["stealth"] = SaveData["stealth"] + 1
			SaveData["disarm"] = 0
			SaveData["bow"] = 0
			SaveData["head"] = 0
			emuObj.SaveConfig(0, SaveData)
			if SaveData["stealth"] >= 10 then
				unlockTrophy(trophy_Undetected) -- Perform 10 consecutive stealth kills.
			end
		end
	end

local S4 =
	function()
		local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
		level = level - 2
	--	print (string.format("level = %s", level))
		if level >= 5 then -- Make sure it's not training mode.
			SaveData["stealth"] = SaveData["stealth"] + 1
			SaveData["disarm"] = 0
			SaveData["bow"] = 0
			SaveData["head"] = 0
			emuObj.SaveConfig(0, SaveData)
			if SaveData["stealth"] >= 10 then
				unlockTrophy(trophy_Undetected) -- Perform 10 consecutive stealth kills.
			end
		end
	end

local S5 =
	function()
		local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
		level = level - 2
	--	print (string.format("level = %s", level))
		if level >= 5 then -- Make sure it's not training mode.
			SaveData["stealth"] = SaveData["stealth"] + 1
			SaveData["disarm"] = 0
			SaveData["bow"] = 0
			SaveData["head"] = 0
			emuObj.SaveConfig(0, SaveData)
			if SaveData["stealth"] >= 10 then
				unlockTrophy(trophy_Undetected) -- Perform 10 consecutive stealth kills.
			end
		end
	end

local S6 =
	function()
		local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
		level = level - 2
	--	print (string.format("level = %s", level))
		if level >= 5 then -- Make sure it's not training mode.
			SaveData["stealth"] = SaveData["stealth"] + 1
			SaveData["disarm"] = 0
			SaveData["bow"] = 0
			SaveData["head"] = 0
			emuObj.SaveConfig(0, SaveData)
			if SaveData["stealth"] >= 10 then
				unlockTrophy(trophy_Undetected) -- Perform 10 consecutive stealth kills.
			end
		end
	end

local S7 =
	function()
		local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
		level = level - 2
	--	print (string.format("level = %s", level))
		if level >= 5 then -- Make sure it's not training mode.
			SaveData["stealth"] = SaveData["stealth"] + 1
			SaveData["disarm"] = 0
			SaveData["bow"] = 0
			SaveData["head"] = 0
			emuObj.SaveConfig(0, SaveData)
			if SaveData["stealth"] >= 10 then
				unlockTrophy(trophy_Undetected) -- Perform 10 consecutive stealth kills.
			end
		end
	end

local S8 =
	function()
		local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
		level = level - 2
	--	print (string.format("level = %s", level))
		if level >= 5 then -- Make sure it's not training mode.
			SaveData["stealth"] = SaveData["stealth"] + 1
			SaveData["disarm"] = 0
			SaveData["bow"] = 0
			SaveData["head"] = 0
			emuObj.SaveConfig(0, SaveData)
			if SaveData["stealth"] >= 10 then
				unlockTrophy(trophy_Undetected) -- Perform 10 consecutive stealth kills.
			end
		end
	end

local K1 =
	function()
		SaveData["stealth"] = 0
		SaveData["disarm"] = 0
		SaveData["bow"] = 0
		SaveData["head"] = 0
		emuObj.SaveConfig(0, SaveData)
	end

local D1 =
	function()
		local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
		level = level - 2
	--	print (string.format("level = %s", level))
		if level >= 5 then -- Make sure it's not training mode.
			SaveData["disarm"] = SaveData["disarm"] + 1
			SaveData["stealth"] = 0
			SaveData["bow"] = 0
			SaveData["head"] = 0
			emuObj.SaveConfig(0, SaveData)
			if SaveData["disarm"] >= 5 then
				unlockTrophy(trophy_Your_own_medecine) -- Disarm 5 consecutive enemies.
			end
		end
	end

local B1 =
	function()
		local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
		level = level - 2
	--	print (string.format("level = %s", level))
		if level >= 5 then -- Make sure it's not training mode.
			SaveData["bow"] = SaveData["bow"] + 1
			SaveData["stealth"] = 0
			SaveData["disarm"] = 0
			emuObj.SaveConfig(0, SaveData)
			if SaveData["bow"] >= 15 then
				unlockTrophy(trophy_Bow_Master) -- Kill 15 consecutive enemies with your bow.
			end
		end
	end

local HD1 =
	function()
		local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
		level = level - 2
	--	print (string.format("level = %s", level))
		if level >= 5 then -- Make sure it's not training mode.
			SaveData["head"] = SaveData["head"] + 1
	--		SaveData["bow"] = SaveData["bow"] + 1 -- Bugfix 8690 20150702 TGL. Removed extra bow count for head kill (already counts it).
			SaveData["stealth"] = 0
			SaveData["disarm"] = 0
			emuObj.SaveConfig(0, SaveData)
			if SaveData["head"] >= 5 then
				unlockTrophy(trophy_Deadeye) -- Perform 5 consecutive single shot kills.
			end
			if SaveData["bow"] >= 15 then
				unlockTrophy(trophy_Bow_Master) -- Kill 15 consecutive enemies with your bow.
			end
		end
	end

local BL1 =
	function()
		local who = eeObj.ReadMem32(eeObj.GetGPR(gpr.a0)) -- sluggo = 0, enemy ~= 0
		local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
		level = level - 2
	--	print (string.format("level = %s", level))
		if level >= 5 and who == 0 then -- Make sure it's not training mode. -- change 20150630 TGL. No longer credits both enemy + player blocks.
			SaveData["block"] = SaveData["block"] + 1
			emuObj.SaveConfig(0, SaveData)
			if SaveData["block"] >= 5 then
				unlockTrophy(trophy_The_best_offense) -- Block 5 consecutive enemy attacks.
			end
		end
	end

local HP1 =
	function()
		SaveData["block"] = 0
		emuObj.SaveConfig(0, SaveData)
	end

local T1 =
	function()
		local level = eeObj.ReadMem32(eeObj.ReadMem32(gLevelManager) + 0x7c)
		level = level - 2
	--	print (string.format("level = %s", level))
		if level < 5 then -- Make sure it's training mode.
			unlockTrophy(trophy_Sharpening_the_Blade) -- Complete training.
		end
	end

local checkeveryframe =
	function()
		lasthitID = hitID
		hitID = eeObj.ReadMem32(0x6bdbf4)
		if hitID >= 0x12c and hitID <= 0x1f4 -- valid range of hit types
 		and hitID == lasthitID then 
 			hitInProgress = 1
			else hitInProgress = 0
			killcount = 0
		end
	end

-- register hooks
Train = eeObj.AddHook(0x1ce8ec, 0x3463ffff, T1) -- unlockInnDoor__Fb -- bugfix 8644(c), 8645(a) 20150707 TGL. More reliable training complete trigger.
Hook1 = eeObj.AddHook(0x26ad90, 0x8c440010, H1) -- checkPendingChallengeEffect__12LevelManager
Hook2 = eeObj.AddHook(0x244e4c, 0x80a20000, H2) -- fe_WaitKey__FiPcP12ScriptThreadRt10StaticHash2Zt12StaticString1Ui32Z4dvarRb
Hook3 = eeObj.AddHook(0x2607ac, 0xaf84d260, H3) -- fe_SetOutfit__FiPcP12ScriptThreadRt10StaticHash2Zt12StaticString1Ui32Z4dvarRb -- bugfix 8692 20150708 TGL. Wrong validation value.
Hook4 = eeObj.AddHook(0x263074, 0x8f82d260, H4) -- fe_SetCheat__FiPcP12ScriptThreadRt10StaticHash2Zt12StaticString1Ui32Z4dvarRb
Hook5 = eeObj.AddHook(0x284e3c, 0x00461025, H5) -- unlockMovie__12MovieManageri
Hook6 = eeObj.AddHook(0x26fa34, 0xaf83d258, H6) -- checkLevelChallengeRewards__12LevelManager
Hook6b = eeObj.AddHook(0x26fa98, 0xa382d2ad, H6b) -- checkLevelChallengeRewards__12LevelManager
Hook7 = eeObj.AddHook(0x151ac8, 0x2c620007, H7) -- getPickup__5ActorP6Mscobj
Hook8 = eeObj.AddHook(0x101100, 0x24040025, H8) -- PlayPostLevelMovie__F6eLevelT0
Hook9 = eeObj.AddHook(0x1f15c8, 0x8e221c50, H9) -- sluggoThread_StealthCombo2S__Fv
Hook10 = eeObj.AddHook(0x1f7688, 0x0002980b, H10) -- sluggo_canSave__FP6Player
Hook11 = eeObj.AddHook(0x1f5a48, 0x44806000, H11) -- sluggoAttack_MainStrat__Fv
Hook12a = eeObj.AddHook(0x17175c, 0xac620038, H12a) -- bugfix 8644(b). More reliable method for detecting number of kills in a single hit.
Hook12b = eeObj.AddHook(0x16f2f0, 0x26940001, H12b) -- collider_checkAttackCollisionVsAllObj__FP9ObjHandle
Hook13 = eeObj.AddHook(0x29a900, 0x90950039, H13) -- Update__8ArenaHud
Hook14 = eeObj.AddHook(0x26b5e0, 0x46000824, H14) -- updateArena__12LevelManager
Hook14b = eeObj.AddHook(0x26b578, 0x3c040001, H14b) -- updateArena__12LevelManager -- bugfix 8645(d) 20150707 TGL. Better spot for hook
Hook15 = eeObj.AddHook(0x29a9bc, 0x0040402d, H15) -- Update__8ArenaHud -- bugfix 8952 TGL 20150909 (20 years!). The inst verify value was a copy/paste error.
Hook16 = eeObj.AddHook(0x10afe8, 0x27bdff90, H16) -- initDeathMode__6Camera
Hook17 = eeObj.AddHook(0x1ea688, 0xff82d250, H17) -- sluggoCheckSpawnEndOfLevel__FP5Actor
Hook18 = eeObj.AddHook(0x25c968, 0x27bdfec0, H18) -- fe_MemCardDelete__FiPcP12ScriptThreadRt10StaticHash2Zt12StaticString1Ui32Z4dvarRb

-- register hooks (for counts)
Stealth1 = eeObj.AddHook(0x1f2308, 0xa0430023, S1) -- Increment single stealth kill
Stealth2 = eeObj.AddHook(0x1f15e4, 0xa0620025, S2) -- Increment combo stealth kill
Stealth3 = eeObj.AddHook(0x1f1080, 0xa0620025, S3) -- Increment combo stealth kill
Stealth4 = eeObj.AddHook(0x1f1330, 0xa0430031, S4) -- Increment combo stealth kill
Stealth5 = eeObj.AddHook(0x1f1374, 0xa062002f, S5) -- Increment combo stealth kill
Stealth6 = eeObj.AddHook(0x1f162c, 0xa062002f, S6) -- Increment combo stealth kill
Stealth7 = eeObj.AddHook(0x1f10c8, 0xa062002f, S7) -- Increment combo stealth kill
Stealth8 = eeObj.AddHook(0x1f1ee0, 0xa0430027, S8) -- Increment wall stealth kill
KillNormal = eeObj.AddHook(0x1f771c, 0xa0430021, K1) -- Increment normal kill
DisarmKill = eeObj.AddHook(0x17852c, 0xa0430029, D1) -- Increment disarm kill
BlockAttack = eeObj.AddHook(0x188020, 0x27bdffc0, BL1) -- Block attack
GotHit = eeObj.AddHook(0x1654b8, 0x27bdfff0, HP1) -- Took damange (got hit)
BowKill = eeObj.AddHook(0x16defc, 0xa062002b, B1) -- Bow kill
HeadKill = eeObj.AddHook(0x16df4c, 0xa062003b, HD1) -- Head kill

if SaveData.t[trophy_One_Fell_Swoop] ~= 1 then
	vsync = emuObj.AddVsyncHook(checkeveryframe)
end

-- Credits

-- Trophy design and development by SCEA ISD SpecOps
-- David Thach			Senior Director
-- George Weising		Executive Producer
-- Tim Lindquist		Senior Technical PM
-- Clay Cowgill			Engineering
-- Nicola Salmoria		Engineering
-- David Haywood		Engineering
-- Warren Davis			Engineering
-- Jenny Murphy			Producer
-- David Alonzo			Assistant Producer
-- Tyler Chan			Associate Producer
-- Karla Quiros			Manager Business Finance & Ops
-- Mayene de la Cruz	Art Production Lead
-- Thomas Hindmarch		Production Coordinator
-- Special thanks to R&D, SWQA, FPQA, GFPQA, studios-all.