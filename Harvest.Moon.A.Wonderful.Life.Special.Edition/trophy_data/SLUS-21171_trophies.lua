-- Lua 5.3
-- Title:   Harvest Moon: A Wonderful Life - Special Edition - SLUS-21171 (US)
-- Version: 1.0.0
-- Date:    Nov 28th, 2016
-- Author(s):  Warren Davis, warren_davis@playstation.sony.com for SCEA and Tim Lindquist
-- Contains fixes for bugs...  10239, 10271


require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj			= getEEObject()
local emuObj		= getEmuObject()
local trophyObj		= getTrophyObject()

local MAX_TROPHY = 30

local TROPHY_A_WONDERFUL_LIFE 		= 00
local TROPHY_PLENTY_OF_PLANTS		= 01
local TROPHY_CHUG_CHUG_CHUG 		= 02
local TROPHY_GAME_TIME 				= 03
local TROPHY_HOOK_LINE_AND_SINKER	= 04
local TROPHY_MOO_BORN				= 05
local TROPHY_FRESH_MILK				= 06
local TROPHY_HAPPY_HEIFER			= 07
local TROPHY_QUACK_QUACK			= 08
local TROPHY_GOLDEN_GROOMER			= 09
local TROPHY_HATCHED				= 10
local TROPHY_SURE_BEATS_WALKING		= 11
local TROPHY_MAIN_COURSE	 		= 12
local TROPHY_THIRD_GENERATION		= 13
local TROPHY_CONSTRUCTION_WORKER	= 14
local TROPHY_DOG_LOVER				= 15
local TROPHY_RIGHT_TOOL_FOR_THE_JOB	= 16
local TROPHY_RECORD_KEEPING			= 17
local TROPHY_TIDY_TOMBSTONE			= 18
local TROPHY_DILIGENT_DIGGER		= 19
local TROPHY_SERIOUS_CELEBRATOR		= 20
local TROPHY_A_HARD_BARGAIN			= 21
local TROPHY_VETERINARIAN	 		= 22
local TROPHY_LIGHTS_IN_THE_SKY		= 23
local TROPHY_RISE_AND_SHINE			= 24
local TROPHY_AWL_CHAPTER_1			= 25
local TROPHY_AWL_CHAPTER_2			= 26
local TROPHY_AWL_CHAPTER_3			= 27
local TROPHY_AWL_CHAPTER_4			= 28
local TROPHY_AWL_CHAPTER_5			= 29
local TROPHY_AWL_CHAPTER_6			= 30

local pGameData = 0
local GameDataOffset = -0x53cc			-- offset from gp
local pRuntimeDataOffset = -0x5404		-- offset from gp
local RecordPlayerOffset = 0x14070
local EventFlagOffset = 0xD8
local BoardGamePlyrScoreOffset = 0x715
local BoardGameOppScoreOffset =	0x714
local StoreShelfOffset = 0x1ef0
local RucksackOffset = 0x44
local DogLoveOffset = 0x68
local BuildingTableOffset = 0x15be0
local TabletOffset = 0x11a
local VanPeddlingOffset = 0x56b
local GameOverOffset = 0x6e4

local mealType = 0x2929				-- initialize to dummy value
local waitForGoatPurchase = 0
local waitForRecordPurchase = 0
local waitForNiceScene = 0
local milkType = -1				-- item number of milk. S-grade = a, e, 12 or 16. Mother's milk = 6
								-- normal milk is 7 thru a (grades C, B, A and S)
								-- marble milk is b thru e (grades C, B, A and S)
								-- star milk is f thru 12 (grades C, B, A and S)
								-- brown milk is 13 thru 16 (grades C, B, A and S)

--print "_NOTE: Starting HM: WONDERFUL LIFE SE US"
	
local SaveData = emuObj.LoadConfig(0)


if SaveData.t == nil then
	SaveData.t  = {}
end


function initsaves()
	local doSave = false
	
	local x = 0
	for x = 0, MAX_TROPHY do
		if SaveData.t[x] == nil then
			SaveData.t[x] = 0
			doSave = true
		end
	end

	if  SaveData["FestivalsVisited"] == nil then
		SaveData["FestivalsVisited"] = 0
		doSave = true
	end
	
	if doSave == true then
		emuObj.SaveConfig(0, SaveData)
		--print "_NOTE: ***** initsaves: Saving Config *****"
	end


end
	
--[[	award_trophy				Trophy 00

	call to award any trophy.  When all trophies have been awarded, it awards trophy 00
	
--]]
function award_trophy(trophy_id)
	initsaves()
	if SaveData.t[trophy_id] ~= 1 then
		SaveData.t[trophy_id] = 1
		trophyObj.Unlock(trophy_id)
        --print (string.format("TROPHY_NOTE: %d Awarded!", trophy_id))
        
        -- Check for Platinum Trophy
        if SaveData.t[TROPHY_A_WONDERFUL_LIFE] ~= 1 then
        	local count = 0
			local x = 0
			for x = 0, MAX_TROPHY do
				count = count + SaveData.t[x]
	        end
	        --print (string.format("_NOTE:         %d trophies awarded so far.", count))
        	if count == MAX_TROPHY then
        		SaveData.t[TROPHY_A_WONDERFUL_LIFE] = 1
				trophyObj.Unlock(TROPHY_A_WONDERFUL_LIFE)
        		--print "TROPHY_NOTE: Platinum trophy 00 - A WONDERFUL LIFE Awarded!"
        	end
        end   	
		emuObj.SaveConfig(0, SaveData)			
	end
end


--[[	SET_GAME_DATA_PTR

	sets the Game Data pointer

	Hook is in: 	initializer of the GameData singleton
--]]
function SET_GAME_DATA_PTR()
	local gp = eeObj.GetGPR(gpr.gp)
	pGameData = eeObj.ReadMem32(gp+GameDataOffset)
	--print (string.format("_NOTE: Setting Game Data to %x (gp = %x)", pGameData, gp))
end

--[[	SEED_PLANTED				Trophy 01

	You get here when a seed is planted.

	Hook is in:		ObjectFarmCell::receiveEndSeedRidge(const ObjectMessage&)
--]]
function SEED_PLANTED()
	local pCell = eeObj.GetGPR(gpr.a0)
	local cellIndx = eeObj.GetGPR(gpr.a1)
	local cell = cellIndx-35
	local field = 0
	if (cell < 0) then
		cell = cell+35
	else
		field = 1
	end
	--print (string.format("_NOTE: Entering SEED_PLANTED for field %d, cell %d, ptr %x", field, cell, pCell))
	local pFirstCell = pCell - (cellIndx*220)	-- start of field cell tables
	local pLastCell = pFirstCell + (69*220)		-- last field cell table of 70 (35 for each field)
--[[	
	local state = {}
	local indx = 0
	for ptr=pFirstCell, pLastCell, 220 do
		state[indx] = eeObj.ReadMem8(ptr+7)
		indx = indx + 1
	end
	for i=0, 63, 7 do
		print (string.format("_NOTE          %d %d %d %d %d %d %d", state[i], state[i+1], state[i+2],
			state[i+3], state[i+4], state[i+5], state[i+6]))
	end
--]]
	local count = 1								-- count the newly planted seed (its state hasn't been set yet)
	for ptr=pFirstCell, pLastCell, 220 do
		local state = eeObj.ReadMem8(ptr+7)		--  the current state is at an offset of +7 in the table
		if (state > 2) then						-- a state > 2 means that cell is planted
			count = count + 1
		end
	end
	--print (string.format("_NOTE:            %d crops at the moment", count))
	if (count >= 20) then
		award_trophy(TROPHY_PLENTY_OF_PLANTS)
	end
end


--[[	WIN_MILK_GAME				Trophy 02

	You get here when you win the milk drinking minigame

	Hook is in: 	SceneMinigameDrink::initWin() 	
--]]		
function WIN_MILK_GAME()
	print "_NOTE: Entering WIN_MILK_GAME"
	award_trophy(TROPHY_CHUG_CHUG_CHUG)
end


--[[	END_TERR_CAP_GAME			Trophy 03

	compares scores at the end of the Territory Capture minigame

	Hook is in:  	ConsoleBoard::GameOver()
--]]
function END_TERR_CAP_GAME()
	local pBoardGameData = eeObj.GetGPR(gpr.v0)
	--print (string.format("_NOTE: Entering END_TERRITORY_CAPTURE (data = %x)", pBoardGameData))
	--
	--	Check player's and opponent's scores
	--
	local oppSc = eeObj.ReadMem8(pBoardGameData + BoardGameOppScoreOffset) 
	local plyrSc = eeObj.ReadMem8(pBoardGameData + BoardGamePlyrScoreOffset) 
	--print (string.format("_NOTE:      me = %d, them = %d", plyrSc, oppSc))
	if (plyrSc > oppSc) then
		award_trophy(TROPHY_GAME_TIME)
	end
end


--[[	CAUGHT_A_FISH				Trophy 04

	You get here when you catch a fish
		
	Hook is in: 	ObjectSyosaku::initFishingPose()
--]]
function CAUGHT_A_FISH()
	-- for TEST purposes only
	--local fishID = eeObj.GetGPR(gpr.v0)
	--print (string.format("_NOTE: Entering CAUGHT_A_FISH, id = %x", fishID))
	-- end TEST
	award_trophy(TROPHY_HOOK_LINE_AND_SINKER)
end


--[[	CALF_BORN					Trophy 05

	You get here when a calf is added.
	
	Hook is in:			DMAnimalObjectManager::addCalf(CharacterID)
--]]
function CALF_BORN()
	--print "_NOTE: Entering CALF_BORN"
	award_trophy(TROPHY_MOO_BORN)
end




--[[	COW_MILK_TYPE				Trophies 06 and 07

	You get here inside ObjectCattleData::getMilk(). You may be milking a cow,
	checking on how much milk you have, or displaying a console screen.

	To determine the milk type...  there are 4 types of cows, each having 4 
	grades of milk (B, C, A and S). The item number of the milk type is in V0. 
	The base item number of milk from that cow is in V1. By subtracting the milk
	type from the base we get an offset which corresponds to the grade of milk.
	S-grade milk should have an offset of 1. The other grades would be 0, 2 or 3.

	The only exception to this is that you can get Mother's Milk after a cow gives
	birth, and that item number is 6. Any other number should be ignored.

	Fixes bug 10271
	
	Hook is in: 	ObjectCattleData::getMilk()

--]]
function COW_MILK_TYPE()
	milkType = eeObj.GetGPR(gpr.v0)
	--print (string.format("_NOTE: Entering COW_MILK_TYPE (milkType = %d)", milkType))
	if (milkType ~= 6) then		-- check for mothers milk
		local baseMilkType = eeObj.GetGPR(gpr.v1)
		milkType = milkType - baseMilkType		-- this gives an offset of 0, 1, 2 or 3
		if ((milkType < 0) or (milkType > 3)) then
			milkType = -1
		end
	end
	--print (string.format("_NOTE:                        (offset = %d)", milkType))
end


--[[	GOT_COW_MILK				Trophies 06 and 07

	You get here after milking a cow.
	milkType is set in COW_MILK_TYPE. It is...
	-1 if you never got to getMilk() 	-- error condition
	6  if you got mother's milk
	3 for S-Grade milk
	0, 1 or 2 for other types of milk

	fixes bug 10271
	
	Hook is in: 	ObjectCattleData::approachBeMilked()
--]]
function GOT_COW_MILK()
	--print (string.format("_NOTE: Entering GOT_MILK, milkType = %d", milkType))
	if (milkType ~= -1) then
		award_trophy(TROPHY_FRESH_MILK)
	end
	if (milkType == 3) then
		award_trophy(TROPHY_HAPPY_HEIFER)
	end
	milkType = -1
end

--[[	GET_BUFFER					Trophy 08 (and 23)

	You get here whenever a script is about to be run. The script number is in a1.
	Script 0x2d3 is the ducks going into the pond script.  When this script is run, 
	we award trophy 8.
	
	Script 0x31e is the script where the sprites find a "nice". We want to award trophy
	23 when this script is finished, so we set a flag here and detect it in STOP_SCRIPT.
	
	Hook is in:			Event::EventManager::getBuffer(int) const
--]]
function GET_BUFFER()
	local param =  eeObj.GetGPR(gpr.a1)
	--print (string.format("_NOTE: Entering GET_BUFFER with param %x", param))
	if (param == 0x2d3) then
		award_trophy(TROPHY_QUACK_QUACK)
	elseif (param == 0x31e) then
		waitForNiceScene = 1
	end
end


--[[	ITEM_IN_HAND				Trophies 09 and 17
 
 	You get here when an item is placed in the player's hands
	if it's a record, call CHECK_RECORDS
	if it's golden wool, call GET_GOLD_WOOL
	
	Hook is in:			ObjectSyosakuData::setHoldItem(Item::ItemID)
--]]
function ITEM_IN_HAND()
	local itemID = eeObj.GetGPR(gpr.a0)
	--print (string.format("_NOTE: Entering ITEM_IN_HAND with %x", itemID))
	if ((itemID >= 0x520) and (itemID <= 0x52e)) then
		CHECK_RECORDS(1)			-- we're holding a record
	elseif (itemID == 0x1b) then
		award_trophy(TROPHY_GOLDEN_GROOMER)
	end
end


--[[	CHECK_RECORDS				Trophy 17

	Called from ITEM_IN_HAND or MAKE_VAN_PURCHASE.
	Records are item numbers 520 thru 52e.  
	They can be on the record player, in your rucksack or on the shelf.
	This will check how many you have. The parameter holding will be 1 or 0
	depending on whether you're holding one at the time.
--]]
function CHECK_RECORDS(holding)		
	--print "_NOTE: Entering CHECK_RECORDS"
	if (pGameData == 0) then
		SET_GAME_DATA_PTR()
	end
	--
	-- First Check Store Shelf
	--
	local count = FIND_RECORDS(pGameData+StoreShelfOffset, 1080)		-- look on shelf
	--print (string.format("_NOTE:  %d records found on shelf", count))
	--
	-- Next Check rucksack
	--
	local count2 = FIND_RECORDS(pGameData+RucksackOffset, 350)		-- look in rucksack
	--print (string.format("_NOTE:  %d records found in rucksack", count2))
	count = count + count2 + holding
	--
	-- Check if there's a record in the Record Player
	--    
	local pData = pGameData+RecordPlayerOffset
	local record = eeObj.ReadMem32(pData+4)
	--print (string.format("_NOTE:   pData = %x, rec = %x", pData, record))
	if (record < 0xf) then
		count = count + 1
		--print (string.format("_NOTE:  Record %x found in record player", record))
	end

	--print (string.format("_NOTE:  %d Records collected", count))	
	if (count >= 10) then
		award_trophy(TROPHY_RECORD_KEEPING)
	end
end
	
--[[	FIND RECORDS

	Helper function for CHECK_RECORDS.  Searches through data for record item numbers.
	Parameters are a start location and the max number of items that can be stored in that location.
	Up to 350 items can be stored in the rucksack
	Up to 1080 items can be stored on your store shelf.
--]]
function FIND_RECORDS(ptr, num)
	--print (string.format("_NOTE: Entering FIND_RECORDS with ptr = %x", ptr))
	local item = eeObj.ReadMem16(ptr)
	local cnt = 0
	for x = 1, num do
		-- for TEST purposes only
--		if (x < 30) then
--			print (string.format("_NOTE:  x = %d, item = %x", x, item))
--		end
		-- end TEST
		if ((item >= 0x520) and (item <= 0x52e)) then
			cnt = cnt + 1		 -- eeObj.ReadMem16(ptr+2)
		end
		ptr = ptr + 4
		item = eeObj.ReadMem16(ptr)
	end
	--print (string.format("_NOTE:             Returning %d", cnt))
	return cnt
end


--[[	EGG_HATCH					Trophy 10

	You get here when a new chicken is initialized. (Baby chicks are type 2)

	Hook is in:		ObjectFowl::ObjectFowl(ObjectFowlData*)
--]]
function EGG_HATCH()		
	local type = eeObj.GetGPR(gpr.v0)
	--print (string.format("_NOTE: Entering EGG_HATCH (Type = %d)", type))
	-- confirm that it's a baby chick
	if (type == 2) then
		award_trophy(TROPHY_HATCHED)
	end
end



--[[	RIDE_HORSE					Trophy 10

	You get here when you get on or off a horse.

	Hook is in:		RuntimeData::setSyosakuRideHorse(bool)
--]]
function RIDE_HORSE()
	local doride = eeObj.GetGPR(gpr.a0)
	--print (string.format("_NOTE: Entering RIDE_HORSE (with %d)", doride))
	if (doride > 0) then
		award_trophy(TROPHY_SURE_BEATS_WALKING)
	end
end


--[[	GET_MEAL_TYPE

	Helper function for Trophy 12
	
	You get here when cooking is about to start - it obtains the
	type of meal being cooked and saves it.
	0 = Salad
	1 = Entree
	2 = Hors D'Oeuvre
	3 = Soup
	4 = Dessert
	
	Hook is in:		ConsoleCooking::enterCooking()
--]]
function GET_MEAL_TYPE()
	mealType = eeObj.GetGPR(gpr.a1) -- find meal type in a1
	--print (string.format("_NOTE: Entering GET_MEAL_TYPE (type = %d)", mealType))
end


--[[  COOKING_SUCCESS				Trophy 12

	You get here when the game determines that the items cooked	form a valid recipe.
	In other words, cooking was successful.
	
	If the type of meal was an entree, the trophy is awarded.
	
	Hook is in: 	CookingDataManager::cooking(CookEnv::CookingType,Item::ItemID,Item::ItemID,Item::ItemID)
--]]
function COOKING_SUCCESS()
	--print (string.format("_NOTE: Entering COOKING_SUCCESS (type = %d)", mealType))
	if (mealType == 1) then			-- 1 = Entree
		award_trophy(TROPHY_MAIN_COURSE)
	end
end
	

--[[ 	CREATE_HYBRID				Trophy 13

	You get here when you successfully create a hybrid
	The item number will tell us if it's third generation or not.
	
	3rd generation seeds range from 0x2cb to 0x3ea and 0x418 to 0x432
	Trophy is awarded for the creation of a 3rd generation seed.
	
	Hook is in:		RuntimeData::setBreedingBreedItem(Item::ItemID)	
--]]
function CREATE_HYBRID()
	local itemID = eeObj.GetGPR(gpr.a1)	
	--print (string.format("_NOTE: Entering CREATE_HYBRID seed ID = %x", itemID))
	if (itemID >= 0x2cb and itemID <= 0x3ea) then
		award_trophy(TROPHY_THIRD_GENERATION)
	elseif (itemID >= 0x418 and itemID <= 0x432) then
		award_trophy(TROPHY_THIRD_GENERATION)
	end
end	
	
--[[ 	Add_Building					

	Helper function for Trophy 14 functions
	Parameter is a building index (0, 1, 2, 3, 4 and 9)
	All the hooks for building additions occur before the table is actually written.
	So this function checks the table to see how many buildings exist, but when it gets
	to the new building, it compensates by adding 1.
	Trophy is awarded if all 6 additions exist.
	
--]]	
function Add_Building(bIndx)
	local tblSt = eeObj.GetGPR(gpr.v1)+BuildingTableOffset
	--print (string.format("_NOTE:      bldg = %d, tblSt = %x", bIndx, tblSt))
	local x = 0
	local count = 0
	for x = 0, 4 do
		local cnt = eeObj.ReadMem8(tblSt+x)
		if (cnt == 0 and x == bIndx) then		-- this building hasn't been written yet, so 
			cnt = 1								-- compensate
		end
		count = count + cnt
	end
	if (bIndx == 9) then
		count = count + 1
	else
		count = count + eeObj.ReadMem8(tblSt+9)
	end
	if (count == 6) then
		award_trophy(TROPHY_CONSTRUCTION_WORKER)
	--else
	--	print (string.format("_NOTE:      %d buildings added so far.", count))
	end
end


--[[	ADD_FOODPROC_ROOM			Trophy 14

	You get here after the Food Processing Room has been added.
	
	Hook is in: 	GameData::setExistFoodProcessRoom(bool)	
--]]
function ADD_FOODPROC_ROOM()
	--print "_NOTE: Entering ADD Food Processing Room"
	Add_Building(1)
end


--[[	ADD_MILKING_ROOM			Trophy 14

	You get here after the Milking Room has been added.
	
	Hook is in: 	GameData::setExistMilkingParlor(bool)
--]]
function ADD_MILKING_ROOM()
	--print "_NOTE: Entering ADD Milking Room"
	Add_Building(2)
end


--[[	ADD_FERT_MAKER				Trophy 14

	You get here after the Fertilizer Maker has been added.
	
	Hook is in: 	GameData::setExistFertilizerMaker(bool)
--]]
function ADD_FERT_MAKER()
	--print "_NOTE: Entering ADD Fertilizer Maker"
	Add_Building(4)
end


--[[	ADD_SEED_MAKER				Trophy 14

	You get here after the Seed Shelf has been added.
	
	Hook is in: 	GameData::setExistSeedShelf(bool)	
--]]
function ADD_SEED_MAKER()
	--print "_NOTE: Entering ADD Seed Maker"
	Add_Building(3)
end


--[[	ADD_POND					Trophy 14

	You get here after the Duck Pond (Reservoir) has been added.
	
	Hook is in: 	GameData::setExistReservoir(bool)
--]]
function ADD_POND()
	--print "_NOTE: Entering ADD Pond"
	Add_Building(0)
end


--[[	ADD_CHICKEN_YARD			Trophy 14

	You get where after the Chicken Yard (Poultry Gauge) has been added.
	
	Hook is in: 	GameData::setExistPoultryGauge(bool)
--]]
function ADD_CHICKEN_YARD()
	--print "_NOTE: Entering ADD Chicken Yard"
	Add_Building(9)
end


--[[		DOG_LOVE				Trophy 15

	You get here when dog Love gets saved from an alternate location to the dog's data block. 
	
	Hook is in:		 ObjectDog::saveWorkAll()
--]]
function DOG_LOVE()
	local pDogData = eeObj.GetGPR(gpr.s0)
	local dogLove = eeObj.ReadMem16(pDogData+DogLoveOffset)
	--print (string.format("_NOTE: Entering DOG_LOVE = %d", dogLove))
	if (dogLove >= 100) then
		award_trophy(TROPHY_DOG_LOVER)
	end
end

	
--[[	CHECK_TOOL_SHELF			Trophy 16

	You get here when a tool is placed in the Tool Shelf. 

	Hook is in:		ToolShelf::set(int)
--]]
function CHECK_TOOL_SHELF()
	local sp = eeObj.GetGPR(gpr.sp)			
	local tblSt = eeObj.ReadMem32(sp+0x10)+8	-- start of status table
	local thisTool = eeObj.GetGPR(gpr.a1)		-- index of tool being placed
	--print (string.format("_NOTE: Entering CHECK_TOOL_SHELF, index = %d, table start = %x", thisTool, tblSt))
	local count = 0
	local x = 0
	for x = 0, 21 do
		local toolbits = eeObj.ReadMem8(tblSt)	-- read status of a tool
		if (x == thisTool) then					-- if current tool, set bit to indicate it is placed.
			toolbits = toolbits | 1
		end
		if ((toolbits & 0x81) == 0x81) then		-- these bits indicate tool is owned and present
			count = count+1
		end
		--print (string.format("_NOTE:     addr = %x, x = %d, bits = %x", tblSt, x, toolbits))
		tblSt = tblSt + 1						-- one byte per tool in this table
	end
	if count == 22 then
		award_trophy(TROPHY_RIGHT_TOOL_FOR_THE_JOB)
	--else
	--	print (string.format("_NOTE:           %d tools counted", count))
	end
end


--[[	GRAVE_CLEANED					Trophy 18

	You get here when you successfully clean Nina's grave before the time runs out.
	
	Hook is in:		SceneMinigameTomb::updateWash(unsigned int)
--]]
function GRAVE_CLEANED()
	--print "_NOTE: Entering GRAVE_CLEANED"
	award_trophy(TROPHY_TIDY_TOMBSTONE)
end


--[[	DUG_TABLET					Trophy 19

	You get here when you dig up a tablet
	S2 contains the tablet index (0-4)
	S0 contains a pointer to the base address for a table of the first 5 tablets
	
	Hook is in:		ObjectDigGround::procDig()
--]]
function DUG_TABLET()
	local pTbl = eeObj.GetGPR(gpr.s0) + TabletOffset
	local tabInd = eeObj.GetGPR(gpr.s2)
	--print (string.format("_NOTE: Entering DUG_TABLET - tablet %d (%x)", tabInd, pTbl))
	local count = 0
	for x=0, 4 do
		local found = eeObj.ReadMem8(pTbl)
		pTbl = pTbl + 1
		if (found == 0 and x == tabInd) then
			count = count + 1
		else
			count = count+found
		end
	end
	--print (string.format("_NOTE:        %d tablets found", count))
	--
	--	Future:: Possibly delay awarding of trophy until it is in the player's hand.
	--
	if (count == 5) then
		award_trophy(TROPHY_DILIGENT_DIGGER)
	end
end

--[[	SET_EVENT_FLAG				Trophy 20

	You get when the game is about to set an Event Flag. The events we will check here
	are related to visiting the four festivals. Those event flags are...
	0xc0 for the New Years Fest
	0xc1 for the Summer Fest
	0xc2 for the Harvest Fest and
	0xc3 for the Winter Fest
	When all these have occurred we award the trophy	

	Hook is in:		Event::EventData::setFlag(Event::EventFlagID)
--]]
function SET_EVENT_FLAG()
	local eventFlg = eeObj.GetGPR(gpr.a1)
	--print (string.format("_NOTE: Entering SET_EVENT_FLAG for event %x", eventFlg))
	if (eventFlg >= 0xc0 and eventFlg <= 0xc3) then
		initsaves()
		local festivalFlags = SaveData["FestivalsVisited"]	-- get saved data
		festivalFlags = festivalFlags |  (1 << (eventFlg-0xc0))
		SaveData["FestivalsVisited"] = festivalFlags
		emuObj.SaveConfig(0, SaveData)			
--[[
		OLD WAY - depended on having visited all the festivals in the currently loaded game
		local pEventData = eeObj.GetGPR(gpr.a0)
		local pEventFlagStart = eeObj.ReadMem32(pEventData + EventFlagOffset)
		local festivalFlags = eeObj.ReadMem32(pEventFlagStart + 0x18) & 0xf
		festivalFlags = festivalFlags |  (1 << (eventFlg-0xc0))
--]]
		--print (string.format("_NOTE:         festival flags = %x", festivalFlags))
		if (festivalFlags == 0xf) then
			award_trophy(TROPHY_SERIOUS_CELEBRATOR)
		end
	end
end


--[[	SELECT_VAN_ITEM				Trophy 21

	You get here when you select something from Van's menu
	
	The item ID is in A1.  We need to make sure that the item is a goat and that
	Van is selling.  Then, after the purchase is complete, we will check the price
	to see if it's lower than 4000g.
	
	Hook is in:		Event::ScriptPlayer::SystemFunc(int,Event::ScriptPlayer::SysFuncArgBuffer*)
--]]
function SELECT_VAN_ITEM()
	local itemID = eeObj.GetGPR(gpr.a1)
	waitForGoatPurchase = 0
	waitForRecordPurchase = 0
	--print (string.format("_NOTE: Entering SELECT_VAN_ITEM (id = %x)", itemID))
	if ((itemID >= 0x520) and (itemID <= 0x52e)) then
		local gp = eeObj.GetGPR(gpr.gp)
		local pRunTimeData = eeObj.ReadMem32(gp+pRuntimeDataOffset)
		local isVanPeddling = eeObj.ReadMem8 (pRunTimeData+VanPeddlingOffset)
		--print (string.format("_NOTE: pRunTimeData = %x, isVanPeddling = %d", pRunTimeData, isVanPeddling))
		if (isVanPeddling == 1) then
			waitForRecordPurchase = 1	
		end
	elseif (itemID == 0x534) then		-- if this is a goat, let's make sure van is selling (safety)
		local gp = eeObj.GetGPR(gpr.gp)
		local pRunTimeData = eeObj.ReadMem32(gp+pRuntimeDataOffset)
		local isVanPeddling = eeObj.ReadMem8 (pRunTimeData+VanPeddlingOffset)
		--print (string.format("_NOTE: pRunTimeData = %x, isVanPeddling = %d", pRunTimeData, isVanPeddling))
		if (isVanPeddling == 1) then
			waitForGoatPurchase = 1
		end
	end
end


--[[	MAKE_VAN_PURCHASE			Trophy 21

	You get here when you've purchased something from Van.
		
	The cost is in V0.  This is a negative number and must be converted to positive.
	If the item we're buying is a goat, and the cost is less than 4000G, that means 
	we haggled with Van and we can award the trophy.

	Hook is in:		Event::ScriptPlayer::SystemFunc(int,Event::ScriptPlayer::SysFuncArgBuffer*)
--]]
function MAKE_VAN_PURCHASE()
	--print (string.format("_NOTE: Entering MAKE_VAN_PURCHASE (goat = %d, record = %d)", waitForGoatPurchase, waitForRecordPurchase))
	if (waitForGoatPurchase == 1) then
		local cost = eeObj.GetGPR(gpr.v0) & 0xffff
		cost = 0x10000 - cost
		--print (string.format("_NOTE:            cost = %d", cost))
		if (cost < 4000) then
			award_trophy(TROPHY_A_HARD_BARGAIN)
		end
		waitForGoatPurchase = 0
	elseif (waitForRecordPurchase == 1) then
		CHECK_RECORDS(0)
		waitForRecordPurchase = 0
	end
end


--[[	HEAL_CATTLE					Trophy 22

	You get here when a cow or bull transitions from sick to well again
	
	Hook is in:		ObjectCattleData::transitionSickness()
--]]
function HEAL_CATTLE()
	--print "_NOTE: Entering HEAL_CATTLE"
	award_trophy(TROPHY_VETERINARIAN)
end


--[[	HEAL_GOAT					Trophy 22

	You get here when a goat or sheep transitions from sick to well again
	
	Hook is in:		ObjectGoatData::transitionSickness()
--]]
function HEAL_GOAT()
	--print "_NOTE: Entering HEAL_GOAT"
	award_trophy(TROPHY_VETERINARIAN)
end


--[[	HEAL_HORSE					Trophy 22

	You get here when a horse transitions from sick to well again
	
	Hook is in:		ObjectHorseData::transitionSickness()
--]]
function HEAL_HORSE()
	--print "_NOTE: Entering HEAL_HORSE"
	award_trophy(TROPHY_VETERINARIAN)
end


--[[	STOP_SCRIPT				 	Trophy 23

	You get here when a script is done playing. If the cut scene where
	the sprites found a "nice" was playing, award trophy 24.
	
	Otherwise, clear all script related flags
	
	Hook is in:		Event::ScriptPlayer::stop()
--]]
function STOP_SCRIPT()
	--print "_NOTE: Entering STOP_SCRIPT"
	if (waitForNiceScene == 1) then
		award_trophy(TROPHY_LIGHTS_IN_THE_SKY)
	end
	waitForGoatPurchase = 0		-- in case we left this hanging as 1.
	waitForRecordPurchase = 0
	waitForNiceScene = 0
end	



--[[	ALARM_WAKE_UP				Trophy 24

	You get here if the player used the alarm clock to wake up. The hook is where the
	alarm sound is played.
	
	Hook is in: 		SceneConsoleDream::procConsoleDream()
--]]		
function ALARM_WAKE_UP()
	--print "_NOTE: Entering ALARM_WAKE_UP"
	award_trophy(TROPHY_RISE_AND_SHINE)
end


--[[	END_OF_CHAPTER				Trophies, 25-30

	You get here at the end of a chapter.
	The chapter number should be in a0  (0-based)
	You can also get here at the very beginning of the game if you respond "No" to
	taking on the farm. Then the game ends, so we test for that condition.
	
	Hook is in:			Chapter::term(unsigned int)
--]]
function END_OF_CHAPTER()
	local chapter = eeObj.GetGPR(gpr.a0)
	
	local gp = eeObj.GetGPR(gpr.gp)
	local pRunTimeData = eeObj.ReadMem32(gp+pRuntimeDataOffset)
	local isGameOver = eeObj.ReadMem8 (pRunTimeData+GameOverOffset) -- bug fix 10239
	
	--print (string.format("_NOTE: CHAPTER %d is over (game-over= %d)", chapter+1, isGameOver))
	if (isGameOver == 0) then
		if (chapter == 0) then
			award_trophy(TROPHY_AWL_CHAPTER_1)
		end
		if (chapter == 1) then
			award_trophy(TROPHY_AWL_CHAPTER_2)
		end
		if (chapter == 2) then
			award_trophy(TROPHY_AWL_CHAPTER_3)
		end
		if (chapter == 3) then
			award_trophy(TROPHY_AWL_CHAPTER_4)
		end
		if (chapter == 4) then
			award_trophy(TROPHY_AWL_CHAPTER_5)
		end
	end
	if (chapter == 5) then
		award_trophy(TROPHY_AWL_CHAPTER_6)
	end
end
 


local hook     = eeObj.AddHook(0x18a450, 0x7bb00000, SET_GAME_DATA_PTR)
local hook_1   = eeObj.AddHook(0x23ce1c, 0x0040202d, SEED_PLANTED) 		-- ObjectFarmCell::receiveEndSeedRidge(const ObjectMessage&)
local hook_2   = eeObj.AddHook(0x4225d8, 0x0040202d, WIN_MILK_GAME)		-- SceneMinigameDrink::initWin()
local hook_3   = eeObj.AddHook(0x41fd34, 0xffbf0000, END_TERR_CAP_GAME) -- ConsoleBoard::GameOver()
local hook_4   = eeObj.AddHook(0x1d0d0c, 0x8c642464, CAUGHT_A_FISH)		-- ObjectSyosaku::initFishingPose()
local hook_5   = eeObj.AddHook(0x27e12c, 0xafa400a0, CALF_BORN)			-- DMAnimalObjectManager::addCalf(CharacterID)
local hook_6_7a =eeObj.AddHook(0x26ff60, 0xdfbf0010, COW_MILK_TYPE) 	-- ObjectCattleData::getMilk()
local hook_6_7b =eeObj.AddHook(0x278c90, 0x8fa20070, GOT_COW_MILK)	    -- ObjectCattle::approachBeMilkedSA()
local hook_8   = eeObj.AddHook(0x2bdf6c, 0x7fb00000, GET_BUFFER) 		-- Event::EventManager::getBuffer(int) const
local hook_9_17 =eeObj.AddHook(0x194268, 0x27bd0020, ITEM_IN_HAND) 		-- ObjectSyosakuData::setHoldItem(Item::ItemID)
local hook_10  = eeObj.AddHook(0x261a10, 0x246400b0, EGG_HATCH) 		-- ObjectFowl::ObjectFowl(ObjectFowlData*)
local hook_11  = eeObj.AddHook(0x194904, 0xa064056a, RIDE_HORSE)		-- RuntimeData::setSyosakuRideHorse(bool)		
local hook_12a = eeObj.AddHook(0x35a758, 0x8fa70054, GET_MEAL_TYPE)		-- ConsoleCooking::enterCooking()
local hook_12b = eeObj.AddHook(0x2a7938, 0x8fa400b0, COOKING_SUCCESS)	-- CookingDataManager::cooking(CookEnv::CookingType,Item::ItemID,Item::ItemID,Item::ItemID)
local hook_13  = eeObj.AddHook(0x3c2ea4, 0xafa40000, CREATE_HYBRID)		-- RuntimeData::setBreedingBreedItem(Item::ItemID)
local hook_14a = eeObj.AddHook(0x2dfad8, 0x00610821, ADD_FOODPROC_ROOM) -- GameData::setExistFoodProcessRoom(bool)
local hook_14b = eeObj.AddHook(0x2dfaa8, 0x00610821, ADD_MILKING_ROOM)	-- GameData::setExistMilkingParlor(bool)
local hook_14c = eeObj.AddHook(0x2df9e8, 0x00610821, ADD_FERT_MAKER)	-- GameData::setExistFertilizerMaker(bool)	
local hook_14d = eeObj.AddHook(0x2dfa48, 0x00610821, ADD_SEED_MAKER)	-- GameData::setExistSeedShelf(bool)
local hook_14e = eeObj.AddHook(0x2dfa78, 0x00610821, ADD_POND)			-- GameData::setExistReservoir(bool)
local hook_14f = eeObj.AddHook(0x2dfa18, 0x00610821, ADD_CHICKEN_YARD)	-- GameData::setExistPoultryGauge(bool)
local hook_15  = eeObj.AddHook(0x322e5c, 0x8c420144, DOG_LOVE)			-- ObjectDog::saveWorkAll()
local hook_16  = eeObj.AddHook(0x1e21ec, 0x00832021, CHECK_TOOL_SHELF) 	-- ToolShelf::set(int)
local hook_18  = eeObj.AddHook(0x41a4ac, 0x0040202d, GRAVE_CLEANED)	 	-- SceneMinigameTomb::updateWash(unsigned int)
local hook_19  = eeObj.AddHook(0x3b97a0, 0x24020006, DUG_TABLET)	 	-- ObjectDigGround::procDig()
local hook_20  = eeObj.AddHook(0x211da0, 0x8fa20030, SET_EVENT_FLAG)	-- Event::EventData::setFlag(Event::EventFlagID)
local hook_21a = eeObj.AddHook(0x2ccc88, 0x0040282d, SELECT_VAN_ITEM)	-- Event::ScriptPlayer::SystemFunc(int,Event::ScriptPlayer::SysFuncArgBuffer*)
local hook_21b = eeObj.AddHook(0x2cc2d0, 0x0040382d, MAKE_VAN_PURCHASE)	-- Event::ScriptPlayer::SystemFunc(int,Event::ScriptPlayer::SysFuncArgBuffer*)
local hook_22a = eeObj.AddHook(0x272d34, 0x2444007c, HEAL_CATTLE) 		-- ObjectCattleData::transitionSickness()
local hook_22b = eeObj.AddHook(0x258dec, 0x24440078, HEAL_GOAT) 		-- ObjectGoatData::transitionSickness()
local hook_22c = eeObj.AddHook(0x252664, 0x24440090, HEAL_HORSE) 		-- ObjectHorseData::transitionSickness()
local hook_23  = eeObj.AddHook(0x2bbe18, 0xafa40010, STOP_SCRIPT)		-- Event::ScriptPlayer::stop()
local hook_24  = eeObj.AddHook(0x3ae498, 0x0000302d, ALARM_WAKE_UP)		-- SceneConsoleDream::procConsoleDream()
local hook_25_30=eeObj.AddHook(0x1949d0, 0x8fa30020, END_OF_CHAPTER) 	-- Chapter::term(unsigned int)



-- Credits

-- Trophy design and development by SCEA ISD SpecOps
-- David Thach		Senior Director
-- George Weising	Executive Producer
-- Tim Lindquist	Senior Technical PM
-- Clay Cowgill		Engineering
-- Nicola Salmoria	Engineering
-- Warren Davis 	Engineering
-- Jenny Murphy		Producer
-- David Alonzo		Assistant Producer
-- Tyler Chan		Associate Producer
-- Karla Quiros		Manager Business Finance & Ops
-- Special thanks to R&D
