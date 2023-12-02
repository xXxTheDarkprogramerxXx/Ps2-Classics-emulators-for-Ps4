-- Lua 5.3
-- Title:   Star Wars Bounty Hunter PS2 - SLES-50831 (EUR)
-- Author:  Ernesto Corvi

-- Changelog:
-- v1.1: move some counters to trophy data
-- v1.2: reduce instances of state save when firing a weapon
-- v1.4: workaround bug 8931 (Going After Vosa triggering too soon)
-- v1.5: workaround bug 8921 (Force game to save after completing every level)
-- v1.6: improved performance detecting a manual missile kill (bug 8902)

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])
require( "ee-cpr0-alias" ) -- for EE CPR

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()
local trophyObj	= getTrophyObject()

local TROPHY_TARGET_ACQUIRED			=  0 -- Mark and claim your first bounty. (tested)
local TROPHY_DEAD_OR_ALIVE_MEEKO		=  1 -- Complete Chapter 1.
local TROPHY_LOWLIFES_IN_HIGH_PLACES	=  2 -- Complete Chapter 2.
local TROPHY_THE_ASTEROID_PRISON		=  3 -- Complete Chapter 3.
local TROPHY_A_TENSE_PARTNERSHIP		=  4 -- Complete Chapter 4.
local TROPHY_A_FAVOR_FOR_A_HUTT			=  5 -- Complete Chapter 5.
local TROPHY_NO_CIVILIAN_CASUALTIES		=  6 -- Kill 150 enemies in one level without killing any non-enemies.
local TROPHY_BODY_COUNT_1000			=  7 -- Kill 1,000 total enemies.
local TROPHY_ALL_MY_OWN_WORK			=  8 -- Kill an enemy with a manually guided missile. (tested)
local TROPHY_GOING_AFTER_VOSA			=  9 -- Complete Chapter 6.
local TROPHY_BODY_COUNT_1500			= 10 -- Kill 1,500 total enemies.
local TROPHY_SECRETS_OF_THE_GALAXY		= 11 -- Find all 18 secrets.
local TROPHY_NON_LETHAL_FORCE			= 12 -- Capture every Secondary Bounty.

-- Global Addresses
local gLevelNumberAddress = 0x3f09ec -- from CFrontEndScreenMgr::SetLevelEndProperties
local gSaveGameAddress = 0x3f0a0c -- from CFrontEndScreenMgr::SetLevelEndProperties
local gShouldSaveFlagAddress = 0x3f0bfc -- from CHUDBountyMgr::TotalLevelComplete

local SaveData = emuObj.LoadConfig(0)

if not next(SaveData) then
	SaveData.t  = {}
	SaveData.manualAim = false
	SaveData.manualMissile = false
	SaveData.bodyCount = 0
	SaveData.secrets = 0
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
	
	if (SaveData.manualAim == nil) then
		SaveData.manualAim = false
		needsSave = true
	end
	
	if (SaveData.manualMissile == nil) then
		SaveData.manualMissile = false
		needsSave = true
	end
	
	if (SaveData.bodyCount == nil) then
		SaveData.bodyCount = 0
		needsSave = true
	end
	
	if (SaveData.secrets == nil) then
		SaveData.secrets = 0
		needsSave = true
	end
	
	if (needsSave == true) then
		emuObj.SaveConfig(0, SaveData)
	end
end

-- initialize the save data now if needed
initsaves()

function unlockTrophy(trophy_id)
	if SaveData.t[trophy_id] ~= 1 then
		SaveData.t[trophy_id] = 1
		trophyObj.Unlock(trophy_id)
		emuObj.SaveConfig(0, SaveData)			
	end
end

local function getLevelEnemyKillCounter(globals)
	return eeObj.ReadMem16(globals - 0x3BA0)
end

local function getLevelNonEnemyKillCounter(globals)
	return eeObj.ReadMem16(globals - 0x3B9C)
end

local function getLevelNumber()
	return eeObj.ReadMem8(gLevelNumberAddress)
end

local function getLevelTotalBounties(levelNumber, savegameBase)
	return eeObj.ReadMem8(savegameBase + 0xcc + levelNumber) -- from CPauseMenu::Init
end

local function capturedAllNonLevelBounties(levelNumber, savegameBase)
	local bountyTotals = savegameBase + 0xcc -- from CPauseMenu::Init
	local capturedTotals = savegameBase + 0xf2 -- from CFrontEndScreenMgr::SetGameStatsProperties
		
	for x = 1, 18 do
		bountyTotals = bountyTotals + 1 -- pre-increment
		capturedTotals = capturedTotals + 1 -- pre-increment
		
		if (x ~= levelNumber) then
			local total = eeObj.ReadMem8(bountyTotals)
			local captured = eeObj.ReadMem8(capturedTotals)
			
			if (total ~= captured) then
				return false
			end
		end
	end
	
	return true
end

local H1 =  -- CFrontEndScreenMgr::SetLevelEndProperties
	function()
		local levelTime = eeObj.GetFpr(12)
		
		if (levelTime > 0.0) then
		
			-- Force the game to save
			eeObj.WriteMem32(gShouldSaveFlagAddress, 1)
		
			local level = getLevelNumber()
			
			if (level == 3) then
				local trophy_id = TROPHY_DEAD_OR_ALIVE_MEEKO
				unlockTrophy(trophy_id)
			elseif (level == 6) then
				local trophy_id = TROPHY_LOWLIFES_IN_HIGH_PLACES
				unlockTrophy(trophy_id)
			elseif (level == 9) then
				local trophy_id = TROPHY_THE_ASTEROID_PRISON
				unlockTrophy(trophy_id)
			elseif (level == 12) then
				local trophy_id = TROPHY_A_TENSE_PARTNERSHIP
				unlockTrophy(trophy_id)
			elseif (level == 15) then
				local trophy_id = TROPHY_A_FAVOR_FOR_A_HUTT
				unlockTrophy(trophy_id)
			elseif (level == 18) then
				local trophy_id = TROPHY_GOING_AFTER_VOSA
				unlockTrophy(trophy_id)
			end
		end
	end

local H2 =	-- Enemy Kill Counter
	function()
		if (SaveData.manualMissile == true) then
			local trophy_id = TROPHY_ALL_MY_OWN_WORK
			unlockTrophy(trophy_id)
		end
	
		local globals = eeObj.GetGpr(gpr.gp)
		local levelEnemyKills = getLevelEnemyKillCounter(globals)
		local levelNonEnemyKills = getLevelNonEnemyKillCounter(globals)
		
		if (levelEnemyKills >= 150 and levelNonEnemyKills == 0) then
			local trophy_id = TROPHY_NO_CIVILIAN_CASUALTIES
			unlockTrophy(trophy_id)
		end
		
		SaveData.bodyCount = SaveData.bodyCount + 1
		emuObj.SaveConfig(0, SaveData)
		
		if (SaveData.bodyCount >= 1500) then
			local trophy_id = TROPHY_BODY_COUNT_1500
			unlockTrophy(trophy_id)
		elseif (SaveData.bodyCount >= 1000) then
			local trophy_id = TROPHY_BODY_COUNT_1000
			unlockTrophy(trophy_id)
		end
		
	end

local H3 =	-- CHUDBountyMgr::SetClaimed
	function()
		local trophy_id = TROPHY_TARGET_ACQUIRED
		unlockTrophy(trophy_id)
		
		local levelCapturedBounties = eeObj.GetGpr(gpr.a1)
		local levelNumber = getLevelNumber()
		local savegameBase = gSaveGameAddress
				
		if (levelCapturedBounties == getLevelTotalBounties(levelNumber, savegameBase)) then
			if (capturedAllNonLevelBounties(levelNumber, savegameBase)) then
				local trophy_id = TROPHY_NON_LETHAL_FORCE
				unlockTrophy(trophy_id)
			end
		end
	end
	
local H4 = -- Pick up Secret
	function()
		local secrets = eeObj.GetGpr(gpr.v0)
		SaveData.secrets = SaveData.secrets | secrets
		emuObj.SaveConfig(0, SaveData)
		
		if (SaveData.secrets & 0x7fffe == 0x7fffe) then
			local trophy_id = TROPHY_SECRETS_OF_THE_GALAXY
			unlockTrophy(trophy_id)
		end
	end
	
local H5 = -- CHUDMgr::SetDisplayMode
	function()
		local mode = eeObj.GetGpr(gpr.a1)
		local oldValue = SaveData.manualAim
		local newValue = false
		
		if (mode == 1) then
			newValue = true
		end
				
		if newValue ~= oldValue then
			SaveData.manualAim = newValue
			emuObj.SaveConfig(0, SaveData)
		end
	end

local H6 = -- CProjectile::CreateExplosion
	function()
		local manualMissile = false
		
		if (SaveData.manualAim == true) then
			local weapon = eeObj.GetGpr(gpr.s0)
			local vtable = eeObj.ReadMem32(weapon+0x40)
			
			if (vtable == 0x3b7710) then -- from CProjConcMissle::~CProjConcMissle
				manualMissile = true
			end
		end
		
		if SaveData.manualMissile ~= manualMissile then
			SaveData.manualMissile = manualMissile
			emuObj.SaveConfig(0, SaveData)
		end
	end
	
local H7 = -- CProjectile::CreateExplosion
	function()
		if (SaveData.manualMissile ~= false) then
			SaveData.manualMissile = false
			emuObj.SaveConfig(0, SaveData)
		end
	end

-- register hooks
local hook1 = eeObj.AddHook(0x317540, 0xc44c01a0, H1)	-- CFrontEndScreenMgr::SetLevelEndProperties
local hook2 = eeObj.AddHook(0x178ed4, 0xdfbf0050, H2)	-- Enemy Kill Counter
local hook3 = eeObj.AddHook(0x2f2140, 0x01031821, H3)	-- CHUDBountyMgr::SetClaimed
local hook4 = eeObj.AddHook(0x1850d4, 0x00431025, H4)	-- Pick up Secret
local hook5 = eeObj.AddHook(0x2fb440, 0x27bdfff0, H5)	-- CHUDMgr::SetDisplayMode
local hook6 = eeObj.AddHook(0x1a42e8, 0x8e0200cc, H6)	-- CProjectile::CreateExplosion
local hook7 = eeObj.AddHook(0x1a4330, 0x27a40030, H7)	-- CProjectile::CreateExplosion
