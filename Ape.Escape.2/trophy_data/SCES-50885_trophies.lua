-- Lua 5.3
-- Title:   Ape Escape 2 - SCEE-50885 (Europe)
-- Version: 1.0.3
-- Date:  Jul.8th, 2015 - CNC - Modified Trophy #12 conditions to ensure correct trigger (and no false trigger)
--        May 8th, 2015 - CNC - Modified Trophy #11 and #13 character detection
--        May 1st, 2015 - CNC - Modified Trophy #12 operation to address bug #8420
--        Apr. 29th, 2015 - CNC - adjusted addresses in trophies #4 and #5
--        Apr. 9th, 2015, 1.0.0 - CNC - initial release
-- Author(s):  Clay Cowgill, clay@embeddedengineeringllc.com for SCEA and Tim Lindquist

-- bugfix 20150430 CNC. Updated mem locs for EU SKU.
-- bugfix 8420 20150501 CNC. Updated hook12 for trophy 12
-- * Changed method for character identification for trophy 11 & 13
--   eliminates two hooks and chance of corner case failure with game save/restore


require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj			= getEEObject()
local emuObj		= getEmuObject()
local trophyObj		= getTrophyObject()

local TROPHY_GOT_ONE=00					
local TROPHY_PERFECT_SCORE=01 
local TROPHY_HAT_TRICK=02     			
local TROPHY_TOP_APE=03       
local TROPHY_ONLY_WAY_IS_UP=04 
local TROPHY_JUNGLE_TUNES=05   			
local TROPHY_LOOK_BOTH_WAYS=06 			
local TROPHY_ENCORE=07        			
local TROPHY_ROBO_JIMMY=08    			
local TROPHY_TAPPED_OUT=09    			
local TROPHY_SUMO_SIZED=10    			
local TROPHY_BACK_FOR_MORE=11  
local TROPHY_END_TO_THE_MADNESS=12 		
local TROPHY_COMPLETELY_BANANAS=13 		

local PLAYER_JIMMY=1
local PLAYER_SPIKE=2
local RUNNING=1
local STOPPED=0

local goriack = STOPPED
local goriack_armed = 0
local goriack_round2 = 0
local player = 0
local SaveData = emuObj.LoadConfig(0)

-- these need to change depending on region
local character  = 0x003e1974 -- SCPS=0x003d8af4, SLUS=0x003e0664, SCES=0x003e1974
local goriack_HP = 0x00D38AD4 -- SCPS=0x00ce8154, SLUS=0x00d38d54, SCES=0x00d38AD4
local jackets = character+4

--print("-- Title:   Ape Escape 2 - SCES-50885 (Europe)")
--print("-- Version: 1.0.3")

if not next(SaveData) then
	SaveData.t  = {}
end

function initsaves()
	local x = 0
		for x = 0, 13 do
			if SaveData.t[x] == nil then
				SaveData.t[x] = 0
				emuObj.SaveConfig(0, SaveData)
			end
		end
	end

-- #00
local HX_TROPHY00 =
	function()
		local trophy_id = TROPHY_GOT_ONE
		initsaves()
		if SaveData.t[trophy_id] ~= 1 then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(0, SaveData)			
--			print("Trophy: Got One! ",TROPHY_GOT_ONE)
		end
	end

-- #01
local HX_TROPHY01 =
	function()
		local x = 0
		local total_score = 0
		local total_score_ptr = eeObj.GetGpr(gpr.s2) + 0x50
		for x = 0,16,4 do
			total_score=total_score+(eeObj.ReadMem32(total_score_ptr+x))
		end
		if (total_score==50) then 
			local trophy_id = TROPHY_PERFECT_SCORE
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)
				-- print("Trophy: Perfect Score ",TROPHY_PERFECT_SCORE)
			end
		end
	end

-- #02
local HX_TROPHY02 =
	function()
		if (eeObj.GetGpr(gpr.v0)==0x00000003) then -- (v0= score to write, v1= base address + offset (0x00cc) for player 1)
			local trophy_id = TROPHY_HAT_TRICK
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
	--			print("Trophy: Hat-Trick ",TROPHY_HAT_TRICK)
			end
		end
	end

-- #03
local HX_TROPHY03 =
	function()
		if (eeObj.GetGpr(gpr.v0)==0x00000000) then -- v0 = medals (0=gold, 1=silver, 2=bronze, -1 = none)
			local trophy_id = TROPHY_TOP_APE
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
	--			print("Trophy: Top Ape ",TROPHY_TOP_APE)
			end
		end
	end

-- #04
local HX_TROPHY04 =
	function()
		if ((eeObj.GetGpr(gpr.v0)==0x00000001) and (eeObj.GetGpr(gpr.a0)==0x003e1c66)) then -- a0 = address of unlock, v0 = flag value (0 = locked, 1=unlocked) -- bugfix 20150430 CNC.
			local trophy_id = TROPHY_ONLY_WAY_IS_UP
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
	--			print("Trophy: Only Way is Up ",TROPHY_ONLY_WAY_IS_UP)
			end
		end
	end

-- #05
local HX_TROPHY05 =
	function()
		if (eeObj.GetGpr(gpr.v1)==0x004D71D0) then -- v1 = address of flag for first track -- bugfix 20150430 CNC.
			local trophy_id = TROPHY_JUNGLE_TUNES
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
	--			print("Trophy: Jungle Tunes ",TROPHY_JUNGLE_TUNES)
			end
		end
	end
	
-- #06 (blue boss)
local HX_TROPHY06 =
	function()
		local trophy_id = TROPHY_LOOK_BOTH_WAYS
		initsaves()
		if SaveData.t[trophy_id] ~= 1 then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(0, SaveData)			
--			print("Trophy: Look Both Ways ",TROPHY_LOOK_BOTH_WAYS)
		end
	end
	
-- #07 (pink boss)
local HX_TROPHY07 =
	function()
		local trophy_id = TROPHY_ENCORE
		initsaves()
		if SaveData.t[trophy_id] ~= 1 then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(0, SaveData)			
--			print("Trophy: Encore ",TROPHY_ENCORE)
		end
	end
	
-- #08 (white boss)
local HX_TROPHY08 =
	function()
		local trophy_id = TROPHY_ROBO_JIMMY
		initsaves()
		if SaveData.t[trophy_id] ~= 1 then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(0, SaveData)			
--			print("Trophy: Robo Jimmy ",TROPHY_ROBO_JIMMY)
		end
	end
	
-- #09 (red boss)
local HX_TROPHY09 =
	function()
		local trophy_id = TROPHY_TAPPED_OUT
		initsaves()
		if SaveData.t[trophy_id] ~= 1 then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(0, SaveData)			
--			print("Trophy: Tapped Out ",TROPHY_TAPPED_OUT)
		end
	end
	
-- #10 (yellow boss)
local HX_TROPHY10 =
	function()
		local trophy_id = TROPHY_SUMO_SIZED
		initsaves()
		if SaveData.t[trophy_id] ~= 1 then
			SaveData.t[trophy_id] = 1
			trophyObj.Unlock(trophy_id)
			emuObj.SaveConfig(0, SaveData)			
--			print("Trophy: Sumo Sized ",TROPHY_SUMO_SIZED)
		end
	end

-- #12a (goriack flag)
local HX_STATE12A =
	function()
		if (goriack==STOPPED) then
			--print("Goriack: ON")
			goriack=RUNNING
		end
	end
	
-- #12b (goriack flag)
local HX_STATE12B =
	function()
		if (goriack==RUNNING) then
			--print("Goriack: OFF")
			goriack=STOPPED
		end
	end
	
-- #12c (return to lobby)
local HX_STATE12C =
	function()
		if (goriack_round2==1) or (goriack_armed==1) then
			--print("Goriack: OFF by exit to lobby")
			--print("Goriack: Round2 OFF")
			--print("Goriack: TRIGGER DISARMED")
			goriack=STOPPED
			goriack_round2=0
			goriack_armed=0
		end
	end

local HX_STATE12D=
	function()
	if ((goriack_round2==1) or (goriack_armed==1)) then
			--print("Goriack: OFF by player death")
			--print("Goriack: Round2 OFF")
			--print("Goriack: TRIGGER DISARMED")
			goriack=STOPPED
			goriack_round2=0
			goriack_armed=0
		end
	end
	
-- #12 (specter boss, first pass)
local HX_TROPHY12 =
	function()
	--print("Goriack=",goriack)
	--print("Goriack_armed=",goriack_armed)
	--print("Goriack_round2=",goriack_round2)

--		if ((eeObj.ReadMem32(goriack_HP)>0x0000003C) and (eeObj.ReadMem32(goriack_HP)<0x00000064))  then
		if ((goriack_armed==1) and (eeObj.GetGpr(gpr.v0)==0x00000000)) then
			--print("Goriack: DEAD")
			goriack=STOPPED
			local trophy_id = TROPHY_END_TO_THE_MADNESS
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
	--			print("Trophy: End to the Madness ",TROPHY_END_TO_THE_MADNESS)
			end
		end
		if ((eeObj.GetGpr(gpr.v0)==0x00000000) and (goriack_round2==0) and (goriack==RUNNING))   then
			goriack_round2=1
			--print("Goriack: PRE-TRIGGER ARMED")
			--print("Goriack: HP=",eeObj.ReadMem32(goriack_HP))
		end
		if ((eeObj.GetGpr(gpr.v0)>0x0000003C) and (goriack_round2==1) and (goriack==RUNNING))   then
			goriack_armed=1
			--print("Goriack: TRIGGER ARMED")
			--print("Goriack: HP=",eeObj.ReadMem32(goriack_HP))
		end
	end
	
-- #13 and #11 (specter boss, second pass)
local HX_TROPHY13 =
	function()
		if ((eeObj.ReadMem32(character)==3) or (eeObj.ReadMem32(character)==4)) then
			player=PLAYER_SPIKE
		else
			player=PLAYER_JIMMY
		end

		if (player==PLAYER_JIMMY) then
			local trophy_id = TROPHY_COMPLETELY_BANANAS
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
	--			print("Trophy: Completely Bananas ",TROPHY_COMPLETELY_BANANAS)
			end
		end

		if (player==PLAYER_SPIKE) then
			local trophy_id = TROPHY_BACK_FOR_MORE
			initsaves()
			if SaveData.t[trophy_id] ~= 1 then
				SaveData.t[trophy_id] = 1
				trophyObj.Unlock(trophy_id)
				emuObj.SaveConfig(0, SaveData)			
	--			print("Trophy: Back for More ",TROPHY_BACK_FOR_MORE)
			end
		end
		
	end
	
hook00 = eeObj.AddHook(0x002A9B54,0xFFB00020, HX_TROPHY00) -- #00
hook01 = eeObj.AddHook(0x00217C74,0x0260202d, HX_TROPHY01) -- #01
hook02 = eeObj.AddHook(0x0031F720,0xACA200CC, HX_TROPHY02) -- #02
hook03 = eeObj.AddHook(0x001B4ED0,0x8E040004, HX_TROPHY03) -- #03
hook04 = eeObj.AddHook(0x003076F4,0xA0820000, HX_TROPHY04) -- #04
hook05 = eeObj.AddHook(0x002D4EF4,0x00231821, HX_TROPHY05) -- #05
hook06 = eeObj.AddHook(0x0014029C,0x3C03003E, HX_TROPHY06) -- #06
hook07 = eeObj.AddHook(0x0014C62C,0x24040001, HX_TROPHY07) -- #07
hook08 = eeObj.AddHook(0x00159108,0x27BDFFE0, HX_TROPHY08) -- #08
hook09 = eeObj.AddHook(0x0015B7CC,0x0000282D, HX_TROPHY09) -- #09
hook10 = eeObj.AddHook(0x00166940,0x27BDFFE0, HX_TROPHY10) -- #10
hook12A = eeObj.AddHook(0x0016B7FC,0x24051750, HX_STATE12A) -- #12 helper function
hook12B = eeObj.AddHook(0x0016C4AC,0xFFB00000, HX_STATE12B) -- #12 helper function
hook12C = eeObj.AddHook(0x0032B040,0x27BDFFF0, HX_STATE12C) -- #12 helper function
hook12D = eeObj.AddHook(0x00269D28,0x27BDFFA0, HX_STATE12D) -- #12 helper function
hook12 = eeObj.AddHook(0x0013900C,0x00451023, HX_TROPHY12) -- #12
hook13 = eeObj.AddHook(0x00176134,0x0000282D, HX_TROPHY13) -- #11, #13 

-- Credits

-- Trophy design and development by SCEA ISD SpecOps
-- David Thach		Senior Director
-- George Weising	Executive Producer
-- Tim Lindquist	Senior Technical PM
-- Clay Cowgill		Engineering
-- Nicola Salmoria	Engineering
-- Jenny Murphy		Producer
-- David Alonzo		Assistant Producer
-- Tyler Chan		Associate Producer
-- Karla Quiros		Manager Business Finance & Ops
-- Special thanks to R&D