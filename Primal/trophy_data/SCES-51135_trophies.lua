-- Lua 5.3

require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])
require( "ee-cpr0-alias" ) -- for EE CPR

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()
local trophyObj	= getTrophyObject()

-- if a print is uncommented, then that trophy trigger is untested.

local userId = 0
local saveData = emuObj.LoadConfig(userId) -- Keep track of running totals

local SAVEDATA_FINISHING_COUNT = "Finishing"

local TROPHY_A_ROCK_OF_MANY_TALENTS		= 0
local TROPHY_ENERGY_BOOST				= 1
local TROPHY_CLINICAL_FINISHER			= 2
local TROPHY_FIERCE_AND_FAIR			= 3
local TROPHY_AQUATICALLY_ADEPT			= 4
local TROPHY_TIME_SHIFTER				= 5
local TROPHY_VOLCANIC_STRENGTH			= 6
local TROPHY_NIGHT_LIGHT				= 7
local TROPHY_COLISEUM_SHOWDOWN			= 8
local TROPHY_REALM_OF_THE_FERAI			= 9
local TROPHY_REALM_OF_THE_UNDINE		= 10
local TROPHY_REALM_OF_THE_WRAITH		= 11
local TROPHY_REALM_OF_DJINN				= 12
local TROPHY_BANISHING_THE_DEMONS		= 13
local TROPHY_TAROT_CARD_COMPLETIONIST	= 14

local currCutscene = ""	-- title of the last cutscene played
local prevCutscene = ""	-- title of the PREVIOUS cutscene played
local prevPrevCutscene = ""	-- title of the cutscene played before the previous one

local H1 = -- trigger cutscene
	function()
		local a0 = eeObj.GetGPR(gpr.a0)
		
		-- keep track of current and previous cutscenes
		prevPrevCutscene = prevCutscene
		prevCutscene = currCutscene
		currCutscene = eeObj.ReadMemStr(a0)

		--	print( string.format("trigger cutscene %s", currCutscene) )
		
		if currCutscene == "pe1malkaicavesolved.cut" then	-- Light the urn in the Malkai cave
			local trophy_id = TROPHY_NIGHT_LIGHT
			--	print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif currCutscene == "pe2belahzurexit.cut" then	-- Defeat Belahzur in The Coliseum
			local trophy_id = TROPHY_COLISEUM_SHOWDOWN
			--	print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif currCutscene == "pe3epilogue.cut" and
				prevCutscene == "pe3devenakilled.cut" and
				prevPrevCutscene == "pe3jaredfinddevena2.cut" then		-- Escape Devena's Tomb
			local trophy_id = TROPHY_REALM_OF_THE_FERAI
			--	print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif currCutscene == "cp2adarodefeated.cut" then	-- Defeat Adaro in the Purification Tower
			local trophy_id = TROPHY_REALM_OF_THE_UNDINE
			--	print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif currCutscene == "sw3countdefeated.cut" then	-- Defeat Raum and Empusa in the Ballroom
			local trophy_id = TROPHY_REALM_OF_THE_WRAITH
			--	print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif currCutscene == "vo4_iblisdefeated.cut" then	-- Defeat Goliath in the Goliath Sanctum
			local trophy_id = TROPHY_REALM_OF_DJINN
			--	print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif currCutscene == "nx_finalfightend.cut" and
				prevCutscene == "nx_belahzurdefeated.cut" then	-- Defeat Lewis in the final battle
			local trophy_id = TROPHY_BANISHING_THE_DEMONS
			--	print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end

local H2 = -- change form during cutscene
	function()
		local aspect = eeObj.GetGPR(gpr.a2)
		if aspect == 1 and currCutscene == "pe2hernetemple.cut" then			-- Receive Ferai aspect
			local trophy_id = TROPHY_FIERCE_AND_FAIR
			--	print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif aspect == 2 and currCutscene == "cp1jengetundineform.cut" then	-- Receive Undine aspect
			local trophy_id = TROPHY_AQUATICALLY_ADEPT
			--	print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif aspect == 3 and currCutscene == "sw1watchertakenpart2.cut" then	-- Receive Wraith aspect
			local trophy_id = TROPHY_TIME_SHIFTER
			--	print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		elseif aspect == 4 and currCutscene == "vo2_iblisawakes.cut" then		-- Receive Djinn aspect
			local trophy_id = TROPHY_VOLCANIC_STRENGTH
			--	print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end

local H3 = -- update possessed statue id
	function()
		local statue = eeObj.GetGpr64(gpr.s1)
		--	print( string.format("possess statue %x", statue) )
		if statue ~= 0 then		-- Possess a statue with Scree
			local trophy_id = TROPHY_A_ROCK_OF_MANY_TALENTS
			--	print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end

local H4 = -- update gem count
	function()
		local oldGems = eeObj.GetGPR(gpr.v1)
		local newGems = eeObj.GetGPR(gpr.v0)
		if newGems < oldGems then	-- Use an energy gem to replenish Jen's demon energy
			local trophy_id = TROPHY_ENERGY_BOOST
			--	print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end

local H5 = -- complete finishing move
	function()
		if saveData[SAVEDATA_FINISHING_COUNT] == nil then
			saveData[SAVEDATA_FINISHING_COUNT] = 0
		end

		saveData[SAVEDATA_FINISHING_COUNT] = saveData[SAVEDATA_FINISHING_COUNT] + 1
		emuObj.SaveConfig(userId, saveData)

		if saveData[SAVEDATA_FINISHING_COUNT] >= 50 then	-- Kill 50 enemies with a finishing move
			local trophy_id = TROPHY_CLINICAL_FINISHER
			--	print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end

local H6 = -- add card to tarot gallery
	function()
		local cards = eeObj.GetGPR(gpr.v0)
		if cards == 0x0fffffff then		-- Complete the Tarot Gallery
			local trophy_id = TROPHY_TAROT_CARD_COMPLETIONIST
			print( string.format("trophy_id=%x", trophy_id) )
			trophyObj.Unlock(trophy_id)
		end
	end


-- register hooks
local hook1 = eeObj.AddHook(0x28df78, 0x27bdffc0, H1) -- <CCSDirector::TriggerCutscene(char const *)>
local hook2 = eeObj.AddHook(0x1d3b18, 0xae460354, H2) -- CSwapCorporeal::ProcessModelMessage(CModelMessage &)
local hook3 = eeObj.AddHook(0x1bfb1c, 0xfe510498, H3) -- CFSMActionScreeSetPossessedStatue::ActionHandle(CFSMStoreInterface &)
local hook4 = eeObj.AddHook(0x17beec, 0x8e230904, H4) -- CJen::Update(void)
local hook5 = eeObj.AddHook(0x243820, 0x27bdffb0, H5) -- <CFSMActionApplyPostFinishingMoveRotation::ActionHandle(CFSMStoreInterface &)>
local hook6 = eeObj.AddHook(0x1288ec, 0x7bbf0040, H6) -- CTarotGallery::AddCard(unsigned int)
