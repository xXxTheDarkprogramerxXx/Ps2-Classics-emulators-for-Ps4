-- Lua 5.3
-- Title:   Kinetica™ PS2 - SCUS-97132 (USA)
-- Author:  Tim Lindquist
-- Trophies version 1.02
-- Date: 3/1/16

-- Changelog:

-- Bugfix TGL 20150225 H1. Fixes false positive for 350 MPH trophy between levels (changed to read a register instead of a memloc).
-- Bugfix TGL 20150225. Fixed Perfectionist unlock by loading save data bug.
-- Turned off cheat to fix bugs 8157, 8162.
-- Change 20150313 TGL. Added trophy tracking via config file.
-- Bugfix 8723 20150707 TGL. Check for post-race demo mode.
-- Bugfix 8163 TGL 20160224. Fixed Technological Advances unobtainable bug.
-- Bugfix 9420 TGL 20160224. Fixed ShockWave trophy (floating point number handling changed in API since this trophy set was first engineered.)
-- Bugfix 9442. 20160301 TGL. Zero count on finish.


require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj			= getEEObject()
local emuObj			= getEmuObject()
local trophyObj		= getTrophyObject()

-- Trophy constants

local	trophy_id						=	0
local	trophy_Bright_Future			=	0
local	trophy_Racing_Evolved			=	1
local	trophy_Human_Vortex				=	2
local	trophy_Warp_Speed				=	3
local	trophy_Shock_Wave				=	4
local	trophy_Jackpot					=	5
local	trophy_Pole_Position			=	6
local	trophy_Overpowered				=	7
local	trophy_Excavation				=	8
local	trophy_Perfectionist			=	9
local	trophy_Out_of_this_World		=	10
local	trophy_Technological_Advances	=	11

local a = 0
local b = 0
local wait = 0

-- Init saves

local saveData = emuObj.LoadConfig(0)

if not next(saveData) then
	saveData.t  = {}
end

function initsaves()
	local x = 0
	for x = 0, 11 do
		if saveData.t[x] == nil then
			saveData.t[x] = 0
			emuObj.SaveConfig(0, saveData)
		end
	end
	if saveData["Season1"] == nil then
		saveData["Season1"] = 0
		emuObj.SaveConfig(0, saveData)
	end
	if saveData["Season2"] == nil then
		saveData["Season2"] = 0
		emuObj.SaveConfig(0, saveData)
	end
	if saveData["Season3"] == nil then
		saveData["Season3"] = 0
		emuObj.SaveConfig(0, saveData)
	end
	if saveData["Siba"] == nil then 
		saveData["Siba"] = 0 	
		emuObj.SaveConfig(0, saveData)
	end
	if saveData["Greck"] == nil then 
		saveData["Greck"] = 0 
		emuObj.SaveConfig(0, saveData)
	end
	if saveData["Crank"] == nil then 
		saveData["Crank"] = 0 
		emuObj.SaveConfig(0, saveData)
	end
	if saveData["Cyan"] == nil then 
		saveData["Cyan"] = 0 
		emuObj.SaveConfig(0, saveData)
	end
	if saveData["Maddox"] == nil then 
		saveData["Maddox"] = 0 
		emuObj.SaveConfig(0, saveData)
	end
	if saveData["Gore"] == nil then 
		saveData["Gore"] = 0 
		emuObj.SaveConfig(0, saveData)
	end
end

-- Unlock trophy function

function unlockTrophy(trophy_id)
	initsaves()
	if saveData.t[trophy_id] ~= 1 then
		saveData.t[trophy_id] = 1
		trophyObj.Unlock(trophy_id)
		emuObj.SaveConfig(0, saveData)			
	end
end

local TimeStr2Time =
	function (my_time)
		_,_,m,s,cs = string.find(my_time, "(%d+):(%d+).(%d+)")
		if m == nil then m = 0 end
		if s == nil then s = 0 end
		if cs == nil then cs = 0 end
		return m*60+s+cs/100.0
	end

local H1 = -- Over 9,000 MPH (actually 350)
	function()
		local MPH = eeObj.GetFPR(0) -- Bugfix TGL 20150225 H1
		local GameMode = eeObj.ReadMem32(0x001fcd9c)
		local Finished = eeObj.ReadMem32(0x001fcbd8)
		if GameMode ~= 0 and Finished ~= 1 then -- not the demo, not the post-game (bug fix 8723)
			if MPH >= 350.0 then -- going so fast
				unlockTrophy(trophy_Warp_Speed) -- true positive tested 20150225 TGL
			end
		end
	end

local H2 = -- Check movie name
	function()
		local movie = eeObj.ReadMem32(0x00208f98)
		if movie == 0x474e4957 then -- Movie is History
			unlockTrophy(trophy_Racing_Evolved) -- true positive tested 20150225 TGL
		end
	end

local H3 = -- Check high score tables (current race and all races)
	function()
		local Macropolis = eeObj.ReadMemStr(0x001de6dc)
		local LostCity = eeObj.ReadMemStr(0x001de704)
		local Electrica = eeObj.ReadMemStr(0x1DE72C)
		local OrbitalJunction = eeObj.ReadMemStr(0x1DE754)
		local SuicideSlide = eeObj.ReadMemStr(0x1DE77C)
		local NewVega = eeObj.ReadMemStr(0x1DE7A4)
		local ElectricaII = eeObj.ReadMemStr(0x1DE7CC)
		local Cliffhanger = eeObj.ReadMemStr(0x1DE7F4)
		local GabrialsHorn = eeObj.ReadMemStr(0x1DE81C)
		local LostCityII = eeObj.ReadMemStr(0x1DE844)
		local Necropolis = eeObj.ReadMemStr(0x1DE86C)
		local Metroscape = eeObj.ReadMemStr(0x1DE894)
		local EmeraldEve = eeObj.ReadMemStr(0x1DE8BC)
		local ElectricaX = eeObj.ReadMemStr(0x1DE8E4)
		local OrbitalJunctionII	= eeObj.ReadMemStr(0x1DE90C)
		local GameMode = eeObj.ReadMem32(0x001fcd9c)
		local Finished = eeObj.ReadMem32(0x001fcbd8)
		local Position = eeObj.ReadMem32(0x001fcbf8)
		local time1 = eeObj.ReadMemStr(0x00200400)
		local time2 = eeObj.ReadMemStr(0x00200420)

		if (GameMode == 2 and Finished == 1 and Position == 1) then -- finished Single Race in first place.
			unlockTrophy(trophy_Bright_Future) -- true positive tested 20150225 TGL
		end

		if (Finished == 1 and Position == 1 and time1 ~= nil) then
			if TimeStr2Time(time2) - TimeStr2Time(time1) >= 5.0 then -- won by more than 5 seconds
				unlockTrophy(trophy_Overpowered) -- true positive tested 20150225 TGL
			end
		end

		if Macropolis == 'PLAYER 1' or LostCity == 'PLAYER 1' or Electrica == 'PLAYER 1' or OrbitalJunction == 'PLAYER 1' or 
			SuicideSlide == 'PLAYER 1' or NewVega == 'PLAYER 1' or ElectricaII == 'PLAYER 1' or Cliffhanger == 'PLAYER 1' or 
			GabrialsHorn == 'PLAYER 1' or LostCityII == 'PLAYER 1' or Necropolis == 'PLAYER 1' or Metroscape == 'PLAYER 1' or 
			EmeraldEve == 'PLAYER 1' or ElectricaX == 'PLAYER 1' or OrbitalJunctionII == 'PLAYER 1' then -- Player 1 has best time
			unlockTrophy(trophy_Pole_Position)
		end

	end

function checkunlocks()
	if (saveData["Season1"] + saveData["Season2"] + saveData["Season3"] +
		saveData["Siba"] + saveData["Greck"] + saveData["Crank"] +
		saveData["Cyan"] + saveData["Maddox"] + saveData["Gore"]) == 9 then -- all bonuses unlocked
		unlockTrophy(trophy_Technological_Advances)
	end
end

local S1 = -- Season 1 all first place
	function()
		local UnlockFlag = eeObj.GetGPR(gpr.v1)
		local GameMode = eeObj.ReadMem32(0x001fcd9c)
		if UnlockFlag == 1 and GameMode >= 2 then
			unlockTrophy(trophy_Perfectionist)
			saveData["Season1"] = 1
			checkunlocks()
		end
	end

local S2 = -- Season 2 all first place
	function()
		local UnlockFlag = eeObj.GetGPR(gpr.v1)
		local GameMode = eeObj.ReadMem32(0x001fcd9c)
		if UnlockFlag == 1 and GameMode >= 2 then
			unlockTrophy(trophy_Excavation)
			saveData["Season2"] = 1
			checkunlocks()
		end
	end

local S3 = -- Season 3 all first place
	function()
		local UnlockFlag = eeObj.GetGPR(gpr.v1)
		local GameMode = eeObj.ReadMem32(0x001fcd9c)
		if UnlockFlag == 1 and GameMode >= 2 then
			unlockTrophy(trophy_Out_of_this_World)
			saveData["Season3"] = 1
			checkunlocks()
		end
	end

local Siba = -- Siba unlocked.
	function()
		local UnlockFlag = eeObj.GetGPR(gpr.v1)
		local GameMode = eeObj.ReadMem32(0x001fcd9c)
		if UnlockFlag == 1 and GameMode >= 2 then
			saveData["Siba"] = 1
			emuObj.SaveConfig(0, saveData)
			checkunlocks()
		end
	end

local Greck = -- Greck unlocked.
	function()
		local UnlockFlag = eeObj.GetGPR(gpr.v1)
		local GameMode = eeObj.ReadMem32(0x001fcd9c)
		if UnlockFlag == 1 and GameMode >= 2 then
			saveData["Greck"] = 1
			emuObj.SaveConfig(0, saveData)
			checkunlocks()
		end
	end

local Crank = -- Crank unlocked.
	function()
		local UnlockFlag = eeObj.GetGPR(gpr.v1)
		local GameMode = eeObj.ReadMem32(0x001fcd9c)
		if UnlockFlag == 1 and GameMode >= 2 then
			saveData["Crank"] = 1
			emuObj.SaveConfig(0, saveData)
			checkunlocks()
		end
	end

local Cyan = -- Cyan unlocked.
	function()
		local UnlockFlag = eeObj.GetGPR(gpr.v1)
		local GameMode = eeObj.ReadMem32(0x001fcd9c)
		if UnlockFlag == 1 and GameMode >= 2 then
			saveData["Cyan"] = 1
			emuObj.SaveConfig(0, saveData)
			checkunlocks()
		end
	end

local Maddox = -- Maddox unlocked.
	function()
		local UnlockFlag = eeObj.GetGPR(gpr.v1)
		local GameMode = eeObj.ReadMem32(0x001fcd9c)
		if UnlockFlag == 1 and GameMode >= 2 then
			saveData["Maddox"] = 1
			emuObj.SaveConfig(0, saveData)
			checkunlocks()
		end
	end

local Gore = -- Gore unlocked.
	function()
		local UnlockFlag = eeObj.GetGPR(gpr.v1)
		local GameMode = eeObj.ReadMem32(0x001fcd9c)
		if UnlockFlag == 1 and GameMode >= 2 then
			saveData["Gore"] = 1
			emuObj.SaveConfig(0, saveData)
			checkunlocks()
		end
	end

local H5 = -- Check crystal meter
	function()
		local OnMarks = eeObj.ReadMem32(0x001fcd6c)
		local CrystalCount = eeObj.ReadMem32(0x001fcc6c)
		local Finished = eeObj.ReadMem32(0x001fcbd8)
		if OnMarks == 1 then 
			a = 0
			b = 0
		end
		if (b - a) < (CrystalCount + a) then
			if CrystalCount ~= 5 then
				b = CrystalCount + a
				wait = 0
				else if wait ~= 1 then
					a = a + 5
					b = a
					wait = 1
				end
			end
		end
		if Finished == 1 then -- Bugfix 9442. 20160301 TGL. Zero count on finish.
			a = 0
			b = 0
		end
--	print (string.format("crystals = %s", b))
		if b >= 25 and Finished ~= 1 then -- bugfix 8723
			unlockTrophy(trophy_Jackpot)
		end
	end

local H6 = -- Count burst attack victims
	function()
		local Finished = eeObj.ReadMem32(0x001fcbd8)
		local burstSuccess = eeObj.ReadMemFloat(0x01a58f14)
		local burstChar1 = eeObj.ReadMemFloat(0x01a58f1c)
		local burstChar2 = eeObj.ReadMemFloat(0x01a58f20)
		local burstChar3 = eeObj.ReadMemFloat(0x01a58f24)
		local burstChar4 = eeObj.ReadMemFloat(0x01a58f28)
		local burstChar5 = eeObj.ReadMemFloat(0x01a58f2c)
		local burstChar6 = eeObj.ReadMemFloat(0x01a58f30)
		local burstChar7 = eeObj.ReadMemFloat(0x01a58f34)
		local burstChar8 = eeObj.ReadMemFloat(0x01a58f38)
		local burstChar9 = eeObj.ReadMemFloat(0x01a58f3c)
		local burstChar10 = eeObj.ReadMemFloat(0x01a58f40)
		local burstChar11 = eeObj.ReadMemFloat(0x01a58f44)
		if burstSuccess == 1 then -- we hit people
			local hitcount = 0
			if burstChar1 > 0 then hitcount = hitcount + 1 end
			if burstChar2 > 0 then hitcount = hitcount + 1 end
			if burstChar3 > 0 then hitcount = hitcount + 1 end
			if burstChar4 > 0 then hitcount = hitcount + 1 end
			if burstChar5 > 0 then hitcount = hitcount + 1 end
			if burstChar6 > 0 then hitcount = hitcount + 1 end
			if burstChar7 > 0 then hitcount = hitcount + 1 end
			if burstChar8 > 0 then hitcount = hitcount + 1 end
			if burstChar9 > 0 then hitcount = hitcount + 1 end
			if burstChar10 > 0 then hitcount = hitcount + 1 end
			if burstChar11 > 0 then hitcount = hitcount + 1 end
			if hitcount >= 3 and Finished ~= 1 then -- we hit 3 or more people (bug fix 8723)
				unlockTrophy(trophy_Shock_Wave)
			end
		end
	end

local H7 = -- Count combo multiplier
	function()
		local Combos = eeObj.ReadMem32(0x001fcc68)
		if Combos == 8 then -- Combo x 8
			unlockTrophy(trophy_Human_Vortex)
		end
	end

-- Register hooks
local Hook1 = eeObj.AddHook(0x00124e58,0xe78091f0,H1)
local Hook2 = eeObj.AddHook(0x001cd844,0x02482021,H2)
local Hook3 = eeObj.AddHook(0x0012776c,0x30420040,H3)
local Hook5 = eeObj.AddHook(0x00124d84,0x24030005,H5)
local Hook6 = eeObj.AddHook(0x001132d0,0x34048000,H6)
local Hook7 = eeObj.AddHook(0x00124fe8,0x3c040020,H7)

-- Register hooks (for counts)
local Season1Hook = eeObj.AddHook(0x10b598,0x24040001,S1)
local Season2Hook = eeObj.AddHook(0x10b5a8,0x24040002,S2)
local Season3Hook = eeObj.AddHook(0x10b5b8,0x0000202d,S3)
local SibaHook = eeObj.AddHook(0x10b628,0x24040007,Siba)
local GreckHook = eeObj.AddHook(0x10b638,0x24040008,Greck)
local CrankHook = eeObj.AddHook(0x10b648,0x24040009,Crank)
local CyanHook = eeObj.AddHook(0x10b6b8,0x24040010,Cyan)
local MaddoxHook = eeObj.AddHook(0x10b6c8,0x24040011,Maddox)
local GoreHook = eeObj.AddHook(0x10b6d8,0x0000202d,Gore)
