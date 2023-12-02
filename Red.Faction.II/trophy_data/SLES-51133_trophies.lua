-- Lua 5.3
-- Title:   Red Faction II PS2 - SLES-51133 (EUR)
-- Author:  Adam McInnis

-- Changelog:
-- v1.1 - fixed lots of bugs.
-- v1.2 - fixed some script errors.
-- v1.3 - fixed more bugs.
-- v1.4 - bug fix for "checkDifficulty()"
-- v1.5 - fix headshot issue with pistol.
-- v1.6 - game bug fix to force marking of "5 ton military truck" Gallery art when objective completed.
-- v1.7 - game bug fix: unlock a lot of Artwork.
-- v1.8 - fix bugs 10495, 10509 - Objectives and E/M/H endings.
-- v1.9 - bugs 10495,10509,10631,10634,10635,10636
-- v2.0 - fix issue where Relatively Precise wouldn't trigger after very first mission.
-- v2.1 - will only check for Above and Beyond after finishing game.
-- v2.2 - unlock 4 more pieces of Artwork for Med & Hard levels.
-- v2.3 - fixed issue with Dive! Dive! Dive! bonus objective.

apiRequest(1.1)	-- request version 1.1 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()
local trophyObj	= getTrophyObject()
local gpr = require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

local REVOLUTIONARY						=  0 -- Unlock all other trophies.                                                                  There should probably be something in here about how using any of the game's freely available cheats invalidates trophy progress, IMO.
local ABOVE_AND_BEYOND					=  1 -- Clear the campaign while accomplishing all bonus objectives.								These aren't available in every stage.
local LETS_HAVE_A_GOOD_CLEAN_FIGHT		=  2 -- Clear the campaign without ever activating one of the cheats.                               
local A_HEROS_REWARD					=  3 -- Get the "I Remember Sopot" ending. (*)                                                      Complete all bonus objectives, achieving maximum Heroism as per the meter in the pause menu. Don't personally shoot civilians.
local A_QUIET_RETIREMENT				=  4 -- Get the "Glory Days" ending. (*)                                                            Complete most bonus objectives.
local PUT_DOWN_LIKE_A_MAD_DOG			=  5 -- Get the "On the Road Again" ending. (*)                                                     Complete very few, if any bonus objectives.
local VANISH_INTO_HISTORY				=  6 -- Get the "Judgement Day" ending. (*)                                                         Complete no bonus objectives whatsoever, and kill every ally or civilian you run into. Zero out the Heroism meter.
local DATA_TRANSFER						=  7 -- Complete "Foreign Lands." (*)                                                                   
local AND_NOW_LETS_MEET_THE_TEAM		=  8 -- Complete "Public Information Building." (*)                                                     
local FLIGHT_RISK						=  9 -- Complete "Shrike's Wild Ride." (*)                                                              
local SQUAD_GOALS						= 10 -- Complete "Underground." (*)                                                                     
local URBAN_RENEWAL						= 11 -- Complete "Tank on the Town." (*)                                                                
local OUR_NATION_CRUMBLES_FROM_WITHIN	= 12 -- Complete "Sopot's Citadel." (*)                                                                 
local BLOOD_IN_THE_STREETS				= 13 -- Complete "Hanging in the 'Hood." (*)                                                            
local DEAD_MANS_PARTY					= 14 -- Complete "Dancing With the Dead." (*)                                                           
local CRITICAL_DEPTH					= 15 -- Complete "A River Runs To It." (*)                                                              
local PROCESS_OF_ELIMINATION			= 16 -- Complete "Inside the Nanobase." (*)                                                             
local SAVIOR_OF_THE_COMMONWEALTH		= 17 -- Complete "In Sopot's Deadly Embrace." (*)                                                       
local THIS_IS_HOW_I_INFILTRATE			= 18 -- Complete "Foreign Lands" without using a non-explosive weapon. (*)                            
local RELATIVELY_PRECISE				= 19 -- Complete any stage with a hit percentage above 60%.                                         
local THE_ART_OF_OVERKILL				= 20 -- Get 100 headshots with an explosive weapon. (***)                                            i.e. grenade launcher, the underslung grenade launcher on the assault rifle, etc.
local CLOSED_CASKETS					= 21 -- Reduce 250 enemies to "gibs." (***)                                                               
local AS_NON_LETHAL_AS_I_GET			= 22 -- Kill 25 enemies by pistol-whipping them. (***)                                              The pistol whip is the alt-fire for the CPS-19 pistol.
local SPRAY_AND_PRAY					= 23 -- Kill 25 enemies with the CMP-32 (Machine pistol) or NCMG-44 (Nano) machine pistols. (***)                                 
local THE_BURNING_SEASON				= 24 -- Kill 25 enemies with incendiary rounds or grenades. (***)                                   The shotgun's alt-fire is an incendiary.
local COVER_FIRE						= 25 -- Kill 25 enemies by firing through a wall with the rail driver. (***)                              
local SIMPLE_YET_EFFECTIVE				= 26 -- Kill 25 enemies with the NICW's primary fire. (***)                                               
local SHOOT_FROM_THE_HIP				= 27 -- Kill 25 enemies with the CRS-60 (sniper) or precision sniper rifle without using their scopes. (***)   This is actually one of the most efficient ways to kill the Processed late in the game.
local WHISPERING_DEATH					= 28 -- Kill 25 enemies with the CSMG-19 silenced machine gun. (***)                                      
local ANKLE_DEEP_IN_SPENT_SHELLS		= 29 -- Kill 25 enemies with the CAR-72 (Assault Rifle) on full auto. (***)                                              
local WRECKER_OF_ENGINES				= 30 -- Destroy 25 vehicles with the WASP. (Wide Area Saturation Projectile)                                                         
local SUPPRESSIVE						= 31 -- Kill 25 enemies with the JF90 HMG. (Heavy Supression Machine Gun)                                                         
local CRUEL_AND_UNUSUAL					= 32 -- Stick a satchel charge onto 25 enemies.                                                     
local POINTS_FOR_EFFORT					= 33 -- Finish the campaign on Easy. (*)                                                                
local STRONG_ENOUGH_TO_PREVAIL			= 34 -- Finish the campaign on Medium. (*)                                                          I'm quoting the weird propaganda reel that plays over the title screen.
local DEMOLITION_MAN					= 35 -- Finish the campaign on Hard. (*)
local PLANNING_STAGES					= 36 -- Unlock all the concept art in the Gallery. (**)                                             http://www.gamefaqs.com/ps2/551510-red-faction-ii/faqs/21037
local CLASSIFIED_DOSSIERS				= 37 -- Unlock all the entries in the Gallery's Enemies menu. (**)                                       
local WRONG_PLACE_WRONG_TIME			= 38 -- Unlock all the entries in the Gallery's Civilians menu. (**)                                     
local AN_ARSENAL_OF_DOOM				= 39 -- Unlock all the entries in the Gallery's Equipment menu. (**)                                     
local ACCEPTABLE_TARGETS				= 40 -- Complete "Search and Destroy" without killing a civilian.                                   The key is basically to avoid raking the place with gunfire on your initial run. The civilians clear out eventually, but anyone who gets triggerhappy will ruin their chance at the trophy.
--  (*) without using the "Unlock All Levels" or "Unlock Every Cheat" cheats.
--  (**) without using the "Unlock Every Cheat" cheat.
--	(***) cannot be completed in Multiplayer mode.

--- WEAPONS ---
PISTOL					= 0x00
DUAL_PISTOLS			= 0x02
SHOTGUN					= 0x03
DUAL_MPS				= 0x04
MACHINE_PISTOL			= 0x05
NANO_GL					= 0x06
SNIPER_RIFLE			= 0x07
SMG			    		= 0x08
RAIL_GUN				= 0x0a	-- (10)
ASSAULT_RIFLE			= 0x0b	-- (11)
HMG						= 0x0c	-- (12)
WASP					= 0x0d	-- (13)
NICW					= 0x0e	-- (14)
NANO_MPS				= 0x0f	-- (15)
DUAL_NANO_MPS			= 0x10	-- (16)
PRECISION_RIFLE			= 0x11	-- (17)
ANTI_PERSONNEL			= 0x12	-- (18)
---
PISTOLWHIP				= 0x20	-- (32) made up for trophy
INCENDIARY				= 0x21  -- (33) made up for trophy
SATCHEL_CHARGE			= 0x22	-- (34) made up for trophy
EXPLOSION				= 0x23	-- (35) made up for trophy

--- PRIMARY or SECONDARY firing type
NOT_FIRING 	= 0
PRIMARY		= 1
SECONDARY	= 2

-- reverse weapon lookup (debugging)
local weaponName = {}
weaponName[0] = "PISTOL (0)"
weaponName[1] = "unknown (1)"
weaponName[2] = "DUAL_PISTOLS (2)"
weaponName[3] = "SHOTGUN (3)"
weaponName[4] = "DUAL_MPS (4)"
weaponName[5] = "MACHINE_PISTOL (5)"
weaponName[6] = "NANO_GL (6)"
weaponName[7] = "SNIPER_RIFLE (7)"
weaponName[8] = "SMG (8)"
weaponName[9] = "unknown (9)"
weaponName[10] = "RAIL_GUN (10)"
weaponName[11] = "ASSAULT_RIFLE (11)"
weaponName[12] = "HMG (12)"
weaponName[13] = "WASP (13)"
weaponName[14] = "NICW (14)"
weaponName[15] = "NANO_MPS (15)"
weaponName[16] = "DUAL_NANO_MPS (16)"
weaponName[17] = "PRECISION_RIFLE (17)"
weaponName[18] = "ANTI_PERSONNEL (18)"
---
weaponName[32] = "PISTOLWHIP (32)"
weaponName[33] = "INCENDIARY (33)"
weaponName[34] = "SATCHEL_CHARGE (34)"
weaponName[35] = "EXPLOSION (35)"

--- DIFFICULTY--
EASY					= 0x01
MEDIUM					= 0x02
HARD					= 0x04
---
CHEAT_LEVELS = 0
CHEAT_ARTWORK = 1
CHEAT_ANY = 2

local SaveDataDirty = false
local SaveDataCounter = 300
local SaveData = emuObj.LoadConfig(0)

local CHEATSBASE = 0x1ce35fc -- cheat list: 0x1d99bf0
local PROFILE = 0x1cdbff0
local ARTWORK = 0x1ce3643
local levelName = ""
local lastLevel = ""

function clearBonusObjectives()
		SaveData.bonusTable = {}
		SaveData.bonusTable["turret:1"] = 0
		SaveData.bonusTable["geo:2"] = 0
		SaveData.bonusTable["bonus:3"] = 0		-- turret to blow up in Marketing
		SaveData.bonusTable["pron:4"] = 0		-- destroy tapes
		SaveData.bonusTable["rail:4"] = 0
		SaveData.bonusTable["disrupt:4"] = 0
		SaveData.bonusTable["radar:5"] = 0
		SaveData.bonusTable["rail:6"] = 0
		SaveData.bonusTable["defenses:7"] = 0
		SaveData.bonusTable["refuel:8"] = 0
		SaveData.bonusTable["aid:9"] = 0
		SaveData.bonusTable["armor:9"] = 0
		SaveData.bonusTable["convoy:9"] = 0
		SaveData.bonusTable["defend:9"] = 0
		SaveData.bonusTable["processed:9"] = 0
		SaveData.bonusTable["bonus_jeeps:14"] = 0
		SaveData.bonusTable["bonus_trailers:14"] = 0
		SaveData.bonusTable["bonus_shortcut:14"] = 0
		SaveData.bonusTable["bonus_gunship:14"] = 0
		SaveData.bonusTable["bonus_rf:15"] = 0
		SaveData.bonusTable["bonus_overpass:15"] = 0
		SaveData.bonusTable["bonus_5ton:15"] = 0
		SaveData.bonusTable["bonus_gunship:15"] = 0
		SaveData.bonusTable["bonus_gunship:16"] = 0
		SaveData.bonusTable["bonus_dropship:16"] = 0
		SaveData.bonusTable["bonus_ba:16"] = 0
		SaveData.bonusTable["bonus_citpower:16"] = 0
		SaveData.bonusTable["bonus_water:16"] = 0
		SaveData.bonusTable["bonus_tower:16"] = 0
		SaveData.bonusTable["security_huts:16"] = 0
		SaveData.bonusTable["bonus_rf:16"] = 0
		SaveData.bonusTable["civvies:17"] = 0
		SaveData.bonusTable["mech:18"] = 0
		SaveData.bonusTable["arms:18"] = 0
		SaveData.bonusTable["crunch:19"] = 0
		SaveData.bonusTable["blowcomm:21"] = 0
		SaveData.bonusTable["fighters:23"] = 0
		SaveData.bonusTable["turret:23"] = 0
		SaveData.bonusTable["bonus_sniper4:24"] = 0
		SaveData.bonusTable["bonus_sniper8:24"] = 0
		SaveData.bonusTable["bonus_rf:24"] = 0
		SaveData.bonusTable["street:25"] = 0
		SaveData.bonusTable["easy_bonus:28"] = 0
		SaveData.bonusTable["hard_bonus:28"] = 0
		SaveData.bonusTable["med_bonus:28"] = 0
		SaveData.bonusTable["earring:28"] = 0
		SaveData.bonusTable["bath:28"] = 0
		SaveData.bonusTable["processed:29"] = 0
		SaveData.bonusTable["urns:29"] = 0
		SaveData.bonusTable["crush:31"] = 0
		SaveData.bonusTable["garbage:32"] = 0
		SaveData.bonusTable["bridge:33"] = 0
		SaveData.bonusTable["crates:33"] = 0
		SaveData.bonusTable["fuel:33"] = 0
		SaveData.bonusTable["subs_med:34"] = 0
		SaveData.bonusTable["subs_ez:34"] = 0
		SaveData.bonusTable["subs_hard:34"] = 0
end

local LEVELS = {"l00s1.rfl","l00s2.rfl","l01s1.rfl","l01s2.rfl","l01s3.rfl","l01s4.rfl","l01s5.rfl","l02s1.rfl","l02s2.rfl","l02s3.rfl",
				"l03s1.rfl","l03s2.rfl","l03s3.rfl","l03s4.rfl","l04s1.rfl","l04s2.rfl","l04s4.rfl","l05s1.rfl","l05s2.rfl","l05s3.rfl",
				"l05s4.rfl","l05s5.rfl","l05s6.rfl","l06s1.rfl","l06s1b.rfl","l06s2.rfl","l06s3.rfl","l06s3b.rfl","l08s1.rfl","l08s2.rfl",
				"l08s3.rfl","l09s1.rfl","l09s2.rfl","l09s3.rfl","l09s4.rfl","l10s1a.rfl","l10s1b.rfl","l10s1c.rfl","l10s1d.rfl","l10s2.rfl",
				"l10s3.rfl","l11s1.rfl","l11s1b.rfl","l11s2.rfl","THE_END"}

function initsaves()
	local needsSave = false

	if SaveData.t == nil then
		SaveData.t = {}
		needsSave = true
	end
	
	for x = 0, 40 do
		if SaveData.t[x] == nil then
			SaveData.t[x] = 0
			needsSave = true
		end
	end
	
	if SaveData.Weapon == nil then
		SaveData.Weapon = {}
		needsSave = true
	end
	if 	SaveData.Weapon[MACHINE_PISTOL] == nil then
		SaveData.Weapon[MACHINE_PISTOL] = 0				-- Set to 0 so + routine in weapon count doesn't error
		needsSave = true
	end
	if 	SaveData.Weapon[DUAL_MPS] == nil then
		SaveData.Weapon[DUAL_MPS] = 0
		needsSave = true
	end
	if 	SaveData.Weapon[NANO_MPS] == nil then
		SaveData.Weapon[NANO_MPS] = 0
		needsSave = true
	end
	if 	SaveData.Weapon[DUAL_NANO_MPS] == nil then
		SaveData.Weapon[DUAL_NANO_MPS] = 0
		needsSave = true
	end
	if 	SaveData.Weapon[SNIPER_RIFLE] == nil then
		SaveData.Weapon[SNIPER_RIFLE] = 0
		needsSave = true
	end
	if 	SaveData.Weapon[PRECISION_RIFLE] == nil then
		SaveData.Weapon[PRECISION_RIFLE] = 0
		needsSave = true
	end
	if 	SaveData.Weapon[PISTOLWHIP] == nil then
		SaveData.Weapon[PISTOLWHIP] = 0
		needsSave = true
	end
	if 	SaveData.Weapon[INCENDIARY] == nil then
		SaveData.Weapon[INCENDIARY] = 0
		needsSave = true
	end
	if 	SaveData.Weapon[EXPLOSION] == nil then
		SaveData.Weapon[EXPLOSION] = 0
		needsSave = true
	end
	if 	SaveData.Weapon[SATCHEL_CHARGE] == nil then
		SaveData.Weapon[SATCHEL_CHARGE] = 0
		needsSave = true
	end
	
	if SaveData.difficulty == nil then
		SaveData.difficulty = {}
	end
	
	if SaveData.gibs == nil then
		SaveData.gibs = 0
	end
	
	if SaveData.headshots == nil then
		SaveData.headshots = 0
	end
	
	if SaveData.bonusTable == nil then
		clearBonusObjectives()
		needsSave = true
	end
	
	if SaveData.cheats == nil then
		SaveData.cheats = {}
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
		SaveDataDirty = false
	end
end

-- GAME FUNCTIONS -----------------------------------------------------------------

function getPlayerName()
	local name = eeObj.ReadMemStr(PROFILE + 0xC)
	return name
end

function numFromLevel(levelName) -- from profile_stats_init 0x2F4BF8
	local offset = 0x1d67a30
	local name = ""
	local level = ""
	local pos = 0
	local levelNum = 0
	
	for i = 0, 44 do
		name = eeObj.ReadMemStr(offset + pos)
		level = eeObj.ReadMemStr(offset + 0x28 + pos)
		pos = pos + 0xc4
		
		if level == levelName then
			levelNum = i
		end
	end

	return levelNum
end

function entityGetKillerHandle(entity)
	return eeObj.ReadMem32(entity+0x3a4) -- from multi_scoring  (RF1 = 0x12cc) unknown if 728 is correct.
end

local function entityIsPlayer(entity) -- from obj_is_player
	local flags = eeObj.ReadMem32(entity + 0x80)
	return ((flags & 8) ~= 0)
end

local function entityIsHumanoid(entity) -- from entity_is_humanoid
	local obj = eeObj.ReadMem32(entity + 0x394)
	local flags = eeObj.ReadMem32(obj + 0xb0)
	return ((flags & 0x400) ~= 0)
end

local function entityIsVehicle(entity) -- NOT from entity_is_vehicle (function does not work)
	local obj = eeObj.ReadMem32(entity + 0x394)
	local flags = eeObj.ReadMem32(obj + 0xb0)
	return ((flags & 0x2000000) ~= 0)
end

local function entityIsOnFire(entity) -- from entity_is_on_fire
	local obj = eeObj.ReadMem32(entity + 0x338)
	return ((obj & 0x10000000) ~= 0)
end

local function entityGetFriendliness(entity)
	local flg = eeObj.ReadMem32(entity + 0xb8) -- from entity_damaged 0x21cf28

	if flg == 0 then
		-- is Enemy Fighter --
	else
		if entityIsHumanoid(entity) then
			flg = 1
		else
			if flg == 3 then
				flg = 1
			else
				flg = 0
			end
		end
	end
	
	return flg
end

function entityFromHandle(handle) -- from entity_from_handle
	local entityTable = 0xaf7150
	if handle ~= 0xffffffff then
		local offs = (handle & 0xffff)
		if offs < 0x400 then
			local entity = eeObj.ReadMem32(entityTable + (offs * 4))
			if eeObj.ReadMem32(entity+0x10) == handle and ( eeObj.ReadMem32(entity+0xC) == 0 or eeObj.ReadMem32(entity+0xC) == 3 ) then
				return entity
			end
		end
	end
	
	return 0
end

function getPlayerRecord(entity)
	return eeObj.ReadMem32(entity+0x770)	-- from entity_is_local_player
end

function getPlayerGun(entity)
	return eeObj.ReadMem32(entity+0x458)	-- from entity_process_gun_do_frame
end

function getGunFireType(gun) -- 0: Not firing, 1: primary, 2: secondary
	if gun ~= 0 then
		local flags = eeObj.ReadMem8(gun+0x08)
		
		if (flags & 0x10) ~= 0 then
			return SECONDARY
		else
			return PRIMARY
		end
	end
	
	return NOT_FIRING
end

function playerFromHandle(handle)	-- from player_from_handle
	local base = 0xc4f7e0
	local offset = eeObj.ReadMem32(base)
end

function getPlayerWeapon(entity)
	local record = getPlayerRecord(entity)
	
	if record ~= 0 then
		return eeObj.ReadMem32(record+0xbf4) --458)
	end
	
	return 0xffffffff
end

local function playerIsControllingDevice(entity) -- from obj_is_controlled_by_player 0x143CEC
	local obj = eeObj.ReadMem32(entity + 0x48)
	local device = entityFromHandle(obj)
	if device ~= 0 then
		return true
	end
	return false
end

function getHitPercentage() -- from game_sp_render_pause 0x12343c
	local hp = eeObj.ReadMemFloat(0xABF034)
	hp = hp * 100
	hp = tonumber(string.format("%3.2f", hp))
	
	if hp > 60 then
		unlockTrophy(RELATIVELY_PRECISE)	-- Complete any stage with a hit percentage above 60%.
	end
end

function checkKills(weapon)
-- PISTOL			= 0x00
-- DUAL_PISTOLS		= 0x02
-- SHOTGUN			= 0x03
-- DUAL_MPS			= 0x04
-- MACHINE_PISTOL	= 0x05
-- NANO_GL			= 0x06
-- SNIPER_RIFLE		= 0x07
-- SMG			   	= 0x08
-- RAIL_GUN			= 0x0a	-- (10)
-- ASSAULT_RIFLE	= 0x0b	-- (11)
-- HMG				= 0x0c	-- (12)
-- WASP				= 0x0d	-- (13)
-- NICW				= 0x0e	-- (14)
-- NANO_MPS			= 0x0f	-- (15)
-- DUAL_NANO_MPS	= 0x10	-- (16)
-- PRECISION_RIFLE	= 0x11	-- (17)
-- ANTI_PERSONNEL	= 0x12	-- (18)
-- PISTOLWHIP		= 0x20	-- (32) made up for trophy
-- INCENDIARY		= 0x21	-- (33) made up for trophy
-- SATCHEL_CHARGE	= 0x22	-- (34) made up for trophy
-- EXPLOSION		= 0x23	-- (35) made up for trophy

	if weapon == PISTOLWHIP and SaveData.Weapon[weapon] >= 25 then			-- Kill 25 enemies by pistol-whipping them. The pistol whip is the alt-fire for the CPS-19 pistol.
		unlockTrophy(AS_NON_LETHAL_AS_I_GET)
	elseif weapon == MACHINE_PISTOL or weapon == DUAL_MPS or weapon == NANO_MPS or weapon == DUAL_NANO_MPS then
		if SaveData.Weapon[MACHINE_PISTOL] + SaveData.Weapon[DUAL_MPS] + SaveData.Weapon[NANO_MPS] + SaveData.Weapon[DUAL_NANO_MPS] >= 25 then
			unlockTrophy(SPRAY_AND_PRAY)									-- Kill 25 enemies with the CMP-32 (Machine pistol) or NCMG-44 (Nano) machine pistols.
		end
	elseif weapon == INCENDIARY or weapon == EXPLOSION then
		if SaveData.Weapon[INCENDIARY] + SaveData.Weapon[EXPLOSION] >= 25 then
			unlockTrophy(THE_BURNING_SEASON)								-- Kill 25 enemies with incendiary rounds or grenades. The shotgun's alt-fire is an incendiary.
		end
	elseif weapon == RAIL_GUN and SaveData.Weapon[weapon] >= 25 then		-- Kill 25 enemies by firing through a wall with the rail driver.
		unlockTrophy(COVER_FIRE)
	elseif weapon == NICW and SaveData.Weapon[weapon] >= 25 then			-- Kill 25 enemies with the NICW's primary fire. 
		unlockTrophy(SIMPLE_YET_EFFECTIVE)
	elseif weapon == SNIPER_RIFLE or weapon == PRECISION_RIFLE then			-- Kill 25 enemies with the CRS-60 (sniper) or precision sniper rifle without using their scopes. This is actually one of the most efficient ways to kill the Processed late in the game.
		if (SaveData.Weapon[SNIPER_RIFLE] + SaveData.Weapon[PRECISION_RIFLE]) >= 25 then
			unlockTrophy(SHOOT_FROM_THE_HIP)
		end
	elseif weapon == SMG and SaveData.Weapon[weapon] >= 25 then				-- Kill 25 enemies with the CSMG-19 silenced machine gun.
		unlockTrophy(WHISPERING_DEATH)
	elseif weapon == ASSAULT_RIFLE and SaveData.Weapon[weapon] >= 25 then	-- Kill 25 enemies with the CAR-72 (Assault Rifle) on full auto.
		unlockTrophy(ANKLE_DEEP_IN_SPENT_SHELLS)		
	elseif weapon == WASP and SaveData.Weapon[weapon] >= 25  then			-- Destroy 25 vehicles with the WASP. (Wide Area Saturation Projectile)
		unlockTrophy(WRECKER_OF_ENGINES)
	elseif weapon == HMG and SaveData.Weapon[weapon] >= 25 then				-- Kill 25 enemies with the JF90 HMG. (Heavy Supression Machine Gun)
		unlockTrophy(SUPPRESSIVE)
	end
end

function getGameDifficulty()
	local difficulty = eeObj.ReadMem16(eeObj.GetGpr(gpr.gp) - 0x555C)
	if difficulty == 0 then
		difficulty = EASY			-- 1
	elseif difficulty == 1 then
		difficulty = MEDIUM 		-- 2
	elseif difficulty == 2 then
		difficulty = HARD			-- 4
	else
		difficulty = EASY -- default to easy
	end	
		
	return difficulty
end

function checkObjectives()
	local obj = true
	
	-- All of these must be complete --
	if SaveData.bonusTable["turret:1"] == 0 or SaveData.bonusTable["geo:2"] == 0 or 
		SaveData.bonusTable["bonus:3"] == 0 or SaveData.bonusTable["pron:4"] == 0 or
		SaveData.bonusTable["rail:4"] == 0 or SaveData.bonusTable["disrupt:4"] == 0 or
		SaveData.bonusTable["radar:5"] == 0 or SaveData.bonusTable["rail:6"] == 0 or
		SaveData.bonusTable["defenses:7"] == 0 or SaveData.bonusTable["refuel:8"] == 0 or
		SaveData.bonusTable["aid:9"] == 0 or SaveData.bonusTable["armor:9"] == 0 or
		SaveData.bonusTable["convoy:9"] == 0 or SaveData.bonusTable["defend:9"] == 0 or
		SaveData.bonusTable["processed:9"] == 0 or SaveData.bonusTable["bonus_trailers:14"] == 0 or
		SaveData.bonusTable["bonus_shortcut:14"] == 0 or SaveData.bonusTable["bonus_jeeps:14"] == 0 or
		SaveData.bonusTable["bonus_gunship:14"] == 0 or SaveData.bonusTable["bonus_rf:15"] == 0 or
		SaveData.bonusTable["bonus_overpass:15"] == 0 or SaveData.bonusTable["bonus_5ton:15"] == 0 or
		SaveData.bonusTable["bonus_gunship:15"] == 0 or SaveData.bonusTable["bonus_gunship:16"] == 0 or
		SaveData.bonusTable["bonus_dropship:16"] == 0 or SaveData.bonusTable["bonus_ba:16"] == 0 or
		SaveData.bonusTable["bonus_citpower:16"] == 0 or SaveData.bonusTable["bonus_water:16"] == 0 or
		SaveData.bonusTable["bonus_tower:16"] == 0 or SaveData.bonusTable["security_huts:16"] == 0 or
		SaveData.bonusTable["bonus_rf:16"] == 0 or SaveData.bonusTable["civvies:17"] == 0 or
		SaveData.bonusTable["mech:18"] == 0 or SaveData.bonusTable["arms:18"] == 0 or
		SaveData.bonusTable["crunch:19"] == 0 or SaveData.bonusTable["blowcomm:21"] == 0 or
		SaveData.bonusTable["fighters:23"] == 0 or SaveData.bonusTable["turret:23"] == 0 or
		SaveData.bonusTable["bonus_sniper4:24"] == 0 or SaveData.bonusTable["bonus_sniper8:24"] == 0 or
		SaveData.bonusTable["bonus_rf:24"] == 0 or SaveData.bonusTable["street:25"] == 0 or
		SaveData.bonusTable["earring:28"] == 0 or SaveData.bonusTable["bath:28"] == 0 or
		SaveData.bonusTable["processed:29"] == 0 or SaveData.bonusTable["urns:29"] == 0 or
		SaveData.bonusTable["crush:31"] == 0 or SaveData.bonusTable["garbage:32"] == 0 or
		SaveData.bonusTable["crates:33"] == 0 or SaveData.bonusTable["fuel:33"] == 0 then
		obj = false
	end
	
	-- At least one of these --
	if SaveData.bonusTable["easy_bonus:28"] == 0 and SaveData.bonusTable["hard_bonus:28"] == 0 and SaveData.bonusTable["med_bonus:28"] == 0 then
		obj = false		-- Kill the Processed
	end

	-- Misc --
	local diff = getGameDifficulty()
	if diff > EASY then		-- these objectives only works on Medium or Hard.
		if SaveData.bonusTable["subs_med:34"] == 0 and SaveData.bonusTable["subs_hard:34"] == 0 then
			obj = false		-- Destroy all enemy subs
		end

		if SaveData.bonusTable["bridge:33"] == 0 then
			obj = false
		end
	end
	
	if obj == true then
		unlockTrophy(ABOVE_AND_BEYOND)	-- Clear the campaign while accomplishing all bonus objectives.
	end
end

function getLevel()	-- from call to level_parse_get_absolute_section_index
	local levelPtr = 0xAD41F4
	local str = eeObj.ReadMemStr(levelPtr)
	str = string.lower(str)
	lastLevel = str
	
	return str
end
levelName = getLevel()

-- GALLERY --

function playerProfileIsUnlocked(a1, a2, a3)
	local PlayerOffset = 0x1ce3643	-- from player_profile_is_unlocked
	local PlayerOffset2 = 0x1ce3704
	local PlayerOffset3 = 0x1ce3670
	local res, val = 0, 0
	local maxArt = 0x1869f
	
	if maxArt ~= a1 then
		res = PlayerOffset + a1
		val = eeObj.ReadMem8(res)

		if val == 0xff then
			val = -1
		end

		if val < a2 then
			res = 1
		else
			res = 0
		end
		
		if res == 0 then
			if a3 < 0 then
				res = 1
			else
				res = PlayerOffset3 + a3
				res = eeObj.ReadMem8(res)
				if res == 0xff then
					res = -1
				end
				
				if res < a2 then
					res = 1
				else
					res = 0
				end
				if res == 1 then			-- xor 1
					res = 0	
				else
					res = 1
				end
			end
		else
			res = 0
		end
	else
		res = PlayerOffset2 + a2
		val = eeObj.ReadMem8(res)
		if val == 0xff then
			val = -1
		end
		if 0 < val then
			res = 1
		else
			res = 0
		end
	end
	
	return res
end

function extrasGalleryGetConcept(item)	-- Concept Art
	local artOffset = 0x1d769c0				-- len 28
	
	offset = item << 2
	offset = offset + item
	offset = offset << 3
	offset = artOffset + offset
		
	return offset
end

function conceptArt()
	local name = getPlayerName()
	if SaveData.cheats[name] ~= nil then
		if SaveData.cheats[name][CHEAT_ARTWORK] == true then
			return
		end
	end
	
	local itemCount = 0x1ce				-- from extras_gallery_list_init 0x2f11c4 ($gp - 0x4890)
	local offset = 0
	local a1, a2, a3 = 0,0,0
	local unlockedCount = 0
	local result = 0
	local item = 0

	for item = 0, (itemCount -1) do
		offset = extrasGalleryGetConcept(item)
		
		a1 = eeObj.ReadMem32(offset + 0x1c)
		if a1 == 0xffffffff then
			a1 = -1
		end
		a2 = eeObj.ReadMem32(offset + 0x20)
		if a2 == 0xffffffff then
			a2 = -1
		end
		a3 = eeObj.ReadMem32(offset + 0x24)
		if a3 == 0xffffffff then
			a3 = -1
		end
		
		result = playerProfileIsUnlocked(a1, a2, a3)
	
		if result == 1 then
			unlockedCount = unlockedCount + 1
		end
	end
	
	if unlockedCount == itemCount then
		return true
	else
		return false
	end
end

function extrasGalleryGetEnemy(item)		-- Enemy Art
	local artOffset = 0x1D6CA00				-- len 724
	local val = 0x2d4
	
	offset = val * item
	offset = artOffset + offset
	
	return offset
end

function enemyArt()
	local name = getPlayerName()
	if SaveData.cheats[name] ~= nil then
		if SaveData.cheats[name][CHEAT_ARTWORK] == true then
			return
		end
	end
	
	local itemCount = 0x16				-- from extras_gallery_get_char 0x2EE414
	local offset = 0
	local a1, a2, a3 = 0,0,0
	local unlockedCount = 0
	local result = 0
	local item = 0
	
	for item = 0, (itemCount -1) do
		offset = extrasGalleryGetEnemy(item)

		a1 = eeObj.ReadMem32(offset + 0x2c8)
		if a1 == 0xffffffff then
			a1 = -1
		end
		a2 = eeObj.ReadMem32(offset + 0x2cc)
		if a2 == 0xffffffff then
			a2 = -1
		end
		a3 = eeObj.ReadMem32(offset + 0x2d0)
		if a3 == 0xffffffff then
			a3 = -1
		end
		
		result = playerProfileIsUnlocked(a1, a2, a3)
		
		if result == 1 then
			unlockedCount = unlockedCount + 1
		end
	end
	
	if unlockedCount == itemCount then
		return true
	else
		return false
	end
end

function extrasGalleryGetCivilian(item)		-- Civilian Art
	local artOffset = 0x1D71EE0				-- len 724
	local val = 0x2d4

	offset = val * item
	offset = artOffset + offset
	
	return offset
end

function civilianArt()
	local name = getPlayerName()
	if SaveData.cheats[name] ~= nil then
		if SaveData.cheats[name][CHEAT_ARTWORK] == true then
			return
		end
	end
	
	local itemCount = 0xc				-- from extras_gallery_get_char 0x2EE42C
	local offset = 0
	local a1, a2, a3 = 0,0,0
	local unlockedCount = 0
	local result = 0
	local item = 0
	
	for item = 0, (itemCount -1) do
		offset = extrasGalleryGetCivilian(item)

		a1 = eeObj.ReadMem32(offset + 0x2c8)
		if a1 == 0xffffffff then
			a1 = -1
		end
		a2 = eeObj.ReadMem32(offset + 0x2cc)
		if a2 == 0xffffffff then
			a2 = -1
		end
		a3 = eeObj.ReadMem32(offset + 0x2d0)
		if a3 == 0xffffffff then
			a3 = -1
		end
		
		result = playerProfileIsUnlocked(a1, a2, a3)
		
		if result == 1 then
			unlockedCount = unlockedCount + 1
		end
	end
	
	if unlockedCount == itemCount then
		return true
	else
		return false
	end
end

function extrasGalleryGetStatic(item)		-- Equipment Art
	local artOffset = 0x1D75770				-- len 156
	
	offset = item << 2
	offset = offset + item
	offset = offset << 3
	offset = offset - item
	offset = offset << 2
	offset = artOffset + offset
	
	return offset
end

function equipmentArt()
	local name = getPlayerName()
	if SaveData.cheats[name] ~= nil then
		if SaveData.cheats[name][CHEAT_ARTWORK] == true then
			return
		end
	end
	
	local itemCount = 0x1b				-- from extras_gallery_get_static 0x2ee498
	local offset = 0
	local a1, a2, a3 = 0,0,0
	local unlockedCount = 0
	local result = 0
	local item = 0
	
	for item = 0, (itemCount -1) do
		offset = extrasGalleryGetStatic(item)

		a1 = eeObj.ReadMem32(offset + 0x90)
		if a1 == 0xffffffff then
			a1 = -1
		end
		a2 = eeObj.ReadMem32(offset + 0x94)
		if a2 == 0xffffffff then
			a2 = -1
		end
		a3 = eeObj.ReadMem32(offset + 0x98)
		if a3 == 0xffffffff then
			a3 = -1
		end
		
		result = playerProfileIsUnlocked(a1, a2, a3)
		
		if result == 1 then
			unlockedCount = unlockedCount + 1
		end
	end
	
	if unlockedCount == itemCount then
		return true
	else
		return false
	end
end

function checkGallery()
	local result = false
	-- Gallery Trophies --
	result = civilianArt()
	if result == true then
		unlockTrophy(WRONG_PLACE_WRONG_TIME)	-- Unlock all the entries in the Gallery's Civilians menu.
	end
	result = conceptArt()
	if result == true then
		unlockTrophy(PLANNING_STAGES)			-- Unlock all the concept art in the Gallery.
	end
	result = enemyArt()
	if result == true then
		unlockTrophy(CLASSIFIED_DOSSIERS)		-- Unlock all the entries in the Gallery's Enemies menu.
	end
	result = equipmentArt()
	if result == true then
		unlockTrophy(AN_ARSENAL_OF_DOOM)		-- Unlock all the entries in the Gallery's Equipment menu.                                     
	end
end

function checkDifficulty()
	local easyFlag, mediumFlag, hardFlag = true,true,true
	local level = ""
	local val = 0
	
	for i = 2, 44 do
		level = LEVELS[i]
		if SaveData.difficulty[level] ~= nil then
			val = SaveData.difficulty[level]
		else
			val = 0
		end

		if val & EASY ~= EASY then
			easyFlag = false
		end
		if val & MEDIUM ~= MEDIUM then
			mediumFlag = false
		end
		if val & HARD ~= HARD then
			hardFlag = false
		end
	end
	
	if easyFlag == true then
		unlockTrophy(POINTS_FOR_EFFORT)			-- Finish the campaign on Easy.
	end
	if mediumFlag == true then
		unlockTrophy(STRONG_ENOUGH_TO_PREVAIL)	-- Finish the campaign on Medium.
	end
	if hardFlag == true then
		unlockTrophy(DEMOLITION_MAN)			-- Finish the campaign on Hard.
	end
end

-- MAIN FUNCTIONS -----------------------------------------------------------------

local entityTable = {}
local weaponType = {}
local fireType = {}
local gibsTable = {}
local headshotTable = {}
local sniperRectile = false
local railHitWall = false
local meleeAttack = false
local stickSatchel = 0xffffffff
local explosionTable = {}
local incendiaryTable = {}
local useGrenade = false
local explosiveInfiltration = true
local searchAndDestroy = false

local H1 = function() -- entity_death_finally_die
	local entity = eeObj.GetGpr(gpr.a0)	-- entity being killed.
	local entityName = eeObj.ReadMemStr(entity+0x234)

	local killerHandle = entityGetKillerHandle(entity)
	local killerEntity = entityFromHandle(killerHandle)
	
	if killerEntity ~= 0 then
		local killerName = eeObj.ReadMemStr(killerEntity+0x234)

		if entityIsPlayer(killerEntity) then
			local weapon = entityTable[entity]	-- lookup in table of enemies to see what weapon was last used to damage them.
			local priSecFire = fireType[entity]
			
			if weapon ~= 0xFFFFFFFF and weapon ~= nil then -- kill with weapon
				-- PISTOL			= 0x00
				-- DUAL_PISTOLS		= 0x02
				-- SHOTGUN			= 0x03
				-- DUAL_MPS			= 0x04
				-- MACHINE_PISTOL	= 0x05
				-- NANO_GL			= 0x06
				-- SNIPER_RIFLE		= 0x07
				-- SMG			   	= 0x08
				-- RAIL_GUN			= 0x0a	-- (10)
				-- ASSAULT_RIFLE	= 0x0b	-- (11)
				-- HMG				= 0x0c	-- (12)
				-- WASP				= 0x0d	-- (13)
				-- NICW				= 0x0e	-- (14)
				-- NANO_MPS			= 0x0f	-- (15)
				-- DUAL_NANO_MPS	= 0x10	-- (16)
				-- PRECISION_RIFLE	= 0x11	-- (17)
				-- ANTI_PERSONNEL	= 0x12	-- (18)
				-- PISTOLWHIP		= 0x20	-- (32) made up for trophy
				-- INCENDIARY		= 0x21	-- (33) made up for trophy
				-- SATCHEL_CHARGE	= 0x22	-- (34) made up for trophy
				-- EXPLOSION		= 0x23	-- (35) made up for trophy

				local friendly = entityGetFriendliness(entity)
				-- 0 = enemy, 1 = non-combatant or Red Faction fighter
				
				if friendly == 0 then	-- enemy killed
					if SaveData.Weapon[weapon] == nil then
						SaveData.Weapon[weapon] = 0
					end
					if playerIsControllingDevice(killerEntity) == true then
						return -- entity is controlling something (e.g. Gunship, Tank, Sub or Mech)
					end
					if weapon == RAIL_GUN then
						if railHitWall == true then	-- Rail Driver hits only count if they go thru wall first.
							SaveData.Weapon[weapon] = SaveData.Weapon[weapon] + 1
							SaveDataDirty = true
							checkKills(weapon)
						end
					elseif weapon == NICW then
						if priSecFire == PRIMARY then
							SaveData.Weapon[weapon] = SaveData.Weapon[weapon] + 1
							SaveDataDirty = true
							checkKills(weapon)
						end
					elseif weapon == SNIPER_RIFLE or weapon == PRECISION_RIFLE then
						if sniperRectile == false then
							SaveData.Weapon[weapon] = SaveData.Weapon[weapon] + 1
							SaveDataDirty = true
							checkKills(weapon)
						end
					elseif weapon == ASSAULT_RIFLE then
						if priSecFire == PRIMARY then
							SaveData.Weapon[weapon] = SaveData.Weapon[weapon] + 1
							SaveDataDirty = true
							checkKills(weapon)
						end
					elseif weapon == WASP then
						local vehicle = entityIsVehicle(entity)
						if vehicle == true then
							SaveData.Weapon[weapon] = SaveData.Weapon[weapon] + 1
							SaveDataDirty = true
							checkKills(weapon)
						end
					elseif weapon == SHOTGUN then
						if entityIsOnFire(entity) == true then
							SaveData.Weapon[INCENDIARY] = SaveData.Weapon[INCENDIARY] + 1
							SaveDataDirty = true
							checkKills(INCENDIARY)
						end
					elseif weapon == SATCHEL_CHARGE or weapon == EXPLOSION or weapon == INCENDIARY then
						useGrenade = false -- reset
						local humanoid = entityIsHumanoid(entity)
						if humanoid == true then
							if weapon == EXPLOSION or weapon == INCENDIARY then
								SaveData.Weapon[weapon] = SaveData.Weapon[weapon] + 1
								checkKills(weapon)
							end
						end
						weaponType[entity] = nil -- prevent "incendiary" counts from incrementing.
					else
						SaveData.Weapon[weapon] = SaveData.Weapon[weapon] + 1
						SaveDataDirty = true
						checkKills(weapon)
					end
					
					if weaponType[entity] == 3 then
						local humanoid = entityIsHumanoid(entity)
						if humanoid == true then
							SaveData.Weapon[INCENDIARY] = SaveData.Weapon[INCENDIARY] + 1
							SaveDataDirty = true			-- Note: WeaponType 3 means incendiary.
							checkKills(INCENDIARY)
						end
					end
					
					if gibsTable[entity] ~= nil then
						SaveData.gibs = SaveData.gibs + 1
						SaveDataDirty = true
						if SaveData.gibs >= 250 then
							unlockTrophy(CLOSED_CASKETS)	-- Reduce 250 enemies to "gibs."
						end
					end
					if headshotTable[entity] ~= nil then
						SaveData.headshots = SaveData.headshots + 1
						SaveDataDirty = true
						if SaveData.headshots >= 100 then
							unlockTrophy(THE_ART_OF_OVERKILL)	-- Get 100 headshots with an explosive weapon.
						end
					end
				else -- non-combatant or RF fighter killed
					if levelName == "l02s1.rfl" then
						searchAndDestroy = true				-- killed non-combatant on "search and destroy"
					end
				end
			end
		else
			entityTable[entity] = nil	-- not killed by player: remove entry to prevent possible Gibs.
		end
		gibsTable[entity] = nil			-- clear gibs
		headshotTable[entity] = nil		-- clear headshots
	end	
end

local H2 = function() -- entity_damage
	local entityDamaged = eeObj.GetGpr(gpr.a0)
	local entityDamagerHandle = eeObj.GetGpr(gpr.a1)
	if entityDamagerHandle == 0xffffffff or entityDamaged == 0xffffffff then
		return
	end
	local weapon = 0xffffffff
	local entityDamager = entityFromHandle(entityDamagerHandle)
	if entityDamager == 0 then
		return
	end
	local damageType = eeObj.GetGpr(gpr.a2)
	local gun = getPlayerGun(entityDamager)
	local priSecFire = getGunFireType(gun)

	if entityDamager ~= 0 then
		if entityIsPlayer(entityDamager) then
			if meleeAttack == true then
				weapon = PISTOLWHIP
				explosiveInfiltration = false
			elseif stickSatchel == entityDamaged then
				weapon = SATCHEL_CHARGE
				stickSatchel = 0xffffffff
			elseif explosionTable[entityDamaged] ~= nil then
				weapon = EXPLOSION
				explosionTable[entityDamaged] = nil		-- reset
			elseif incendiaryTable[entityDamaged] ~= nil then
				weapon = INCENDIARY
			else
				weapon = getPlayerWeapon(entityDamager)
				if string.sub(levelName, 1, 3) == "l00" then
					if weapon == 14 and priSecFire == 1 then
						explosiveInfiltration = false	-- NICW primary
					elseif weapon == 0 or weapon == 11 or weapon == 32 then
						explosiveInfiltration = false	-- pistol, assault rifle
					end
				end
			end
			
			if weapon ~= 0xffffffff then
				entityTable[entityDamaged] = weapon
				weaponType[entityDamaged] = damageType
				fireType[entityDamaged] = priSecFire
			end
		end
	end
	meleeAttack = false
end

local H3 = function() -- p_satchel::projectile_hit_callback
	local entity = eeObj.GetGpr(gpr.s0)
	if stickSatchel ~= entity then
		SaveData.Weapon[SATCHEL_CHARGE] = SaveData.Weapon[SATCHEL_CHARGE] + 1
		SaveDataDirty = true
		stickSatchel = entity
		
		if SaveData.Weapon[SATCHEL_CHARGE] >= 25 then	-- Stick a satchel charge onto 25 enemies.
			unlockTrophy(CRUEL_AND_UNUSUAL)
		end
	end
end

local H4 = function() -- level_set_filename
	levelName = eeObj.ReadMemStr(eeObj.GetGpr(gpr.a0))
	levelName = string.lower(levelName)
	if levelName ~= nil then
		entityTable = {}
		weaponType = {}
		fireType = {}
		explosionTable = {}
		incendiaryTable = {}
		
--		checkDifficulty() -- check incase player went back and did a level on a different difficulty.
	end
	
	-- DIFFICULTY --
	local name = getPlayerName()
	local cheatFlag = false
	if SaveData.cheats[name] ~= nil then
		if SaveData.cheats[name][CHEAT_LEVELS] ~= nil then
			cheatFlag = true
		end
	end
	if cheatFlag == false then
		if lastLevel ~= "" and lastLevel ~= levelName then
			local diff = getGameDifficulty()

			if SaveData.difficulty[lastLevel] == nil then
				SaveData.difficulty[lastLevel] = 0
			end
			local sd = SaveData.difficulty[lastLevel] | diff
			SaveData.difficulty[lastLevel] = sd -- easy=1, med=2, hard=4 (bitfield)
			SaveDataDirty = true
		end
	
		-- LEVEL LOGIC --
		if levelName == "l00s1.rfl" then					-- Game Start or Reset.  Initalize things.
			clearBonusObjectives()
			explosiveInfiltration = true
			return											-- dont check Hit Percentage (below)
		elseif levelName == "l01s1.rfl" then
			unlockTrophy(DATA_TRANSFER)						-- Complete "Foreign Lands."
			if explosiveInfiltration == true then --and SaveData.cheats[CHEAT_ANY] == nil then
				unlockTrophy(THIS_IS_HOW_I_INFILTRATE)		-- Complete "Foreign Lands" without using a non-explosive weapon.
			end
		elseif levelName == "l02s1.rfl" then
			unlockTrophy(AND_NOW_LETS_MEET_THE_TEAM)		-- Complete "Public Information Building."
			searchAndDestroy = false
		elseif levelName == "l02s2.rfl" then
			if searchAndDestroy == false then
				unlockTrophy(ACCEPTABLE_TARGETS)			-- Complete "Search and Destroy" without killing a civilian.
			end
		elseif levelName == "l03s1.rfl" then
			unlockTrophy(FLIGHT_RISK)						-- Complete "Shrike's Wild Ride." 
		elseif levelName == "l04s1.rfl" then
			unlockTrophy(SQUAD_GOALS)						-- Complete "Underground." 
		elseif levelName == "l05s1.rfl" then
			unlockTrophy(URBAN_RENEWAL)						-- Complete "Tank on the Town."
		elseif levelName == "l06s1.rfl" then
			unlockTrophy(OUR_NATION_CRUMBLES_FROM_WITHIN)	-- Complete "Sopot's Citadel." 
		elseif levelName == "l08s1.rfl" then
			unlockTrophy(BLOOD_IN_THE_STREETS)				-- Complete "Hanging in the 'Hood."
		elseif levelName == "l09s1.rfl" then
			unlockTrophy(DEAD_MANS_PARTY)					-- Complete "Dancing With the Dead." 
		elseif levelName == "l10s1a.rfl" then
			unlockTrophy(CRITICAL_DEPTH)					-- Complete "A River Runs To It." 
		elseif levelName == "l11s1.rfl" then
			unlockTrophy(PROCESS_OF_ELIMINATION)			-- Complete "Inside the Nanobase."
		end
	end

	checkGallery()

	if (lastLevel ~= "" and lastLevel ~= levelName) or (lastLevel == "l00s1.rfl" or (lastLevel == "" and levelName == "l00s2.rfl")) then
		getHitPercentage() -- level may have been restarted, do not check hit percentage. But only check if after very first level.
	end

	lastLevel = levelName
end

-- Rail Gun Thru Wall code --
-- The game first checks hit thru all solid objects.  Then the 2nd pass sees if it goes thru any
-- Entities.  So for the first pass (H8) we get the first "hit" to get the distance.  Then (H9) we get
-- any entity hits and calc the distance using the first routines "origin" against the entities origin,
-- since the entity does not give us the distance.

local x1, y1, z1 = 0,0,0	-- origin point
local railStart = false
local wallDistance = 100

function vectorDistance(x1,x2,y1,y2,z1,z2)
	local x = x1 - x2
	local y = y1 - y2
	local z = z1 - z2
	
	x = x * x
	y = y * y
	z = z * z
	
	local var = math.sqrt(x + y + z)
	
	return var
end

local H5 = function()
	x1, y1, z1 = 0,0,0
	railStart = true
	wallDistance = 100
	railHitWall = false
end
local H6 = function()
	if railStart == true then
		local a0 = eeObj.GetGpr(gpr.a0)	-- origin
		x1 = eeObj.ReadMemFloat(a0)
		y1 = eeObj.ReadMemFloat(a0+4)
		z1 = eeObj.ReadMemFloat(a0+8)
		local a1 = eeObj.GetGpr(gpr.a1)	-- object hit
		x2 = eeObj.ReadMemFloat(a1)
		y2 = eeObj.ReadMemFloat(a1+4)
		z2 = eeObj.ReadMemFloat(a1+8)
		wallDistance = vectorDistance(x1,x2,y1,y2,z1,z2)
	end
	railStart = false
end
local H7 = function()
	if x1 == 0 and y1 == 0 and z1 == 0 then
		return -- origin not set
	end
	
	local sp = eeObj.GetGpr(gpr.sp)
	sp = sp + 0x3d0
	local x2 = eeObj.ReadMemFloat(sp)
	local y2 = eeObj.ReadMemFloat(sp+4)
	local z2 = eeObj.ReadMemFloat(sp+8)
	
	local enemyDistance = vectorDistance(x1,x2,y1,y2,z1,z2)
	
	if wallDistance < enemyDistance then
		railHitWall = true
	end
end
-- End Rail Gun code --

local H8 = function() -- player_stats_increment_head_shots
	local entityDamaged = eeObj.GetGpr(gpr.s4)	-- called from entity_damage.

	if headshotTable[entityDamaged] == nil then
		headshotTable[entityDamaged] = 1
	end
end

local H9 = function() -- entity_blood_spawn_gibs
	local entity = eeObj.GetGpr(gpr.a0)
	if gibsTable[entity] == nil then
		gibsTable[entity] = 1
	end
end

local H10 = function() -- gun::standard_melee_collide_helper
	local weaponPtr = eeObj.GetGpr(gpr.s4)
	local entityHandle = eeObj.ReadMem32(weaponPtr + 0xC)
	if entityHandle == 0 then
		return
	end
	local entity = entityFromHandle(entityHandle)	-- make sure that rifle is players rifle.
	if not(entityIsPlayer(entity)) then
		return
	end

	meleeAttack = true
end

local H11 = function() -- g_quill_sniper::do_actual_firing OR g_sniper::do_actual_firing
	local weaponPtr = eeObj.GetGpr(gpr.a0)
	local entityHandle = eeObj.ReadMem32(weaponPtr + 0xC)
	if entityHandle == 0 then
		return
	end
	local entity = entityFromHandle(entityHandle)	-- make sure that rifle is players rifle.
	if not(entityIsPlayer(entity)) then
		return
	end
	
	local weapon = eeObj.ReadMem8(weaponPtr + 0xEC)
	if weapon & 0x8 == 8 then
		sniperRectile = true
	else
		sniperRectile = false
	end
end

local H12 = function() -- obj_apply_radius_damage_to_object (when player uses grenade, adjust "weapon")
	local entityDamaged = eeObj.GetGpr(gpr.s0)
	if not(entityIsPlayer(entityDamaged)) then
		if useGrenade == true then
			explosionTable[entityDamaged] = 1
		end
	end
end

local H13 = function() -- item_use_grenade
	useGrenade = true
end

local H14 = function()	-- objective_succeed
	local bonus = eeObj.GetGpr(gpr.s3)
	local bonusFlag = eeObj.ReadMem32(bonus + 0x98) -- from 0x251290
	
	if bonusFlag == 2 then
		local levelIndex = eeObj.GetGpr(gpr.v0)
		local str = eeObj.ReadMemStr(bonus)
		str = string.gsub(str, "%s+", "")	-- remove any spaces
		str = str .. ":" .. levelIndex
		str = string.lower(str)				-- convert all to lower case
		SaveData.bonusTable[str] = 1
		SaveDataDirty = true
		
		-- Unlock Artwork based on Bonus Objectives --
		if str == "bonus:3" then				-- bug fix after completing "Admin Area"
			local mem = ARTWORK + 0x38			-- Concept art: 29
			eeObj.WriteMem8(mem, 0x02)		
		elseif str == "disrupt:4" then			-- bug fix after completing "Propaganda Studios"
			local mem = ARTWORK + 0x37			-- Concept art: 203 medium
			eeObj.WriteMem8(mem, 0x02)		
		elseif str == "rail:6" then				-- bug fix after completing "To The Rooftop" --
			local mem = ARTWORK + 0x06			-- Concept art: 207 hard
			eeObj.WriteMem8(mem, 0x02)		
			local mem = ARTWORK + 0x2d			-- Concept art: 207 hard
			eeObj.WriteMem8(mem, 0x02)		
		elseif str == "refuel:8" then			-- bug fix after completing "Aerial Encounters"
			local mem = ARTWORK + 0x3a			-- Concept art: 349 medium
			eeObj.WriteMem8(mem, 0x02)		
		elseif str == "bonus_gunship:14" then	-- bug fix after completing "Tank Gunner"
			-- EASY --
			local mem = ARTWORK + 0x4b 			-- Concept art: 129,131,133-138,147,149,157-160,165,320,329,332,333,364,405,409
			eeObj.WriteMem8(mem, 0x02)		
			local mem = ARTWORK + 0x4c 			-- Concept art: 132,139-143,148,154-156,330,334,335,375-378,406
			eeObj.WriteMem8(mem, 0x02)		
			local mem = ARTWORK + 0x4d 			-- Concept art: 144-146,151-153,336,337,407
			eeObj.WriteMem8(mem, 0x02)		
			local mem = ARTWORK + 0x4e 			-- Concept art: 150,162-164,166,167,338,339,408
			eeObj.WriteMem8(mem, 0x02)		
			-- MEDIUM --
			local mem = ARTWORK + 0x3b			-- Concept art: 48
			eeObj.WriteMem8(mem, 0x02)		
			local mem = ARTWORK + 0x3c			-- Concept art: 50
			eeObj.WriteMem8(mem, 0x02)		
			local mem = ARTWORK + 0x30 			-- Concept art: 363
			eeObj.WriteMem8(mem, 0x02)
		elseif str == "bonus_5ton:15" then
			local mem = ARTWORK + 0x31			-- bug fix: 24 "5 ton military truck" Gallery art does not always set the bit.  Force it.
			eeObj.WriteMem8(mem, 0x02)
		elseif str == "bonus_gunship:15" then	-- bug fix after completing "Traffic Congestion"
			local mem = ARTWORK + 0x68 			-- Concept art: 324 medium
			eeObj.WriteMem8(mem, 0x02)		
		elseif str == "bonus_gunship:16" then	-- bug fix after completing "Road to the Citadel"
			local mem = ARTWORK + 0x6f			-- Concept art: 352 medium
			eeObj.WriteMem8(mem, 0x02)		
		elseif str == "mech:18" then			-- bug fix after Completing "Main Gate"
			local mem = ARTWORK + 0x12			-- Concept art: top bits
			eeObj.WriteMem8(mem, 0x02)		
			local mem = ARTWORK + 0x50			-- Concept art: 59,60,244 medium, 246 hard
			eeObj.WriteMem8(mem, 0x02)		
		elseif str == "blowcomm:21" then		-- bug fix after Completing "Hot Pursuit"
			local mem = ARTWORK + 0x66			-- Concept art: 319 Medium
			eeObj.WriteMem8(mem, 0x02)		
		elseif str == "bonus_rf:24" then		-- bug fix after Completing "High Rise Hell"
			local mem = ARTWORK + 0x43			-- Concept art: 89 medium
			eeObj.WriteMem8(mem, 0x04)		
		elseif str == "street:25" then			-- bug fix after Completing "Death From Above"
			local mem = ARTWORK + 0x67			-- Concept art: 323 medium
			eeObj.WriteMem8(mem, 0x02)		
		elseif str == "bath:28" then			-- bug fix after Completing "Cemetary"
			local mem = ARTWORK + 0x57			-- Concept art: 272 medium
			eeObj.WriteMem8(mem, 0x02)		
			local mem = ARTWORK + 0x1c			-- Concept art: 311 hard
			eeObj.WriteMem8(mem, 0x02)		
			local mem = ARTWORK + 0x5f			-- Concept art: 311 hard
			eeObj.WriteMem8(mem, 0x02)		
			local mem = ARTWORK + 0x46			-- Concept art: 96 hard
			eeObj.WriteMem8(mem, 0x02)		
			local mem = ARTWORK + 0x45			-- Concept art: 94, 271 med
			eeObj.WriteMem8(mem, 0x02)		
		elseif str == "fuel:33" then			-- bug fix after Completing "Dive Dive Dive"
			local mem = ARTWORK + 0x5a			-- Concept art: 285 easy (and 0x21)
			eeObj.WriteMem8(mem, 0x02)		
		elseif str == "subs_med:34" or str == "subs_ez:34" or str == "subs_hard:34" then -- bug fix after completing "The Right Way In"
			local mem = ARTWORK + 0x5d			-- Concept art: 289 (and 0x22)
			eeObj.WriteMem8(mem, 0x02)		
			local mem = ARTWORK + 0x62			-- Concept art: 314, 318
			eeObj.WriteMem8(mem, 0x02)		
			local mem = ARTWORK + 0x49			-- Concept art: 105,106 easy (and 0x27)
			eeObj.WriteMem8(mem, 0x02)		
			local mem = ARTWORK + 0x5e			-- Concept art: 290, 374 hard
			eeObj.WriteMem8(mem, 0x02)		
		end
	end
end

local H15 = function() -- rolling_demo_get_ending_movie
	unlockTrophy(SAVIOR_OF_THE_COMMONWEALTH)		-- Complete "In Sopot's Deadly Embrace."
	checkGallery()
	getHitPercentage()
	checkObjectives()
	
	local name = getPlayerName()
	if SaveData.cheats[name] ~= nil then
		if SaveData.cheats[name][CHEAT_LEVELS] ~= nil then
			return -- used a Levels cheat.
		end
	end
	
	-- ENDINGS --
	local player = eeObj.GetGpr(gpr.v1)
	local heroics = eeObj.ReadMem32(player + 0xc70)
	
	if heroics >= 0x2000 then
		unlockTrophy(A_HEROS_REWARD)				-- Get the "I Remember Sopot" ending.
	elseif heroics >= 0xB12 then
		unlockTrophy(A_QUIET_RETIREMENT)			-- Get the "Glory Days" ending.                                                                Complete most bonus objectives.
	elseif heroics >= 0x589 then
		unlockTrophy(PUT_DOWN_LIKE_A_MAD_DOG)		-- Get the "On the Road Again" ending.                                                         Complete very few, if any bonus objectives.
	else
		unlockTrophy(VANISH_INTO_HISTORY)			-- Get the "Judgement Day" ending.                                                             Complete no bonus objectives whatsoever, and kill every ally or civilian you run into. Zero out the Heroism meter.
	end

	local diff = getGameDifficulty()
	if SaveData.difficulty["l11s2.rfl"] == nil then
		SaveData.difficulty["l11s2.rfl"] = 0
	end
	local sd = SaveData.difficulty["l11s2.rfl"] | diff
	SaveData.difficulty["l11s2.rfl"] = sd -- easy=1, med=2, hard=4 (bitfield)
	SaveDataDirty = true
	checkDifficulty()

	if SaveData.cheats[name] ~= nil then
		if SaveData.cheats[name][CHEAT_ANY] ~= nil then
			return -- used Unlock Everything Cheat.
		end
	end
	unlockTrophy(LETS_HAVE_A_GOOD_CLEAN_FIGHT)	-- Clear the campaign without ever activating one of the cheats.
end

local H16 = function() -- entity_fire_ignite
	local entityDamaged = eeObj.GetGpr(gpr.a0)
	if useGrenade == true then
		if useGrenade == true then
			incendiaryTable[entityDamaged] = 1
		end
	end
end

local H17 = function() -- fastcall player_profile_delete
	local profile = eeObj.GetGpr(gpr.v0)
	local name = eeObj.ReadMemStr(profile + 0x10)
	
	if SaveData.cheats[name] ~= nil then
		SaveData.cheats[name][CHEAT_ARTWORK] = nil
		SaveData.cheats[name][CHEAT_LEVELS] = nil
		SaveData.cheats[name] = nil
		emuObj.SaveConfig(0, SaveData)
	end
end

local H18 = function() -- cheat_unlock_everything_entered
	local name = getPlayerName()
	if SaveData.cheats[name] == nil then
		SaveData.cheats[name] = {}
	end
	SaveData.cheats[name][CHEAT_ARTWORK] = true
	emuObj.SaveConfig(0, SaveData)
end

local H19 = function() -- cheat_unlock_levels_entered
	local name = getPlayerName()
	if SaveData.cheats[name] == nil then
		SaveData.cheats[name] = {}
	end
	SaveData.cheats[name][CHEAT_LEVELS] = true
	emuObj.SaveConfig(0, SaveData)
end

local H20 = function() -- extras_cheats_accept_pressed
	local name = getPlayerName()

	if SaveData.cheats[name] == nil then
		SaveData.cheats[name] = {}
	end
	SaveData.cheats[name][CHEAT_ANY] = true
	emuObj.SaveConfig(0, SaveData)
end

local H21 = function() -- level_select_do_frame
	lastLevel = ""	-- reset lastLevel name so H3 won't trigger accidently trophy.
end

-- Hooks -----------------------------------------------------------------

local hook1 = eeObj.AddHook(0x230C70, 0x27bdffb0, H1)		-- entity_death_finally_die
local hook2 = eeObj.AddHook(0x21BE00, 0x27bdfce0, H2)		-- entity_damage
local hook3 = eeObj.AddHook(0x297c4c, 0x0040902d, H3)		-- p_satchel::projectile_hit_callback
local hook4 = eeObj.AddHook(0x12F360, 0x27bdffe0, H4)		-- level_set_filename
local hook5 = eeObj.AddHook(0x292680, 0x27bdfb00, H5)		-- g_railgun::railgun_bullet_collide_helper
local hook6 = eeObj.AddHook(0x1827A0, 0x27bdffe0, H6)		-- vec_dist_approx
local hook7 = eeObj.AddHook(0x29314c, 0x8e430394, H7)		-- g_railgun::railgun_bullet_collide_helper
local hook8 = eeObj.AddHook(0x28D4C0, 0x000218c0, H8)		-- player_stats_increment_head_shots
local hook9 = eeObj.AddHook(0x11A200, 0x27bdff50, H9)		-- entity_blood_spawn_gibs
local hook10 = eeObj.AddHook(0x20F5C4, 0x0040802d, H10)		-- gun::standard_melee_collide_helper
local hook111 = eeObj.AddHook(0x280720, 0x27bdfda0, H11)	-- g_sniper::do_actual_firing
local hook112 = eeObj.AddHook(0x2C73D0, 0x27bdfdb0, H11)	-- g_quill_sniper::do_actual_firing
local hook12 = eeObj.AddHook(0x141f60, 0x0000382d, H12)		-- obj_apply_radius_damage_to_object
local hook13 = eeObj.AddHook(0x12db10, 0x27bdfff0, H13)		-- item_use_grenade
local hook14 = eeObj.AddHook(0x2512C0, 0x0040882d, H14)		-- objective_succeed
local hook15 = eeObj.AddHook(0x1F5454, 0x8f839e20, H15)		-- rolling_demo_get_ending_movie
local hook16 = eeObj.AddHook(0x296580, 0x27bdffc0, H16)		-- entity_fire_ignite
local hook17 = eeObj.AddHook(0x2a2aa4, 0x27a40020, H17)		-- fastcall player_profile_delete
local hook18 = eeObj.AddHook(0x2EB640, 0x27bdfff0, H18)		-- cheat_unlock_everything_entered
local hook19 = eeObj.AddHook(0x2EB810, 0x24030001, H19)		-- cheat_unlock_levels_entered
local hook201 = eeObj.AddHook(0x2EAB14, 0x8F828FC0, H20)	-- extras_cheats_accept_pressed (indiviual items)
local hook202 = eeObj.AddHook(0x2EABD4, 0x8F84A5C0, H20)	-- extras_cheats_accept_pressed (bulk items)
local hook21 = eeObj.AddHook(0x2A5A68, 0x8C420000, H21)		-- level_select_do_frame


function updatesaves()
	SaveDataCounter = SaveDataCounter - 1
	
	if SaveDataCounter <= 0 then
		SaveDataCounter = 300
		if SaveDataDirty ~= false then
			emuObj.SaveConfig(0, SaveData)
			SaveDataDirty = false
		end
	end
end
emuObj.AddVsyncHook(updatesaves)


--[[
Cheats: 0x1ce35fc 1 to 12. (comes from: extras_cheats_accept_pressed - memory at offset: 0x2EAB14)
cheats table: 0x1d99bf0

]]--

--[[
FAQS: http://www.gamefaqs.com/ps2/551510-red-faction-ii/faqs/19927
]]--