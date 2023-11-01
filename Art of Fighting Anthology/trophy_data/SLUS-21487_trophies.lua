-- Lua 5.3
-- Title: Art of Fighting Anthology - SLUS-21487 (USA) v1.00
-- Trophies version: 20170303
-- Author: Nicola Salmoria
-- Date: April 27, 2017


apiRequest(1.4)

local gpr = require( "ee-gpr-alias" )

local eeObj		= getEEObject()
local emuObj	= getEmuObject()
local trophyObj	= getTrophyObject()


local TROPHY_PERSONAL_REMIX								=  1
local TROPHY_THE_TIGER_AND_THE_DRAGON					=  2
local TROPHY_THE_STORY_OF_THE_DRAGON					=  3
local TROPHY_THE_STORY_OF_THE_TIGER						=  4
local TROPHY_HEIR_TO_THE_DOJO							=  5
local TROPHY_INNER_FIRE									=  6
local TROPHY_WHAT_A_TOUGH_GUY							=  7
local TROPHY_SORRY_ABOUT_YOUR_SHIRT						=  8
local TROPHY_TAKE_ME_TO_YOUR_BOSS						=  9
local TROPHY_GETTING_STRONGER_ALL_THE_TIME				= 10
local TROPHY_INVINCIBLE_DRAGON							= 11
local TROPHY_RAGING_TIGER								= 12
local TROPHY_BELIEVE_THE_HYPE							= 13
local TROPHY_BOTTLE_DISSERVICE							= 14
local TROPHY_CRUSHED_ICE								= 15
local TROPHY_SECRET_TECHNIQUE							= 16
local TROPHY_THE_BIRTH_OF_A_PHOENIX						= 17
local TROPHY_THE_FIRST_KING_OF_FIGHTERS					= 18
local TROPHY_PORTRAIT_OF_THE_CRIMELORD_AS_A_YOUNG_MAN	= 19
local TROPHY_TRANQUIL_FURY								= 20
local TROPHY_LUMBERJACKED								= 21
local TROPHY_NONE_LEFT_STANDING							= 22
local TROPHY_ULTIMATE_TECHNIQUE							= 23
local TROPHY_WORDS_HURT_YOU_KNOW						= 24
local TROPHY_WARDROBE_MALFUNCTION						= 25
local TROPHY_YOU_BROUGHT_A_SWORD_TO_A_FISTFIGHT			= 26
local TROPHY_UNFORESEEN_SIDE_EFFECTS					= 27
local TROPHY_WARRIOR_CONCERTO							= 28
local TROPHY_HIDDEN_AGENDA								= 29
local TROPHY_ONCE_UPON_A_TIME_IN_MEXICO					= 30


-- persistent state handling
local userId = 0
local saveData = emuObj.LoadConfig(userId)

local SAVEDATA_ATTRACT_MOVIES_WATCHED		= "AttractMovies"
local SAVEDATA_COMPLETED_WITHOUT_CONTINUES	= "CompletedNoContinue"
local SAVEDATA_COMPLETED_RYO				= "CompletedRyo"
local SAVEDATA_COMPLETED_ROBERT				= "CompletedRobert"
local SAVEDATA_COMPLETED_HARD				= "CompletedHard"
local SAVEDATA_COMPLETED_AOF3_CHARACTERS	= "CompletedAoF3"


local ROOT_TASK_ADDRESS				= 0x21a408
local MENU_CONTENT_BODY_ADDRESS		= 0x214b20
local DEFAULT_PALETTE_ADDRESS		= 0x2ae070


-- emulated 68k addresses
local AOF_P1_DATA_ADDRESS			= 0x109080
local AOF_P2_DATA_ADDRESS			= 0x109180

local AOF2_P1_DATA_ADDRESS			= 0x109080
local AOF2_P2_DATA_ADDRESS			= 0x109180

local AOF3_P1_DATA_PTR_ADDRESS		= 0x104e28
local AOF3_P2_DATA_PTR_ADDRESS		= 0x104e2c


local function getNeoGeoTitleId()
	local gameState = eeObj.ReadMem32(ROOT_TASK_ADDRESS + 8)
	local currentState = eeObj.ReadMem32(gameState + 32)

	if currentState == 4 then		-- playing AoF
		return 0
	elseif currentState == 5 then	-- playing AoF 2
		return 1
	elseif currentState == 6 then	-- playing AoF 3
		return 2
	else
		return -1
	end
end


local mpu68 = {
	memorymap = 4,
	d0 =  8,
	d1 = 12,
	d2 = 16,
	d3 = 20,
	d4 = 24,
	d5 = 28,
	d6 = 32,
	d7 = 36,
	a0 = 40,
	a1 = 44,
	a2 = 48,
	a3 = 52,
	a4 = 56,
	a5 = 60,
	a6 = 64,
	a7 = 68,
	pc = 72,
}

local function memoryMappingGetByte(mpu, address)
	local mm = eeObj.ReadMem32(mpu + mpu68.memorymap)
	local page = (address >> 20) & 15
	local base = eeObj.ReadMem32(mm + 100 + page * 32)
	local mask = eeObj.ReadMem32(mm + 104 + page * 32)

	if base ~= 0 then
		local val = eeObj.ReadMem8(base + ((address & mask) ~ 1))
		return val
	else
		print( string.format("MEMORYMAPPING ERROR %06x", address) )
		return 0
	end
end

local function memoryMappingGetWord(mpu, address)
	return (memoryMappingGetByte(mpu, address) << 8) |
			memoryMappingGetByte(mpu, address + 1)
end

local function memoryMappingGetLong(mpu, address)
	return (memoryMappingGetWord(mpu, address) << 16) |
			memoryMappingGetWord(mpu, address + 2)
end



local function isPlayerCpuAoF(mpu, player)
	local state = memoryMappingGetByte(mpu, player + 0x40)
	return ((state & 0x40) == 0)
end

local function otherPlayerAoF(mpu, player)
	local p1Address = AOF_P1_DATA_ADDRESS
	local p2Address = AOF_P2_DATA_ADDRESS

	if player == p1Address then
		return p2Address
	elseif player == p2Address then
		return p1Address
	else
		print( string.format("PLAYER ADDRESS ERROR %06x vs %06x/%06x", player, p1Address, p2Address) )
		return player
	end
end

local function isHumanAgainstCpuAoF(mpu, player)
	thisCpu  = isPlayerCpuAoF(mpu, player)
	otherCpu = isPlayerCpuAoF(mpu, otherPlayerAoF(mpu, player))

	return (thisCpu == false and otherCpu == true)
end



local function isPlayerCpuAoF2(mpu, player)
	local state = memoryMappingGetByte(mpu, player + 0x60)
	return ((state & 0x40) == 0)
end

local function otherPlayerAoF2(mpu, player)
	local p1Address = AOF2_P1_DATA_ADDRESS
	local p2Address = AOF2_P2_DATA_ADDRESS

	if player == p1Address then
		return p2Address
	elseif player == p2Address then
		return p1Address
	else
		print( string.format("PLAYER ADDRESS ERROR %06x vs %06x/%06x", player, p1Address, p2Address) )
		return player
	end
end

local function isHumanAgainstCpuAoF2(mpu, player)
	thisCpu  = isPlayerCpuAoF2(mpu, player)
	otherCpu = isPlayerCpuAoF2(mpu, otherPlayerAoF2(mpu, player))

	return (thisCpu == false and otherCpu == true)
end



local function isPlayerCpuAoF3(mpu, player)
	local comFlg = memoryMappingGetByte(mpu, player + 0x72)
	return (comFlg ~= 0)
end

local function otherPlayerAoF3(mpu, player)
	local p1Address = memoryMappingGetLong(mpu, AOF3_P1_DATA_PTR_ADDRESS)
	local p2Address = memoryMappingGetLong(mpu, AOF3_P2_DATA_PTR_ADDRESS)

	if player == p1Address then
		return p2Address
	elseif player == p2Address then
		return p1Address
	else
		print( string.format("PLAYER ADDRESS ERROR %06x vs %06x/%06x", player, p1Address, p2Address) )
		return player
	end
end

local function isHumanAgainstCpuAoF3(mpu, player)
	thisCpu  = isPlayerCpuAoF3(mpu, player)
	otherCpu = isPlayerCpuAoF3(mpu, otherPlayerAoF3(mpu, player))

	return (thisCpu == false and otherCpu == true)
end



local function checkAllBitsTrophy(bit, numBits, saveDataTag, trophyId)
	local mask = saveData[saveDataTag]
	if mask == nil then
		mask = 0
	end

	mask = mask | (1 << bit)

	if saveData[saveDataTag] ~= mask then
		saveData[saveDataTag] = mask
		emuObj.SaveConfig(userId, saveData)
	end

	if mask == ((1 << numBits) - 1) then
		local trophy_id = trophyId
		trophyObj.Unlock(trophy_id)
	end
end

local function checkCompletedTrophy(titleId)
	checkAllBitsTrophy(titleId, 3, SAVEDATA_COMPLETED_WITHOUT_CONTINUES, TROPHY_THE_TIGER_AND_THE_DRAGON)
end

local function checkCompletedRyoTrophy(titleId)
	checkAllBitsTrophy(titleId, 3, SAVEDATA_COMPLETED_RYO, TROPHY_THE_STORY_OF_THE_DRAGON)
end

local function checkCompletedRobertTrophy(titleId)
	checkAllBitsTrophy(titleId, 3, SAVEDATA_COMPLETED_ROBERT, TROPHY_THE_STORY_OF_THE_TIGER)
end

local function checkCompletedHardTrophy(titleId)
	checkAllBitsTrophy(titleId, 3, SAVEDATA_COMPLETED_HARD, TROPHY_HEIR_TO_THE_DOJO)
end


local H1 =	-- confirm character palette change
	function()
		local currentPalette = MENU_CONTENT_BODY_ADDRESS + 356
		local defaultPalette = DEFAULT_PALETTE_ADDRESS
		local characterCounts = { 10, 12, 10 }

		for title = 0, 2 do
			local totalCharacters = characterCounts[title + 1]
			local numEditedCharacters = 0

			for character = 0, totalCharacters-1 do
				local offset = 2*128 * (character + 12 * title)
				local numDifferences = 0

				for i = 0, 127 do
					local currentColor = eeObj.ReadMem16(currentPalette + offset + 2 * i)
					local defaultColor = eeObj.ReadMem16(defaultPalette + offset + 2 * i)
					
					if currentColor ~= defaultColor then
						numDifferences = numDifferences + 1
					end
				end

				if numDifferences > 0 then
					numEditedCharacters = numEditedCharacters + 1
				end
			end

			if numEditedCharacters == totalCharacters then
				local trophy_id = TROPHY_PERSONAL_REMIX
				trophyObj.Unlock(trophy_id)
			end
		end
	end


local neverUsedContinue = false

local H2 =	-- handle opcode move.w
	function()
		local opcode = eeObj.GetGpr(gpr.a1)
		local mpu = eeObj.GetGpr(gpr.a0)
		local pc = eeObj.ReadMem32(mpu + mpu68.pc)

		local titleId = getNeoGeoTitleId()
		if		titleId == 0 and		-- AoF
				opcode == 0x302d and	-- move.w  ($xxxx,A5), D0
				pc == 0x633a then		-- Continue screen about to appear
			neverUsedContinue = false
		elseif	titleId == 1 and		-- AoF 2
				opcode == 0x302d and	-- move.w  ($xxxx,A5), D0
				pc == 0x1a5f6 then		-- Continue screen about to appear
			neverUsedContinue = false
		end
	end


local chargingUpFromEmpty = {}

local H4 =	-- handle opcode cmp.w EA, Dx
	function()
		local opcode = eeObj.GetGpr(gpr.a1)
		local mpu = eeObj.GetGpr(gpr.a0)
		local pc = eeObj.ReadMem32(mpu + mpu68.pc)

		local titleId = getNeoGeoTitleId()
		if		titleId == 0 and		-- AoF
				opcode == 0xb06e and	-- cmp.w   ($xxxx,A6), D0
				pc == 0x126fa then		-- after incrementing spirit
			local player = eeObj.ReadMem32(mpu + mpu68.a6) - 0x200
			local newSpirit = eeObj.ReadMem32(mpu + mpu68.d0)
			local currentSpirit = memoryMappingGetWord(mpu, player + 0x424)
			local maxSpirit = memoryMappingGetWord(mpu, player + 0x456)
			local subStep = memoryMappingGetWord(mpu, 0x108094)

			if chargingUpFromEmpty[player] == nil then
				chargingUpFromEmpty[player] = false
			end

			if		subStep == 2 and			-- during game (not pre-game demo)
					currentSpirit < 0x300 then	-- starting to charge up from empty bar
				chargingUpFromEmpty[player] = true
			end

			if newSpirit >= maxSpirit then	-- maxed up
				if currentSpirit < maxSpirit then	-- incrementing
					if		isHumanAgainstCpuAoF(mpu, player) and		-- human against CPU
							chargingUpFromEmpty[player] == true then	-- charged from 0
						local trophy_id = TROPHY_INNER_FIRE
						trophyObj.Unlock(trophy_id)
					end
				end

				chargingUpFromEmpty[player] = false
			end
		end
	end


local H5 =	-- handle opcode clr.w EA
	function()
		local opcode = eeObj.GetGpr(gpr.a1)
		local mpu = eeObj.GetGpr(gpr.a0)
		local pc = eeObj.ReadMem32(mpu + mpu68.pc)

		local titleId = getNeoGeoTitleId()
		if		titleId == 0 and		-- AoF
				opcode == 0x422d and	-- clr.b   ($xxxx,A5)
				pc == 0xf9fa then		-- won a stage
			local nextStage = memoryMappingGetWord(mpu, 0x108428)

			if nextStage == 3 then		-- defeated Jack
				local trophy_id = TROPHY_WHAT_A_TOUGH_GUY
				trophyObj.Unlock(trophy_id)
			elseif nextStage == 6 then	-- defeated King
				local trophy_id = TROPHY_SORRY_ABOUT_YOUR_SHIRT
				trophyObj.Unlock(trophy_id)
			elseif nextStage == 9 then	-- defeated John
				local trophy_id = TROPHY_TAKE_ME_TO_YOUR_BOSS
				trophyObj.Unlock(trophy_id)
			elseif nextStage == 12 then	-- defeated Mr. Karate (completed game)
				local difficulty = memoryMappingGetByte(mpu, 0x10fd8d)
				local leftId = memoryMappingGetWord(mpu, AOF_P1_DATA_ADDRESS + 0x242)
				local rightId = memoryMappingGetWord(mpu, AOF_P2_DATA_ADDRESS + 0x242)

				checkCompletedTrophy(titleId)

				if neverUsedContinue == true then	-- completed without continues
					local trophy_id = TROPHY_BELIEVE_THE_HYPE
					trophyObj.Unlock(trophy_id)
				end

				if leftId == 0 or rightId == 0 then		-- Ryo
					local trophy_id = TROPHY_INVINCIBLE_DRAGON
					trophyObj.Unlock(trophy_id)

					if difficulty >= 2 then			-- Normal difficulty or higher
						checkCompletedRyoTrophy(titleId)
					end
				elseif leftId == 1 or rightId == 1 then	-- Robert
					local trophy_id = TROPHY_RAGING_TIGER
					trophyObj.Unlock(trophy_id)

					if difficulty >= 2 then			-- Normal difficulty or higher
						checkCompletedRobertTrophy(titleId)
					end
				end

				if difficulty >= 6 then			-- Hard difficulty or higher
					checkCompletedHardTrophy(titleId)
				end
			end
		end
	end


local H6 =	-- handle opcode move.l EA
	function()
		local opcode = eeObj.GetGpr(gpr.a1)
		local mpu = eeObj.GetGpr(gpr.a0)
		local pc = eeObj.ReadMem32(mpu + mpu68.pc)

		local titleId = getNeoGeoTitleId()
		if		titleId == 0 and		-- AoF
				opcode == 0x2b40 and	-- move.l  D0, ($xxxx,A5)
				(pc == 0xeaa0 or pc == 0xdf94) then		-- end of the bottles or ice blocks bonus stage
			local score = eeObj.ReadMem32(mpu + mpu68.d0)

			if score == 10000 then	-- won stage
				if pc == 0xeaa0 then		-- won bottles game
					local trophy_id = TROPHY_BOTTLE_DISSERVICE
					trophyObj.Unlock(trophy_id)
				elseif pc == 0xdf94 then	-- won ice blocks game
					local trophy_id = TROPHY_CRUSHED_ICE
					trophyObj.Unlock(trophy_id)
				end
			end
		elseif	titleId == 1 and		-- AoF 2
				opcode == 0x2b40 and	-- move.l  D0, ($xxxx,A5)
				pc == 0x17c72 then		-- end of the spirit training bonus stage
			local score = eeObj.ReadMem32(mpu + mpu68.d0)

			if score == 10000 then	-- won stage
				local trophy_id = TROPHY_LUMBERJACKED
				trophyObj.Unlock(trophy_id)
			end
		elseif	titleId == 1 and		-- AoF 2
				opcode == 0x2b40 and	-- move.l  D0, ($xxxx,A5)
				pc == 0x18352 then		-- end of the strngth training bonus stage
			local enemiesLeft = memoryMappingGetWord(mpu, 0x1084cc)

			if enemiesLeft == 0 then	-- won stage
				local trophy_id = TROPHY_NONE_LEFT_STANDING
				trophyObj.Unlock(trophy_id)
			end
		elseif	titleId == 0 and		-- AoF
				opcode == 0x2b41 and	-- move.l  D1, ($xxxx,A5)
				pc == 0x7df2 then		-- awarded Perfect bonus
			local stageNum = memoryMappingGetWord(mpu, 0x108428)
			local difficulty = memoryMappingGetByte(mpu, 0x10fd8d)

			if		stageNum > 7 and		-- after Scene 5
					difficulty >= 2 then	-- Normal difficulty or higher
				local trophy_id = TROPHY_GETTING_STRONGER_ALL_THE_TIME
				trophyObj.Unlock(trophy_id)
			end
		end
	end


local H7 =	-- handle opcode or #$xxxx, EA
	function()
		local opcode = eeObj.GetGpr(gpr.a1)
		local mpu = eeObj.GetGpr(gpr.a0)
		local pc = eeObj.ReadMem32(mpu + mpu68.pc)

		local titleId = getNeoGeoTitleId()
		if		titleId == 0 and		-- AoF
				opcode == 0x0000 and	-- ori.b   #$xxxx, D0
				pc == 0xa31c then		-- starting Story Mode
			neverUsedContinue = true
		elseif	titleId == 1 and		-- AoF 2
				opcode == 0x0000 and	-- ori.b   #$xxxx, D0
				pc == 0xbdf2 then		-- starting Story Mode
			neverUsedContinue = true
		end
	end


local H8 =	-- handle opcode addq.w  #$x, ($yyyy,Az)
	function()
		local opcode = eeObj.GetGpr(gpr.a1)
		local mpu = eeObj.GetGpr(gpr.a0)
		local pc = eeObj.ReadMem32(mpu + mpu68.pc)

		local titleId = getNeoGeoTitleId()
		if		titleId == 1 and		-- AoF 2
				opcode == 0x526d and	-- addq.w  #1, ($xxxx,A5)
				pc == 0x197b0 then		-- won a stage
			local wonStage = memoryMappingGetWord(mpu, 0x108428)
			local winner = memoryMappingGetLong(mpu, 0x108408)
			local loser = otherPlayerAoF2(mpu, winner)
			local winnerId = memoryMappingGetWord(mpu, winner + 0x262)
			local loserId = memoryMappingGetWord(mpu, loser + 0x262)
			local winnerRounds = memoryMappingGetWord(mpu, winner + 0x70)
			local loserRounds = memoryMappingGetWord(mpu, loser + 0x70)
			local spirit = memoryMappingGetWord(mpu, winner + 0x424)

			if spirit < 0x2000 then	-- red bar
				local trophy_id = TROPHY_TRANQUIL_FURY
				trophyObj.Unlock(trophy_id)
			end

			if		wonStage == 1 and		-- 1st stage
					winnerId == 11 and		-- Yuri
					loserId == 1 and		-- Ryo
					loserRounds == 0 then	-- no rounds lost
				local trophy_id = TROPHY_THE_BIRTH_OF_A_PHOENIX
				trophyObj.Unlock(trophy_id)
			elseif	loserId == 9 then		-- Mr. Big
				local trophy_id = TROPHY_THE_FIRST_KING_OF_FIGHTERS
				trophyObj.Unlock(trophy_id)
			elseif	loserId == 13 then		-- Geese (completed game)
				local difficulty = memoryMappingGetByte(mpu, 0x10fd8d)

				local trophy_id = TROPHY_PORTRAIT_OF_THE_CRIMELORD_AS_A_YOUNG_MAN
				trophyObj.Unlock(trophy_id)

				checkCompletedTrophy(titleId)

				if winnerId == 1 then		-- Ryo
					if difficulty >= 2 then			-- Normal difficulty or higher
						checkCompletedRyoTrophy(titleId)
					end
				elseif winnerId == 2 then	-- Robert
					if difficulty >= 2 then			-- Normal difficulty or higher
						checkCompletedRobertTrophy(titleId)
					end
				end

				if difficulty >= 6 then			-- Hard difficulty or higher
					checkCompletedHardTrophy(titleId)
				end
			end
		elseif	titleId == 2 and		-- AoF 3
				opcode == 0x526d and	-- addq.w  #1, ($xxxx,A5)
				pc == 0xbc42 then		-- won a stage
			local wonStage = memoryMappingGetWord(mpu, 0x104bea)
			local winnerId = memoryMappingGetWord(mpu, 0x104bf4)
			local loserId = memoryMappingGetWord(mpu, 0x104bf6)

			if		loserId == 8 then	-- Sinclair
				local trophy_id = TROPHY_YOU_BROUGHT_A_SWORD_TO_A_FISTFIGHT
				trophyObj.Unlock(trophy_id)
			elseif loserId == 9 then	-- Wyler
				local trophy_id = TROPHY_UNFORESEEN_SIDE_EFFECTS
				trophyObj.Unlock(trophy_id)

				if winnerId == 8 then	-- Sinclair
					local trophy_id = TROPHY_HIDDEN_AGENDA
					trophyObj.Unlock(trophy_id)
				end
			end

			if wonStage == 8 then		-- completed game
				local difficulty = memoryMappingGetWord(mpu, 0x104bfa)

				checkCompletedTrophy(titleId)

				if neverUsedContinue == true then	-- completed without continues
					local trophy_id = TROPHY_WARRIOR_CONCERTO
					trophyObj.Unlock(trophy_id)
				end

				if winnerId == 1 then		-- Ryo
					if difficulty >= 2 then			-- Normal difficulty or higher
						checkCompletedRyoTrophy(titleId)
					end
				elseif winnerId == 0 then	-- Robert
					if difficulty >= 2 then			-- Normal difficulty or higher
						checkCompletedRobertTrophy(titleId)
					end
				end

				if difficulty >= 7 then			-- Hard difficulty or higher
					checkCompletedHardTrophy(titleId)
				end

				checkAllBitsTrophy(winnerId, 10, SAVEDATA_COMPLETED_AOF3_CHARACTERS, TROPHY_ONCE_UPON_A_TIME_IN_MEXICO)
			end
		end
	end


local H9 =	-- handle opcode move.b
	function()
		local opcode = eeObj.GetGpr(gpr.a1)
		local mpu = eeObj.GetGpr(gpr.a0)
		local pc = eeObj.ReadMem32(mpu + mpu68.pc)

		local titleId = getNeoGeoTitleId()
		if		titleId == 0 and		-- AoF
				opcode == 0x1b7c and	-- move.b  #$xxxx, ($yyyy,A5)
				pc == 0xf544 then		-- Haow-Ken bonus stage successful
			local trophy_id = TROPHY_SECRET_TECHNIQUE
			trophyObj.Unlock(trophy_id)
		elseif	titleId == 1 and		-- AoF 2
				opcode == 0x1b7c and	-- move.b  #$xxxx, ($yyyy,A5)
				pc == 0x18844 then		-- Haow-Ken bonus stage successful
			local trophy_id = TROPHY_ULTIMATE_TECHNIQUE
			trophyObj.Unlock(trophy_id)
		elseif	titleId == 2 and		-- AoF 3
				opcode == 0x1b7c and	-- ori.b   #$xxxx, ($yyyy,A5)
				pc == 0xb858 then		-- Continue screen about to appear
			neverUsedContinue = false
		end
	end


local H10 =	-- handle opcode sub.b Dx, EA
	function()
		local opcode = eeObj.GetGpr(gpr.a1)
		local mpu = eeObj.GetGpr(gpr.a0)
		local pc = eeObj.ReadMem32(mpu + mpu68.pc)

		local titleId = getNeoGeoTitleId()
		if	titleId == 1 and			-- AoF 2
				opcode == 0x9128 and	-- sub.b   D0, ($xxxx,A0)
				pc == 0x1da40 then		-- decrement spirit by taunting
			local player = eeObj.ReadMem32(mpu + mpu68.a6) - 0x200
			local other = eeObj.ReadMem32(mpu + mpu68.a0) - 0x200
			local spiritHi = memoryMappingGetByte(mpu, other + 0x424)
			local difference = eeObj.ReadMem32(mpu + mpu68.d0)

			if		isHumanAgainstCpuAoF2(mpu, player) and	-- human against CPU
					difference >= spiritHi then				-- reduce spirit to 0
				local trophy_id = TROPHY_WORDS_HURT_YOU_KNOW
				trophyObj.Unlock(trophy_id)
			end
		end
	end


local H11 =	-- handle opcode move.l
	function()
		local opcode = eeObj.GetGpr(gpr.a1)
		local mpu = eeObj.GetGpr(gpr.a0)
		local pc = eeObj.ReadMem32(mpu + mpu68.pc)

		local titleId = getNeoGeoTitleId()
		if		titleId == 2 and		-- AoF 3
				opcode == 0x2cbc and	-- move.l  #$xxxxxxxx, (A6)
				pc == 0x15caa then		-- Ultimate KO performed

			local winner = memoryMappingGetLong(mpu, AOF3_P1_DATA_PTR_ADDRESS)
			if memoryMappingGetWord(mpu, winner + 0x68) == 0 then	-- actually loser, so change
				winner = memoryMappingGetLong(mpu, AOF3_P2_DATA_PTR_ADDRESS)
			end

			if isHumanAgainstCpuAoF3(mpu, winner) then	-- won by Ultimate KO
				local trophy_id = TROPHY_WARDROBE_MALFUNCTION
				trophyObj.Unlock(trophy_id)
			end
		end
	end


local H12 =	-- handle opcode move.l
	function()
		local opcode = eeObj.GetGpr(gpr.a1)
		local mpu = eeObj.GetGpr(gpr.a0)
		local pc = eeObj.ReadMem32(mpu + mpu68.pc)

		local titleId = getNeoGeoTitleId()
		if		titleId == 2 and		-- AoF 3
				opcode == 0x2cb0 and	-- move.l  (A0,D0.w), (A6)
				pc == 0x40380 then		-- starting Story Mode (or entering Options menu)
			neverUsedContinue = true
		end
	end


-- register hooks

local elfChk = function(opcode, pc, expectedOpcode)
	local checkValue = eeObj.ReadMem32(0x100010)

	if checkValue == 0x91eed080 then
		assert(opcode == expectedOpcode, string.format("Overlay opcode mismatch @ 0x%06x: expected 0x%08x, found %08x", pc, expectedOpcode, opcode))
		return true
	else
		return false
	end
end

local hooks = {
	eeObj.AddHookJT(0x121de8, function(op, pc) return elfChk(op, pc, 0x1000fff6) end, H1),	-- <_ZN4Menu24menu_exec_color_edit_subEv>:
	eeObj.AddHook(0x1e1660, function(op, pc) return elfChk(op, pc, 0x27bdffc0) end, H2),	-- <_ZN6neogeo10mpu_detail41_GLOBAL__N_.._.._src_mpu_detail.cppJBdeob11MoveOperateItLj0ELj5EE4execERNS_3MpuEj>:
	eeObj.AddHook(0x1e5c00, function(op, pc) return elfChk(op, pc, 0x27bdffd0) end, H4),	-- <_ZN6neogeo10mpu_detail41_GLOBAL__N_.._.._src_mpu_detail.cppJBdeob9EaOperateItLi5EE9cmp_ea_DnERNS_3MpuEj>:
	eeObj.AddHook(0x1d9010, function(op, pc) return elfChk(op, pc, 0x27bdffe0) end, H5),	-- <_ZN6neogeo10mpu_detail41_GLOBAL__N_.._.._src_mpu_detail.cppJBdeob9EaOperateIhLi5EE6clr_eaERNS_3MpuEj>:
	eeObj.AddHook(0x1e04f8, function(op, pc) return elfChk(op, pc, 0x27bdffc0) end, H6),	-- <_ZN6neogeo10mpu_detail41_GLOBAL__N_.._.._src_mpu_detail.cppJBdeob11MoveOperateIjLj5ELj0EE4execERNS_3MpuEj>:
	eeObj.AddHook(0x1d6430, function(op, pc) return elfChk(op, pc, 0x27bdfff0) end, H7),	-- <_ZN6neogeo10mpu_detail41_GLOBAL__N_.._.._src_mpu_detail.cppJBdeob9EaOperateIhLi0EE9or_imm_eaERNS_3MpuEj>:
	eeObj.AddHook(0x1e3a50, function(op, pc) return elfChk(op, pc, 0x27bdfff0) end, H8),	-- <_ZN6neogeo10mpu_detail41_GLOBAL__N_.._.._src_mpu_detail.cppJBdeob9EaOperateItLi5EE11addq_imm_eaERNS_3MpuEj>:
	eeObj.AddHook(0x1de690, function(op, pc) return elfChk(op, pc, 0x27bdffc0) end, H9),	-- <_ZN6neogeo10mpu_detail41_GLOBAL__N_.._.._src_mpu_detail.cppJBdeob11MoveOperateIhLj5ELj7EE4execERNS_3MpuEj>:
	eeObj.AddHook(0x1e5198, function(op, pc) return elfChk(op, pc, 0x27bdfff0) end, H10),	-- <_ZN6neogeo10mpu_detail41_GLOBAL__N_.._.._src_mpu_detail.cppJBdeob9EaOperateIhLi5EE9sub_Dn_eaERNS_3MpuEj>:
	eeObj.AddHook(0x1dfb88, function(op, pc) return elfChk(op, pc, 0x27bdffc0) end, H11),	-- <_ZN6neogeo10mpu_detail41_GLOBAL__N_.._.._src_mpu_detail.cppJBdeob11MoveOperateIjLj2ELj7EE4execERNS_3MpuEj>:
	eeObj.AddHook(0x1dfb08, function(op, pc) return elfChk(op, pc, 0x27bdffc0) end, H12),	-- <_ZN6neogeo10mpu_detail41_GLOBAL__N_.._.._src_mpu_detail.cppJBdeob11MoveOperateIjLj2ELj6EE4execERNS_3MpuEj>:
}
