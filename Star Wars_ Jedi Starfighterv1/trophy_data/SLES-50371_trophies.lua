-- Lua 5.3
-- Title:   Star Wars Jedi Starfighter PS2 - SLES-50371 (EUR)
-- Author:  Ernesto Corvi

-- Changelog:
-- v1.1: disabled triggers when using cheat codes
-- v1.2: fix for full hangar trophy
-- v1.3: another fix for full hangar trophy
-- v1.4: Fixed Dragon's Den trophy trigger (Bug 8930) - Fixed No Small Task trophy trigger (Bug 8929)
-- v1.5: Fixed Flying Solo and Buddy System triggers (Bug 8978)
-- v1.6: Works around a game bug that prevented completing the No Small Task trophy (Bug 8930)
-- v1.7: Removes the need to unlock the headhunter with a cheat code to earn the Full Hangar trophy

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])
require( "ee-cpr0-alias" ) -- for EE CPR

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()
local trophyObj	= getTrophyObject()

local TROPHY_FLIGHT_SCHOOL				=  0 -- Complete all training missions.
local TROPHY_WINGMAN					=  1 -- Complete a mission using cooperative play.
local TROPHY_FLYING_SOLO				=  2 -- Unlock all one-player Bonus Missions.
local TROPHY_BUDDY_SYSTEM				=  3 -- Unlock all two-player Bonus Missions.
local TROPHY_FULL_HANGAR				=  4 -- Unlock every ship.
local TROPHY_DRAGONS_BREATH				=  5 -- Complete all Act I missions on any difficulty. (tested)
local TROPHY_DRAGONS_DEN				=  6 -- Complete all Act II missions on any difficulty.
local TROPHY_NO_SHIELD_REQUIRED			=  7 -- Complete a mission without taking any damage. (tested)
local TROPHY_A_JEDIS_WORK_IS_NEVER_DONE	=  8 -- Complete every hidden objective.
local TROPHY_JEDI_PADAWAN				=  9 -- Complete every mission on the Easy difficulty.
local TROPHY_JEDI_KNIGHT				= 10 -- Complete every mission on the Medium difficulty.
local TROPHY_JEDI_MASTER				= 11 -- Complete every mission on the Hard difficulty.
local TROPHY_NO_SMALL_TASK				= 12 -- Complete every regular and bonus objective for every stage.

local missionTags = {	"t01", "t02", "t03", "t04", "t05",
						"m01", "m02", "m03", "m04", "m05", "m06", "m08", "m09", "m10", "m11", "m12", "m13", "m14", "m15", "m16",
						"b08", "b01", "b02", "b03", "b04", "b13", "b05", "b06", "b09", "b12" }

local trainingMissionsMask = 0x1f
local regularMissionsMask = 0xfffe0
local hiddenStory1pObjectivesMask = 0xfffe0
local hidden1pObjectivesMask = 0x1fffff
local hidden2pObjectivesMask = 0xfffe0
local allStagesBonusMask = 0x3ffffff
local allStagesMissionMask = 0x3fffffff

local SaveData = emuObj.LoadConfig(0)

if not next(SaveData) then
	SaveData.t  = {}
	SaveData.easyMissions = 0
	SaveData.mediumMissions = 0
	SaveData.hardMissions = 0
	SaveData.twoplayerMissions = 0
	SaveData.bonusObjectives = 0
	SaveData.hidden1pObjectives = 0
	SaveData.hidden2pObjectives = 0
	SaveData.primaryActor = ""
	SaveData.cheater = 0
	SaveData.bonusCompleted = 0
end

function initsaves()
	local needsSave = false
	local x = 0
	for x = 0, 12 do
		if SaveData.t[x] == nil then
			SaveData.t[x] = 0
			needsSave = true
		end
	end
	
	if (SaveData.easyMissions == nil) then
		SaveData.easyMissions = 0
		needsSave = true
	end
	
	if (SaveData.mediumMissions == nil) then
		SaveData.mediumMissions = 0
		needsSave = true
	end
	
	if (SaveData.hardMissions == nil) then
		SaveData.hardMissions = 0
		needsSave = true
	end
	
	if (SaveData.twoplayerMissions == nil) then
		SaveData.twoplayerMissions = 0
		needsSave = true
	end
	
	if (SaveData.bonusObjectives == nil) then
		SaveData.bonusObjectives = 0
		needsSave = true
	end
	
	if (SaveData.hidden1pObjectives == nil) then
		SaveData.hidden1pObjectives = 0
		needsSave = true
	end
	
	if (SaveData.hidden2pObjectives == nil) then
		SaveData.hidden2pObjectives = 0
		needsSave = true
	end
	
	if (SaveData.primaryActor == nil) then
		SaveData.primaryActor = ""
		needsSave = true
	end
	
	if (SaveData.wasHit == nil) then
		SaveData.wasHit = false
		needsSave = true
	end
	
	if (SaveData.cheater == nil) then
		SaveData.cheater = 0
		needsSave = true
	end
	
	if (SaveData.bonusCompleted == nil) then
		SaveData.bonusCompleted = 0
		needsSave = true
	end
	
	if (needsSave) then
		emuObj.SaveConfig(0, SaveData)
	end
end

-- init save data
initsaves()

function unlockTrophy(trophy_id)
	if SaveData.t[trophy_id] ~= 1 then
		SaveData.t[trophy_id] = 1
		trophyObj.Unlock(trophy_id)
		emuObj.SaveConfig(0, SaveData)			
	end
end

local function missionBits(mission)
	local bit = 1
	for key,value in pairs(missionTags) do
		if (value == mission) then
			return bit
		end
		bit = bit << 1
	end
	-- print("************* Could not match mission: " .. mission)
	return 0
end

local function getStringValue(pointer, maxlen)
	local base = eeObj.ReadMem32(pointer)
	local length = eeObj.ReadMem32(base)
	local data = eeObj.ReadMem32(base + 0x0c)
	local c
	local value = ""
	
	if maxlen > length then
		maxlen = length
	end
	
	if length > 0 then
		repeat
			c = eeObj.ReadMem8(data)
			data = data + 1		
			
			if (c ~= 0) then
				value = value .. string.format("%c", c)
				if (string.len(value) >= maxlen) then
					c = 0
				end
			end
		until c == 0
	end
	
	return value
end

local function checkAllShipsUnlocked()
	local completed = 0
	completed = completed | missionBits("m03") -- unlocks xwing 
	completed = completed | missionBits("m04") -- unlocks tie fighter
	completed = completed | missionBits("m08") -- unlocks super zoomer 
	completed = completed | missionBits("m09") -- unlocks super jedi star fighter
	completed = completed | missionBits("m10") -- unlocks sabaoth
	completed = completed | missionBits("m11") -- unlocks super free fall
	completed = completed | missionBits("m13") -- unlocks super havok
	completed = completed | missionBits("m15") -- unlocks gunship
	
	if ((SaveData.bonusObjectives & completed) == completed) then
		if ((SaveData.hidden1pObjectives & hiddenStory1pObjectivesMask) == hiddenStory1pObjectivesMask) then -- unlocks slave1
			local trophy_id = TROPHY_FULL_HANGAR
			unlockTrophy(trophy_id)
		end
	end
end

-- 1 player bonus missions: b01, b03, b04, b08, b09

local function checkAll1pBonusMissionsUnlocked()
	local completed = 0
	completed = completed | missionBits("m16") -- unlocks b01
	completed = completed | missionBits("m01") -- unlocks b03
	completed = completed | missionBits("m14") -- unlocks b04
	completed = completed | missionBits("m06") -- unlocks b08
	-- b09 always unlocked

	if ((SaveData.bonusObjectives & completed) == completed) then
		local trophy_id = TROPHY_FLYING_SOLO
		unlockTrophy(trophy_id)
	end
end

-- 2 players bonus missions: b02, b05, b06, b12, b13

local function checkAll2pBonusMissionsUnlocked()
	local completed = 0
	completed = completed | missionBits("m12") -- unlocks b02
	completed = completed | missionBits("m02") -- unlocks b05
	-- b12 always unlocked

	if ((SaveData.bonusObjectives & completed) == completed) then
		if ((SaveData.hidden2pObjectives & hidden2pObjectivesMask) == hidden2pObjectivesMask) then -- unlocks b06, b13
			local trophy_id = TROPHY_BUDDY_SYSTEM
			unlockTrophy(trophy_id)
		end
	end
end

local function checkAllHiddenObjectivesCompleted()
	if ((SaveData.hidden1pObjectives & hidden1pObjectivesMask) == hidden1pObjectivesMask) then
		if ((SaveData.hidden2pObjectives & hidden2pObjectivesMask) == hidden2pObjectivesMask) then
			local trophy_id = TROPHY_A_JEDIS_WORK_IS_NEVER_DONE
			unlockTrophy(trophy_id)
		end
	end
end

local function checkActICompleted()
	local completed = 0
	completed = completed | missionBits("m01")
	completed = completed | missionBits("m02")
	completed = completed | missionBits("m03")
	completed = completed | missionBits("m04")
	
	local missions = SaveData.easyMissions | SaveData.mediumMissions | SaveData.hardMissions
	if ((missions & completed) == completed) then
		local trophy_id = TROPHY_DRAGONS_BREATH
		unlockTrophy(trophy_id)
	end
end

local function checkActIICompleted()
	local completed = 0
	completed = completed | missionBits("m05")
	completed = completed | missionBits("m06")
	completed = completed | missionBits("m08")
	completed = completed | missionBits("m09")
	completed = completed | missionBits("m10")
	
	local missions = SaveData.easyMissions | SaveData.mediumMissions | SaveData.hardMissions
	if ((missions & completed) == completed) then
		local trophy_id = TROPHY_DRAGONS_DEN
		unlockTrophy(trophy_id)
	end
end

local function checkAllBonusObjectivesCompleted()
	if ((SaveData.bonusObjectives & allStagesBonusMask) == allStagesBonusMask) then
		local completed = SaveData.easyMissions | SaveData.mediumMissions | SaveData.hardMissions | SaveData.twoplayerMissions

		if ((completed & allStagesMissionMask) == allStagesMissionMask) then
			local trophy_id = TROPHY_NO_SMALL_TASK
			unlockTrophy(trophy_id)
		end
	end
end

local function checkAllEasyMissionsCompleted()
	if ((SaveData.easyMissions & regularMissionsMask) == regularMissionsMask) then
		local trophy_id = TROPHY_JEDI_PADAWAN
		unlockTrophy(trophy_id)
	end
end

local function checkAllMediumMissionsCompleted()
	if ((SaveData.mediumMissions & regularMissionsMask) == regularMissionsMask) then
		local trophy_id = TROPHY_JEDI_KNIGHT
		unlockTrophy(trophy_id)
	end
end

local function checkAllHardMissionsCompleted()
	if ((SaveData.hardMissions & regularMissionsMask) == regularMissionsMask) then
		local trophy_id = TROPHY_JEDI_MASTER
		unlockTrophy(trophy_id)
	end
end

local function checkAllTrainingMissionsCompleted()
	if ((SaveData.mediumMissions & trainingMissionsMask) == trainingMissionsMask) then
		local trophy_id = TROPHY_FLIGHT_SCHOOL
		unlockTrophy(trophy_id)
	end
end

local function completed2pMission()
	local trophy_id = TROPHY_WINGMAN
	unlockTrophy(trophy_id)
end

local function completedNoDamage()
	local trophy_id = TROPHY_NO_SHIELD_REQUIRED
	unlockTrophy(trophy_id)
end

local H1 = -- CMissionStats::SetMissionComplete
	function()
		if (SaveData.cheater == 0) then
			local pointer = eeObj.GetGpr(gpr.a1)
			local name = getStringValue(pointer,3)
			local difficulty = eeObj.GetGpr(gpr.a2)
			local bits = missionBits(name)
			
			-- print( "name = " .. name)
			-- print( string.format("difficulty = %d", difficulty))
			-- print( string.format("bits = %d", bits))
			
			if (bits ~= 0) then
				
				if ((bits & regularMissionsMask) ~= 0) then
					if (SaveData.wasHit == false) then
						completedNoDamage()
					end
				end
			
				if (difficulty == 1) then -- easy
					SaveData.easyMissions = SaveData.easyMissions | bits
					checkAllEasyMissionsCompleted()
				elseif (difficulty == 2) then -- medium
					SaveData.mediumMissions = SaveData.mediumMissions | bits
					checkAllMediumMissionsCompleted()
					checkAllTrainingMissionsCompleted() -- training missions are always run on medium difficulty
				elseif (difficulty == 3) then -- hard
					SaveData.hardMissions = SaveData.hardMissions | bits
					checkAllHardMissionsCompleted()
				end
				emuObj.SaveConfig(0, SaveData)
			
				checkActICompleted()
				checkActIICompleted()
				checkAllBonusObjectivesCompleted()
			end
		end
	end
	
local H2 = -- CMissionStats::SetBonusObjComplete
	function()
		if (SaveData.cheater == 0) then
			local pointer = eeObj.GetGpr(gpr.a1)
			local name = getStringValue(pointer,3)
			local bits = missionBits(name)
			
			if (bits ~= 0) then
				SaveData.bonusObjectives = SaveData.bonusObjectives | bits
				emuObj.SaveConfig(0, SaveData)
				
				checkAllBonusObjectivesCompleted()
				checkAllShipsUnlocked()
				checkAll1pBonusMissionsUnlocked()
				checkAll2pBonusMissionsUnlocked()
			end
		end
	end
	
local H3 = -- CMissionStats::Set1pHiddenObjComplete
	function()
		if (SaveData.cheater == 0) then
			local pointer = eeObj.GetGpr(gpr.a1)
			local name = getStringValue(pointer,3)
			local bits = missionBits(name)
			
			if (bits ~= 0) then
				SaveData.hidden1pObjectives = SaveData.hidden1pObjectives | bits
				emuObj.SaveConfig(0, SaveData)
				
				checkAllHiddenObjectivesCompleted()
				checkAllShipsUnlocked()
			end
		end
	end
	
local H4 = -- CMissionStats::Set2pHiddenObjComplete
	function()
		if (SaveData.cheater == 0) then
			local pointer = eeObj.GetGpr(gpr.a1)
			local name = getStringValue(pointer,3)
			local bits = missionBits(name)
			
			if (bits ~= 0) then
				SaveData.hidden2pObjectives = SaveData.hidden2pObjectives | bits
				emuObj.SaveConfig(0, SaveData)
				
				checkAllHiddenObjectivesCompleted()
				checkAll2pBonusMissionsUnlocked()
			end
		end
	end
	
local H5 = -- CMissionStats::Set2pMissionComplete
	function()
		if (SaveData.cheater == 0) then
			completed2pMission()

			local pointer = eeObj.GetGpr(gpr.a1)
			local name = getStringValue(pointer,3)
			local bits = missionBits(name)
			
			if (bits ~= 0) then
				SaveData.twoplayerMissions = SaveData.twoplayerMissions | bits
				emuObj.SaveConfig(0, SaveData)
				
				if name == "b02" then -- special case b02 to register bonus objective. Works around bug in game
					if SaveData.bonusCompleted ~= 0 then
						SaveData.bonusObjectives = SaveData.bonusObjectives | bits
						emuObj.SaveConfig(0, SaveData)
						
						checkAllBonusObjectivesCompleted()
					end
				end
			end
		end
	end

local H6 = -- CFlightModelPYCtrl::SetPrimaryActor
	function()
		local model = eeObj.GetGpr(gpr.a0)
		local modelVTable = eeObj.ReadMem32(model)
		local modelClassID = eeObj.ReadMem32(modelVTable+0x0c)
		
		if (modelClassID == 0x2ae750) then -- CPlayerFlightModel::GetClassID
			local pointer = eeObj.GetGpr(gpr.a1)
			local name = getStringValue(pointer+0x40,3)
			SaveData.primaryActor = name
			emuObj.SaveConfig(0, SaveData)
		end
	end
	
local H7 = -- CDestructible::DamageDestructible
	function()
		local pointer = eeObj.GetGpr(gpr.a0)
		local name = getStringValue(pointer+0x40,3)
				
		if (name == SaveData.primaryActor and SaveData.wasHit == false) then
			SaveData.wasHit = true
			emuObj.SaveConfig(0, SaveData)
		end
	end

local H8 = -- COverseer::RunMission
	function()
		SaveData.wasHit = false
		SaveData.bonusCompleted = 0
		emuObj.SaveConfig(0, SaveData)
	end
	
local H9 = -- CEuropaGame::SetVarToItemText
	function()
		local pointer = eeObj.GetGpr(gpr.v0)
		local name = getStringValue(pointer,9)
		
		if (name == "Code_Fail") then
			SaveData.cheater = 1
			emuObj.SaveConfig(0, SaveData)
		end
	end
	
local H10 = -- CStrobeUserInterface::SetUIVariable
	function()
		local pointer = eeObj.GetGpr(gpr.a1)
		local name = getStringValue(pointer,13)
		
		if (name == "sf:codeReturn") then
			SaveData.cheater = 0
			emuObj.SaveConfig(0, SaveData)
		end
	end
	
local H11 = -- COverseer::SetObjectiveStatus
	function()
		local objtype = eeObj.GetGpr(gpr.a3)
		local objstate = eeObj.GetGpr(gpr.a2)
		
		if objtype == 1 and objstate == 2 then -- bonus type, completed state
			if SaveData.bonusCompleted == 0 then
				SaveData.bonusCompleted = 1
				emuObj.SaveConfig(0, SaveData)
			end
		end
	end
	
-- register hooks
local hook1 = eeObj.AddHook(0x4dcb90, 0x27bdff50, H1)	--  CMissionStats::SetMissionComplete
local hook2 = eeObj.AddHook(0x4dcfc0, 0x27bdffe0, H2)	--  CMissionStats::SetBonusObjComplete
local hook3 = eeObj.AddHook(0x4dd030, 0x27bdffe0, H3)	--  CMissionStats::Set1pHiddenObjComplete
local hook4 = eeObj.AddHook(0x4dd0a0, 0x27bdffe0, H4)	--  CMissionStats::Set2pHiddenObjComplete
local hook5 = eeObj.AddHook(0x4dcda0, 0x27bdff50, H5)	--  CMissionStats::Set2pMissionComplete
local hook6 = eeObj.AddHook(0x1da9a0, 0x27bdffd0, H6)	--  CFlightModelPYCtrl::SetPrimaryActor
local hook7 = eeObj.AddHook(0x140830, 0x27bdfcb0, H7)	--  CDestructible::DamageDestructible
local hook8 = eeObj.AddHook(0x39d0e0, 0x27bdff40, H8)	--  COverseer::RunMission
local hook9 = eeObj.AddHook(0x336044, 0x8e0400cc, H9)	--  CEuropaGame::SetVarToItemText
local hook10 = eeObj.AddHook(0x5636e0, 0x27bdffd0, H10)	--  CStrobeUserInterface::SetUIVariable
local hook11 = eeObj.AddHook(0x39e6d0, 0x27bdff70, H11)	--  COverseer::SetObjectiveStatus

--[[

Walk-through for the game:
http://www.gamefaqs.com/ps2/538296-star-wars-jedi-starfighter/faqs/18580


--

To Unlock All 1 Player Bonus Missions (TROPHY_FLYING_SOLO)
* Complete Missions:
	- The Informant
	- Mount Merakan
	- Attack of the Clones
	- The Jedi Master

---
	
To Unlock All 2 Player Bonus Missions (TROPHY_BUDDY_SYSTEM)
* Complete Missions:
	- Unlikely Allies
	- Escort to Geonosis
* Complete all the 2 player hidden objectives

---

To Unlock All Ships (TROPHY_FULL_HANGAR)
* Complete Bonus Objectives for Missions:
	- Prison Break
	- Turning the Tides
	- Hammer and Anvil
	- Demolition Squad
	- The Dragon's Den
	- Tug of War
	- Cannon Fodder
	- Heart of the Storm
* Complete all the 1 player hidden objectives in Story mode (don't need training missions or the bonus mission 1p hidden objective, see below)

---

To Complete every hidden objective (TROPHY_A_JEDIS_WORK_IS_NEVER_DONE)
* Complete all the 1 player hidden objectives (including training missions)
* Complete all the 2 player hidden objectives

Note there's a hidden 1p objective on Bonus Mission "Riding Shotgun".
You must kill 150 ships and finish the level in order to get it, and it's a requirement to unlock this trophy

---

]]--
