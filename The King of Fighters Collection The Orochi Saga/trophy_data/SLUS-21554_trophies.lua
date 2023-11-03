-- Lua 5.3
-- Titles: The King of Fighters Collection - The Orochi Saga
-- Trophies version: 1.03
-- Author: David Haywood
-- Date: December 2016/Jan 2017

--[[

for

BOOT2 = cdrom0:\SLUS_215.54;1
VER = 1.02
VMODE = NTSC

and

BOOT2 = cdrom0:\SLES_553.73;1
VER = 1.00
VMODE = PAL


Changes for 1.03 Trophy Set

Trophy 7, 13, 19, 22
Changed from "without losing a character" to "without using a continue"

Trophy 34, 35, 36, 37 and 38
Removed "without losing"



--]]

--[[

Notes

Kof97 has a bonus 1-on-1 fight as part of one of the endings, this isn't considered by the game to be
a regular fight, just a bonus / secret, you won't get a continue screen if you lose it.  I'm counting
the 'win game' as happening prior to this fight, because that seems consistent with the game logic.

--]]

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.8)
-- 0.8 to enable to enable:
-- Emu::ForceRefreshRate(int)
		
-- obtain necessary objects.
local eeObj			= getEEObject()
local emuObj		= getEmuObject()
local trophyObj		= getTrophyObject()
local dmaObj		= getDmaObject()

-- load configuration if exist
local SaveData		= emuObj.LoadConfig(0)

-- 1 for US
-- 2 for Europe
local Region = 1

local allow_awards = 1

-- Set this to 1 to force the emulated NeoGeo region to be Japan
local HackNeoGeoRegionToBeJapan = 0

--[[###################################################################################################################
#######################################################################################################################

  Adjusted Memory Read/Write operations

  when data stored in memory differs by a common offset between regions these functions are handy

###################################################################################################################--]]

-- Initial offsets based on European version
local AdjustForRegion = 0

function Adjusted_WM32(base, data)
	eeObj.WriteMem32(base + AdjustForRegion, data)
end

function Adjusted_WM16(base, data)
	eeObj.WriteMem16(base + AdjustForRegion, data)
end

function Adjusted_WM8(base, data)
	eeObj.WriteMem8(base + AdjustForRegion, data)
end

function Adjusted_WMFloat(base, data)
	eeObj.WriteMemFloat(base + AdjustForRegion, data)
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

function Adjusted_RMFloat(base)
	return eeObj.ReadMemFloat(base + AdjustForRegion)
end

function Adjusted_W_bitset_8(base, bit)
	local u8val = eeObj.ReadMem8(base + AdjustForRegion)
	local bitmask = 1 << bit
	u8val = u8val | bitmask
	eeObj.WriteMem8(base + AdjustForRegion, u8val)
end

function Adjusted_W_bitclear_8(base, bit)
	local u8val = eeObj.ReadMem8(base + AdjustForRegion)
	local bitmask = 1 << bit
	bitmask = bitmask ~0xff
	
	u8val = u8val & bitmask
	eeObj.WriteMem8(base + AdjustForRegion, u8val)
end

function Adjusted_R_bit_8(base, bit)	
	local u8val = eeObj.ReadMem8(base + AdjustForRegion)
	local bitmask = 1 << bit
	u8val = u8val & bitmask
	u8val = u8val >> bit
						
	return u8val
end


function NeoGeo_WM8(address, data)

	local tempaddress = address & ~3
	
	address = address & 3
	if (address==0) then
		tempaddress = tempaddress + 1
	elseif (address==1) then
		tempaddress = tempaddress + 0
	elseif (address==2) then
		tempaddress = tempaddress + 3
	elseif (address==3) then
		tempaddress = tempaddress + 2
	end
	
	eeObj.WriteMem8(tempaddress, data)
end


function NeoGeo_RM8(address)

	local tempaddress = address & ~3
	
	address = address & 3
	if (address==0) then
		tempaddress = tempaddress + 1
	elseif (address==1) then
		tempaddress = tempaddress + 0
	elseif (address==2) then
		tempaddress = tempaddress + 3
	elseif (address==3) then
		tempaddress = tempaddress + 2
	end
	
	return eeObj.ReadMem8(tempaddress)
end

--[[###################################################################################################################
#######################################################################################################################

  Generic Award Function

###################################################################################################################--]]


function AwardTrophy(trophy_id, savetext, awardbits)

	if allow_awards == 1 then

		local temp = SaveData[savetext]
		local oldtemp = temp
		
		temp = temp | awardbits
		
		SaveData[savetext] = temp
		
		print( string.format("############################## setting trophy bits %02x for trophy_id=%d (%s) NEW VALUE is %02x  #########################", awardbits, trophy_id, savetext, SaveData[savetext] ) )

		if SaveData[savetext] == 0xff then

			print( string.format("############################## AWARDING trophy_id=%d (%s) #########################", trophy_id, savetext) )
			trophyObj.Unlock(trophy_id)		 
		end
		
		if oldtemp ~= temp then
			emuObj.SaveConfig(0, SaveData)
		end

	else
		--print( string.format("############################## NOT AWARDING trophy_id=%d (%s) (BLOCKED BY CHEAT?) #########################", trophy_id, savetext) )
	end
	
end

--[[###################################################################################################################
#######################################################################################################################

  Generic Helper Functions

###################################################################################################################--]]

function InitSave(savetext, trophyid)
	if SaveData[savetext] == nil then
		SaveData[savetext] = 0
		emuObj.SaveConfig(0, SaveData)
	end
end

function CheckTrophyState(savetext, trophyid)
	return SaveData[savetext]
end

local InitSaves = function()
-- KOF94
	InitSave("StayFree", 1)
	InitSave("ShotGlory", 2)
	InitSave("CrowdFave", 3)
-- KOF95
	InitSave("YouCantKeepBadManDown", 4)	
	InitSave("IgotMeAshovel", 5)	
	InitSave("ScionOfTheFlame", 6)	
	InitSave("ReturningChampion", 7)	
-- KOF96
	InitSave("CalmSkies", 8)	
	InitSave("SevenYearsBadLuck", 9)	
	InitSave("OldBusiness", 10)	
	InitSave("SunMoonMirror", 11)	
	InitSave("WildWind", 12)	
	InitSave("MyFavourite", 13)	
-- KOF97
	InitSave("Penguined", 14)	
	InitSave("RestIsSilence", 15)	
	InitSave("SacredWeapons", 16)	
	InitSave("Freak", 17)	
	InitSave("DancingWithMyself", 18)	
	InitSave("Fighters2Beat", 19)	
	InitSave("ApocalypseDenied", 20)	
-- KOF98
	InitSave("AlphaOmega", 21)	
	InitSave("Retire", 22)	
-- Challenges
	InitSave("Chal1", 23)	
	InitSave("Chal2", 24)	
	InitSave("Chal3", 25)	
	InitSave("Chal4", 26)	
	InitSave("Chal5", 27)	
	InitSave("Chal6", 28)	
	InitSave("Chal7", 29)	
	InitSave("Chal8", 30)	
	InitSave("Chal9", 31)	
	InitSave("ChalALL", 32)	
-- Story
	InitSave("TheRealStory", 33)
-- Team Trophies
	InitSave("FatalFuryTeam", 34)
	InitSave("ArtOfFightingTeam", 35)
	InitSave("PsychoSoldierTeam", 36)
	InitSave("TeamKorea", 37)
	InitSave("IkariTeam", 38)
	InitSave("WomensTeam", 39)	
end

InitSaves()


--[[###################################################################################################################
#######################################################################################################################

Platinum	    The King of Fighters Collection - The Orochi Saga	        1	Keeper of Sacred Treasures	Unlock all other trophies.	

Bronze	        The King of Fighters '94	                                2	Stay Free	                    KOF94: Defeat Rugal aboard the Blacknoah.	Rugal turns competitors he beats into statues for his collection, and "stay free" is a saying from the fighting-game community, so it's a double meaning.
Bronze (Hidden)	The King of Fighters '94	                                3	One Shot at Glory	            KOF94: Complete the tournament as Team USA without losing a match.	After this game, the "Sports Team" becomes a running joke, and never appears again in playable form in a game that's part of the canon.
Silver	        The King of Fighters '94	                                4	Crowd Favorite              	KOF94: Clear the Arcade mode without losing a match.	

Bronze	        The King of Fighters '95                                 	5	You Can't Keep A Bad Man Down	KOF95: Defeat Rugal. Again.	
Bronze	        The King of Fighters '95	                                6	Not Dead Yet	                KOF95: Defeat Saisyu Kusanagi.	
Bronze (Hidden)	The King of Fighters '95	                                7	Scion of the Flame	            KOF95: As Kyo, defeat Saisyu Kusanagi on your own.	When you reach his fight, send Kyo in first and beat Saisyu with just him, without getting knocked out.
Silver        	The King of Fighters '95	                                8	Returning Champion	            KOF95: Clear the Arcade mode without losing a character.	

Bronze	        The King of Fighters '96	                                9	Calm Skies	                    KOF96: Defeat Goenitz.	
Bronze	        The King of Fighters '96	                                10	Seven Years' Bad Luck	        KOF96: Defeat Chizuru Kagura.	She's the keeper of the sacred mirror, which is why she has a bunch of moves that involve illusions of herself.
Bronze	        The King of Fighters '96	                                11	Old Business	                KOF96: Defeat the Boss Team of Geese, Krauser, and Mr. Big.	
Bronze (Hidden)	The King of Fighters '96	                                12	Sun, Moon, and Mirror	        KOF96: Defeat Goenitz with a team of Kyo, Iori, and Kagura.	This is one of two edited teams that have their own endings in '96.
Bronze (Hidden)	The King of Fighters '96	                                13	The Wildly-Blowing Wind   	    KOF96: Defeat Goenitz with a team that includes Goenitz.	It doesn't matter who else is on the team. This team also has its own ending.
Silver         	The King of Fighters '96	                                14	The Odds-On Favorite	        KOF96: Clear the Arcade mode without losing a character.	

Bronze	        The King of Fighters '97	                                15	Sealed Away Once Again	        KOF97: Defeat Orochi.	
Bronze         	The King of Fighters '97                                  	16	And the Rest is Silence	        KOF97: Defeat the "real" New Faces Team.	In their overpowered "Orochi" equivalents, the New Faces are this game's second-to-last fight.
Bronze (Hidden)	The King of Fighters '97	                                17	Three Sacred Weapons	        KOF97: Defeat Orochi with a team of Kyo, Iori, and Kagura and see the game's true ending.	
Silver (Hidden)	The King of Fighters '97                                	18	Neo Geo Freak	                KOF97: See all of the special team edit endings.	Several edited teams receive their own special endings after beating Orochi, although all are simple still shots: Kyo/Shingo/anyone but Iori; Kyo, Terry, and Ryo; Benimaru, Joe, and Kim; King, Mai, and Yuri; and Ralf, Clark, and Athena.
Bronze (Hidden)	The King of Fighters '97	                                19	Dancing With Myself	            KOF97: Defeat Orochi and his minions with Orochi and his minions.	Pick the New Faces Team, and when you reach the battle with the Orochi New Faces Team, pick Chris to go first. Defeat all three of them and then Orochi without getting Chris knocked out.
Silver        	The King of Fighters '97	                                20	The Fighters to Beat	        KOF97: Clear the Arcade mode without losing a character.	
Gold (Hidden)	The King of Fighters '97	                                21	Apocalypse Denied	            KOF97: Defeat Orochi with a single character.	

Bronze	        The King of Fighters '98	                                22	Alpha, Meet Omega	            KOF98: Defeat Omega Rugal.	
Silver	        The King of Fighters '98	                                23	Retire My Gloves	            KOF98: Clear the Arcade mode without losing a character.	


********** NOT POSSIBLE, you don't unlock one thing at a time ****************
Silver	        The King of Fighters Collection - The Orochi Saga	        24	The Art of Fighting	                        Unlock all the pictures in Art Gallery 1.	
Silver         	The King of Fighters Collection - The Orochi Saga	        25	Art of Fighting 2	                        Unlock all the pictures in Art Gallery 2.	
Silver	        The King of Fighters Collection - The Orochi Saga	        26	The Path of the Artist: Art of Fighting 3	Unlock all the pictures in Art Gallery 3.	
Silver	        The King of Fighters Collection - The Orochi Saga	        27	Real Bout Art of Fighting	                Unlock all the pictures in Art Gallery 4.	There wasn't an AOF4, so I'm using the name of the fourth Fatal Fury.
Silver	        The King of Fighters Collection - The Orochi Saga	        28	OST '94	                                    Unlock the entire soundtrack for KOF94.	You unlock both the OST and Arranged tracks one at a time by completing specific Challenges. The trophy should require all of both.
Silver	        The King of Fighters Collection - The Orochi Saga	        29	OST '95	                                    Unlock the entire soundtrack for KOF95.	You unlock both the OST and Arranged tracks one at a time by completing specific Challenges. The trophy should require all of both.
Silver	        The King of Fighters Collection - The Orochi Saga	        30	OST '96	                                    Unlock the entire soundtrack for KOF96.	You unlock both the OST and Arranged tracks one at a time by completing specific Challenges. The trophy should require all of both.
Silver	        The King of Fighters Collection - The Orochi Saga	        31	OST '97                                    	Unlock the entire soundtrack for KOF97.	You unlock both the OST and Arranged tracks one at a time by completing specific Challenges. The trophy should require all of both.
Silver	        The King of Fighters Collection - The Orochi Saga	        32	OST '98	                                    Unlock the entire soundtrack for KOF98.	You unlock both the OST and Arranged tracks one at a time by completing specific Challenges. The trophy should require all of both.
*********** REPLACEMENTS ******************************************************
Silver	        The King of Fighters Collection - The Orochi Saga	        24	Advanced Entertainment System               Complete all CHallenges listed under 'Advanced'
Silver         	The King of Fighters Collection - The Orochi Saga	        25	The Orochi Saga EX                          Complete all Challenges listed under 'Extra'	
Silver	        The King of Fighters Collection - The Orochi Saga	        26	All Out Attack                            	Complete all Challenges listed under 'Offense'	
Silver	        The King of Fighters Collection - The Orochi Saga	        27	A Brick Wall	                            Complete all Challenges listed under 'Defense'	
Silver	        The King of Fighters Collection - The Orochi Saga	        28	C-C-C-C-Challenges                          Complete all Challenges listed under 'Combo'	
Silver	        The King of Fighters Collection - The Orochi Saga	        29	Tough Guy	                                Complete all Challenges listed under 'Endurance'	
Silver	        The King of Fighters Collection - The Orochi Saga	        30	Tick Tock Challenge                         Complete all Challenges listed under 'Time Trial'
Silver	        The King of Fighters Collection - The Orochi Saga	        31	Desperation Takes Hold                     	Complete all Challenges listed under 'DMs'
Silver	        The King of Fighters Collection - The Orochi Saga	        32	Ssssh, Don't Tell Anyone                    Complete all Challenges listed under 'Secret Characters'
****************************************************************************
Gold	        The King of Fighters Collection - The Orochi Saga	        33	The King of Challenges	                    Complete all the Challenges.	

Silver (Hidden)	The King of Fighters Collection - The Orochi Saga	        34	The Real Story	                            Play through the canonical version of the Orochi Saga.	Beat KOF94, 95, and 96 as Team Japan, then beat KOF97 with Kyo, Iori, and Kagura. KOF98 is deliberately plotless, so it doesn't matter.

Bronze (Hidden)	The King of Fighters Collection - The Orochi Saga	        35	The Legend of the Hungry Wolves	            Clear all five games with the Fatal Fury Team without losing a match.	
Bronze (Hidden)	The King of Fighters Collection - The Orochi Saga	        36	Doing the Dojo Proud	                    Clear all five games with the Art of Fighting Team without losing a match.	It's Ryo, Robert, and Takuma in '94 and '95, then it's Ryo, Robert, and Yuri in '96, '97, and '98.
Bronze (Hidden)	The King of Fighters Collection - The Orochi Saga	        37	This One's For My Fans                     	Clear all five games with the Psycho Soldier Team without losing a match.	
Bronze (Hidden)	The King of Fighters Collection - The Orochi Saga	        38	For Justice                              	Clear all five games with Team Korea without losing a match.	
Bronze (Hidden)	The King of Fighters Collection - The Orochi Saga	        39	Ikari Warriors	                            Clear all five games with the Ikari Team without losing a match.	It's Heidern, Ralf, and Clark in '94 and '95, then switches to Leona, Ralf, and Clark in '96 and onward.
Bronze (Hidden)	The King of Fighters Collection - The Orochi Saga	        40	Party at Café Illusion	                    Clear all five games with the Women Fighters' Team without losing a match.	In '94 and '95, the team is King, Mai, and Yuri. Kasumi joins in Yuri's place in '96, and in '97 and '98, Kagura takes Kasumi's place.
  
###################################################################################################################--]]

local Kof94Names = 
 {
-- Brazil -->
--[[00--]]"Heidern",
--[[01--]]"Ralf",
--[[02--]]"Clark",
-- China -->
--[[03--]]"Athena A",
--[[04--]]"Sie Kensou",
--[[05--]]"Chin Gentsai",
-- Japan -->
--[[06--]]"Kyo Kusanagi",
--[[07--]]"Benimaru N",
--[[08--]]"Goro Daimon",
-- USA -->
--[[09--]]"Heavy D",
--[[0A--]]"Lucky Clauber",
--[[0B--]]"Brian Battler",
-- Korea -->
--[[0C--]]"Kim Kaphnan",
--[[0D--]]"Chang Koehan",
--[[0E--]]"Chot Boonge",
-- Italy -->
--[[0F--]]"Terry Bogard",
--[[10--]]"Andy Bogard",
--[[11--]]"Joe Higashi",
-- Mexico -->
--[[12--]]"Ryo Sakazaki",
--[[13--]]"Robert Garcia",
--[[14--]]"Takuma S",
-- England -->
--[[15--]]"Yuri Sakazaki",
--[[16--]]"Mai Shiranui",
--[[17--]]"King",
-- Boss -->
--[[18--]]"Rugal B",
"David Haywood" -- need a 19th entry because it gets used during the boss fight, even if the character never is
}

local Kof94NumChars = 0x18

local Kof95Names = 
 {
--[[00--]] "Heidern",
--[[01--]] "Ralf",
--[[02--]] "Clark",
--[[03--]] "Athena",
--[[04--]] "Kensou",
--[[05--]] "Chin",
--[[06--]] "Kyo",
--[[07--]] "Benimaru",
--[[08--]] "Daimon",
--[[09--]] "Iori",
--[[0A--]] "Eiji",
--[[0B--]] "Billy",
--[[0C--]] "Kim",
--[[0D--]] "Chang",
--[[0E--]] "Choi",
--[[0F--]] "Terry",
--[[10--]] "Andy",
--[[11--]] "Joe",
--[[12--]] "Ryo",
--[[13--]] "Robert",
--[[14--]] "Takuma",
--[[15--]] "Yuri",
--[[16--]] "Mai",
--[[17--]] "King",
--[[18--]] "Saisyu Kusanagi",
--[[19--]] "Omega Rugal",
}

local Kof95NumChars = 0x19


local Kof96Names = 
{
--[[00--]] "Kyo Kusanagi",
--[[01--]] "Benimaru Nikaido",
--[[02--]] "Goro Daimon",
--[[03--]] "Terry Bogard",
--[[04--]] "Andy Bogard",
--[[05--]] "Joe Higashi",
--[[06--]] "Ryo Sakazaki",
--[[07--]] "Robert Garcia",
--[[08--]] "Yuri Sakazaki",
--[[09--]] "Leona",
--[[0A--]] "Ralf Jones",
--[[0B--]] "Clark Steel",
--[[0C--]] "Athena Asamiya",
--[[0D--]] "Sie Kensou",
--[[0E--]] "Chin Gentsai",
--[[0F--]] "Kasumi Todo",
--[[10--]] "Mai Shiranui",
--[[11--]] "King",
--[[12--]] "Kim Kaphwan",
--[[13--]] "Chang Koehan",
--[[14--]] "Choi Bounge",
--[[15--]] "Iori Yagami",
--[[16--]] "Mature",
--[[17--]] "Vice",
--[[18--]] "Geese Howard",
--[[19--]] "Wolfgang Krauser",
--[[1A--]] "Mr. Big",
--[[1B--]] "#Chizuru Kagura",
--[[1C--]] "#Goenitz",
}

local Kof96NumChars = 0x1C


local Kof97Names = 
{
--[[00--]] "Kyo Kusanagi",
--[[01--]] "Benimaru Nikaido",
--[[02--]] "Goro Daimon",
--[[03--]] "Terry Bogard",
--[[04--]] "Andy Bogard",
--[[05--]] "Joe Higashi",
--[[06--]] "Ryo Sakazaki",
--[[07--]] "Robert Garcia",
--[[08--]] "Yuri Sakazaki",
--[[09--]] "Leona",
--[[0A--]] "Ralf Jones",
--[[0B--]] "Clark Steel",
--[[0C--]] "Athena Asamiya",
--[[0D--]] "Sie Kensou",
--[[0E--]] "Chin Gentsai",
--[[0F--]] "Chizuru Kagura",
--[[10--]] "Mai Shiranui",
--[[11--]] "King",
--[[12--]] "Kim Kaphwan",
--[[13--]] "Chang Koehan",
--[[14--]] "Choi Bounge",
--[[15--]] "Yashiro Nanakase",
--[[16--]] "Shermie",
--[[17--]] "Chris",
--[[18--]] "Ryuji Yamazaki",
--[[19--]] "Blue Mary",
--[[1A--]] "Billy Kane",
--[[1B--]] "Iori Yagami",
--[[1C--]] "#Orochi Iori",
--[[1D--]] "#Orochi Leona",
--[[1E--]] "#Orochi",
--[[1F--]] "Shingo Yabuki",
}

local Kof97NumChars = 0x1F

local Kof98Names = 
{
--[[00--]] "Kyo Kusanagi",
--[[01--]] "Benimaru Nikaido",
--[[02--]] "Goro Daimon",
--[[03--]] "Terry Bogard",
--[[04--]] "Andy Bogard",
--[[05--]] "Joe Higashi",
--[[06--]] "Ryo Sakazaki",
--[[07--]] "Robert Garcia",
--[[08--]] "Yuri Sakazaki",
--[[09--]] "Leona",
--[[0A--]] "Ralf Jones",
--[[0B--]] "Clark Steel",
--[[0C--]] "Athena Asamiya",
--[[0D--]] "Sie Kensou",
--[[0E--]] "Chin Gentsai",
--[[0F--]] "Chizuru Kagura",
--[[10--]] "Mai Shiranui",
--[[11--]] "King",
--[[12--]] "Kim Kaphwan",
--[[13--]] "Chang Koehan",
--[[14--]] "Choi Bounge",
--[[15--]] "Yashiro Nanakase",
--[[16--]] "Shermie",
--[[17--]] "Chris",
--[[18--]] "Ryuji Yamazaki",
--[[19--]] "Blue Mary",
--[[1A--]] "Billy Kane",
--[[1B--]] "Iori Yagami",
--[[1C--]] "Mature",
--[[1D--]] "Vice",
--[[1E--]] "Heidern",
--[[1F--]] "Takuma Sakazaki",
--[[20--]] "Saisyu Kusanagi",
--[[21--]] "Heavy D!",
--[[22--]] "Lucky Glauber",
--[[23--]] "Brian Battler",
--[[24--]] "Rugal Bernstein",
--[[25--]] "Shingo Yabuki",
}  
	  
local Kof98NumChars = 0x25




local currentGame = -1
local lastRomBase = -1
local textVramBase = -1 -- address of text VRAM for emulated NeoGeo
local RamBase = -1; -- address of main ram for emulated NeoGeo


local CurrentTeamP1 = { -1, -1, -1 }
local CurrentTeamP2 = { -1, -1, -1 }

local oldCurrentTeamP1 = { -1, -1, -1 }
local oldCurrentTeamP2 = { -1, -1, -1 }




local CharacterList = { }
local NumCharacters = -1



local CurrentPlayMode = -1

-- for the Current Game
local PlayerHasLostMatch = 0
local PlayerHasLostCharacter = 0
local PlayerDrawSpecial = 0
local PlayerKof96SpecialCheck = 0

-- Same on all games
local PlayerAdressBase = { 0x08100, 0x08300 }

local Kof94HealthAddr = 0x121
local Kof95HealthAddr = 0x121
local Kof96HealthAddr = 0x139
local Kof97HealthAddr = 0x139
local Kof98HealthAddr = 0x139

-- Kof 94 Character Orders are in THE PLAYER area, not the Game State area
local Kof94CharacterBase = 0x132
-- 132, 133, 134 are the character numbers
-- 135, 136, 137 are the character numbers in the order they're being used


local Kof94GameStateAddr = 0x08500 -- note, straight after the player area

local Kof95GameStateAddr = 0x0a700
local Kof96GameStateAddr = 0x0a700
local Kof97GameStateAddr = 0x0a700
local Kof98GameStateAddr = 0x0a700

local P1Kof95CharacterBase = 0x143
local P1Kof96CharacterBase = 0x146
local P1Kof97CharacterBase = 0x14B
local P1Kof98CharacterBase = 0x14E

local P2Kof95CharacterBase = 0x153
local P2Kof96CharacterBase = 0x157
local P2Kof97CharacterBase = 0x15c
local P2Kof98CharacterBase = 0x15f


function GetTextChar(x, y)

	if (textVramBase ~= -1) then
	
		local offset = ((x+1) * 0x40) + ((y+2)*2)
		
		return eeObj.ReadMem16((textVramBase+offset))
	
	end
	
	return 0


end

local Blank = { 0x00ff, 0x00ff } 

function checkstring(x,y,strng,baseval, mask)

	-- loops over all elements in Challenger
	local i = 1
	while strng[i] do
		
		local srctile = strng[i]
		srctile = srctile + baseval
		
		local txttile = GetTextChar(x,y)
	
		srctile = srctile & mask
		txttile = txttile & mask

		--if (strng==Blank) then
		--	print( string.format("test %04x %04x\n", srctile,txttile ) )
		--end
		
		if (txttile ~= srctile) then
			return 0
		end
		
		x = x + 1
		
		i = i + 1
	end	
			
	return 1
			
end


local P1HealthAddr = -1
local P2HealthAddr = -1

local MaxHealth = -1

local P1CharacterAddresses = { -1, -1, -1 }
local P2CharacterAddresses = { -1, -1, -1 }

local P1CharacterAddressesOrder = { -1, -1, -1 }
local P2CharacterAddressesOrder = { -1, -1, -1 }


local CharNumStyle = -1


local DoesTeamContain = function(player,ident)

	if (player==1) then	
		if (CurrentTeamP1[1] == ident) then return 1 end
		if (CurrentTeamP1[2] == ident) then return 1 end
		if (CurrentTeamP1[3] == ident) then return 1 end
	end
	
	if (player==2) then	
		if (CurrentTeamP2[1] == ident) then return 1 end
		if (CurrentTeamP2[2] == ident) then return 1 end
		if (CurrentTeamP2[3] == ident) then return 1 end
	end
	
	return 0
end



local ResetGameStats = function()
	PlayerHasLostMatch = 0
	PlayerHasLostCharacter = 0
	PlayerDrawSpecial = 0
	PlayerKof96SpecialCheck = 0
end

local ResetVariables = function()
	P1HealthAddr = -1
	P2HealthAddr = -1
	
	MaxHealth = -1
	
	P1CharacterAddresses[1] = -1
	P1CharacterAddresses[2] = -1
	P1CharacterAddresses[3] = -1
	P2CharacterAddresses[1] = -1
	P2CharacterAddresses[2] = -1
	P2CharacterAddresses[3] = -1

	P1CharacterAddressesOrder[1] = -1
	P1CharacterAddressesOrder[2] = -1
	P1CharacterAddressesOrder[3] = -1
	P2CharacterAddressesOrder[1] = -1
	P2CharacterAddressesOrder[2] = -1
	P2CharacterAddressesOrder[3] = -1


	CharNumStyle = -1

	CurrentTeamP1[1] = -1
	CurrentTeamP1[2] = -1
	CurrentTeamP1[3] = -1
	
	CurrentTeamP2[1] = -1
	CurrentTeamP2[2] = -1
	CurrentTeamP2[3] = -1
	
	oldCurrentTeamP1[1] = -1
	oldCurrentTeamP1[2] = -1
	oldCurrentTeamP1[3] = -1
	
	oldCurrentTeamP2[1] = -1
	oldCurrentTeamP2[2] = -1
	oldCurrentTeamP2[3] = -1	
	
	CharacterList = { }
	
	CurrentPlayMode = -1
	
	ResetGameStats()
end


local oldLostFlag1 = -1
local oldLostFlag2 = -1
local oldLostFlag3 = -1
local oldLostFlag4 = -1




local TimeText = { 0xa688, 0xa689, 0xa68a, 0xa68b}


local ReFormatFlags = function(valx,valy)

	local newflag = -1

	if (valx == 0x06) and (valy == 0x01) then
		newflag = 0x00
	end

	if (valx == 0x86) and (valy == 0x01) then
		newflag = 0x01
	end
	
	if (valx == 0x04) and (valy == 0x02) then
		newflag = 0x01
	end		
	
	if (valx == 0x84) and (valy == 0x02) then
		newflag = 0x02
	end		
	
	if (valx == 0x00) and (valy == 0x04) then
		newflag = 0x02
	end			
	
	if (valx == 0x80) and (valy == 0x04) then
		newflag = 0x03
	end			

	-- Rugal
	if (valx == 0x02) and (valy == 0x01) then
		newflag = 0x00
	end

	if (valx == 0x82) and (valy == 0x01) then
		newflag = 0x00
	end
	
	if (valx == 0x00) and (valy == 0x02) then
		newflag = 0x01
	end		
	
	if (valx == 0x80) and (valy == 0x02) then
		newflag = 0x02
	end	

	return newflag
end

-- Give teams that have special meanings to the trophies specific return values for later checking / use
local FINALBOSSTEAM = 200

local FATAL_FURY_TEAM = 300
local ART_OF_FIGHTING_TEAM = 301
local PSYCHO_SOLDIER_TEAM = 302
local TEAM_KOREA = 303
local IKARI_TEAM = 304
local WOMENS_TEAM = 305

local TEAM_STORY = 400

local KOF94_TEAM_USA = 9400

local KOF95_KYO = 9500

local KOF96_BOSS = 9600
local KOF96_SPECIAL1 = 9601
local KOF96_SPECIAL2 = 9602
local KOF96_CHIZURA = 9603

local KOF97_SPECIAL1 = 9700
local KOF97_SPECIAL2 = 9701
local KOF97_SPECIAL3 = 9702
local KOF97_SPECIAL4 = 9703
local KOF97_SPECIAL5 = 9704
local KOF97_NEWFACES_REAL = 9705
local KOF97_NEWFACES_CHRISFIRST = 9706

local printImportantTeamsStringDEBUG = function(id)

	if (id == FINALBOSSTEAM) then print( string.format("--- A Final Boss Team ---\n" ) )
	elseif (id == FATAL_FURY_TEAM) then print( string.format("--- Fatal Fury Team ---\n" ) )
	elseif (id == ART_OF_FIGHTING_TEAM) then print( string.format("--- Art of Fighting Team ---\n" ) )
	elseif (id == PSYCHO_SOLDIER_TEAM) then print( string.format("--- Psycho Soldier Team ---\n" ) )
	elseif (id == TEAM_KOREA) then print( string.format("--- Korean Team ---\n" ) )
	elseif (id == IKARI_TEAM) then print( string.format("--- Ikari Team ---\n" ) )
	elseif (id == WOMENS_TEAM) then print( string.format("--- Womens Team ---\n" ) )
	elseif (id == TEAM_STORY) then print( string.format("--- Team Japan (Story team) ---\n" ) )
	
	elseif (id == KOF94_TEAM_USA) then print( string.format("--- KOF94 Special - Team USA ---\n" ) )

	elseif (id == KOF95_KYO) then print( string.format("--- KOF95 Special - Team containing Kyo ---\n" ) )

	elseif (id == KOF96_BOSS) then print( string.format("--- KOF96 Special - 'Boss Team' ---\n" ) )
	elseif (id == KOF96_SPECIAL1) then print( string.format("--- KOF96 Special - 'Special Ending Team 1' ---\n" ) )
	elseif (id == KOF96_SPECIAL2) then print( string.format("--- KOF96 Special - 'Special Ending Team 2' ---\n" ) )
	elseif (id == KOF96_CHIZURA) then print( string.format("--- KOF96 Special - 'Sub-Boss' ---\n" ) )

	elseif (id == KOF97_SPECIAL1) then print( string.format("--- KOF97 Special - 'Special Ending Team 1' ---\n" ) )
	elseif (id == KOF97_SPECIAL2) then print( string.format("--- KOF97 Special - 'Special Ending Team 2' ---\n" ) )
	elseif (id == KOF97_SPECIAL3) then print( string.format("--- KOF97 Special - 'Special Ending Team 3' ---\n" ) )
	elseif (id == KOF97_SPECIAL4) then print( string.format("--- KOF97 Special - 'Special Ending Team 4' ---\n" ) )
	elseif (id == KOF97_SPECIAL5) then print( string.format("--- KOF97 Special - 'Special Ending Team 5' ---\n" ) )
	elseif (id == KOF97_NEWFACES_REAL) then print( string.format("--- KOF97 Special - 'New Faces overpowered' ---\n" ) )
	elseif (id == KOF97_NEWFACES_CHRISFIRST) then print( string.format("--- KOF97 Special - 'New Faces with CHRIS fighting first' ---\n" ) )
	else print( string.format("--- regular team, nothing special to check ---\n" ) ) end
	
end

local DoesTeamMatch = function(WhichTeamx, ch1, ch2, ch3)

	local match1 = DoesTeamContain(WhichTeamx, ch1)
	local match2 = DoesTeamContain(WhichTeamx, ch2)
	local match3 = DoesTeamContain(WhichTeamx, ch3)

	if match1 == 1 and match2 == 1 and match3 ==1 then
		return 1
	end
	
	return 0
end

local DoesTeamMatchEXACT = function(player, ch1, ch2, ch3)

	if (player==1) then	
		if (CurrentTeamP1[1] == ch1) and (CurrentTeamP1[2] == ch2) and (CurrentTeamP1[3] == ch3) then return 1 end
	end
	
	if (player==2) then	
		if (CurrentTeamP2[1] == ch1) and (CurrentTeamP2[2] == ch2) and (CurrentTeamP2[3] == ch3) then return 1 end
	end
		
	return 0
end

local IsTeamEntirely = function(player, ident)

	if (player==1) then	
		if (CurrentTeamP1[1] == ident) and (CurrentTeamP1[2] == ident) and (CurrentTeamP1[3] == ident) then return 1 end
	end
	
	if (player==2) then	
		if (CurrentTeamP2[1] == ident) and (CurrentTeamP2[2] == ident) and (CurrentTeamP2[3] == ident) then return 1 end
	end
	
	return 0
	
end

local CheckSpecialCostume = function(WhichTeamx)

	if RamBase == -1 then
		return 0
	end
	
	if (currentGame ~= 97) then
		return 0
	end
	
	local addr = 0
	
	if (WhichTeamx==1) then addr = RamBase + Kof97GameStateAddr + 0x157 end
	if (WhichTeamx==2) then addr = RamBase + Kof97GameStateAddr + 0x157 + 0x11 end

	local costumes = NeoGeo_RM8(addr)
	
	if (costumes & 3) ~= 0 then return 1
	else return 0 end
	
end

local GetFightingFirst = function(WhichTeamx)

	if RamBase == -1 then
		return 0
	end

	if CharNumStyle == 1 then
		-- Direct 
		local first = -1
		-- kof94 style
		if WhichTeamx == 1 then
			first = NeoGeo_RM8(P1CharacterAddressesOrder[1])
		elseif WhichTeamx == 2 then
			first = NeoGeo_RM8(P2CharacterAddressesOrder[1])
		end
		
		return first
	
	elseif CharNumStyle == 2 then
		-- kof95, 96,97,98 style
	
		local first = -1
	
		if WhichTeamx == 1 then
			first = NeoGeo_RM8(P1CharacterAddressesOrder[1])
			
			local chr = -1
				
			if first == 0x00 then chr = NeoGeo_RM8(P1CharacterAddresses[1]) end
			if first == 0x01 then chr = NeoGeo_RM8(P1CharacterAddresses[2]) end
			if first == 0x02 then chr = NeoGeo_RM8(P1CharacterAddresses[3]) end
			
			return chr
			
		elseif WhichTeamx == 2 then
			first = NeoGeo_RM8(P2CharacterAddressesOrder[1])
			
			local chr = -1
				
			if first == 0x00 then chr = NeoGeo_RM8(P2CharacterAddresses[1]) end
			if first == 0x01 then chr = NeoGeo_RM8(P2CharacterAddresses[2]) end
			if first == 0x02 then chr = NeoGeo_RM8(P2CharacterAddresses[3]) end
			
			return chr			
		end	
	end
end


local IdentifyTeam = function(WhichTeamx)

	local matchCheck = -1

	if (currentGame == 94) then
		
		-- #########################################################################################################
		-- #########################################################################################################
		-- FINAL BOSS
		-- #########################################################################################################
		-- #########################################################################################################
		
		local fightingRugal1 = DoesTeamContain(WhichTeamx, 0x18)
		local fightingRugal2 = DoesTeamContain(WhichTeamx, 0x19) -- needs to contain this invalid character too
		
		if fightingRugal1 == 1 and fightingRugal2 == 1 then
			return FINALBOSSTEAM
		end
		
		--[[
		
		Lua     (  2abe10-e d4febd9e): (Not valid outside of a fight) We Appear to have a new Team Configuration of (0f 10 11) and (19 19 18)
		Lua     (  2abe10-e d4febd9e): Which would be a team of
		Lua     (  2abe10-e d4febd9e): Terry Bogard
		Lua     (  2abe10-e d4febd9e): Andy Bogard
		Lua     (  2abe10-e d4febd9e): Joe Higashi
		Lua     (  2abe10-e d4febd9e): vs
		Lua     (  2abe10-e d4febd9e): INVALID
		Lua     (  2abe10-e d4febd9e): INVALID
		Lua     (  2abe10-e d4febd9e): Rugal B
		Lua     (  2abe10-e d4febd9e): Fighting First is  (Terry Bogard)   VS   (Rugal B)
		
		--]]

		-- #########################################################################################################
		-- #########################################################################################################
		-- Teams for Trophies 36-41
		-- #########################################################################################################
		-- #########################################################################################################

		-- Fatal Fury Team (Italy)
		-- Terry Bogard, Andy Bogard, Joe Higashi
		matchCheck = DoesTeamMatch(WhichTeamx, 0x0f, 0x10, 0x11)
		if matchCheck == 1 then return FATAL_FURY_TEAM end
		
		-- Art of Fighting Team (Mexico)
		-- Ryo, Robert, Takuma
		matchCheck = DoesTeamMatch(WhichTeamx, 0x12, 0x13, 0x14)
		if matchCheck == 1 then return ART_OF_FIGHTING_TEAM end

		-- Psycho Soldier Team (China)
		--  Athena A, Sie Kensou, Chin Gentsai
		matchCheck = DoesTeamMatch(WhichTeamx, 0x03, 0x04, 0x05)
		if matchCheck == 1 then return PSYCHO_SOLDIER_TEAM end
	
		-- Team Korea
		-- Kim Kaphnan, Chang Koehan, Chot Boonge
		matchCheck = DoesTeamMatch(WhichTeamx, 0x0c, 0x0d, 0x0e)
		if matchCheck == 1 then return TEAM_KOREA end
	
		-- Ikari Team (Brazil)
		-- Heidern, Ralf, Clark	
		matchCheck = DoesTeamMatch(WhichTeamx, 0x00 , 0x01, 0x02)
		if matchCheck == 1 then return IKARI_TEAM end
		
		--Women's Fighters' Team (England)
		--94 King, Mai, Yuri
		matchCheck = DoesTeamMatch(WhichTeamx, 0x15 , 0x16, 0x17)
		if matchCheck == 1 then return WOMENS_TEAM end
	
		-- #########################################################################################################
		-- #########################################################################################################
		-- Story
		-- #########################################################################################################
		-- #########################################################################################################

		-- Team Japan
		-- Kyo Kusanagi, Benimaru N, Goro Daimon
		matchCheck = DoesTeamMatch(WhichTeamx, 0x06 , 0x07, 0x08)
		if matchCheck == 1 then return TEAM_STORY end

	
		-- #########################################################################################################
		-- #########################################################################################################
		-- Others
		-- #########################################################################################################
		-- #########################################################################################################

		-- Team USA
		-- Heavy D, Lucky Clauber, Brian Battler
		matchCheck = DoesTeamMatch(WhichTeamx, 0x09 , 0x0a, 0x0b)
		if matchCheck == 1 then return KOF94_TEAM_USA end
	
	end


	if (currentGame == 95) then

		-- #########################################################################################################
		-- #########################################################################################################
		-- FINAL BOSS
		-- #########################################################################################################
		-- #########################################################################################################

		-- Saisyu Kusanagi.
		-- also used for sub-boss Rugal (sub-boss) as this counts as one fight
		matchCheck = DoesTeamMatchEXACT(WhichTeamx, 0x18, 0x19, 0x19)
		if matchCheck == 1 then return FINALBOSSTEAM end

		-- #########################################################################################################
		-- #########################################################################################################
		-- Teams for Trophies 36-41
		-- #########################################################################################################
		-- #########################################################################################################

		-- Fatal Fury Team (Italy)
		matchCheck = DoesTeamMatch(WhichTeamx, 0x0f, 0x10, 0x11)
		if matchCheck == 1 then return FATAL_FURY_TEAM end
		
		
		-- Art of Fighting Team
		matchCheck = DoesTeamMatch(WhichTeamx, 0x12, 0x13, 0x14)
		if matchCheck == 1 then return ART_OF_FIGHTING_TEAM end
		
		
		-- Psycho Soldier Team
		matchCheck = DoesTeamMatch(WhichTeamx, 0x03, 0x04, 0x05)
		if matchCheck == 1 then return PSYCHO_SOLDIER_TEAM end
	
		
		-- Team Korea
		matchCheck = DoesTeamMatch(WhichTeamx, 0x0c, 0x0d, 0x0e)
		if matchCheck == 1 then return TEAM_KOREA end
	
		
		-- Ikari Team
		matchCheck = DoesTeamMatch(WhichTeamx, 0x00, 0x01, 0x02)
		if matchCheck == 1 then return IKARI_TEAM end
		
		
		--Women's Fighters' Team
		matchCheck = DoesTeamMatch(WhichTeamx, 0x15, 0x16, 0x17)
		if matchCheck == 1 then return WOMENS_TEAM end
	
		-- #########################################################################################################
		-- #########################################################################################################
		-- Story
		-- #########################################################################################################
		-- #########################################################################################################

		-- Team Japan
		matchCheck = DoesTeamMatch(WhichTeamx, 0x06, 0x07, 0x08)
		if matchCheck == 1 then return TEAM_STORY end
	
		
		-- #########################################################################################################
		-- #########################################################################################################
		-- Others
		-- #########################################################################################################
		-- #########################################################################################################
		
		-- any team with Kyo **FIGHTING FIRST**
		-- 06  (NOTE, needs extra logic elsewhere, TEAM_STORY also satisfies this condition so needs checking for?)
		local matchCheck = DoesTeamContain(WhichTeamx, 0x06)
		if matchCheck == 1 then return TEAM_STORY end
		-- due to Japan also satisfying this, check later instead
		--local first = GetFightingFirst(WhichTeamx)	
		--if first == 0x06 then return KOF95_KYO end	
		
		--[[
			Lua     (  2abe10-e a83dec84): (Not valid outside of a fight) We Appear to have a new Team Configuration of (06 07 08) and (18 19 19)
			Lua     (  2abe10-e a83dec84): Which would be a team of
			Lua     (  2abe10-e a83dec84): Kyo
			Lua     (  2abe10-e a83dec84): Benimaru
			Lua     (  2abe10-e a83dec84): Daimon
			Lua     (  2abe10-e a83dec84): vs
			Lua     (  2abe10-e a83dec84): Saisyu Kusanagi
			Lua     (  2abe10-e a83dec84): Omega Rugal
			Lua     (  2abe10-e a83dec84): Omega Rugal
		--]]
		
	end
	
	
	if (currentGame == 96) then

		-- #########################################################################################################
		-- #########################################################################################################
		-- FINAL BOSS
		-- #########################################################################################################
		-- #########################################################################################################

		-- Goenitz
		matchCheck = IsTeamEntirely(WhichTeamx,0x1c)
		if matchCheck == 1 then return FINALBOSSTEAM end	
	
		
		-- #########################################################################################################
		-- #########################################################################################################
		-- Teams for Trophies 36-41
		-- #########################################################################################################
		-- #########################################################################################################

		-- Fatal Fury Team (Italy)
		matchCheck = DoesTeamMatch(WhichTeamx, 0x03, 0x04, 0x05)
		if matchCheck == 1 then return FATAL_FURY_TEAM end
		
		
		-- Art of Fighting Team
		--  Ryo, Robert, and Yuri 
		matchCheck = DoesTeamMatch(WhichTeamx, 0x06, 0x07, 0x08)
		if matchCheck == 1 then return ART_OF_FIGHTING_TEAM end
		
		-- Psycho Soldier Team
		-- Athena, Sie, Chin
		matchCheck = DoesTeamMatch(WhichTeamx, 0x0c, 0x0d, 0x0e)
		if matchCheck == 1 then return PSYCHO_SOLDIER_TEAM end
	
		-- Team Korea
		matchCheck = DoesTeamMatch(WhichTeamx,  0x12, 0x13, 0x14)
		if matchCheck == 1 then return TEAM_KOREA end
		
		
		-- Ikari Team
		-- Leona, Ralf, and Clark
		matchCheck = DoesTeamMatch(WhichTeamx, 0x09, 0x0a, 0x0b)
		if matchCheck == 1 then return IKARI_TEAM end
		
		--Women's Fighters' Team
		matchCheck = DoesTeamMatch(WhichTeamx, 0x0f, 0x10, 0x11)
		if matchCheck == 1 then return WOMENS_TEAM end
		
		
		-- #########################################################################################################
		-- #########################################################################################################
		-- Story
		-- #########################################################################################################
		-- #########################################################################################################
	
		-- Team Japan
		matchCheck = DoesTeamMatch(WhichTeamx, 0x00, 0x01, 0x02)
		if matchCheck == 1 then return TEAM_STORY end
	
		
		-- #########################################################################################################
		-- #########################################################################################################
		-- Others
		-- #########################################################################################################
		-- #########################################################################################################
	
		-- Chizuru Kagura. (sub-boss)
		-- 1B
		matchCheck = IsTeamEntirely(WhichTeamx,0x1b)
		if matchCheck == 1 then return KOF96_CHIZURA end	
	
		
--[[
Lua     (  2abe10-e 65d05963): (Not valid outside of a fight) We Appear to have a new Team Configuration of (00 01 0b) and (1b 1b 1b)
Lua     (  2abe10-e 65d05963): Which would be a team of
Lua     (  2abe10-e 65d05963): Kyo Kusanagi
Lua     (  2abe10-e 65d05963): Benimaru Nikaido
Lua     (  2abe10-e 65d05963): Clark Steel
Lua     (  2abe10-e 65d05963): vs
Lua     (  2abe10-e 65d05963): #Chizuru Kagura
Lua     (  2abe10-e 65d05963): #Chizuru Kagura
Lua     (  2abe10-e 65d05963): #Chizuru Kagura
Lua     (  2abe10-e 8380f36f): Kof 96/97/98 format Lost Flags  00 | 03
Lua     (  2abe10-e 8380f36f): PLAYER HAS WON MATCH
Lua     (  2abe10-e 80ad7182): Kof 96/97/98 format Lost Flags  00 | 00
Lua     (  2abe10-e b9dd39dd): (Not valid outside of a fight) We Appear to have a new Team Configuration of (00 01 0b) and (1c 1c 1c)
Lua     (  2abe10-e b9dd39dd): Which would be a team of
Lua     (  2abe10-e b9dd39dd): Kyo Kusanagi
Lua     (  2abe10-e b9dd39dd): Benimaru Nikaido
Lua     (  2abe10-e b9dd39dd): Clark Steel
Lua     (  2abe10-e b9dd39dd): vs
Lua     (  2abe10-e b9dd39dd): #Goenitz
Lua     (  2abe10-e b9dd39dd): #Goenitz
Lua     (  2abe10-e b9dd39dd): #Goenitz
Lua     (  2abe10-e ea52a1f1): Kof 96/97/98 format Lost Flags  00 | 03
Lua     (  2abe10-e ea52a1f1): PLAYER HAS WON MATCH
--]]
		
		-- KOF96: Defeat the Boss Team of Geese, Krauser, and Mr. Big.
		matchCheck = DoesTeamMatch(WhichTeamx, 0x18, 0x19, 0x1a)
		if matchCheck == 1 then return KOF96_BOSS end
	
		
		-- Special Endings
		-- Kyo, Iori, Kagura
		matchCheck = DoesTeamMatch(WhichTeamx, 0x00, 0x15, 0x1B)
		if matchCheck == 1 then return KOF96_SPECIAL1 end
	
	
		--*any player team with Goenitz*
		-- 1C ?
		local matchCheck = DoesTeamContain(WhichTeamx, 0x1c)
		if matchCheck == 1 then return KOF96_SPECIAL2 end

		
	end	
	
	
	if (currentGame == 97) then

		-- #########################################################################################################
		-- #########################################################################################################
		-- FINAL BOSS
		-- #########################################################################################################
		-- #########################################################################################################

		-- Orochi
		matchCheck = IsTeamEntirely(WhichTeamx,0x1e)
		if matchCheck == 1 then return FINALBOSSTEAM end	
		
	
		-- **there's also an ending fight with Iori in some conditions, but it's not a real part of the game
		--matchCheck = IsTeamEntirely(WhichTeamx,0x1b)
		--if matchCheck == 1 then return FINALBOSSTEAM end	
		
		-- #########################################################################################################
		-- #########################################################################################################
		-- Teams for Trophies 36-41
		-- #########################################################################################################
		-- #########################################################################################################

		-- Fatal Fury Team (Italy)
		matchCheck = DoesTeamMatch(WhichTeamx, 0x03, 0x04, 0x05)
		if matchCheck == 1 then return FATAL_FURY_TEAM end
	
		
		-- Art of Fighting Team
		--  Ryo, Robert, and Yuri
		matchCheck = DoesTeamMatch(WhichTeamx, 0x06, 0x07, 0x08)
			if matchCheck == 1 then return ART_OF_FIGHTING_TEAM end
	
		-- Psycho Soldier Team
		-- Athena, Sie, Chin
		matchCheck = DoesTeamMatch(WhichTeamx, 0x0c, 0x0d, 0x0e)
		if matchCheck == 1 then return PSYCHO_SOLDIER_TEAM end
	
		
		-- Team Korea
		-- Kim, Chang, Choi
		matchCheck = DoesTeamMatch(WhichTeamx, 0x12, 0x13, 0x14)
		if matchCheck == 1 then return TEAM_KOREA end
		
		
		-- Ikari Team
	    -- Leona, Ralf, and Clark
		matchCheck = DoesTeamMatch(WhichTeamx, 0x09, 0x0a, 0x0b)
		if matchCheck == 1 then return IKARI_TEAM end
		
		
		--Women's Fighters' Team
		-- Chizuru Kagura, Mai Shiranui, King
		matchCheck = DoesTeamMatch(WhichTeamx, 0x0f, 0x10, 0x11)
		if matchCheck == 1 then return WOMENS_TEAM end
	
		-- #########################################################################################################
		-- #########################################################################################################
		-- Story
		-- #########################################################################################################
		-- #########################################################################################################
		
		--  Kyo, Iori, and Kagura
		matchCheck = DoesTeamMatch(WhichTeamx, 0x00, 0x1b, 0x0f)
		if matchCheck == 1 then return TEAM_STORY end
	
		
		-- #########################################################################################################
		-- #########################################################################################################
		-- Others
		-- #########################################################################################################
		-- #########################################################################################################
		
		-- Real new faces (note, alt costume check needed)
		matchCheck = DoesTeamMatch(WhichTeamx, 0x15, 0x16, 0x17)
		local matchCheck2 = CheckSpecialCostume(WhichTeamx)

		if matchCheck == 1 and matchCheck2 == 1 then return KOF97_NEWFACES_REAL end
	
		-- Special Endings
		
		-- Kyo, Shingo, NOT Iori
		-- 00 1f BUT NOT 1b
		local special1 = DoesTeamContain(WhichTeamx, 0x00)
		local special2 = DoesTeamContain(WhichTeamx, 0x1f)
		local special3 = DoesTeamContain(WhichTeamx, 0x1b) -- can't contain
	
		if special1 == 1 and special2 == 1 and special3 == 0 then
			return KOF97_SPECIAL5
		end
	
		
		
		-- Kyo Terry, Ryo
		matchCheck = DoesTeamMatch(WhichTeamx, 0x00, 0x03, 0x06)
		if matchCheck == 1 then return KOF97_SPECIAL1 end
	
		
		-- Benimaru, Joe, Kim
		matchCheck = DoesTeamMatch(WhichTeamx, 0x01, 0x05, 0x12)
		if matchCheck == 1 then return KOF97_SPECIAL2 end
		
		-- King, Mai, Yuri
		matchCheck = DoesTeamMatch(WhichTeamx, 0x11, 0x10, 0x08)
		if matchCheck == 1 then return KOF97_SPECIAL3 end
	
		-- Ralf, Clark, Athena
		matchCheck = DoesTeamMatch(WhichTeamx, 0x0a, 0x0b, 0x0c)
		if matchCheck == 1 then return KOF97_SPECIAL4 end
	
		
		-- True Ending (same as Story)
		-- Kyo, Iori, Kagura

		-- New Faces Team (WITH CHRIS FIGHTING FIRST)
		matchCheck = DoesTeamMatch(WhichTeamx, 0x15, 0x16, 0x17)	
		local first = GetFightingFirst(WhichTeamx)		
		if matchCheck == 1 and first == 0x17 then return KOF97_NEWFACES_CHRISFIRST end
		
		--[[
				Lua     (  2abe10-e 789fb976): Kof 96/97/98 format Lost Flags  00 | 00
				Lua     (  2abe10-e ae9589cc): (Not valid outside of a fight) We Appear to have a new Team Configuration of (00 01 02) and (1c 1c 1c)
				Lua     (  2abe10-e ae9589cc): Which would be a team of
				Lua     (  2abe10-e ae9589cc): Kyo Kusanagi
				Lua     (  2abe10-e ae9589cc): Benimaru Nikaido
				Lua     (  2abe10-e ae9589cc): Goro Daimon
				Lua     (  2abe10-e ae9589cc): vs
				Lua     (  2abe10-e ae9589cc): #Orochi Iori
				Lua     (  2abe10-e ae9589cc): #Orochi Iori
				Lua     (  2abe10-e ae9589cc): #Orochi Iori
				Lua     (  2abe10-e 3ede79a7): Kof 96/97/98 format Lost Flags  00 | 03
				Lua     (  2abe10-e 3ede79a7): PLAYER HAS WON MATCH

				Lua     (  2abe10-e a996d5e7): (Not valid outside of a fight) We Appear to have a new Team Configuration of (00 01 02) and (1e 1e 1e)
				Lua     (  2abe10-e a996d5e7): Which would be a team of
				Lua     (  2abe10-e a996d5e7): Kyo Kusanagi
				Lua     (  2abe10-e a996d5e7): Benimaru Nikaido
				Lua     (  2abe10-e a996d5e7): Goro Daimon
				Lua     (  2abe10-e a996d5e7): vs
				Lua     (  2abe10-e a996d5e7): #Orochi
				Lua     (  2abe10-e a996d5e7): #Orochi
				Lua     (  2abe10-e a996d5e7): #Orochi
				Lua     (  2abe10-e d8d27693): Kof 96/97/98 format Lost Flags  00 | 03
				Lua     (  2abe10-e d8d27693): PLAYER HAS WON MATCH
				-- Bonus Match
				Lua     (  2abe10-e 1c7c3788): (Not valid outside of a fight) We Appear to have a new Team Configuration of (00 01 02) and (1b 1b 1b)
				Lua     (  2abe10-e 1c7c3788): Which would be a team of
				Lua     (  2abe10-e 1c7c3788): Kyo Kusanagi
				Lua     (  2abe10-e 1c7c3788): Benimaru Nikaido
				Lua     (  2abe10-e 1c7c3788): Goro Daimon
				Lua     (  2abe10-e 1c7c3788): vs
				Lua     (  2abe10-e 1c7c3788): Iori Yagami
				Lua     (  2abe10-e 1c7c3788): Iori Yagami
				Lua     (  2abe10-e 1c7c3788): Iori Yagami
				Lua     (  2abe10-e 1e8e4872): Kof 96/97/98 format Lost Flags  00 | 03
				Lua     (  2abe10-e 1e8e4872): PLAYER HAS WON MATCH
		--]]
		
	
	end	
	
	
	if (currentGame == 98) then

		-- #########################################################################################################
		-- #########################################################################################################
		-- FINAL BOSS
		-- #########################################################################################################
		-- #########################################################################################################
		
		-- Counts as Final Round from the start (sub-boss is the same)
		-- Omega Rugal
		matchCheck = IsTeamEntirely(WhichTeamx, 0x24)
		if matchCheck == 1 then return FINALBOSSTEAM end

		-- #########################################################################################################
		-- #########################################################################################################
		-- Teams for Trophies 36-41
		-- #########################################################################################################
		-- #########################################################################################################

		-- Fatal Fury Team (Italy)
		matchCheck = DoesTeamMatch(WhichTeamx, 0x03, 0x04, 0x05)
		if matchCheck == 1 then return FATAL_FURY_TEAM end
		
		
		-- Art of Fighting Team
		--  Ryo, Robert, and Yuri 
		matchCheck = DoesTeamMatch(WhichTeamx, 0x06, 0x07, 0x08)
		if matchCheck == 1 then return ART_OF_FIGHTING_TEAM end
	
		-- Psycho Soldier Team
		-- Athena, Sie, Chin
		matchCheck = DoesTeamMatch(WhichTeamx, 0x0c, 0x0d, 0x0e)
		if matchCheck == 1 then return PSYCHO_SOLDIER_TEAM end
		
		
		-- Team Korea
		-- Kim, Chang, Choi
		matchCheck = DoesTeamMatch(WhichTeamx, 0x12, 0x13, 0x14)
		if matchCheck == 1 then return TEAM_KOREA end
		
		
		-- Ikari Team
		-- Leona, Ralf, and Clark
		matchCheck = DoesTeamMatch(WhichTeamx, 0x09, 0x0a, 0x0b)
		if matchCheck == 1 then return IKARI_TEAM end
		
		
		--Women's Fighters' Team
		-- Chizuru Kagura, Mai Shiranui, King
		matchCheck = DoesTeamMatch(WhichTeamx, 0x0f, 0x10, 0x11)
		if matchCheck == 1 then return WOMENS_TEAM end
	
		
		-- #########################################################################################################
		-- #########################################################################################################
		-- Story
		-- #########################################################################################################
		-- #########################################################################################################
		
		-- N/A for Kof98
		
		-- #########################################################################################################
		-- #########################################################################################################
		-- Others
		-- #########################################################################################################
		-- #########################################################################################################
		
		
	end	
	
end



local GetNumberRounds = function()

	local WhichTeam = -1
	
	if (CurrentPlayMode == 1) then
		WhichTeam = 2
	elseif (CurrentPlayMode == 2) then
		WhichTeam = 1
	end
	
	if (WhichTeam == -1) then
		return 9999999
	end

	if (currentGame == 94) or (currentGame == 95) then
		
		local oppteam = IdentifyTeam(WhichTeam)
		
		if (oppteam==FINALBOSSTEAM) then
			return 2
		end
	end

	return 3
end


local HandleWin = function(flagx,flagy)

	local WhichTeam = -1
	local MyTeam = -1
	
	if (CurrentPlayMode == 1) then
		WhichTeam = 2
		MyTeam = 1
	elseif (CurrentPlayMode == 2) then
		WhichTeam = 1
		MyTeam = 2
	end
	
	local oppteam = IdentifyTeam(WhichTeam)
	local playteam = IdentifyTeam(MyTeam)
	
	
	if (oppteam==KOF96_CHIZURA) then
		AwardTrophy(9, "SevenYearsBadLuck", 0xff)
	end
	
	if (oppteam==KOF96_BOSS) then
		AwardTrophy(10, "OldBusiness", 0xff)
	end	

	if (oppteam==KOF97_NEWFACES_REAL) then
	
		AwardTrophy(15, "RestIsSilence", 0xff)
	
		if (playteam == KOF97_NEWFACES_CHRISFIRST) then
			-- have to beat these with just Chris AND then the boss with just chris
			-- so this is a special check
			if (flagx==0) then PlayerKof96SpecialCheck = 1 end
		end	
		
	
	end		
	
	if (oppteam==FINALBOSSTEAM) then
		print( string.format("======= PLAYER HAS BEATEN THE LAST BOSS ======\n" ) )
		print( string.format("======= (STATUS) LOST A MATCH %d  LOST A CHARACTER %d ======\n", PlayerHasLostMatch,PlayerHasLostCharacter ) )
		
		-- KOF 94 END GAME
		
		if (currentGame == 94) then
		
			AwardTrophy(1, "StayFree", 0xff)
			
			if PlayerHasLostMatch == 0 then
				AwardTrophy(3, "CrowdFave", 0xff)
			
				if playteam == KOF94_TEAM_USA then
					AwardTrophy(2, "ShotGlory", 0xff)
				end
			
			end
		
		end
		
		-- KOF 95 END GAME
		
		if (currentGame == 95) then
		
			AwardTrophy(4, "YouCantKeepBadManDown", 0xff)
			
			if PlayerHasLostMatch == 0 then
				AwardTrophy(7, "ReturningChampion", 0xff)
			end
						
		end
		
		if (currentGame == 96) then
		
			AwardTrophy(8, "CalmSkies", 0xff)
			
			-- beat without losing a character in arcad mode
			if PlayerHasLostMatch == 0 then
				AwardTrophy(13, "MyFavourite", 0xff)
			end
			
			if (playteam == KOF96_SPECIAL1) then
				AwardTrophy(11, "SunMoonMirror", 0xff)
			end

			if (playteam == KOF96_SPECIAL2) then
				AwardTrophy(12, "WildWind", 0xff)
			end
	
		end
		
		if (currentGame == 97) then
		
			AwardTrophy(14, "Penguined", 0xff)
		
			-- beat without losing a character in arcad mode
			if PlayerHasLostMatch == 0 then
				AwardTrophy(19, "Fighters2Beat", 0xff)
			end
			
			-- beat with a single character
			if flagx == 0 then
				AwardTrophy(20, "ApocalypseDenied", 0xff)
			end
		
			if (playteam == KOF97_NEWFACES_CHRISFIRST) then
			-- only valid if you also beat the new faces with just chris!
			-- so this is a special check
				if (PlayerKof96SpecialCheck == 1) then
					if (flagx==0) then
						AwardTrophy(18, "DancingWithMyself", 0xff)
						PlayerKof96SpecialCheck = 0
					end
				end
				
			end
			
			if (playteam == TEAM_STORY) then
				AwardTrophy(16, "SacredWeapons", 0xff)
			end				
			
			if (playteam == KOF97_SPECIAL1) then
				AwardTrophy(17, "Freak", 0x01)
			end			
			
			if (playteam == KOF97_SPECIAL2) then
				AwardTrophy(17, "Freak", 0x02)
			end	
			
			if (playteam == KOF97_SPECIAL3) then
				AwardTrophy(17, "Freak", 0x04)
			end	
			
			if (playteam == KOF97_SPECIAL4) then
				AwardTrophy(17, "Freak", 0x08)
			end		
			
			if (playteam == KOF97_SPECIAL5) then
				AwardTrophy(17, "Freak", 0xf0)
			end		
		
		end
		
		if (currentGame == 98) then
		
			AwardTrophy(21, "AlphaOmega", 0xff)
			
			if PlayerHasLostMatch == 0 then
				AwardTrophy(22, "Retire", 0xff)
			end
						
		end		
		
		local trophybitval = 0
		
		if (currentGame==94) then trophybitval = 0x01 end
		if (currentGame==95) then trophybitval = 0x02 end
		if (currentGame==96) then trophybitval = 0x04 end
		if (currentGame==97) then trophybitval = 0x08 end
		if (currentGame==98) then trophybitval = 0xf0 end
	
		
		--  All Games End
		if (playteam == FATAL_FURY_TEAM) then
			AwardTrophy(34, "FatalFuryTeam", trophybitval)
		end
		
		if (playteam == ART_OF_FIGHTING_TEAM) then
			AwardTrophy(35, "ArtOfFightingTeam", trophybitval)
		end		
		
		if (playteam == PSYCHO_SOLDIER_TEAM) then
			AwardTrophy(36, "PsychoSoldierTeam", trophybitval)
		end		
		
		if (playteam == TEAM_KOREA) then
			AwardTrophy(37, "TeamKorea", trophybitval)
		end	

		if (playteam == IKARI_TEAM) then
			AwardTrophy(38, "IkariTeam", trophybitval)
		end	

		if (playteam == WOMENS_TEAM) then
		
			if PlayerHasLostMatch == 0 then
				AwardTrophy(39, "WomensTeam", trophybitval)
			end
		end	

		-- Story trophy (everything except 98, IN ORDER)
		if (currentGame ~= 98) then
			if (playteam == TEAM_STORY) then
		
				if (currentGame == 94) then
					AwardTrophy(33, "TheRealStory", 0x01)
				end
				
				if (currentGame == 95) then
					-- have to have done 94 first
					local check = CheckTrophyState("TheRealStory", 33)
					if (check & 0x01) then AwardTrophy(33, "TheRealStory", 0x02) end
				end			
				
				if (currentGame == 96) then
					-- have to have done 95 first
					local check = CheckTrophyState("TheRealStory", 33)
					if (check & 0x02) then AwardTrophy(33, "TheRealStory", 0x04) end
				end		
	
				if (currentGame == 97) then
					-- have to have done 96 first
					local check = CheckTrophyState("TheRealStory", 33)
					if (check & 0x04) then AwardTrophy(33, "TheRealStory", 0xf8) end
				end			
	
			end			
		end
		
	end
		
		

end


local ProcessLostFlagsSub = function(flagx,flagy)
	local detectedlossmatch = 0
	
	if flagx ~= 0x00 then
		if (PlayerHasLostCharacter == 0) then
			print( string.format("PLAYER HAS LOST CHARACTER\n" ) )
			PlayerHasLostCharacter = 1
			PlayerKof96SpecialCheck = 0
		else
			print( string.format("player lost flag already set!\n" ) )
		end
		
	else
		PlayerDrawSpecial = 0
	end

	if flagx == 0x03 then
		if flagy ~= 0x03 or (flagy == 0x03 and PlayerDrawSpecial == 1) then -- theres an odd 'draw game' extra round in this situation
			PlayerHasLostMatch = 1
			PlayerKof96SpecialCheck = 0
			print( string.format("PLAYER HAS LOST MATCH\n" ) )
			
		else
			PlayerDrawSpecial = 1
		end
	end
	
	if flagx == 0x04 then -- the draw game takes us to round 4, if the player has lost 4 rounds they've definitely lost, even if that round was a draw
		PlayerHasLostMatch = 1
		
		print( string.format("PLAYER HAS LOST MATCH\n" ) )
		PlayerKof96SpecialCheck = 0
		detectedlossmatch = 1
	end
	
	
	-- if the player hasn't just lost the match, check what just happened
	if (detectedlossmatch == 0) then
			
		-- if it's a 3/3 or 4/4 draw then the player hasn't won anything
		if (flagx == 0x03 and flagy == 0x03) or (flagx == 0x04 and flagy == 0x04) then
			return
		end
	
		-- for some fights (special / boss) we don't play 3 rounds, so need to check
		local numRound = GetNumberRounds()
		
		if (flagy >= numRound) then
		
			print( string.format("PLAYER HAS WON MATCH\n" ) )
		
			HandleWin(flagx, flagy)
		
		end	
		
		if (flagy == 0x01) then
			-- Saisyu Kusanagi. in KOF95 is considered a character win, not a match win
			-- so this is a special case
			if (currentGame == 95) then
				
				local WhichTeam = -1
				local MyTeam = -1
				
				if (CurrentPlayMode == 1) then
					WhichTeam = 2
					MyTeam = 1
				elseif (CurrentPlayMode == 2) then
					WhichTeam = 1
					MyTeam = 2
				end	
				
				if WhichTeam == -1 then return end
				
			
				local oppteam = IdentifyTeam(WhichTeam)
		
				if (oppteam==FINALBOSSTEAM) then
					
					AwardTrophy(5, "IgotMeAshovel", 0xff)
					
					local first = GetFightingFirst(MyTeam)
					if first == 0x06 and flagx == 0x00 then
						AwardTrophy(6, "ScionOfTheFlame", 0xff)
					end
			
				end
			end
		
		end
		
	end
end

local ProcessLostFlags = function(flag1,flag2)
	
	print( string.format("Kof 96/97/98 format Lost Flags  %02x | %02x\n", flag1, flag2 ) )
		
	-- we only care about things that happen in a single player game
	if (CurrentPlayMode ~= 1) and (CurrentPlayMode ~= 2) then
		return
	end
	
	if (CurrentPlayMode == 1) then
		ProcessLostFlagsSub(flag1,flag2)
	elseif (CurrentPlayMode == 2) then
		ProcessLostFlagsSub(flag2,flag1)
	end	
	
	
end



local GetRoundsLost = function()

	if RamBase == -1 then
		return -1
	end

	if (currentGame == 96) or (currentGame == 97) then	
		if (NeoGeo_RM8(RamBase + 0x85d4) ~= 0xff) or (NeoGeo_RM8(RamBase + 0x85d5) ~= 0xff) then
			return
		end
	end
	

	if (currentGame == 98) then
		local test = checkstring(17,24,TimeText,0, 0xffff)
		
		if (test==1) then
			return
		end
	end

	if (currentGame == 94) or (currentGame == 95) then

		local basex = 0
		basex = 0x138


		addr1 = RamBase + PlayerAdressBase[1] + basex
	    addr2 = RamBase + PlayerAdressBase[1] + basex + 1

		addr3 = RamBase + PlayerAdressBase[2] + basex
	    addr4 = RamBase + PlayerAdressBase[2] + basex + 1

		val1 = NeoGeo_RM8(addr1)
		val2 = NeoGeo_RM8(addr2)
		val3 = NeoGeo_RM8(addr3)
		val4 = NeoGeo_RM8(addr4)
		
		if (oldLostFlag1 ~= val1) or (oldLostFlag2 ~= val2) or (oldLostFlag3 ~= val3) or (oldLostFlag4 ~= val4) then
				
			oldLostFlag1 = val1
			oldLostFlag2 = val2
			oldLostFlag3 = val3
			oldLostFlag4 = val4
		
			print( string.format("Kof 94 / 95 Lost Flags  %02x %02x  |  %02x %02x\n", val1, val2, val3, val4 ) )
			
		--[[
			These flags look like this for Kof94/95
		
			0601 - Start of round, nothing lost
			8601 - Dying!

			0402 - Start of round 2, nothing lost
			8402 - Dying!

			0004 - Start of round 3 , nothing lost
			8004 - Dying!

			8704 - Char Selct Order? (p1) probably only first byte?
			8701 - Char Select (p2)

			0201 - rugal undefeated?
			8201 - rugal first round done

			0002 - rugal 2nd round
			8002 - rugal 2nd round defeated
		--]]
		
			local reformattedFlag1 = -1
			local reformattedFlag2 = -1
			
			reformattedFlag1 = ReFormatFlags(val1,val2)
			reformattedFlag2 = ReFormatFlags(val3,val4)
		
			if (reformattedFlag1 ~= -1) and (reformattedFlag2 ~= -1) then
				ProcessLostFlags(reformattedFlag1, reformattedFlag2)
			end
		end
	end
	
	if (currentGame == 96) or (currentGame == 97) or (currentGame == 98) then
	
		local addr1 = -1
		local addr2 = -1
	
		if (currentGame == 96) then
			addr1 = RamBase + Kof96GameStateAddr + 0x145
			addr2 = RamBase + Kof96GameStateAddr + 0x145 + 0x11
		elseif (currentGame == 97) then
			addr1 = RamBase + Kof97GameStateAddr + 0x14a
			addr2 = RamBase + Kof97GameStateAddr + 0x14a + 0x11
		elseif (currentGame == 98) then
			addr1 = RamBase + Kof98GameStateAddr + 0x14d
			addr2 = RamBase + Kof98GameStateAddr + 0x14d + 0x11
		end
		
		local val1 = -1
		local val2 = -1

		val1 = NeoGeo_RM8(addr1)
		val2 = NeoGeo_RM8(addr2)

		if (oldLostFlag1 ~= val1) or (oldLostFlag2 ~= val2) then
			
			-- invalid transition
			if ((val1==0x03) and (val2==0x03)) and ((oldLostFlag1 ~= 0x02) and (oldLostFlag2 ~= 0x02)) then
				return
			end	
			
			oldLostFlag1 = val1
			oldLostFlag2 = val2
			
			
	
			ProcessLostFlags(val1, val2)
	
		end
	end
		
end




local SetupGame = function()

	if RamBase == -1 then
		return
	end
	
	if (currentGame == 94) then
		P1HealthAddr = RamBase + PlayerAdressBase[1] + Kof94HealthAddr
		P2HealthAddr = RamBase + PlayerAdressBase[2] + Kof94HealthAddr
		MaxHealth = 0xcf
		
		P1CharacterAddresses[1] = RamBase + PlayerAdressBase[1] + 0x132 + 3
		P1CharacterAddresses[2] = RamBase + PlayerAdressBase[1] + 0x132 + 4
		P1CharacterAddresses[3] = RamBase + PlayerAdressBase[1] + 0x132 + 5
	
		P1CharacterAddressesOrder[1] = RamBase + PlayerAdressBase[1] + 0x132 + 0
		P1CharacterAddressesOrder[2] = RamBase + PlayerAdressBase[1] + 0x132 + 1
		P1CharacterAddressesOrder[3] = RamBase + PlayerAdressBase[1] + 0x132 + 2
	
		P2CharacterAddresses[1] = RamBase + PlayerAdressBase[2] + 0x132 + 3
		P2CharacterAddresses[2] = RamBase + PlayerAdressBase[2] + 0x132 + 4
		P2CharacterAddresses[3] = RamBase + PlayerAdressBase[2] + 0x132 + 5
		
		P2CharacterAddressesOrder[1] = RamBase + PlayerAdressBase[2] + 0x132 + 0
		P2CharacterAddressesOrder[2] = RamBase + PlayerAdressBase[2] + 0x132 + 1
		P2CharacterAddressesOrder[3] = RamBase + PlayerAdressBase[2] + 0x132 + 2
		
		
		CharNumStyle = 1
		CharacterList = Kof94Names
		NumCharacters = Kof94NumChars
	end
	
	if (currentGame == 95) then
		P1HealthAddr = RamBase + PlayerAdressBase[1] + Kof95HealthAddr
		P2HealthAddr = RamBase + PlayerAdressBase[2] + Kof95HealthAddr
		MaxHealth = 0xcf
		
		P1CharacterAddresses[1] = RamBase + Kof95GameStateAddr + P1Kof95CharacterBase + 0
		P1CharacterAddresses[2] = RamBase + Kof95GameStateAddr + P1Kof95CharacterBase + 1
		P1CharacterAddresses[3] = RamBase + Kof95GameStateAddr + P1Kof95CharacterBase + 2

		P1CharacterAddressesOrder[1] = RamBase + Kof95GameStateAddr + 0x149
		P1CharacterAddressesOrder[2] = RamBase + Kof95GameStateAddr + 0x149+1
		P1CharacterAddressesOrder[3] = RamBase + Kof95GameStateAddr + 0x149+2

		P2CharacterAddresses[1] = RamBase + Kof95GameStateAddr + P2Kof95CharacterBase + 0
		P2CharacterAddresses[2] = RamBase + Kof95GameStateAddr + P2Kof95CharacterBase + 1
		P2CharacterAddresses[3] = RamBase + Kof95GameStateAddr + P2Kof95CharacterBase + 2
		
		P2CharacterAddressesOrder[1] = RamBase + Kof95GameStateAddr + 0x149+0x10
		P2CharacterAddressesOrder[2] = RamBase + Kof95GameStateAddr + 0x149+0x10+1
		P2CharacterAddressesOrder[3] = RamBase + Kof95GameStateAddr + 0x149+0x10+2
	
		
		CharNumStyle = 2
		CharacterList = Kof95Names
		NumCharacters = Kof95NumChars
	end
	
	if (currentGame == 96) then
		P1HealthAddr = RamBase + PlayerAdressBase[1] + Kof96HealthAddr
		P2HealthAddr = RamBase + PlayerAdressBase[2] + Kof96HealthAddr
		MaxHealth = 0x67
		
		P1CharacterAddresses[1] = RamBase + Kof96GameStateAddr + P1Kof96CharacterBase + 0
		P1CharacterAddresses[2] = RamBase + Kof96GameStateAddr + P1Kof96CharacterBase + 1
		P1CharacterAddresses[3] = RamBase + Kof96GameStateAddr + P1Kof96CharacterBase + 2

		P1CharacterAddressesOrder[1] = RamBase + Kof96GameStateAddr + 0x14C
		P1CharacterAddressesOrder[2] = RamBase + Kof96GameStateAddr + 0x14C+1
		P1CharacterAddressesOrder[3] = RamBase + Kof96GameStateAddr + 0x14C+2

		P2CharacterAddresses[1] = RamBase + Kof96GameStateAddr + P2Kof96CharacterBase + 0
		P2CharacterAddresses[2] = RamBase + Kof96GameStateAddr + P2Kof96CharacterBase + 1
		P2CharacterAddresses[3] = RamBase + Kof96GameStateAddr + P2Kof96CharacterBase + 2
		
		P2CharacterAddressesOrder[1] = RamBase + Kof96GameStateAddr + 0x14C+0x11
		P2CharacterAddressesOrder[2] = RamBase + Kof96GameStateAddr + 0x14C+0x11+1
		P2CharacterAddressesOrder[3] = RamBase + Kof96GameStateAddr + 0x14C+0x11+2
	
		
		CharNumStyle = 2
		CharacterList = Kof96Names
		NumCharacters = Kof96NumChars	
	end

	if (currentGame == 97) then
		P1HealthAddr = RamBase + PlayerAdressBase[1] + Kof97HealthAddr
		P2HealthAddr = RamBase + PlayerAdressBase[2] + Kof97HealthAddr
		MaxHealth = 0x67
		
		P1CharacterAddresses[1] = RamBase + Kof97GameStateAddr + P1Kof97CharacterBase + 0
		P1CharacterAddresses[2] = RamBase + Kof97GameStateAddr + P1Kof97CharacterBase + 1
		P1CharacterAddresses[3] = RamBase + Kof97GameStateAddr + P1Kof97CharacterBase + 2

		P1CharacterAddressesOrder[1] = RamBase + Kof97GameStateAddr + 0x151
		P1CharacterAddressesOrder[2] = RamBase + Kof97GameStateAddr + 0x151+1
		P1CharacterAddressesOrder[3] = RamBase + Kof97GameStateAddr + 0x151+2

		P2CharacterAddresses[1] = RamBase + Kof97GameStateAddr + P2Kof97CharacterBase + 0
		P2CharacterAddresses[2] = RamBase + Kof97GameStateAddr + P2Kof97CharacterBase + 1
		P2CharacterAddresses[3] = RamBase + Kof97GameStateAddr + P2Kof97CharacterBase + 2
		
		P2CharacterAddressesOrder[1] = RamBase + Kof97GameStateAddr + 0x151+0x11
		P2CharacterAddressesOrder[2] = RamBase + Kof97GameStateAddr + 0x151+0x11+1
		P2CharacterAddressesOrder[3] = RamBase + Kof97GameStateAddr + 0x151+0x11+2
		
		CharNumStyle = 2
		CharacterList = Kof97Names
		NumCharacters = Kof97NumChars		
	end
	
	if (currentGame == 98) then
		P1HealthAddr = RamBase + PlayerAdressBase[1] + Kof98HealthAddr
		P2HealthAddr = RamBase + PlayerAdressBase[2] + Kof98HealthAddr
		MaxHealth = 0x67
		
		P1CharacterAddresses[1] = RamBase + Kof98GameStateAddr + P1Kof98CharacterBase + 0
		P1CharacterAddresses[2] = RamBase + Kof98GameStateAddr + P1Kof98CharacterBase + 1
		P1CharacterAddresses[3] = RamBase + Kof98GameStateAddr + P1Kof98CharacterBase + 2

		P1CharacterAddressesOrder[1] = RamBase + Kof98GameStateAddr + 0x154
		P1CharacterAddressesOrder[2] = RamBase + Kof98GameStateAddr + 0x154+1
		P1CharacterAddressesOrder[3] = RamBase + Kof98GameStateAddr + 0x154+2

		P2CharacterAddresses[1] = RamBase + Kof98GameStateAddr + P2Kof98CharacterBase + 0
		P2CharacterAddresses[2] = RamBase + Kof98GameStateAddr + P2Kof98CharacterBase + 1
		P2CharacterAddresses[3] = RamBase + Kof98GameStateAddr + P2Kof98CharacterBase + 2
		
		P2CharacterAddressesOrder[1] = RamBase + Kof98GameStateAddr + 0x154+0x11
		P2CharacterAddressesOrder[2] = RamBase + Kof98GameStateAddr + 0x154+0x11+1
		P2CharacterAddressesOrder[3] = RamBase + Kof98GameStateAddr + 0x154+0x11+2
	
		CharNumStyle = 2
		CharacterList = Kof98Names
		NumCharacters = Kof98NumChars		
	end
end


	
local ScanCurrentTeam = function(JustScanForInvalid)
	
	local retvalue = 0
	
	if RamBase == -1 then
		return -100
	end

	

	--print( string.format("Addresses %08x %08x %08x     %08x %08x %08x ", P1CharacterAddresses[1], P1CharacterAddresses[2], P1CharacterAddresses[3], P2CharacterAddresses[1], P2CharacterAddresses[2], P2CharacterAddresses[3] ) )

	CurrentTeamP1[1] = NeoGeo_RM8(P1CharacterAddresses[1])
	CurrentTeamP1[2] = NeoGeo_RM8(P1CharacterAddresses[2])
	CurrentTeamP1[3] = NeoGeo_RM8(P1CharacterAddresses[3])

	CurrentTeamP2[1] = NeoGeo_RM8(P2CharacterAddresses[1])
	CurrentTeamP2[2] = NeoGeo_RM8(P2CharacterAddresses[2])
	CurrentTeamP2[3] = NeoGeo_RM8(P2CharacterAddresses[3])
	
	if CurrentTeamP1[1] == 0x00 and CurrentTeamP1[2] == 0x00 and CurrentTeamP1[3] and CurrentTeamP2[1] == 0x00 and CurrentTeamP2[2] == 0x00 and CurrentTeamP2[3] then
		retvalue = -1
	end

	
	if JustScanForInvalid == 1 then
		return retvalue
	end
	
	if (CurrentTeamP1[1] ~= oldCurrentTeamP1[1]) or
	   (CurrentTeamP1[2] ~= oldCurrentTeamP1[2]) or
	   (CurrentTeamP1[3] ~= oldCurrentTeamP1[3]) or	
	   (CurrentTeamP2[1] ~= oldCurrentTeamP2[1]) or
	   (CurrentTeamP2[2] ~= oldCurrentTeamP2[2]) or
	   (CurrentTeamP2[3] ~= oldCurrentTeamP2[3]) then
	   
	  	if retvalue ~= -1 then
	   
			oldCurrentTeamP1[1] = CurrentTeamP1[1]
			oldCurrentTeamP1[2] = CurrentTeamP1[2]
			oldCurrentTeamP1[3] = CurrentTeamP1[3]
			
			oldCurrentTeamP2[1] = CurrentTeamP2[1]
			oldCurrentTeamP2[2] = CurrentTeamP2[2]
			oldCurrentTeamP2[3] = CurrentTeamP2[3]
		
		

			
			print( string.format("(Not valid outside of a fight) We Appear to have a new Team Configuration of (%02x %02x %02x) and (%02x %02x %02x)", CurrentTeamP1[1], CurrentTeamP1[2], CurrentTeamP1[3], CurrentTeamP2[1], CurrentTeamP2[2], CurrentTeamP2[3]) )

			print( string.format("Which would be a team of\n") )
			if ( CurrentTeamP1[1] <= NumCharacters ) then print( string.format("%s\n", CharacterList[CurrentTeamP1[1]+1] ) ) else print( string.format("INVALID\n" ) ) end
			if ( CurrentTeamP1[2] <= NumCharacters ) then print( string.format("%s\n", CharacterList[CurrentTeamP1[2]+1] ) ) else print( string.format("INVALID\n" ) ) end
			if ( CurrentTeamP1[3] <= NumCharacters ) then print( string.format("%s\n", CharacterList[CurrentTeamP1[3]+1] ) ) else print( string.format("INVALID\n" ) ) end
			print( string.format("vs\n") )
			if ( CurrentTeamP2[1] <= NumCharacters ) then print( string.format("%s\n", CharacterList[CurrentTeamP2[1]+1] ) ) else print( string.format("INVALID\n" ) ) end
			if ( CurrentTeamP2[2] <= NumCharacters ) then print( string.format("%s\n", CharacterList[CurrentTeamP2[2]+1] ) ) else print( string.format("INVALID\n" ) ) end
			if ( CurrentTeamP2[3] <= NumCharacters ) then print( string.format("%s\n", CharacterList[CurrentTeamP2[3]+1] ) ) else print( string.format("INVALID\n" ) ) end

			local first1 = GetFightingFirst(1)
			local first2 = GetFightingFirst(2)
			print( string.format("Fighting First is  (%s)   VS   (%s)", CharacterList[first1+1], CharacterList[first2+1]) )
			
			local team1ID = IdentifyTeam(1)
			local team2ID = IdentifyTeam(2) 
			
			print( string.format("::::::::::::: Team 1 Identification (for trophy use etc.) --" ) )
			printImportantTeamsStringDEBUG(team1ID)
			print( string.format("::::::::::::: Team 2 Identification (for trophy use etc.) --" ) )
			printImportantTeamsStringDEBUG(team2ID)
			print( string.format(":::::::::::::::::::::::::::--" ) )
		
		end

		
	end


	return retvalue

end



local CheckPlaying = function()

	if RamBase == -1 then
		return -1
	end
	
	local base = RamBase + Kof97GameStateAddr  + 0xF2

	local test1 = NeoGeo_RM8(base)


	local test2 = ScanCurrentTeam(1)

	if (test2 == -1) then
	
		if (CurrentPlayMode~=0) then
			CurrentPlayMode = 0
			print( string.format("Teams are currently invalid - Game is NOT being played, resetting current game flags/stats\n" ) )
			ResetGameStats()
		end
		
	end		
end


local Challenger = { 0x43, 0x48, 0x41, 0x4C, 0x4C, 0x45, 0x4E, 0x47, 0x45, 0x52, 0x21 }
local PressStart = { 0x50, 0x52, 0x45, 0x53, 0x53, 0x20, 0x53, 0x54, 0x41, 0x52, 0x54 }
local BeatBy = { 0x42, 0x45, 0x41, 0x54, 0x20, 0x42, 0x59 } 
local P1 = { 0x31, 0x50 } -- 1P
local P2 = { 0x32, 0x50 } -- 2P

local P1x = { 0x31, 0x50, 0x2D } -- 1P-



local GameStateChecks = function()

	if (currentGame == 94) or (currentGame == 95) then
	
		-- " ppp 1P-     00  tttt PUSH START  ppp "
		-- " pppTERRY BOGARD ttttKIM KAPHWAN  ppp "

		local test = 0

		test = checkstring(5,1,P1x,0, 0x007f)
		
		if test == 1 then
			local newPlaymode = 1
			
			if (CurrentPlayMode ~= newPlaymode) then
				CurrentPlayMode = newPlaymode
				
				print( string.format("Appears to be a 1 Player game as Player 1") )
			end
			ScanCurrentTeam(0)
			GetRoundsLost()
		end

	end

	if (currentGame == 96) or (currentGame == 97) or (currentGame == 98) then
	
	--  00000000001111111111222222222233333333
	--  01234567890123456789012345678901234567
	-- "xxxx CHALLENGER! tttt CHALLENGER! xxxx"
	-- "xxxx CHALLENGER! tttt BEAT BY  01 xxxx"
	-- "xxxx BEAT BY  01 tttt CHALLENGER! xxxx"
	-- "xxxx PRESS START tttt 2P        00xxxx"
	-- "xxxx1P        00 tttt PRESS START xxxx"
	
		if (textVramBase ~= -1) then
		
			-- base palette for text strings we're checking is 0x2300
			local basePal = 0x2300
			local basePal2 = 0x1300
	
			local test = 0
			local test2 = 0
			
			test = checkstring(4,1,P1,basePal, 0x007f)	
			--test2 = checkstring(22,1,PressStart,basePal2, 0x007f)
			if test == 1 then -- and test2 ==1 then
				
				local challengeModeCheck = 0
				
				if (currentGame == 98) then
				
					local test2 = checkstring(14,1,Blank,0x0000, 0xffff)	
				
					if (test2 == 1) then
						challengeModeCheck = 1
						
						local OldMode = CurrentPlayMode
						CurrentPlayMode = -1
						
						if (OldMode ~= CurrentPlayMode) then
							print( string.format("==== CHALLENGE MODE *** DISABLING NORMAL TROPHIES *** ==== (test1 %d test2 %d)", test, test2) )
						end
					end
				end
				
				--if (currentGame == 98) then
				--	print( string.format("Check For Challenge") )
				--	local testchal = checkstring(14,1,Blank,0x0000, 0xffff)	
				--
				--	if (testchal==1) then challengeModeCheck = 1 end
				--end
				
				if challengeModeCheck == 0 then
				
					local newPlaymode = 1
					
					if (CurrentPlayMode ~= newPlaymode) then
						CurrentPlayMode = newPlaymode
						
						print( string.format("Appears to be a 1 Player game as Player 1 (test1 %d test2 %d", test, test2) )
					end
					
					ScanCurrentTeam(0)
					GetRoundsLost()
				end
			end
		
			test = checkstring(22,1,P2,basePal2, 0x007f)	
			--test2 = checkstring(5,1,PressStart,basePal, 0x007f)
			if test == 1 then -- and test2 ==1 then
				local newPlaymode = 2
				
				if (CurrentPlayMode ~= newPlaymode) then
					CurrentPlayMode = newPlaymode
					
					print( string.format("Appears to be a 1 Player game as Player 2") )
				end
				
				ScanCurrentTeam(0)
				GetRoundsLost()
			end		
		
			test = checkstring(22,1,Challenger,basePal2, 0x007f)	
			test2 = checkstring(5,1,Challenger,basePal, 0x007f)
			if test == 1 or test2 ==1 then
				local newPlaymode = 3
				
				if (CurrentPlayMode ~= newPlaymode) then
					CurrentPlayMode = newPlaymode
					
					print( string.format("Appears to be a 2 Player game") )
				end
				
				ScanCurrentTeam(0)
				GetRoundsLost()
			end			
		
	
	
		end
	end
	
	
end



local VsyncFunc = function()

	if HackNeoGeoRegionToBeJapan == 1 then
		if RamBase ~= -1 then
			NeoGeo_WM8(RamBase + 0xfd83,0x00)
		end
	end
	
	CheckPlaying()
	
	GameStateChecks()
	GetRoundsLost() -- needs to happen at all times during gameplay, but be blocked during character select / order select

	local romBase = -1
	
	if Region == 1 then
		romBase = Adjusted_RM32(0x02d89bc)
	elseif Region == 2 then
		romBase = Adjusted_RM32(0x02d89bc + 0x700)
	end
	
	if (romBase ~= lastRomBase) then
		lastRomBase = romBase	
		print( string.format("Rom Base %08x\n", romBase ) )
		
		if (romBase == 0) then
			currentGame = -1
			textVramBase = -1
			RamBase = -1
			ResetVariables()
			print( string.format("unloaded game, disable game specific trophies\n", romBase ) )
		end
	end
	
	if (currentGame == -1) then
	
		if (romBase ~= 0) then
		
			local checkString1 = eeObj.ReadMem32(romBase+0x100+0x0)
			local checkString2 = eeObj.ReadMem32(romBase+0x100+0x4)
			local checkString3 = eeObj.ReadMem32(romBase+0x100+0x8)
	
			--print( string.format("%08x %08x %08x", checkString1, checkString2, checkString3 ) )
		  		   
			if (checkString1 == 0x4f2d4e45) and (checkString2 == 0x4f004745) and (checkString3 == 0x00100055) then
				print( string.format("1994 1994 1994\n" ) )
				currentGame = 94
			end	
	
			if (checkString1 == 0x4f2d4e45) and (checkString2 == 0x4f004745) and (checkString3 == 0x00100084) then
				print( string.format("looks like we're KOF'95ing\n" ) )
				currentGame = 95
			end	

			if (checkString1 == 0x4f2d4e45) and (checkString2 == 0x4f104745) and (checkString3 == 0x00300214) then
				print( string.format("Once upon a 1996\n" ) )
				currentGame = 96
			end	

			if (checkString1 == 0x4f2d4e45) and (checkString2 == 0x4f104745) and (checkString3 == 0x00400232) then
				print( string.format("it's 1997!\n" ) )
				currentGame = 97
			end	

			if (checkString1 == 0x4f2d4e45) and (checkString2 == 0x4f104745) and (checkString3 == 0x00500242) then
				print( string.format("Slugfest of '98!\n" ) )
				currentGame = 98
			end	
				
		end
	
	end	

end

local TextFunc = function()

	if (currentGame ~= -1) then

		if (textVramBase == -1) then
		
			local base = eeObj.GetGPR(gpr.s0);
			
			local newText = base + 0xe000
			
			if (newText ~= textVramBase) then		
				print( string.format("text base is %08x?!\n", newText ) )
				textVramBase = newText
				
				if Region==1 then
					RamBase = Adjusted_RM32(0x002d89b0)
				elseif Region==2 then
					RamBase = Adjusted_RM32(0x002d89b0+0x700)
				end
				
				print( string.format("RAM base is 0x%08x\n", RamBase ) )
				
				SetupGame()
			end
		
		end

	end

end



if Region == 1 then
	TextHook = eeObj.AddHook(0x001e0280,0x3c03002e,TextFunc)
elseif Region == 2 then
	TextHook = eeObj.AddHook(0x001e09a0,0x3c03002e,TextFunc)
end


MainHook = emuObj.AddVsyncHook(VsyncFunc)

--[[

code that checks for unlocked stuff in the menu..

0x00000000002252c8                SUnlockable::isUnlocked(void) const
calls
0x00000000001dbe48                CScenarioManager::isUnlocked(int) const

calls

001DBE48    27BDFFE0	addiu       sp,sp,-0x20         IX .. .. .. .. .. .. ..  
001DBE4C    FFB10008	sd          s1,0x0008(sp)       .. .. LS .. .. .. .. ..  [01] REG 
001DBE50    FFB00000	sd          s0,0x0000(sp)       .. .. LS .. .. .. .. ..  
001DBE54    FFB20010	sd          s2,0x0010(sp)       .. .. LS .. .. .. .. ..  [01] PIPE 
001DBE58    FFBF0018	sd          ra,0x0018(sp)       .. .. LS .. .. .. .. ..  
001DBE5C    8C900008	lw          s0,0x0008(a0)       .. .. LS .. .. .. .. ..  [01] PIPE 
001DBE60    12000014	beq         s0,zero,0x001DBEB4  .. .. .. BR .. .. .. ..  [01] REG   early exit  
001DBE64    00A0882D	dmove       s1,a1               IX .. .. .. .. .. .. ..  
001DBE68    3C120033	lui         s2,0x33             IX .. .. .. .. .. .. ..  
001DBE6C    92020014	lbu         v0,0x0014(s0)       .. .. LS .. .. .. .. ..  

-- jumps back up here from down below?
001DBE70    5451000E	bnel        v0,s1,0x001DBEAC    .. .. .. BR .. .. .. ..  [01] REG 
001DBE74    8E100024	lw          s0,0x0024(s0)       .. .. LS .. .. .. .. ..  
001DBE78    8E020000	lw          v0,0x0000(s0)       .. .. LS .. .. .. .. ..  [01] REG 
001DBE7C    00021303	sra         v0,v0,12            IX .. .. .. .. .. .. ..  [02] REG 
001DBE80    0040282D	dmove       a1,v0               IX .. .. .. .. .. .. ..  
001DBE84    28420100	slti        v0,v0,0x100         IX .. .. .. .. .. .. ..  
001DBE88    10400005	beq         v0,zero,0x001DBEA0  .. .. .. BR .. .. .. ..   -- skip the achievement check?
001DBE8C    0000182D	dmove       v1,zero             IX .. .. .. .. .. .. ..  
001DBE90    8E445660	lw          a0,0x5660(s2)       .. .. LS .. .. .. .. ..  
001DBE94    0C083E1E	jal         0x0020F878          .. .. .. BR .. .. .. ..        0x000000000020f878                CAchievementMgr::isAchievementAchieved(unsigned int) const
001DBE98    24840070	addiu       a0,a0,0x70          IX .. .. .. .. .. .. ..  [01] REG 
001DBE9C    0040182D	dmove       v1,v0               IX .. .. .. .. .. .. ..    << setting V1 after here unlocks everything

-- if skipped the achievement check?
001DBEA0    14600005	bne         v1,zero,0x001DBEB8  .. .. .. BR .. .. .. ..    -- jump to not so early exit
001DBEA4    24020001	li          v0,0x1              IX .. .. .. .. .. .. ..  

001DBEA8    8E100024	lw          s0,0x0024(s0)       .. .. LS .. .. .. .. ..  


001DBEAC    5600FFF0	bnel        s0,zero,0x001DBE70  .. .. .. BR .. .. .. ..  [03] REG  BRANCH   (jump back up there^^)
001DBEB0    92020014	lbu         v0,0x0014(s0)       .. .. LS .. .. .. .. ..  


-- early exit
001DBEB4    0000102D	dmove       v0,zero             IX .. .. .. .. .. .. ..  
-- not so early exit
001DBEB8    DFB00000	ld          s0,0x0000(sp)       .. .. LS .. .. .. .. ..  
001DBEBC    DFB10008	ld          s1,0x0008(sp)       .. .. LS .. .. .. .. ..  [01] PIPE 
001DBEC0    DFB20010	ld          s2,0x0010(sp)       .. .. LS .. .. .. .. ..  
001DBEC4    DFBF0018	ld          ra,0x0018(sp)       .. .. LS .. .. .. .. ..  [01] PIPE 
001DBEC8    03E00008	jr          ra                  .. .. .. BR .. .. .. ..  [01] REG 
001DBECC    27BD0020	addiu       sp,sp,0x20          IX .. .. .. .. .. .. ..  


 .text          0x000000000020f6f8      0x69c kofps2obj/ie_achievements.o
                0x000000000020fbb8                CAchievementMgr::setAllAchievements(bool)
                0x000000000020f908                CAchievementMgr::isCountAchievementAchieved(unsigned int) const
                0x000000000020f838                CAchievementMgr::~CAchievementMgr(void)
                0x000000000020fbf8                CAchievementMgr::operator==(CAchievementMgr const &) const
                0x000000000020fc90                CAchievementMgr::getMemoryUsage(void)
                0x000000000020f878                CAchievementMgr::isAchievementAchieved(unsigned int) const
                0x000000000020fc98                CAchievementMgr::save(COutStream &)
                0x000000000020f870                CAchievementMgr::isEnabled(void) const
                0x000000000020fa08                CAchievementMgr::setAchievement(unsigned int, bool)
                0x000000000020f998                CAchievementMgr::getCountAchievementCount(unsigned int) const
                0x000000000020fad8                CAchievementMgr::setCountAchievement(unsigned int, bool, unsigned int)
                0x000000000020f6f8                CAchievementMgr::load(CInStream &)
                0x000000000020fd30                CAchievementMgr::setDefault(void)
                0x000000000020f820                CAchievementMgr::CAchievementMgr(void)
                0x000000000020fa00                CAchievementMgr::setEnabled(bool)

0x000000000020f878                CAchievementMgr::isAchievementAchieved(unsigned int) const
0020F878    27BDFFD0	addiu       sp,sp,-0x30         IX .. .. .. .. .. .. ..  
0020F87C    FFB00010	sd          s0,0x0010(sp)       .. .. LS .. .. .. .. ..  [01] REG 
0020F880    00A0802D	dmove       s0,a1               IX .. .. .. .. .. .. ..  
0020F884    2E020100	sltiu       v0,s0,0x100         IX .. .. .. .. .. .. ..  [01] REG 
0020F888    FFB10018	sd          s1,0x0018(sp)       .. .. LS .. .. .. .. ..  
0020F88C    FFBF0020	sd          ra,0x0020(sp)       .. .. LS .. .. .. .. ..  [01] PIPE 
0020F890    1440000C	bne         v0,zero,0x0020F8C4  .. .. .. BR .. .. .. ..  
0020F894    0080882D	dmove       s1,a0               IX .. .. .. .. .. .. ..  

0020F898    3C020039	lui         v0,0x39             IX .. .. .. .. .. .. ..  
0020F89C    3C040039	lui         a0,0x39             IX .. .. .. .. .. .. ..  
0020F8A0    2442A800	addiu       v0,v0,-0x5800       IX .. .. .. .. .. .. ..  
0020F8A4    3C070034	lui         a3,0x34             IX .. .. .. .. .. .. ..  
0020F8A8    3C080034	lui         t0,0x34             IX .. .. .. .. .. .. ..  
0020F8AC    2403002E	li          v1,0x2E             IX .. .. .. .. .. .. ..  
0020F8B0    2484A830	addiu       a0,a0,-0x57D0       IX .. .. .. .. .. .. ..  
0020F8B4    24060100	li          a2,0x100            IX .. .. .. .. .. .. ..  
0020F8B8    ACE2E1A0	sw          v0,0xE1A0(a3)       .. .. LS .. .. .. .. ..  
0020F8BC    0C09BA5A	jal         0x0026E968          .. .. .. BR .. .. .. ..                0x000000000026e968                reallyGTFO(char const *,...)
0020F8C0    AD03E1A4	sw          v1,0xE1A4(t0)       .. .. LS .. .. .. .. ..  

0020F8C4    32030007	andi        v1,s0,0x7           IX .. .. .. .. .. .. ..  
0020F8C8    24020001	li          v0,0x1              IX .. .. .. .. .. .. ..  
0020F8CC    001020C2	srl         a0,s0,3             IX .. .. .. .. .. .. ..  
0020F8D0    DFB00010	ld          s0,0x0010(sp)       .. .. LS .. .. .. .. ..  
0020F8D4    00621004	sllv        v0,v0,v1            IX .. .. .. .. .. .. ..  
0020F8D8    308300FF	andi        v1,a0,0xFF          IX .. .. .. .. .. .. ..  
0020F8DC    A3A40000	sb          a0,0x0000(sp)       .. .. LS .. .. .. .. ..  
0020F8E0    304400FF	andi        a0,v0,0xFF          IX .. .. .. .. .. .. ..  
0020F8E4    A3A20001	sb          v0,0x0001(sp)       .. .. LS .. .. .. .. ..  
0020F8E8    00711821	addu        v1,v1,s1            IX .. .. .. .. .. .. ..  
0020F8EC    DFBF0020	ld          ra,0x0020(sp)       .. .. LS .. .. .. .. ..  
0020F8F0    90620010	lbu         v0,0x0010(v1)       .. .. LS .. .. .. .. ..  
0020F8F4    DFB10018	ld          s1,0x0018(sp)       .. .. LS .. .. .. .. ..  [01] PIPE 
0020F8F8    00441024	and         v0,v0,a0            IX .. .. .. .. .. .. ..     -- if V0 is 1 here then we're good
0020F8FC    0002102B	sltu        v0,zero,v0          IX .. .. .. .. .. .. ..  [01] REG 
0020F900    03E00008	jr          ra                  .. .. .. BR .. .. .. ..  
0020F904    27BD0030	addiu       sp,sp,0x30          IX .. .. .. .. .. .. ..  

0x000000000020fa08                CAchievementMgr::setAchievement(unsigned int, bool)
0020FA08    27BDFFD0	addiu       sp,sp,-0x30         IX .. .. .. .. .. .. ..  
0020FA0C    0000102D	dmove       v0,zero             IX .. .. .. .. .. .. ..  
0020FA10    FFB00010	sd          s0,0x0010(sp)       .. .. LS .. .. .. .. ..  
0020FA14    00A0802D	dmove       s0,a1               IX .. .. .. .. .. .. ..  
0020FA18    FFB10018	sd          s1,0x0018(sp)       .. .. LS .. .. .. .. ..  
0020FA1C    0080882D	dmove       s1,a0               IX .. .. .. .. .. .. ..  
0020FA20    FFB20020	sd          s2,0x0020(sp)       .. .. LS .. .. .. .. ..  
0020FA24    00C0902D	dmove       s2,a2               IX .. .. .. .. .. .. ..  
0020FA28    FFBF0028	sd          ra,0x0028(sp)       .. .. LS .. .. .. .. ..  
0020FA2C    8E230030	lw          v1,0x0030(s1)       .. .. LS .. .. .. .. ..  [01] PIPE 
0020FA30    10600023	beq         v1,zero,0x0020FAC0  .. .. .. BR .. .. .. ..  [01] REG   -- early out?
0020FA34    2E040100	sltiu       a0,s0,0x100         IX .. .. .. .. .. .. ..  


0020FA38    1480000D	bne         a0,zero,0x0020FA70  .. .. .. BR .. .. .. ..  
0020FA3C    001020C2	srl         a0,s0,3             IX .. .. .. .. .. .. ..  

0020FA40    3C020039	lui         v0,0x39             IX .. .. .. .. .. .. ..  
0020FA44    3C040039	lui         a0,0x39             IX .. .. .. .. .. .. ..  
0020FA48    2442A800	addiu       v0,v0,-0x5800       IX .. .. .. .. .. .. ..  
0020FA4C    3C070034	lui         a3,0x34             IX .. .. .. .. .. .. ..  
0020FA50    3C080034	lui         t0,0x34             IX .. .. .. .. .. .. ..  
0020FA54    24030062	li          v1,0x62             IX .. .. .. .. .. .. ..  
0020FA58    2484A958	addiu       a0,a0,-0x56A8       IX .. .. .. .. .. .. ..  
0020FA5C    24060100	li          a2,0x100            IX .. .. .. .. .. .. ..  
0020FA60    ACE2E1A0	sw          v0,0xE1A0(a3)       .. .. LS .. .. .. .. ..  
0020FA64    0C09BA5A	jal         0x0026E968          .. .. .. BR .. .. .. ..                         0x000000000026e968                reallyGTFO(char const *,...)
0020FA68    AD03E1A4	sw          v1,0xE1A4(t0)       .. .. LS .. .. .. .. ..  
0020FA6C    001020C2	srl         a0,s0,3             IX .. .. .. .. .. .. ..  

-- good path?
0020FA70    32020007	andi        v0,s0,0x7           IX .. .. .. .. .. .. ..  
0020FA74    24030001	li          v1,0x1              IX .. .. .. .. .. .. ..  
0020FA78    A3A40000	sb          a0,0x0000(sp)       .. .. LS .. .. .. .. ..  
0020FA7C    00431804	sllv        v1,v1,v0            IX .. .. .. .. .. .. ..  
0020FA80    308200FF	andi        v0,a0,0xFF          IX .. .. .. .. .. .. ..  
0020FA84    24420010	addiu       v0,v0,0x10          IX .. .. .. .. .. .. ..  [01] REG 
0020FA88    A3A30001	sb          v1,0x0001(sp)       .. .. LS .. .. .. .. ..  
0020FA8C    12400006	beq         s2,zero,0x0020FAA8  .. .. .. BR .. .. .. ..  [01] BRANCH  -- to path 1
0020FA90    02222021	addu        a0,s1,v0            IX .. .. .. .. .. .. ..  

0020FA94    90820000	lbu         v0,0x0000(a0)       .. .. LS .. .. .. .. ..  [01] REG 
0020FA98    00431025	or          v0,v0,v1            IX .. .. .. .. .. .. ..  [01] REG 
0020FA9C    10000007	b           0x0020FABC          .. .. .. BR .. .. .. ..  [01] BRANCH   - to path 2
0020FAA0    A0820000	sb          v0,0x0000(a0)       .. .. LS .. .. .. .. ..  

0020FAA4    00000000	nop                             IX .. .. .. .. .. .. ..  
-- path 1
0020FAA8    93A20001	lbu         v0,0x0001(sp)       .. .. LS .. .. .. .. ..  
0020FAAC    90830000	lbu         v1,0x0000(a0)       .. .. LS .. .. .. .. ..  [01] PIPE 
0020FAB0    00021027	nor         v0,zero,v0          IX .. .. .. .. .. .. ..  
0020FAB4    00621824	and         v1,v1,v0            IX .. .. .. .. .. .. ..  [01] REG 
0020FAB8    A0830000	sb          v1,0x0000(a0)       .. .. LS .. .. .. .. ..    (not hit during unlock?)
-- path 2
0020FABC    24020001	li          v0,0x1              IX .. .. .. .. .. .. ..  

-- early exit?
0020FAC0    DFB00010	ld          s0,0x0010(sp)       .. .. LS .. .. .. .. ..  
0020FAC4    DFB10018	ld          s1,0x0018(sp)       .. .. LS .. .. .. .. ..  [01] PIPE 
0020FAC8    DFB20020	ld          s2,0x0020(sp)       .. .. LS .. .. .. .. ..  
0020FACC    DFBF0028	ld          ra,0x0028(sp)       .. .. LS .. .. .. .. ..  [01] PIPE 
0020FAD0    03E00008	jr          ra                  .. .. .. BR .. .. .. ..  [01] REG 
0020FAD4    27BD0030	addiu       sp,sp,0x30          IX .. .. .. .. .. .. ..  


--]]


--[[

0x00000000001dbdd0                CScenarioManager::isScenarioCompleted(int) const

001DBDD0    00051B03	sra         v1,a1,12            IX .. .. .. .. .. .. ..  
001DBDD4    27BDFFF0	addiu       sp,sp,-0x10         IX .. .. .. .. .. .. ..  
001DBDD8    0060282D	dmove       a1,v1               IX .. .. .. .. .. .. ..  
001DBDDC    28630100	slti        v1,v1,0x100         IX .. .. .. .. .. .. ..  
001DBDE0    FFBF0000	sd          ra,0x0000(sp)       .. .. LS .. .. .. .. ..  
001DBDE4    10600008	beq         v1,zero,0x001DBE08  .. .. .. BR .. .. .. ..  [01] BRANCH  -- to early exit
001DBDE8    0000102D	dmove       v0,zero             IX .. .. .. .. .. .. ..  
001DBDEC    3C020033	lui         v0,0x33             IX .. .. .. .. .. .. ..  
001DBDF0    DFBF0000	ld          ra,0x0000(sp)       .. .. LS .. .. .. .. ..  
001DBDF4    8C445660	lw          a0,0x5660(v0)       .. .. LS .. .. .. .. ..  [01] PIPE 
001DBDF8    24840070	addiu       a0,a0,0x70          IX .. .. .. .. .. .. ..  [01] REG 
001DBDFC    08083E1E	j           0x0020F878          .. .. .. BR .. .. .. ..              020f878                CAchievementMgr::isAchievementAchieved(unsigned int) const
001DBE00    27BD0010	addiu       sp,sp,0x10          IX .. .. .. .. .. .. ..  
001DBE04    00000000	nop                             IX .. .. .. .. .. .. ..  

-- early exit
001DBE08    DFBF0000	ld          ra,0x0000(sp)       .. .. LS .. .. .. .. ..  
001DBE0C    03E00008	jr          ra                  .. .. .. BR .. .. .. ..  [02] REG 
001DBE10    27BD0010	addiu       sp,sp,0x10          IX .. .. .. .. .. .. ..  



--]]


local DEFENSE_EXPERT_ADVANCE_RETREAT =        0x00100000
local DEFENSE_ADVANCE_RETREAT =               0x00080000
local OFFENSE_UNLIMITED_STOCK_PUNCHING_BAG =  0x00040000
local OFFENSE_VAMPIRE_SURVIVAL =              0x00020000
local OFFENSE_UNLIMITED_STOCK_PERFECT_ROUND = 0x00010000
local EXPERT_BOSS_BATTLE_UNLIMITED_STOCK =    0x00008000
local COMBOS_TRAINING_3HIT =                  0x00004000
local OFFENSE_PUNCHING_BAG =                  0x00002000
local ADVANCE_MODE_STOCK_TRAINING =           0x00001000
local OFFENSE_REGENERATING_ENEMY =            0x00000800
local ENDURANCE_TIME_TRIAL =                  0x00000400
local MAX_MODE_TRAINING_MAX_VAMPIRE =         0x00000200
local DMS_SPEED_RUN =                         0x00000100
local PERFECT_ROUND =                         0x00000080
local OFFENSE_DIZZIES =                       0x00000040
local OFFENSE_CALCULATED_STRIKES =            0x00000020
local EVASION_HOT_POTATO =                    0x00000010
local EVASION_GLASS_JAW =                     0x00000008
local OFFENSE_FAVOURITE_ATTACK =              0x00000004
local BLIND_FIGHTING =                        0x00000002

local ADV_MODE_CHALLENGES =   ADVANCE_MODE_STOCK_TRAINING +
                              DEFENSE_ADVANCE_RETREAT +
                              DEFENSE_EXPERT_ADVANCE_RETREAT

local EXTRA_MODE_CHALLENGES = MAX_MODE_TRAINING_MAX_VAMPIRE

local OFFENSE_CHALLENGES =    COMBOS_TRAINING_3HIT +
                              DMS_SPEED_RUN +
                              EXPERT_BOSS_BATTLE_UNLIMITED_STOCK +
                              MAX_MODE_TRAINING_MAX_VAMPIRE +
                              OFFENSE_CALCULATED_STRIKES +
                              OFFENSE_DIZZIES +
                              OFFENSE_FAVOURITE_ATTACK +
                              OFFENSE_PUNCHING_BAG +
                              OFFENSE_REGENERATING_ENEMY +
                              OFFENSE_UNLIMITED_STOCK_PERFECT_ROUND +
                              OFFENSE_UNLIMITED_STOCK_PUNCHING_BAG +
                              OFFENSE_VAMPIRE_SURVIVAL

local DEFENSE_CHALLENGES =    DEFENSE_ADVANCE_RETREAT +
                              DEFENSE_EXPERT_ADVANCE_RETREAT +
                              EVASION_GLASS_JAW +
                              EVASION_HOT_POTATO +
                              PERFECT_ROUND

local COMBO_CHALLENGES =      COMBOS_TRAINING_3HIT +  
                              OFFENSE_VAMPIRE_SURVIVAL

local ENDURANCE_CHALLENGES =  ENDURANCE_TIME_TRIAL +
                              EXPERT_BOSS_BATTLE_UNLIMITED_STOCK

local TIME_TRIAL_CHALLENGES = DMS_SPEED_RUN +
                              ENDURANCE_TIME_TRIAL +
                              OFFENSE_VAMPIRE_SURVIVAL

local DM_CHALLENGES =         DMS_SPEED_RUN +
                              EXPERT_BOSS_BATTLE_UNLIMITED_STOCK + 
                              OFFENSE_UNLIMITED_STOCK_PERFECT_ROUND

local SECRET_CHR_CHALLENGES = DEFENSE_ADVANCE_RETREAT + 
                              DMS_SPEED_RUN +
                              OFFENSE_FAVOURITE_ATTACK

local ALL_CHALLENGES        = DEFENSE_EXPERT_ADVANCE_RETREAT +
                              DEFENSE_ADVANCE_RETREAT +
                              OFFENSE_UNLIMITED_STOCK_PUNCHING_BAG +
                              OFFENSE_VAMPIRE_SURVIVAL +
                              OFFENSE_UNLIMITED_STOCK_PERFECT_ROUND +
                              EXPERT_BOSS_BATTLE_UNLIMITED_STOCK +
                              COMBOS_TRAINING_3HIT +
                              OFFENSE_PUNCHING_BAG +
                              ADVANCE_MODE_STOCK_TRAINING +
                              OFFENSE_REGENERATING_ENEMY +
                              ENDURANCE_TIME_TRIAL +
                              MAX_MODE_TRAINING_MAX_VAMPIRE +
                              DMS_SPEED_RUN +
                              PERFECT_ROUND +
                              OFFENSE_DIZZIES +
                              OFFENSE_CALCULATED_STRIKES +
                              EVASION_HOT_POTATO +
                              EVASION_GLASS_JAW +
                              OFFENSE_FAVOURITE_ATTACK +
                              BLIND_FIGHTING




local ChallengeCompleteFunc = function()
	print( string.format("ChallengeCompleteFunc\n" ) )
	
	local unlockaddress = eeObj.GetGPR(gpr.a0) & ~3;
	
	local flags = eeObj.ReadMem32(unlockaddress)

	print( string.format("Unlock Address is %08x Flages are %08x\n", unlockaddress, flags ) )	
	
	if ((flags & ADV_MODE_CHALLENGES) == ADV_MODE_CHALLENGES) then AwardTrophy(23, "Chal1", 0xff) end
	if ((flags & EXTRA_MODE_CHALLENGES) == EXTRA_MODE_CHALLENGES) then AwardTrophy(24, "Chal2", 0xff) end
	if ((flags & OFFENSE_CHALLENGES) == OFFENSE_CHALLENGES) then AwardTrophy(25, "Chal3", 0xff) end
	if ((flags & DEFENSE_CHALLENGES) == DEFENSE_CHALLENGES) then AwardTrophy(26, "Chal4", 0xff) end
	if ((flags & COMBO_CHALLENGES) == COMBO_CHALLENGES) then AwardTrophy(27, "Chal5", 0xff) end
	if ((flags & ENDURANCE_CHALLENGES) == ENDURANCE_CHALLENGES) then AwardTrophy(28, "Chal6", 0xff) end
	if ((flags & TIME_TRIAL_CHALLENGES) == TIME_TRIAL_CHALLENGES) then AwardTrophy(29, "Chal7", 0xff) end
	if ((flags & DM_CHALLENGES) == DM_CHALLENGES) then AwardTrophy(30, "Chal8", 0xff) end
	if ((flags & SECRET_CHR_CHALLENGES) == SECRET_CHR_CHALLENGES) then AwardTrophy(31, "Chal9", 0xff) end	
	if ((flags & ALL_CHALLENGES) == ALL_CHALLENGES) then AwardTrophy(32, "ChalALL", 0xff) end
	
end 


if Region == 1 then
	ChallengeCompleteHook = eeObj.AddHook(0x0020FABC,0x24020001,ChallengeCompleteFunc)
elseif Region == 2 then
	ChallengeCompleteHook = eeObj.AddHook(0x002110c4,0x24020001,ChallengeCompleteFunc)
end



    
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


