--Lua 5.3
-- Title:   War of the Monsters™ PS2 - SCUS-97197 (USA) v1.00
-- Trophies version: 1.08
-- Author:  Tim Lindquist
-- Date: Aug 27, 2015

-- Changelog:
-- Bugfix TGL 20150217 H1-1. Fixed an uninitialized variable causing trophy 11 and 15 not to trigger.
-- Bugfix TGL 20150718 H1-2. Moved save file check inside H1 to fix trophy 15 not triggering.
-- Bugfix TGL 20150218 Hook2. Moved hook location and corrected typo for the unlocking trophies.
-- Bugfix TGL 20150217 H2. Moved triggers for Raptros and Zorgon from H1 to H2 so that you don't have to play as them to unlock trophies 4 & 5.
-- Re-wrote Lua to comply with save game load TRC.
-- Bugfix TGL 20150217 H4. Added monster ID check to H4 (to confirm enemy is Goliath Prime). Fixes false
-- positive on "ROBO 47" or "ULTRA-V " in Endurance mode.
-- Change TGL 20150218 Sweet. Moved Sweet Tooth unlock trigger out of H2 since H2 location changed.
-- Change TGL 20150219 H9. Moved trophy 7 condition out of H3 and changed the trigger hook so that it will work on all 2P modes.
-- Bugfix TGL 20150220 H8. Move hook for trophy 16 to comply with save game load TRC.
-- Bugfix TGL 20150304 Hook5. Fixed false positive on taunt trophy during cut scene.
-- Changed all trophy pops to check SaveData first. This should eliminate the possibility of any pops on save game load only.
-- Bugfix 8713. No trophy for AI taunt.
-- Removed inproper "null" from checkunlocks() function

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj			= getEEObject()
local emuObj			= getEmuObject()
local trophyObj		= getTrophyObject()
-- local debugObj		= getDebugObject() -- disable for release

local	trophy_Sticks_and_Stones					=	0
local	trophy_Defeat_Goliath_Prime					=	1
local	trophy_Defeat_Vegon							=	2
local	trophy_Defeat_Cerebulon_Destroyer_of_Worlds	=	3
local	trophy_Zorgulon_Unleashed					=	4
local	trophy_Wrath_of_Raptros						=	5
local	trophy_Your_First_Battle					=	6
local	trophy_It_Takes_2_to_Tangle					=	7
local	trophy_Youre_a_Big_Shot						=	8
local	trophy_CrushORama							=	9
local	trophy_If_You_Can_Dodge_a_Monster			=	10
local	trophy_Youve_got_a_Sweet_Tooth				=	11
local	trophy_Destroyer_of_Worlds					=	12
local	trophy_Monster_Fashion						=	13
local	trophy_One_Monster_to_Rule_Them_All			=	14
local	trophy_Its_a_Monster_Thing					=	15
local	trophy_Battle_Master						=	16
local	trophy_Master_of_MiniGames					=	17

local vsync = 0

local UnlockSweet = -- only for US version because original unlock condition is impossibe.
	function()
		eeObj.WriteMem16(0x2A22A8, 1)  -- Unlock Sweet Tooth (Agamo4)
	end

local DamageHack = -- Disable hook for release
   function()

		eeObj.WriteMem32(0x002B456C, 0x432C0000)  -- Player 1 always has health (except if crushed by rubble)

		local emuObj = emuObj
		local pad = emuObj.GetPad()

		if pad & 0x100 == 0x100 then -- if you press L2
			eeObj.WriteMem32(0x002c56fc, 0x00000000)  -- Take away player 2 health (still requires 1 hit to kill them)
			eeObj.WriteMem32(0x002D688C, 0x00000000)  -- Take away player 3 health (still requires 1 hit to kill them)
			eeObj.WriteMem32(0x002E7A1C, 0x00000000)  -- Take away player 4 health (still requires 1 hit to kill them)
			eeObj.WriteMem32(0x002F8BAC, 0x00000000)  -- Take away Boss 1 health (still requires 1 hit to kill them)
		end
	end

local SaveData = emuObj.LoadConfig(0)

local user_id = 0

if not next(SaveData) then
	SaveData.t  = {}
end

function initsaves()
	local x = 0
	for x = 0, 17 do
		if SaveData.t[x] == nil then
			SaveData.t[x] = 0
			emuObj.SaveConfig(user_id, SaveData)
		end
	end
end

initsaves()

local H1 =		-- Check which character is selected
	function()
		local Mon = eeObj.ReadMem32(0x2b4134)
		local Control = eeObj.ReadMem32(0x2b4138) -- 1 = human, 2 = ai
		local Costume = eeObj.ReadMem32(0x6f7f18) -- 0-3

		local Monster = 0 -- Bugfix TGL 20150217 H1-1

		if Mon == 0xa0 then Monster = 3 end
		if Mon == 0x60 then Monster = 2 end
		if Mon == 0x20 then Monster = 4 end
		if Mon == 0x40 then Monster = 5 end
		if Mon == 0x140 then Monster = 6 end
		if Mon == 0x120 then Monster = 1 end
		if Mon == 0x160 then Monster = 10 end
		if Mon == 0x100 then Monster = 8 end
		if Mon == 0xe0 then Monster = 9 end
		if Mon == 0x80 then Monster = 7 end

		if Monster == 6 and Costume == 3 and Control == 1 then -- SweetTooth played (Agamo4)
		  	local trophy_id = trophy_Youve_got_a_Sweet_Tooth -- Trigger true positive tested 20150217 TGL
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(user_id, SaveData)			
			end
		end
		if Control == 1 then
			local x = 0 -- Bugfix TGL 20150718 H1-2. Moved save file check inside H1 to comply with "no pops on mem card load" TRC.
			local y = 0
			-- Init save data
			for x = 1, 10 do
				if SaveData["Monster" .. tostring(x)] == nil then
					SaveData["Monster" .. tostring(x)] = 0
				end
			end
			-- Save monster played
			if SaveData["Monster" .. tostring(Monster)] == 0 then
				SaveData["Monster" .. tostring(Monster)] = 1
				emuObj.SaveConfig(user_id, SaveData)
			end
			-- Check save data
			for x = 1, 10 do
				if SaveData["Monster" .. tostring(x)] == 1 then
					y = y + 1
				end
			end
			if y == 10 then   -- All monsters played
				local trophy_id = trophy_Its_a_Monster_Thing -- Trigger true positive tested 20150218 TGL
				if SaveData.t[trophy_id] ~= 1 then
					SaveData.t[trophy_id] = 1
					trophyObj.Unlock(trophy_id)
					emuObj.SaveConfig(user_id, SaveData)			
				end
			else
				y = 0
			end
		end
	end

local H2 =		-- Check for unlocks
	function ()
		local unlockPtr = eeObj.GetGPR(gpr.a2)
		local Zorg1Unlocked = 0x2A24E4
		local Zorg2Unlocked = 0x2A2510
		local Zorg3Unlocked = 0x2A253C
		local Zorg4Unlocked = 0x2A2568
		local Rapt1Unlocked = 0x2A1EB4
		local Rapt2Unlocked = 0x2A1EE0
		local Rapt3Unlocked = 0x2A1F0C
		local Rapt4Unlocked = 0x2A1F38
		local Togera3Unlocked = 0x2A1FBC
		local Togera4Unlocked = 0x2A1FE8
		local Preytor3Unlocked = 0x2A206C
		local Preytor4Unlocked = 0x2A2098
		local Congar3Unlocked = 0x2A211C
		local Congar4Unlocked = 0x2A2148
		local Robo3Unlocked = 0x2A21CC
		local Robo4Unlocked = 0x2A21F8
		local Agamo3Unlocked = 0x2A227C
		local Ultra3Unlocked = 0x2A232C
		local Ultra4Unlocked = 0x2A2358
		local Magamo3Unlocked = 0x2A23DC
		local Magamo4Unlocked = 0x2A2408
		local Kinect3Unlocked = 0x2A248C
		local Kinect4Unlocked = 0x2A24B8
		local BigShotUnlocked = 0x2A2670
		local CrushUnlocked = 0x2A269C
		local DodgeUnlocked = 0x2A2644
		local CapitolUnlocked = 0x2A25EC
		local MiniBayUnlocked = 0x2A25C0
		local UFOUnlocked = 0x2A2618
		local VolcanoUnlocked = 0x2A2594
		if unlockPtr == Zorg1Unlocked then -- Zorg unlocked -- TGL 20150217 H2
		  	local trophy_id = trophy_Zorgulon_Unleashed -- Trigger true positive tested 20150218 TGL
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				SaveData["Zorg1Unlocked"] = 1
				emuObj.SaveConfig(user_id, SaveData)
				checkUnlocks()
			end
		end
		if unlockPtr == Zorg2Unlocked then
			SaveData["Zorg2Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Zorg3Unlocked then
			SaveData["Zorg3Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Zorg4Unlocked then
			SaveData["Zorg4Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Rapt1Unlocked then -- Rapt unlocked -- TGL 20150217 H2
			local trophy_id = trophy_Wrath_of_Raptros -- Trigger true positive tested 20150218 TGL
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				SaveData["Rapt1Unlocked"] = 1
				emuObj.SaveConfig(user_id, SaveData)
				checkUnlocks()
			end
		end
		if unlockPtr == Rapt2Unlocked then
			SaveData["Rapt2Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Rapt3Unlocked then
			SaveData["Rapt3Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Rapt4Unlocked then
			SaveData["Rapt4Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == BigShotUnlocked then -- Big Shot unlocked
			local trophy_id = trophy_Youre_a_Big_Shot  -- Trigger true positive tested 20150218 TGL
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				SaveData["BigShotUnlocked"] = 1
				emuObj.SaveConfig(user_id, SaveData)
				checkUnlocks()
			end
		end
		if unlockPtr == CrushUnlocked then -- Crush-o-Rama unlocked
			local trophy_id = trophy_CrushORama  -- Trigger true positive tested 20150218 TGL
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				SaveData["CrushUnlocked"] = 1
				emuObj.SaveConfig(user_id, SaveData)
				checkUnlocks()
			end
		end
		if unlockPtr == DodgeUnlocked then -- Dodgeball unlocked
			local trophy_id = trophy_If_You_Can_Dodge_a_Monster  -- Trigger true positive tested 20150218 TGL
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				SaveData["DodgeUnlocked"] = 1
				emuObj.SaveConfig(user_id, SaveData)
				checkUnlocks()
			end
		end
		if unlockPtr == CapitolUnlocked then
			SaveData["CapitolUnlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == MiniBayUnlocked then
			SaveData["MiniBayUnlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == UFOUnlocked then
			SaveData["UFOUnlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == VolcanoUnlocked then
			SaveData["VolcanoUnlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == BigShotUnlocked then
			SaveData["BigShotUnlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == CrushUnlocked then
			SaveData["CrushUnlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == DodgeUnlocked then
			SaveData["DodgeUnlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Togera3Unlocked then
			SaveData["Togera3Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Togera4Unlocked then
			SaveData["Togera4Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Preytor3Unlocked then
			SaveData["Preytor3Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Preytor4Unlocked then
			SaveData["Preytor4Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Congar3Unlocked then
			SaveData["Congar3Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Congar4Unlocked then
			SaveData["Congar4Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Robo3Unlocked then
			SaveData["Robo3Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Robo4Unlocked then
			SaveData["Robo4Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Agamo3Unlocked then
			SaveData["Agamo3Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Ultra3Unlocked then
			SaveData["Ultra3Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Ultra4Unlocked then
			SaveData["Ultra4Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Magamo3Unlocked then
			SaveData["Magamo3Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Magamo4Unlocked then
			SaveData["Magamo4Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Kinect3Unlocked then
			SaveData["Kinect3Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
		if unlockPtr == Kinect4Unlocked then
			SaveData["Kinect4Unlocked"] = 1
			emuObj.SaveConfig(user_id, SaveData)
			checkUnlocks()
		end
	end

function checkUnlocks()
	if SaveData["CapitolUnlocked"] == 1 and SaveData["MiniBayUnlocked"] == 1 and
		SaveData["UFOUnlocked"] == 1 and SaveData["VolcanoUnlocked"] == 1 then -- All locked levels unlocked
		local trophy_id = trophy_Destroyer_of_Worlds  -- Trigger true positive tested 20150218 TGL
		if SaveData.t[trophy_id] ~= 1 then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(user_id, SaveData)			
		end
	end
	if SaveData["BigShotUnlocked"] == 1 and SaveData["CrushUnlocked"] == 1 and SaveData["DodgeUnlocked"] == 1 then -- All mini games unlocked
		local trophy_id = trophy_Master_of_MiniGames  -- Trigger true positive tested 20150218 TGL
		if SaveData.t[trophy_id] ~= 1 then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(user_id, SaveData)			
		end
	end
	if SaveData["Zorg1Unlocked"] == 1 and SaveData["Zorg2Unlocked"] == 1 and 
		SaveData["Zorg3Unlocked"] == 1 and SaveData["Zorg4Unlocked"] == 1 and
		SaveData["Togera3Unlocked"] == 1 and SaveData["Togera4Unlocked"] == 1 and
		SaveData["Preytor3Unlocked"] == 1 and SaveData["Preytor4Unlocked"] == 1 and
		SaveData["Congar3Unlocked"] == 1 and SaveData["Congar4Unlocked"] == 1 and
		SaveData["Robo3Unlocked"] == 1 and SaveData["Robo4Unlocked"] == 1 and
		SaveData["Agamo3Unlocked"] == 1 and
		SaveData["Ultra3Unlocked"] == 1 and SaveData["Ultra4Unlocked"] == 1 and
		SaveData["Magamo3Unlocked"] == 1 and SaveData["Magamo4Unlocked"] == 1 and
		SaveData["Kinect3Unlocked"] == 1 and SaveData["Kinect4Unlocked"] == 1 and
		SaveData["Rapt1Unlocked"] == 1 and SaveData["Rapt2Unlocked"] == 1 and
		SaveData["Rapt3Unlocked"] == 1 and SaveData["Rapt4Unlocked"] == 1 then -- All skins unlocked
		local trophy_id = trophy_Monster_Fashion -- Trigger true positive tested 20150218 TGL
		if SaveData.t[trophy_id] ~= 1 then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(user_id, SaveData)			
		end
	end
end

local H3 =		-- See who died
	function()
	  local playerNum = eeObj.GetGPR(gpr.v0)
		if playerNum == 0x002c52b0 then -- player is 2
			local p2Ptr = playerNum
			local p2ID = eeObj.ReadMem32(p2Ptr+0x14)
			local p2AI = eeObj.ReadMem32(p2Ptr+0x18)
			local level = eeObj.ReadMemStr(0x417f80)
			if p2ID == 0x20 then -- ID is Congar
				if p2AI == 2 then -- player 2 is AI controlled
					if level == 'central' then -- level is Mid-Town Park.
						local trophy_id = trophy_Your_First_Battle -- Trigger true positive tested 20150220 TGL
						if SaveData.t[trophy_id] ~= 1 then
							SaveData.t[trophy_id] = 1
							trophyObj.Unlock(trophy_id)
							emuObj.SaveConfig(user_id, SaveData)			
						end
					end
				end
			end
		end
	end

local H4 = -- Check for Goliath Prime defeat
	function ()
		local hpPtr = eeObj.GetGPR(gpr.a0)
		local Health = eeObj.GetFPR(0)
		local who = eeObj.ReadMem32(0x2f8774) -- TGL 20150217 H4. 
		if who == 0x1a0 then -- Goliath Prime -- TGL 20150217 H4. 
			if hpPtr == 0x2f8ba8 then
				if Health <= 0 then -- Whupped
					local trophy_id = trophy_Defeat_Goliath_Prime -- Trigger true positive tested 20150217 TGL
					if SaveData.t[trophy_id] ~= 1 then
						SaveData.t[trophy_id] = 1
						trophyObj.Unlock(trophy_id)
						emuObj.SaveConfig(user_id, SaveData)			
					end
				end
			end
		end
	end


local H5 = -- player taunted
	function ()
		local p2AI = eeObj.ReadMem32(eeObj.GetGPR(gpr.s1)+0x18) -- bugfix 8713 20150708 TGL.
		if p2AI == 1 then -- player taunting is human controlled
			local trophy_id = trophy_Sticks_and_Stones -- Trigger true positive tested 20150217 TGL
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(user_id, SaveData)			
			end
		end
	end

local H6 = -- Plant Boss defeat
	function ()
		local trophy_id = trophy_Defeat_Vegon -- Trigger true positive tested 20150220 TGL
		if SaveData.t[trophy_id] ~= 1 then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(user_id, SaveData)			
		end
	end

local H7 = -- Final Boss defeat
	function ()
		local trophy_id = trophy_Defeat_Cerebulon_Destroyer_of_Worlds -- Trigger true positive tested 20150220 TGL
		if SaveData.t[trophy_id] ~= 1 then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(user_id, SaveData)			
		end
		local trophy_id = trophy_One_Monster_to_Rule_Them_All -- Trigger true positive tested 20150220 TGL
		if SaveData.t[trophy_id] ~= 1 then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(user_id, SaveData)			
		end
	end

local H8 = -- Token count
	function ()
		local tokens = eeObj.ReadMem32(0x4178a4)
		if tokens >= 0x30D40 then -- got 200,000+ tokens
			local trophy_id = trophy_Battle_Master -- Trigger true positive tested 20150220 TGL
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(user_id, SaveData)
				emuObj.RemoveVsyncHook(vsync)
			end
		end
	end

-- Change TGL 20150219 H9.
local H9 = -- Check for Player 1 Win string
	function()
		local sPtr = eeObj.GetGPR(gpr.a0)
		local p2Ptr = eeObj.ReadMem32(0x3d3924) -- Bugfix 8701. Player 2 data location changes. This address points to it always.
		local Control = eeObj.ReadMem32(p2Ptr+0x18)
		local str = eeObj.ReadMemStr(sPtr)
		if str == 'PLAYER 1 WINS' or str == 'CONGRATULATIONS PLAYER 1' then
			if Control == 1 then -- Player 2 is human contorlled
				local trophy_id = trophy_It_Takes_2_to_Tangle -- Trigger true positive tested 20150219 TGL
				if SaveData.t[trophy_id] ~= 1 then
					SaveData.t[trophy_id] = 1
					trophyObj.Unlock(trophy_id)
					emuObj.SaveConfig(user_id, SaveData)			
				end
			end
		end
	end

-- register hooks
Hook1 = eeObj.AddHook(0x1a6b64, 0x0000802d, H1) -- Main
Hook2 = eeObj.AddHook(0x169444, 0xacc50000, H2) -- getSettingsData__9MonsterMcR13_SettingsData -- Bugfix TGL 20150218 Hook2. Moved hook to better location to fix unlock bugs.
Hook3 = eeObj.AddHook(0x1529f8, 0xa0400049, H3) -- transitionInto__10StateDeath
Hook4 = eeObj.AddHook(0x16d30c, 0x46010034, H4) -- HealthMeter::drain(float)
Hook5 = eeObj.AddHook(0x15791c, 0x248422b0, H5) -- <StateTaunt::transitionInto(void)> -- Bugfix TGL 20150304 Hook5.
Hook6 = eeObj.AddHook(0x183724, 0x24052264, H6) -- update__9PlantBoss
Hook7 = eeObj.AddHook(0x131f6c, 0x2404226d, H7) -- update__9FinalBoss
Hook8 = eeObj.AddHook(0x1d6830, 0x0220102d, H8) -- TokenManager::grandTotal(Void) -- Bugfix TGL 20150220 H8
Hook9 = eeObj.AddHook(0x23fe60, 0x3c02006e, H9) -- sprintf -- Change TGL 20150219 H9
Sweet = eeObj.AddHook(0x1d9868, 0x27bdff70, UnlockSweet) -- Unlock Sweet Tooth (Agamo 4). -- Change TGL 20150218 Sweet. 

if SaveData.t[trophy_Battle_Master] ~= 1 then
	vsync = emuObj.AddVsyncHook(H8)
end

--DamageHackHook  = eeObj.AddHook(0x0016d2d8, 0x8c820014, DamageHack) -- drain__11HealthMeterf (disable for release)