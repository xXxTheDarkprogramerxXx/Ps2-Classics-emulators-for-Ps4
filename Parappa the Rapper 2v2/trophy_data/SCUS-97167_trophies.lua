--Lua 5.3
-- Title:   PaRappa the Rapper 2 - SCUS-97167 (USA) v1.01
-- Author:  Tim Lindquist
-- Trophies version 1.03

-- Changelog

-- Bugfix 20150218 H2 TGL. Found simpler trigger (hat == 4). Moved trigger to H2 to fix unobtainable trophy 11 bug.

-- bugfix 20150218 H4 TGL. Typo. Trophy ID was set to 10 unstead of 8. Fixes unobtainable trophy 8 bug.

-- Added trophy tracking via save data config file.

-- Trophy changes per studio request 20150320.
-- Reordered trophies 9-14.
-- Changed Blue hat to Pink hat. 
-- Added new trigger - unlock all records in record shop.

-- added init for miss variable

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj			= getEEObject()
local emuObj			= getEmuObject()
local trophyObj		= getTrophyObject()

local trophy_Beard_Burger_Masters_burger_building_technique = 0
local trophy_Chop_Chop_Master_Onion = 1
local trophy_Learn_from_the_Guru_Ant_Micro_Masta = 2
local trophy_Inspire_Instructor_Sister_Moosesha = 3
local trophy_Out_Cut_Hairdresser_Octopus = 4
local trophy_Beat_the_Food_Court_Videogame = 5
local trophy_Stop_Colonel_Noodle_from_Noodling_the_world = 6
local trophy_The_Final_Party = 7
local trophy_Kick_Punch_Its_all_in_the_Mind = 8
local trophy_Parappa_and_BJ_Versus_Play = 9
local trophy_The_King_of_Cool = 10
local trophy_The_Pink_Hat = 11
local trophy_The_Yellow_Hat = 12
local trophy_Vinyl_Fantasy_4 = 13
local trophy_Everything_in_Stock = 14

local miss = 0

local SaveData = emuObj.LoadConfig(0)

if not next(SaveData) then
	SaveData.t  = {}
end

function initsaves()
	local x = 0
	for x = 0, 14 do
		if SaveData.t[x] == nil then
			SaveData.t[x] = 0
			emuObj.SaveConfig(0, SaveData)
		end
	end
end

function checkRecords()
	local lv = eeObj.GetGPR(gpr.s0) + 0x58
	local hat = eeObj.ReadMem32(eeObj.GetGPR(gpr.s0))
	local x,y,z = 0,0,0
	for x = 0,60,4 do
		y = eeObj.ReadMem32(lv+x)
		if y >= 4 then z = z + 1 end
	end
	if z + hat >= 20 then
		local trophy_id = trophy_Everything_in_Stock -- true postive tested 20150331
		initsaves()
		if SaveData.t[trophy_id] ~= 1 then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(0, SaveData)			
		end
	else z = 0
	end
end

local H0 = -- rank
	function ()
		local rank = eeObj.GetGPR(gpr.fp)
--		eeObj.SetGPR(gpr.fp,0) -- cheat (disable for release) (0=cool, 3=good)
	end

local H1 = -- Level unlocking
	function()
		local level = eeObj.GetGPR(gpr.a1)
		local hat = eeObj.GetGPR(gpr.a2)
		if level == 0 then
			local trophy_id = trophy_Beard_Burger_Masters_burger_building_technique -- true positive tested 20150227 TGL
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
			end
		end
		if level == 4 then
			local trophy_id = trophy_Chop_Chop_Master_Onion -- true positive tested 20150227 TGL
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
			end
		end
		if level == 8 then
			local trophy_id = trophy_Learn_from_the_Guru_Ant_Micro_Masta -- true positive tested 20150227 TGL
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
			end
		end
		if level == 0xc then
			local trophy_id = trophy_Inspire_Instructor_Sister_Moosesha -- true positive tested 20150227 TGL
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
			end
		end
		if level == 0x10 then
			local trophy_id = trophy_Out_Cut_Hairdresser_Octopus -- true positive tested 20150227 TGL
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
			end
		end
		if level == 0x14 then
			local trophy_id = trophy_Beat_the_Food_Court_Videogame -- true positive tested 20150227 TGL
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
			end
		end
		if level == 0x18 then
			local trophy_id = trophy_Stop_Colonel_Noodle_from_Noodling_the_world -- true positive tested 20150227 TGL
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
			end
		end
		if level == 0x1c then
			local trophy_id = trophy_The_Final_Party -- true positive tested 20150227 TGL
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
			end
		end
	end

local H2 = -- Hat check
	function()
		local hat = eeObj.GetGPR(gpr.v0)
		if hat == 2 then
			local trophy_id = trophy_The_Pink_Hat -- Change 20150320 TGL. untested
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
			end
		end
		if hat == 3 then
			local trophy_id = trophy_The_Yellow_Hat -- true positive tested 20150227 TGL
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
			end
		end
		if hat == 4 then
			local trophy_id = trophy_Vinyl_Fantasy_4 -- Bugfix 20150218 H2 TGL. --true positive tested 20150227 TGL
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
			end
		end
		checkRecords()
	end

local H3 = -- Check for versus mode
	function()
		local mode = eeObj.GetGPR(gpr.s4)
		local round = eeObj.GetGPR(gpr.s1)
		if mode == 1 and round == 0x180 then
			local trophy_id = trophy_Parappa_and_BJ_Versus_Play -- true positive tested 20150227 TGL
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
			end
		end
	end

local H4 = -- Bonus round
	function()
		local score = eeObj.GetGPR(gpr.v1)
		if score == 5 then -- first hit of round
			miss = 0
		end
		if score >= 200 and miss == 0 then
			local trophy_id = trophy_Kick_Punch_Its_all_in_the_Mind -- bugfix 20150218 H4 TGL. -- true positive tested 20150227 TGL
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
			end
		end
	end

local H5 = -- Earn a crown
	function()
		local crown = eeObj.GetGPR(gpr.v0)
		if crown >= 1 then
			local trophy_id = trophy_The_King_of_Cool -- true positive tested 20150227 TGL
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
			end
		end
		checkRecords()
	end

local H6 = -- Check all win flags
	function()
		local v0 = eeObj.GetGPR(gpr.v0)
		local t1 = eeObj.GetGPR(gpr.t1)
		if v0 < t1 then eeObj.WriteMem32(eeObj.GetGPR(gpr.v1),t1) end
		checkRecords()
	end

local m1 = -- Missed tile
	function()
		miss = 1
	end

local m2 = -- Missed tile
	function()
		miss = 1
	end

-- register hooks
Hook0 = eeObj.AddHook(0x0010c290, 0x8e620010, H0) -- rank cheat (disable for release)
Hook1 = eeObj.AddHook(0x126f94, 0x00e52021, H1) -- level unlocks
Hook2 = eeObj.AddHook(0x127064, 0x0082182a, H2) -- hat level up
Hook3 = eeObj.AddHook(0x10b584, 0xaeb40eb4, H3) -- Mode
Hook4 = eeObj.AddHook(0x10e6c8, 0xae63000c, H4) -- Bonus score
Hook5 = eeObj.AddHook(0x127018, 0xac820000, H5) -- Cool crown
Hook6 = eeObj.AddHook(0x126F04, 0x0049102A, H6) -- VS wins

-- register hooks for counting
miss1 = eeObj.AddHook(0x10e63c, 0x24020003, m1) -- missed a tile in bonus
miss2 = eeObj.AddHook(0x10e64c, 0x0220202d, m2) -- missed a tile in bonus

-- Credits

-- Trophy design and development by SCEA ISD SpecOps
-- David Thach		Senior Director
-- George Weising	Executive Producer
-- Tim Lindquist	Senior Technical PM
-- Clay Cowgill		Engineering
-- Nicola Salmoria	Engineering
-- Jenny Murphy		Producer
-- David Alonzo		Assistant Producer
-- Tyler Chan		Associate Producer
-- Karla Quiros		Manager Business Finance & Ops
-- Special thanks to R&D