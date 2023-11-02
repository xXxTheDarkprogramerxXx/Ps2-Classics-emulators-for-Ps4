-- Lua 5.3
-- Title:   Dark Cloud - SCUS-97111 (USA) v1.01 (EU) v1.00 (JP) v1.00
-- Trophies version: 1.08
-- Author:  Tim Lindquist
-- Date: Aug 27, 2015

-- Changelog:
-- Bugfix 8156 TGL 20150226 H18. Fixed Bug 8156. false positive trophy 1 on unlock chest with key.
-- Changed all trophy pops to check SaveData first. This should eliminate any pops on save game load only.
-- Bugfix 8240 20150310 H16 TGL. Fixed unobtainable trophy 22 (fish length). Changed compare from hex to float.
-- Bugfix Toan's house 20150507 TGL. Fixed variable pointer for SCEJ.
-- bugfix 20150319 Hook7 TGL. Fix for possible false positive condition. Changed hook location.
-- bug fix 96248 20150504 TGL. Fixed false positive upon entering Norune without conditions met.
-- Bugfix 10 Trees 20150520 TGL. Fixed false positive by setting things in other towns with the same ID as Norune Trees.
-- Changed trophy 12, 16, 25 per studio request.
-- Consolidated all three regions into one codebase.
-- Added extra check to Home_Sweet_Home trophy to make sure it's only in Norune
-- Bugfix 8898. Forgot to remove the old trophy IDs.
-- modified initsaves()

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj			= getEEObject()
local emuObj			= getEmuObject()
local trophyObj		= getTrophyObject()

-- Trophy constants

local		trophy_id					=	0
local		trophy_Call_it_a_hunch		=	1
local		trophy_Heads_up				=	2
local		trophy_Whats_this			=	3
local		trophy_Hoarder				=	4
local		trophy_Call_for_Backup		=	5
local		trophy_For_the_birds		=	6
local		trophy_Sticky_Fingers		=	7
local		trophy_Status_Breaker		=	8
local		trophy_Teach_a_man_to_fish	=	9
local		trophy_Calculating_Kindness	=	10
local		trophy_Home_Sweet_Home		=	11
local		trophy_Weapon_Collector		=	12 -- changed 20150724 per studio request
local		trophy_Even_Stronger		=	13 -- name changed 20150724 per studio request
local		trophy_Solar_Power			=	14
local		trophy_A_Rare_Catch			=	15
local		trophy_Specialized_Weapon	=	16 -- changed 20150724 per studio request
local		trophy_The_God_of_Beasts	=	17
local		trophy_Forest_Keeper		=	18
local		trophy_Ice_Queen			=	19
local		trophy_Break_the_Curse		=	20
local		trophy_A_New_Champion		=	21
local		trophy_The_Big_One			=	22
local		trophy_Hometown_Hero		=	23
local		trophy_Comfort_Food			=	24
local		trophy_Tycoon				=	25 -- changed 20150724 per studio request
local		trophy_Lets_go_home			=	26
local		trophy_Strength_in_Numbers	=	27

-- Constants (change per region)

local titleid = emuObj.GetDiscTitleId() -- returns string as read from iso img SYSTEM.CNF

local mapNo_ptr = 0
local UserStatus = 0
local gilda_offset = 0
local objID = 0
local houseID = 0
local vsync = 0

if titleid == 'SCUS-97111' then
	mapNo_ptr = 0x2a2518
	UserStatus = 0x2a3468
	gilda_offset = 0x4346
	objID = 0x1d1a81c
	houseID = 0x1d19c54
end

if titleid == 'SCES-50295' then
	mapNo_ptr = 0x2a4e24
	UserStatus = 0x2a5d88
	gilda_offset = 0x4346
	objID = 0x1d2d48c
	houseID = 0x1D2C8C4
end

if titleid == 'SCPS-15004' then
	mapNo_ptr = 0x285310
	UserStatus = 0x2861e0
	gilda_offset = 0x3ede
	objID = 0x1d3299c
	houseID = 0x1D31DD4
end

-- PS4 SaveData

local SaveData = emuObj.LoadConfig(0)

if not next(SaveData) then
	SaveData.t  = {}
end

function initsaves()
	local x = 0
	for x = 1, 27 do
		if SaveData.t[x] == nil then
			SaveData.t[x] = 0
			emuObj.SaveConfig(0, SaveData)
		end
	end
end

initsaves()

-- Unlock trophy function

function unlockTrophy(trophy_id)
	if SaveData.t[trophy_id] ~= 1 then
		SaveData.t[trophy_id] = 1
		trophyObj.Unlock(trophy_id)
		emuObj.SaveConfig(0, SaveData)			
	end
	if SaveData.t[trophy_Tycoon] == 1 then
		emuObj.RemoveVsyncHook(vsync)
	end
end

local cheat =
	function()
		eeObj.WriteMem16(0x1CD955E, 0x00ff) -- Toan HP
		eeObj.WriteMem16(0x1CD9552, 0x00ff) -- Toan Max HP
		eeObj.WriteMem16(0x1CDD894, 0x0063) -- Toan Max Defense
		eeObj.WriteMem32(0x1cdda68, 0x42C60000) -- Toan Weapon HP
		eeObj.WriteMem32(0x1CDD850, 0x42C80000) -- Toan Water
		eeObj.WriteMem16(0x1CD9560, 0x00ff) -- Xiao HP
		eeObj.WriteMem16(0x1CD9554, 0x00ff) -- Xiao Max HP
		eeObj.WriteMem16(0x1CDE33C, 0x0063) -- Xiao Max Defense
		eeObj.WriteMem32(0x1CDD854, 0x42C80000) -- Xiao Water
		eeObj.WriteMem16(0x1CD9566, 0x00ff) -- Ungaga HP
		eeObj.WriteMem16(0x1CD955A, 0x00ff) -- Ungaga Max HP
		eeObj.WriteMem16(0x1CDE342, 0x0063) -- Ungaga Max Defense
		eeObj.WriteMem32(0x1CDD860, 0x42C80000) -- Ungaga Water
		eeObj.WriteMem8(0x2A35A0, 0x01) -- Always have dungeon crystal
		eeObj.WriteMem8(0x2A359C, 0x01) -- Always have dungeon map
	end

local kill = -- One hit kills
	function()
		local enemyhp = eeObj.GetGPR(gpr.at) - 0x1c0c
		eeObj.WriteMem32(enemyhp, 0x63)
	end

local H1 = -- Status break
	function()
		unlockTrophy(trophy_Status_Breaker) -- true positive tested 20150226 TGL
	end

local H2 = -- Transform weapon to new weapon
	function()
		local weapon = eeObj.GetGPR(gpr.v1)
			unlockTrophy(trophy_Even_Stronger) -- name changed 20150724 per studio request
	end

local H3 = -- Attach things to weapons
	function()
		local item = eeObj.GetGPR(gpr.v0)
		if item == 0x6b then
			unlockTrophy(trophy_Solar_Power) -- true positive tested 20150226 TGL
		end		
	end

local H3j = -- Attach things to weapons
	function()
		local item = eeObj.GetGPR(gpr.a0)
		if item == 0x6b then
			unlockTrophy(trophy_Solar_Power) -- true positive tested 20150226 TGL
		end		
	end

local H4 = -- Max an attribute for a weapon -- changed 20150724 per studio request
	function ()
		local fi = eeObj.ReadMem8(eeObj.GetGPR(gpr.s0) + 0x17)
		local ic = eeObj.ReadMem8(eeObj.GetGPR(gpr.s0) + 0x18)
		local th = eeObj.ReadMem8(eeObj.GetGPR(gpr.s0) + 0x19)
		local wi = eeObj.ReadMem8(eeObj.GetGPR(gpr.s0) + 0x1a)
		local ho = eeObj.ReadMem8(eeObj.GetGPR(gpr.s0) + 0x1b)
		local lv = eeObj.ReadMem8(eeObj.GetGPR(gpr.s0) + 2)
--		print(string.format("fi = %x", fi))
--		print(string.format("ic = %x", ic))
--		print(string.format("th = %x", th))
--		print(string.format("wi = %x", wi))
--		print(string.format("ho = %x", ho))
--		print(string.format("lv = %x", lv))
		if fi == 0x63 or ic == 0x63 or th == 0x63 or wi == 0x63 or ho == 0x63 then
			unlockTrophy(trophy_Specialized_Weapon) -- tested true positive 20150724
		end
		if lv >= 9 then
			unlockTrophy(trophy_Weapon_Collector) -- Perform 10 weapon upgrades -- tested true positive 20150724
		end
	end

local H4j = -- Max an attribute for a weapon -- changed 20150724 per studio request
	function ()
		local fi = eeObj.ReadMem8(eeObj.GetGPR(gpr.s1) + 0x17)
		local ic = eeObj.ReadMem8(eeObj.GetGPR(gpr.s1) + 0x18)
		local th = eeObj.ReadMem8(eeObj.GetGPR(gpr.s1) + 0x19)
		local wi = eeObj.ReadMem8(eeObj.GetGPR(gpr.s1) + 0x1a)
		local ho = eeObj.ReadMem8(eeObj.GetGPR(gpr.s1) + 0x1b)
		local lv = eeObj.ReadMem8(eeObj.GetGPR(gpr.s1) + 2)
--		print(string.format("fi = %x", fi))
--		print(string.format("ic = %x", ic))
--		print(string.format("th = %x", th))
--		print(string.format("wi = %x", wi))
--		print(string.format("ho = %x", ho))
--		print(string.format("lv = %x", lv))
		if fi == 0x63 or ic == 0x63 or th == 0x63 or wi == 0x63 or ho == 0x63 then
			unlockTrophy(trophy_Specialized_Weapon) -- tested true positive 20150724
		end
		if lv >= 9 then
			unlockTrophy(trophy_Weapon_Collector) -- Perform 10 weapon upgrades -- tested true positive 20150724
		end
	end

local H5 = -- Steal something
	function()
		unlockTrophy(trophy_Sticky_Fingers) -- true positive tested 20150302 TGL.
	end

local H6 = -- Eat somebody's favorite food
	function()
		local food = eeObj.GetGPR(gpr.a1)
		local dood = eeObj.GetGPR(gpr.a2)
		if (food == 0x88 and dood == 0) or (food == 0x89 and dood == 1) or
		(food == 0x8a and dood == 2) or (food == 0x8b and dood == 3) or
		(food == 0x8c and dood == 4) or (food == 0x8d and dood == 5) then
			unlockTrophy(trophy_Comfort_Food) -- true positive tested toan eating fluffy donut 20150226 TGL
		end
	end

local H7 = -- Use stand-in powder
	function()
		unlockTrophy(trophy_Call_for_Backup) -- true positive tested 20150319 TGL
	end

local H8 = -- Kill an enemy
	function()
		local toss = eeObj.GetGPR(gpr.s3)
		local boss = eeObj.ReadMem32(eeObj.GetGPR(gpr.at) - 0x21d0)
		if toss == 0xffffffff then -- Killed enemy with thrown item
			unlockTrophy(trophy_Heads_up) -- true positive tested 20150227 TGL.
		end
		if boss == 0x61323163 then -- killed Dran
			unlockTrophy(trophy_The_God_of_Beasts) -- true postivie tested FPQA
		end
		if boss == 0x61343163 then -- killed Masterutan
			unlockTrophy(trophy_Forest_Keeper) -- true postivie tested FPQA
		end
		if boss == 0x61333163 then -- killed La Saia
			unlockTrophy(trophy_Ice_Queen) -- true postivie tested FPQA
		end
		if boss == 0x61353163 then -- killed King's Curse
			unlockTrophy(trophy_Break_the_Curse) -- true postivie tested FPQA
		end
		if boss == 0x61363163 then -- killed Minotaur Joe
			unlockTrophy(trophy_A_New_Champion) -- true postivie tested FPQA
		end
		if boss == 0x61333263 then -- killed Dark Genie
			unlockTrophy(trophy_Lets_go_home) -- true postivie tested FPQA
		end
	end

local H8j = -- Kill an enemy
	function()
		local toss = eeObj.GetGPR(gpr.s2)
		local boss = eeObj.ReadMem32(eeObj.GetGPR(gpr.at) - 0x21d0)
		if toss == 0xffffffff then -- Killed enemy with thrown item
			unlockTrophy(trophy_Heads_up) -- true positive tested 20150227 TGL.
		end
		if boss == 0x61323163 then -- killed Dran
			unlockTrophy(trophy_The_God_of_Beasts) -- true postivie tested FPQA
		end
		if boss == 0x61343163 then -- killed Masterutan
			unlockTrophy(trophy_Forest_Keeper) -- true postivie tested FPQA
		end
		if boss == 0x61333163 then -- killed La Saia
			unlockTrophy(trophy_Ice_Queen) -- true postivie tested FPQA
		end
		if boss == 0x61353163 then -- killed King's Curse
			unlockTrophy(trophy_Break_the_Curse) -- true postivie tested FPQA
		end
		if boss == 0x61363163 then -- killed Minotaur Joe
			unlockTrophy(trophy_A_New_Champion) -- true postivie tested FPQA
		end
		if boss == 0x61373163 then -- killed Dark Genie
			unlockTrophy(trophy_Lets_go_home) -- true postivie tested FPQA
		end
	end

local H9 = -- Get new allies
	function()
		local allies = eeObj.GetGPR(gpr.v0)
		if allies == 6 then -- got all six
			unlockTrophy(trophy_Strength_in_Numbers) -- true postivie tested FPQA
		end
		if allies == 2 then -- got Xiao
			unlockTrophy(trophy_Whats_this) -- true postivie tested FPQA
		end
	end

local H10 = -- Arrange 10 trees
	function()
		local obj = eeObj.GetGPR(gpr.v0)
		local qty = eeObj.GetGPR(gpr.v1)
		local mapNo = eeObj.ReadMem8(mapNo_ptr)
		if (obj == objID and qty == 0x0a and mapNo == 0) then -- placed 10 Norune trees -- Bugfix 10 Trees 20150507 TGL.
			unlockTrophy(trophy_For_the_birds) -- true positive tested 20150507 TGL. - False positive fix tested 20150520.
		end
	end

local H11 = -- Acquire item
	function()
		local item = eeObj.GetGPR(gpr.a0)
		if item == 0xb9 then -- got fishing rod
			unlockTrophy(trophy_Teach_a_man_to_fish) -- true postivie tested FPQA
		end
	end

local H12 = -- Assemble Toan's house
	function()
		local house = eeObj.GetGPR(gpr.s5)
		local mapNo = eeObj.ReadMem8(mapNo_ptr)
		if house == houseID and mapNo == 0 then
			unlockTrophy(trophy_Home_Sweet_Home) -- true positive tested 20150226 TGL
		end
	end

local H13 = -- Complete a request on the Georama Analysis screen
	function()
		local percent = eeObj.GetFPR(0)
		if percent > 0 then
			unlockTrophy(trophy_Calculating_Kindness)
		end
	end

local H14 = -- Check-in an item
	function()
		unlockTrophy(trophy_Hoarder) -- true postivie tested FPQA
	end

local H15 = -- Fish kind
	function()
		local fish = eeObj.GetGPR(gpr.v0)
		if fish == 0x11 then -- caught Baron Garayan
			unlockTrophy(trophy_A_Rare_Catch) -- true postivie tested FPQA
		end
	end

local H16 = -- Fish length
	function()
		local length = eeObj.GetFPR(12)
--		print(string.format("fish = %f", length))
		if length >= 100.0 then -- More than 100 cm -- bugfix 8240 20150310 H16 TGL.
			unlockTrophy(trophy_The_Big_One) -- true postitive tested 20150310 H16 TGL.
		end
	end

local H16j = -- Fish kind and length
	function()
		local length = eeObj.GetFPR(12)
		if length >= 100.0 then -- More than 100 cm
			unlockTrophy(trophy_The_Big_One) -- untested
		end
		local fish = eeObj.GetGPR(gpr.a1)
		if fish == 0x05 then -- caught マーダンガラヤン
			unlockTrophy(trophy_A_Rare_Catch) -- untested
		end
	end

local H17 = -- Learn windmill slash
	function()
		unlockTrophy(trophy_Hometown_Hero) -- true positive tested 20150226 TGL
	end

local H18 = -- Force open a trap on a chest
	function()
		local trapid = eeObj.ReadMem32(eeObj.GetGPR(gpr.a0) - 0x14) -- bugfix 8156 TGL 20150226 H18.
		if trapid ~= 0 then -- didn't use a key to unlock
			unlockTrophy(trophy_Call_it_a_hunch) -- true positive tested TGL 20150226
		end
	end

local HX_VSYNC =
	function()
		local UserStatus_ptr = eeObj.ReadMem32(UserStatus)
		if UserStatus_ptr ~= 0 then
			local gilda = eeObj.ReadMem16(eeObj.ReadMem32(UserStatus)+gilda_offset)
--		print(string.format("gilda = %s", gilda))
			if gilda == 0xFFFF then
				unlockTrophy(trophy_Tycoon)
			end
		end
	end

-- register hooks

if titleid == 'SCUS-97111' then
	local Hook1 = eeObj.AddHook(0x2368d0, 0x27bdff70, H1) -- SetStatusBreak__14CWeaponLevelUpFP11WEAPON_HAVEP10CCharacterP1i
	local Hook2 = eeObj.AddHook(0x237794, 0x862312de, H2) -- Step__14CWeaponLevelUpFv
	local Hook3 = eeObj.AddHook(0x200318, 0x86240000, H3) -- WeaponMenuAttachWepKey__Fv
	local Hook4 = eeObj.AddHook(0x236770, 0x27bdffd0, H4) -- SetLevelUpWeaponData__14CWeaponLevelUpFv
	local Hook5 = eeObj.AddHook(0x1d7a18, 0x8ca20134, H5) -- checkEvent__10CStealItemFv
	local Hook6 = eeObj.AddHook(0x20c3e0, 0x27bdfd90, H6) -- ItemUseFunc__FP11CUserStatusiiiP11WEAPON_HAVE
	local Hook7 = eeObj.AddHook(0x2294c8, 0x240500ae, H7) -- <CharaChangeKey(void)> -- bugfix 20150319 Hook7 TGL.
	local Hook8 = eeObj.AddHook(0x1bf700, 0x80850000, H8) -- AddKills__14CDngStatusDataFv
	local Hook9 = eeObj.AddHook(0x1954b0, 0xa2020005, H9) -- _SSET_PARTY_NUM__FP12RS_STACKDATAi
	local Hook10 = eeObj.AddHook(0x1a0744, 0xac43000c, H10) -- SetMapParts__11CEditGroundFifffi
	local Hook11 = eeObj.AddHook(0x160290, 0x27bdff80, H11) -- ItemGetMes__Fiiii
	local Hook12 = eeObj.AddHook(0x218748, 0x24020001, H12) -- AtoraCompOrEvent__FP14EDITPARTS_INFO
	local Hook13 = eeObj.AddHook(0x212300, 0x46010034, H13) -- <AnalyzeRequestPer(void)> -- bug fix 96248 20150504 TGL
	local Hook14 = eeObj.AddHook(0x1ea21c, 0x24020002, H14) -- ChargeSelectKey__Fv
	local Hook15 = eeObj.AddHook(0x1a96fc, 0x8c420000, H15) -- FishingFishKind__Fi
	local Hook16 = eeObj.AddHook(0x157e04, 0xe50c0000, H16) -- SetFishingRank__9CSaveDataFif
	local Hook17 = eeObj.AddHook(0x1903d4, 0x24050028, H17) -- _SKILL_GET_MES__FP12RS_STACKDATAi
	local Hook18 = eeObj.AddHook(0x1bd254, 0xac2067ec, H18) -- _RESET_ITEM_TRAP__FP12RS_STACKDATAi
end

if titleid == 'SCES-50295' then
	local Hook1 = eeObj.AddHook(0x238780, 0x27bdff70, H1) -- SetStatusBreak__14CWeaponLevelUpFP11WEAPON_HAVEP10CCharacterP1i
	local Hook2 = eeObj.AddHook(0x239644, 0x862312de, H2) -- Step__14CWeaponLevelUpFv
	local Hook3 = eeObj.AddHook(0x201818, 0x86240000, H3) -- WeaponMenuAttachWepKey__Fv
	local Hook4 = eeObj.AddHook(0x238620, 0x27bdffd0, H4) -- SetLevelUpWeaponData__14CWeaponLevelUpFv
	local Hook5 = eeObj.AddHook(0x1d8c48, 0x8ca20134, H5) -- checkEvent__10CStealItemFv
	local Hook6 = eeObj.AddHook(0x20da80, 0x27bdfd90, H6) -- ItemUseFunc__FP11CUserStatusiiiP11WEAPON_HAVE
	local Hook7 = eeObj.AddHook(0x22b328, 0x240500ae, H7) -- <CharaChangeKey(void)>
	local Hook8 = eeObj.AddHook(0x1c0800, 0x80850000, H8) -- AddKills__14CDngStatusDataFv
	local Hook9 = eeObj.AddHook(0x195fa0, 0xa2020005, H9) -- _SSET_PARTY_NUM__FP12RS_STACKDATAi
	local Hook10 = eeObj.AddHook(0x1a12e4, 0xac43000c, H10) -- SetMapParts__11CEditGroundFifffi
	local Hook11 = eeObj.AddHook(0x160380, 0x27bdff80, H11) -- ItemGetMes__Fiiii
	local Hook12 = eeObj.AddHook(0x219da8, 0x24020001, H12) -- AtoraCompOrEvent__FP14EDITPARTS_INFO
	local Hook13 = eeObj.AddHook(0x2139a0, 0x46010034, H13) -- <AnalyzeRequestPer(void)> -- bug fix 96248 20150504 TGL
	local Hook14 = eeObj.AddHook(0x1eb61c, 0x24020002, H14) -- ChargeSelectKey__Fv
	local Hook15 = eeObj.AddHook(0x1aa29c, 0x8c420000, H15) -- FishingFishKind__Fi
	local Hook16 = eeObj.AddHook(0x157ef4, 0xe50c0000, H16) -- SetFishingRank__9CSaveDataFif
	local Hook17 = eeObj.AddHook(0x190ec4, 0x24050028, H17) -- _SKILL_GET_MES__FP12RS_STACKDATAi
	local Hook18 = eeObj.AddHook(0x1be354, 0xac20995c, H18) -- _RESET_ITEM_TRAP__FP12RS_STACKDATAi
end

if titleid == 'SCPS-15004' then
	local Hook1 = eeObj.AddHook(0x22f2c0, 0x27bdff60, H1) -- SetStatusBreak__14CWeaponLevelUpFP11WEAPON_HAVEP10CCharacterP1i
	local Hook2 = eeObj.AddHook(0x22ffa0, 0x862312d0, H2) -- Step__14CWeaponLevelUpFv
	local Hook3 = eeObj.AddHook(0x1fb954, 0x86220000, H3j) -- WeaponMenuAttachWepKey__Fv
	local Hook4 = eeObj.AddHook(0x22f150, 0x27bdffd0, H4j) -- SetLevelUpWeaponData__14CWeaponLevelUpFv
	local Hook5 = eeObj.AddHook(0x1d46f8, 0x8ca20134, H5) -- checkEvent__10CStealItemFv
	local Hook6 = eeObj.AddHook(0x207120, 0x27bdfdb0, H6) -- ItemUseFunc__FP11CUserStatusiiiP11WEAPON_HAVE
	local Hook7 = eeObj.AddHook(0x2220f4, 0x240500ae, H7) -- <CharaChangeKey(void)>
	local Hook8 = eeObj.AddHook(0x1bc5f0, 0x80850000, H8j) -- AddKills__14CDngStatusDataFv
	local Hook9 = eeObj.AddHook(0x195950, 0xa2020005, H9) -- _SSET_PARTY_NUM__FP12RS_STACKDATAi
	local Hook10 = eeObj.AddHook(0x1a0cac, 0xac43000c, H10) -- SetMapParts__11CEditGroundFifffi
	local Hook11 = eeObj.AddHook(0x15fdf0, 0x27bdffd0, H11) -- ItemGetMes__Fiiii
	local Hook12 = eeObj.AddHook(0x211814, 0x24020001, H12) -- AtoraCompOrEvent__FP14EDITPARTS_INFO
	local Hook13 = eeObj.AddHook(0x20bec0, 0x46010034, H13) -- <AnalyzeRequestPer(void)> -- bug fix 96248 20150504 TGL
	local Hook14 = eeObj.AddHook(0x1e5d44, 0x24020002, H14) -- ChargeSelectKey__Fv
	local Hook16 = eeObj.AddHook(0x1579f4, 0xe50c0000, H16j) -- SetFishingRank__9CSaveDataFif
	local Hook17 = eeObj.AddHook(0x190864, 0x24050028, H17) -- _SKILL_GET_MES__FP12RS_STACKDATAi
	local Hook18 = eeObj.AddHook(0x1ba254, 0xac20590c, H18) -- _RESET_ITEM_TRAP__FP12RS_STACKDATAi
end

if SaveData.t[trophy_Tycoon] ~= 1 then
	vsync = emuObj.AddVsyncHook(HX_VSYNC)
end

-- Disable for release
--hack =  eeObj.AddHook(0x1d9f10, 0x27bdfd90, cheat) -- check damage
--onehk = eeObj.AddHook(0x1dc424, 0x00610821, kill) -- one hit kills

-- Credits

-- Trophy design and development by SCEA ISD SpecOps
-- David Thach			Senior Director
-- George Weising		Executive Producer
-- Tim Lindquist		Senior Technical PM
-- Clay Cowgill			Engineering
-- Nicola Salmoria		Engineering
-- David Haywood		Engineering
-- Warren Davis			Engineering
-- Ernesto Corvi		Engineering
-- Adam McInnis			Engineering
-- Jenny Murphy			Producer
-- David Alonzo			Assistant Producer
-- Tyler Chan			Associate Producer
-- Karla Quiros			Manager Business Finance & Ops
-- Mayene de la Cruz	Art Production Lead
-- Thomas Hindmarch		Production Coordinator
-- Special thanks to R&D, SWQA, FPQA, GFPQA, studios-all.