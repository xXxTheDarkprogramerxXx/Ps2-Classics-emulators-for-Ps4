-- Lua 5.3
-- Title:   Hot Shots Tennis - SCUS-97610 (US) 1.0.0
-- Version: 1.0.0
-- Date:    June. 18th, 2015
-- Revision:   Aug 4, 2016		Bug 9861 fixed (script now detects Demo play vs. actual play)
-- Revision:   Aug 23, 2016		Bug 9896 fixed (no trophies awarded during Demo play or All-computer play in Fun Time mode)
--									Also.. script now supports Fun Time Tennis mode (trophies 2, 3 and 8 may be awarded in this mode,
--									       Human player no longer assumed to be player 0.)
--									Also.. Speed threshold for Trophy 3 fixed. Speed is internally stored as km/h even in US version.								
-- Author(s):  Warren Davis, warren_davis@playstation.sony.com for SCEA and Tim Lindquist

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj			= getEEObject()
local emuObj		= getEmuObject()
local trophyObj		= getTrophyObject()

local TROPHY_BEGINNERS_LUCK=00					
local TROPHY_ON_A_ROLL=01
local TROPHY_RIGHT_BACK_AT_YOU=02					
local TROPHY_COMIN_IN_HOT=03
local TROPHY_STRAIGHT_A_STUDENT=04					
local TROPHY_HIGH_CHAIR_HEROES=05					
local TROPHY_WORLD_TOUR=06					
local TROPHY_GATHER_AROUND=07					
local TROPHY_PERSISTENCE_PAYS_OFF=08					
local TROPHY_SERVING_UP_BAGELS=09					
local TROPHY_CONSISTENT_WINNER=10
local TROPHY_PRACTICE_PRO=11
local TROPHY_CHALLENGE_CHAMPION=12

--   Main Menu indices
local mode = 5					-- initialize gameplay mode to an out-of-range value (0-4 is valid)
local CHALLENGE_MODE = 0		-- this script only checks to see if the mode is CHALLENGE_MODE
--local TENNIS_EVERYONE = 1
--local DATA_MODE = 2
--local OPTIONS_MODE = 3
--local TRAINING_MODE = 4


--[[  Training Mode indices
local GENERAL = 0
local SMASH = 1
local VOLLEY = 2
local SERVICE = 3
--]]

local WORLD_CLASS = 5
local SEMIPRO_CLASS = 2

local SPEED_THRESH = 160.9334    -- km/h (equiv to 100 mph)
										

local in_actual_play = false
local playerIndx = 0			-- will always be 0 in Challenge Mode. In Fun Time Mode will be
								-- 				0 or 1 for singles, 0, 1, 2 or 3 for doubles.
local playerTeam = 0			-- will always be 0 in Challenge Mode.  0 or 1 in Fun Time Mode.
					
--local pGameCount = 0x422fa0
local pComputerControlled = 0x422fc8	-- start of 4 words which indicate which players are computer controlled
local pNumPlayers = 0x422fa4			-- either 2 (for singles) or 4 (for doubles)
local pWhoServed = 0x42304c				-- 0 or 1 depending on which team served
local pWhosHitting = 0x423058			-- player number of last player to hit the ball.
local pVolleyCount = 0x423060
--local pPlayerScore = 0x423064
--local pOpponentScore = 0x423068
local pOpponentWins = 0x423070
local pPlayerWins = 0x42307c
local pWhoWon = 0x4230a8				-- will be 0 or 1 depending on which team won.
local pGameIsOver = 0x4230b8

local pUnlockedPlayers = 0x2ef13a  -- start of 14 byte table (1= unlocked,0=not unlocked)
local pUnlockedUmps = 0x2ef156     -- start of 5 byte table
local pUnlockedCourts = 0x2ef15b   -- start of 11 byte table
local pWonMatchesTable = 0x2ef1b2  -- start of 66 byte table (3 = match won)
local pNumServiceWins = 0x2ef2dc
local pNumServiceGames = 0x2ef2e0
local pMatchCount = 0x2ef310
local pMatchClass = 0x2ef826

local pTrainingScoreTbl = 0x2ef262  -- start of Training score table, entries every 20 bytes
local pTrainingATbl = 0x418c94 	-- start of table showing score needed for A level, entries every 0x48 bytes
local pTrainingMode = 0x3167a8  -- 0 = General, 1 = Smash, 2 = Volley, 3 = Service
local pTrainingLevel = 0x3167bc
local pNewTrainingScore = 0x3167cc  -- score from the training match just played
local pHighTrainingScore = 0x3167d0

--helpers for Trophy 02
local serviceBreakCount = 0

--helpers for Trophy 03
local serveSpeed = 0.0
local lookingForSpeed = false

	
local SaveData = emuObj.LoadConfig(0)

--local vsync_timer=0

local hook_t2 = nil	-- helper hook for trophy 02
local hook_t3 = nil	-- helper hook for trophy 03

local hook_00_01_09_12 = nil
local hook_03 = nil
local hook_04 = nil
local hook_05_06_07 = nil
local hook_08 = nil
local hook_02_10 = nil
local hook_11a = nil
local hook_11b = nil
local hook_11c = nil
local hook_chk = nil
local hook_setmode = 0

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



function START_GAME()
	--print "_NOTE: Entering START_GAME"
	in_actual_play = false
	local numPlyrs = eeObj.ReadMem16(pNumPlayers)
	local lpCompContr = pComputerControlled
	local humans = 0
	for n = 1, numPlyrs do
		local cc = eeObj.ReadMem16(lpCompContr)
		if (cc == 0) then
			humans = humans + 1
			playerIndx = (n-1)			-- can be 0 or 1 or 2 or 3
		end
		lpCompContr = lpCompContr + 4
	end
	
	playerTeam = playerIndx & 1
	--print (string.format("_NOTE: Checking human count...  %d", humans))
	if (humans == 1) then			-- award trophies only if there is 1 and only 1 human player
		in_actual_play = true
		--print (string.format("_NOTE: Player %d is on team %d", playerIndx, playerTeam))
	end
end



function SET_MODE()
	mode = eeObj.GetGPR(gpr.s2)
	--print (string.format("MODE_NOTE: We are entering mode %d", mode))
end


--[[  CheckServiceBreak()

       This function checks at the end of a game to see if it was a service break.
       
	   It's called from two places - one, a hook that triggers at the end of every volley
	   (except the last volley of a match) and two, from a hook that triggers at the end
	   of a match that's been won by the player.
	   
	   If an opponent served and the player's team won, the service break count
	   is incremented.
	   
	   Parameter:  winner = 0 means the player won,  1 means the opponent won
--]]   
function CheckServiceBreak(winner)
	local whoServed =  eeObj.ReadMem32(pWhoServed) & 1		-- convert from player to team
	--print (string.format("CHECK_SERVICE_BREAK_NOTE: whoServed = %d, winner = %d", whoServed, winner))
	if (whoServed ~= playerTeam and winner == playerTeam) then --if opp served and player won, this is a service break
		serviceBreakCount = serviceBreakCount + 1
		--print (string.format("SERVICE_BREAK_NOTE: %d", serviceBreakCount))
	end
end


--[[	TROPHY_BEGINNERS_LUCK 00
		TROPHY_ON_A_ROLL 01
		TROPHY_SERVING_UP_BAGELS 09
		TROPHY_CHALLENGE_CHAMPION 12
		
		Hook occurs after player wins a match - ONLY IN CHALLENGE MODE
		
		00) Awarded for completing a match
		01 and 09) If the game was won in straight sets, check the class and award
		    one of these trophies if appropriate
		12) See if every possible match has been won. This is stored in a table
		    There are 64 consecutive bytes which should contain a "3".
--]]
local PLAYER_WON_MATCH_00_01_09_12 =
function()
	if (in_actual_play == true) then
		--print "_NOTE: Entering Player_Won_Match"

		if (mode == CHALLENGE_MODE) then	
			-- Check for trophy	00
			local trophy_id = TROPHY_BEGINNERS_LUCK
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
	            --print ("TROPHY_NOTE 00 Beginners Luck  AWARDED!")
			end	
			
			-- Check for trophies 01 and 09		
			local plyrGamesWon = eeObj.ReadMem32(pPlayerWins)
			local oppGamesWon = eeObj.ReadMem32(pOpponentWins)
			--print (string.format("_NOTE: Player won %d games, Opponent won %d", plyrGamesWon,  oppGamesWon))
			if (plyrGamesWon > 0 and oppGamesWon == 0) then
				local matchClass = eeObj.ReadMem8(pMatchClass)
				--print (string.format("_NOTE: Player won match in straight sets (Class = %d)", matchClass))
				if (matchClass == SEMIPRO_CLASS) then
					trophy_id = TROPHY_ON_A_ROLL
					if SaveData.t[trophy_id] ~= 1 then
						SaveData.t[trophy_id] = 1
						trophyObj.Unlock(trophy_id)
						emuObj.SaveConfig(0, SaveData)			
		        		--print "TROPHY_NOTE 01 On A Roll AWARDED!"
		        	end
				end	
				if (matchClass == WORLD_CLASS) then
					trophy_id = TROPHY_SERVING_UP_BAGELS
					if SaveData.t[trophy_id] ~= 1 then
						SaveData.t[trophy_id] = 1
						trophyObj.Unlock(trophy_id)
						emuObj.SaveConfig(0, SaveData)			
		        		--print "TROPHY_NOTE 09 Serving Up Bagels AWARDED!"
		        	end
				end	
			end	
			
			-- Check for trophy 12
			trophy_id = TROPHY_CHALLENGE_CHAMPION
			local awardIt = false
			local lastTwo = eeObj.ReadMem16(pWonMatchesTable+64)  -- read last 2 bytes of table
			--print (string.format("_NOTE: Last two matches =  %x", lastTwo))
			if lastTwo == 0x0303 then
				awardIt = true
			    for count = 0, 60, 4 do
					local fourBytes = eeObj.ReadMem32(pWonMatchesTable+count)
					--print (string.format("_NOTE: Count: %d,  %x", count, fourBytes))
					if fourBytes ~= 0x03030303 then
						awardIt = false
						break
					end
				end
			end
			if awardIt and SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
	            --print ("TROPHY_NOTE 12 Challenge Chamption  AWARDED!")
			end	
		end
	end
end




--[[  END_OF_GAME - helper function for Trophy 02.
	  This hook occurs at the end of every volley (except the last volley of a match)
	  It does NOT trigger twice from instant replays.
	  It checks to see if this volley ended the game, and if so it checks to see if the
	  game was a service break.
--]]
local END_OF_GAME = 
function()
	if (in_actual_play == true) then
		local isGameOver =  eeObj.ReadMem32(pGameIsOver)
		--print (string.format("_NOTE: isGameOver = %d", isGameOver))
		if (isGameOver > 0) then -- game is over
			local whoWon = eeObj.ReadMem32(pWhoWon)
			CheckServiceBreak(whoWon)
		end
	end
end

	
	
	
-- helper function for Trophy 03 - hook occurs when the speed of a ball is computed
-- if prior conditions have occurred (namely the opponent is serving) then 
-- save the speed of the serve to be examined later.
local GET_SPEED =
	function()
		if (lookingForSpeed) then
	    	serveSpeed = eeObj.GetFpr(20)
			--print (string.format("SPEED_NOTE, serve speed = %f", serveSpeed))
	    end
	end
	
	
	
	
--[[   	TROPHY_COMIN_IN_HOT 03
		Hook occurs when any ball is successfully hit.
		First, detect if it's a serve and if the opponent is serving.
		If so, look for the speed of the serve when it is computed.
		Next, detect if the player is returning the serve.
		If so, check the speed and award trophy if appropriate.
--]]
local BALLHIT_03 =
function()
	if (in_actual_play == true) then	
		local trophy_id = TROPHY_COMIN_IN_HOT
		if SaveData.t[trophy_id] ~= 1 then	
		    local volleyCount = eeObj.ReadMem32(pVolleyCount)
		    if (volleyCount == 1) then
				local whoServed =  eeObj.ReadMem32(pWhoServed) & 1	-- which team is Serving		    
				if (whoServed ~= playerTeam) then
		    		-- this is the opponent serving
			    	lookingForSpeed = true
		    		--print "SPEED_NOTE: look for speed"
				end
		   	end
		    if (volleyCount == 2) then
			    local whosHitting = eeObj.ReadMem32(pWhosHitting)
		    	if (whosHitting == playerIndx) then
			        -- this is the player returning a serve
		   		  	--print (string.format("SPEED_NOTE, Player returned a serve of %f km/h", serveSpeed))
			        if (serveSpeed > SPEED_THRESH) then
						SaveData.t[trophy_id] = 1
						trophyObj.Unlock(trophy_id)
						emuObj.SaveConfig(0, SaveData)			
		            	--print ("TROPHY_NOTE 03 Comin' In Hot  AWARDED!")
			        end
		   		end
		     	lookingForSpeed = false
		     	serveSpeed = 0.0	    
		    end
		end
	end
end



--[[	TROPHY_STRAIGHT_A_STUDENT 04
		Hook occurs after a training session has ended, but before the new score is
		checked against the hi score.  (That code gets executed every frame while waiting
		for the player to press the X button).
		First, check the new score to see if it's higher than the current hi score.
		If it isn't, we're done. 
		The score for each Training Mode is checked against the score required for an A grade.
		If all 4 training modes have high enough scores, the trophy is awarded
--]]
local END_OF_TRAINING_04 = 
	function()
		local trophy_id = TROPHY_STRAIGHT_A_STUDENT
		if SaveData.t[trophy_id] ~= 1 then
   			local newScore = eeObj.ReadMem16(pNewTrainingScore)
			local hiScore = eeObj.ReadMem16(pHighTrainingScore)
    		--print (string.format("END OF TRAINING_NOTE. new score = %d. hi score = %d", newScore, hiScore))
			if (hiScore <= newScore) then
				local lpTrainingScore = pTrainingScoreTbl
				local lpTrainingA = pTrainingATbl
		    	mode = eeObj.ReadMem16(pTrainingMode)
			    --print (string.format("_NOTE: Training Mode = %d", mode))
			    local num_A = 0
			    for count = 0, 3, 1 do
			        print (string.format("_NOTE %d checking %x and %x",count, lpTrainingScore, lpTrainingA))
				    local score = 0
				    if count == mode then
				        score = newScore
				    else
				     	score = eeObj.ReadMem16(lpTrainingScore)
				    end
					local Ascore = eeObj.ReadMem32(lpTrainingA)
			        --print (string.format("_NOTE score = %d, thresh = %d",score, Ascore))
					if score >= Ascore then
					    num_A = num_A + 1
					end
					lpTrainingScore = lpTrainingScore + 20
					lpTrainingA = lpTrainingA + 0x48
				end
				if num_A == 4 then
					SaveData.t[trophy_id] = 1
					trophyObj.Unlock(trophy_id)
					emuObj.SaveConfig(0, SaveData)					
					--print ("TROPHY_NOTE 04 Straight A Student AWARDED!")
				end
			end	
		end
	end




-- This function checks to see if all of a particular item has been unlocked.
-- Possible items are Players, Umpires and Courts.

	function CheckUnlock(trophy_id, pUnlockTbl, itemCnt)
		if SaveData.t[trophy_id] ~= 1 then
		    local award = true
		    for i = 1, itemCnt, 1 do 
		    	if  (eeObj.ReadMem8(pUnlockTbl) == 0) then 
		    		award = false
		    		break 
		    	end
		    	pUnlockTbl = pUnlockTbl + 1		-- check next byte in table
		    end    	
		    --print (string.format("UNLOCK_NOTE trophy %d, %d items, %s", trophy_id, itemCnt, award and "true" or "false"))
		    if award then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)					
				--print (string.format("TROPHY_NOTE %d (%d items) AWARDED!", trophy_id, itemCnt))		    
		    end	    
		end
	end



--[[	TROPHY_HIGH_CHAIR_HEROES  	05					
		TROPHY_WORLD_TOUR			06					
		TROPHY_GATHER_AROUND		07
		Hook occurs whenever something is unlocked at the end of a match.
		For each trophy, check the appropriate table of unlocked items. If all items are
		unlocked, award the trophy.
--]]
local UNLOCK_05_06_07 =
	function()
		--print "CHECKING_NOTE UNLOCK"
		CheckUnlock(TROPHY_HIGH_CHAIR_HEROES, pUnlockedUmps, 5)
		CheckUnlock(TROPHY_WORLD_TOUR, pUnlockedCourts, 11)
		CheckUnlock(TROPHY_GATHER_AROUND, pUnlockedPlayers, 14)
	end



--[[	TROPHY_PERSISTENCE_PAYS_OFF 08
		Hook occurs at end of a volley after a point has been awarded.
		See who won the point.  If it's the player, see how long the volley was
		and award trophy if appropriate.
--]]
local POINT_WON_08 = 
function() 
	if (in_actual_play == true) then
		--print "_NOTE: Entering POINT_WON_08"
		local trophy_id = TROPHY_PERSISTENCE_PAYS_OFF
		if SaveData.t[trophy_id] ~= 1 then
		    -- the winner of the point is stored in s0 + 0x15c.  (0 = player won, 1 = opponent won)
			local pWhoWonPoint = eeObj.GetGpr(gpr.s0) + 0x15c
			local whoWonPoint = eeObj.ReadMem32(pWhoWonPoint)
			--print (string.format("_NOTE: who won Point = %d",  whoWonPoint))
			local isPlayerWinner = whoWonPoint==playerTeam
			local volleyCount = eeObj.ReadMem32(pVolleyCount)
		    --print (string.format("POINT SCORED_NOTE: Point to %s, Volley cnt = %d", isPlayerWinner and "Player" or "Opponent", volleyCount))
			if (isPlayerWinner) then
				if (volleyCount >= 10) then
					SaveData.t[trophy_id] = 1
					trophyObj.Unlock(trophy_id)
					emuObj.SaveConfig(0, SaveData)			
					--print ("TROPHY_NOTE 08 Persistence Pays Off AWARDED!")
				end
			end
		end
	end
end

	
--[[	TROPHY_CONSISTENT_WINNER 10
		TROPHY_RIGHT_BACK_AT_YOU 02

		Hook occurs at the end of a match after the service game count has been updated.

		If a Challenge Mode match, it checks if over 100 matches have been played
		and over half the service games have been won by the player. (Trophy 10)

		For any match, it checks to see if the match was won with at least 2 service breaks. (Trophy 2)
--]]
local TROPHY_02_10 = 
function()
	if (in_actual_play == true) then
	
		--
		-- Check for trophy 2 (Can be Fun Time or Challenge Mode)
		--
		trophy_id = TROPHY_RIGHT_BACK_AT_YOU
		if SaveData.t[trophy_id] ~= 1 then
			CheckServiceBreak(playerTeam) -- need to check if the match winning game was a service break
			 							  -- we know the player won, so pass a 0 parameter
			if (serviceBreakCount >= 2) then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
        	    --print (string.format("TROPHY_NOTE 02 Right Back At You  AWARDED! (%d svc brks)", serviceBreakCount))
			end	
		end
	
		--
		-- If this was a Challenge Mode match, check for trophy 10
		--
		if (mode == CHALLENGE_MODE) then	
			local matchCount = eeObj.ReadMem32(pMatchCount)
			--print (string.format("_NOTE: Trophy 10 check, match count = %d", matchCount))
			if (matchCount > 100) then
				local trophy_id = TROPHY_CONSISTENT_WINNER
				if SaveData.t[trophy_id] ~= 1 then	
					local serviceGames = eeObj.ReadMem32(pNumServiceGames)
					local serviceWins = eeObj.ReadMem32(pNumServiceWins)
					if (serviceWins * 2) > serviceGames then
						SaveData.t[trophy_id] = 1
						trophyObj.Unlock(trophy_id)
						emuObj.SaveConfig(0, SaveData)			
		            	--print ("TROPHY_NOTE 10 Consistent Winner  AWARDED!")
		            end
				end
			end	
		end
		
		serviceBreakCount = 0;	-- reset for next match			
	end
end	

--[[   	CheckTrainingLevel()
		Helper function for Trophy 11
		Check the training level and if >= max for current mode, award the trophy
--]]
	function CheckTrainingLevel(maxLevel)
		local trophy_id = TROPHY_PRACTICE_PRO
		if SaveData.t[trophy_id] ~= 1 then	
			local levelAchieved = eeObj.ReadMem32(pTrainingLevel)+1   
			--print (string.format("TRAINING_LEVEL_NOTE: training level = %d, awarded at %d", levelAchieved,maxLevel))
			if (levelAchieved >= maxLevel)then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
				--print ("TROPHY_NOTE 11 Practice Pro AWARDED!")
			end
		end
	end

--[[	TROPHY_PRACTICE_PRO 11
		Hook occurs when the training level is updated.
		For GENERAL, SMASH, and VOLLEY training, the level is updated in different
		places, so there are separate hooks.
		SERVICE training does not appear to increase the level ever.
--]]
local TROPHY_11_Gen = 
	function()
		CheckTrainingLevel(9)
	end

local TROPHY_11_Vol = 
	function()
		CheckTrainingLevel(6)
	end

local TROPHY_11_Sm = 
	function()
		CheckTrainingLevel(6)
	end
    

--[[  This function is triggered when overlay code is loaded.  There seem to be two overlays...
	  one for code running during gameplay (meaning Training, Challenge and Tennis For Everyone)
	  and one for the main menu and any selection screens leading up to gameplay.
--]]	  
local DYN_LOAD = 
	function()
		local load = eeObj.GetGpr(gpr.v0)
		--print (string.format("LOAD_NOTE: %x", load))
		if (load == 0x100280) then	-- ok to add hooks
			initsaves()
			
			-- reset any helper variables
			serviceBreakCount = 0
			lookingForSpeed = false
			serveSpeed = 0.0
			endOfMatch = false
			
	    	--print ("LOAD_NOTE loading hooks") 
	    	
	    	if (hook_00_01_09_12 == nil) then
				hook_00_01_09_12 = eeObj.AddHook(0x3ac4b4, 0x3c04002f, PLAYER_WON_MATCH_00_01_09_12) -- #00, 01, 09, 12
			end
	    	if (hook_03 == nil) then
				hook_03 = eeObj.AddHook(0x33eae0, 0x2404ffff, BALLHIT_03) -- #03
			end
		    if (hook_04 == nil) then
				hook_04 = eeObj.AddHook(0x3da260, 0x00431021, END_OF_TRAINING_04) -- #04
			end
			if (hook_05_06_07 == nil) then
				hook_05_06_07 = eeObj.AddHook(0x3ac538,  0x26940001, UNLOCK_05_06_07) -- #05, 06, 07
			end
			if (hook_08 == nil) then
				hook_08 = eeObj.AddHook(0x38be00, 0x9042d6c8, POINT_WON_08) -- #08
			end
			if (hook_02_10 == nil) then
				hook_02_10 = eeObj.AddHook(0x3acbcc, 0x3c02002f, TROPHY_02_10) -- #02, 10
			end
		    if (hook_11a == nil) then
				hook_11a = eeObj.AddHook(0x3f0e84, 0x906367c0, TROPHY_11_Gen) -- #11
			end
		    if (hook_11b == nil) then
				hook_11b = eeObj.AddHook(0x3eecf0, 0x2403001e, TROPHY_11_Vol) -- #11
			end
		    if (hook_11c == nil) then
				hook_11c = eeObj.AddHook(0x3f02b4, 0xae440E68, TROPHY_11_Sm) -- #11
			end
			if (hook_t2 == nil) then
				hook_t2 = eeObj.AddHook(0x3265ac, 0x24060001, END_OF_GAME) -- helper for #02
			end
			if (hook_t3 == nil) then
				hook_t3 = eeObj.AddHook(0x33f2d4, 0x3c043f80, GET_SPEED) -- helper for #03
			end
			if (hook_chk == nil) then
				hook_chk = eeObj.AddHook(0x327aa4, 0x0200102d, START_GAME) -- helper 
			end
	    	if (hook_setmode ~= 0) then
	    		eeObj.RemoveHook(hook_setmode)
	    		hook_setmode = 0
	    	end
		else	-- if 0x72780 or anything else, remove the hooks
			--print ("LOAD_NOTE removing hooks") 

	    	if (hook_00_01_09_12 ~= nil) then
	    		eeObj.RemoveHook(hook_00_01_09_12)
	    		hook_00_01_09_12 = nil
	    	end
	    	if (hook_03 ~= nil) then
	    		eeObj.RemoveHook(hook_03)
	    		hook_03 = nil
	    	end
	    	if (hook_04 ~= nil) then
	    		eeObj.RemoveHook(hook_04)
	    		hook_04 = nil
	    	end
	    	if (hook_05_06_07 ~= nil) then
	    		eeObj.RemoveHook(hook_05_06_07)
	    		hook_05_06_07 = nil
	    	end
	    	if (hook_08 ~= nil) then
	    		eeObj.RemoveHook(hook_08)
	    		hook_08 = nil
	    	end
	    	if (hook_02_10 ~= nil) then
	    		eeObj.RemoveHook(hook_02_10)
	    		hook_02_10 = nil
	    	end
	    	if (hook_11a ~= nil) then
	    		eeObj.RemoveHook(hook_11a)
	    		hook_11a = nil
	    	end
	    	if (hook_11b ~= nil) then
	    		eeObj.RemoveHook(hook_11b)
	    		hook_11b = nil
	    	end	    	
	    	if (hook_11c ~= nil) then
	    		eeObj.RemoveHook(hook_11c)
	    		hook_11c = nil
	    	end
	    	if (hook_t2 ~= nil) then
	    		eeObj.RemoveHook(hook_t2)
	    		hook_t2 = nil
	    	end
	    	if (hook_t3 ~= nil) then
	    		eeObj.RemoveHook(hook_t3)
	    		hook_t3 = nil
	    	end
	    	if (hook_chk ~= nil) then
	    		eeObj.RemoveHook(hook_chk)
	    		hook_chk = nil
	    	end
			if (hook_setmode == 0) then
				hook_setmode = eeObj.AddHook(0x3512c0, 0x024050009, SET_MODE) -- helper, set gameplay mode
			end
	   	end
	end

local hook_loader = eeObj.AddHook(0x100380, 0x40882d, DYN_LOAD) -- see which hooks to set


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