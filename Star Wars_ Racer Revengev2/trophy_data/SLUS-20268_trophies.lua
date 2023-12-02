-- Lua 5.3
-- Title:   Star Wars Racer Revenge PS2 - SLUS-20268 (USA)
-- Author:  Ernesto Corvi

-- Changelog:
-- v1.1: fix bug 8967 (trophies 'Rookie Racer' and 'Stellar Superstar' triggering if you were 2nd or 3rd)
-- v1.2: fix bug 8967b (trophy 'Wattos Wares' triggering early)

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])
require( "ee-cpr0-alias" ) -- for EE CPR

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()
local trophyObj	= getTrophyObject()

local TROPHY_THE_FIRST_OF_MANY			=  0 -- Win your first tournament race. (tested)
local TROPHY_MOST_DEADLY				=  1 -- Achieve 7 KO's in one 3-lap race. (tested)
local TROPHY_FIRST_AROUND_THE_TRACK		=  2 -- Earn the Best Lap time for any 3-lap race. (tested)
local TROPHY_RECORD_BREAKER				=  3 -- Earn the Best Race time for any 3-lap race. (tested)
local TROPHY_WATTOS_WARES				=  4 -- Upgrade any pod attribute to MAX. (tested)
local TROPHY_BANTHA_POODOO				=  5 -- KO a human opponent in Versus mode. (tested)
local TROPHY_ROOKIE_RACER				=  6 -- Take first place in the Galactic Trials. (tested)
local TROPHY_STELLAR_SUPERSTAR			=  7 -- Take first place in the Podracer Open. (tested)
local TROPHY_SITH_LORD					=  8 -- Unlock Darth Maul.
local TROPHY_GALACTIC_GREATNESS			=  9 -- Take first place in the Hutt Championships. (tested)
local TROPHY_PODRACING_PRODIGY			= 10 -- Unlock Young Anakin.
local TROPHY_POD_FATHER					= 11 -- Unlock Darth Vader.
local TROPHY_THE_BEST_AROUND			= 12 -- Take first place in every tournament race with any one character. (tested)

-- Game specifics
local GAMEMODE_SINGLERACE	= 0
local GAMEMODE_VSRACE		= 1
local GAMEMODE_TOURNAMENT	= 2

local ALL_TOURNAMENT_RACES_MASK = 0x1fff

local PLAYER_VEHICLE_VTABLE = 0x3ced50 -- from PodPlayerVehicle::PodPlayerVehicle


local SaveData = emuObj.LoadConfig(0)

if not next(SaveData) then
	SaveData.t  = {}
	SaveData.gameMode = 0
	SaveData.maxxed = {}
	SaveData.wins = {}
end

function initsaves()
	local x = 0
	local needsSave = false
	for x = 0, 12 do
		if SaveData.t[x] == nil then
			SaveData.t[x] = 0
			needsSave = true
		end
	end
	
	if (SaveData.gameMode == nil) then
		SaveData.gameMode = 0
		needsSave = true
	end
	
	if SaveData.maxxed == nil then
		SaveData.maxxed = {}
		needsSave = true
	end
	
	for x = 0, 5 do
		if SaveData.maxxed[x] == nil then
			SaveData.maxxed[x] = false
			needsSave = true
		end
	end
	
	if SaveData.wins == nil then
		SaveData.wins = {}
		needsSave = true
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

local function getFinalRacePosition(vehicle)
	-- all the offsets from PodPlayerVehicle::CheckForPositionChange
	local raceContext = eeObj.ReadMem32(0x0382B80)
	local raceStatusContext = eeObj.ReadMem32(raceContext+0x28c)
	local statsContext = eeObj.ReadMem32(raceStatusContext+0xb4)
	local totalVehicles = eeObj.ReadMem32(statsContext+0x4c) - 1
	local statsList = eeObj.ReadMem32(statsContext+0x3c)
	local x = 0
	
	for x = 0, totalVehicles do
		local stats = eeObj.ReadMem32(statsList + (x * 4))
		local statsVehicle = eeObj.ReadMem32(stats)
		
		if (statsVehicle == vehicle) then
			return eeObj.ReadMem32(stats + 0x3c)
		end
	end
	
	return 0
end

local H1 =  -- PodGame::SetGameMode
	function()
		local mode = eeObj.GetGpr(gpr.a1)
		if (mode ~= SaveData.gameMode) then
			SaveData.gameMode = mode
			emuObj.SaveConfig(0, SaveData)
		end
	end

local H2 =  -- PodRaceEvent::NewRecord
	function()
		unlockTrophy(TROPHY_RECORD_BREAKER)
	end
	
local H3 =  -- PodGameOptions::IsRecordKills
	function()
		local kills = eeObj.GetGpr(gpr.a2)
		if (kills >= 7) then
			unlockTrophy(TROPHY_MOST_DEADLY)
		end
	end

local H4 =  -- PodVehicle::TestForWreck
	function()
		local source = eeObj.GetGpr(gpr.s2)
		local sourceVtable = eeObj.ReadMem32(source+8)
		local target = eeObj.GetGpr(gpr.s3)
		local targetVtable = eeObj.ReadMem32(target+8)
		
		if (SaveData.gameMode == GAMEMODE_VSRACE) then -- VS Race mode
			if (sourceVtable == PLAYER_VEHICLE_VTABLE and targetVtable == PLAYER_VEHICLE_VTABLE) then
				unlockTrophy(TROPHY_BANTHA_POODOO)
			end
		end
	end

local H5 =  -- PodPlayerVehicle::LapTurned
	function()
		local curLap = eeObj.GetGpr(gpr.v1)
		local totalLaps = eeObj.GetGpr(gpr.a1)
		
		-- print(string.format("Lap %d/%d", curLap, totalLaps))
		
		if (curLap == totalLaps) then
			if (SaveData.gameMode == GAMEMODE_TOURNAMENT) then
				local vehicle = eeObj.GetGpr(gpr.s3)
				local position = getFinalRacePosition(vehicle)
				if (position == 1) then
					unlockTrophy(TROPHY_THE_FIRST_OF_MANY)

					local options = eeObj.GetGpr(gpr.a0)
					local character = (eeObj.ReadMem8(options+0x1125d) >> 3) & 0x1f -- from PodGame::CreateScene
					local track = eeObj.ReadMem8(options+0x1125f) & 0x0f -- from PodGameOptions::GetCurrentRace
					local mask = 1
					
					mask = mask << track
					
					if (SaveData.wins[character] == nil) then
						SaveData.wins[character] = 0
					end
					
					SaveData.wins[character] = SaveData.wins[character] | mask
					emuObj.SaveConfig(0, SaveData)
					
					if ((SaveData.wins[character] & ALL_TOURNAMENT_RACES_MASK) == ALL_TOURNAMENT_RACES_MASK) then
						unlockTrophy(TROPHY_THE_BEST_AROUND)
					end
					
					-- print(string.format("Won race. character %d, track %d", character, track))
				end
			end
		end
	end
	
local H6 =  -- PodGameOptions::UnlockDarthMaul
	function()
		unlockTrophy(TROPHY_SITH_LORD)
	end
	
local H7 =  -- PodGameOptions::UnlockAnakinEP1
	function()
		unlockTrophy(TROPHY_PODRACING_PRODIGY)
	end
	
local H8 =  -- PodGameOptions::UnlockDarthVader
	function()
		unlockTrophy(TROPHY_POD_FATHER)
	end
	
local H9 =  -- PodPlayerVehicle::LapTurned
	function()
		local options = eeObj.GetGpr(gpr.a0)
		local totalLaps = eeObj.ReadMem8(options+0x1125c) & 0x1f -- from PodGameOptions::IsRecordRace
		
		if (totalLaps == 3) then
			unlockTrophy(TROPHY_FIRST_AROUND_THE_TRACK)
		end
	end

local H10 =  -- PodUIPageCircuitWin::ResetPage
	function()
		local data = eeObj.GetGpr(gpr.s2)
		local tier = eeObj.ReadMem32(data+0x650)
		
		if (tier == 1) then
			unlockTrophy(TROPHY_ROOKIE_RACER)
		elseif (tier == 2) then
			unlockTrophy(TROPHY_STELLAR_SUPERSTAR)
		end
	end
	
local H11 =  -- PodGame::StartTierWinCutscene
	function()
		local tier = eeObj.GetGpr(gpr.a1)
		
		if (tier == 3) then
			unlockTrophy(TROPHY_GALACTIC_GREATNESS)
		end
	end

local H12 =  -- PodUIPageGarage::RenderStats
	function()
		local data = eeObj.GetGpr(gpr.s1)
		local index = eeObj.ReadMem32(data+0x4e4)
		
		if index <= 5 then
			if SaveData.maxxed[index] == true then
				SaveData.maxxed[index] = false
				emuObj.SaveConfig(0, SaveData)
			end
		end
	end

local H13 =  -- PodUIPageGarage::RenderStats
	function()
		local data = eeObj.GetGpr(gpr.s1)
		local index = eeObj.ReadMem32(data+0x4e4)
		
		if index <= 5 then
			if SaveData.maxxed[index] ~= true then
				SaveData.maxxed[index] = true
				emuObj.SaveConfig(0, SaveData)
			end
		end
	end
	
local H14 =  -- PodUIPageGarage::ProcessUserInput
	function()
		local x = 0
		for x = 0, 5 do
			if (SaveData.maxxed[x] == true) then
				unlockTrophy(TROPHY_WATTOS_WARES)
				return
			end
		end
	end
	
-- register hooks
local hook1 = eeObj.AddHook(0x17de50, 0x8c8702dc, H1)	-- PodGame::SetGameMode
local hook2 = eeObj.AddHook(0x1a2d00, 0x24120001, H2)	-- PodPlayerVehicle::LapTurned
local hook3 = eeObj.AddHook(0x1863f4, 0x3c010001, H3)	-- PodGameOptions::IsRecordKills
local hook4 = eeObj.AddHook(0x225fc0, 0x8e650060, H4)	-- PodVehicle::TestForWreck
local hook5 = eeObj.AddHook(0x1a2ce4, 0x8e630cc8, H5)	-- PodPlayerVehicle::LapTurned
local hook6 = eeObj.AddHook(0x1881d0, 0x3c010001, H6)	-- PodGameOptions::UnlockDarthMaul
local hook7 = eeObj.AddHook(0x187ff0, 0x3c010001, H7)	-- PodGameOptions::UnlockAnakinEP1
local hook8 = eeObj.AddHook(0x1882b0, 0x3c010001, H8)	-- PodGameOptions::UnlockDarthVader
local hook9 = eeObj.AddHook(0x1a2cb8, 0x24110001, H9)	-- PodPlayerVehicle::LapTurned
local hook10 = eeObj.AddHook(0x2086d8, 0x72402628, H10) -- PodUIPageCircuitWin::ResetPage
local hook11 = eeObj.AddHook(0x17d9f0, 0x27bdfff0, H11) -- PodGame::StartTierWinCutscene
local hook12 = eeObj.AddHook(0x1fd998, 0x8e430004, H12) -- PodUIPageGarage::RenderStats
local hook13 = eeObj.AddHook(0x1fda34, 0x8e030004, H13) -- PodUIPageGarage::RenderStats
local hook14 = eeObj.AddHook(0x1fafc0, 0x27bdffe0, H14) -- PodUIPageGarage::PageClosing

--[[

Notes:

Game Guide:
http://www.gamefaqs.com/ps2/480910-star-wars-racer-revenge/faqs/15960


Cheat that allows killing enemies with just one hit, and unlike the similar cheat code, actually does count the kill:
eeInsnReplace(0x22270c, 0x10400007, 0x00000000)

]]--
