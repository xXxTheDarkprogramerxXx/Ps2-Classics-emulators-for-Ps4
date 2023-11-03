-- Lua 5.3
-- Title:   Fantavision - SCES-50002 (EU) v1.00
-- Trophies v1.01
-- Author:  Tim Lindquist

-- Changelog
-- Cleaned up trophy unlocking code.
-- bugfix 8790. 20150729 TGL. 


require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj			= getEEObject()
local emuObj			= getEmuObject()
local trophyObj		= getTrophyObject()

-- Trophy constants
local	trophy_id					=	0
local	trophy_Blast_Off			=	0 -- untested
local	trophy_Make_a_Wish			=	1 -- untested
local	trophy_Chain_Prodigy		=	2 -- untested
local	trophy_Where_Credits_Due	=	3 -- untested
local	trophy_Far_Out				=	4 -- untested
local	trophy_Underdog				=	5 -- untested
local	trophy_Back_2_Back			=	6 -- untested
local	trophy_Thats_Mine_Now		=	7 -- untested
local	trophy_One_Small_Step		=	8 -- untested
local	trophy_Perfection			=	9 -- untested
local	trophy_Another_Dimension	=	10 -- untested
local	trophy_Chain_Onslaught		=	11 -- untested
local	trophy_Monochromatic		=	12 -- untested
local	trophy_To_the_Victor		=	13 -- untested
local	trophy_Top_Earner			=	14 -- untested

-- For tracking number of starmines in a single level
local currentstage = 0
local laststage = 0

-- Pointers (derived from symbols)
local select_effect_ptr				= 0x497e30 -- Effect in replay mode -- bugfix 8790. 20150729 TGL. 

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

function unlockTrophy(trophy_id)
	initsaves()
	if SaveData.t[trophy_id] ~= 1 then
		SaveData.t[trophy_id] = 1
		trophyObj.Unlock(trophy_id)
		emuObj.SaveConfig(0, SaveData)			
	end
end

local H1 =		-- Chain count
	function()
		local chain = eeObj.GetGPR(gpr.s7)
		local count = eeObj.ReadMem32(chain)
		local chainattack = eeObj.ReadMem32(chain-0x668) -- changed for EU
		local mode = eeObj.ReadMem32(chain+0x154) -- unchanged for EU
		if chainattack ~= 1 and mode ~= 1 then -- we're not in chain attack or 2P mode
			if count >= 30 then -- got chain of 30 or higher
				unlockTrophy(trophy_Chain_Prodigy)
			end
		end
		if chainattack == 1 then -- we're in chain attack mode
			if count >= 150 then -- got 150 or higher
				unlockTrophy(trophy_Chain_Onslaught)
			end
		end
	end

local HXUNDER =
	function()
		local chain = eeObj.GetGPR(gpr.s7)
		local p1p2pcount = eeObj.ReadMem32(chain+0x20) -- unchanged for EU
		local handicap = eeObj.ReadMem32(chain-0x148) -- changed for EU
		local gameset = eeObj.ReadMem32(chain-0x14c) -- changed for EU
		local mode = eeObj.ReadMem32(chain+0x154) -- unchanged for EU
		if p1p2pcount >= gameset and handicap == 6 and mode == 1 then -- 1p won a 2p match 
			unlockTrophy(trophy_Underdog)
		end
	end

local H2 =		-- check for stage clear strings
	function()
		local stage = eeObj.GetGPR(gpr.v1)
		local mode = eeObj.ReadMem32(0x498634) -- changed for EU
		local chainattackmode = eeObj.ReadMem32(0x497e78) -- changed for EU
		if stage == 2 and mode ~= 1 and chainattackmode ~= 1 then
			unlockTrophy(trophy_Blast_Off)
		end
		if stage == 4 and mode ~= 1 and chainattackmode ~= 1 then
			unlockTrophy(trophy_Make_a_Wish)
		end
		if stage == 6 and mode ~= 1 and chainattackmode ~= 1 then
			unlockTrophy(trophy_One_Small_Step)
		end
		if stage == 8 and mode ~= 1 and chainattackmode ~= 1 then
			unlockTrophy(trophy_Another_Dimension)
		end
	end

local H3 =		-- check for 100% success
	function()
		local rate = eeObj.GetGPR(gpr.v1)
		if rate == 100 then -- got 100% success
			unlockTrophy(trophy_Perfection)
		end
	end

local H4 =		-- check for Psychadelic effects
	function()
		local select_effect = eeObj.ReadMem32(select_effect_ptr) -- bugfix 8790. 20150729 TGL. 
--		print( string.format("Effect=%x", select_effect) )
		if select_effect >= 6 and select_effect <= 8 then -- Psychadelic
			unlockTrophy(trophy_Far_Out)
		end
	end

local H5 = -- Check for end of credits.
   function()
		unlockTrophy(trophy_Where_Credits_Due)
	end

local H7 =  -- See if they got more than ten shells in a single flash
	function()
		local daisycount = eeObj.GetGPR(gpr.s1)
		local daisycontent = eeObj.GetGPR(gpr.s5)
		local flashed = eeObj.ReadMem32(daisycontent+0x1c) -- unchanged for EU
		local chainattackmode = eeObj.ReadMem32(0x497e78) -- changed for EU
--		print( string.format("Daisy=%x", daisycount) )
--		print( string.format("Flashed=%x", flashed) )
	  	if daisycount == 1 then -- flashed only one set
	  		if flashed >= 10 and flashed <= 256 and chainattackmode ~= 1 then -- Flash a 10+ chain of only one color, outside Chain Attack mode.
				unlockTrophy(trophy_Monochromatic)
			end
		end
	end

local H8 = -- See if we're playing Ultra Play Movie 2
	function()
		local fPtr = eeObj.GetGPR(gpr.a0)
		if fPtr == 7 then -- movie is eultra2.pss
			unlockTrophy(trophy_To_the_Victor)
		end
	end

local HXFLIP = -- 2P reverse during starmine
	function()
		local flipper = eeObj.GetGPR(gpr.s1) -- (0 = p1, 1 = p2)
		local starmine1p = eeObj.ReadMem32(0x2BB0DC) -- changed for EU
		local starmine2p = eeObj.ReadMem32(0x2Bb254) -- changed for EU
		if (flipper == 0 and starmine2p == 1) or (flipper == 1 and starmine1p == 1) then
			unlockTrophy(trophy_Thats_Mine_Now)
		end
	end

local HXSTARMINE = -- Check for two starmines in one stage
	function()
		local mode = eeObj.ReadMem32(eeObj.GetGPR(gpr.t0)+0x1b4) -- unchanged for EU
		currentstage = eeObj.ReadMem32(eeObj.GetGPR(gpr.t0)-0x680) -- changed for EU
		if currentstage == laststage and mode ~= 1 then
			unlockTrophy(trophy_Back_2_Back)
		end
		laststage = currentstage
	end

local HXEXIT = -- Detect stage exit via quit or game over
	function()
		laststage = 0
	end

local HXSCORE = -- Check score
	function()
		local score = eeObj.GetGPR(gpr.v1)
		local chainattackmode = eeObj.ReadMem32(0x497e78) -- changed for EU
		local mode = eeObj.ReadMem32(eeObj.GetGPR(gpr.s7)+0x154) -- unchanged for EU
		if score >= 0x989680 and chainattackmode ~= 1 and mode ~= 1 then
			unlockTrophy(trophy_Top_Earner)
		end				
	end

-- register hooks
Hook1 = eeObj.AddHook(0x155544, 0x0220202d, H1) -- chain count -- updated for EU
Hook2 = eeObj.AddHook(0x103c78, 0x8f838c10, H2) -- check which stage is clear -- updated for EU
Hook3 = eeObj.AddHook(0x115410, 0xaf8099e0, H3) -- check success rate 1p normal stage -- updated for EU
Hook4 = eeObj.AddHook(0x1074cc, 0x30830100, H4) -- Set effect in replay mode -- updated for EU
Hook5 = eeObj.AddHook(0x10dd7c, 0x8fa4000c, H5) -- Watched all of the end credits -- updated for EU
Hook7 = eeObj.AddHook(0x155470, 0x0220202d, H7) -- Daisy count (count flash here too) -- updated for EU
Hook8 = eeObj.AddHook(0x198cb8, 0x27bdff70, H8) -- Movie play -- updated for EU
Hook9 = eeObj.AddHook(0x1555a8, 0x8e430000, HXUNDER) -- P1 score in 2P game -- bug fix 95614 "Underdog" -- updated for EU
Hook10 = eeObj.AddHook(0x14d620, 0x3c0c002c, HXFLIP) -- 2P reverse -- updated for EU
Hook11 = eeObj.AddHook(0x149e50, 0x27bdffe0, HXSTARMINE) -- Starmine mode start -- updated for EU
Hook12 = eeObj.AddHook(0x152030, 0x27bdffd0, HXEXIT) -- detect stage exit -- updated for EU
Hook13 = eeObj.AddHook(0x155104, 0xfc830000, HXSCORE) -- monitor score -- updated for EU

-- Credits

-- Trophy design and development by SCEA ISD SpecOps
-- David Thach			Senior Director
-- George Weising		Executive Producer
-- Tim Lindquist		Senior Technical PM
-- Clay Cowgill			Engineering
-- Nicola Salmoria		Engineering
-- Warren Davis			Engineering
-- David Haywood		Engineering
-- Jenny Murphy			Producer
-- David Alonzo			Assistant Producer
-- Tyler Chan			Associate Producer
-- Karla Quiros			Manager Business Finance & Ops
-- Mayene de la Cruz	Art Production Lead
-- Thomas Hindmarch		Production Coordinator
-- Special thanks to R&D