-- Lua 5.3
-- Title:   Harvest Moon: Save The Homeland - SLUS-20251 (US) 1.3.0
-- Version: 1.0.0
-- Date:    May 17th, 2016
-- Author(s):  Warren Davis, warren_davis@playstation.sony.com for SCEA and Tim Lindquist

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj			= getEEObject()
local emuObj		= getEmuObject()
local trophyObj		= getTrophyObject()

local TROPHY_SAVIOR_OF_THE_HOMELAND = 00
local TROPHY_INCUBATION = 01
local TROPHY_TRACK_STAR = 02
local TROPHY_DECENT_DAIRY = 03
local TROPHY_MANS_BEST_FRIEND = 04
local TROPHY_RIDING_PARTNERS = 05
local TROPHY_FOLLOW_THE_MUSIC = 06
local TROPHY_GIDDY_UP = 07
local TROPHY_STARTING_TO_FEEL_LIKE_HOME = 08
local TROPHY_SUPERFOOD = 09
local TROPHY_MAD_COW = 10
local TROPHY_CHICKEN_CRAZY = 11
local TROPHY_FORGOTTEN_TREASURES = 12
local TROPHY_FEED_THE_HUNGRY = 13
local TROPHY_PROTECTING_THE_ENDANGERED = 14
local TROPHY_FINEST_FABRIC = 15
local TROPHY_OFF_TO_THE_RACES = 16
local TROPHY_HOOKED = 17
local TROPHY_FLOAT_LIKE_A_BUTTERFLY = 18
local TROPHY_FAMOUS_DESSERTS = 19
local TROPHY_FURRY_FRIEND = 20

local pChickenTableSt = 0x859e60		-- start of Chicken Tables
local pCowTableSt = 0x859f20			-- start of Cow Tables
local pPowerBerry = 0x267860			-- location of power berry bits (0-4)
local pHorseLove = 0x859fc8				-- how much love from your horse
local pDogLove = 0x859ffa				-- how much love from your dog
local pFarmFlg = 0x2678c8				-- farm_flg: bits 0 and 1 are set to indicate the kitchen and dog house are built
local pRaceMinutes = 0x2677a0			-- Race Time
local pRaceSeconds = 0x26779c
local pRaceMsecs = 0x267798
local pEventTbl = 0x80d980				-- event flags  (00 thru 0xbf)

--print "_NOTE: Starting HM: SAVE THE HOMELAND"
	
local SaveData = emuObj.LoadConfig(0)


if SaveData.t == nil then
	SaveData.t  = {}
end


function initsaves()
	local doSave = false
	
	local x = 0
	for x = 0, 20 do
		if SaveData.t[x] == nil then
			SaveData.t[x] = 0
			doSave = true
		end
	end

	if doSave == true then
		emuObj.SaveConfig(0, SaveData)
		--print "_NOTE: ***** initsaves: Saving Config *****"
	end

end
	



function award_trophy(trophy_id)
	initsaves()
	if SaveData.t[trophy_id] ~= 1 then
		SaveData.t[trophy_id] = 1
		trophyObj.Unlock(trophy_id)
        --print (string.format("TROPHY_NOTE: %d Awarded!", trophy_id))
        
        --[[ Check for Platinum Trophy is not necessary
        if SaveData.t[TROPHY_SAVIOR_OF_THE_HOMELAND] ~= 1 then
        	local count = 0
			local x = 0
			for x = 0, 20 do
				count = count + SaveData.t[x]
	        end
	        --print (string.format("_NOTE:         %d trophies awarded so far.", count))
        	if count == 20 then
        		SaveData.t[TROPHY_SAVIOR_OF_THE_HOMELAND] = 1
				trophyObj.Unlock(TROPHY_SAVIOR_OF_THE_HOMELAND)
        		--print "TROPHY_NOTE: Platinum trophy 00 - SAVIOR OF THE HOMELAND Awarded!"
        	end
        end   
		--]]
		emuObj.SaveConfig(0, SaveData)			
	end
end



--[[	ANIMAL_LOVE		Trophies 04 and 05

		This is called when an animal increases its love towards the player.
		When the love exceeds a certain amount, they have reached a 5 heart friendship.
		
		For your horse, the amount is 0xf0
		For your dog, the amount is 0xdc
		
		We check to see which animal is receiving love (Horse or Dog) and check the appropriate
		amount to see if the trophy should be awarded.
--]]
function ANIMAL_LOVE()
	--print "_NOTE: Entering ANIMAL_LOVE!"
	--
	-- First see which animal
	--
	local pAnimalId = eeObj.GetGpr(gpr.sp) + 0x58
	local animalID = eeObj.ReadMem8(pAnimalId)
	if (animalID == 1) then			-- horse
		local horseLove = eeObj.ReadMem8(pHorseLove)
		--print (string.format("_NOTE: Horse, Love = %x", horseLove))
		if (horseLove >= 0xf0) then
			award_trophy(TROPHY_RIDING_PARTNERS)
		end
	elseif (animalID == 0) then
		local dogLove = eeObj.ReadMem8(pDogLove)
		--print (string.format("_NOTE: Dog, Love = %x", dogLove))
		if (dogLove >= 0xdc) then
			award_trophy(TROPHY_MANS_BEST_FRIEND)
		end
	end
end



--[[	MOUNT_HORSE		Trophy 07

		This is called when the player successfully attempts to get on the horse.
		
--]]
function MOUNT_HORSE()
	--print "_NOTE: Entering MOUNT_HORSE!"
	award_trophy(TROPHY_GIDDY_UP)
end



--[[	EGG_HATCHES		Trophy 01 and 11

		This is called when an hatches and a baby chick is added to the chicken table.   Trophy 01 is awarded.
		
		We also check to see how many chicks/chickens are on the farm.
		If there are 6, we award Trophy 11.
--]]
function EGG_HATCHES()
	--print "_NOTE: Entering EGG_HATCHES!"
	award_trophy(TROPHY_INCUBATION)
	CountChickens()
end



--[[	PURCHASE_CHICKEN	Trophy 11

		This is called when a chicken is purchased.
		
		We check to see how many chicks/chickens are on the farm.
		If there are 6, we award Trophy 11.
--]]
function PURCHASE_CHICKEN()
	--print "_NOTE: Entering PURCHASE_CHICKEN!"
	CountChickens()
end



--[[	PURCHASE_COW		Trophy 10

		This is called when a cow is purchased.
		
		We check to see how many calves/cows are on the farm.
		If there are 5, we award Trophy 10.
--]]
function PURCHASE_COW()
	--print "_NOTE: Entering PURCHASE_COW!"
	CountCows()
end



--[[	CALF_IS_BORN		Trophy 10

		This is called when a baby calf is born.
		
		We check to see how many calves/cows are on the farm.
		If there are 5, we award Trophy 10.
--]]
function CALF_IS_BORN()
	--print "_NOTE: Entering CALF_IS_BORN!"
	CountCows()
end



--[[	GET_GOLD_MILK	Trophy 03

		This is called when a cow gives Gold Milk.   Trophy 03 is awarded.
--]]
function GET_GOLD_MILK()
	--print "_NOTE: Entering GET_GOLD_MILK!"
	award_trophy(TROPHY_DECENT_DAIRY)
end


--[[	GET_POWER_BERRY		Trophy 9

		This is called when a cow is purchased.
		
		We check to see how many calves/cows are on the farm.
		If there are 5, we award Trophy 10.
--]]
function GET_POWER_BERRY()
	local bits = eeObj.ReadMem16(pPowerBerry)
	--print (string.format("_NOTE: power berry bits = %x", bits))
	if ((bits & 0x1f) == 0x1f) then		-- all 5 bits are set
		award_trophy(TROPHY_SUPERFOOD)
	end
end



--[[	CountChickens	Trophy 11

		This checks to see if there are 6 active chicks/chickens in the
		chicken table.  If there are, we award Trophy 11
--]]	
function CountChickens()
	local chickenPtr = pChickenTableSt
	local count = 0
	for x = 0, 5 do
		local flags = eeObj.ReadMem16(chickenPtr)
		--print (string.format("_NOTE: Chicken Table  %d = %x", x, flags))
		count = count + (flags & 1)			-- increment count if bit 0 = 1 
		chickenPtr = chickenPtr + 0x20
	end
	if (count == 6) then
		award_trophy(TROPHY_CHICKEN_CRAZY)
	end
end


--[[	CountCows	Trophy 10

		This checks to see if there are 5 active calves/cows in the
		cow table.  If there are, we award Trophy 10
--]]	
function CountCows()
	local cowPtr = pCowTableSt
	local count = 0
	for x = 0, 4 do
		local flags = eeObj.ReadMem16(cowPtr)
		--print (string.format("_NOTE: Cow Table  %d = %x", x, flags))
		count = count + (flags & 1)			-- increment count if bit 0 = 1 
		cowPtr = cowPtr + 0x20
	end
	if (count == 5) then
		award_trophy(TROPHY_MAD_COW)
	end
end


--[[   Flute related functions   Trophy 6

	There are 6 flute commands for the dog.  Trophy 6 is awarded when you can get the dog
	to respond to any of them.
	
--]]

function FLUTE_CMD_SIT()
	--print "_NOTE: Entering FLUTE_CMD_SIT"
	award_trophy(TROPHY_FOLLOW_THE_MUSIC)
end

function FLUTE_CMD_LAY()
	--print "_NOTE: Entering FLUTE_CMD_LAY"
	award_trophy(TROPHY_FOLLOW_THE_MUSIC)
end

function FLUTE_CMD_HEEL()
	--print "_NOTE: Entering FLUTE_CMD_HEEL"
	award_trophy(TROPHY_FOLLOW_THE_MUSIC)
end

function FLUTE_CMD_HERD()
	--print "_NOTE: Entering FLUTE_CMD_HERD"
	award_trophy(TROPHY_FOLLOW_THE_MUSIC)
end

function FLUTE_CMD_JUMP()
	--print "_NOTE: Entering FLUTE_CMD_JUMP"
	award_trophy(TROPHY_FOLLOW_THE_MUSIC)
end

function FLUTE_CMD_STAND()
	--print "_NOTE: Entering FLUTE_CMD_STAND"
	award_trophy(TROPHY_FOLLOW_THE_MUSIC)
end


--[[	CINEMATIC_OVER		Trophy 8 and 12

	This is called after any cinematic is done playing.  If there is a cinematic for the
	start of the day, it will play when you exit your house after sleeping.
	
	When you build a kitchen or dog house, you get one of these cinematics.  What tells us to award trophy 8
	is that the lowest 2 bits of farm_flg are set.  (Bit 0 gets set when the kitchen is built and bit 1 when 
	the doghouse is built).
	
	When Tim first tells you about the treasure map, Bit 0 of ev_action gets set.  When you find Bob's junk,
	Bit 1 gets set, which is an indication to award trophy .
	
--]]

function CINEMATIC_OVER()
	--print "_NOTE: Entering CINEMATIC OVER"
	local flags = eeObj.ReadMem16(pFarmFlg)
	if ((flags & 3) == 3) then		-- if first 2 bits set, then award Trophy 8
		award_trophy(TROPHY_STARTING_TO_FEEL_LIKE_HOME)
	end
	flags = eeObj.ReadMem16(pEventTbl)
	if ((flags & 3) == 3) then		-- if first 2 bits are set, then award Trophy 12
		award_trophy(TROPHY_FORGOTTEN_TREASURES)
	end
	
end


--[[	TIME_ATTACK_OVER		Trophy 2

	This is called when the Time Attack horse race ends. The final race time has been stored 
	in race_msec, race_sec and race_min.  If the player finishes in less than 55 secs, the
	trophy is awarded.
	
--]]

function TIME_ATTACK_OVER()
	local t = eeObj.ReadMem16(pRaceMinutes)			-- look at minutes
	local secs = eeObj.ReadMem16(pRaceSeconds)		-- look at seconds
	--print (string.format("_NOTE: Entering TIME_ATTACK_OVER (M: %d, S: %d)", t, secs))
	if (t == 0) then									-- continue only if we're under a minute
		if (secs <= 55) then							-- if we're at exactly 55 seconds, check mSecs
			t = eeObj.ReadMem16(pRaceMsecs)
			--print (string.format("_NOTE: MS: %d", t))
			if (t > 0) then								-- if mSecs are over 0, add a second to the total
				secs = secs + 1
			end
			if (secs <= 55) then						-- if we finished the race in under 55 secs (or exactly 55 secs)
				award_trophy(TROPHY_TRACK_STAR)			--        then award the trophy
			end			
		end
	end
end

--[[	EVENT_ACTION_BIT_ON

	Many of the trophies are awarded when a particular ending is achieved.
	These endings are basically playback of a cinematic in which the player
	learns that they saved the town in a certain way.
	
	This function is called when a Game Event bit is set.  We check for the
	particular Game Events which represent the playing of an ending cinematic
	and award the trophy where appropriate.  For some endings, there are two 
	game events, each of which plays a cinematic with one auto-following the other.  
	In this case, the trophy is awarded on the last cinematic.
	
	The Treasure Hunt trophy has two possible paths to get there.  Whichever the player
	does first will award the trophy.
	
--]]

function EVENT_ACTION_BIT_ON()
	local bit = eeObj.GetGpr(gpr.a0)
	--print (string.format("_NOTE: ------------------------------>  SETTING Event Action bit  %x", bit))
	if (bit == 0x2c) then
		award_trophy(TROPHY_FLOAT_LIKE_A_BUTTERFLY)		-- Azure Butterfly ending
	elseif (bit == 0x88) then
		award_trophy(TROPHY_FURRY_FRIEND)				-- Endangered Weasel ending
	elseif (bit == 0x73) then
		award_trophy(TROPHY_FINEST_FABRIC)				-- Goddess Dress ending
	elseif (bit == 0x92) then
		award_trophy(TROPHY_PROTECTING_THE_ENDANGERED)	-- BlueBird ending
	elseif (bit == 0x1d) then
		award_trophy(TROPHY_FEED_THE_HUNGRY)			-- Treasure Hunt 2 ending
	elseif (bit == 0x1e) then
		award_trophy(TROPHY_FEED_THE_HUNGRY)			-- Treasure Hunt 1 ending
	elseif (bit == 0x41) then
		award_trophy(TROPHY_OFF_TO_THE_RACES)			-- Horse Race ending
	elseif (bit == 0x63) then
		award_trophy(TROPHY_FAMOUS_DESSERTS)			-- Cake Contest ending
	elseif (bit == 0x7e) then
		award_trophy(TROPHY_HOOKED)						-- Silver Fish ending
	end
end

local hook_01_11a = eeObj.AddHook(0x1b5cd0, 0xac650000, EGG_HATCHES)		-- called when an egg hatches into a chick
local hook_02 =     eeObj.AddHook(0x220f00, 0x7bbf0020, TIME_ATTACK_OVER)	-- called when the time attack race ends
local hook_03 =     eeObj.AddHook(0x1c3360, 0x305000ff, GET_GOLD_MILK) 		-- called when a cow produces gold milk
local hook_04_05 =	eeObj.AddHook(0x1b8130, 0x7bb00000, ANIMAL_LOVE) 		-- called when an animal gets love
local hook_6a =     eeObj.AddHook(0x1bf8cc, 0x3c010086, FLUTE_CMD_SIT)		-- called when you play ULD on flute
local hook_6b =     eeObj.AddHook(0x1bfc0c, 0x3c010086, FLUTE_CMD_LAY)		-- called when you play UDD on flute
local hook_6c =     eeObj.AddHook(0x1bff68, 0x00621824, FLUTE_CMD_HEEL)		-- called when you play LRR on flute
local hook_6d =     eeObj.AddHook(0x1c020c, 0x8c239fe0, FLUTE_CMD_HERD)		-- called when you play RLR on flute
local hook_6e =     eeObj.AddHook(0x1c0544, 0x2403ffef, FLUTE_CMD_JUMP)		-- called when you play LUR on flute
local hook_6f =     eeObj.AddHook(0x1c08c8, 0x24050019, FLUTE_CMD_STAND)	-- called when you play DUU on flute
local hook_07 =		eeObj.AddHook(0x19bc0c, 0x24050004, MOUNT_HORSE) 		-- called when player gets on horse
local hook_8_12 =	eeObj.AddHook(0x1b2074, 0x97858998, CINEMATIC_OVER)		-- called after a new day's opening cinematic
local hook_09 =     eeObj.AddHook(0x178bf0, 0x27bd0010, GET_POWER_BERRY) 	-- called when you get a power berry
local hook_10a =    eeObj.AddHook(0x1a8488, 0x00032140, PURCHASE_COW) 		-- called when a cow is purchased
local hook_10b =    eeObj.AddHook(0x1b5f5c, 0x322200ff, CALF_IS_BORN) 		-- called when a calf is born
local hook_11b =    eeObj.AddHook(0x1a87c4, 0x72002628, PURCHASE_CHICKEN) 	-- called when a chicken is purchased
local hook_18 =		eeObj.AddHook(0x14986c, 0x3065ffff, EVENT_ACTION_BIT_ON)-- called when an event bit gets set

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
