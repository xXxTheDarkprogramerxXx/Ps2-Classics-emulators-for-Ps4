-- Lua 5.3
-- Title: Okage™ Shadow King PS2 - SCUS-97129 (USA) v1.01
-- Title: Okage™ Shadow King PS2 - SCPS-11008 (Japan) v1.02
-- Trophies version: 1.06
-- Author: David Haywood
-- Date: August 03, 2015



--[[ 
    Changelog:
    June 19, 2015 - Initial submission
    June 21, 2015 - allow Mega Charm execution from menu outside of battles to count
                  - made Raging Devil trophy trigger when raging devil is executed rather than when question is answered
				    (was causing some false positives)
				  - fixed bad logic on ForScience trophy

	June 28, 2015 - Preliminary port to Japan version
	June 29, 2015 - simplified ForScience trophy again, wasn't very compatible with Japan version'
	July 13, 2015 - added missing Adjusted_RMStr
	August 02, 2015 - Fixed FeelingLucky and false positive boss triggers
	October 09, 2015 - Move Award function

--]]


-- set to 0 for SCUS-97129 (USA), set to 1 for SCPS-11008 (Japan)
local JapanRegion = 0

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])



apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.



-- obtain necessary objects.
local eeObj			= getEEObject()
local emuObj		= getEmuObject()
local trophyObj		= getTrophyObject()
local dmaObj		= getDmaObject()

-- load configuration if exist
local SaveData		= emuObj.LoadConfig(0)




--[[###################################################################################################################
#######################################################################################################################

  Adjusted Memory Read/Write operations

  The Japanese version has mostly the same RAM structures for character details, event details, battle details etc.
  but they're all shifted, these functions allow us to share common code.

###################################################################################################################--]]


local AdjustForRegion = 0

if JapanRegion == 1 then
	AdjustForRegion = -0x6800
end

function Adjusted_WM32(base, data)
	eeObj.WriteMem32(base + AdjustForRegion, data)
end

function Adjusted_WM16(base, data)
	eeObj.WriteMem16(base + AdjustForRegion, data)
end

function Adjusted_WM8(base, data)
	eeObj.WriteMem8(base + AdjustForRegion, data)
end

function Adjusted_RM32(base)
	return eeObj.ReadMem32(base + AdjustForRegion)
end

function Adjusted_RM16(base)
	return eeObj.ReadMem16(base + AdjustForRegion)
end

function Adjusted_RM8(base)
	return eeObj.ReadMem8(base + AdjustForRegion)
end

function Adjusted_RMStr(base)
	return eeObj.ReadMemStr(base + AdjustForRegion)
end

--[[###################################################################################################################
#######################################################################################################################

  Generic Helper Functions

###################################################################################################################--]]

function InitSave(savetext)
	if SaveData[savetext] == nil then
		SaveData[savetext] = 0
		emuObj.SaveConfig(0, SaveData)
	end
end

--[[###################################################################################################################
#######################################################################################################################

  Generic Award Function

###################################################################################################################--]]


function AwardTrophy(trophynum, savetext)
	local trophy_id = trophynum
	print( string.format("############################## AWARDING trophy_id=%d (%s) #########################", trophy_id, savetext) )
	trophyObj.Unlock(trophy_id)		 
	SaveData[savetext] = 1
	emuObj.SaveConfig(0, SaveData)

end


--[[###################################################################################################################
#######################################################################################################################

Type: Silver (Hidden)
Game: Okage™ Shadow King PS2
Number: 18
Name: Feeling Lucky?
Description: Acquire the Q of Hearts weapon.
Hint: Dropped by Masterless Sword enemies. One place where these are guaranteed to appear is during the Gear Tower boss fight.

Type: Bronze (Hidden)
Game: Okage™ Shadow King PS2
Number: 7
Name: Hopkins' Legacy
Description: Acquire the Forgotten Sword.
Hint: The Forgotten Sword is located in a chest inside the World Library. The Amethyst key is required to access it.

Type: Bronze
Game: Okage™ Shadow King PS2
Number: 10
Name: Message in a Bottle
Decruption: Acquire the Hand Knit Cap from the Sickly Pretty Girl.
Hint: Reward for completing the message in a bottle side quest. The quest begins by receiving the Letter Bottle from the lighthouse in Rashelo and bringing it to the just north of the circus in Rumille Plains.

Type: Silver (Hidden)
Game: Okage™ Shadow King PS2
Number: 25
Name: Mythical Rarity
Description: Obtain the Unicorn's Horn.
Hint: This accessory is received from Ari's Father in exchange for the Broken Gun.

Type: Silver
Game: Okage™ Shadow King PS2
Number: 20
Name: What Does This Say?
Description: Complete the Cyphertext quest.
Hint: Received after turning in Cyphertext 6 in Tenel Church.

###################################################################################################################--]]

InitSave("FeelingLucky")
InitSave("HopkinsLegacy")
InitSave("MessageInABottle")
InitSave("MythicalRarity")
InitSave("WhatDoesThisSay")


local QofHeartsTrophy = function()
	if SaveData["FeelingLucky"] ~= 1 then
		local Count = Adjusted_RM8(0x5C1b0a) -- Q of Hearts

		if Count > 0 then
			AwardTrophy(18, "FeelingLucky")
		end
	end
end

local ForgottenTrophy = function()
	if SaveData["HopkinsLegacy"] ~= 1 then
		local Count = Adjusted_RM8(0x5C1Aeb) -- Forgotten Sword

		if Count > 0 then
			AwardTrophy(7,  "HopkinsLegacy")
		end
	end
end

local HandKnitCapTrophy = function()
	if SaveData["MessageInABottle"] ~= 1 then
		local Count = Adjusted_RM8(0x5C1b59)  -- Hand Knit Cap

		if Count > 0 then
			AwardTrophy(10, "MessageInABottle")
		end
	end
end

local UnicornTrophy = function()
	if SaveData["MythicalRarity"] ~= 1 then
		local Count = Adjusted_RM8(0x5C1b46) -- Unicorns Horn

		if Count > 0 then
			AwardTrophy(25, "MythicalRarity")
		end
	end
end

local Cypher6Trophy = function()
	if SaveData["WhatDoesThisSay"] ~= 1 then
		local Count = Adjusted_RM8(0x5C1b4f) -- Divine Shoes

		if Count > 0 then
			AwardTrophy(20, "WhatDoesThisSay")
		end
	end
end

QofHeartsHook = emuObj.AddVsyncHook(QofHeartsTrophy)
ForgottenHook = emuObj.AddVsyncHook(ForgottenTrophy)
HandKnitCapHook = emuObj.AddVsyncHook(HandKnitCapTrophy)
UnicornHook = emuObj.AddVsyncHook(UnicornTrophy)
Cypher6Hook = emuObj.AddVsyncHook(Cypher6Trophy)

--[[###################################################################################################################
#######################################################################################################################

Type: Gold
Game: Okage™ Shadow King PS2
Number: 29
Name: All Accounted For
Description: Collect 30 Tiny Gears.
Hint: Tiny Gears are picked up throughout the game. There are 32 total.

Extra: While there are 32 gears in the game you only need to collect 30 in order to exchange them for a special
       item, therefore we make the collection requiement 30, not 32 as otherwise it could become impossible to
	   obtain in a playthrough if the gears are exchanged when you have 30.

###################################################################################################################--]]

InitSave("AllAccounted")

local TinyGearTrophy = function()
	if SaveData["AllAccounted"] ~= 1 then
		local Count = Adjusted_RM8(0x5C1Ac5)

		if Count >= 30 then
			AwardTrophy(29, "AllAccounted")
		end
	end
end

TinyGearHook = emuObj.AddVsyncHook(TinyGearTrophy)


--[[###################################################################################################################
#######################################################################################################################

Type: Silver
Game: Okage™ Shadow King PS2
Number: 21
Name: Expensive Taste
Description: Purchase a piece of armor for over 100,000 sukel.
Hint: The Conjurer Tux can be purchased from the Pospos Spa merchant for 100,000. The Natural Outfit can be purchased from the Highland Village shop for 145,000.

Type: Silver
Game: Okage™ Shadow King PS2
Number: 22
Name: Top of the Line
Description: Purchase a weapon for over 100,000 sukel.
Hint: The K of Clubs can be purchased at the Rashelo shop for 150,000. There are several weapons at the Highland Village shop costing over 100,000 as well.

###################################################################################################################--]]

InitSave("ExpensiveTaste")
InitSave("TopOfTheLine")

-- Natural Outfit (DFNS +12)  Highland Shop 145000 sukel
-- Basics Only Coat (DFNS +18)  Highland Shop 130000 sukel
-- Conjurer Tux (DFNS +12) Pospos Spa 100000 sukel

local ExpensiveArmorTrophy = function()
	if SaveData["ExpensiveTaste"] ~= 1 then
		local Count1 = Adjusted_RM8(0x5C1b14)
		local Count2 = Adjusted_RM8(0x5C1b24)
		local Count3 = Adjusted_RM8(0x5C1b35)
	
		if Count1 > 0 or Count2 > 0 or Count3 > 0 then
			AwardTrophy(21, "ExpensiveTaste")
		end
	end
end

-- Mastermold Sword (ATK +35) Highland Shop 145000 sukel
-- WhiteRose Rapier (ATK +30) Highland Shop 177000 sukel
-- Ghostosystem II (ATK +30)  Highland Shop 130000 sukel
-- K of Clubs (ATK +20) Rashelo Shop 150000 sukel

local ExpensiveWeaponTrophy = function()
	if SaveData["TopOfTheLine"] ~= 1 then
		local Count1 = Adjusted_RM8(0x5C1Aea)
		local Count2 = Adjusted_RM8(0x5C1Af3)
		local Count3 = Adjusted_RM8(0x5C1Afb)
		local Count4 = Adjusted_RM8(0x5C1b0b)

		if Count1 > 0 or Count2 > 0 or Count3 > 0 or Count4 > 0 then
			AwardTrophy(22, "TopOfTheLine")
		end
	end
end

ExpensiveArmorHook = emuObj.AddVsyncHook(ExpensiveArmorTrophy)
ExpensiveWeaponHook = emuObj.AddVsyncHook(ExpensiveWeaponTrophy)

--[[###################################################################################################################
#######################################################################################################################

Type: Silver
Game: Okage™ Shadow King PS2
Number: 24
Name: A Wealthy Slave
Decription: Accrue 500,000 sukel.	

###################################################################################################################--]]

InitSave("WealthySlave")

local MoneyTrophy = function()
	if SaveData["WealthySlave"] ~= 1 then
		local Money = Adjusted_RM32(0x5c1b6c)

		if Money >= 500000 then
			AwardTrophy(24, "WealthySlave")
		end
	end
end

MoneyHook = emuObj.AddVsyncHook(MoneyTrophy)

--[[###################################################################################################################
#######################################################################################################################

Type: Bronze
Game: Okage™ Shadow King PS2
Number: 2
Name: Much-Needed Assistance
Description: Recruit two allies to join your party.	Kisling will be the second ally to join.

Type: Silver
Game: Okage™ Shadow King PS2
Number: 19
Name: Junior Varsity
Description: Reach level 30 with three characters.	

Type: Gold
Game: Okage™ Shadow King PS2
Number: 26
Name: Varsity
Description: Reach level 70 with three characters.	

Type: Memory Watch
Extra: these 3 depend on the party status flags in RAM, we can check which characters have been found, and based on
       that check the level of each character in the party.

###################################################################################################################--]]

InitSave("MuchNeeded")
InitSave("JuniorVarsity")
InitSave("Varsity")

-- 0x5c1bc0 for Ari
-- 0x5c1bc4 for ros
-- 0x5c1bc8 for kis
-- 0x5c1bcc for bigbull
-- 0x5c1bd0 for linda
-- 0x5c1bd4 for epros
-- value of 0x00000003 means in active party
-- value of 0x00000002 means available for selection
-- value of 0x00000000 means not discovered yet

local CheckNumberCharacters = function()

	local readBase = 0x5c1bc0
	local available = 0

	local NumberThirty = 0
	local NumberSeventy = 0

	for i = 0, 5, 1 do
		local CharacterAvailable = Adjusted_RM32(readBase)
		readBase = readBase + 4

		if CharacterAvailable ~= 0 then
			available = available + 1

		    local level = Adjusted_RM16((0x5c1c18)+(0x50*i))

			if level >= 30 then
				NumberThirty = NumberThirty + 1
			end

			if level >= 70 then
				NumberSeventy = NumberSeventy + 1
			end
		end
	end

	if available>=3 then
		if SaveData["MuchNeeded"] ~= 1 then
			--print( "*************************************************" )
			--print( "******************** Kisling Available **********" )
			--print( string.format("@@@@@@@#######@@@@@@@ available %d @@@@@@@#######@@@@@@@", available) )
			--print( string.format("@@@@@@@#######@@@@@@@ NumberThirty %d @@@@@@@#######@@@@@@@", NumberThirty) )
			--print( string.format("@@@@@@@#######@@@@@@@ NumberSeventy %d @@@@@@@#######@@@@@@@", NumberSeventy) )
			--print( "*************************************************" )
			AwardTrophy(2, "MuchNeeded")
		end
	end

	if NumberThirty >= 3 then
		if SaveData["JuniorVarsity"] ~= 1 then
			--print( "*************************************************" )
			--print( "******************** Three Over 30 **********" )
			--print( string.format("@@@@@@@#######@@@@@@@ available %d @@@@@@@#######@@@@@@@", available) )
			--print( string.format("@@@@@@@#######@@@@@@@ NumberThirty %d @@@@@@@#######@@@@@@@", NumberThirty) )
			--print( string.format("@@@@@@@#######@@@@@@@ NumberSeventy %d @@@@@@@#######@@@@@@@", NumberSeventy) )
			--print( "*************************************************" )
			AwardTrophy(19, "JuniorVarsity")
		end
	end

	if NumberSeventy >= 3 then
		if SaveData["Varsity"] ~= 1 then
			--print( "*************************************************" )
			--print( "******************** Three Over 70 **********" )
			--print( string.format("@@@@@@@#######@@@@@@@ available %d @@@@@@@#######@@@@@@@", available) )
			--print( string.format("@@@@@@@#######@@@@@@@ NumberThirty %d @@@@@@@#######@@@@@@@", NumberThirty) )
			--print( string.format("@@@@@@@#######@@@@@@@ NumberSeventy %d @@@@@@@#######@@@@@@@", NumberSeventy) )
			--print( "*************************************************" )
			AwardTrophy(26, "Varsity")
		end
	end
end

CharAvailableHook = emuObj.AddVsyncHook(CheckNumberCharacters)

--[[###################################################################################################################
#######################################################################################################################

Type: Bronze
Game: Okage™ Shadow King PS2
Number: 8
Name: Cat Scratch Fever
Description: Use a Black Cat Jewel in battle.
Hint: One way to receive a Black Cat Jewel can be acquired is by donating 10,000 to the Research Center. Soul Binding a 24K Screw can also yield a Black Cat Jewel.

Type: Bronze
Game: Okage™ Shadow King PS2
Number: 4
Name: Mega Relief
Description: Use a Mega Stone to cure all ailments.
Hint: A Mega Stone can be purchased in Triste for 400 sukel. They are also dropped by Soul Binding various enemies.

Type: Bronze
Game: Okage™ Shadow King PS2
Number: 5
Name: One Charm to Rule Them All
Description: Use a Mega Charm to cure all curses.
Hint: A Mega Charm can be purchased in Triste for 1,000 sukel. They are also dropped by Soul Binding various enemies.

Type: Bronze (Hidden)
Game: Okage™ Shadow King PS2
Number: 3
Name: Raging Devil
Description: Correctly answer Stan's questions for him to execute a bonus attack.
Hint: Stan will randomly appear before a battle and ask questions. Answering correctly results in Stan performing Raging Devil on enemies.

Type: Memory Watch (or Breakpoint trigger)
Extra: There are two approaches for these, one is to trigger when the item is selected from the menu, at which point
       it is removed from your inventory, however, that doesn't guarantee it will be used (even if the item is
	   always consumed)
	   The other approach is to watch for the specific item use animation sequence, which is what we do.
	   A Black Cat Jewel will have no effect on enemies with 1 health as it can't be halved.'
	   You can also use Mega Charm and Mega Stone(?) outside of battle.

###################################################################################################################--]]

InitSave("CatScratch")
InitSave("MegaRelief")
InitSave("OneCharm")
InitSave("RagingDevil")


--[[
This alternate method of implementing the trophy relies on checking the string of the currently executing
Item / Spell.  This ensures that the Black Cat Jewel or Mega Charm are actually executed, although see
above note about the game allowing you to use one of the items without it taking effect due to the battle
ending.

--]]

-- could use GetMemStr here

local ItemExecutingNameCheckTest = function()
	if SaveData["CatScratch"] ~= 1 then
		if Adjusted_RM8(0x089a391) == 0x42 and
		   Adjusted_RM8(0x089a392) == 0x6c and
		   Adjusted_RM8(0x089a393) == 0x61 and
		   Adjusted_RM8(0x089a394) == 0x63 and
		   Adjusted_RM8(0x089a395) == 0x6b and
		   Adjusted_RM8(0x089a396) == 0x20 and
		   Adjusted_RM8(0x089a397) == 0x43 and
		   Adjusted_RM8(0x089a398) == 0x61 and
		   Adjusted_RM8(0x089a399) == 0x74 then
	
			--print( "*************************************************" )
			--print( "*** Black Cat being Executed ********************" )
			--print( "*************************************************" )
			AwardTrophy(8, "CatScratch")
		end
	end

	if SaveData["OneCharm"] ~= 1 then
		if Adjusted_RM8(0x089a391) == 0x4D and
		   Adjusted_RM8(0x089a392) == 0x65 and
		   Adjusted_RM8(0x089a393) == 0x67 and
		   Adjusted_RM8(0x089a394) == 0x61 and
		   Adjusted_RM8(0x089a395) == 0x20 and
		   Adjusted_RM8(0x089a396) == 0x43 and
		   Adjusted_RM8(0x089a397) == 0x68 and
		   Adjusted_RM8(0x089a398) == 0x61 and
		   Adjusted_RM8(0x089a399) == 0x72 then
	
			--print( "*************************************************" )
			--print( "*** Mega Charm being Executed *******************" )
			--print( "*************************************************" )
			AwardTrophy(5, "OneCharm")
		end
	end

	if SaveData["MegaRelief"] ~= 1 then
		if Adjusted_RM8(0x089a391) == 0x4D and
		   Adjusted_RM8(0x089a392) == 0x65 and
		   Adjusted_RM8(0x089a393) == 0x67 and
		   Adjusted_RM8(0x089a394) == 0x61 and
		   Adjusted_RM8(0x089a395) == 0x20 and
		   Adjusted_RM8(0x089a396) == 0x53 and
		   Adjusted_RM8(0x089a397) == 0x74 and
		   Adjusted_RM8(0x089a398) == 0x6f and
		   Adjusted_RM8(0x089a399) == 0x6e then
	
			--print( "*************************************************" )
			--print( "*** Mega Stone being Executed *******************" )
			--print( "*************************************************" )
			AwardTrophy(4, "MegaRelief")
		end
	end

	if SaveData["RagingDevil"] ~= 1 then
		if Adjusted_RM8(0x089a391) == 0x52 and
		   Adjusted_RM8(0x089a392) == 0x61 and
		   Adjusted_RM8(0x089a393) == 0x67 and
		   Adjusted_RM8(0x089a394) == 0x69 and
		   Adjusted_RM8(0x089a395) == 0x6E and
		   Adjusted_RM8(0x089a396) == 0x67 and
		   Adjusted_RM8(0x089a397) == 0x20 and
		   Adjusted_RM8(0x089a398) == 0x44 and
		   Adjusted_RM8(0x089a399) == 0x65 then
	
			--print( "*************************************************" )
			--print( "*** RagingDevil being Executed *******************" )
			--print( "*************************************************" )
			AwardTrophy(3, "RagingDevil")
		end
	end

end



-- this also triggers when SELLING items, as well as being given items, so we check one of the menu structures as well
-- can't use Mega Stone outside of battle, so no need to check it?

local ItemCureMenuTest = function()
	local a0 = eeObj.GetGPR(gpr.a0)
	local s1 = eeObj.GetGPR(gpr.s1)

	local st1 = Adjusted_RMStr(0x08b301b)
	st2 = string.sub(st1, 1, 5);

	 print( "*** Mega Charm in cure menu *******************" )
	print( string.format("cure menu a0 %08x s1 %08x | %s", a0, s1, st1 ) )
	print( string.format("%s", st2 ) )


	-- subtracting one
	if s1 == 0xFFFFFFFF then
		-- mega charm
		if a0 == 0x5C1A72 then
			if SaveData["OneCharm"] ~= 1 then
				if st2 == 'Mega ' then
					print( "*************************************************" )
					print( "*** Mega Charm in cure menu *******************" )
					print( "*************************************************" )
					AwardTrophy(5, "OneCharm")
				end
			end
		end

		if SaveData["MegaRelief"] ~= 1 then
			if a0 == 0x5C1A77 then
				if st2 == 'Mega ' then
					print( "*************************************************" )
					print( "*** Mega Stone in cure menu *******************" )
					print( "*************************************************" )
					AwardTrophy(4, "MegaRelief")
				end
			end		
		end
	end
end



--[[
Japan version
009117c0 : 325b665c 837d835d 83588343 835b8167    \f[2] } C X g [ 
009117d0 : 0000008b 00000000 00000000 0000001a                    
009117e0 : 000000a1 00000054 00000000 00000000        T           
009117f0 : 00000060 0092226c 3f800000 3f800000    `   l"     ?   ?

--]]

          

local ItemExecutingNameCheckTestJapan = function()
	local temp0 = eeObj.ReadMem8(0x09117c5)
	local temp1 = eeObj.ReadMem8(0x09117c6)
	local temp2 = eeObj.ReadMem8(0x09117c7)
	local temp3 = eeObj.ReadMem8(0x09117c8)
	local temp4 = eeObj.ReadMem8(0x09117c9)
	local temp5 = eeObj.ReadMem8(0x09117ca)
	local temp6 = eeObj.ReadMem8(0x09117cb)
	local temp7 = eeObj.ReadMem8(0x09117cc)
	local temp8 = eeObj.ReadMem8(0x09117cd)
	local temp9 = eeObj.ReadMem8(0x09117ce)
	--print( string.format("%02x %02x %02x %02x %02x %02x %02x %02x %02x %02x", temp0, temp1, temp2, temp3,temp4,temp5,temp6,temp7,temp8,temp9 ) )         

	if SaveData["CatScratch"] ~= 1 then
	
		if temp0 == 0x8d and
		   temp1 == 0x95 and
		   temp2 == 0x94 and
		   temp3 == 0x4c and
		   temp4 == 0x82 and
		   temp5 == 0xcc and
		   temp6 == 0x91 then
	
			--print( "*************************************************" )
			--print( "*** Black Cat being Executed ********************" )
			--print( "*************************************************" )
			AwardTrophy(8, "CatScratch")
		end
	end

	if SaveData["OneCharm"] ~= 1 then

		if temp0 == 0x82 and
		   temp1 == 0xb7 and
		   temp2 == 0x82 and
		   temp3 == 0xb2 and
		   temp4 == 0x82 and
		   temp5 == 0xa2 and
		   temp6 == 0x82 and
		   temp7 == 0xa8 and
		   temp8 == 0x8e and
		   temp9 == 0x44 then

			--print( "*************************************************" )
			--print( "*** Mega Charm being Executed *******************" )
			--print( "*************************************************" )
			AwardTrophy(5, "OneCharm")
		end
	end

	if SaveData["MegaRelief"] ~= 1 then   

		if temp0 == 0x82 and
		   temp1 == 0xb7 and
		   temp2 == 0x82 and
		   temp3 == 0xb2 and
		   temp4 == 0x82 and
		   temp5 == 0xa2 and
		   temp6 == 0x90 and
		   temp7 == 0xce and
		   temp8 == 0x00 then
			
			--print( "*************************************************" )
			--print( "*** Mega Stone being Executed *******************" )
			--print( "*************************************************" )
			AwardTrophy(4, "MegaRelief")
		end
	end

	if SaveData["RagingDevil"] ~= 1 then

		if temp0 == 0x83 and
		   temp1 == 0x74 and
		   temp2 == 0x83 and
		   temp3 == 0x89 and
		   temp4 == 0x83 and
		   temp5 == 0x43 and
		   temp6 == 0x83 then
	
			--print( "*************************************************" )
			--print( "*** RagingDevil being Executed *******************" )
			--print( "*************************************************" )
			AwardTrophy(3, "RagingDevil")
		end
	end

end



-- this also triggers when SELLING items, as well as being given items, so we check one of the menu structures as well
-- can't use Mega Stone outside of battle, so no need to check it?

local ItemCureMenuTestJapan = function()
	local a0 = eeObj.GetGPR(gpr.a0)
	local s1 = eeObj.GetGPR(gpr.s1)

	local temp0 = eeObj.ReadMem8(0x0929d45)
	local temp1 = eeObj.ReadMem8(0x0929d46)
	local temp2 = eeObj.ReadMem8(0x0929d47)
	local temp3 = eeObj.ReadMem8(0x0929d48)
	local temp4 = eeObj.ReadMem8(0x0929d49)
	local temp5 = eeObj.ReadMem8(0x0929d4a)
	local temp6 = eeObj.ReadMem8(0x0929d4b)
	local temp7 = eeObj.ReadMem8(0x0929d4c)
	local temp8 = eeObj.ReadMem8(0x0929d4d)
	local temp9 = eeObj.ReadMem8(0x0929d4e)

	print( string.format("%02x %02x %02x %02x %02x %02x %02x %02x %02x %02x", temp0, temp1, temp2, temp3,temp4,temp5,temp6,temp7,temp8,temp9 ) )    

	-- subtracting one
	if s1 == 0xFFFFFFFF then
		-- mega charm
		if a0 == (0x5C1A72+AdjustForRegion) then
			if SaveData["OneCharm"] ~= 1 then
				if temp0 == 0x82 and
				   temp1 == 0xb7 and
				   temp2 == 0x82 and
				   temp3 == 0xb2 and
				   temp4 == 0x82 and
				   temp5 == 0xa2 and
				   temp6 == 0x82 and
				   temp7 == 0xa8 and
				   temp8 == 0x8e and
				   temp9 == 0x44 then
						print( "*************************************************" )
						print( "*** Mega Charm in cure menu *******************" )
						print( "*************************************************" )
						AwardTrophy(5, "OneCharm")
				end
			end
		end

	
	end
end

if JapanRegion == 0 then
	ItemCureMenuHook = eeObj.AddHook(0x00125A5C,0x90820000,ItemCureMenuTest)
	ItemExecutingNameCheckHook = emuObj.AddVsyncHook(ItemExecutingNameCheckTest)
else
	ItemCureMenuHook = eeObj.AddHook(0x0125684,0x90820000,ItemCureMenuTestJapan)
	ItemExecutingNameCheckHook = emuObj.AddVsyncHook(ItemExecutingNameCheckTestJapan)
end


--[[###################################################################################################################
#######################################################################################################################

Type: Bronze
Game: Okage™ Shadow King PS2
Number: 1
Name: Quenching the People's Thirst
Description: Open the water valve in the church.
Hint: The valve is located in the Church basement, after the battle with the Ghost.	

Type: Breakpoint hook
Extra: this code gets executed setting a single bit flag in memory, the flag is used for the visual status of the
       water flowing.

dasm: todo

###################################################################################################################--]]

InitSave("Quenching")

local WaterOnTest = function()
	if SaveData["Quenching"] ~= 1 then

		local v0 = eeObj.GetGPR(gpr.v0)
		local v1 = eeObj.GetGPR(gpr.v1)
		local a1 = eeObj.GetGPR(gpr.a1)
	
		--print( string.format("hook test v0 %08x", v0) )
		--print( string.format("hook test v1 %08x", v1) )
		--print( string.format("hook test a1 %08x", a1) )

		if a1 == (0x5c1765+AdjustForRegion) and v1 == 0x40 then

			--print( "*************************************************" )
			--print( "******************** Water Turned On ************" )

			AwardTrophy(1, "Quenching")

		end

	end

end

if JapanRegion == 0 then
	WaterOnHook = eeObj.AddHook(0x0012599c,0x90A20000, WaterOnTest)
else
	WaterOnHook = eeObj.AddHook(0x0012599c-0x3D8,0x90A20000, WaterOnTest)
end

--[[###################################################################################################################
#######################################################################################################################

Type: Bronze
Game: Okage™ Shadow King PS2
Number: 6
Name: For Science!
Description: Give a donation to Madril's Research Center.
Hint: The Research Center is located in Madril. The minimum donation is 10 sukel.

Notes

triggers a few conversation lines AFTER you select the donation value, this is when the flag is set to indicate
you've made a donation, this is more compatible between versions (USA/Japan) than hooking on a conversation.


bp at 0x0012599c
a1 = 0x5c1779 (byte address of flag)
v0 is 4a
v1 is 02

USA
00125994    12200005	beq         s1,zero,0x001259AC  .. .. .. BR .. .. .. ..  [01] BRANCH 
00125998    00621807	srav        v1,v0,v1            IX .. .. .. .. .. .. ..  
0012599C    90A20000	lbu         v0,0x0000(a1)       .. .. LS .. .. .. .. .. 
001259A0    00431025	or          v0,v0,v1            IX .. .. .. .. .. .. ..  [01] REG    << here 
001259A4    10000005	b           0x001259BC          .. .. .. BR .. .. .. ..  [01] BRANCH 
001259A8    A0A20000	sb          v0,0x0000(a1)       .. .. LS .. .. .. .. ..  
001259AC    90A20000	lbu         v0,0x0000(a1)       .. .. LS .. .. .. .. ..  [01] PIPE 
001259B0    00031827	nor         v1,zero,v1          IX .. .. .. .. .. .. ..  
001259B4    00431024	and         v0,v0,v1            IX .. .. .. .. .. .. ..  [01] REG 
001259B8    A0A20000	sb          v0,0x0000(a1)       .. .. LS .. .. .. .. ..  
001259BC    DFBF0030	ld          ra,0x0030(sp)       .. .. LS .. .. .. .. ..  [01] PIPE 
001259C0    DFB10020	ld          s1,0x0020(sp)       .. .. LS .. .. .. .. ..  
001259C4    DFB00010	ld          s0,0x0010(sp)       .. .. LS .. .. .. .. ..  [01] PIPE 
001259C8    03E00008	jr          ra                  .. .. .. BR .. .. .. ..  
001259CC    27BD0040	addiu       sp,sp,0x40          IX .. .. .. .. .. .. ..  
001259D0    27BDFFC0	addiu       sp,sp,-0x40         IX .. .. .. .. .. .. ..  
001259D4    30A20008	andi        v0,a1,0x8           IX .. .. .. .. .. .. ..  
001259D8    FFB10020	sd          s1,0x0020(sp)       .. .. LS .. .. .. .. ..  
001259DC    FFB00010	sd          s0,0x0010(sp)       .. .. LS .. .. .. .. ..  [01] PIPE 
001259E0    00C0882D	dmove       s1,a2               IX .. .. .. .. .. .. ..  
001259E4    FFBF0030	sd          ra,0x0030(sp)       .. .. LS .. .. .. .. ..  
001259E8    10400009	beq         v0,zero,0x00125A10  .. .. .. BR .. .. .. ..  
001259EC    0080802D	dmove       s0,a0               IX .. .. .. .. .. .. ..  
001259F0    0C0495D6	jal         0x00125758          .. .. .. BR .. .. .. ..  
001259F4    30A40007	andi        a0,a1,0x7           IX .. .. .. .. .. .. ..  
001259F8    00101840	sll         v1,s0,1             IX .. .. .. .. .. .. ..  

Japan
001255BC    12200005	beq         s1,zero,0x001255D4
001255C0    00621807	srav        v1,v0,v1
001255C4    90A20000	lbu         v0,0x0000(a1)
001255C8    00431025	or          v0,v0,v1     << here 
001255CC    10000005	b           0x001255E4
001255D0    A0A20000	sb          v0,0x0000(a1)
001255D4    90A20000	lbu         v0,0x0000(a1)
001255D8    00031827	nor         v1,zero,v1
001255DC    00431024	and         v0,v0,v1
001255E0    A0A20000	sb          v0,0x0000(a1)
001255E4    DFBF0030	ld          ra,0x0030(sp)
001255E8    DFB10020	ld          s1,0x0020(sp)
001255EC    DFB00010	ld          s0,0x0010(sp)
001255F0    03E00008	jr          ra
001255F4    27BD0040	addiu       sp,sp,0x40
001255F8    27BDFFC0	addiu       sp,sp,-0x40
001255FC    30A20008	andi        v0,a1,0x8
00125600    FFB10020	sd          s1,0x0020(sp)
00125604    FFB00010	sd          s0,0x0010(sp)
00125608    00C0882D	dmove       s1,a2
0012560C    FFBF0030	sd          ra,0x0030(sp)
00125610    10400009	beq         v0,zero,0x00125638
00125614    0080802D	dmove       s0,a0
00125618    0C0494E0	jal         0x00125380
0012561C    30A40007	andi        a0,a1,0x7
00125620    00101840	sll         v1,s0,1
00125624    00621821	addu        v1,v1,v0
00125628    94620000	lhu         v0,0x0000(v1)
0012562C    00511021	addu        v0,v0,s1
00125630    10000017	b           0x00125690
00125634    A4620000	sh          v0,0x0000(v1)
00125638    24020004	li          v0,0x4
0012563C    14A2000A	bne         a1,v0,0x00125668
00125640    0200202D	dmove       a0,s0
00125644    3C030025	lui         v1,0x25
00125648    00102080	sll         a0,s0,2
0012564C    8C62B108	lw          v0,0xB108(v1)
00125650    24420510	addiu       v0,v0,0x510
00125654    00822021	addu        a0,a0,v0
00125658    8C830000	lw          v1,0x0000(a0)
0012565C    00711821	addu        v1,v1,s1
00125660    1000000B	b           0x00125690


###################################################################################################################--]]

InitSave("ForScience")

local ResearchTest = function()

	local originalvalue = eeObj.GetGPR(gpr.v0) 
	local appliedvalue = eeObj.GetGPR(gpr.v1) 
	local address = eeObj.GetGPR(gpr.a1) 
	--print( "*************************************************" )
	--print( string.format("ov %08x av %08x ad %08x", originalvalue,appliedvalue,address) )
	--print( "*************************************************" )

	if SaveData["ForScience"] ~= 1 then

		if address == (0x05c1779+AdjustForRegion) and appliedvalue == 0x02 then

			print( "*************************************************" )
			print( "******************** Made Initial Donation ******" )

			AwardTrophy(6, "ForScience")
		end
	end
end


if JapanRegion == 0 then
	ResearchHook3 = eeObj.AddHook(0x01259A0,0x00431025, ResearchTest)   
else
	ResearchHook3 = eeObj.AddHook(0x01255C8,0x00431025, ResearchTest)   
end

 
--[[###################################################################################################################
#######################################################################################################################

Type: Bronze
Game: Okage™ Shadow King PS2
Number:	9
Name: Don't Move a Muscle
Description: Successfully paralyze an enemy
Hint: Kisling gains a Paralyze spell (lv 42), and Immobilize (lv 57) can also happen with a Chained Bottle or Epros Random spell (lv 50).  An enemy may also 'Short Circuit' during battle.

Type: Breakpoint hook
Extra: results of spells etc. can appear out of order (another spell can be cast in battle sequence before the status gets updated)
       this means the last cast spell / item won't neccessarily be the cause of the paralysis.
	  
dasm: todo

###################################################################################################################--]]

InitSave("DontMoveAMuscle")

local ParalyzeTest = function()
	if SaveData["DontMoveAMuscle"] ~= 1 then
		local s3 = eeObj.GetGPR(gpr.s3)
		--print( string.format("Battle Address ;;;;;;;;;;;;;;;;;;;;; %08x @@@@@@@#######@@@@@@@", s3) )
		s3 = s3 + 0x0008
		--print( string.format("Battle Address ;;;;;;;;;;;;;;;;;;;;; %08x @@@@@@@#######@@@@@@@", s3) )
		local addr = eeObj.ReadMem32(s3)
		addr = addr & 0xfffffffc
		local by =  eeObj.ReadMem32(addr)
		by = by & 0x00000700
		--print( string.format("Battle Status :;;;;;;;;;;;;;;;;;;;;; %08x @@@@@@@#######@@@@@@@", addr) )
		--print( string.format("Battle Statusx :;;;;;;;;;;;;;;;;;;;;; %08x @@@@@@@#######@@@@@@@", by) )

		if by == 0x0100 then
			--print( string.format("Normal", addr) )
		end

		if by == 0x0200 then
			--print( string.format("Poison", addr) )
		end

		if by == 0x0300 then
			--print( string.format("Sleep", addr) )
		end

		if by == 0x0400 then
			--print( string.format("Paralyze", addr) )

			--[[ This checks is the last attack executed was the Paralzye spell,
			     however the game has 'out of order' updates meaning that sometimes
				 there will be another spell executed between the Paralyze spell
				 and the Paralyze effect being applied --]]

			--[[
			if Adjusted_RM8(0x089a391) == 0x50 and
			   Adjusted_RM8(0x089a392) == 0x61 and
			   Adjusted_RM8(0x089a393) == 0x72 and
		 	   Adjusted_RM8(0x089a394) == 0x61 and
			   Adjusted_RM8(0x089a395) == 0x6C and
			   Adjusted_RM8(0x089a396) == 0x79 and
			   Adjusted_RM8(0x089a397) == 0x7A and
			   Adjusted_RM8(0x089a398) == 0x65 then

				print( "*************************************************" )
				print( "******************** Paralyzed with Paralyze*****" )

			else
				print( string.format("%02x %02x %02x %02x %02x %02x %02x %02x", Adjusted_RM8(0x089a391), Adjusted_RM8(0x089a392), Adjusted_RM8(0x089a393), Adjusted_RM8(0x089a394), Adjusted_RM8(0x089a395), Adjusted_RM8(0x089a396), Adjusted_RM8(0x089a397), Adjusted_RM8(0x089a398)) )
			end
			--]]

			AwardTrophy(9, "DontMoveAMuscle")
		end

		if by == 0x0500 then
			print( string.format("Seal", addr) )
		end

	end
end

if JapanRegion == 0 then
	ParalyzeHook = eeObj.AddHook(0x0015A96C,0x24030001, ParalyzeTest)
else
	ParalyzeHook = eeObj.AddHook(0x015989c,0x24030001, ParalyzeTest)
end

--[[###################################################################################################################
#######################################################################################################################

Type: Gold
Game: Okage™ Shadow King PS2
Number: 28
Name: Two Peas in a Pod
Description: Receive a Compatibility Gift.
Hint: Compatibility Gifts are awarded from one of the Fortune Tellers and vary based on what your responses and actions have been throughout the game.

Type: Breakpoint hook and Memory Watch
Extra: 5 of the characters award items, these are handled via simple memory watching on the inventory, if you have the item you have the gift
       for Stan the award is a unique stat boost so we need an additional check.

	compatibility is stored at 005c1ba0, higher number = higher compatibility
	005c1ba0 : 0000000b 00000003 00000007 00000003                    
	005c1bb0 : 0000000a 00000003 00000000 00000000                    
		
	"father" "julia" "mysterious woman" "stan"
	"rosalyn" "princess marlene" "unused" "unused"
		
	(setting the unused values also acts as princess)

	gifts are as follows

	Father: A of Spades (item 0x5C1b0c )
	Julia: Owl's Amulet (item 0x5C1b58 )
	Mysterious Woman: Daymare Ring (item 0x5C1b55)
	Stan: stat boost (not an item)
	Rosalyn: Gallant Rapier (item 0x5C1Af4 )
	Marlene: Reunion Outfit (item 0x5C1b15 )

###################################################################################################################--]]

InitSave("TwoPeasInAPod")

local StanCompatibilityTest = function()
	if SaveData["TwoPeasInAPod"] ~= 1 then
		-- is this called in any other case? could need additional checks to make sure it's the right situation if so.
		AwardTrophy(28, "TwoPeasInAPod")
	end
end

local CompatibilityItemTrophy = function()
	if SaveData["TwoPeasInAPod"] ~= 1 then
		local Count0 = Adjusted_RM8(0x5C1b0c) -- A of Spades
		local Count1 = Adjusted_RM8(0x5C1b58) -- Owl's Amulet
		local Count2 = Adjusted_RM8(0x5C1b55) -- Daymare Ring
		local Count3 = Adjusted_RM8(0x5C1Af4) -- Gallant Rapier
		local Count4 = Adjusted_RM8(0x5C1b15) -- Reunion Outfit

		if Count0 > 0 or Count1 > 0 or Count2 > 0 or Count3 > 0 or Count4 > 0 then
			AwardTrophy(28, "TwoPeasInAPod")
		end
	end
end


if JapanRegion == 0 then
	StanCompatibilityHook = eeObj.AddHook(0x01259f8,0x00101840, StanCompatibilityTest)
else
	StanCompatibilityHook = eeObj.AddHook(0x00125620,0x00101840, StanCompatibilityTest)
end

CompatibilityItemHook = emuObj.AddVsyncHook(CompatibilityItemTrophy)

--[[###################################################################################################################
#######################################################################################################################

Type: Silver
Game: Okage™ Shadow King PS2
Number: 23
Name: Clear!
Description: Revive an ally during battle
Hint: Ari's Revive spell (lv 32) or Life Spark spell (lv 51) can do this, as can an Energy Flower

Implementation notes:

Type: Breakpoint hook
Extra: can the status flag be anything other than 0x06 when a character is dead?

dasm:

00153534    27BD0020	addiu       sp,sp,0x20          IX .. .. .. .. .. .. ..  
00153538    8C820004	lw          v0,0x0004(a0)       .. .. LS .. .. .. .. ..  << Breakpoint given here (happens after execute)
0015353C    24050001	li          a1,0x1              IX .. .. .. .. .. .. ..  
00153540    A0450000	sb          a1,0x0000(v0)       .. .. LS .. .. .. .. ..  [01] REG 
00153544    8C830008	lw          v1,0x0008(a0)       .. .. LS .. .. .. .. ..  [01] PIPE 
00153548    03E00008	jr          ra                  .. .. .. BR .. .. .. ..  
0015354C    A4600000	sh          zero,0x0000(v1)     .. .. LS .. .. .. .. ..  [01] REG 
00153550    8C82000C	lw          v0,0x000C(a0)       .. .. LS .. .. .. .. ..  
00153554    A0400000	sb          zero,0x0000(v0)     .. .. LS .. .. .. .. ..  [02] REG  PIPE 
00153558    8C830010	lw          v1,0x0010(a0)       .. .. LS .. .. .. .. ..  
0015355C    A4600000	sh          zero,0x0000(v1)     .. .. LS .. .. .. .. ..  [02] REG  PIPE 

###################################################################################################################--]]

InitSave("Clear!")

local ReviveTest = function()
	if SaveData["Clear!"] ~= 1 then

		local v0 = eeObj.GetGPR(gpr.v0) -- the address where the status flag is

		local ExistingStatus = eeObj.ReadMem8(v0)

		-- 0x06 means dead? the code above changes it back to 0x01 (normal?)
		if ExistingStatus == 0x06 then
			AwardTrophy(23, "Clear!")
		end
	end
end

if JapanRegion == 0 then
	Trophy23CodeHook = eeObj.AddHook(0x0153538,0x8C820004, ReviveTest)
else
	Trophy23CodeHook = eeObj.AddHook(0x0152468,0x8C820004, ReviveTest)
end

--[[###################################################################################################################
#######################################################################################################################

Type: Silver (Hidden)
Game: Okage™ Shadow King PS2
Number: 11
Name: Sewer Rodent
Description: Defeat the Sewer Evil King.
Hint: First Boss.

Type: Silver (Hidden)
Game: Okage™ Shadow King PS2
Number: 12
Name: Something's Fishy
Description: Defeat the Bubble Evil King.
Hint: Second boss.

Type: Silver (Hidden)
Game: Okage™ Shadow King PS2
Number: 13
Name: Ex-Former Chairman
Description: Defeat the Former Chairman Evil King.
Hint: Third boss.

Type: Silver (Hidden)
Game: Okage™ Shadow King PS2
Number: 14
Name: The Champ is Here
Description: Defeat the Big Bull Evil King.
Hint: Fourth boss.

Type: Silver (Hidden)
Game: Okage™ Shadow King PS2
Number: 15
Name: Pop Sensation
Description: Defeat the Teen Idol Evil King.
Hint: Fifth boss.

Type: Silver (Hidden)
Game: Okage™ Shadow King PS2
Number: 16
Name: Just an Illusion
Description: Defeat the Phantom Evil King.
Hint: Sixth boss.

Type: Silver (Hidden)
Game: Okage™ Shadow King PS2
Number: 17
Name: What Large Teeth You Have
Description: Defeat the Vampire Evil King.
Hint: Seventh boss.

Type: Gold (Hidden)
Game: Okage™ Shadow King PS2
NumbeR: 27
Name: Breaking the Class
Description: Defeat Beiloune in the final battle.
Hint: This is the final boss fight.

Type: File Access watches
Extra: 

###################################################################################################################--]]

InitSave("Boss1")
InitSave("Boss2")
InitSave("Boss3")
InitSave("Boss4")
InitSave("Boss5")
InitSave("Boss6")
InitSave("Boss7")
InitSave("Boss8")


local LastBossLoaded = 0

local LoadSewerKing = function()
	--print( "*************************************************" )
	--print( "******************** SewerKing ******************" )
	--print( "*************************************************" )
	LastBossLoaded = 1
end

local LoadBubbleKing = function()
	--print( "*************************************************" )
	--print( "******************** BubbleKing *****************" )
	--print( "*************************************************" )
	LastBossLoaded = 2
end

local LoadChairman = function()
	--print( "*************************************************" )
	--print( "******************** Chairman********************" )
	--print( "*************************************************" )
	LastBossLoaded = 3
end

local LoadBigBull = function()
	--print( "*************************************************" )
	--print( "******************** BigBull ********************" )
	--print( "*************************************************" )
	LastBossLoaded = 4
end

local LoadLinda = function()
	--print( "*************************************************" )
	--print( "******************** Linda **********************" )
	--print( "*************************************************" )
	LastBossLoaded = 5
end

local LoadPhantom = function()
	--print( "*************************************************" )
	--print( "******************** Phantom ********************" )
	--print( "*************************************************" )
	LastBossLoaded = 6
end

local LoadVampire = function()
	--print( "*************************************************" )
	--print( "******************** Vampire ********************" )
	--print( "*************************************************" )
	LastBossLoaded = 7
end

local LoadFinalBoss = function()
	--print( "*************************************************" )
	--print( "******************** Final Boss *****************" )
	--print( "*************************************************" )
	LastBossLoaded = 8
end

local LoadBattleStart = function()
	--print( "*************************************************" )
	--print( "******************** Start Battle ***************" )
	--print( "*************************************************" )
	LastBossLoaded = 0
end

local LoadBattleResults = function()
	-- if this screen loads then you have won
	-- it never loads if you've lost?

	--print( "*************************************************" )
	--print( "******************** Results ** *****************" )
	--print( "*************************************************" )

	if LastBossLoaded == 1 then
		if SaveData["Boss1"] ~= 1 then
			AwardTrophy(11, "Boss1")
		end
	end

	if LastBossLoaded == 2 then
		if SaveData["Boss2"] ~= 1 then
			AwardTrophy(12, "Boss2")
		end
	end

	if LastBossLoaded == 3 then
		if SaveData["Boss3"] ~= 1 then
			AwardTrophy(13, "Boss3")
		end
	end

	if LastBossLoaded == 4 then
		if SaveData["Boss4"] ~= 1 then
			AwardTrophy(14, "Boss4")
		end
	end

	if LastBossLoaded == 5 then
		if SaveData["Boss5"] ~= 1 then
			AwardTrophy(15, "Boss5")
		end
	end

	if LastBossLoaded == 6 then
		if SaveData["Boss6"] ~= 1 then
			AwardTrophy(16, "Boss6")
		end
	end

	if LastBossLoaded == 7 then
		if SaveData["Boss7"] ~= 1 then
			AwardTrophy(17, "Boss7")
		end
	end

	if LastBossLoaded == 8 then
		if SaveData["Boss8"] ~= 1 then
			AwardTrophy(27, "Boss8")
		end
	end

	--print( "*************************************************" )
	--print( "*************************************************" )


	LastBossLoaded = 0
end

-- if either of these get loaded then wipe out our 'last boss loaded' flag
-- they're loaded at the start of each battle before the boss is loaded (if there is a boss)
-- and after the characters are loaded (to prevent a conflict with Linda and BigBull from
-- being detected as bosses after becoming playable)

local LoadBag = function()
	--print(string.format("*****************LOADING BAG*************** (last boss value %d)", LastBossLoaded)    )
	if LastBossLoaded ~= 8 then
		LastBossLoaded = 0
		--print( "*****************CLEARING FLAG***************" )
	end
end

local LoadBox = function()
	--print(string.format("*****************LOADING BOX*************** (last boss value %d)", LastBossLoaded)    )
	if LastBossLoaded ~= 8 then
		LastBossLoaded = 0
		--print( "*****************CLEARING FLAG***************" )
	end
end

local LoadTitle = function()
	print(string.format("*****************LOADING TITLE*************** (last boss value %d)", LastBossLoaded)    )
	LastBossLoaded = 0
end

if JapanRegion == 0 then
	emuObj.AddSectorReadHook(0x0157b2, 0x000010, LoadSewerKing) -- Boss 1
	emuObj.AddSectorReadHook(0x014750, 0x000010, LoadBubbleKing) -- Boss 2
	emuObj.AddSectorReadHook(0x014d75, 0x000010, LoadChairman) -- Boss 3
	emuObj.AddSectorReadHook(0x014692, 0x000010, LoadBigBull) -- Boss 4 (also used for playable character)
	emuObj.AddSectorReadHook(0x014f9c, 0x000010, LoadLinda) -- Boss 5 (also used for playable character)
	emuObj.AddSectorReadHook(0x0143a8, 0x000010, LoadPhantom) -- Boss 6 (also used for a playable character)
	emuObj.AddSectorReadHook(0x015ead, 0x000010, LoadVampire) -- Boss 7
	emuObj.AddSectorReadHook(0x015dbf, 0x000010, LoadFinalBoss) -- Boss 8
	emuObj.AddSectorReadHook(0x016a0b, 0x000008, LoadBag)
	emuObj.AddSectorReadHook(0x016a14, 0x000005, LoadBox)

	  
	emuObj.AddSectorReadHook(0x01426b, 0x000010, LoadTitle)  -- : CMNDATA/2D/SCR.XPF
	
	emuObj.AddSectorReadHook(0x013d8b, 0x000009, LoadBattleStart) -- loaded at the start of a battle
	emuObj.AddSectorReadHook(0x013d95, 0x000010, LoadBattleResults) -- loaded when the results screen comes up (but also some other times?!)
else
	-- adjustments for locations of files in Japan version
	local SectorAdjust = -0x14351
	local SectorAdjust2 = -0x14352
	local SectorAdjust3 = -0xC2FF

	emuObj.AddSectorReadHook(0x0157b2+SectorAdjust, 0x000010, LoadSewerKing) -- Boss 1 -- ABD9000 -- A30800*
	emuObj.AddSectorReadHook(0x014750+SectorAdjust2, 0x000010, LoadBubbleKing) -- Boss 2 -- A3A8000 -- 1ff000* 153d800 287d000  -- 0x1ff000 in iso (0x3fe * 2048)
	emuObj.AddSectorReadHook(0x014d75+SectorAdjust2, 0x000010, LoadChairman) -- Boss 3 -- A6BA800 -- 511800@  184f000  2b8f800
	emuObj.AddSectorReadHook(0x014692+SectorAdjust2, 0x000010, LoadBigBull) -- Boss 4 -- A349000 -- 1a0000@ 14de800 281e000 (also used for playable character)
	emuObj.AddSectorReadHook(0x014f9c+SectorAdjust2, 0x000010, LoadLinda) -- Boss 5 -- A7CE000 -- 625000@ 1963800 2ca4000 (also used for playable character)
	emuObj.AddSectorReadHook(0x0143a8+SectorAdjust2, 0x000010, LoadPhantom) --  Boss 6 -- A1D4000 -- 2b000@ 1364800 26a4000 (also used for a playable character)
	emuObj.AddSectorReadHook(0x015ead+SectorAdjust, 0x000010, LoadVampire) -- Boss 7-- AF56800 -- dae000@ 20e7800 3411000
	emuObj.AddSectorReadHook(0x015dbf+SectorAdjust, 0x000010, LoadFinalBoss) -- Boss 8 -- AEDF800 -- d37000@ 2070800 339a000
	emuObj.AddSectorReadHook(0x016a0b+SectorAdjust, 0x000008, LoadBag) -- B505800 --135d000* 269c800 39e1800
	emuObj.AddSectorReadHook(0x016a14+SectorAdjust, 0x000005, LoadBox) -- B50A000 --1361800* 26a1000 39e6000

	emuObj.AddSectorReadHook(0x007855, 0x000010, LoadTitle)  -- : CMNDATA/2D/SCR.XPF
	
	emuObj.AddSectorReadHook(0x013d8b+SectorAdjust3, 0x000009, LoadBattleStart) -- loaded at the start of a battle ( CMNDATA/WIN/BTL.RUW )
	emuObj.AddSectorReadHook(0x013d95+SectorAdjust3, 0x000010, LoadBattleResults) -- loaded when the results screen comes up (but also some other times?!) ( CMNDATA/WIN/FLD.RUW )
end





--[[###################################################################################################################
#######################################################################################################################

  CHEAT HELPERS for debugging / notes etc.

###################################################################################################################--]]

-- set to 0 for release
local AllowCheats = 0

-- VsyncHook cheats
local HPCheat = function()



	if AllowCheats == 1 then


		-- check for pressing 2 shoulder buttons
		local pad = emuObj.GetPad()
		if pad & 0x300 == 0x300 then
			-- ensure we don't have the special items
			Adjusted_WM8(0x5C1b14, 0)
			Adjusted_WM8(0x5C1b24, 0)
			Adjusted_WM8(0x5C1b35, 0)
			Adjusted_WM8(0x5C1Aea, 0)
			Adjusted_WM8(0x5C1Af3, 0)
			Adjusted_WM8(0x5C1Afb, 0)
			Adjusted_WM8(0x5C1b0b, 0)

			Adjusted_WM8(0x5C1b0a, 0) -- Q of Hearts
			Adjusted_WM8(0x5C1Aeb, 0) -- Forgotten Sword
			Adjusted_WM8(0x5C1b59, 0)  -- Hand Knit Cap
			Adjusted_WM8(0x5C1b46, 0) -- Unicorns Horn
			Adjusted_WM8(0x5C1b4f, 0) -- Divine Shoes
			Adjusted_WM32(0x5c1b6c, 490000)

			-- HP values
			-- per character
			Adjusted_WM16((0x5c1c1c)+(0x50*0), 999) -- ari
			Adjusted_WM16((0x5c1c1c)+(0x50*1), 999) -- ros
			Adjusted_WM16((0x5c1c1c)+(0x50*2), 999) -- Kisling
			Adjusted_WM16((0x5c1c1c)+(0x50*3), 999) -- big bull
			Adjusted_WM16((0x5c1c1c)+(0x50*4), 999) -- Linda
			Adjusted_WM16((0x5c1c1c)+(0x50*5), 999) -- Epros


	

			-- global (money)
			
	
			-- enemy death cheat
			Adjusted_WM32(0x01dc7838-(0*0x3f0), 0) -- first enemy (ususally a boss?)
			Adjusted_WM32(0x01dc7838-(1*0x3f0), 0) -- 2nd ( 0x1DC7448 )
			Adjusted_WM32(0x01dc7838-(2*0x3f0), 0) -- 3rd ( 0x1DC7058 )
			Adjusted_WM32(0x01dc7838-(3*0x3f0), 0) -- 4th ( 0x1DC6C68 )
			Adjusted_WM32(0x01dc7838-(4*0x3f0), 0) -- 5th ( 0x1DC6878 )

			-- Level	
			--Adjusted_WM16(0x5c1c16, 999)	-- AP
			Adjusted_WM16((0x5c1c1a)+(0x50*0), 999)	-- Experience Points (Ari)
			Adjusted_WM16((0x5c1c1a)+(0x50*1), 999)	-- Experience Points
			Adjusted_WM16((0x5c1c1a)+(0x50*2), 999)	-- Experience Points
			Adjusted_WM16((0x5c1c1a)+(0x50*3), 999)	-- Experience Points
			Adjusted_WM16((0x5c1c1a)+(0x50*4), 999)	-- Experience Points
			Adjusted_WM16((0x5c1c1a)+(0x50*5), 999)	-- Experience Points (Epros)
		

			-- enemy status value before these is 0x0001 when active?
			-- 0x0100 = normal status? (always set if nothing wrong?)
			-- 0x0200 = skull? (skull bottle / poison)
			-- 0x0300 = zz (sleep)
			-- 0x0400 = paralyze?
			-- 0x0500 = seal

			--Adjusted_WM16(0x01dc783c-(0*0x3f0), 0x0400)
			--Adjusted_WM16(0x01dc783c-(1*0x3f0), 0x0400)
			--Adjusted_WM16(0x01dc783c-(2*0x3f0), 0x0400)
			--Adjusted_WM16(0x01dc783c-(3*0x3f0), 0x0400)
			--Adjusted_WM16(0x01dc783c-(4*0x3f0), 0x0400)
		
  
			-- Item cheats 
			--[[
			local count = math.random(99)
			Adjusted_WM8(0x5C1A61, count) -- Nut (first item?)
			Adjusted_WM8(0x5C1A62, count) -- Big Nut
			Adjusted_WM8(0x5C1A63, count) -- Miracle Nut
			Adjusted_WM8(0x5C1A64, count) -- Bountiful Nut
			Adjusted_WM8(0x5C1A65, count) -- Wild Strawberry
			Adjusted_WM8(0x5C1A66, count) -- Whim Berry
			Adjusted_WM8(0x5C1A67, count) -- Energy Flower
			Adjusted_WM8(0x5C1A68, count) -- Energy Bouquet
			Adjusted_WM8(0x5C1A69, count) -- Clarity Charm
			Adjusted_WM8(0x5C1A6a, count) -- Bunny Charm
			Adjusted_WM8(0x5C1A6b, count) -- Villains Charm

			Adjusted_WM8(0x5C1A6c, count) -- Rust Off Charm
			Adjusted_WM8(0x5C1A6d, count) -- Sommelier Charm
			Adjusted_WM8(0x5C1A6e, count) -- Angel Charm
			Adjusted_WM8(0x5C1A6f, count) -- Alarm Charm
			Adjusted_WM8(0x5C1A70, count) -- Big Boss Charm
			Adjusted_WM8(0x5C1A71, count) -- Writeoff Charm
			Adjusted_WM8(0x5C1A72, count) -- Mega Charm
			Adjusted_WM8(0x5C1A73, count) -- Purging Stone
			Adjusted_WM8(0x5C1A74, count) -- Awakening Stone
			Adjusted_WM8(0x5C1A75, count) -- Liberation Stone
			Adjusted_WM8(0x5C1A76, 10) -- Cheerful Stone

			Adjusted_WM8(0x5C1A77, count) -- Mega Stone
			Adjusted_WM8(0x5C1A78, count) -- Black Cat Jewel
			Adjusted_WM8(0x5C1A79, count) -- White Cat Jewel
			Adjusted_WM8(0x5C1A7a, count) -- Life Candy
			Adjusted_WM8(0x5C1A7b, count) -- Heart Candy
			Adjusted_WM8(0x5C1A7c, count) -- Power Candy
			Adjusted_WM8(0x5C1A7d, count) -- Defense Candy
			Adjusted_WM8(0x5C1A7e, count) -- Agility Candy
			Adjusted_WM8(0x5C1A7f, count) -- Lucky Candy
			Adjusted_WM8(0x5C1A80, count) -- Guidance Jewel
			Adjusted_WM8(0x5C1A81, 20) -- Healing Crystal

			Adjusted_WM8(0x5C1A93, 18) -- Burned Bottle
			Adjusted_WM8(0x5C1A94, 19) -- Frozen Bottle
			Adjusted_WM8(0x5C1A95, 20) -- Glaring Bottle
			Adjusted_WM8(0x5C1A96, 21) -- Skull Bottle
			Adjusted_WM8(0x5C1A97, 1) -- Sleeping Bottle
			Adjusted_WM8(0x5C1A98, 2) -- Ordinary Bottle
			Adjusted_WM8(0x5C1A99, 3) -- Chained Bottle
			Adjusted_WM8(0x5C1A9a, 4) -- Swift Bottle
			Adjusted_WM8(0x5C1A9b, 5) -- Mega Luck Bottle
			Adjusted_WM8(0x5C1Aa7, 17) -- Map of Evil Kings
			Adjusted_WM8(0x5C1Aa8, 18) -- Miniature Statue

			Adjusted_WM8(0x5C1Aa9, 19) -- Platinum Ticket
			Adjusted_WM8(0x5C1Aaa, 20) -- Gear Tower Key
			Adjusted_WM8(0x5C1Aab, 21) -- Voice Recorder
			Adjusted_WM8(0x5C1Aac, 22) -- Recorder 2
			Adjusted_WM8(0x5C1Aad, 23) -- Ordinary Card
			Adjusted_WM8(0x5C1Aae, 24) -- Official Card
			Adjusted_WM8(0x5C1Aaf, 25) -- Gaudy Card
			Adjusted_WM8(0x5C1Ab0, 26) -- Mere Pebble
			Adjusted_WM8(0x5C1Ab1, 27) -- Bread Crust
			Adjusted_WM8(0x5C1Ab2, 28) -- Worn Brush
			Adjusted_WM8(0x5C1Ab3, 29) -- Letter Bottle

			Adjusted_WM8(0x5C1Ab4, 30) -- Cyphertext 1
			Adjusted_WM8(0x5C1Ab5, 31) -- Cyphertext 2
			Adjusted_WM8(0x5C1Ab6, 32) -- Cyphertext 3
			Adjusted_WM8(0x5C1Ab7, 33) -- Cyphertext 4
			Adjusted_WM8(0x5C1Ab8, 34) -- Cyphertext 5
			Adjusted_WM8(0x5C1Ab9, 35) -- Cyphertext 6
			Adjusted_WM8(0x5C1Aba, 36) -- Punk Wig
			Adjusted_WM8(0x5C1Abb, 37) -- Cholesterol
			Adjusted_WM8(0x5C1Abc, 38) -- Chic Suspenders
			Adjusted_WM8(0x5C1Abd, 39) -- Lustrous Hair
			Adjusted_WM8(0x5C1Abe, 40) -- Gorgeous Mascara

			Adjusted_WM8(0x5C1Abf, 41) -- Cool Vest
			Adjusted_WM8(0x5C1Ac0, 42) -- Ground Beef
			Adjusted_WM8(0x5C1Ac1, 43) -- Loaf for Pickup
			Adjusted_WM8(0x5C1Ac2, 44) -- Fruit Knife
			Adjusted_WM8(0x5C1Ac3, 45) -- Swanky Mirror
			Adjusted_WM8(0x5C1Ac4, 46) -- Shiny Lens
			Adjusted_WM8(0x5C1Ac5, 47) -- Tiny Gear
			Adjusted_WM8(0x5C1Ac6, 48) -- Silver Gear
			Adjusted_WM8(0x5C1Ac7, 49) -- Gold Gear
			Adjusted_WM8(0x5C1Ac8, 50) -- Rare Gear
			Adjusted_WM8(0x5C1Ac9, 51) -- Old Stone Doll

			Adjusted_WM8(0x5C1Aca, 52) -- Garnet Key
			Adjusted_WM8(0x5C1Acb, 53) -- Emerald Key
			Adjusted_WM8(0x5C1Acc, 54) -- Sapphire Key
			Adjusted_WM8(0x5C1Acd, 55) -- Amethyst Key
			Adjusted_WM8(0x5C1Ace, 56) -- Cow Bone
			Adjusted_WM8(0x5C1Acf, 57) -- Filet Mignon
			Adjusted_WM8(0x5C1Ad0, 58) -- Old Music Box
			Adjusted_WM8(0x5C1Ad1, 59) -- Eh its ok card
			Adjusted_WM8(0x5C1Ad2, 60) -- Odd Glass Tube
			Adjusted_WM8(0x5C1Ad3, 61) -- Spiral Wire
			Adjusted_WM8(0x5C1AD4, 62) -- Bell Tube

			Adjusted_WM8(0x5C1Ad5, 63) -- Manual Handle
			Adjusted_WM8(0x5C1Ad6, 64) -- Long Screw
			Adjusted_WM8(0x5C1Ad7, 65) -- Dial with One Hand
			Adjusted_WM8(0x5C1Ad8, 66) -- Pedestal of Stone
			Adjusted_WM8(0x5C1Ad9, 67) -- Pen Light
			Adjusted_WM8(0x5C1Ada, 68) -- Broken Gun
			Adjusted_WM8(0x5C1Adb, 69) -- Friendship Bond 
			Adjusted_WM8(0x5C1Ae3, 77) -- Picked Up Branch
			Adjusted_WM8(0x5C1Ae4, 78) -- Leftover Sowrd
			Adjusted_WM8(0x5C1Ae5, 79) -- Ordinary Sword
			Adjusted_WM8(0x5C1Ae6, 80) -- Nameless Sword

			Adjusted_WM8(0x5C1Ae7, 81) -- Omnislice Sword
			Adjusted_WM8(0x5C1Ae8, 82) -- Brand Sword
			Adjusted_WM8(0x5C1Ae9, 83) -- Rustic Sword
			Adjusted_WM8(0x5C1Aea, 84) -- Mastermold Sword
			Adjusted_WM8(0x5C1Aeb, 85) -- Forgotten Sword
			Adjusted_WM8(0x5C1Aec, 86) -- Sword of Gear
			Adjusted_WM8(0x5C1Aef, 3) -- Ordinary Rapier
			Adjusted_WM8(0x5C1Af0, 4) -- Hardy Rapier
			Adjusted_WM8(0x5C1Af1, 5) -- Slim Rapier
			Adjusted_WM8(0x5C1Af2, 6) -- Sparkling Rapier
			Adjusted_WM8(0x5C1Af3, 7) -- WhiteRose Rapier

			Adjusted_WM8(0x5C1Af4, 93) -- Gallant Rapier
			Adjusted_WM8(0x5C1Af7, 96) -- Ghost Basics
			Adjusted_WM8(0x5C1Af8, 97) -- Ghost Pictorial
			Adjusted_WM8(0x5C1Af9, 98) -- Ghostologos
			Adjusted_WM8(0x5C1Afa, 99) -- Worldy Ghost
			Adjusted_WM8(0x5C1Afb, 1) -- Ghostosystem II
			Adjusted_WM8(0x5C1Afc, 2) -- Ghostomicon
			Adjusted_WM8(0x5C1Aff, 5) -- Battle Manual
			Adjusted_WM8(0x5C1b03, 9) -- Mike of Hope
			Adjusted_WM8(0x5C1b04, 10) -- Mike of Happiness
			Adjusted_WM8(0x5C1b05, 11) -- Love Mike

			Adjusted_WM8(0x5C1b09, 15) -- J of Diamonds
			Adjusted_WM8(0x5C1b0a, 16) -- Q of Hearts
			Adjusted_WM8(0x5C1b0b, 17) -- K of Clubs
			Adjusted_WM8(0x5C1b0c, 18) -- A of Spades
			Adjusted_WM8(0x5C1b0e, 20) -- Ordinary Outfit
			Adjusted_WM8(0x5C1b0f, 21) -- Clean Outfit
			Adjusted_WM8(0x5C1b10, 22) -- Fancy Outfit
			Adjusted_WM8(0x5C1b11, 23) -- Durable Outfit
			Adjusted_WM8(0x5C1b12, 24) -- Custom-made Wear
			Adjusted_WM8(0x5C1b13, 25) -- Latest Outfit
			Adjusted_WM8(0x5C1b14, 26) -- Natural Outfit

			Adjusted_WM8(0x5C1b15, 27) -- Reunion Outfit
			Adjusted_WM8(0x5C1b18, 30) -- Swordsman Armor
			Adjusted_WM8(0x5C1b19, 31) -- Chiefs Armor
			Adjusted_WM8(0x5C1b1a, 32) -- Magical Armor
			Adjusted_WM8(0x5C1b1b, 33) -- Honorable Armor
			Adjusted_WM8(0x5C1b1c, 34) -- Heros Armor
			Adjusted_WM8(0x5C1b20, 38) -- Wornout Coat
			Adjusted_WM8(0x5C1b21, 39) -- Starchy Coat
			Adjusted_WM8(0x5C1b22, 40) -- Battlefront Coat
			Adjusted_WM8(0x5C1b23, 41) -- Stately Coat
			Adjusted_WM8(0x5C1b24, 42) -- Basics Only Coat

			Adjusted_WM8(0x5C1b28, 46) -- Infantry Pants
			Adjusted_WM8(0x5C1b29, 47) -- Blood and Sweat Pants
			Adjusted_WM8(0x5C1b2a, 48) -- Inferno Pants
			Adjusted_WM8(0x5C1b2e, 52) -- Stage Dress
			Adjusted_WM8(0x5C1b2f, 53) -- Treasured Dress  
			Adjusted_WM8(0x5C1b30, 54) -- Celeb Dress
			Adjusted_WM8(0x5C1b34, 58) -- Dazzling Tux
			Adjusted_WM8(0x5C1b35, 59) -- Conjurer Tux
			Adjusted_WM8(0x5C1b3d, 67) -- Mongoose Whisker
			Adjusted_WM8(0x5C1b3e, 68) -- Pharaohs Hair
			Adjusted_WM8(0x5C1b3f, 69) -- Rooster Feathers

			Adjusted_WM8(0x5C1b40, 70) -- Sun Medal
			Adjusted_WM8(0x5C1b41, 71) -- Weed Resistance
			Adjusted_WM8(0x5C1b42, 72) -- Touch of Earth
			Adjusted_WM8(0x5C1b43, 73) -- Flake of Snow
			Adjusted_WM8(0x5C1b44, 74) -- Full Moon Medal
			Adjusted_WM8(0x5C1b45, 75) -- Guardian Crystal
			Adjusted_WM8(0x5C1b46, 76) -- Unicorns Horn
			Adjusted_WM8(0x5C1b47, 77) -- Wildcats Fang
			Adjusted_WM8(0x5C1b48, 78) -- Panthers Fang
			Adjusted_WM8(0x5C1b49, 79) -- Cerberus Fang
			Adjusted_WM8(0x5C1b4a, 80) -- 1st Fight Charm

			Adjusted_WM8(0x5C1b4b, count) -- Defense Necklace
			Adjusted_WM8(0x5C1b4c, count) -- Iron Necklace
			Adjusted_WM8(0x5C1b4d, count) -- Bandits Shoes
			Adjusted_WM8(0x5C1b4e, count) -- Pegasus Shoes
			Adjusted_WM8(0x5C1b4f, count) -- Divine Shoes
			Adjusted_WM8(0x5C1b50, count) -- Holly
			Adjusted_WM8(0x5C1b51, count) -- Laurel
			Adjusted_WM8(0x5C1b52, count) -- Legendary Leaf
			Adjusted_WM8(0x5C1b53, count) -- Heatwave Ring
			Adjusted_WM8(0x5C1b54, count) -- Mirage Ring
			Adjusted_WM8(0x5C1b55, count) -- Daymare Ring

			Adjusted_WM8(0x5C1b56, count) -- Aves Amulet
			Adjusted_WM8(0x5C1b57, count) -- Crows Amulet
			Adjusted_WM8(0x5C1b58, count) -- Owls Amulet
			Adjusted_WM8(0x5C1b59, count) -- Hand Knit Cap
			Adjusted_WM8(0x5C1b5a, count) -- 1st Star Badge
			Adjusted_WM8(0x5C1B5B, count) -- Omnibooster (final item?)

			--Adjusted_WM8(0x5C1A82, count) -- unused
			--Adjusted_WM8(0x5C1A83, count) -- unused
			--Adjusted_WM8(0x5C1A84, count) -- unused
			--Adjusted_WM8(0x5C1A85, count) -- unused
			--Adjusted_WM8(0x5C1A86, count) -- unused
			--Adjusted_WM8(0x5C1A87, count) -- unused
			--Adjusted_WM8(0x5C1A88, count) -- unused
			--Adjusted_WM8(0x5C1A89, count) -- unused
			--Adjusted_WM8(0x5C1A8a, count) -- unused
			--Adjusted_WM8(0x5C1A8b, count) -- unused
			--Adjusted_WM8(0x5C1A8c, count) -- unused
			--Adjusted_WM8(0x5C1A8d, count) -- unused
			--Adjusted_WM8(0x5C1A8e, count) -- unused
			--Adjusted_WM8(0x5C1A8f, count) -- unused
			--Adjusted_WM8(0x5C1A90, count) -- unused
			--Adjusted_WM8(0x5C1A91, count) -- unused
			--Adjusted_WM8(0x5C1A92, count) -- unused
			--Adjusted_WM8(0x5C1A9c, count) -- unused
			--Adjusted_WM8(0x5C1A9d, count) -- unused
			--Adjusted_WM8(0x5C1A9e, count) -- unused
			--Adjusted_WM8(0x5C1A9f, count) -- unused
			--Adjusted_WM8(0x5C1Aa0, count) -- unused
			--Adjusted_WM8(0x5C1Aa1, count) -- unused
			--Adjusted_WM8(0x5C1Aa2, count) -- unused
			--Adjusted_WM8(0x5C1Aa3, count) -- unused
			--Adjusted_WM8(0x5C1Aa4, count) -- unused
			--Adjusted_WM8(0x5C1Aa5, count) -- unused
			--Adjusted_WM8(0x5C1Aa6, count) -- unused
			--Adjusted_WM8(0x5C1Adc, count) -- unused
			--Adjusted_WM8(0x5C1Add, count) -- unused
			--Adjusted_WM8(0x5C1Ade, count) -- unused
			--Adjusted_WM8(0x5C1Adf, count) -- unused
			--Adjusted_WM8(0x5C1Ae0, count) -- unused
			--Adjusted_WM8(0x5C1Ae1, count) -- unused
			--Adjusted_WM8(0x5C1Ae2, count) -- unused
			--Adjusted_WM8(0x5C1Aed, count) -- unused
			--Adjusted_WM8(0x5C1Aee, count) -- unused
			--Adjusted_WM8(0x5C1Af5, count) -- unused
			--Adjusted_WM8(0x5C1Af6, count) -- unused
			--Adjusted_WM8(0x5C1Afd, count) -- unused
			--Adjusted_WM8(0x5C1Afe, count) -- unused
			--Adjusted_WM8(0x5C1b00, count) -- unused
			--Adjusted_WM8(0x5C1b01, count) -- unused
			--Adjusted_WM8(0x5C1b02, count) -- unused
			--Adjusted_WM8(0x5C1b06, count) -- unused
			--Adjusted_WM8(0x5C1b07, count) -- unused
			--Adjusted_WM8(0x5C1b08, count) -- unused
			--Adjusted_WM8(0x5C1b0d, count) -- unused
			--Adjusted_WM8(0x5C1b16, count) -- unused
			--Adjusted_WM8(0x5C1b17, count) -- unused
			--Adjusted_WM8(0x5C1b1d, count) -- unused
			--Adjusted_WM8(0x5C1b1e, count) -- unused
			--Adjusted_WM8(0x5C1b1f, count) -- unused
			--Adjusted_WM8(0x5C1b25, count) -- unused
			--Adjusted_WM8(0x5C1b26, count) -- unused
			--Adjusted_WM8(0x5C1b27, count) -- unused
			--Adjusted_WM8(0x5C1b2b, count) -- unused
			--Adjusted_WM8(0x5C1b2c, count) -- unused
			--Adjusted_WM8(0x5C1b2d, count) -- unused
			--Adjusted_WM8(0x5C1b31, count) -- unused
			--Adjusted_WM8(0x5C1b32, count) -- unused
			--Adjusted_WM8(0x5C1b33, count) -- unused  
			--Adjusted_WM8(0x5C1b36, count) -- unused
			--Adjusted_WM8(0x5C1b37, count) -- unused
			--Adjusted_WM8(0x5C1b38, count) -- unused
			--Adjusted_WM8(0x5C1b39, count) -- unused
			--Adjusted_WM8(0x5C1b3a, count) -- unused
			--Adjusted_WM8(0x5C1b3b, count) -- unused
			--Adjusted_WM8(0x5C1b3c, count) -- unused
			--]]
		end
	end
end

HPCheatHook = emuObj.AddVsyncHook(HPCheat)


-- Credits

-- Trophy design and development by SCEA ISD SpecOps
-- David Thach                  Senior Director
-- George Weising               Executive Producer
-- Tim Lindquist                Senior Technical PM
-- Clay Cowgill                 Engineering
-- Nicola Salmoria              Engineering
-- David Haywood                Engineering
-- Warren Davis                 Engineering
-- Jenny Murphy                 Producer
-- David Alonzo                 Assistant Producer
-- Tyler Chan                   Associate Producer
-- Karla Quiros                 Manager Business Finance & Ops
-- Mayene de la Cruz            Art Production Lead
-- Thomas Hindmarch             Production Coordinator
-- Special thanks to R&D

