local gpr = require("ee-gpr-alias")
apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local emuObj  		= getEmuObject()
local eeObj         = getEEObject()

-- require("debughooks")
-- local iopObj = getIOPObject()
-- iopObj.AddHook(0x000135ac, 0x27bdffe0, DebugHooks.h_IOP_ioman_write)

-- bug#8123
-- Skip resetting VAG stream which happens on an error.
iopInsnReplace(0x00090028, 0x16220009, 0x08024014)	-- bne $s1,$v0,0x00090050 => j 0x00090050

-- bug#9405 - advance EE clock according to spinning-loop SIF activity.
 
local skip_syncDCache = function()
	-- Original value when actually processing syncDCache was 3300
	-- Boosting to 8000 helps reduce bottleneck
	eeObj.AdvanceClock(8000)
end

eeInsnReplace(0x1ca9e0, 0x27bdffe0, 0x03e00008)
eeInsnReplace(0x1ca9e4, 0x0080302d, 0x00000000)
eeObj.AddHookJT(0x1ca9e0, 0x03e00008, skip_syncDCache)

-- gametime to be from realtim....
-- # this causes the time elapses even while in pause. so bugged
-- # also maybe this causes 'negative' race time as well.
-- we should be OK even without this because skipping frame works (mostly).
-- 
-- local prevtime = 0.0
-- eeObj.AddHook(0x12350c,	0x27bdfec0, function()
-- 				 local curtime = os.clock()
-- 				 if prevtime ~= 0.0 then
-- 					eeObj.WriteMemFloat(eeObj.GetGpr(gpr.gp)-31776, curtime - prevtime)
-- 				 end
-- 				 prevtime = curtime
-- end)

-- to work skipping frame mechanism correctly...
-- the game checks a flag set by INTC GS whether GS still does his job or not to
-- determine whether it should skip a frame or not.
-- Unfortunately we don't have the actual timing of GS FINISH signal.
-- Instead of that, we check EE clock to determine to skip or not.

local ee_frequency = 294912000
local vsync_frequency = 59.94	-- use interlace freq. 

local one_vsync_clock_on_ntsc = math.floor(ee_frequency / vsync_frequency)


-- Kinetica has some inconsistency among frames -- some frames take unusually long, possibly due
-- to AI updates.  In these cases, it is necessary to skip multiple frames to catch the game's
-- clock back up to realtime.  To do so, we track 'expected_clock' over time, so that especially
-- slow frames are compensated for over time.

local prev_clock = 0
local expected_clock = 0

eeObj.AddHook(0x181f7c,	0x8f82bf54, function()
				-- It hits here when it skips a frame.
				--local diff = eeObj.GetClock() - prev_clock
				
				local clock = eeObj.GetClock()
				--local diff  = clock - expected_clock
				--print(string.format("SKIP FRAME: diff=%7d", diff))

				--prev_clock     = eeObj.GetClock()		-- just update the clock.
				expected_clock = expected_clock + one_vsync_clock_on_ntsc
end)
eeObj.AddHook(0x18202c, 0x8f84bf54, function()
				local clock = eeObj.GetClock()
				--local diff = clock - prev_clock
				--print(string.format("diff=%d vsync_term=%f %s", diff, one_vsync_clock_on_ntsc, diff > one_vsync_clock_on_ntsc and "SKIP" or ""))
				
				local diff = clock - expected_clock
				
				-- Sanity correction -- to handle cases where expected_clock contents is
				-- zero or out-dated.
				if (math.abs(diff) > (one_vsync_clock_on_ntsc * 6)) then
					expected_clock = clock
				end
				 
				-- print(string.format("diff=%7d %s", diff, diff > 17000 and "SKIP" or ""))
                
				if diff > 17000 then
					eeObj.SetGpr(gpr.a0, 1)
				end
                
				-- update clock
				--prev_clock     = clock
				expected_clock = expected_clock + one_vsync_clock_on_ntsc
end)


-- Applies a cycle rate hack to what I presume is the game logic pipeline, for roughly per-frame updates.

local mpgCycles_default	= 900
local currentMpgCycles = mpgCycles_default

local checkNeedsSpeedHack = function()
	local stageId    = eeObj.ReadMem32(0x01fce8c)
	local numPlayers = eeObj.ReadMem32(0x01ffd78)		-- 0x01ffd7c seems to always match this one...

	-- print(string.format("stageId = %d, numPlayers = %d", stageId, numPlayers))
	
	-- 3 = Electrica
	-- 7 = Electrica II
	-- 8 = Cliffhanger
	
	local newMpgCycles = mpgCycles_default
	if (stageId == 3 or stageId == 7 or stageId == 8) then

		-- note: this will also apply to demo loops (0 players)
		newMpgCycles = newMpgCycles + 120
		
		if stageId == 7 then
			-- Electrica 2 is extra-special slow in some areas.
			-- (and 2-player mode on this map runs enough mpgs that extra penalty isn't needed)
			if numPlayers == 2 then
				newMpgCycles = newMpgCycles - 100
			else
				newMpgCycles = newMpgCycles + 275
			end
		elseif numPlayers == 2 then
			-- increment is not so big here because two player mode already runs many more VU programs.
			newMpgCycles = newMpgCycles + 100
		end

	end

	if currentMpgCycles ~= newMpgCycles then
		-- print ( string.format("################### Setting mpg-cycles = %d", newMpgCycles) )
		eeObj.Vu1MpgCycles(newMpgCycles)
		currentMpgCycles = newMpgCycles
	end
end

eeObj.AddHookJT(0x15ca2c,0x27bdff20,checkNeedsSpeedHack)

