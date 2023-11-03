-- Lua 5.3
-- Title:   Rise of the Kasai PS2 - SCUS-97416 (USA)
-- Author:  Ernesto Corvi, Adam McInnis

-- Changelog:

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])
require( "ee-cpr0-alias" ) -- for EE CPR

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()

local L1 =  -- engLoadIndicator::Activate
	function()
		emuObj.ThrottleMax()
	end
	
local L2 =  -- engLoadIndicator::Deactivate
	function()
		emuObj.ThrottleNorm()
	end
	
local load1 = eeObj.AddHook(0x2ddd58, 0x27bdffc0, L1) -- engLoadIndicator::Activate
local load2 = eeObj.AddHook(0x2de458, 0x27bdffe0, L2) -- engLoadIndicator::Deactivate

-- Arena unlock game fix (Bug 9219)
-- Rise of the Kasai exhibits a game bug whereas sometimes it won't unlock an Arena even though all challenges
-- in the appropiate level have been completed. The following function and hook solve the problem, by going through
-- the list of total and completed challenges on every level and updating the global arena unlock mask appropiately.
-- The hook gets called upong entering the Arenas menu, so it should work in every case.

local function getLevelChallengeCount(level) -- LevelChallengeManager::GetGameplayLevelChallengeCount(LevelChallengeManager *__hidden this, int, unsigned int *, unsigned int *)
	local result = nil

	if level >= 0 and level <= 9 then
		--
		-- GetLevelChallengeData(RawLevelChallengeData **, int)
		local rawchallengedata = {0x41e900, 0x41e978, 0x41e9f0, 0x41ea68, 0x41eac8, 0x41eb40, 0x41ebb8, 0x41ec30, 0x41ec78, 0x41ecd8}
		local rawchallengetotals = {5, 5, 5, 4, 5, 5, 5, 3, 4, 4}
		local challengedata = rawchallengedata[level+1]
		local numchallenges = rawchallengetotals[level+1]
		
		local challengestotal = 0
		local challengescompleted = 0
		local challenge = 0
		
		for challenge = 0, numchallenges - 1 do
			local data = challengedata + (challenge * 0x18)
			local flags = eeObj.ReadMem16(data)
			
			if (flags & 0x8300) == 0 then
				local statsTracker = 0x4186c8
			
				--
				-- StatsTracker::IsChallengeComplete
				local offs = (flags >> 3) & 0x1c
				local bits = flags & 0x1f
				local mask = 1 << bits
				local completion = eeObj.ReadMem32(0x104+statsTracker+offs)
				
				if (completion & mask) ~= 0 then
					challengescompleted = challengescompleted + 1
				end
				
				challengestotal = challengestotal + 1
			end
		end
		
		result = {}
		result["completed"] = challengescompleted
		result["total"] = challengestotal
	end
	
	return result
end

eeObj.AddHook(0x149460, 0x27bdfff0, function() -- CircleMenuManager::EnableArenas(CircleMenuManager *__hidden this)
	local level = 0
	
	for level = 0, 9 do
		local data = getLevelChallengeCount(level)
		if data ~= nil then
			local total = data["total"]
			local completed = data["completed"]
--			print(string.format("Level %d: %d/%d", level + 1, completed, total))
			
			if total == completed then
				local unlockedArenas = eeObj.ReadMem32(0x3F5574)
				local mask = 1 << level
				
				if (unlockedArenas & mask) == 0 then
					print(string.format("Fixing arena unlock for level %d", level + 1))
					unlockedArenas = unlockedArenas | mask
					eeObj.WriteMem32(0x3F5574, unlockedArenas)
				end
			end
		end
	end
end)
