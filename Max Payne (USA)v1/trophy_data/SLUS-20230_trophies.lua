-- Lua 5.3
-- Title: Max Payne - SLUS-20230 (USA) v1.30
-- Trophies version: 1.00
-- Author: Nicola Salmoria
-- Date: March 7, 2016


require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()
local trophyObj	= getTrophyObject()


local TROPHY_WEAPONS_TRAINING					=  0
local TROPHY_TRICK_SHOT							=  1
local TROPHY_FOUR_FOR_THE_PRICE_OF_ONE			=  2
local TROPHY_QUICKEST_ON_THE_DRAW				=  3
local TROPHY_PLENTY_TO_GO_AROUND				=  4
local TROPHY_THE_AMERICAN_DREAM					=  5
local TROPHY_A_COLD_DAY_IN_HELL					=  6
local TROPHY_A_BIT_CLOSER_TO_HEAVEN				=  7
local TROPHY_FEEL_THE_PAYNE						=  8
local TROPHY_UNDER_PAR							=  9
local TROPHY_THE_LAST_CHALLENGE					= 10


local ADDRESS_TOTAL_PLAY_TIME	= 0x5b0004



-- convert unsigned int to signed
local function asSigned(n)
	local MAXINT = 0x80000000
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



H1 =	-- retrieve string from language database
	function()
		local stringIdPtr = eeObj.GetGpr(gpr.a1)
		local stringId = eeObj.ReadMemStr(stringIdPtr)

		if stringId == "TIP_54" then
			local trophy_id = TROPHY_WEAPONS_TRAINING
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif stringId == "STRING_ENDCOMBAT_03" then
			local trophy_id = TROPHY_THE_LAST_CHALLENGE
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif stringId == "STRING_NORMAL_COMPLETED1" then
			local trophy_id = TROPHY_A_BIT_CLOSER_TO_HEAVEN
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif stringId == "STRING_NIGHTMARE_COMPLETED1" then
			local trophy_id = TROPHY_FEEL_THE_PAYNE
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif stringId == "STRING_TIMEDMODE_COMPLETED2" then
			local timeSpent = eeObj.ReadMemFloat(ADDRESS_TOTAL_PLAY_TIME)
			local timeRemedy = 56 * 60 + 23		-- "0:56:23"

			if timeSpent <= timeRemedy then
				local trophy_id = TROPHY_UNDER_PAR
				--	print( string.format("trophy_id=%d", trophy_id) )
				trophyObj.Unlock(trophy_id)
			end
		end
	end


H2 =	-- load page of graphic novel
	function()
		local namePtr = eeObj.GetGpr(gpr.a2)
		local name = eeObj.ReadMemStr(namePtr)

		if name == "p1l5b_008" then
			local trophy_id = TROPHY_THE_AMERICAN_DREAM
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif name == "p3l0a_003" then
			local trophy_id = TROPHY_A_COLD_DAY_IN_HELL
			--	print( string.format("trophy_id=%d", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end


local isShootDodging = 0
local isBulletTime = 0
local numKillsDuringShootDodge = 0
local numKillsDuringBulletTime = 0
local playerCharacterProperties = 0

local isSniperZoomedIn = 0
local lastFiredWeapon = 0
local numConsecutiveSnipes = 0
local waitingSniperShot = false
local numKillsWithOneGrenade = 0


H3 =	-- game update
	function()
		local gameModePtr = eeObj.GetGpr(gpr.s4)
		local v0 = eeObj.ReadMem32(gameModePtr + 4316)
		if v0 ~= 0 then
			local characterPtr = eeObj.ReadMem32(v0 + 8)
			local characterPropertiesPtr = characterPtr + 520
			local dodging = eeObj.ReadMem8(characterPropertiesPtr + 71)

			isShootDodging = dodging
			playerCharacterProperties = characterPropertiesPtr
		else
			isShootDodging = 0
			playerCharacterProperties = 0
		end

		local bulletTime = eeObj.ReadMem8(gameModePtr + 5108)
		isBulletTime = bulletTime

		if isShootDodging == 0 then
			numKillsDuringShootDodge = 0
		end

		if isBulletTime == 0 then
			numKillsDuringBulletTime = 0
		end
	end


H4 =	-- check whether sniper rifle is zoomed in
	function()
		local zoomed = eeObj.GetGpr(gpr.v0)
		isSniperZoomedIn = zoomed
	end


H5 =	-- handle player shooting
	function()
		local characterProperties = eeObj.GetGpr(gpr.a0)
		
		if characterProperties == playerCharacterProperties then
			local weapon = eeObj.ReadMem32(characterProperties + 128)

			lastFiredWeapon = weapon

			numKillsWithOneGrenade = 0

			if waitingSniperShot then	-- missed a shot
				numConsecutiveSnipes = 0
			end

			if		weapon == 15 and			-- Sniper rifle
					isSniperZoomedIn ~= 0 then	-- zoomed in
				waitingSniperShot = true
			else
				numConsecutiveSnipes = 0
				waitingSniperShot = false
			end
		end
	end


H6 =	-- handle character killed by added damage
	function()
		local character = eeObj.GetGpr(gpr.s1)
		local skin = eeObj.ReadMem32(character + 0x6d4)
		local namePtr = eeObj.ReadMem32(skin + 4)
		local name = eeObj.ReadMemStr(namePtr)

		if name ~= "rat" then	-- not a rat, i.e. a proper enemy
			if isShootDodging ~= 0 then
				numKillsDuringShootDodge = numKillsDuringShootDodge + 1

				if numKillsDuringShootDodge == 2 then
					local trophy_id = TROPHY_TRICK_SHOT
					--	print( string.format("trophy_id=%d", trophy_id) )
					trophyObj.Unlock(trophy_id)
				end
			end

			if isBulletTime ~= 0 then
				numKillsDuringBulletTime = numKillsDuringBulletTime + 1

				if numKillsDuringBulletTime == 10 then
					local trophy_id = TROPHY_QUICKEST_ON_THE_DRAW
					--	print( string.format("trophy_id=%d", trophy_id) )
					trophyObj.Unlock(trophy_id)
				end
			end

			if waitingSniperShot == true then
				waitingSniperShot = false
				numConsecutiveSnipes = numConsecutiveSnipes + 1

				if numConsecutiveSnipes == 10 then
					local trophy_id = TROPHY_PLENTY_TO_GO_AROUND
					--	print( string.format("trophy_id=%d", trophy_id) )
					trophyObj.Unlock(trophy_id)
				end
			end

			if lastFiredWeapon == 13 then
				numKillsWithOneGrenade = numKillsWithOneGrenade + 1

				if numKillsWithOneGrenade == 4 then
					local trophy_id = TROPHY_FOUR_FOR_THE_PRICE_OF_ONE
					--	print( string.format("trophy_id=%d", trophy_id) )
					trophyObj.Unlock(trophy_id)
				end
			end
		end
	end



-- register hooks

local registeredHooks = {}


local function unregisterAllHooks()
	for _, hook in pairs(registeredHooks) do
		eeObj.RemoveHook(hook)
	end
	
	registeredHooks = {}

	-- in features.lua
	if maxpayne_features_unregisterHooks ~= nil then
		maxpayne_features_unregisterHooks()
	end

	-- in tooling.lua
	if maxpayne_tooling_unregisterHooks ~= nil then
		maxpayne_tooling_unregisterHooks()
	end
end



-- forward declaration
local LEH

local function registerHooksBoot()
	unregisterAllHooks()
	registeredHooks = {
		eeObj.AddHook(0x10e360, 0x24030006, LEH)	-- <LoadExecPS2>:
	}
end

local function registerHooksIntro()
	unregisterAllHooks()
	registeredHooks = {
		eeObj.AddHook(0x10e3a0, 0x24030006, LEH)	-- <LoadExecPS2>:
	}
end

local function registerHooksDemo()
	unregisterAllHooks()
	registeredHooks = {
		eeObj.AddHook(0x10e3a0, 0x24030006, LEH)	-- <LoadExecPS2>:
	}
end

local function registerHooksCred()
	unregisterAllHooks()
	registeredHooks = {
		eeObj.AddHook(0x10e3a0, 0x24030006, LEH)	-- <LoadExecPS2>:
	}
end

local function registerHooksMain()
	unregisterAllHooks()

	registeredHooks = {
		eeObj.AddHook(0x1120a0, 0x24030006, LEH),	-- <LoadExecPS2>:
		eeObj.AddHook(0x4dc7d8, 0x00a0902d, H1),	-- <X_SharedDBStringTable::getString( const(char const *))>:
		eeObj.AddHook(0x1d8d08, 0x8c460004, H2),	-- <MaxPayne_GraphicNovelPage::load(void)>:
		eeObj.AddHook(0x162ef4, 0x0080a02d, H3),	-- <MaxPayne_GameMode::update(float)>:
		eeObj.AddHook(0x22fefc, 0x92820748, H4),	-- <MaxPayne_PlayerCamera::update(X_CameraTarget const *, X_TimeUpdate const &)>:
		eeObj.AddHook(0x384930, 0x0040202d, H5),	-- <X_PlayerInputEvaluator::State_DodgeSpecific::reactivate( (unsigned int))>:
		eeObj.AddHook(0x387620, 0x0040202d, H5),	-- <X_PlayerInputEvaluator::State_WeaponSpecific::reactivate( (unsigned int))>:
		eeObj.AddHook(0x387740, 0x0040202d, H5),	-- <X_PlayerInputEvaluator::State_WeaponSpecific::activate( (unsigned int))>:
		eeObj.AddHook(0x3ae740, 0x0200102d, H6),	-- <X_Character::causeDamage(float, X_Character::DeathAnim)>:
  }

	-- in features.lua
	if maxpayne_features_registerHooks ~= nil then
		maxpayne_features_registerHooks()
	end

	-- in tooling.lua
	if maxpayne_tooling_registerHooks ~= nil then
		maxpayne_tooling_registerHooks()
	end
end

LEH =	-- load PS2 executable (not local because forward declared above)
	function()
		local namePtr = eeObj.GetGpr(gpr.a0)
		local name = eeObj.ReadMemStr(namePtr)

		if name == "cdrom0:\\INTRO.RUN;1" then
			registerHooksIntro()
		elseif name == "cdrom0:\\DEMO.RUN;1" then
			registerHooksDemo()
		elseif name == "cdrom0:\\CRED.RUN;1" then
			registerHooksCred()
		elseif name == "cdrom0:\\MAIN.RUN;1" then
			registerHooksMain()
		else
			print( string.format("*** UNKNOWN EXEC %s ***", name) )
		end
	end



-- register boot hooks
registerHooksBoot()

-- to have proper hooks after loading snapshots/reloading lua during development.
-- remove for release!
--local tempHook
--local ForceHooks = function()
--	emuObj.RemoveVsyncHook(tempHook)
--	tempHook = nil
--	registerHooksMain()
--end
--tempHook = emuObj.AddVsyncHook(ForceHooks)	-- use vsync to wait for other Lua scripts to be loaded


-- Credits

-- Trophy design and development by SCEA ISD SpecOps
-- David Thach Senior Director
-- George Weising Executive Producer
-- Tim Lindquist Senior Technical PM
-- Clay Cowgill Engineering
-- Nicola Salmoria Engineering
-- Jenny Murphy Producer
-- David Alonzo Assistant Producer
-- Tyler Chan Associate Producer
-- Karla Quiros Manager Business Finance & Ops
-- Special thanks to A-R&D
