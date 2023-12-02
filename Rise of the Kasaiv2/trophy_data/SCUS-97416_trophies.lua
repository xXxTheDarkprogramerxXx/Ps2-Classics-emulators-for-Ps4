-- Lua 5.3
-- Title:   Rise of Kasai PS2 - SCUS-97416 (USA)
-- Author:  Ernesto Corvi

-- Changelog:

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])
require( "ee-cpr0-alias" ) -- for EE CPR

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()
local trophyObj	= getTrophyObject()

local TROPHY_PROTECTOR_OF_THE_INNOCENT  =  0 -- Unlock all trophies. (automatic)
local TROPHY_UNSUSPECTING               =  1 -- Perform two group stealth kills in one level. (tested)
local TROPHY_ALWAYS_WEAR_A_HELMET       =  2 -- Crush three enemies at once with a stack of barrels. (tested)
local TROPHY_LEGENDARY_PRECISION        =  3 -- Get 10 headshots in one level with the bow. (tested)
local TROPHY_DEATH_FROM_ABOVE           =  4 -- Stealth kill an enemy from above. (tested)
local TROPHY_GIMME_THAT                 =  5 -- Disarm 15 enemies in one level. (tested)
local TROPHY_SECOND_WIND                =  6 -- Kill ten consecutive enemies while Player's health is below 25% (tested)
local TROPHY_PUFF_PUFF_PASS             =  7 -- Stick 10 enemies with puffers in one level. (tested)
local TROPHY_RISE_OF_THE_KASAI          =  8 -- Read from the Book of Dundao at a Story Altar. (tested)
local TROPHY_WITHOUT_A_TRACE            =  9 -- Complete a level without saving. (tested)
local TROPHY_HEAVY_HANDED               = 10 -- Kill 50 enemies in one level using Baumusu's Narga. (tested)
local TROPHY_BETTER_THAN_BROTHER        = 11 -- Kill 50 enemies in one level with Tati's Bishaq. (tested)
local TROPHY_WAY_OF_THE_ELDER           = 12 -- Kill 30 enemies in one level with Griz's Kukrin. (tested)
local TROPHY_OLD_RELIABLE               = 13 -- Kill 50 enemies in one level using Rau's Broadsword. (tested)
local TROPHY_COLLECTOR_TAPUROKU         = 14 -- Collect all tukus in the Tapuroku level. (tested)
local TROPHY_COLLECTOR_NGARI            = 15 -- Collect all tukus in the Ngari level. (tested)
local TROPHY_COLLECTOR_MOUNT_BASUKU     = 16 -- Collect all tukus in the Mt. Basuku level. (tested)
local TROPHY_COLLECTOR_VOLO_MAIBISI     = 17 -- Collect all tukus in the Volo Maibisi level. (tested)
local TROPHY_COLLECTOR_VAITAKU          = 18 -- Collect all tukus in the Vaitaku level. (tested)
local TROPHY_COLLECTOR_DAI_HARU         = 19 -- Collect all tukus in the Dai Haru level. (tested)
local TROPHY_COLLECTOR_RUTU_TEI_HURU    = 20 -- Collect all tukus in the Rutu Tei Huru level. (tested)
local TROPHY_A_MERCIFUL_WARRIOR         = 21 -- Complete a level killing fewer than 10 enemies. (tested)
local TROPHY_WRATH_OF_THE_RAKUS         = 22 -- Achieve a body count of 40 in an Arena level. (tested)
local TROPHY_MAIBISIS_PET               = 23 -- Defeat the Tentacle monster for the final time. (tested)
local TROPHY_A_BREATH_OF_HOT_AIR        = 24 -- Defeat the Dragon on Mt. Basuku with Rau. (tested)
local TROPHY_A_WATCHFUL_EYE             = 25 -- Unlock all 10 movies.
local TROPHY_TOOLS_OF_THE_TRADE         = 26 -- Unlock all weapons by collecting every Tuku. (tested)
local TROPHY_ARENA_CHAMPION             = 27 -- Unlock all arena levels by completing all level challenges.
local TROPHY_UNTOUCHABLE                = 28 -- Complete a level without taking any damage. (tested)
local TROPHY_MAIBISIS_DEMISE            = 29 -- Defeat Maibisi. (tested)

-- Constants
local CHARACTER_RAU		= 0
local CHARACTER_TATI	= 1
local CHARACTER_BAUMUSU	= 2
local CHARACTER_GRIZZ	= 3


local SaveData = emuObj.LoadConfig(0)

if not next(SaveData) then
	SaveData.t  = {}
	SaveData.currentLevel = 0
	SaveData.bowHeadshots = 0
	SaveData.groupKills = 0
	SaveData.disarmCounter = 0
	SaveData.barrelKills = 0
	SaveData.BaumusuKills = 0
	SaveData.TatiKills = 0
	SaveData.GrizKills = 0
	SaveData.RauKills = 0
	SaveData.pufferStick = 0
	SaveData.gameSaved = 1
	SaveData.playerHit = 1
	SaveData.lowHealthKills = 0
	SaveData.levelKills = -1
end

function initsaves()
	local x = 0
	local needsSave = false
	for x = 0, 29 do
		if SaveData.t[x] == nil then
			SaveData.t[x] = 0
			needsSave = true
		end
	end
	
	if (SaveData.currentLevel == nil) then
		SaveData.currentLevel = 0
	end
	
	if (SaveData.bowHeadshots == nil) then
		SaveData.bowHeadshots = 0
	end
	
	if (SaveData.groupKills == nil) then
		SaveData.groupKills = 0
	end
	
	if (SaveData.disarmCounter == nil) then
		SaveData.disarmCounter = 0
	end
	
	if (SaveData.barrelKills == nil) then
		SaveData.barrelKills = 0
	end
	
	if (SaveData.BaumusuKills == nil) then
		SaveData.BaumusuKills = 0
	end
	
	if (SaveData.TatiKills == nil) then
		SaveData.TatiKills = 0
	end
	
	if (SaveData.GrizKills == nil) then
		SaveData.GrizKills = 0
	end
	
	if (SaveData.RauKills == nil) then
		SaveData.RauKills = 0
	end
	
	if (SaveData.pufferStick == nil) then
		SaveData.pufferStick = 0
	end
	
	if (SaveData.gameSaved == nil) then
		SaveData.gameSaved = 1
	end
	
	if (SaveData.playerHit == nil) then
		SaveData.playerHit = 1
	end
	
	if (SaveData.lowHealthKills == nil) then
		SaveData.lowHealthKills = 0
	end
	
	if (SaveData.levelKills == nil) then
		SaveData.levelKills = -1
	end
	
	if (needsSave == true) then
		emuObj.SaveConfig(0, SaveData)
	end
end

initsaves()

function unlockTrophy(trophy_id)
	if SaveData.t[trophy_id] ~= 1 then
		SaveData.t[trophy_id] = 1
		trophyObj.Unlock(trophy_id)
		emuObj.SaveConfig(0, SaveData)
	end
end

local function isCameo(player)
	local flags = eeObj.ReadMem32(player+0x10) -- from Obj::IsCameo
	
	if (flags & 0x10) ~= 0 then
		return true
	end
	
	return false
end

local function getPlayerCharacter()
	return eeObj.ReadMem32(0x3fdeb4) -- from fe_GetPlayerCharacter
end

local function getCharacter(player)
	return eeObj.ReadMem32(player+0x18) -- from Obj::preInit
end

local function getPlayer(globals) -- offsets from Player::GetOtherPlayer
	local characterList = eeObj.ReadMem32(globals-0x7570)
	local actor1 = eeObj.ReadMem32(characterList+0x6828)
	local actor2 = eeObj.ReadMem32(characterList+0x682c)
	local character1 = eeObj.ReadMem32(actor1+0x10)
	local character2 = eeObj.ReadMem32(actor2+0x10)
	
	if isCameo(character1) == false then
		return character1
	end
	
	return character2
end

local function resetLevelStats(level)
	SaveData.currentLevel = level
	SaveData.bowHeadshots = 0
	SaveData.groupKills = 0
	SaveData.disarmCounter = 0
	SaveData.barrelKills = 0
	SaveData.BaumusuKills = 0
	SaveData.TatiKills = 0
	SaveData.GrizKills = 0
	SaveData.RauKills = 0
	SaveData.pufferStick = 0
	SaveData.gameSaved = 0
	SaveData.playerHit = 0
	SaveData.levelKills = 0
	
	if level == 0xffffffff then
		SaveData.gameSaved = 1
		SaveData.playerHit = 1
		SaveData.levelKills = -1
	end
end

local function countBits(value)
	local count = 0
	while value > 0 do
		if (value & 1) ~= 0 then
			count = count + 1
		end
		value = value >> 1
	end
	
	return count
end

local function isPlayerHealthLow(player) -- health under 25%
	local health = eeObj.ReadMemFloat(player+0x448)
	local maxhealth = eeObj.ReadMemFloat(player+0x44c)
	local quarterHealth = maxhealth * 0.25
	
	if health < quarterHealth then
		return true
	end
	
	return false
end

local function checkKills(player)
	
	-- Level Kills
	if SaveData.levelKills >= 0 then
		SaveData.levelKills = SaveData.levelKills + 1
		emuObj.SaveConfig(0, SaveData)
	end
	
	-- Low Health Kills
	if isPlayerHealthLow(player) == true then
		SaveData.lowHealthKills = SaveData.lowHealthKills + 1
		emuObj.SaveConfig(0, SaveData)

		if SaveData.lowHealthKills >= 10 then
			unlockTrophy(TROPHY_SECOND_WIND)
		end
		
	elseif SaveData.lowHealthKills ~= 0 then
		SaveData.lowHealthKills = 0
		emuObj.SaveConfig(0, SaveData)
	end
end

local H1 =  -- Game::setCurrentLevelTukuFound
	function()
		local stack = eeObj.GetGpr(gpr.sp)
		local level = eeObj.ReadMem32(stack)
		local collected = eeObj.GetGpr(gpr.v0)
		local numTucus = countBits(collected)
				
		if (level == 0 and numTucus == 4) then
			unlockTrophy(TROPHY_COLLECTOR_TAPUROKU)
		elseif (level == 1 and numTucus == 3) then
			unlockTrophy(TROPHY_COLLECTOR_NGARI)
		elseif (level == 2 and numTucus == 4) then
			unlockTrophy(TROPHY_COLLECTOR_MOUNT_BASUKU)
		elseif (level == 4 and numTucus == 4) then
			unlockTrophy(TROPHY_COLLECTOR_VOLO_MAIBISI)
		elseif (level == 5 and numTucus == 4) then
			unlockTrophy(TROPHY_COLLECTOR_VAITAKU)
		elseif (level == 6 and numTucus == 3) then
			unlockTrophy(TROPHY_COLLECTOR_DAI_HARU)
		elseif (level == 7 and numTucus == 4) then
			unlockTrophy(TROPHY_COLLECTOR_RUTU_TEI_HURU)
		end
	end

local H2 =  -- Tentacle::Thread_Die
	function()
		if (SaveData.currentLevel == 6) then -- Dai Haru
			unlockTrophy(TROPHY_MAIBISIS_PET)
		end
	end
	
local H3 =  -- Player::RecordMeleeKill
	function()
		local player = eeObj.GetGpr(gpr.s0)
		
		if isCameo(player) == false then
			local weapon = eeObj.ReadMem8(player+0x770) -- from Actor::getCurrWeaponHier
			
			if getPlayerCharacter() == CHARACTER_BAUMUSU and weapon == 2 then -- Narga
				SaveData.BaumusuKills = SaveData.BaumusuKills + 1
				emuObj.SaveConfig(0, SaveData)
				
				if SaveData.BaumusuKills >= 50 then
					unlockTrophy(TROPHY_HEAVY_HANDED)
				end
			elseif getPlayerCharacter() == CHARACTER_TATI and weapon == 0 then -- Bishaq
				SaveData.TatiKills = SaveData.TatiKills + 1
				emuObj.SaveConfig(0, SaveData)
				
				if SaveData.TatiKills >= 50 then
					unlockTrophy(TROPHY_BETTER_THAN_BROTHER)
				end
			elseif getPlayerCharacter() == CHARACTER_RAU and weapon == 0 then -- Broadsword
				SaveData.RauKills = SaveData.RauKills + 1
				emuObj.SaveConfig(0, SaveData)
				
				if SaveData.RauKills >= 50 then
					unlockTrophy(TROPHY_OLD_RELIABLE)
				end
			end
			
			checkKills(player)
		end
	end
	
local H4 =  -- StatsTracker::ProcessStealthKillEvent
	function()
		local kind = eeObj.GetGpr(gpr.v1)
		local event = eeObj.GetGpr(gpr.a1)
		local flags = eeObj.ReadMem32(event+0x0c)
		
		if kind == 2 or kind == 3 then
			SaveData.groupKills = SaveData.groupKills + 1
			emuObj.SaveConfig(0, SaveData)
					
			if SaveData.groupKills >= 2 then
				unlockTrophy(TROPHY_UNSUSPECTING)
			end
		end

		if (flags & 0x20) ~= 0 then -- roof kill
			unlockTrophy(TROPHY_DEATH_FROM_ABOVE)
		end
		
		local globals = eeObj.GetGpr(gpr.gp)
		local player = getPlayer(globals)
		checkKills(player)
	end
	
local H5 =  -- StatsTracker::ProcessBowKillEvent
	function()
		local flags = eeObj.GetGpr(gpr.v0)
		local character = getPlayerCharacter()
				
		if character == CHARACTER_RAU and (flags & 1) ~= 0 then
			SaveData.bowHeadshots = SaveData.bowHeadshots + 1
			emuObj.SaveConfig(0, SaveData)
					
			if SaveData.bowHeadshots >= 10 then
				unlockTrophy(TROPHY_LEGENDARY_PRECISION)
			end
		elseif character == CHARACTER_GRIZZ then
			SaveData.GrizKills = SaveData.GrizKills + 1
			emuObj.SaveConfig(0, SaveData)
				
			if SaveData.GrizKills >= 30 then
				unlockTrophy(TROPHY_WAY_OF_THE_ELDER)
			end
		end
		
		local globals = eeObj.GetGpr(gpr.gp)
		local player = getPlayer(globals)
		checkKills(player)
	end

local H6 =  -- LevelManager::startLevel
	function()
		local stack = eeObj.GetGpr(gpr.sp)
		local level = eeObj.ReadMem32(stack+0x48)
		local sublevel = eeObj.ReadMem32(stack+0x4c)
		
--		print(string.format("level: %d, sub: %d", level, sublevel))
		
		if level == 0xffffffff or sublevel == 0 then
			resetLevelStats(level)
		end
		
		SaveData.currentLevel = level
		emuObj.SaveConfig(0, SaveData)
	end
	
local H7 =  -- StatsTracker::ProcessDefendEvent
	function()
		SaveData.disarmCounter = SaveData.disarmCounter + 1
		emuObj.SaveConfig(0, SaveData)
					
		if SaveData.disarmCounter >= 15 then
			unlockTrophy(TROPHY_GIMME_THAT)
		end
		
		local globals = eeObj.GetGpr(gpr.gp)
		local player = getPlayer(globals)
		checkKills(player)
	end
	
local H8 =  -- Camera::updateStoryLookTo
	function()
		unlockTrophy(TROPHY_RISE_OF_THE_KASAI)
	end
	
local H9 =  -- Dragon::Thread_Die
	function()
		local character = getPlayerCharacter()
		
		if character == CHARACTER_RAU then
			unlockTrophy(TROPHY_A_BREATH_OF_HOT_AIR)
		end
	end

local H10 =  -- TopplingRubble::Trigger_Activate
	function()
		SaveData.barrelKills = 0
		emuObj.SaveConfig(0, SaveData)
	end
	
local H11 =  -- Player::RecordEnvObjKill
	function()
		local player = eeObj.GetGpr(gpr.s0)
		if isCameo(player) == false then
			local level = SaveData.currentLevel
			
			if level == 3 or level == 5 then
				local cause = eeObj.GetGpr(gpr.a1)
				if cause == 1 then
					SaveData.barrelKills = SaveData.barrelKills + 1
					emuObj.SaveConfig(0, SaveData)
						
					if SaveData.barrelKills >= 3 then
						unlockTrophy(TROPHY_ALWAYS_WEAR_A_HELMET)
					end
				end
			end

			checkKills(player)
		end
	end
	
local H12 =  -- Puffer::CheckStickToBody
	function()
		local character = getPlayerCharacter()
		
		if character == CHARACTER_TATI then
			SaveData.pufferStick = SaveData.pufferStick + 1
			emuObj.SaveConfig(0, SaveData)
						
			if SaveData.pufferStick >= 10 then
				unlockTrophy(TROPHY_PUFF_PUFF_PASS)
			end
		end
	end
	
local H13 =  -- FlowManager::RewardIfAllTukusCollected
	function()
		local count = eeObj.GetGpr(gpr.v0)
		
		if count >= 32 then
			unlockTrophy(TROPHY_TOOLS_OF_THE_TRADE)
		end
	end
	
local H14 =  -- SpiderBoss::Thread_Die
	function()
		unlockTrophy(TROPHY_MAIBISIS_DEMISE)
	end
	
local H15 =  -- Reward::GrantReward
	function()
		local moviesUnlocked = countBits(eeObj.GetGpr(gpr.v0))
		
--		print(string.format("Movies unlocked: %d", moviesUnlocked))
		
		if moviesUnlocked >= 10 then
			unlockTrophy(TROPHY_A_WATCHFUL_EYE)
		end
	end
	
local H16 =  -- Reward::GrantReward
	function()
		local arenasUnlocked = countBits(eeObj.GetGpr(gpr.v0))
		
--		print(string.format("Arenas unlocked: %d", arenasUnlocked))
		
		if arenasUnlocked >= 10 then
			unlockTrophy(TROPHY_ARENA_CHAMPION)
		end
	end
	
local H17 =  -- ArenaHud::Update
	function()
		local arenaKills = eeObj.GetGpr(gpr.s3)
		
		if arenaKills >= 40 then
			unlockTrophy(TROPHY_WRATH_OF_THE_RAKUS)
		end
	end
	
local H18 =  -- GameSaver::SaveGameNB
	function()
		if SaveData.gameSaved == 0 then
			SaveData.gameSaved = 1
			emuObj.SaveConfig(0, SaveData)
		end
	end
	
local H19 =  -- FlowManager::FinishLevel
	function()
		if SaveData.gameSaved == 0 then
			unlockTrophy(TROPHY_WITHOUT_A_TRACE)
		end
		
		if SaveData.playerHit == 0 then
			unlockTrophy(TROPHY_UNTOUCHABLE)
		end
		
		if SaveData.levelKills >= 0 and SaveData.levelKills < 10 then
			unlockTrophy(TROPHY_A_MERCIFUL_WARRIOR)
		end
	end
	
local H20 =  -- StatsTracker::ProcessPlayerHitEvent
	function()
		if SaveData.playerHit == 0 then
			SaveData.playerHit = 1
			emuObj.SaveConfig(0, SaveData)
		end
	end
	
	
-- register hooks
local hook1 = eeObj.AddHook(0x1869a0, 0x00441025, H1)	-- Game::setCurrentLevelTukuFound
local hook2 = eeObj.AddHook(0x2bd2b0, 0xc4400050, H2)	-- Tentgrabber::CheckEndLevel (Volo Maibisi, last sublevel)
local hook3 = eeObj.AddHook(0x23b65c, 0x0220282d, H3)	-- Player::RecordMeleeKill
local hook4 = eeObj.AddHook(0x2b50b4, 0x8ca30008, H4)	-- StatsTracker::ProcessStealthKillEvent
local hook5 = eeObj.AddHook(0x2b52ac, 0x8ca20004, H5)	-- StatsTracker::ProcessBowKillEvent
local hook6 = eeObj.AddHook(0x1a46ec, 0x8fa30048, H6)	-- LevelManager::startLevel
local hook7 = eeObj.AddHook(0x2b5224, 0x24420001, H7)	-- StatsTracker::ProcessDefendEvent
local hook8 = eeObj.AddHook(0x139fc4, 0x0000282d, H8)	-- Camera::updateStoryLookTo
local hook9 = eeObj.AddHook(0x1601f8, 0x27bdffb0, H9)	-- Dragon::Thread_Die
local hook10 = eeObj.AddHook(0x2c4a58, 0x27bdffe0, H10)	-- TopplingRubble::Trigger_Activate
local hook11 = eeObj.AddHook(0x23bbf8, 0x0046280a, H11)	-- Player::RecordEnvObjKill
local hook12 = eeObj.AddHook(0x2642e8, 0x240700ff, H12)	-- Puffer::CheckStickToBody
local hook13 = eeObj.AddHook(0x171800, 0x3c03003f, H13)	-- FlowManager::RewardIfAllTukusCollected
local hook14 = eeObj.AddHook(0x29ecc0, 0x3c040040, H14)	-- SpiderBoss::Thread_Die
local hook15 = eeObj.AddHook(0x19f004, 0x00431025, H15)	-- Reward::GrantReward
local hook16 = eeObj.AddHook(0x19f030, 0x00431025, H16)	-- Reward::GrantReward
local hook17 = eeObj.AddHook(0x1880bc, 0x24030002, H17)	-- ArenaHud::Update
local hook18 = eeObj.AddHook(0x1b1008, 0x27bdffa0, H18)	-- GameSaver::SaveGameNB
local hook19 = eeObj.AddHook(0x171358, 0x0200282d, H19)	-- FlowManager::FinishLevel
local hook20 = eeObj.AddHook(0x2b53e0, 0x8ca3000c, H20)	-- StatsTracker::ProcessPlayerHitEvent

--[[

Notes:

- Trophy 2 (TROPHY_ALWAYS_WEAR_A_HELMET) can be easily completed on the 3rd sublevel of Vaitaku. Going with Grizz, you'll find an open area with barrels
hanging above 5-6 enemies. Use the right stick to quickly enable the switch and fire a Kukrin at it. You can easily kill at least 4 enemies
if done quick enough.

- Trophy 10 (TROPHY_HEAVY_HANDED) and Trophy 12 (TROPHY_OLD_RELIABLE) can be tested at the very beggining of the Vaitaku level.


]]--
