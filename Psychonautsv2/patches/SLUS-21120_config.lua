-- psychonauts_slus21120
local gpr    = require("ee-gpr-alias")
local emuObj = getEmuObject()	

apiRequest(1.0)	-- request version 0.1 API. Calling apiRequest() is mandatory.

-- Bug#9174 - 
emuObj.SetGsTitleFix( "ignoreSubBuffCov", "reserved", { } )

-- Bug#9240 (Light maps uprender)
-- Copy z-buffer for future use with light maps. psm = SCE_GS_PSMZ24 (49)
emuObj.SetGsTitleFix( "forceSimpleFetch", "reserved", {tw=9, th=9, psm=49, zmsk=1 } )

-- Apply light maps texMode=2 (bilinear)   psm= SCE_GS_PSMCT32 (0)
emuObj.SetGsTitleFix( "forceSimpleFetch", "reserved", {tw=8, th=8, psm=0, ztst=1, texMode=2 } )

-- Bug#9176
--
-- This bug seems GPUGS interpolation problem.
-- The game draws clouds as undiscovered area on the map, but
-- Z value is unstable --- sometimes 0x320, sometimes 0x321.
-- On drawing 'Highlight' object (which is missing one), it uses z=0x320 with
-- ZTST=GEQUAL. Therefore if the cloud renders with z=0x321, this highlighted object
-- doesn't appear. But it's OK on the real PS2 because of no-drawing right edge,
-- z=0x321 won't be available on the packet (interpolation differences between
-- the real PS2 and our gs)
-- it gives some values (50.0f) to get +1 on Z value for the highlighted object.
-- this value will be used later to create the packet in _sprite_ps2_push_data(ESprite*).
--
-- This old one causes a problem on some other scenes.
-- local eeObj = getEEObject()
-- eeObj.AddHook(0x1b276c,	0xe4400024, function() 
-- 				 local v0 = eeObj.GetGpr(gpr.v0)
-- 				 local z  = eeObj.ReadMemFloat(v0+32)
-- 				 eeObj.WriteMemFloat(v0+32, z+50.0)
-- end)
-- New one by Ernesto :
-- The idea is to apply the offset only on the marker.
local eeObj = getEEObject()
local adjustMapZHook = function() -- EMapRenderWindow::drawHighlightSprites
    eeObj.SetFpr(14, eeObj.GetFpr(14) + 50.0)
end
eeObj.AddHook(0x25d654, 0x8de40068, adjustMapZHook) -- \/
eeObj.AddHook(0x25d714, 0xe7b500cc, adjustMapZHook) -- /\
eeObj.AddHook(0x25d7d0, 0xe7b500cc, adjustMapZHook) -- <
eeObj.AddHook(0x25d894, 0x46000386, adjustMapZHook) -- >


-- bug#9423 - menus render 20+ times over again, causing very low fps.
-- The whole game in general has no concept of pacing and will re-draw frames multiple times
-- between vsync refreshes.  Hook placed on GameApp::EndFrame() measures time between frames and
-- if it's too short, the EE clock is advanced significantly to compensate.

local last_time = 0
local last_diff = 0
local advanceClockForAny = function()
	local thistime = eeObj.GetClock()
	local diff = thistime - last_time
	local adv  = 0

	if diff <= 0 then
		-- sanity check, mostly for snapshot restore.
		last_diff = diff
		last_time = thistime
		return
	end
	
	-- EE @ 30fps == roughly 10 million cycles
	-- bug#9555 - We need to make a reasonable tally of VIF cycles across game display swaps.
	--   Use a combination heuristic of EE and VIF1 cycles to gues at whether the title should
	--   lock to 45fps, 30fps, or something worse.
	
	local fastminEE		= 1600000		-- less than this it's safe to run > 30 fps
	local fastminVIF_30	= 2450000		-- VU1 total that merits 30hz throttle
	local fastminVIF_45	= 1750000		-- VU1 total that merits 45hz throttle.
	local baremin_wo_vif= 5800000		-- EE values below this get promoted to this value  (~50hz)
	local forced30hz	= 9550000
	local forced45hz	= 7900000
	
	local vif1_cycles = eeObj.GetVif1Cycles()
	if (vif1_cycles > forced30hz) then
		vif1_cycles = forced30hz
	end

	local diff_vif = diff + vif1_cycles
	adv = adv + vif1_cycles

	-- Lock anything that seems like "Real Work" to either 30 or 45 FPS:
	
	if diff_vif < fastminEE then
		adv = adv + (fastminEE*2 - diff_vif)
	elseif vif1_cycles > fastminVIF_30 and (diff+(fastminVIF_30)//2) < forced30hz then
		adv = adv + (forced30hz  		- diff - (fastminVIF_30)//2)
	elseif vif1_cycles > fastminVIF_45 and (diff+(fastminVIF_45)//2) < forced45hz then
		adv = adv + (forced45hz  		- diff - (fastminVIF_45)//2)
	elseif diff < baremin_wo_vif then
		adv = adv + (baremin_wo_vif  	- diff)
	end

	-- print (string.format("DELTA: %d  ADV: %d  VIF1: %d", diff, adv, vif1_cycles))

	if adv ~= 0 then
		eeObj.AdvanceClock(adv)
	end

	-- Ensure next frame's delta time takes into consideration this frame's advancement.
	-- Otherwise each fraem delta time would get progressively worse.

	thistime = thistime + adv
	last_time = thistime
	last_diff = diff
end

local advanceClockForGame = function() advanceClockForAny() end
eeObj.AddHookJT(0x207cf8, 0x27bdfff0, advanceClockForGame) 	  -- <GameApp::EndFrame()>:
