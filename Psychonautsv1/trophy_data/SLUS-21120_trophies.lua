-- Lua 5.3
-- Title:   Psychonauts PS2 - SLUS-21120 (USA)
-- Author:  Ernesto Corvi, Adam McInnis

-- Changelog:
-- v1.1: Fixed Victory Tour trophy bug
-- v1.4: Fixed A Victory For Good Taste trophy bug (BUG 9394), Fixed Camp Gossip trophy bug (BUG 9403)
-- v1.5: Fixed Thanks For All The Snails trophy bug (BUG 9412, 9418)
-- v1.6: Fixed No More Secrets trophy bug (BUG 9433)

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])
require( "ee-cpr0-alias" ) -- for EE CPR

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()
local trophyObj	= getTrophyObject()

local BRAINIAC                        = 0  -- Unlock all trophies. (automatic)
local YOUR_LAST_CHANCE_TO_CHICKEN_OUT = 1  -- Complete Basic Braining. (done)
local JUNIOR_PSI_CADET                = 2  -- Achieve Rank 20. (done)
local REGULAR_PSI_CADET               = 3  -- Achieve Rank 40. (done)
local ADVANCED_PSI_CADET              = 4  -- Achieve Rank 60. (done)
local SUPER_PSI_CADET                 = 5  -- Achieve Rank 80. (done)
local MATH_IS_HARD                    = 6  -- Achieve Rank 101. (done)
local A_VICTORY_FOR_GOOD_TASTE        = 7  -- Complete Sasha's Shooting Gallery. (done)
local ROLLING_ROCK_STAR               = 8  -- Complete Milla's Dance Party. (done)
local FOR_INSURANCE_REASONS           = 9  -- Complete Lungfishopolis. (done)
local TIME_TO_DELIVER_THE_MILK        = 10 -- Complete The Milkman Conspiracy. (done)
local YOURE_ALL_SO_KIND               = 11 -- Complete Gloria's Theater. (done)
local THANKS_FOR_ALL_THE_SNAILS       = 12 -- Complete Waterloo World. (done)
local I_ALWAYS_LOVED_YOU_MORE         = 13 -- Complete Black Velvetopia. (done)
local HEIGHT_OF_INSANITY              = 14 -- Complete The Asylum. (done)
local I_THOUGHT_THAT_WAS_UNBEATABLE   = 15 -- Complete Meat Circus. (done)
local THEY_SHOULD_TOTALLY_SELL_THOSE  = 16 -- Earn all Merit Badges. (done)
local IM_GONNA_LIVE_FOREVER           = 17 -- Find all Golden Helmets. (done)
local THEY_CALL_ME_THE_HUNTER         = 18 -- Redeem all 16 Scavenger Hunt Items. (done)
local NO_SOLID_FOOD_FOR_SIX_HOURS     = 19 -- Re-brain the Children. (done)
local NO_MORE_SECRETS                 = 20 -- Crack all Vaults. (done)
local HAPPY_BAGS                      = 21 -- Sort all Emotional Baggage. (done)
local FIGGY_PIGGY                     = 22 -- Gather all Figments. (done)
local HOLIDAY_DINNER                  = 23 -- Cook and consume two different kinds of roast in one sitting. (done)
local CHRISTMAS_SHOPPING              = 24 -- Buy an item from the Camp Store on Christmas. (done)
local MADE_MAN                        = 25 -- Witness Maloof's transformation. (done)
local IM_SURE_SHES_OVER_IT            = 26 -- Uncover Milla's Secret. (done)
local WOLPAW_SAYS_THANKS              = 27 -- Hear Vernon's Ghost Story. (done)
local MAYBE_ITS_THE_HAIR              = 28 -- Spy on Bobby's love life. (done)
local LOOK_AT_THOSE_PANSIES           = 29 -- Find Edgar's Secret Garden. (done)
local I_THINK_THEY_WERE_IMPRESSED     = 30 -- Introduce all Camp Kids to Mr. Pokeylope. (done)
local VICTORY_TOUR                    = 31 -- Revisit all brains after completion. (done)
local CAMP_GOSSIP                     = 32 -- Read many bulletin board messages. (done)
local MMM_BACON                       = 33 -- Use the bacon. A lot. (done)
local A_SLICE_OF_HISTORY              = 34 -- Discover the secret history of Whispering Rock. (done)
local STUMP_SPEECH                    = 35 -- Give the Coach's speech on the stump. (done)
local SELF_AWARE                      = 36 -- See yourself through the eyes of many others. (done)
local I_LOVE_PUNCHING                 = 37 -- Complete the Punchy Target mini-game. (done)

local NUM_BACON_USES = 5			-- number of times to use the bacon before triggering the MMM_BACON trophy
local NUM_CLAIRVOYANCE_SEEN = 15	-- number of times you use clairvoyance to see yourself before triggering the SELF_AWARE trophy

local gGameApp = 0x3699F0

local POKEYLOPE_COMPLETE = 0xffff
local POKEYLOPE_IDS = { "CAIT004CP", -- Melvin "Chops" Sweetwind - CAIT004CP
					    "CAIS000JT", -- JT Hoofburger - CAIS000JT
                        "CAIL002KI", -- Kirry Bubai - CAIL002KI
                        "CAIN002FA", -- Frankie Athens - CAIN002FA
                        "CAIU001CH", -- Chloe Barge - CAIU001CH
                        "CAIV004BZ", -- Bobby Zilch - CAIV004BZ
                        "CAIJ002DO", -- Dogen Boole - CAIJ002DO
                        "CAII002EL", -- Elka Doom - CAII002EL
                        "CAIH003NI", -- Nils Lutefisk - CAIH003NI
                        "CAIX001QU", -- Quentin Hedgemouse - CAIX001QU
                        "CAIW001PH", -- Phoebe Love - CAIW001PH
                        "CAIG002VE", -- Vernon Tripe - CAIG002VE
						"CAIK003EF", -- Elton Fir & Milka Fage - CAIK003EF
						"CAIR006CF", -- Crystal Flowers Snagrash - CAIR006CF
						"CAIQ010CM", -- Clem Foote - CAIQ010CM
						"CAIP003MF"} -- Maloof Canola & Mikhail Bulgakov - CAIP003MF
						
local MENTAL_LEVELS = { "BB", "BV", "LO", "MC", "MI", "MM", "NI", "SA", "TH", "WW" }
local REVISIT_LEVELS = { "BB", "BV", "LO", "MI", "MM", "NI", "SA", "TH", "WW" }
local REVISIT_COMPLETE = 0x1FF
						
local SaveData = emuObj.LoadConfig(0)

if not next(SaveData) then
	SaveData.t  = {}
	SaveData.baconUses = 0
	SaveData.pokeylope = 0
	SaveData.dinner = {}
	SaveData.revisit = 0
	SaveData.clairvoyance = {}
end

function initsaves()
	local x = 0
	local needsSave = false
	for x = 0, 37 do
		if SaveData.t[x] == nil then
			SaveData.t[x] = 0
			needsSave = true
		end
	end
	
	if SaveData.baconUses == nil then
		SaveData.baconUses = 0
		needsSave = true
	end
	
	if SaveData.pokeylope == nil then
		SaveData.pokeylope = 0
		needsSave = true
	end	
	
	if SaveData.dinner == nil then
		SaveData.dinner = {}
		needsSave = true
	end
	
	if SaveData.revisit == nil then
		SaveData.revisit = 0
		needsSave = true
	end
	
	if SaveData.clairvoyance == nil then
		SaveData.clairvoyance = {}
		needsSave = true
	end
	
	if (needsSave == true) then
		emuObj.SaveConfig(0, SaveData)
	end
end

initsaves()

function unlockTrophy(trophy_id)
	print(string.format("unlocking %d (%d)", trophy_id, SaveData.t[trophy_id]))
	if SaveData.t[trophy_id] ~= 1 then
		SaveData.t[trophy_id] = 1
		trophyObj.Unlock(trophy_id)
		emuObj.SaveConfig(0, SaveData)
	end
end

local function isChristmas()
	local values = os.date("*t")
	
	if values["day"] == 25 and values["month"] == 12 then
		return true
	end
	
	return false
end

local function getLevelName()
	local gameApp = eeObj.ReadMem32(gGameApp)
	return eeObj.ReadMemStr(gameApp+0x162a) -- from Lua_GetCurrentLevelName
end

local function getLUABase()
	local gameApp = eeObj.ReadMem32(gGameApp)
	local scriptvm = gameApp+0x17c0 -- from EEntity::GetValue
	return eeObj.ReadMem32(scriptvm+4) -- from EScriptVM::Initialise
end

local function locateTable(name)
	local base = getLUABase()
	local start = eeObj.ReadMem32(base+0x4c) -- from luaV_getglobal
	for part in string.gmatch(name, "%S+") do
		local node = eeObj.ReadMem32(start)
		local size = eeObj.ReadMem32(start+8)
		local count = 0
		local found = false
		
		while count < size do
			local keytype = eeObj.ReadMem8(node+8)
			local valuetype = eeObj.ReadMem8(node+9)
			
			if valuetype == 4 and keytype == 3 then
				local key = eeObj.ReadMem32(node)
				local keyvalue = eeObj.ReadMemStr(key+0x10)
				
				if keyvalue == part then
					local value = eeObj.ReadMem32(node+4)
					start = value
					found = true
					break
				end
			end
			count = count + 1
			node = node + 12
		end
		
		if found == false then
			return nil
		end
	end
	
	return start
end

local function readTable(hash)
	local values = {}
	local node = eeObj.ReadMem32(hash)
	local size = eeObj.ReadMem32(hash+8)
	local count = 0
	
	while count < size do
		local keytype = eeObj.ReadMem8(node+8)
		
		if keytype == 3 then
			local key = eeObj.ReadMem32(node)
			local keyvalue = eeObj.ReadMemStr(key+0x10)
			local value = eeObj.ReadMem32(node+4)
			local valuetype = eeObj.ReadMem8(node+9)
			
			if valuetype == 2 then
				local valueval = eeObj.ReadMemFloat(node+4)
				values[keyvalue] = valueval
				-- print(string.format("%s = %f", keyvalue, valueval))
			elseif valuetype == 3 then
				local valueval = eeObj.ReadMemStr(value+0x10)
				values[keyvalue] = valueval
				-- print(string.format("%s = %s", keyvalue, valueval))
			elseif valuetype == 4 then
				values[keyvalue] = "<table>"
			elseif valuetype == 5 then
				values[keyvalue] = "<function>"
			end
		end
		count = count + 1
		node = node + 12
	end
	
	return values
end

local function getStat(name)
	local stats = locateTable("Global player stats")
	if stats ~= nil then
		local values = readTable(stats)
		if values[name] ~= nil then
			return values[name]
		end
	end
	
	return 0.0
end

local function getGlobal(name)
	local stats = locateTable("Global saved Global")
	if stats ~= nil then
		local values = readTable(stats)
		if values[name] ~= nil then
			return values[name]
		end
	end
	
	return 0.0
end

local function allMentalCollected(varName)
	local x = 0
	for x = 1, #MENTAL_LEVELS do
		local level = locateTable("Global saved " .. MENTAL_LEVELS[x])
		if level == nil then
			return false
		end
		local values = readTable(level)
		if values[varName] == nil then
			return false
		end
		
		if values[varName] ~= 1.0 then
			return false
		end
	end
	
	return true
end

local H1 = function() -- EUserInterfaceManager::AddCompletedGoalDisplay
	local goal = eeObj.ReadMemStr(eeObj.GetGpr(gpr.a1))
--	print(string.format("completed goal: %s", goal))
	
	if goal == "/GLZD118TO/" then						-- Complete Basic Braining.
		unlockTrophy(YOUR_LAST_CHANCE_TO_CHICKEN_OUT)
	elseif goal == "/GLZD407TO/" then					-- Complete Sasha's Shooting Gallery.
		unlockTrophy(A_VICTORY_FOR_GOOD_TASTE)
	elseif goal == "/GLZD414TO/" then					-- Complete Lungfishopolis.
		unlockTrophy(FOR_INSURANCE_REASONS)
	elseif goal == "/GLZD579TO/" then					-- Complete The Milkman Conspiracy.
		unlockTrophy(TIME_TO_DELIVER_THE_MILK)
	elseif goal == "/GLZD205TO/" then					-- Complete Gloria's Theater.
		unlockTrophy(YOURE_ALL_SO_KIND)
	elseif goal == "/GLZD232TO/" then					-- Complete Black Velvetopia.
		unlockTrophy(I_ALWAYS_LOVED_YOU_MORE)
	elseif goal == "/GLZD217TO/" then					-- Complete Waterloo World.
		unlockTrophy(THANKS_FOR_ALL_THE_SNAILS)
	elseif goal == "/GLZD241TO/" then					-- Complete The Asylum.
		unlockTrophy(HEIGHT_OF_INSANITY)
	elseif goal == "/GLZD585TO/" then					-- Scavenger Hunt
		unlockTrophy(THEY_CALL_ME_THE_HUNTER)
	end
end

local H2 = function() -- EUserInterfaceManager::AddGoalDisplay
	local goal = eeObj.ReadMemStr(eeObj.GetGpr(gpr.a1))
--	print(string.format("added goal: %s", goal))
	
	if goal == "/GLZD410TO/" then
		unlockTrophy(ROLLING_ROCK_STAR)
	end
end

local H3 = function() -- Lua_HUDRankup
	local rank = eeObj.GetGpr(gpr.a2)
--	print(string.format("new rank: %d", rank))
	local ranks = { 20, 40, 60, 80, 101 }
	local trophies = { JUNIOR_PSI_CADET, REGULAR_PSI_CADET, ADVANCED_PSI_CADET, SUPER_PSI_CADET, MATH_IS_HARD }
	local x = 0
	
	for x = 1, #ranks do
		if rank >= ranks[x] then
			unlockTrophy(trophies[x])
		end
	end
end

local H4 = function() -- Lua_SetCollectedItemText
	local item = eeObj.ReadMemStr(eeObj.GetGpr(gpr.v0))
	local level = getLevelName()
--	print(string.format("collected item: %s on level: %s", item, level))
	
	if isChristmas() == true then
		-- /GLZB051TO/ = Mental Magnet (Store Item) *
		-- /GLZB016TO/ = Dowsing Rod (Store Item)
		-- /GLZB015TO/ = Cobweb Duster (Store Item)
		-- /GLZB011TO/ = PSI Core (Store Item) *
		-- /GLZB017TO/ = PSI Energy Colorizer (Store Item)
		-- /GLZB013TO/ = Dream Fluff (Store Item)
	
		local storeItems = {}
		storeItems["/GLZB051TO/"] = true
		storeItems["/GLZB016TO/"] = true
		storeItems["/GLZB015TO/"] = true
		storeItems["/GLZB011TO/"] = true
		storeItems["/GLZB017TO/"] = true
		storeItems["/GLZB013TO/"] = true
		
		if storeItems[item] ~= nil then
			unlockTrophy(CHRISTMAS_SHOPPING)
		end
	end
	
	-- Holiday Dinner IDS:  /CAZB008TO/ & /CAZB001TO/
	local holidayIDs = {}
	holidayIDs["/CAZB008TO/"] = 1
	holidayIDs["/CAZB001TO/"] = 2
	if holidayIDs[item] ~= nil then
		if SaveData.dinner[level] == nil then
			SaveData.dinner[level] = 0
		end
		
		SaveData.dinner[level] = SaveData.dinner[level] | holidayIDs[item]
		emuObj.SaveConfig(0, SaveData)
		
		if SaveData.dinner[level] == 3 then
			unlockTrophy(HOLIDAY_DINNER)
		end
	end
	if item == "/GLZB008TO/" then -- Golden Helmet
		local lives = getStat("maxLives")
		if lives >= 11.0 then
			unlockTrophy(IM_GONNA_LIVE_FOREVER)
		end
	end
end

local H5 = function() -- EBubbleControlHandler::AllowPower
	local powers = eeObj.GetGpr(gpr.t7)
	local curPower = eeObj.GetGpr(gpr.a1)
	local curTrainer = eeObj.GetGpr(gpr.a2)
	
	if curTrainer == 0 then
		local x = 0
		local allPowers = true
	
--		print(string.format("power: %d - trainer: %d", curPower, curTrainer))
	
		for x = 0, 7 do
			if x ~= curPower then
				if eeObj.ReadMem8(powers+x) ~= 1 then
					allPowers = false
					break
				end
			end
		end
		
		if allPowers then
			unlockTrophy(THEY_SHOULD_TOTALLY_SELL_THOSE)
		end
	end
end

local H6 = function() -- ESlideshowControlHandler::InitSlides
	local name = eeObj.ReadMemStr(eeObj.GetGpr(gpr.a3))
	
	if name == "/GLZH004TO/" then
		unlockTrophy(IM_SURE_SHES_OVER_IT)
	elseif name == "/GLZH008TO/" then
		unlockTrophy(LOOK_AT_THOSE_PANSIES)
	end
	
--	print(string.format("Memories: %s", name))
end

local H7 = function() -- Lua_DisplayText
	local level = getLevelName()
	local msg = eeObj.ReadMemStr(eeObj.GetGpr(gpr.s5))
	
--	print(string.format("Level: %s, Msg: %s", level, msg))
	
	if level == "BBA2" and msg == "50 /BBZE018TO/" then
		unlockTrophy(I_LOVE_PUNCHING)
	end
	
	msg = string.sub(msg, 1, 11)
	
	if msg == "/GLZD438TO/" or msg == "/GLZE008TO/" then -- All baggage sorted
		if allMentalCollected("bEmoBagsComplete") == true then
			unlockTrophy(HAPPY_BAGS)
		end
	elseif msg == "/GLZD439TO/" then -- All Figments collected
		if allMentalCollected("bFigmentsComplete") == true then
			unlockTrophy(FIGGY_PIGGY)
		end
	end
end

local H8 = function() -- Lua_PlayVideo
	local video = eeObj.GetGpr(gpr.v0)
	if video ~= 0 then
		local name = string.upper(eeObj.ReadMemStr(video))
		
		if name == "CUTSCENES/PRERENDERED/MCVI.XMV" then
			unlockTrophy(I_THOUGHT_THAT_WAS_UNBEATABLE)
		end
	end
end

local H9 = function() -- Lua_DialogChoiceBubble
	local level = getLevelName()
	if level == "CAJA" then
		local brainsWired = getStat("totalBrainsRedeemed") -- Redeem brains
		if brainsWired >= 19.0 then
			unlockTrophy(NO_SOLID_FOOD_FOR_SIX_HOURS)
		end
	end
end

local H10 = function() -- Lua_PlaySoundWithBabble
	local sound = eeObj.GetGpr(gpr.s4)

	if sound ~= 0 then
		local name = string.upper(eeObj.ReadMemStr(sound))
		
		if name == "CAJO013RA" then 			-- Whispering Rock history
			unlockTrophy(A_SLICE_OF_HISTORY)
		elseif name == "CAJB044RA" or name == "CAJB023RA" then 		-- Okay, that does it. I've been looking for... / Greetings Pan Galatic Travelers...
			unlockTrophy(CAMP_GOSSIP)
		elseif name == "CAJN014RA" then			-- Stump speech
			unlockTrophy(STUMP_SPEECH)
		elseif name == "CABI023RA" then			-- Witness Maloof's transformation.
			unlockTrophy(MADE_MAN)
		elseif name == "CABG010NI" then			-- Spy on Bobby's love life.
			unlockTrophy(MAYBE_ITS_THE_HAIR)
		elseif name == "CAAO028VE" then			-- Hear Vernon's Ghost Story.
			unlockTrophy(WOLPAW_SAYS_THANKS)
		end
				
		local x = 0
		for x = 1, #POKEYLOPE_IDS do
			if name == POKEYLOPE_IDS[x] then
				local bit = 1 << (x - 1)
				SaveData.pokeylope = SaveData.pokeylope | bit
				emuObj.SaveConfig(0, SaveData)
		
				if SaveData.pokeylope == POKEYLOPE_COMPLETE then
					unlockTrophy(I_THINK_THEY_WERE_IMPRESSED)
				end
			end
		end
		
--		print(string.format("Sound: %s", name))
	end
end

local H11 = function() -- Lua_AttachInventoryEntityToPlayer
	local entity = eeObj.GetGpr(gpr.v0)
	local nameptr = eeObj.ReadMem32(entity+0x24)
	local name = string.upper(eeObj.ReadMemStr(nameptr))
	
	if name == "BACON" then
		SaveData.baconUses = SaveData.baconUses + 1
		emuObj.SaveConfig(0, SaveData)
		
		if SaveData.baconUses >= NUM_BACON_USES then
			unlockTrophy(MMM_BACON)
		end
	end

--	print(string.format("Selected item: %s", name))
end

local H12 = function() -- Lua_LoadNewLevel
	local level = eeObj.GetGpr(gpr.v0)
	if level ~= 0 then
		local levelname = string.upper(eeObj.ReadMemStr(level))
		local primaryLevel = string.sub(levelname, 1, 2)
		local str = "b" .. primaryLevel .. "Completed"
		local levelStat = getGlobal(str)

		--print(string.format("Entering primary level: %s", primaryLevel))
		--print(string.format("Stat: %s, value: %f", str, levelStat))
		
		if levelStat >= 1.0 then
			for x = 1, #REVISIT_LEVELS do
				if primaryLevel == REVISIT_LEVELS[x] then
					local bit = 1 << (x - 1)
					SaveData.revisit = SaveData.revisit | bit
					emuObj.SaveConfig(0, SaveData)
		
					if SaveData.revisit == REVISIT_COMPLETE then
						unlockTrophy(VICTORY_TOUR)
					end
					break
				end
			end
		end
	end
end

local H13 = function() -- Lua_ExitClairvoyanceCloud
	local target = locateTable("Global player lastClairTarget")
	if target ~= nil then
		local values = readTable(target)
		local name = values["Name"]
		
		if name ~= nil then
			local count = 0
			
			for _ in pairs(SaveData.clairvoyance) do
				count = count + 1
			end
			
			if count <= NUM_CLAIRVOYANCE_SEEN then
				if SaveData.clairvoyance[name] == nil then
					SaveData.clairvoyance[name] = true
					emuObj.SaveConfig(0, SaveData)
					count = count + 1
					if count >= NUM_CLAIRVOYANCE_SEEN then
						unlockTrophy(SELF_AWARE)
					end
				end
			end
		end
	end
end

local H14 = function() -- Lua_HideHUD
	if allMentalCollected("bVaultsComplete") == true then
		unlockTrophy(NO_MORE_SECRETS)
	end
end

-- register hooks
local hook1 = eeObj.AddHook(0x24a340, 0x27bdfff0, H1) -- EUserInterfaceManager::AddCompletedGoalDisplay
local hook2 = eeObj.AddHook(0x24a328, 0x27bdfff0, H2) -- EUserInterfaceManager::AddGoalDisplay
local hook3 = eeObj.AddHook(0x2b0258, 0x8de40a14, H3) -- Lua_HUDRankup
local hook4 = eeObj.AddHook(0x2aaa68, 0x0040902d, H4) -- Lua_SetCollectedItemText
local hook5 = eeObj.AddHook(0x1e39e4, 0x278fbf60, H5) -- EBubbleControlHandler::AllowPower
local hook6 = eeObj.AddHook(0x23c4e0, 0x27bdfee0, H6) -- ESlideshowControlHandler::InitSlides
local hook7 = eeObj.AddHook(0x2ab894, 0x8def99f0, H7) -- Lua_DisplayText
local hook8 = eeObj.AddHook(0x29c0c0, 0x2a0f0002, H8) -- Lua_PlayVideo
local hook9 = eeObj.AddHook(0x2ae620, 0x27bdfec0, H9) -- Lua_DialogChoiceBubble
local hook10 = eeObj.AddHook(0x2a0880, 0x8faf0208, H10) -- Lua_PlaySoundWithBabble
local hook11 = eeObj.AddHook(0x2b5474, 0x2a2f0002, H11) -- Lua_AttachInventoryEntityToPlayer
local hook12 = eeObj.AddHook(0x2bd31c, 0x0040202d, H12) -- Lua_LoadNewLevel
local hook13 = eeObj.AddHook(0x2c5170, 0x27bdfff0, H13) -- Lua_ExitClairvoyanceCloud
local hook14 = eeObj.AddHook(0x2ac480, 0x27bdffd0, H14) -- Lua_HideHUD

-- disable cheats
eeInsnReplace(0x20c910, 0x14400027, 0x10000027) -- All Powers
eeInsnReplace(0x20c9c0, 0x1440000e, 0x1000000e) -- Million Lives
eeInsnReplace(0x20cb14, 0x1440000a, 0x1000000a) -- Max Rank

-- eeInsnReplace(0x20ccc4, 0x0c083228, 0) -- All cheats
