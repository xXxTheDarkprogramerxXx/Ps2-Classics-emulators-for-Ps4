-- Lua 5.3
-- Title:   Puzzle Quest: Challenge of the Warlords - SLUS-21692 (US) 1.0.0
-- Version: 1.0.0
-- Date:    July 24th, 2015, revised 9/15/15
-- Author(s):  Warren Davis, warren_davis@playstation.sony.com for SCEA and Tim Lindquist

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj			= getEEObject()
local emuObj		= getEmuObject()
local trophyObj		= getTrophyObject()

local TROPHY_RENOWNED_HERO=00					
local TROPHY_BEAST_TAMER=01	
local TROPHY_ARMED_AND_READY=02				
local TROPHY_KNOWLEDGEABLE_HERO=03
local TROPHY_OGRE_SLAYER=04					
local TROPHY_BULL_SLAYER=05					
local TROPHY_GOD_RAISER=06					
local TROPHY_MASTER_ENGINEER=07					
local TROPHY_INSPIRING_LEADER=08					
local TROPHY_MASTER_CRAFTSMAN=09					
local TROPHY_LEGENDARY_HERO=10
local TROPHY_MASTER_OF_DEATH=11

local pCharacterManager = nil		--Need to get this once program has allocated it.
local pHeroBlock = 0				--This will be assigned when game starts or when
									-- player switches characters

--
-- This is an offset from the start of Game Data (pointed to by the Character Manager)
--
local oEnemyBlockOffset = 0xA8

--
-- These are offsets from the start of the Hero Block of data
--
local oLevelOffset = 0x54				--Player Level
local oItemTableOffset = 0xe0
local oOpponentTableOffset = 0x100
local oCompanionTableOffset = 0x160
local oBuildingTableOffset = 0x190

local bNewItemForged = false				
				
--print "_NOTE: Starting PUZZLE QUEST US"
	
local SaveData = emuObj.LoadConfig(0)

local vsync_timer=0



if not next(SaveData) then
	SaveData.t  = {}
end




function initsaves()
	local x = 0
		for x = 0, 12 do
			if SaveData.t[x] == nil then
				SaveData.t[x] = 0
				emuObj.SaveConfig(0, SaveData)
			end
		end
	end


--[[  getCharacterMgr()
	   All data we need to examine is referenced relative to the Character Manager.
	   AFIAK, it never changes once it is allocated.  We grab it the first time we
	   need it and it stays set after that.
--]]
function getCharacterMgr()
	if (pCharacterManager == nil) then
		local gp = eeObj.GetGpr(gpr.gp)
		pCharacterManager = eeObj.ReadMem32(gp+0x8c6c-0x10000)
		--print (string.format("_NOTE: Setting Char Mgr to %x", pCharacterManager))
	end
	return pCharacterManager
end


--[[ ********************************  TEST FUNCTIONS
     ********************************
     ********************************  The following 4 functions contain cheats which
     ********************************  enable the player to quickly win any of the
     ********************************  following types of battles...
     ********************************
     ********************************  1) Normal combat against an enemy 
     ********************************  2) A Capture battle 
     ********************************  3) A Spell battle 
     ********************************  4) A Forging an Item from Runes battle 
     ********************************
     ********************************  The hooks for these functions should be disabled for release.
     ********************************
     ********************************  For a cheat to take effect, press L1 and L2 simultaneously after
     ********************************  electing to start the battle.
     
--]]

--[==[
--[[  TEST FUNCTION 1
	  When a battle starts, immediately drain the enemy of all life
--]]	 
function TEST_Win_Normal_Battle()
	local pad = emuObj.GetPad()
	if (pad & 0x500 == 0x500) then
		local pGameData = eeObj.ReadMem32(getCharacterMgr())
		local pEnemyBlock = eeObj.ReadMem32(pGameData+oEnemyBlockOffset)
		if (pEnemyBlock < 0x1000000) then
			--print (string.format("_NOTE: clearing enemy life at %x", pEnemyBlock+0x5c))
			eeObj.WriteMem32(pEnemyBlock + 0x5c, 0)
		end
	end
end
	

--[[  TEST FUNCTION 2
	  When a capture game, reshape the grid for an easy win
--]]	 
function TEST_Win_Capture_Game()
	local pad = emuObj.GetPad()
	if (pad & 0x500 == 0x500) then
		local gp = eeObj.GetGpr(gpr.gp)
		local pGridStart = eeObj.ReadMem32(gp+0x98fc-0x10000)
		--print (string.format("_NOTE: TEST_Win_Capture_Game, start of grid= %x", pGridStart))
	
		for column = 1, 8, 1 do
			for next = 0, 8, 1 do
				eeObj.WriteMem32(pGridStart, 0)
				pGridStart = pGridStart + 8
			end
		end
		eeObj.WriteMem32(pGridStart - 8, 3)
		eeObj.WriteMem32(pGridStart - 0x50, 3)
		eeObj.WriteMem32(pGridStart - 0xE0, 3)	
	end
end

	
--[[  TEST FUNCTION 3
	  When a spell game, ensure all targets are met
--]]
function TEST_Win_Spell_Game()
	local pad = emuObj.GetPad()
	if (pad & 0x500 == 0x500) then
		local pTarget = eeObj.GetGpr(gpr.v1)
		local pAmount = eeObj.GetGpr(gpr.v0)
		--print (string.format("_NOTE: TEST_Win_Spell_Game, table start = %x %x", pTarget, pAmount))
		for next = 1, 5, 1 do
			local targ = eeObj.ReadMem32(pTarget)
			eeObj.WriteMem32(pAmount, targ)
			pTarget = pTarget + 4
			pAmount = pAmount + 4
		end
	end
end	
	
--[[  TEST FUNCTION 4
	  When forging an item, ensure an easy victory by placing Hammers and Anvils
--]]
function TEST_Win_Item_Game()	
	local pad = emuObj.GetPad()
	if (pad & 0x500 == 0x500) then
		local gp = eeObj.GetGpr(gpr.gp)
		local pGridStart = eeObj.ReadMem32(gp+0x98fc-0x10000)
		--print (string.format("_NOTE: TEST_Win_Item_Game, start of grid= %x", pGridStart))
		eeObj.WriteMem32(pGridStart+8, 17)
		eeObj.WriteMem32(pGridStart+16, 17)
		eeObj.WriteMem32(pGridStart+24, 6)	
		eeObj.WriteMem32(pGridStart+32, 17)
		eeObj.WriteMem32(pGridStart+40, 17)
		eeObj.WriteMem32(pGridStart+24+0x48, 17)	
	end
end	
	
--    TEST FUNCTION HOOKS --   Disable for release
	
local hook_t1 = eeObj.AddHook(0x1838e8, 0x7fb20060, TEST_Win_Normal_Battle)
local hook_t2 = eeObj.AddHook(0x12e1f4, 0x3c020032, TEST_Win_Item_Game)
local hook_t3 = eeObj.AddHook(0x154570, 0x52880, TEST_Win_Spell_Game)
local hook_t4 = eeObj.AddHook(0x1693a0, 0x7bb703f0, TEST_Win_Capture_Game)
]==]



--[[  HERO_SELECTED()
		Much of the data we need to examine is in a block of data related to the Hero (player).  
		The pointer	to the Hero block is grabbed from register S2 during the SetHero function.
		This happens upon the start of every game, and whenever the player switches characters.
--]]
function HERO_SELECTED()
	pHeroBlock = eeObj.GetGpr(gpr.s2)	
	--print (string.format("_NOTE: Hero Block is at %x", pHeroBlock))	
end

function getHeroBlock()
	return pHeroBlock
end	
		


--[[  TROPHY_RENOWNED_HERO         00

		ENEMY_TABLE_UPDATED()

		This function is called when the Opponent Table is written into. This can happen after a victory or defeat,
		but here we will just compute how many opponents the player has defeated at least once.
		
		The trophy will be awarded when 5 enemies have been defeated.
		
--]]
function ENEMY_TABLE_UPDATED()
	--print ("_NOTE: Entering ENEMY_TABLE_UPDATED()")
	local trophy_id = TROPHY_RENOWNED_HERO
	initsaves()
	if SaveData.t[trophy_id] ~= 1 then
		--
		--  compute the start and end of the Opponent table
		--
		local pStartOfOppTable = getHeroBlock()  + oOpponentTableOffset
		local startOfOppTable = eeObj.ReadMem32(pStartOfOppTable)
		local endOfOppTable = eeObj.ReadMem32(pStartOfOppTable + 4) -4
		--
		--  iterate through table and count number of enemies defeated at least once
		--
		local enemiesDefeated = 0
	    for next = startOfOppTable, endOfOppTable, 8 do
	    	local oppCode = eeObj.ReadMem32(next)
	    	local numBattles = eeObj.ReadMem16(next+4)
	    	local numVictories = eeObj.ReadMem16(next+6)
			--[[
			     turn id code into string for testing only
			--
			local c1 = oppCode & 0xff
			local c2 = (oppCode >> 8) & 0xff
			local c3 = (oppCode >> 16) & 0xff
			local c4 = oppCode >> 24
			print (string.format("_NOTE Opponent %s  Fought %d, Won %d", 
				string.char(c1,c2,c3,c4), numBattles, numVictories))
			--[[
			     end of test code
			--]]	
			if (numVictories > 0) then
				enemiesDefeated = enemiesDefeated+1	
			end
		end
		--
		--  Award trophy if at least 5 enemies have been defeated
		--
		if (enemiesDefeated >= 5) then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(0, SaveData)			
       	    --print (string.format("TROPHY_NOTE 00 RENOWNED HERO Awarded! (%d enemies defeated)", enemiesDefeated))
		end	
	end
end
		
		
--[[   TROPHY_BEAST_TAMER		01

		MOUNT_CAPTURED()

		This function is called when a new Mount record is written after capturing a mount.
		
		Reaching this code means you have captured a mount, so the trophy can be awarded.
		
--]]
function MOUNT_CAPTURED()
	--print ("_NOTE: Entering MOUNT_CAPTURED()")
	local trophy_id = TROPHY_BEAST_TAMER
	initsaves()
	if SaveData.t[trophy_id] ~= 1 then
		SaveData.t[trophy_id] = 1
		trophyObj.Unlock(trophy_id)
		emuObj.SaveConfig(0, SaveData)			
   		--print "TROPHY_NOTE 01 BEAST TAMER Awarded!"
	end
end	
		

				
				
--[[   TROPHY_KNOWLEDGEABLE_HERO		03

		SPELL_RESEARCH_VICTORY()

		This function is called when the player wins a Research Spell mini-game.
		
		Reaching this code means you have successfully researched the spell, so the trophy can be awarded.
		
--]]
function SPELL_RESEARCH_VICTORY()
	--print ("_NOTE: Entering SPELL_RESEARCH_VICTORY()")
	local trophy_id = TROPHY_KNOWLEDGEABLE_HERO
	initsaves()
	if SaveData.t[trophy_id] ~= 1 then
		SaveData.t[trophy_id] = 1
		trophyObj.Unlock(trophy_id)
		emuObj.SaveConfig(0, SaveData)			
   		--print "TROPHY_NOTE 03 KNOWLEDGEABLE HERO Awarded!"
	end
end	
		
		
--[[ 	TROPHY_OGRE_SLAYER		04 
		TROPHY_BULL_SLAYER		05
		TROPHY_MASTER_OF_DEATH	11
		
			ENEMY_BATTLE_OVER()  

			This function is called when a battle with an Opponent is over.
			First we check to see if it ended in a victory for the player or not.  If so,
			we check who the opponent was. 
		
			A trophy is awarded for defeating these particular enemies. Each enemy is identified
			by a 4-letter code stored in the enemy block of data.
		
			Trophy 04	Dugog      MDGG   0x4747444D
			Trophy 05	Mechataur  MMCH	  0x48434D4D
			Trophy 11	Lord Bane  MBAN	  0x4E41424D
				
--]]
function ENEMY_BATTLE_OVER()
	--print ("_NOTE: Entering ENEMY_BATTLE_OVER()")
	initsaves()	
	--
	-- First check to see who won
	--
	local pGameData = eeObj.ReadMem32(getCharacterMgr())
	--print (string.format("_NOTE: CharMgr = %x, GameData = %x", pCharacterManager, pGameData))
	local whoWon = eeObj.ReadMem8(pGameData+0x12)
	--print (string.format("_NOTE whoWon = %d", whoWon))
	--
	-- if Player won, see who the enemy was
	--
	if (whoWon == 1) then
		--
		-- Get ID code of enemy that was just defeated
		--
		local pEnemyBlock = eeObj.ReadMem32(pGameData+oEnemyBlockOffset)
		--print (string.format("_NOTE: EnemyBlock = %x", pEnemyBlock))
		local oppCode = eeObj.ReadMem32(pEnemyBlock)
		--[[
		     turn id code into string for testing only
		--
		local c1 = oppCode & 0xff
		local c2 = (oppCode >> 8) & 0xff
		local c3 = (oppCode >> 16) & 0xff
		local c4 = oppCode >> 24
		print (string.format("_NOTE Opponent %s Defeated!", string.char(c1,c2,c3,c4)))
		--[[
		      set trophy_id based on enemy defeated
		--]]
		local trophy_id  = -1
		if (oppCode == 0x4747444d) then			-- Dugog's code is MDGG
			trophy_id = TROPHY_OGRE_SLAYER 
		else 
			if (oppCode == 0x48434D4D) then		-- Mechataur's code is MMCH
				trophy_id = TROPHY_BULL_SLAYER
			else
				if (oppCode == 0x4E41424D) then	-- Lord Bane's code is MBAN	
					trophy_id =  TROPHY_MASTER_OF_DEATH
				end
			end
		end
		--[[
			  issue trophy if one of the 3 specific enemies were defeated
		--]]
		if (trophy_id >= 0) then
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
	       	    --print (string.format("TROPHY_NOTE %d Awarded!", trophy_id))
	       	end
	    end
	end	
end

	
	
--[[   TROPHY_ARMED_AND_READY	02
	   TROPHY_GOD_RAISER     	06

		QUEST_COMPLETED() 

		This function is called when the player completes any quest.  The id code 
		of the quest just completed is in register A1.
		
		Advanced combat training has an ID of Q0T2  ( 0x32543051 ).
		Trophy 02 is awarded if we find that code in A1.
		
		The last quest in the rebuilding of Sartek has an ID of Q2Q9 ( 0x39513251).
		Trophy 06 is awarded if we find that code in A1.
		
--]]
function QUEST_COMPLETED()
	--print ("_NOTE: Entering QUEST_COMPLETED()")
	--
	-- Get the id of the quest just completed.
	--
	local questID = eeObj.GetGpr(gpr.a1)	
	--[[
	     turn id code into string for testing only
	--
	local c1 = questID & 0xff
	local c2 = (questID >> 8) & 0xff
	local c3 = (questID >> 16) & 0xff
	local c4 = questID >> 24
	print (string.format("_NOTE: The quest just completed is %s", string.char(c1,c2,c3,c4)))
	--[[
	     end of test code
	--]]	
	local trophy_id  = -1
	if (questID == 0x32543051) then        -- "Q0T2"
		trophy_id =  TROPHY_ARMED_AND_READY
	else 
		if (questID == 0x39513251) then        -- "Q2Q9"
			trophy_id =  TROPHY_GOD_RAISER
		end
	end

	if (trophy_id >= 0) then
		initsaves()
		if SaveData.t[trophy_id] ~= 1 then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(0, SaveData)			
       	    --print (string.format("TROPHY_NOTE %d Awarded!", trophy_id))
       	end
    end
end

		


--[[  TROPHY_MASTER_ENGINEER     07

 		BUILDING_ADDED() 

		This function is called when the Building Table is written into.
		
		The buildings of the citadel are indicated by consecutive bytes which = 1.  
		There are 9 parts to the citadel.  When all 9 bytes in the building
		table equal 1, the trophy will be awarded.
		
--]]
function BUILDING_ADDED()
	--print ("_NOTE: Entering BUILDING_ADDED()")
	local trophy_id = TROPHY_MASTER_ENGINEER
	initsaves()
	if SaveData.t[trophy_id] ~= 1 then
		--
		-- compute start of Building table
		--
		local pStartOfBldgTable = getHeroBlock()  + oBuildingTableOffset
		--
		--  Read the first 2 words of the building table. Together, these represent 8 of the 9
		--  buildings.  If all 8 of these buildings have been added, their sum should be 0x02020202 
		--
		local word1 = eeObj.ReadMem32(pStartOfBldgTable) + eeObj.ReadMem32(pStartOfBldgTable+4)
		--print (string.format("_NOTE: W = %x", word1))
		if (word1 == 0x02020202) then
			--
			--  If the first 8 parts of the building have been added, we only need to check
			--  the last byte in the table.  If it is 1, we award the trophy.
			--
			local byte1 = eeObj.ReadMem8(pStartOfBldgTable+8)
			--print (string.format("_NOTE: B = %d", byte1))
			if (byte1 == 1) then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
   	    		--print "TROPHY_NOTE 07 MASTER ENGINEER Awarded!"
   	    	end
   	   	end
	end
end	

--[[ TROPHY_INSPIRING_LEADER   08a
	
   		COMPANION_TABLE_UPDATED()  

		This function is called when the Companion Table is written into.
		It is one of two situations when we need to check if this trophy should be awarded.
		See CheckCompanions for more info.
		
--]]
function COMPANION_TABLE_UPDATED()
	--print ("_NOTE: Entering COMPANION_TABLE_UPDATED()")
	CheckCompanions()
end

--[[ TROPHY_INSPIRING_LEADER   08b
	
   		COMPANION_ADDED()  

		This function is called when a Companion is added to your party thru the Inventory.
		It is one of two situations when we need to check if this trophy should be awarded.
		See CheckCompanions for more info.
		
--]]
function COMPANION_ADDED()
	--print ("_NOTE: Entering COMPANION_ADDED()")
	CheckCompanions()
end


--[[   CheckCompanions()

		Trophy 08,  TROPHY_INSPIRING_LEADER is awarded when the player has 5 companions
		travelling with him or her.
		
		There are two ways this might happen.  If you have 4 companions who are all travelling
		with you and you gain another, the trophy should be awarded.  
		But if you had 4 companions and not all were travelling	with you, then the trophy would
		not be awarded.  However, if the player went to the Inventory screen and added
		a fifth companion, the trophy would then be awarded.  So there are two ways to get here.
		
		This function checks the companion table and counts how many companions are travelling
		with the player.
--]]


function CheckCompanions()
	--print ("_NOTE: Entering CheckCompanions()")
	local trophy_id = TROPHY_INSPIRING_LEADER
	initsaves()
	if SaveData.t[trophy_id] ~= 1 then
		--
		-- compute the start and end of the companion table
		--
		local pStartOfCompTable = getHeroBlock()  + oCompanionTableOffset
		local startOfCompTable = eeObj.ReadMem32(pStartOfCompTable)
		local endOfCompTable = eeObj.ReadMem32(pStartOfCompTable + 4) -4
		--
		--   Iterate through the Companion Table
		--
		local numCompanions = 0
	    for next = startOfCompTable, endOfCompTable, 8 do
	    	--
	    	-- The first word of the companion table (+0) is the 4 letter id of that companion.
	    	-- The next half word (+4) is the number of times that companion has been added.
	    	-- The next half word (+6) is either 0 or 1 indicating whether that companion is
	    	-- currently travelling with the player.
	    	--
	    	numCompanions = numCompanions + eeObj.ReadMem16(next+6)
		end	    	
		--print (string.format("_NOTE: num companions = %d", numCompanions))
		--
		-- If at least 5 companions, award the trophy.
		--
		if (numCompanions >= 5) then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(0, SaveData)			
   	    	--print "TROPHY_NOTE 08 INSPIRING LEADER Awarded!"
   	   	end
	end
end	

		
--[[   ItemForged     Helper function for Trophy 09

	Called when an item is forged.  Sets a flag for ITEM_TABLE_UPDATED
--]]
function ItemForged()
	--print ("_NOTE: Entering ItemForged()")
	bNewItemForged = true
end


--[[  TROPHY_MASTER_CRAFTSMAN    09

		ITEM_TABLE_UPDATED() 

		This function is called when the Item Table is written into.  The only time we are
		interested in this is after an item is forged. A flag is set in a helper function to
		allow us to distinguish between a forged item being added and any other item.
		
		The trophy is to be awarded if a Godlike item is forged.  Forged items come from 3 Runes,
		and are identified by the code  Jxyz  where x, y, and z are hex digits representing the ids
		of the runes that were combined to create the item.   
		
		In an item forged from the God rune, y will be 9.
		
--]]
function ITEM_TABLE_UPDATED()
	--print ("_NOTE: Entering ITEM_TABLE_UPDATED()")
	--
	-- Don't bother continuing if we didn't just forge a new item
	--
	if (bNewItemForged == true) then
		initsaves()	
		local trophy_id = TROPHY_MASTER_CRAFTSMAN
		if SaveData.t[trophy_id] ~= 1 then
			--[[
				 	Scan the item table for items with ids in the form Jxyz.
					If y==9, that represents a God-like item.
					
					First, compute the start and end of the Item Table.
					Note that at this breakpoint, the game has NOT updated
					the end of the Item table to reflect the newly added item.
			--]]
			local pStartOfItemTable = getHeroBlock()  + oItemTableOffset
			local startOfItemTable = eeObj.ReadMem32(pStartOfItemTable)
			local endOfItemTable = eeObj.ReadMem32(pStartOfItemTable + 4)
			--
			--   Iterate through the Item Table
			--
		    for next = startOfItemTable, endOfItemTable, 8 do
		    	--
		    	--  read the first character of this item's id code. 
		    	--
				local byte0 = eeObj.ReadMem8(next)
				--print (string.format("_NOTE: item id starts with %x", byte0))
				--
				--  if the first character is 'J', continue, otherwise ignore
				--
				if (byte0 == 0x4a) then	
					--
					--  read the middle of the 3 digits in the code.
					--
					local byte2 = eeObj.ReadMem8(next+2)
					--print (string.format("_NOTE: middle digit is %x", byte2))
					--
					--  If the middle digit is '9', then we award the trophy
					--
					if (byte2 == 0x39) then
						SaveData.t[trophy_id] = 1
						trophyObj.Unlock(trophy_id)
						emuObj.SaveConfig(0, SaveData)			
	    	   	    	--print "TROPHY_NOTE 09 MASTER CRAFTSMAN Awarded!"
	    	   	    end
	    	   	end
	       	end
		end			
	end
	bNewItemForged = false		-- reset flag for next time
end



--[[   TROPHY_LEGENDARY_HERO     10

		LEVEL_CHANGE() 

		This function is called when the player's level is incremented.
		The trophy is awarded when level 50 is reached.
		
--]]
function LEVEL_CHANGE()
	--print ("_NOTE: Entering LEVEL_CHANGE()")
	local trophy_id =  TROPHY_LEGENDARY_HERO
	initsaves()	
	if SaveData.t[trophy_id] ~= 1 then
		--
		-- Read the player's new level
		--
		local pLevel = getHeroBlock() + oLevelOffset
		local newLevel = eeObj.ReadMem32(pLevel)	
		--print (string.format("_NOTE: The new level is %d", newLevel))
		--
		--  if new level is >= 50, award the trophy.
		--
		if (newLevel >= 50) then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(0, SaveData)			
       	    --print "TROPHY_NOTE 10 LEGENDARY HERO Awarded!"
       	end
    end
end
	
	
	

local hook_00 = eeObj.AddHook(0x164988, 0x27bdffa0, ENEMY_TABLE_UPDATED) -- called when the enemy table is written to
local hook_01 = eeObj.AddHook(0x18c128, 0x7fb000a0, MOUNT_CAPTURED) -- called when a mount is captured
local hook_03 = eeObj.AddHook(0x152e2c, 0x3c02002f, SPELL_RESEARCH_VICTORY) -- called when victory is achieved in a spell mini-game
local hook_04_05_11 = eeObj.AddHook(0x164908, 0x8d2300ac, ENEMY_BATTLE_OVER) -- called when a battle with an enemy ends
local hook_02_06 = eeObj.AddHook(0x1930fc, 0x7fb00030, QUEST_COMPLETED) -- called when a quest is completed
local hook_07 = eeObj.AddHook(0x105d3c, 0x3c02002c, BUILDING_ADDED) -- called when a building is added to the citadel
local hook_08a = eeObj.AddHook(0x18ce28, 0x7bb10080, COMPANION_TABLE_UPDATED) -- called when a companion is added
local hook_08b = eeObj.AddHook(0x10924c, 0x3c02002f, COMPANION_ADDED) -- called when a companion is added to your party
local hook_09h = eeObj.AddHook(0x12c970, 0x27bdff90, ItemForged) -- Helper function - called when an item is forged
local hook_09 = eeObj.AddHook(0x18b224, 0x24420008, ITEM_TABLE_UPDATED) -- called when an item is added
local hook_10 = eeObj.AddHook(0x189860, 0xa21100a8, LEVEL_CHANGE) -- called when player's level is incremented
local hero = eeObj.AddHook(0x151dd8, 0x7bb00030, HERO_SELECTED) -- called when a hero is selected




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