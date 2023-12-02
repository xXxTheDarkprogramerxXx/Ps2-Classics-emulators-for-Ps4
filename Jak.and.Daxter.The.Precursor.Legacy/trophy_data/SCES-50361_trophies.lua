-- Lua 5.3
-- Titles: Jak and Daxter: The Precursor Legacy
-- Trophies version: 2.02
-- Author: David Haywood
-- Date: Feb/March 2017
-- 
-- SCES-50361 (Europe)
-- SCUS-97124 (US)
-- SCPS-15021 (Japan)
-- SCPS-56003 (Korea)

--]]

--[[

Trohies v2.01

added Korea support

Trophies v2.02

updated API

--]]


--[[

Jak 1 Trophies

Platinum                               0                                 Top of the Heap                          You have mastered the game and collected all there is to collect!
Bronze                                 1                                 Open Sez Me                              Open the Precursor Door
Bronze                                 2                                 Yee Haw!                                 Herd the Yakows in to their Pen
Silver                                 3                                 Black Thumb                              Defeat the Dark Eco Plant
SIlver                                 4                                 Shiny Happy Steeples                     Connect the Eco Beams
Bronze                                 5                                 Hand Over Fish                           Catch 200 Pounds of Fish using the touchscreen
Bronze                                 6                                 Gimmee That!                             Get the Power Cell from the Pelican
Bronze                                 7                                 Eggs Over Hard                           Push the Flut Flut Egg Off the Cliff
Bronze                                 8                                 Pop Goes the Lurker                      Destroy the Balloon Lurkers
Bronze                                 9                                 Tonight's Featured Event                 Defeat Lurker Ambush in Arena
Bronze                                 10                                Zoom!                                    Reach the End of Fire Canyon
Silver                                 11                                Catch as Catch Can                       Catch the Flying Lurkers
Silver                                 12                                Green Thumb                              Cure Dark Eco Infected Plants
Bronze                                 13                                Purple Pain                              Navigate the Purple Precursor Rings
Bronze                                 14                                I Got The Blues                          Navigate the Blue Precursor Rings
SIlver                                 15                                Speedy Fast                              Beat the Record Time on the Gorge
Bronze                                 16                                Twist and Shout                          Defeat the Lurker Ambush
Bronze                                 17                                Hungry?                                  Protect Farthy's Snacks using the touchscreen
SIlver                                 18                                The Lead Zeppelin                        Break all Four Tethers to the Zeppelin
Bronze                                 19                                Zoom Zoom!                               Reach the End of the Mountain Pass
Silver                                 20                                De-Klawwed                               Defeat Klaww
Silver                                 21                                Kerblamm!                                Destroy the Dark Eco Crystals
Bronze                                 22                                It's Dark in Here                        Survive the Lurker Infested Cave
Silver                                 23                                It's Cold Out Here                       Stop the 3 Lurker Glacier Troops
Bronze                                 24                                Zoom, Zoom, Zoom!                        Reach the End of the Lava Tube
Bronze                                 25                                Set Me Free!                             Free the Red Sage
Bronze                                 26                                No, Set Me Free!                         Free the Blue Sage
Bronze                                 27                                Hey, Set Me Free!                        Free the Yellow Sage
Bronze                                 28                                Set Me Free Already!                     Free the Green Sage
Gold                                   29                                Battle Hardened                          The Final Battle Against Gol and Maia
Bronze                                 30                                Power Lunch                              Collect 25 Power Cells
SIlver                                 31                                Power Chords                             Collect 50 Power Cells
Gold                                   32                                Maximum Power!                           Collect 101 Power Cells
Bronze                                 33                                Buzzin'                                  Collect 28 Scout Flies
Silver                                 34                                Buzzed                                   Collect 49 Scout Flies
Gold                                   35                                Totally Buzzed Out!                      Collect 112 Scout Flies
Bronze                                 36                                The Orbist                               Collect 100 Precursor Orbs
SIlver                                 37                                The Orberator                            Collect 1000 Precursor Orbs
Gold                                   38                                The Super Orberator                      Collect 2000 Precursor Orbs

--]]



require( "ee-gpr-alias" ) -- you can access EE GPR by alias (gpr.a0 / gpr["a0"])

apiRequest(2.1)
-- 0.8 to enable:
-- Emu::ForceRefreshRate(int)
-- 2.1 to enable:
-- eeObject::getOverlayObject()

-- obtain necessary objects.
local eeObj			= getEEObject()
local emuObj		= getEmuObject()
local trophyObj		= getTrophyObject()
local dmaObj		= getDmaObject()
local eeOverlay 	= eeObj.getOverlayObject()

-- load configuration if exist
local SaveData		= emuObj.LoadConfig(0)

local allow_awards = 1

--[[###################################################################################################################
#######################################################################################################################

  Generic Award Function

###################################################################################################################--]]


function AwardTrophy(savetext, trophy_id)
	local awardbits = 0xff
	
	if allow_awards == 1 then

		local temp = SaveData[savetext]
		local oldtemp = temp
		
		if temp ~= 0xff then	
		
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
			
		end

	else	
		local temp = SaveData[savetext]
		local oldtemp = temp
		
		if temp ~= 0xff then	
			--print( string.format("############################## NOT AWARDING trophy_id=%d (%s) (BLOCKED BY CHEAT?) #########################", trophy_id, savetext) )
		end
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
	-- Geyser Rock
	InitSave("training-door",       1 ) -- OpenSezMe              -- 7020:	2403005d 	li	v1,93
	-- Sandover Village
	InitSave("village1-yakow",      2 ) -- YeeHaw                 -- 7060:	2403000a 	li	v1,10
	-- The Forbidden Jungle
	InitSave("jungle-plant",        3 ) -- BlackThumb             -- 70a0:	24030006 	li	v1,6
	InitSave("jungle-lurkerm",      4 ) -- ShinyHappySteeples     -- 70e0:	24030003 	li	v1,3
	InitSave("jungle-fishgame",     5 ) -- HookLineStinker        -- 7120:	24030005 	li	v1,5
	-- Sentinel Beach
	InitSave("beach-pelican",       6 ) -- GimmeeThat             -- 7160:	24030010 	li	v1,16
	InitSave("beach-flutflut",      7 ) -- EggsOverHard           -- 71a0:	24030011 	li	v1,17
	-- Misty Island
	InitSave("misty-bike",          8 ) -- PopGoestheLurker       -- 71e0:	2403001b 	li	v1,27
	InitSave("misty-warehouse",     9 ) -- TonightsFeaturedEvent  -- 7220:	24030019 	li	v1,25
	-- Fire Canyon
	InitSave("firecanyon-end",      10) -- Zoom                   -- 7260:	24030045 	li	v1,69
	-- Rock Village
	-- The Precursor Basin
	InitSave("rolling-robbers",     11) -- CatchAsCatchCan        -- 72a0:	24030035 	li	v1,53
	InitSave("rolling-plants",      12) -- GreenThumb             -- 72e0:	24030037 	li	v1,55
	InitSave("rolling-ring-chase-1",13) -- PurplePain             -- 7320:	2403003a 	li	v1,58
	InitSave("rolling-ring-chase-2",14) -- IGotTheBlues           -- 7360:	2403003b 	li	v1,59
	InitSave("rolling-race",        15) -- SpeedyFast             -- 73a0:	24030034 	li	v1,52
	-- Boggy Swamp
	InitSave("swamp-battle",        16) -- TwistAndShout          -- 73e0:	24030026 	li	v1,38
	InitSave("swamp-billy",         17) -- Hungry                 -- 7420:	24030024 	li	v1,36
	InitSave("swamp-arm",           18) -- TheLeadZeppelin        -- 7460:	24030068 	li	v1,104
	-- Lost Precursor City
	-- Mountain Pass
	InitSave("ogre-end",            19) -- ZoomZoom               -- 74a0:	24030057 	li	v1,87
	InitSave("ogre-boss",           20) -- De-Klawwed             -- 74e0:	24030056 	li	v1,86
	-- Volcanic Crater
	-- Spider Cave
	InitSave("cave-dark-crystals",  21) -- Kerblamm               -- 7520:	2403004f 	li	v1,79
	-- Snowy Mountain
	InitSave("snow-bunnies",        22) -- ItsDarkInHere          -- 7560:	24030040 	li	v1,64
	InitSave("snow-ram",            23) -- ItsColdOutHere         -- 75a0:	2403003d 	li	v1,61
	-- Lava Tube
	InitSave("lavatube-end",        24) -- ZoomZoomZoom           -- 75e0:	24030059 	li	v1,89
	-- Gol and Maia's Citadel
	InitSave("citadel-sage-red",    25) -- SetMeFree              -- 7620:	24030048 	li	v1,72
	InitSave("citadel-sage-blue",   26) -- NoSetMeFree            -- 7660:	24030047 	li	v1,71
	InitSave("citadel-sage-yellow", 27) -- HeySetMeFree           -- 76a0:	24030049 	li	v1,73
	InitSave("citadel-sage-green",  28) -- SetMeFreeAlready!      -- 76e0:	24030046 	li	v1,70
	-- Endgame -- (also task-status need-reminder-a)
	InitSave("finalboss-movies",    29) -- Battle Hardened 

	InitSave("POWERCELL_25",        30) -- Power Lunch
	InitSave("POWERCELL_50",        31) -- Power Chords
	InitSave("POWERCELL_101",       32) -- Maximum Power!
	
	InitSave("SCOUTFLIES_28",       33) -- Buzzin'
	InitSave("SCOUTFLIES_49",       34) -- Buzzed
	InitSave("SCOUTFLIES_112",      35) -- Totally Buzzed Out!
	
	InitSave("PRECURSORORBS_100",   36) -- The Orbist
	InitSave("PRECURSORORBS_1000",  37) -- The Orberator
	InitSave("PRECURSORORBS_2000",  38) -- The Super Orberator	
end




InitSaves()


--[[###################################################################################################################
#######################################################################################################################

  Main Support

###################################################################################################################--]]

--[[



struct link_control
{
	// parameters for link_and_exec, but
	// may be modified by subsequent processing
	void*			data;
	char			filename[64];
	int				length;
	kheapinfo*		heap;
	uint32			warn;

	// internal parameters
	jumper			func;
	void*			heapcur;
	int32			methodinc;
	link_blockptr	linkblock;     ******* SEE BELOW ********
	int				datalen;

	// new parameters for state-wise execution
	int				state;
	int				stateparm;
	uint8*			old;		// old pos when in memcpy
	int				delta;		// saved delta for memcpy
	uint8*			p;			// rellink/symlink ptr
	uint32			totalbase;	// rellink parms
	uint32*			base;
	bool			mode;
	link_segment*	seg;
	void*			data_start;	// area to flush cache over

	void	begin(void* data, char* filename, int length, kheapinfo* heap, uint32 warn);
	bool	work();
	bool	work_v2();
	bool	work_v3();
	void	finish();
};




typedef struct {
	uint8 *link;
	uint8 *data;
	uint32 size;
	uint32 flags;
} link_segment;

typedef struct link_block_v3
{
    int32 allocated_length;
    int32 version;
	uint32 segment_count;
	char name[64];
    link_segment segment[3];
    char link_stream[1];
} link_block_v3;

typedef struct link_block_v4
{
	int32	basic[GTYPE_BASIC_OFFSET / 4];		// the basic offset crap
    int32	llen;		// link len
    int32	version;	// version = 4
	int32	dlen;		// data len
} link_block_v4;

--]]



local cstageFunc = function()
	print( string.format("======================= EXECUTING CSTAGE =========================" ) )

end

local cstageFunc2 = function()


	local gp = eeObj.GetGpr(gpr.gp)
	
	local taskID = eeObj.ReadMem32(gp+0x00)
	local taskState = eeObj.ReadMem32(gp+0x08)
	
	print( string.format(" (not being skipped either - Task ID %08x Task State %08x)", taskID, taskState ) )
	
	-- 7 is task complete? most trophies trigger on this
	if (taskState == 7) then
	
		if taskID == 93 then AwardTrophy("training-door",       1 ) end -- OpenSezMe              -- 7020:	2403005d 	li	v1,93
		-- Sandover Village
		if taskID == 10 then AwardTrophy("village1-yakow",      2 ) end -- YeeHaw                 -- 7060:	2403000a 	li	v1,10
		-- The Forbidden Jungle
		if taskID == 6  then AwardTrophy("jungle-plant",        3 ) end -- BlackThumb             -- 70a0:	24030006 	li	v1,6
		if taskID == 3  then AwardTrophy("jungle-lurkerm",      4 ) end -- ShinyHappySteeples     -- 70e0:	24030003 	li	v1,3
		if taskID == 5  then AwardTrophy("jungle-fishgame",     5 ) end -- HookLineStinker        -- 7120:	24030005 	li	v1,5
		-- Sentinel Beach
		if taskID == 16 then AwardTrophy("beach-pelican",       6 ) end -- GimmeeThat             -- 7160:	24030010 	li	v1,16
		if taskID == 17 then AwardTrophy("beach-flutflut",      7 ) end -- EggsOverHard           -- 71a0:	24030011 	li	v1,17
		-- Misty Island
		if taskID == 27 then AwardTrophy("misty-bike",          8 ) end -- PopGoestheLurker       -- 71e0:	2403001b 	li	v1,27
		if taskID == 25 then AwardTrophy("misty-warehouse",     9 ) end -- TonightsFeaturedEvent  -- 7220:	24030019 	li	v1,25
		-- Fire Canyon
		if taskID == 69 then AwardTrophy("firecanyon-end",      10) end -- Zoom                   -- 7260:	24030045 	li	v1,69
		-- Rock Village
		-- The Precursor Basin
		if taskID == 53 then AwardTrophy("rolling-robbers",     11) end -- CatchAsCatchCan        -- 72a0:	24030035 	li	v1,53
		if taskID == 55 then AwardTrophy("rolling-plants",      12) end -- GreenThumb             -- 72e0:	24030037 	li	v1,55
		if taskID == 58 then AwardTrophy("rolling-ring-chase-1",13) end -- PurplePain             -- 7320:	2403003a 	li	v1,58
		if taskID == 59 then AwardTrophy("rolling-ring-chase-2",14) end -- IGotTheBlues           -- 7360:	2403003b 	li	v1,59
		if taskID == 52 then AwardTrophy("rolling-race",        15) end -- SpeedyFast             -- 73a0:	24030034 	li	v1,52
		-- Boggy Swamp
		if taskID == 38 then AwardTrophy("swamp-battle",        16) end -- TwistAndShout          -- 73e0:	24030026 	li	v1,38
		if taskID == 36 then AwardTrophy("swamp-billy",         17) end -- Hungry                 -- 7420:	24030024 	li	v1,36
		if taskID == 104 then AwardTrophy("swamp-arm",          18) end -- TheLeadZeppelin        -- 7460:	24030068 	li	v1,104
		-- Lost Precursor City
		-- Mountain Pass
		if taskID == 87 then AwardTrophy("ogre-end",            19) end -- ZoomZoom               -- 74a0:	24030057 	li	v1,87
		if taskID == 86 then AwardTrophy("ogre-boss",           20) end -- De-Klawwed             -- 74e0:	24030056 	li	v1,86
		-- Volcanic Crater
		-- Spider Cave
		if taskID == 79 then AwardTrophy("cave-dark-crystals",  21) end -- Kerblamm               -- 7520:	2403004f 	li	v1,79
		-- Snowy Mountain
		if taskID == 64 then AwardTrophy("snow-bunnies",        22) end -- ItsDarkInHere          -- 7560:	24030040 	li	v1,64
		if taskID == 61 then AwardTrophy("snow-ram",            23) end -- ItsColdOutHere         -- 75a0:	2403003d 	li	v1,61
		-- Lava Tube
		if taskID == 89 then AwardTrophy("lavatube-end",        24) end -- ZoomZoomZoom           -- 75e0:	24030059 	li	v1,89
		-- Gol and Maia's Citadel
		if taskID == 72 then AwardTrophy("citadel-sage-red",    25) end -- SetMeFree              -- 7620:	24030048 	li	v1,72
		if taskID == 71 then AwardTrophy("citadel-sage-blue",   26) end -- NoSetMeFree            -- 7660:	24030047 	li	v1,71
		if taskID == 73 then AwardTrophy("citadel-sage-yellow", 27) end -- HeySetMeFree           -- 76a0:	24030049 	li	v1,73
		if taskID == 70 then AwardTrophy("citadel-sage-green",  28) end -- SetMeFreeAlready!      -- 76e0:	24030046 	li	v1,70	
	
	end
	
	if taskID == 0x70 then
		if taskState >= 0x00000004 then
			AwardTrophy("finalboss-movies",  29) 
		end
	end	
	
end


--[[
local gameinfoFunc1 = function()
	local newTotal = eeObj.GetFpr(0)
	print( string.format("********************** gameinfoFunc1 %f", newTotal ) )
end
--]]
local gameinfoFunc2 = function()
	-- THE ORBS

	local oldTotal = eeObj.GetFpr(0)
	local Increment = eeObj.GetFpr(1)
	local newTotal = oldTotal + Increment
	
	print( string.format("********************** Precursor Orbs was %f incby %f is %f", oldTotal, Increment, newTotal ) )
	

--	Bronze                                 36                                The Orbist                               Collect 100 Precursor Orbs
--	SIlver                                 37                                The Orberator                            Collect 1000 Precursor Orbs
--	Gold                                   38                                The Super Orberator                      Collect 2000 Precursor Orbs	

    if oldTotal < 100 and newTotal >= 100 then
		AwardTrophy("PRECURSORORBS_100",    36) 
	end
	
	if oldTotal < 1000 and newTotal >= 1000 then
		AwardTrophy("PRECURSORORBS_1000",    37) 	
	end
	
	if oldTotal < 2000 and newTotal >= 2000 then
		AwardTrophy("PRECURSORORBS_2000",   38) 	
	end
	
end

--[[
local gameinfoFunc3 = function()
	local newTotal = eeObj.GetFpr(0)
	print( string.format("********************** gameinfoFunc3 %f", newTotal ) )
end
--]]

local gameinfoFunc4 = function()
	-- THE POWER CELLS

	local oldTotal = eeObj.GetFpr(0)
	local Increment = eeObj.GetFpr(1)
	local newTotal = oldTotal + Increment
	
	print( string.format("********************** Power Cells was %f incby %f is %f", oldTotal, Increment, newTotal ) )
	
--	Bronze                                 30                                Power Lunch                              Collect 25 Power Cells
--	SIlver                                 31                                Power Chords                             Collect 50 Power Cells
--	Gold                                   32                                Maximum Power!                           Collect 101 Power Cells

    if oldTotal < 25 and newTotal >= 25 then
		AwardTrophy("POWERCELL_25",    30) 
	end
	
	if oldTotal < 50 and newTotal >= 50 then
		AwardTrophy("POWERCELL_50",    31) 	
	end
	
	if oldTotal < 101 and newTotal >= 101 then
		AwardTrophy("POWERCELL_101",   32) 	
	end
end

local gameinfoFunc5 = function()
	-- THE FLIES

	local oldTotal = eeObj.GetFpr(0)
	local Increment = eeObj.GetFpr(1)
	local newTotal = oldTotal + Increment
	
	print( string.format("********************** Scout Flies was %f incby %f is %f", oldTotal, Increment, newTotal ) )
	
--	Bronze                                 33                                Buzzin'                                  Collect 28 Scout Flies
--	Silver                                 34                                Buzzed                                   Collect 49 Scout Flies
--	Gold                                   35                                Totally Buzzed Out!                      Collect 112 Scout Flies		

    if oldTotal < 28 and newTotal >= 28 then
		AwardTrophy("SCOUTFLIES_28",    33) 
	end
	
	if oldTotal < 49 and newTotal >= 49 then
		AwardTrophy("SCOUTFLIES_49",    34) 	
	end
	
	if oldTotal < 112 and newTotal >= 112 then
		AwardTrophy("SCOUTFLIES_112",   35) 	
	end
	
end

--[[
local gameinfoFunc6 = function()
	local newTotal = eeObj.GetFpr(30)
	print( string.format("********************** gameinfoFunc6 %f", newTotal ) )
end
--]]

--[[ 

this is
(defmethod adjust ((obj game-info) (item symbol) (amount float) &key (source handle INVALID_HANDLE))
  "Adjust a particular fact."

00787D9C   67BDFFA0 daddiu      sp,sp,-0x60
00787DA0   FFBF0000 sd          ra,0x0000(sp)
00787DA4   FFBE0008 sd          fp,0x0008(sp)
00787DA8   0320F025 dmove       fp,t9
00787DAC   7FB30010 sq          s3,0x0010(sp)
00787DB0   7FB40020 sq          s4,0x0020(sp)
00787DB4   7FB50030 sq          s5,0x0030(sp)
00787DB8   7FBC0040 sq          gp,0x0040(sp)
00787DBC   E7BE0050 swc1        f30,0x0050(sp)
00787DC0   0080E025 dmove       gp,a0
00787DC4   00C0A825 dmove       s5,a2
00787DC8   00E0A025 dmove       s4,a3
00787DCC   00A01825 dmove       v1,a1
00787DD0   66E4CCD0 daddiu      a0,s7,-0x3330
00787DD4   14640023 bne         v1,a0,0x00787E64
00787DD8   02E02025 dmove       a0,s7
00787DDC   44950000 mtc1        s5,f0
00787DE0   44800800 mtc1        zero,f1
00787DE4   46010034 c.olt.s     f0,f1
00787DE8   4501000E bc1t        0x00787E24
00787DEC   00000000 nop
00787DF0   8EF9D4A0 lw          t9,0xD4A0(s7)
00787DF4   C7800008 lwc1        f0,0x0008(gp)
00787DF8   44040000 mfc1        a0,f0
00787DFC   C780000C lwc1        f0,0x000C(gp)
00787E00   44050000 mfc1        a1,f0
00787E04   02A03025 dmove       a2,s5
00787E08   0320F809 jalr        ra,t9
00787E0C   001F1000 sll         v0,ra,0
00787E10   44820000 mtc1        v0,f0
00787E14   E7800008 swc1        f0,0x0008(gp)
00787E18   44030000 mfc1        v1,f0
00787E1C   1000000D b           0x00787E54
00787E20   00000000 nop
00787E24   8EF9D4A0 lw          t9,0xD4A0(s7)
00787E28   C7800008 lwc1        f0,0x0008(gp)
00787E2C   44040000 mfc1        a0,f0
00787E30   8FC5109C lw          a1,0x109C(fp)
00787E34   44950000 mtc1        s5,f0
00787E38   46000007 neg.s       f0,f0
00787E3C   44060000 mfc1        a2,f0
00787E40   0320F809 jalr        ra,t9
00787E44   001F1000 sll         v0,ra,0
00787E48   44820000 mtc1        v0,f0
00787E4C   E7800008 swc1        f0,0x0008(gp)
00787E50   44030000 mfc1        v1,f0
00787E54   C7800008 lwc1        f0,0x0008(gp)
00787E58   44020000 mfc1        v0,f0
00787E5C   100000FF b           0x0078825C
00787E60   00000000 nop
00787E64   66E4D610 daddiu      a0,s7,-0x29F0
00787E68   14640067 bne         v1,a0,0x00788008
00787E6C   02E02025 dmove       a0,s7
00787E70   44800000 mtc1        zero,f0
00787E74   44950800 mtc1        s5,f1
00787E78   46010034 c.olt.s     f0,f1
00787E7C   45010002 bc1t        0x00787E88
00787E80   66E30008 daddiu      v1,s7,0x8
00787E84   02E01825 dmove       v1,s7
00787E88   52E3000A beql        s7,v1,0x00787EB4
00787E8C   00601825 dmove       v1,v1
00787E90   C7800010 lwc1        f0,0x0010(gp)
00787E94   44950800 mtc1        s5,f1
00787E98   46010000 add.s       f0,f0,f1                  --- XXX1
00787E9C   8EE38BC8 lw          v1,0x8BC8(s7)
00787EA0   C461000C lwc1        f1,0x000C(v1)
00787EA4   46010032 c.eq.s      f0,f1
00787EA8   45010002 bc1t        0x00787EB4
00787EAC   66E30008 daddiu      v1,s7,0x8
00787EB0   02E01825 dmove       v1,s7
00787EB4   12E3000A beq         s7,v1,0x00787EE0
00787EB8   02E01825 dmove       v1,s7
00787EBC   8EF9FFB0 lw          t9,0xFFB0(s7)
00787EC0   24040233 li          a0,0x233
00787EC4   67C50F78 daddiu      a1,fp,0xF78
00787EC8   02E03025 dmove       a2,s7
00787ECC   8EE7F158 lw          a3,0xF158(s7)
00787ED0   24080000 li          t0,0x0
00787ED4   0320F809 jalr        ra,t9
00787ED8   001F1000 sll         v0,ra,0
00787EDC   00401825 dmove       v1,v0
00787EE0   44800000 mtc1        zero,f0
00787EE4   44950800 mtc1        s5,f1
00787EE8   46010034 c.olt.s     f0,f1
00787EEC   4500003F bc1f        0x00787FEC
00787EF0   02E01825 dmove       v1,s7
00787EF4   02971823 subu        v1,s4,s7
00787EF8   50600009 beql        v1,zero,0x00787F20
00787EFC   02E01825 dmove       v1,s7
00787F00   00141804 sllv        v1,s4,zero
00787F04   9C640000 lwu         a0,0x0000(v1)
00787F08   8C830024 lw          v1,0x0024(a0)
00787F0C   0014283F dsra        a1,s4,32
00787F10   14A30002 bne         a1,v1,0x00787F1C
00787F14   02E01825 dmove       v1,s7
00787F18   00801825 dmove       v1,a0
00787F1C   00602025 dmove       a0,v1
00787F20   52E30002 beql        s7,v1,0x00787F2C
00787F24   00602025 dmove       a0,v1
00787F28   9C640030 lwu         a0,0x0030(v1)
00787F2C   12E4002F beq         s7,a0,0x00787FEC
00787F30   02E02025 dmove       a0,s7
00787F34   8EE49738 lw          a0,0x9738(s7)
00787F38   8C840000 lw          a0,0x0000(a0)
00787F3C   9C650030 lwu         a1,0x0030(v1)
00787F40   9CA50014 lwu         a1,0x0014(a1)
00787F44   9CA50010 lwu         a1,0x0010(a1)
00787F48   9CA50034 lwu         a1,0x0034(a1)
00787F4C   8CA5000C lw          a1,0x000C(a1)
00787F50   0085202A slt         a0,a0,a1
00787F54   14800025 bne         a0,zero,0x00787FEC
00787F58   02E02025 dmove       a0,s7
00787F5C   9C630030 lwu         v1,0x0030(v1)
00787F60   9C630014 lwu         v1,0x0014(v1)
00787F64   9C630010 lwu         v1,0x0010(v1)
00787F68   9C630034 lwu         v1,0x0034(v1)
00787F6C   8C63000C lw          v1,0x000C(v1)
00787F70   6463FFFF daddiu      v1,v1,-0x1
00787F74   000318B8 dsll        v1,v1,2
00787F78   8EE49738 lw          a0,0x9738(s7)
00787F7C   0064182D daddu       v1,v1,a0
00787F80   8C74000C lw          s4,0x000C(v1)
00787F84   029C182D daddu       v1,s4,gp
00787F88   90630018 lbu         v1,0x0018(v1)
00787F8C   44950000 mtc1        s5,f0
00787F90   46000024 cvt.w.s     f0,f0
00787F94   44040000 mfc1        a0,f0
00787F98   0064182D daddu       v1,v1,a0
00787F9C   029C202D daddu       a0,s4,gp
00787FA0   A0830018 sb          v1,0x0018(a0)
00787FA4   C7800014 lwc1        f0,0x0014(gp)
00787FA8   44950800 mtc1        s5,f1
00787FAC   46010000 add.s       f0,f0,f1                ---- XXX2
00787FB0   E7800014 swc1        f0,0x0014(gp)
00787FB4   8EF97DC0 lw          t9,0x7DC0(s7)
00787FB8   02802025 dmove       a0,s4
00787FBC   0320F809 jalr        ra,t9
00787FC0   001F1000 sll         v0,ra,0
00787FC4   8C430000 lw          v1,0x0000(v0)
00787FC8   029C202D daddu       a0,s4,gp
00787FCC   90840018 lbu         a0,0x0018(a0)
00787FD0   14830006 bne         a0,v1,0x00787FEC
00787FD4   02E02025 dmove       a0,s7
00787FD8   8EF994E0 lw          t9,0x94E0(s7)
00787FDC   02802025 dmove       a0,s4
00787FE0   0320F809 jalr        ra,t9
00787FE4   001F1000 sll         v0,ra,0
00787FE8   00402025 dmove       a0,v0
00787FEC   C7800010 lwc1        f0,0x0010(gp)
00787FF0   44950800 mtc1        s5,f1
00787FF4   46010000 add.s       f0,f0,f1              ---- XXX3
00787FF8   E7800010 swc1        f0,0x0010(gp)
00787FFC   44020000 mfc1        v0,f0
00788000   10000096 b           0x0078825C
00788004   00000000 nop
00788008   66E4BAB8 daddiu      a0,s7,-0x4548
0078800C   14640039 bne         v1,a0,0x007880F4
00788010   02E02025 dmove       a0,s7
00788014   44950000 mtc1        s5,f0
00788018   46000024 cvt.w.s     f0,f0
0078801C   44150000 mfc1        s5,f0
00788020   03802025 dmove       a0,gp
00788024   9C83FFFC lwu         v1,0xFFFC(a0)
00788028   9C79003C lwu         t9,0x003C(v1)
0078802C   02A02825 dmove       a1,s5
00788030   0320F809 jalr        ra,t9
00788034   001F1000 sll         v0,ra,0
00788038   00401825 dmove       v1,v0
0078803C   56E30005 bnel        s7,v1,0x00788054
00788040   00601825 dmove       v1,v1
00788044   24030001 li          v1,0x1
00788048   0075202B sltu        a0,v1,s5
0078804C   66E30008 daddiu      v1,s7,0x8
00788050   02E4180B movn        v1,s7,a0
00788054   16E30023 bne         s7,v1,0x007880E4
00788058   02E01825 dmove       v1,s7
0078805C   AF8000A0 sw          zero,0x00A0(gp)
00788060   8EE378A8 lw          v1,0x78A8(s7)
00788064   DC63030C ld          v1,0x030C(v1)
00788068   FF8300C4 sd          v1,0x00C4(gp)
0078806C   8EE378A8 lw          v1,0x78A8(s7)
00788070   DC63030C ld          v1,0x030C(v1)
00788074   001520F8 dsll        a0,s5,3
00788078   9F8500CC lwu         a1,0x00CC(gp)
0078807C   0085202D daddu       a0,a0,a1
00788080   FC83000C sd          v1,0x000C(a0)
00788084   C7C01094 lwc1        f0,0x1094(fp)
00788088   C781005C lwc1        f1,0x005C(gp)
0078808C   46010000 add.s       f0,f0,f1           ---- XXX4
00788090   E780005C swc1        f0,0x005C(gp)
00788094   9F830064 lwu         v1,0x0064(gp)
00788098   00152138 dsll        a0,s5,4
0078809C   0064182D daddu       v1,v1,a0
007880A0   94630014 lhu         v1,0x0014(v1)
007880A4   34630100 ori         v1,v1,0x100
007880A8   9F840064 lwu         a0,0x0064(gp)
007880AC   00152938 dsll        a1,s5,4
007880B0   0085202D daddu       a0,a0,a1
007880B4   A4830014 sh          v1,0x0014(a0)
007880B8   8EF9AD38 lw          t9,0xAD38(s7)
007880BC   02A02025 dmove       a0,s5
007880C0   0320F809 jalr        ra,t9
007880C4   001F1000 sll         v0,ra,0
007880C8   00401825 dmove       v1,v0
007880CC   8EF916D8 lw          t9,0x16D8(s7)
007880D0   24050007 li          a1,0x7
007880D4   02A02025 dmove       a0,s5
007880D8   0320F809 jalr        ra,t9
007880DC   001F1000 sll         v0,ra,0
007880E0   00401825 dmove       v1,v0
007880E4   C780005C lwc1        f0,0x005C(gp)
007880E8   44020000 mfc1        v0,f0
007880EC   1000005B b           0x0078825C
007880F0   00000000 nop
007880F4   66E44320 daddiu      a0,s7,0x4320
007880F8   14640058 bne         v1,a0,0x0078825C
007880FC   02E01025 dmove       v0,s7
00788100   44950000 mtc1        s5,f0
00788104   46000024 cvt.w.s     f0,f0
00788108   44030000 mfc1        v1,f0
0078810C   3064FFFF andi        a0,v1,0xFFFF
00788110   44950000 mtc1        s5,f0
00788114   46000024 cvt.w.s     f0,f0
00788118   44030000 mfc1        v1,f0
0078811C   0003A43B dsra        s4,v1,16
00788120   4480F000 mtc1        zero,f30
00788124   0004182B sltu        v1,zero,a0
00788128   1060004B beq         v1,zero,0x00788258
0078812C   02E01825 dmove       v1,s7
00788130   8EF9AD38 lw          t9,0xAD38(s7)
00788134   0320F809 jalr        ra,t9
00788138   001F1000 sll         v0,ra,0
0078813C   00409825 dmove       s3,v0
00788140   02602025 dmove       a0,s3
00788144   9C83FFFC lwu         v1,0xFFFC(a0)
00788148   9C790050 lwu         t9,0x0050(v1)
0078814C   24050000 li          a1,0x0
00788150   0320F809 jalr        ra,t9
00788154   001F1000 sll         v0,ra,0
00788158   0040A825 dmove       s5,v0
0078815C   0280182A slt         v1,s4,zero
00788160   66E40008 daddiu      a0,s7,0x8
00788164   02E3200B movn        a0,s7,v1
00788168   52E40008 beql        s7,a0,0x0078818C
0078816C   00801825 dmove       v1,a0
00788170   8EE32100 lw          v1,0x2100(s7)
00788174   C4600034 lwc1        f0,0x0034(v1)
00788178   46000024 cvt.w.s     f0,f0
0078817C   44030000 mfc1        v1,f0
00788180   0283202A slt         a0,s4,v1
00788184   66E30008 daddiu      v1,s7,0x8
00788188   02E4180A movz        v1,s7,a0
0078818C   12E3001C beq         s7,v1,0x00788200
00788190   02E01825 dmove       v1,s7
00788194   24030001 li          v1,0x1
00788198   06830003 bgezl       s4,0x007881A8
0078819C   02831814 dsllv       v1,v1,s4
007881A0   0014202F dneg        a0,s4
007881A4   00831817 dsrav       v1,v1,a0
007881A8   02A31824 and         v1,s5,v1
007881AC   14600006 bne         v1,zero,0x007881C8
007881B0   02E01825 dmove       v1,s7
007881B4   C7C01094 lwc1        f0,0x1094(fp)
007881B8   C7810058 lwc1        f1,0x0058(gp)
007881BC   46010000 add.s       f0,f0,f1               ---- XXX5
007881C0   E7800058 swc1        f0,0x0058(gp)
007881C4   44030000 mfc1        v1,f0
007881C8   9E63FFFC lwu         v1,0xFFFC(s3)
007881CC   9C790054 lwu         t9,0x0054(v1)
007881D0   24030001 li          v1,0x1
007881D4   06830003 bgezl       s4,0x007881E4
007881D8   02831814 dsllv       v1,v1,s4
007881DC   0014202F dneg        a0,s4
007881E0   00831817 dsrav       v1,v1,a0
007881E4   02A3A825 or          s5,s5,v1
007881E8   02A02825 dmove       a1,s5
007881EC   24060000 li          a2,0x0
007881F0   02602025 dmove       a0,s3
007881F4   0320F809 jalr        ra,t9
007881F8   001F1000 sll         v0,ra,0
007881FC   00401825 dmove       v1,v0
00788200   8EE32100 lw          v1,0x2100(s7)
00788204   C4600034 lwc1        f0,0x0034(v1)
00788208   46000024 cvt.w.s     f0,f0
0078820C   44030000 mfc1        v1,f0
00788210   1000000D b           0x00788248
00788214   00000000 nop
00788218   6463FFFF daddiu      v1,v1,-0x1
0078821C   24040001 li          a0,0x1
00788220   04630003 bgezl       v1,0x00788230
00788224   00642014 dsllv       a0,a0,v1
00788228   0003282F dneg        a1,v1
0078822C   00A42017 dsrav       a0,a0,a1
00788230   02A42024 and         a0,s5,a0
00788234   10800004 beq         a0,zero,0x00788248
00788238   02E02025 dmove       a0,s7
0078823C   C7C01094 lwc1        f0,0x1094(fp)
00788240   461E0780 add.s       f30,f0,f30    ---- XXX6
00788244   4404F000 mfc1        a0,f30
00788248   1460FFF3 bne         v1,zero,0x00788218
0078824C   00000000 nop
00788250   02E01825 dmove       v1,s7
00788254   02E01825 dmove       v1,s7
00788258   4402F000 mfc1        v0,f30
0078825C   DFBF0000 ld          ra,0x0000(sp)
00788260   DFBE0008 ld          fp,0x0008(sp)
00788264   C7BE0050 lwc1        f30,0x0050(sp)
00788268   7BBC0040 lq          gp,0x0040(sp)
0078826C   7BB50030 lq          s5,0x0030(sp)
00788270   7BB40020 lq          s4,0x0020(sp)
00788274   7BB30010 lq          s3,0x0010(sp)
00788278   03E00008 jr          ra
0078827C   67BD0060 daddiu      sp,sp,0x60


the PS3 version is


$// Function: game-info__game-info__method-id-10:	File offset:0x001f5c-0x26bc, Segment:#0+0x142c
$
$		.section	".text.GOAL"
$		.align	2
$		.type	.GOAL_game_info__game_info__method_id_10,@function
$		.globl	.GOAL_game_info__game_info__method_id_10
$
F.GOAL_game_info__game_info__method_id_10:	// 'game-info__game-info__method-id-10'
     1f5c:	67bdff90 	daddiu	sp,sp,-112
     1f60:	ffbf0000 	sd	ra,0(sp)
     1f64:	ffbe0008 	sd	s8,8(sp)
     1f68:	0320f025 	move	s8,t9
     1f6c:	7fb20010 	sq	s2,16(sp)
     1f70:	7fb30020 	sq	s3,32(sp)
     1f74:	7fb40030 	sq	s4,48(sp)
     1f78:	7fb50040 	sq	s5,64(sp)
     1f7c:	7fbc0050 	sq	gp,80(sp)
     1f80:	e7be0060 	swc1	$f30,96(sp)
     1f84:	0080e025 	move	gp,a0
     1f88:	00c0a825 	move	s5,a2
     1f8c:	00e0a025 	move	s4,a3
     1f90:	00a01825 	move	v1,a1
     1f94:	66e45780 	daddiu	a0,s7,22400	// sym: 'life'
     1f98:	14640023 	bne	v1,a0,0x2028
     1f9c:	02e02025 	move	a0,s7
     1fa0:	44950000 	mtc1	s5,$f0
     1fa4:	44800800 	mtc1	zero,$f1
     1fa8:	46010034 	c.olt.s	$f0,$f1
     1fac:	4501000e 	bc1t	0x1fe8
     1fb0:	00000000 	nop
     1fb4:	8ef91390 	lw	t9,5008(s7)	// sym: 'seek'
     1fb8:	c7800008 	lwc1	$f0,8(gp)
     1fbc:	44040000 	mfc1	a0,$f0
     1fc0:	c780000c 	lwc1	$f0,12(gp)
     1fc4:	44050000 	mfc1	a1,$f0
     1fc8:	02a03025 	move	a2,s5
     1fcc:	0320f809 	jalr	t9
     1fd0:	001f1000 	sll	v0,ra,0x0
     1fd4:	44820000 	mtc1	v0,$f0
     1fd8:	e7800008 	swc1	$f0,8(gp)
     1fdc:	44030000 	mfc1	v1,$f0
     1fe0:	1000000d 	b	0x2018
     1fe4:	00000000 	nop
     1fe8:	8ef91390 	lw	t9,5008(s7)	// sym: 'seek'
     1fec:	c7800008 	lwc1	$f0,8(gp)
     1ff0:	44040000 	mfc1	a0,$f0
     1ff4:	8fc51510 	lw	a1,5392(s8)
     1ff8:	44950000 	mtc1	s5,$f0
     1ffc:	46000007 	neg.s	$f0,$f0
     2000:	44060000 	mfc1	a2,$f0
     2004:	0320f809 	jalr	t9
     2008:	001f1000 	sll	v0,ra,0x0
     200c:	44820000 	mtc1	v0,$f0
     2010:	e7800008 	swc1	$f0,8(gp)
     2014:	44030000 	mfc1	v1,$f0
     2018:	c7800008 	lwc1	$f0,8(gp)
     201c:	44020000 	mfc1	v0,$f0
     2020:	1000019c 	b	0x2694
     2024:	00000000 	nop
     2028:	66e439e8 	daddiu	a0,s7,14824	// sym: 'money'
     202c:	1464009c 	bne	v1,a0,0x22a0
     2030:	02e02025 	move	a0,s7
     2034:	44800000 	mtc1	zero,$f0
     2038:	44950800 	mtc1	s5,$f1
     203c:	46010034 	c.olt.s	$f0,$f1
     2040:	45010002 	bc1t	0x204c
     2044:	66e30008 	daddiu	v1,s7,8
     2048:	02e01825 	move	v1,s7
     204c:	52e3000a 	beql	s7,v1,0x2078
     2050:	00601825 	move	v1,v1
     2054:	c7800010 	lwc1	$f0,16(gp)
     2058:	44950800 	mtc1	s5,$f1
     205c:	46010000 	add.s	$f0,$f0,$f1
     2060:	8ee34a10 	lw	v1,18960(s7)	// sym: '*GAME-bank*'
     2064:	c461000c 	lwc1	$f1,12(v1)
     2068:	46010032 	c.eq.s	$f0,$f1
     206c:	45010002 	bc1t	0x2078
     2070:	66e30008 	daddiu	v1,s7,8
     2074:	02e01825 	move	v1,s7
     2078:	12e3000a 	beq	s7,v1,0x20a4
     207c:	02e01825 	move	v1,s7
     2080:	8ef90700 	lw	t9,1792(s7)	// sym: 'level-hint-spawn'
     2084:	24040233 	li	a0,563
     2088:	67c513c8 	daddiu	a1,s8,5064	// rel: 0x003324=[string #10]
     208c:	02e03025 	move	a2,s7
     2090:	8ee70d10 	lw	a3,3344(s7)	// sym: '*entity-pool*'
     2094:	24080000 	li	a4,0
     2098:	0320f809 	jalr	t9
     209c:	001f1000 	sll	v0,ra,0x0
     20a0:	00401825 	move	v1,v0
     20a4:	44800000 	mtc1	zero,$f0
     20a8:	44950800 	mtc1	s5,$f1
     20ac:	46010034 	c.olt.s	$f0,$f1
     20b0:	4500003f 	bc1f	0x21b0
     20b4:	02e01825 	move	v1,s7
     20b8:	02971823 	subu	v1,s4,s7
     20bc:	50600009 	beqzl	v1,0x20e4
     20c0:	02e01825 	move	v1,s7
     20c4:	00141804 	sllv	v1,s4,zero
     20c8:	9c640000 	lwu	a0,0(v1)
     20cc:	8c830024 	lw	v1,36(a0)
     20d0:	0014283f 	dsra32	a1,s4,0x0
     20d4:	14a30002 	bne	a1,v1,0x20e0
     20d8:	02e01825 	move	v1,s7
     20dc:	00801825 	move	v1,a0
     20e0:	00602025 	move	a0,v1
     20e4:	52e30002 	beql	s7,v1,0x20f0
     20e8:	00602025 	move	a0,v1
     20ec:	9c640030 	lwu	a0,48(v1)
     20f0:	12e4002f 	beq	s7,a0,0x21b0
     20f4:	02e02025 	move	a0,s7
     20f8:	8ee45f48 	lw	a0,24392(s7)	// sym: '*level-task-data-remap*'
     20fc:	8c840000 	lw	a0,0(a0)
     2100:	9c650030 	lwu	a1,48(v1)
     2104:	9ca50014 	lwu	a1,20(a1)
     2108:	9ca50010 	lwu	a1,16(a1)
     210c:	9ca50034 	lwu	a1,52(a1)
     2110:	8ca5000c 	lw	a1,12(a1)
     2114:	0085202a 	slt	a0,a0,a1
     2118:	14800025 	bnez	a0,0x21b0
     211c:	02e02025 	move	a0,s7
     2120:	9c630030 	lwu	v1,48(v1)
     2124:	9c630014 	lwu	v1,20(v1)
     2128:	9c630010 	lwu	v1,16(v1)
     212c:	9c630034 	lwu	v1,52(v1)
     2130:	8c63000c 	lw	v1,12(v1)
     2134:	6463ffff 	daddiu	v1,v1,-1
     2138:	000318b8 	dsll	v1,v1,0x2
     213c:	8ee45f48 	lw	a0,24392(s7)	// sym: '*level-task-data-remap*'
     2140:	0064182d 	daddu	v1,v1,a0
     2144:	8c74000c 	lw	s4,12(v1)
     2148:	029c182d 	daddu	v1,s4,gp
     214c:	90630018 	lbu	v1,24(v1)
     2150:	44950000 	mtc1	s5,$f0
     2154:	46000024 	cvt.w.s	$f0,$f0
     2158:	44040000 	mfc1	a0,$f0
     215c:	0064182d 	daddu	v1,v1,a0
     2160:	029c202d 	daddu	a0,s4,gp
     2164:	a0830018 	sb	v1,24(a0)
     2168:	c7800014 	lwc1	$f0,20(gp)
     216c:	44950800 	mtc1	s5,$f1
     2170:	46010000 	add.s	$f0,$f0,$f1
     2174:	e7800014 	swc1	$f0,20(gp)
     2178:	8ef95f38 	lw	t9,24376(s7)	// sym: 'get-game-count'
     217c:	02802025 	move	a0,s4
     2180:	0320f809 	jalr	t9
     2184:	001f1000 	sll	v0,ra,0x0
     2188:	8c430000 	lw	v1,0(v0)
     218c:	029c202d 	daddu	a0,s4,gp
     2190:	90840018 	lbu	a0,24(a0)
     2194:	14830006 	bne	a0,v1,0x21b0
     2198:	02e02025 	move	a0,s7
     219c:	8ef95f50 	lw	t9,24400(s7)	// sym: 'activate-orb-all'
     21a0:	02802025 	move	a0,s4
     21a4:	0320f809 	jalr	t9
     21a8:	001f1000 	sll	v0,ra,0x0
     21ac:	00402025 	move	a0,v0
     21b0:	c7800010 	lwc1	$f0,16(gp)
     21b4:	44950800 	mtc1	s5,$f1
     21b8:	46010000 	add.s	$f0,$f0,$f1
     21bc:	e7800010 	swc1	$f0,16(gp)
     21c0:	44800000 	mtc1	zero,$f0
     21c4:	44950800 	mtc1	s5,$f1
     21c8:	46010034 	c.olt.s	$f0,$f1
     21cc:	45000030 	bc1f	0x2290
     21d0:	02e01825 	move	v1,s7
     21d4:	c7800014 	lwc1	$f0,20(gp)
     21d8:	c7c114f8 	lwc1	$f1,5368(s8)
     21dc:	46010032 	c.eq.s	$f0,$f1
     21e0:	4500000d 	bc1f	0x2218
     21e4:	02e01825 	move	v1,s7
     21e8:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     21ec:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     21f0:	67c51398 	daddiu	a1,s8,5016	// rel: 0x0032f4=[string #9]
     21f4:	0320f809 	jalr	t9
     21f8:	001f1000 	sll	v0,ra,0x0
     21fc:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     2200:	24040024 	li	a0,36
     2204:	0320f809 	jalr	t9
     2208:	001f1000 	sll	v0,ra,0x0
     220c:	00401825 	move	v1,v0
     2210:	1000001f 	b	0x2290
     2214:	00000000 	nop
     2218:	c7c114ec 	lwc1	$f1,5356(s8)
     221c:	46010032 	c.eq.s	$f0,$f1
     2220:	4500000d 	bc1f	0x2258
     2224:	02e01825 	move	v1,s7
     2228:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     222c:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     2230:	67c51368 	daddiu	a1,s8,4968	// rel: 0x0032c4=[string #8]
     2234:	0320f809 	jalr	t9
     2238:	001f1000 	sll	v0,ra,0x0
     223c:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     2240:	24040025 	li	a0,37
     2244:	0320f809 	jalr	t9
     2248:	001f1000 	sll	v0,ra,0x0
     224c:	00401825 	move	v1,v0
     2250:	1000000f 	b	0x2290
     2254:	00000000 	nop
     2258:	c7c114e8 	lwc1	$f1,5352(s8)
     225c:	46010032 	c.eq.s	$f0,$f1
     2260:	4500000b 	bc1f	0x2290
     2264:	02e01825 	move	v1,s7
     2268:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     226c:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     2270:	67c51328 	daddiu	a1,s8,4904	// rel: 0x003284=[string #7]
     2274:	0320f809 	jalr	t9
     2278:	001f1000 	sll	v0,ra,0x0
     227c:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     2280:	24040026 	li	a0,38
     2284:	0320f809 	jalr	t9
     2288:	001f1000 	sll	v0,ra,0x0
     228c:	00401825 	move	v1,v0
     2290:	c7800010 	lwc1	$f0,16(gp)
     2294:	44020000 	mfc1	v0,$f0
     2298:	100000fe 	b	0x2694
     229c:	00000000 	nop
     22a0:	66e41948 	daddiu	a0,s7,6472	// sym: 'fuel-cell'
     22a4:	1464006d 	bne	v1,a0,0x245c
     22a8:	02e02025 	move	a0,s7
     22ac:	44950000 	mtc1	s5,$f0
     22b0:	46000024 	cvt.w.s	$f0,$f0
     22b4:	44140000 	mfc1	s4,$f0
     22b8:	03802025 	move	a0,gp
     22bc:	9c83fffc 	lwu	v1,-4(a0)
     22c0:	9c79003c 	lwu	t9,60(v1)
     22c4:	02802825 	move	a1,s4
     22c8:	0320f809 	jalr	t9
     22cc:	001f1000 	sll	v0,ra,0x0
     22d0:	00401825 	move	v1,v0
     22d4:	56e30005 	bnel	s7,v1,0x22ec
     22d8:	00601825 	move	v1,v1
     22dc:	24030001 	li	v1,1
     22e0:	0074202b 	sltu	a0,v1,s4
     22e4:	66e30008 	daddiu	v1,s7,8
     22e8:	02e4180b 	movn	v1,s7,a0
     22ec:	16e30023 	bne	s7,v1,0x237c
     22f0:	02e01825 	move	v1,s7
     22f4:	af8000a0 	sw	zero,160(gp)
     22f8:	8ee30348 	lw	v1,840(s7)	// sym: '*display*'
     22fc:	dc63030c 	ld	v1,780(v1)
     2300:	ff8300c4 	sd	v1,196(gp)
     2304:	8ee30348 	lw	v1,840(s7)	// sym: '*display*'
     2308:	dc63030c 	ld	v1,780(v1)
     230c:	001420f8 	dsll	a0,s4,0x3
     2310:	9f8500cc 	lwu	a1,204(gp)
     2314:	0085202d 	daddu	a0,a0,a1
     2318:	fc83000c 	sd	v1,12(a0)
     231c:	c7c01508 	lwc1	$f0,5384(s8)
     2320:	c781005c 	lwc1	$f1,92(gp)
     2324:	46010000 	add.s	$f0,$f0,$f1
     2328:	e780005c 	swc1	$f0,92(gp)
     232c:	9f830064 	lwu	v1,100(gp)
     2330:	00142138 	dsll	a0,s4,0x4
     2334:	0064182d 	daddu	v1,v1,a0
     2338:	94630014 	lhu	v1,20(v1)
     233c:	34630100 	ori	v1,v1,0x100
     2340:	9f840064 	lwu	a0,100(gp)
     2344:	00142938 	dsll	a1,s4,0x4
     2348:	0085202d 	daddu	a0,a0,a1
     234c:	a4830014 	sh	v1,20(a0)
     2350:	8ef90cf8 	lw	t9,3320(s7)	// sym: 'get-task-control'
     2354:	02802025 	move	a0,s4
     2358:	0320f809 	jalr	t9
     235c:	001f1000 	sll	v0,ra,0x0
     2360:	00401825 	move	v1,v0
     2364:	8ef90590 	lw	t9,1424(s7)	// sym: 'close-specific-task!'
     2368:	24050007 	li	a1,7
     236c:	02802025 	move	a0,s4
     2370:	0320f809 	jalr	t9
     2374:	001f1000 	sll	v0,ra,0x0
     2378:	00401825 	move	v1,v0
     237c:	44800000 	mtc1	zero,$f0
     2380:	44950800 	mtc1	s5,$f1
     2384:	46010034 	c.olt.s	$f0,$f1
     2388:	45000030 	bc1f	0x244c
     238c:	02e01825 	move	v1,s7
     2390:	c780005c 	lwc1	$f0,92(gp)
     2394:	c7c114fc 	lwc1	$f1,5372(s8)
     2398:	46010032 	c.eq.s	$f0,$f1
     239c:	4500000d 	bc1f	0x23d4
     23a0:	02e01825 	move	v1,s7
     23a4:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     23a8:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     23ac:	67c512f8 	daddiu	a1,s8,4856	// rel: 0x003254=[string #6]
     23b0:	0320f809 	jalr	t9
     23b4:	001f1000 	sll	v0,ra,0x0
     23b8:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     23bc:	2404001e 	li	a0,30
     23c0:	0320f809 	jalr	t9
     23c4:	001f1000 	sll	v0,ra,0x0
     23c8:	00401825 	move	v1,v0
     23cc:	1000001f 	b	0x244c
     23d0:	00000000 	nop
     23d4:	c7c114f4 	lwc1	$f1,5364(s8)
     23d8:	46010032 	c.eq.s	$f0,$f1
     23dc:	4500000d 	bc1f	0x2414
     23e0:	02e01825 	move	v1,s7
     23e4:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     23e8:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     23ec:	67c512c8 	daddiu	a1,s8,4808	// rel: 0x003224=[string #5]
     23f0:	0320f809 	jalr	t9
     23f4:	001f1000 	sll	v0,ra,0x0
     23f8:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     23fc:	2404001f 	li	a0,31
     2400:	0320f809 	jalr	t9
     2404:	001f1000 	sll	v0,ra,0x0
     2408:	00401825 	move	v1,v0
     240c:	1000000f 	b	0x244c
     2410:	00000000 	nop
     2414:	c7c114f0 	lwc1	$f1,5360(s8)
     2418:	46010032 	c.eq.s	$f0,$f1
     241c:	4500000b 	bc1f	0x244c
     2420:	02e01825 	move	v1,s7
     2424:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     2428:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     242c:	67c51298 	daddiu	a1,s8,4760	// rel: 0x0031f4=[string #4]
     2430:	0320f809 	jalr	t9
     2434:	001f1000 	sll	v0,ra,0x0
     2438:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     243c:	24040020 	li	a0,32
     2440:	0320f809 	jalr	t9
     2444:	001f1000 	sll	v0,ra,0x0
     2448:	00401825 	move	v1,v0
     244c:	c780005c 	lwc1	$f0,92(gp)
     2450:	44020000 	mfc1	v0,$f0
     2454:	1000008f 	b	0x2694
     2458:	00000000 	nop
     245c:	66e43a40 	daddiu	a0,s7,14912	// sym: 'buzzer'
     2460:	1464008c 	bne	v1,a0,0x2694
     2464:	02e01025 	move	v0,s7
     2468:	44950000 	mtc1	s5,$f0
     246c:	46000024 	cvt.w.s	$f0,$f0
     2470:	44030000 	mfc1	v1,$f0
     2474:	3064ffff 	andi	a0,v1,0xffff
     2478:	44950000 	mtc1	s5,$f0
     247c:	46000024 	cvt.w.s	$f0,$f0
     2480:	44030000 	mfc1	v1,$f0
     2484:	00039c3b 	dsra	s3,v1,0x10
     2488:	4480f000 	mtc1	zero,$f30
     248c:	0004182b 	sltu	v1,zero,a0
     2490:	1060004b 	beqz	v1,0x25c0
     2494:	02e01825 	move	v1,s7
     2498:	8ef90cf8 	lw	t9,3320(s7)	// sym: 'get-task-control'
     249c:	0320f809 	jalr	t9
     24a0:	001f1000 	sll	v0,ra,0x0
     24a4:	00409025 	move	s2,v0
     24a8:	02402025 	move	a0,s2
     24ac:	9c83fffc 	lwu	v1,-4(a0)
     24b0:	9c790050 	lwu	t9,80(v1)
     24b4:	24050000 	li	a1,0
     24b8:	0320f809 	jalr	t9
     24bc:	001f1000 	sll	v0,ra,0x0
     24c0:	0040a025 	move	s4,v0
     24c4:	0260182a 	slt	v1,s3,zero
     24c8:	66e40008 	daddiu	a0,s7,8
     24cc:	02e3200b 	movn	a0,s7,v1
     24d0:	52e40008 	beql	s7,a0,0x24f4
     24d4:	00801825 	move	v1,a0
     24d8:	8ee313b0 	lw	v1,5040(s7)	// sym: '*FACT-bank*'
     24dc:	c4600034 	lwc1	$f0,52(v1)
     24e0:	46000024 	cvt.w.s	$f0,$f0
     24e4:	44030000 	mfc1	v1,$f0
     24e8:	0263202a 	slt	a0,s3,v1
     24ec:	66e30008 	daddiu	v1,s7,8
     24f0:	02e4180a 	movz	v1,s7,a0
     24f4:	12e3001c 	beq	s7,v1,0x2568
     24f8:	02e01825 	move	v1,s7
     24fc:	24030001 	li	v1,1
     2500:	06630003 	bgezl	s3,0x2510
     2504:	02631814 	dsllv	v1,v1,s3
     2508:	0013202f 	dnegu	a0,s3
     250c:	00831817 	dsrav	v1,v1,a0
     2510:	02831824 	and	v1,s4,v1
     2514:	14600006 	bnez	v1,0x2530
     2518:	02e01825 	move	v1,s7
     251c:	c7c01508 	lwc1	$f0,5384(s8)
     2520:	c7810058 	lwc1	$f1,88(gp)
     2524:	46010000 	add.s	$f0,$f0,$f1
     2528:	e7800058 	swc1	$f0,88(gp)
     252c:	44030000 	mfc1	v1,$f0
     2530:	9e43fffc 	lwu	v1,-4(s2)
     2534:	9c790054 	lwu	t9,84(v1)
     2538:	24030001 	li	v1,1
     253c:	06630003 	bgezl	s3,0x254c
     2540:	02631814 	dsllv	v1,v1,s3
     2544:	0013202f 	dnegu	a0,s3
     2548:	00831817 	dsrav	v1,v1,a0
     254c:	0283a025 	or	s4,s4,v1
     2550:	02802825 	move	a1,s4
     2554:	24060000 	li	a2,0
     2558:	02402025 	move	a0,s2
     255c:	0320f809 	jalr	t9
     2560:	001f1000 	sll	v0,ra,0x0
     2564:	00401825 	move	v1,v0
     2568:	8ee313b0 	lw	v1,5040(s7)	// sym: '*FACT-bank*'
     256c:	c4600034 	lwc1	$f0,52(v1)
     2570:	46000024 	cvt.w.s	$f0,$f0
     2574:	44030000 	mfc1	v1,$f0
     2578:	1000000d 	b	0x25b0
     257c:	00000000 	nop
     2580:	6463ffff 	daddiu	v1,v1,-1
     2584:	24040001 	li	a0,1
     2588:	04630003 	bgezl	v1,0x2598
     258c:	00642014 	dsllv	a0,a0,v1
     2590:	0003282f 	dnegu	a1,v1
     2594:	00a42017 	dsrav	a0,a0,a1
     2598:	02842024 	and	a0,s4,a0
     259c:	10800004 	beqz	a0,0x25b0
     25a0:	02e02025 	move	a0,s7
     25a4:	c7c01508 	lwc1	$f0,5384(s8)
     25a8:	461e0780 	add.s	$f30,$f0,$f30
     25ac:	4404f000 	mfc1	a0,$f30
     25b0:	1460fff3 	bnez	v1,0x2580
     25b4:	00000000 	nop
     25b8:	02e01825 	move	v1,s7
     25bc:	02e01825 	move	v1,s7
     25c0:	44800000 	mtc1	zero,$f0
     25c4:	44950800 	mtc1	s5,$f1
     25c8:	46010034 	c.olt.s	$f0,$f1
     25cc:	45000030 	bc1f	0x2690
     25d0:	02e01825 	move	v1,s7
     25d4:	c7800058 	lwc1	$f0,88(gp)
     25d8:	c7c114e4 	lwc1	$f1,5348(s8)
     25dc:	46010032 	c.eq.s	$f0,$f1
     25e0:	4500000d 	bc1f	0x2618
     25e4:	02e01825 	move	v1,s7
     25e8:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     25ec:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     25f0:	67c51268 	daddiu	a1,s8,4712	// rel: 0x0031c4=[string #3]
     25f4:	0320f809 	jalr	t9
     25f8:	001f1000 	sll	v0,ra,0x0
     25fc:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     2600:	24040021 	li	a0,33
     2604:	0320f809 	jalr	t9
     2608:	001f1000 	sll	v0,ra,0x0
     260c:	00401825 	move	v1,v0
     2610:	1000001f 	b	0x2690
     2614:	00000000 	nop
     2618:	c7c114dc 	lwc1	$f1,5340(s8)
     261c:	46010032 	c.eq.s	$f0,$f1
     2620:	4500000d 	bc1f	0x2658
     2624:	02e01825 	move	v1,s7
     2628:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     262c:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     2630:	67c51238 	daddiu	a1,s8,4664	// rel: 0x003194=[string #2]
     2634:	0320f809 	jalr	t9
     2638:	001f1000 	sll	v0,ra,0x0
     263c:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     2640:	24040022 	li	a0,34
     2644:	0320f809 	jalr	t9
     2648:	001f1000 	sll	v0,ra,0x0
     264c:	00401825 	move	v1,v0
     2650:	1000000f 	b	0x2690
     2654:	00000000 	nop
     2658:	c7c114d8 	lwc1	$f1,5336(s8)
     265c:	46010032 	c.eq.s	$f0,$f1
     2660:	4500000b 	bc1f	0x2690
     2664:	02e01825 	move	v1,s7
     2668:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     266c:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     2670:	67c511f8 	daddiu	a1,s8,4600	// rel: 0x003154=[string #1]
     2674:	0320f809 	jalr	t9
     2678:	001f1000 	sll	v0,ra,0x0
     267c:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     2680:	24040023 	li	a0,35
     2684:	0320f809 	jalr	t9
     2688:	001f1000 	sll	v0,ra,0x0
     268c:	00401825 	move	v1,v0
     2690:	4402f000 	mfc1	v0,$f30
     2694:	dfbf0000 	ld	ra,0(sp)
     2698:	dfbe0008 	ld	s8,8(sp)
     269c:	c7be0060 	lwc1	$f30,96(sp)
     26a0:	7bbc0050 	lq	gp,80(sp)
     26a4:	7bb50040 	lq	s5,64(sp)
     26a8:	7bb40030 	lq	s4,48(sp)
     26ac:	7bb30020 	lq	s3,32(sp)
     26b0:	7bb20010 	lq	s2,16(sp)
     26b4:	03e00008 	jr	ra
     26b8:	67bd0070 	daddiu	sp,sp,112


----------------------------
Original code
----------------------------

(defmethod adjust ((obj game-info) (item symbol) (amount float) &key (source handle INVALID_HANDLE))
  "Adjust a particular fact."
  (the float
    (case item
      
      (life
       (cond
	((>= amount 0.0)
	 (seek! (-> obj life) (-> obj life-max) amount))
	(else
	 (seek! (-> obj life) 0.0 (- amount))
	 )
	)
       (-> obj life))
      
      (money
       (when (and (> amount 0.0) (= (+ (-> obj money) amount) GAME_MONEY_TASK_INC))
	 (level-hint-spawn (text-id v1-trade-orbs-hint) :sound "sksp0014")
	 )
       (unless (<= amount 0.0)
	 (let ((proc (as-process source)))
	   (when (and proc (-> proc entity))
	     (when (<= (-> (entity-level (-> proc entity)) info index) (-> *level-task-data-remap* length))
	       (let ((level-index (-> *level-task-data-remap* (- (-> (entity-level (-> proc entity)) info index) 1))))
		 (+! (-> obj money-per-level level-index) amount)
		 (+! (-> obj money-total) amount)
		 (when (= (-> obj money-per-level level-index) (-> (get-game-count level-index) money-count))
		 ;;(when (= (-> obj money-per-level level-index) 1)
		   (activate-orb-all level-index)
		   )
		 )
	       )
	     )
	   )
	 )
       #|
       (when (> amount 0.0)
       (let ((proc (as-process source)))
       (format *stdout* "amount ~F from process ~S ~S~%" amount (when proc (-> proc name)) (when proc (-> proc parent name)))
       )
       )
       |#
       (+! (-> obj money) amount)
       )
      
      (fuel-cell
       (let ((task (the game-task amount)))
	 (unless (or (task-complete? obj task) (<= task (game-task complete)))
	   (set! (-> obj fuel-cell-deaths) 0)
	   (set! (-> obj fuel-cell-pickup-time) (current-time))
	   (set! (-> obj fuel-cell-time task) (current-time))
	   (+! (-> obj fuel) 1.0)
	   (entity-status-set! (-> obj task-perm-list task status) task-complete)
	   ;; close the task-control reminder section for the task
	   (let ((task-control (get-task-control task))
		 )
	     (close-specific-task! task (task-status need-resolution))
	     )
	   )
	 )
       (-> obj fuel))
      
      (buzzer
       (let ((task (the game-task (logand (the int amount) #xffff)))
	     (index (ash (the int amount) -16))
	     (count 0.0)
	     )
	 (when (> task (game-task none))
	   (let* ((control (get-task-control task))
		  (bits (get-reminder control :which (buzzer-reminder picked-up)))
		  )
	     (when (and (>= index 0) (< index (the int FACT_BUZZER_MAX_DEFAULT)))
	       (unless (logbit? bits index)
		 (+! (-> obj buzzer-total) 1.0)
		 )
	       (save-reminder control (set! bits (logior bits (ash 1 index))) :which (buzzer-reminder picked-up))
	       )
	     (countdown (i (the int FACT_BUZZER_MAX_DEFAULT))
	       (when (logbit? bits i)
		 (+! count 1.0))
	       )
	     )
	   )
	 count)
       )
      
      )
    )
  )

PS3 code

(defmethod adjust ((obj game-info) (item symbol) (amount float) &key (source handle INVALID_HANDLE))
  "Adjust a particular fact."

  ;; cast the return value to a float
  (the float
    (case item

      ;; adjusting life
      (life
        (cond
          ((>= amount 0.0)
            (seek! (-> obj life) (-> obj life-max) amount)
            )
          (else
            (seek! (-> obj life) 0.0 (- amount))
            )
          )
        ;; return life
        (-> obj life)
        )

      ;; adjusting money (precursor orbs)
      (money
        (when (and (> amount 0.0)
                   (= (+ (-> obj money) amount) GAME_MONEY_TASK_INC)
                   )
          (level-hint-spawn (text-id v1-trade-orbs-hint) :sound "sksp0014")
          )
        (unless (<= amount 0.0)
          (let ((proc (as-process source)))
            (when (and proc (-> proc entity))
              (when (<= (-> (entity-level (-> proc entity)) info index) (-> *level-task-data-remap* length))
                (let ((level-index (-> *level-task-data-remap* (- (-> (entity-level (-> proc entity)) info index) 1))))
                  (+! (-> obj money-per-level level-index) amount)
                  (+! (-> obj money-total) amount)
                  (when (= (-> obj money-per-level level-index) (-> (get-game-count level-index) money-count))
                    (activate-orb-all level-index)
                    )
                  )
                )
              )
            )
          )
        (+! (-> obj money) amount)
        ;; return money
        (when (> amount 0.0)
          (case (-> obj money-total)
            (100
              (format #t "TROPHY: 36 (The Orbist) recieved!~%")
              (trophy-func 36)
              )
            (1000
              (format #t "TROPHY: 37 (The Orberer) recieved!~%")
              (trophy-func 37)
              )
            (2000
              (format #t "TROPHY: 38 (The Super Orberator) recieved!~%")
              (trophy-func 38)
              )
            )
          )
        (-> obj money)
        )

      ;; adjusting fuel (power cells)
      (fuel-cell
        (let ((task (the game-task amount)))
          (unless (or (task-complete? obj task) (<= task (game-task complete)))
            (set! (-> obj fuel-cell-deaths) 0)
            (set! (-> obj fuel-cell-pickup-time) (current-time))
            (set! (-> obj fuel-cell-time task) (current-time))
            (+! (-> obj fuel) 1.0)
            (entity-status-set! (-> obj task-perm-list task status) task-complete)

            ;; close the task-control reminder section for the task
            (let ((task-control (get-task-control task)))
              (close-specific-task! task (task-status need-resolution))
              )
            )
          )
        ;; return fuel
        (when (> amount 0.0)
          (case (-> obj fuel)
            (25
              (format #t "TROPHY: 30 (Power Lunch) recieved!~%")
              (trophy-func 30)
              )
            (50
              (format #t "TROPHY: 31 (Power Chords) recieved!~%")
              (trophy-func 31)
              )
            (101
              (format #t "TROPHY: 32 (Maximum Power!) recieved!~%")
              (trophy-func 32)
              )
            )
          )
        (-> obj fuel)
        )

      ;; adjusting buzzer (scout flies)
      (buzzer
        (let ((task (the game-task (logand (the int amount) #xffff)))
              (index (ash (the int amount) -16))
              (count 0.0)
              )
          (when (> task (game-task none))
            (let* ((control (get-task-control task))
                   (bits (get-reminder control :which (buzzer-reminder picked-up)))
                   )
              (when (and (>= index 0) (< index (the int FACT_BUZZER_MAX_DEFAULT)))
                (unless (logbit? bits index)
                  (+! (-> obj buzzer-total) 1.0)
                  )
                (save-reminder control (set! bits (logior bits (ash 1 index))) :which (buzzer-reminder picked-up))
                )
              (countdown (i (the int FACT_BUZZER_MAX_DEFAULT))
                (when (logbit? bits i)
                  (+! count 1.0)
                  )
                )
              )
            )
          ;; return count
          (when (> amount 0.0)
            (case (-> obj buzzer-total)
              (28
                (format #t "TROPHY: 33 (Buzzin') recieved!~%")
                (trophy-func 33)
                )
              (49
                (format #t "TROPHY: 34 (Buzzed) recieved!~%")
                (trophy-func 34)
                )
              (112
                (format #t "TROPHY: 35 (Totally Buzzed Out!) recieved!~%")
                (trophy-func 35)
                )
              )
            )
          count
          )
        )

      )
    )
  )
  
--]]



--[[ from task-control.dis

$// Function: task-control__task-cstage__method-id-14:	File offset:0x006fdc-0x77e8, Segment:#0+0x5a4c
$
$		.section	".text.GOAL"
$		.align	2
$		.type	.GOAL_task_control__task_cstage__method_id_14,@function
$		.globl	.GOAL_task_control__task_cstage__method_id_14
$
F.GOAL_task_control__task_cstage__method_id_14:	// 'task-control__task-cstage__method-id-14'
     6fdc:	67bdffe0 	daddiu	sp,sp,-32
     6fe0:	ffbf0000 	sd	ra,0(sp)
     6fe4:	ffbe0008 	sd	s8,8(sp)
     6fe8:	0320f025 	move	s8,t9
     6fec:	7fbc0010 	sq	gp,16(sp)
     6ff0:	0080e025 	move	gp,a0
     6ff4:	93830000 	lbu	v1,0(gp)
     6ff8:	14600005 	bnez	v1,0x7010
     6ffc:	02e01825 	move	v1,s7
     7000:	02e01025 	move	v0,s7
     7004:	100001f3 	b	0x77d4
     7008:	00000000 	nop
     700c:	00001825 	move	v1,zero
     7010:	24030007 	li	v1,7
     7014:	df840008 	ld	a0,8(gp)
     7018:	148301bf 	bne	a0,v1,0x7718
     701c:	02e01825 	move	v1,s7
     7020:	2403005d 	li	v1,93
     7024:	93840000 	lbu	a0,0(gp)
     7028:	1483000d 	bne	a0,v1,0x7060
     702c:	02e01825 	move	v1,s7
     7030:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     7034:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7038:	67c567f8 	daddiu	a1,s8,26616	// rel: 0x00d7d4=[string #234]
     703c:	0320f809 	jalr	t9
     7040:	001f1000 	sll	v0,ra,0x0
     7044:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7048:	24040001 	li	a0,1
     704c:	0320f809 	jalr	t9
     7050:	001f1000 	sll	v0,ra,0x0
     7054:	00401825 	move	v1,v0
     7058:	100001af 	b	0x7718
     705c:	00000000 	nop
     7060:	2403000a 	li	v1,10
     7064:	93840000 	lbu	a0,0(gp)
     7068:	1483000d 	bne	a0,v1,0x70a0
     706c:	02e01825 	move	v1,s7
     7070:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     7074:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7078:	67c567c8 	daddiu	a1,s8,26568	// rel: 0x00d7a4=[string #233]
     707c:	0320f809 	jalr	t9
     7080:	001f1000 	sll	v0,ra,0x0
     7084:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7088:	24040002 	li	a0,2
     708c:	0320f809 	jalr	t9
     7090:	001f1000 	sll	v0,ra,0x0
     7094:	00401825 	move	v1,v0
     7098:	1000019f 	b	0x7718
     709c:	00000000 	nop
     70a0:	24030006 	li	v1,6
     70a4:	93840000 	lbu	a0,0(gp)
     70a8:	1483000d 	bne	a0,v1,0x70e0
     70ac:	02e01825 	move	v1,s7
     70b0:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     70b4:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     70b8:	67c56798 	daddiu	a1,s8,26520	// rel: 0x00d774=[string #232]
     70bc:	0320f809 	jalr	t9
     70c0:	001f1000 	sll	v0,ra,0x0
     70c4:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     70c8:	24040003 	li	a0,3
     70cc:	0320f809 	jalr	t9
     70d0:	001f1000 	sll	v0,ra,0x0
     70d4:	00401825 	move	v1,v0
     70d8:	1000018f 	b	0x7718
     70dc:	00000000 	nop
     70e0:	24030003 	li	v1,3
     70e4:	93840000 	lbu	a0,0(gp)
     70e8:	1483000d 	bne	a0,v1,0x7120
     70ec:	02e01825 	move	v1,s7
     70f0:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     70f4:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     70f8:	67c56758 	daddiu	a1,s8,26456	// rel: 0x00d734=[string #231]
     70fc:	0320f809 	jalr	t9
     7100:	001f1000 	sll	v0,ra,0x0
     7104:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7108:	24040004 	li	a0,4
     710c:	0320f809 	jalr	t9
     7110:	001f1000 	sll	v0,ra,0x0
     7114:	00401825 	move	v1,v0
     7118:	1000017f 	b	0x7718
     711c:	00000000 	nop
     7120:	24030005 	li	v1,5
     7124:	93840000 	lbu	a0,0(gp)
     7128:	1483000d 	bne	a0,v1,0x7160
     712c:	02e01825 	move	v1,s7
     7130:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     7134:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7138:	67c56718 	daddiu	a1,s8,26392	// rel: 0x00d6f4=[string #230]
     713c:	0320f809 	jalr	t9
     7140:	001f1000 	sll	v0,ra,0x0
     7144:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7148:	24040005 	li	a0,5
     714c:	0320f809 	jalr	t9
     7150:	001f1000 	sll	v0,ra,0x0
     7154:	00401825 	move	v1,v0
     7158:	1000016f 	b	0x7718
     715c:	00000000 	nop
     7160:	24030010 	li	v1,16
     7164:	93840000 	lbu	a0,0(gp)
     7168:	1483000d 	bne	a0,v1,0x71a0
     716c:	02e01825 	move	v1,s7
     7170:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     7174:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7178:	67c566e8 	daddiu	a1,s8,26344	// rel: 0x00d6c4=[string #229]
     717c:	0320f809 	jalr	t9
     7180:	001f1000 	sll	v0,ra,0x0
     7184:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7188:	24040006 	li	a0,6
     718c:	0320f809 	jalr	t9
     7190:	001f1000 	sll	v0,ra,0x0
     7194:	00401825 	move	v1,v0
     7198:	1000015f 	b	0x7718
     719c:	00000000 	nop
     71a0:	24030011 	li	v1,17
     71a4:	93840000 	lbu	a0,0(gp)
     71a8:	1483000d 	bne	a0,v1,0x71e0
     71ac:	02e01825 	move	v1,s7
     71b0:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     71b4:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     71b8:	67c566b8 	daddiu	a1,s8,26296	// rel: 0x00d694=[string #228]
     71bc:	0320f809 	jalr	t9
     71c0:	001f1000 	sll	v0,ra,0x0
     71c4:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     71c8:	24040007 	li	a0,7
     71cc:	0320f809 	jalr	t9
     71d0:	001f1000 	sll	v0,ra,0x0
     71d4:	00401825 	move	v1,v0
     71d8:	1000014f 	b	0x7718
     71dc:	00000000 	nop
     71e0:	2403001b 	li	v1,27
     71e4:	93840000 	lbu	a0,0(gp)
     71e8:	1483000d 	bne	a0,v1,0x7220
     71ec:	02e01825 	move	v1,s7
     71f0:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     71f4:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     71f8:	67c56678 	daddiu	a1,s8,26232	// rel: 0x00d654=[string #227]
     71fc:	0320f809 	jalr	t9
     7200:	001f1000 	sll	v0,ra,0x0
     7204:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7208:	24040008 	li	a0,8
     720c:	0320f809 	jalr	t9
     7210:	001f1000 	sll	v0,ra,0x0
     7214:	00401825 	move	v1,v0
     7218:	1000013f 	b	0x7718
     721c:	00000000 	nop
     7220:	24030019 	li	v1,25
     7224:	93840000 	lbu	a0,0(gp)
     7228:	1483000d 	bne	a0,v1,0x7260
     722c:	02e01825 	move	v1,s7
     7230:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     7234:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7238:	67c56638 	daddiu	a1,s8,26168	// rel: 0x00d614=[string #226]
     723c:	0320f809 	jalr	t9
     7240:	001f1000 	sll	v0,ra,0x0
     7244:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7248:	24040009 	li	a0,9
     724c:	0320f809 	jalr	t9
     7250:	001f1000 	sll	v0,ra,0x0
     7254:	00401825 	move	v1,v0
     7258:	1000012f 	b	0x7718
     725c:	00000000 	nop
     7260:	24030045 	li	v1,69
     7264:	93840000 	lbu	a0,0(gp)
     7268:	1483000d 	bne	a0,v1,0x72a0
     726c:	02e01825 	move	v1,s7
     7270:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     7274:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7278:	67c56608 	daddiu	a1,s8,26120	// rel: 0x00d5e4=[string #225]
     727c:	0320f809 	jalr	t9
     7280:	001f1000 	sll	v0,ra,0x0
     7284:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7288:	2404000a 	li	a0,10
     728c:	0320f809 	jalr	t9
     7290:	001f1000 	sll	v0,ra,0x0
     7294:	00401825 	move	v1,v0
     7298:	1000011f 	b	0x7718
     729c:	00000000 	nop
     72a0:	24030035 	li	v1,53
     72a4:	93840000 	lbu	a0,0(gp)
     72a8:	1483000d 	bne	a0,v1,0x72e0
     72ac:	02e01825 	move	v1,s7
     72b0:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     72b4:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     72b8:	67c565c8 	daddiu	a1,s8,26056	// rel: 0x00d5a4=[string #224]
     72bc:	0320f809 	jalr	t9
     72c0:	001f1000 	sll	v0,ra,0x0
     72c4:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     72c8:	2404000b 	li	a0,11
     72cc:	0320f809 	jalr	t9
     72d0:	001f1000 	sll	v0,ra,0x0
     72d4:	00401825 	move	v1,v0
     72d8:	1000010f 	b	0x7718
     72dc:	00000000 	nop
     72e0:	24030037 	li	v1,55
     72e4:	93840000 	lbu	a0,0(gp)
     72e8:	1483000d 	bne	a0,v1,0x7320
     72ec:	02e01825 	move	v1,s7
     72f0:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     72f4:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     72f8:	67c56598 	daddiu	a1,s8,26008	// rel: 0x00d574=[string #223]
     72fc:	0320f809 	jalr	t9
     7300:	001f1000 	sll	v0,ra,0x0
     7304:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7308:	2404000c 	li	a0,12
     730c:	0320f809 	jalr	t9
     7310:	001f1000 	sll	v0,ra,0x0
     7314:	00401825 	move	v1,v0
     7318:	100000ff 	b	0x7718
     731c:	00000000 	nop
     7320:	2403003a 	li	v1,58
     7324:	93840000 	lbu	a0,0(gp)
     7328:	1483000d 	bne	a0,v1,0x7360
     732c:	02e01825 	move	v1,s7
     7330:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     7334:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7338:	67c56568 	daddiu	a1,s8,25960	// rel: 0x00d544=[string #222]
     733c:	0320f809 	jalr	t9
     7340:	001f1000 	sll	v0,ra,0x0
     7344:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7348:	2404000d 	li	a0,13
     734c:	0320f809 	jalr	t9
     7350:	001f1000 	sll	v0,ra,0x0
     7354:	00401825 	move	v1,v0
     7358:	100000ef 	b	0x7718
     735c:	00000000 	nop
     7360:	2403003b 	li	v1,59
     7364:	93840000 	lbu	a0,0(gp)
     7368:	1483000d 	bne	a0,v1,0x73a0
     736c:	02e01825 	move	v1,s7
     7370:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     7374:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7378:	67c56528 	daddiu	a1,s8,25896	// rel: 0x00d504=[string #221]
     737c:	0320f809 	jalr	t9
     7380:	001f1000 	sll	v0,ra,0x0
     7384:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7388:	2404000e 	li	a0,14
     738c:	0320f809 	jalr	t9
     7390:	001f1000 	sll	v0,ra,0x0
     7394:	00401825 	move	v1,v0
     7398:	100000df 	b	0x7718
     739c:	00000000 	nop
     73a0:	24030034 	li	v1,52
     73a4:	93840000 	lbu	a0,0(gp)
     73a8:	1483000d 	bne	a0,v1,0x73e0
     73ac:	02e01825 	move	v1,s7
     73b0:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     73b4:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     73b8:	67c564f8 	daddiu	a1,s8,25848	// rel: 0x00d4d4=[string #220]
     73bc:	0320f809 	jalr	t9
     73c0:	001f1000 	sll	v0,ra,0x0
     73c4:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     73c8:	2404000f 	li	a0,15
     73cc:	0320f809 	jalr	t9
     73d0:	001f1000 	sll	v0,ra,0x0
     73d4:	00401825 	move	v1,v0
     73d8:	100000cf 	b	0x7718
     73dc:	00000000 	nop
     73e0:	24030026 	li	v1,38
     73e4:	93840000 	lbu	a0,0(gp)
     73e8:	1483000d 	bne	a0,v1,0x7420
     73ec:	02e01825 	move	v1,s7
     73f0:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     73f4:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     73f8:	67c564b8 	daddiu	a1,s8,25784	// rel: 0x00d494=[string #219]
     73fc:	0320f809 	jalr	t9
     7400:	001f1000 	sll	v0,ra,0x0
     7404:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7408:	24040010 	li	a0,16
     740c:	0320f809 	jalr	t9
     7410:	001f1000 	sll	v0,ra,0x0
     7414:	00401825 	move	v1,v0
     7418:	100000bf 	b	0x7718
     741c:	00000000 	nop
     7420:	24030024 	li	v1,36
     7424:	93840000 	lbu	a0,0(gp)
     7428:	1483000d 	bne	a0,v1,0x7460
     742c:	02e01825 	move	v1,s7
     7430:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     7434:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7438:	67c56488 	daddiu	a1,s8,25736	// rel: 0x00d464=[string #218]
     743c:	0320f809 	jalr	t9
     7440:	001f1000 	sll	v0,ra,0x0
     7444:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7448:	24040011 	li	a0,17
     744c:	0320f809 	jalr	t9
     7450:	001f1000 	sll	v0,ra,0x0
     7454:	00401825 	move	v1,v0
     7458:	100000af 	b	0x7718
     745c:	00000000 	nop
     7460:	24030068 	li	v1,104
     7464:	93840000 	lbu	a0,0(gp)
     7468:	1483000d 	bne	a0,v1,0x74a0
     746c:	02e01825 	move	v1,s7
     7470:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     7474:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7478:	67c56448 	daddiu	a1,s8,25672	// rel: 0x00d424=[string #217]
     747c:	0320f809 	jalr	t9
     7480:	001f1000 	sll	v0,ra,0x0
     7484:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7488:	24040012 	li	a0,18
     748c:	0320f809 	jalr	t9
     7490:	001f1000 	sll	v0,ra,0x0
     7494:	00401825 	move	v1,v0
     7498:	1000009f 	b	0x7718
     749c:	00000000 	nop
     74a0:	24030057 	li	v1,87
     74a4:	93840000 	lbu	a0,0(gp)
     74a8:	1483000d 	bne	a0,v1,0x74e0
     74ac:	02e01825 	move	v1,s7
     74b0:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     74b4:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     74b8:	67c56418 	daddiu	a1,s8,25624	// rel: 0x00d3f4=[string #216]
     74bc:	0320f809 	jalr	t9
     74c0:	001f1000 	sll	v0,ra,0x0
     74c4:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     74c8:	24040013 	li	a0,19
     74cc:	0320f809 	jalr	t9
     74d0:	001f1000 	sll	v0,ra,0x0
     74d4:	00401825 	move	v1,v0
     74d8:	1000008f 	b	0x7718
     74dc:	00000000 	nop
     74e0:	24030056 	li	v1,86
     74e4:	93840000 	lbu	a0,0(gp)
     74e8:	1483000d 	bne	a0,v1,0x7520
     74ec:	02e01825 	move	v1,s7
     74f0:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     74f4:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     74f8:	67c563e8 	daddiu	a1,s8,25576	// rel: 0x00d3c4=[string #215]
     74fc:	0320f809 	jalr	t9
     7500:	001f1000 	sll	v0,ra,0x0
     7504:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7508:	24040014 	li	a0,20
     750c:	0320f809 	jalr	t9
     7510:	001f1000 	sll	v0,ra,0x0
     7514:	00401825 	move	v1,v0
     7518:	1000007f 	b	0x7718
     751c:	00000000 	nop
     7520:	2403004f 	li	v1,79
     7524:	93840000 	lbu	a0,0(gp)
     7528:	1483000d 	bne	a0,v1,0x7560
     752c:	02e01825 	move	v1,s7
     7530:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     7534:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7538:	67c563b8 	daddiu	a1,s8,25528	// rel: 0x00d394=[string #214]
     753c:	0320f809 	jalr	t9
     7540:	001f1000 	sll	v0,ra,0x0
     7544:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7548:	24040015 	li	a0,21
     754c:	0320f809 	jalr	t9
     7550:	001f1000 	sll	v0,ra,0x0
     7554:	00401825 	move	v1,v0
     7558:	1000006f 	b	0x7718
     755c:	00000000 	nop
     7560:	24030040 	li	v1,64
     7564:	93840000 	lbu	a0,0(gp)
     7568:	1483000d 	bne	a0,v1,0x75a0
     756c:	02e01825 	move	v1,s7
     7570:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     7574:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7578:	67c56378 	daddiu	a1,s8,25464	// rel: 0x00d354=[string #213]
     757c:	0320f809 	jalr	t9
     7580:	001f1000 	sll	v0,ra,0x0
     7584:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7588:	24040016 	li	a0,22
     758c:	0320f809 	jalr	t9
     7590:	001f1000 	sll	v0,ra,0x0
     7594:	00401825 	move	v1,v0
     7598:	1000005f 	b	0x7718
     759c:	00000000 	nop
     75a0:	2403003d 	li	v1,61
     75a4:	93840000 	lbu	a0,0(gp)
     75a8:	1483000d 	bne	a0,v1,0x75e0
     75ac:	02e01825 	move	v1,s7
     75b0:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     75b4:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     75b8:	67c56338 	daddiu	a1,s8,25400	// rel: 0x00d314=[string #212]
     75bc:	0320f809 	jalr	t9
     75c0:	001f1000 	sll	v0,ra,0x0
     75c4:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     75c8:	24040017 	li	a0,23
     75cc:	0320f809 	jalr	t9
     75d0:	001f1000 	sll	v0,ra,0x0
     75d4:	00401825 	move	v1,v0
     75d8:	1000004f 	b	0x7718
     75dc:	00000000 	nop
     75e0:	24030059 	li	v1,89
     75e4:	93840000 	lbu	a0,0(gp)
     75e8:	1483000d 	bne	a0,v1,0x7620
     75ec:	02e01825 	move	v1,s7
     75f0:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     75f4:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     75f8:	67c562f8 	daddiu	a1,s8,25336	// rel: 0x00d2d4=[string #211]
     75fc:	0320f809 	jalr	t9
     7600:	001f1000 	sll	v0,ra,0x0
     7604:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7608:	24040018 	li	a0,24
     760c:	0320f809 	jalr	t9
     7610:	001f1000 	sll	v0,ra,0x0
     7614:	00401825 	move	v1,v0
     7618:	1000003f 	b	0x7718
     761c:	00000000 	nop
     7620:	24030048 	li	v1,72
     7624:	93840000 	lbu	a0,0(gp)
     7628:	1483000d 	bne	a0,v1,0x7660
     762c:	02e01825 	move	v1,s7
     7630:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     7634:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7638:	67c562c8 	daddiu	a1,s8,25288	// rel: 0x00d2a4=[string #210]
     763c:	0320f809 	jalr	t9
     7640:	001f1000 	sll	v0,ra,0x0
     7644:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7648:	24040019 	li	a0,25
     764c:	0320f809 	jalr	t9
     7650:	001f1000 	sll	v0,ra,0x0
     7654:	00401825 	move	v1,v0
     7658:	1000002f 	b	0x7718
     765c:	00000000 	nop
     7660:	24030047 	li	v1,71
     7664:	93840000 	lbu	a0,0(gp)
     7668:	1483000d 	bne	a0,v1,0x76a0
     766c:	02e01825 	move	v1,s7
     7670:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     7674:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7678:	67c56288 	daddiu	a1,s8,25224	// rel: 0x00d264=[string #209]
     767c:	0320f809 	jalr	t9
     7680:	001f1000 	sll	v0,ra,0x0
     7684:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7688:	2404001a 	li	a0,26
     768c:	0320f809 	jalr	t9
     7690:	001f1000 	sll	v0,ra,0x0
     7694:	00401825 	move	v1,v0
     7698:	1000001f 	b	0x7718
     769c:	00000000 	nop
     76a0:	24030049 	li	v1,73
     76a4:	93840000 	lbu	a0,0(gp)
     76a8:	1483000d 	bne	a0,v1,0x76e0
     76ac:	02e01825 	move	v1,s7
     76b0:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     76b4:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     76b8:	67c56248 	daddiu	a1,s8,25160	// rel: 0x00d224=[string #208]
     76bc:	0320f809 	jalr	t9
     76c0:	001f1000 	sll	v0,ra,0x0
     76c4:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     76c8:	2404001b 	li	a0,27
     76cc:	0320f809 	jalr	t9
     76d0:	001f1000 	sll	v0,ra,0x0
     76d4:	00401825 	move	v1,v0
     76d8:	1000000f 	b	0x7718
     76dc:	00000000 	nop
     76e0:	24030046 	li	v1,70
     76e4:	93840000 	lbu	a0,0(gp)
     76e8:	1483000b 	bne	a0,v1,0x7718
     76ec:	02e01825 	move	v1,s7
     76f0:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     76f4:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     76f8:	67c56208 	daddiu	a1,s8,25096	// rel: 0x00d1e4=[string #207]
     76fc:	0320f809 	jalr	t9
     7700:	001f1000 	sll	v0,ra,0x0
     7704:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7708:	2404001c 	li	a0,28
     770c:	0320f809 	jalr	t9
     7710:	001f1000 	sll	v0,ra,0x0
     7714:	00401825 	move	v1,v0
     7718:	df830008 	ld	v1,8(gp)
     771c:	6463fffc 	daddiu	v1,v1,-4
     7720:	66e40008 	daddiu	a0,s7,8
     7724:	02e3200b 	movn	a0,s7,v1
     7728:	52e40005 	beql	s7,a0,0x7740
     772c:	00801825 	move	v1,a0
     7730:	93830000 	lbu	v1,0(gp)
     7734:	6464ff90 	daddiu	a0,v1,-112
     7738:	66e30008 	daddiu	v1,s7,8
     773c:	02e4180b 	movn	v1,s7,a0
     7740:	12e3000b 	beq	s7,v1,0x7770
     7744:	02e01825 	move	v1,s7
     7748:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     774c:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     7750:	67c561c8 	daddiu	a1,s8,25032	// rel: 0x00d1a4=[string #206]
     7754:	0320f809 	jalr	t9
     7758:	001f1000 	sll	v0,ra,0x0
     775c:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     7760:	2404001d 	li	a0,29
     7764:	0320f809 	jalr	t9
     7768:	001f1000 	sll	v0,ra,0x0
     776c:	00401825 	move	v1,v0
     7770:	93830010 	lbu	v1,16(gp)
     7774:	34630001 	ori	v1,v1,0x1
     7778:	a3830010 	sb	v1,16(gp)
     777c:	93830010 	lbu	v1,16(gp)
     7780:	30630002 	andi	v1,v1,0x2
     7784:	10600012 	beqz	v1,0x77d0
     7788:	02e01825 	move	v1,s7
     778c:	8ee40598 	lw	a0,1432(s7)	// sym: '*game-info*'
     7790:	9c83fffc 	lwu	v1,-4(a0)
     7794:	9c790044 	lwu	t9,68(v1)
     7798:	93850000 	lbu	a1,0(gp)
     779c:	0320f809 	jalr	t9
     77a0:	001f1000 	sll	v0,ra,0x0
     77a4:	00401825 	move	v1,v0
     77a8:	94640008 	lhu	a0,8(v1)
     77ac:	34840020 	ori	a0,a0,0x20
     77b0:	a4640008 	sh	a0,8(v1)
     77b4:	90640000 	lbu	a0,0(v1)
     77b8:	df850008 	ld	a1,8(gp)
     77bc:	0085202b 	sltu	a0,a0,a1
     77c0:	10800003 	beqz	a0,0x77d0
     77c4:	02e02025 	move	a0,s7
     77c8:	df840008 	ld	a0,8(gp)
     77cc:	a0640000 	sb	a0,0(v1)
     77d0:	00001025 	move	v0,zero
     77d4:	dfbf0000 	ld	ra,0(sp)
     77d8:	dfbe0008 	ld	s8,8(sp)
     77dc:	7bbc0010 	lq	gp,16(sp)
     77e0:	03e00008 	jr	ra
     77e4:	67bd0020 	daddiu	sp,sp,32
	 
--]]
	
--[[ from game-info.dis

$// Function: game-info__game-info__method-id-10:	File offset:0x001f5c-0x26bc, Segment:#0+0x142c
$
$		.section	".text.GOAL"
$		.align	2
$		.type	.GOAL_game_info__game_info__method_id_10,@function
$		.globl	.GOAL_game_info__game_info__method_id_10
$
F.GOAL_game_info__game_info__method_id_10:	// 'game-info__game-info__method-id-10'
     1f5c:	67bdff90 	daddiu	sp,sp,-112
     1f60:	ffbf0000 	sd	ra,0(sp)
     1f64:	ffbe0008 	sd	s8,8(sp)
     1f68:	0320f025 	move	s8,t9
     1f6c:	7fb20010 	sq	s2,16(sp)
     1f70:	7fb30020 	sq	s3,32(sp)
     1f74:	7fb40030 	sq	s4,48(sp)
     1f78:	7fb50040 	sq	s5,64(sp)
     1f7c:	7fbc0050 	sq	gp,80(sp)
     1f80:	e7be0060 	swc1	$f30,96(sp)
     1f84:	0080e025 	move	gp,a0
     1f88:	00c0a825 	move	s5,a2
     1f8c:	00e0a025 	move	s4,a3
     1f90:	00a01825 	move	v1,a1
     1f94:	66e45780 	daddiu	a0,s7,22400	// sym: 'life'
     1f98:	14640023 	bne	v1,a0,0x2028
     1f9c:	02e02025 	move	a0,s7
     1fa0:	44950000 	mtc1	s5,$f0
     1fa4:	44800800 	mtc1	zero,$f1
     1fa8:	46010034 	c.olt.s	$f0,$f1
     1fac:	4501000e 	bc1t	0x1fe8
     1fb0:	00000000 	nop
     1fb4:	8ef91390 	lw	t9,5008(s7)	// sym: 'seek'
     1fb8:	c7800008 	lwc1	$f0,8(gp)
     1fbc:	44040000 	mfc1	a0,$f0
     1fc0:	c780000c 	lwc1	$f0,12(gp)
     1fc4:	44050000 	mfc1	a1,$f0
     1fc8:	02a03025 	move	a2,s5
     1fcc:	0320f809 	jalr	t9
     1fd0:	001f1000 	sll	v0,ra,0x0
     1fd4:	44820000 	mtc1	v0,$f0
     1fd8:	e7800008 	swc1	$f0,8(gp)
     1fdc:	44030000 	mfc1	v1,$f0
     1fe0:	1000000d 	b	0x2018
     1fe4:	00000000 	nop
     1fe8:	8ef91390 	lw	t9,5008(s7)	// sym: 'seek'
     1fec:	c7800008 	lwc1	$f0,8(gp)
     1ff0:	44040000 	mfc1	a0,$f0
     1ff4:	8fc51510 	lw	a1,5392(s8)
     1ff8:	44950000 	mtc1	s5,$f0
     1ffc:	46000007 	neg.s	$f0,$f0
     2000:	44060000 	mfc1	a2,$f0
     2004:	0320f809 	jalr	t9
     2008:	001f1000 	sll	v0,ra,0x0
     200c:	44820000 	mtc1	v0,$f0
     2010:	e7800008 	swc1	$f0,8(gp)
     2014:	44030000 	mfc1	v1,$f0
     2018:	c7800008 	lwc1	$f0,8(gp)
     201c:	44020000 	mfc1	v0,$f0
     2020:	1000019c 	b	0x2694
     2024:	00000000 	nop
     2028:	66e439e8 	daddiu	a0,s7,14824	// sym: 'money'
     202c:	1464009c 	bne	v1,a0,0x22a0
     2030:	02e02025 	move	a0,s7
     2034:	44800000 	mtc1	zero,$f0
     2038:	44950800 	mtc1	s5,$f1
     203c:	46010034 	c.olt.s	$f0,$f1
     2040:	45010002 	bc1t	0x204c
     2044:	66e30008 	daddiu	v1,s7,8
     2048:	02e01825 	move	v1,s7
     204c:	52e3000a 	beql	s7,v1,0x2078
     2050:	00601825 	move	v1,v1
     2054:	c7800010 	lwc1	$f0,16(gp)
     2058:	44950800 	mtc1	s5,$f1
     205c:	46010000 	add.s	$f0,$f0,$f1
     2060:	8ee34a10 	lw	v1,18960(s7)	// sym: '*GAME-bank*'
     2064:	c461000c 	lwc1	$f1,12(v1)
     2068:	46010032 	c.eq.s	$f0,$f1
     206c:	45010002 	bc1t	0x2078
     2070:	66e30008 	daddiu	v1,s7,8
     2074:	02e01825 	move	v1,s7
     2078:	12e3000a 	beq	s7,v1,0x20a4
     207c:	02e01825 	move	v1,s7
     2080:	8ef90700 	lw	t9,1792(s7)	// sym: 'level-hint-spawn'
     2084:	24040233 	li	a0,563
     2088:	67c513c8 	daddiu	a1,s8,5064	// rel: 0x003324=[string #10]
     208c:	02e03025 	move	a2,s7
     2090:	8ee70d10 	lw	a3,3344(s7)	// sym: '*entity-pool*'
     2094:	24080000 	li	a4,0
     2098:	0320f809 	jalr	t9
     209c:	001f1000 	sll	v0,ra,0x0
     20a0:	00401825 	move	v1,v0
     20a4:	44800000 	mtc1	zero,$f0
     20a8:	44950800 	mtc1	s5,$f1
     20ac:	46010034 	c.olt.s	$f0,$f1
     20b0:	4500003f 	bc1f	0x21b0
     20b4:	02e01825 	move	v1,s7
     20b8:	02971823 	subu	v1,s4,s7
     20bc:	50600009 	beqzl	v1,0x20e4
     20c0:	02e01825 	move	v1,s7
     20c4:	00141804 	sllv	v1,s4,zero
     20c8:	9c640000 	lwu	a0,0(v1)
     20cc:	8c830024 	lw	v1,36(a0)
     20d0:	0014283f 	dsra32	a1,s4,0x0
     20d4:	14a30002 	bne	a1,v1,0x20e0
     20d8:	02e01825 	move	v1,s7
     20dc:	00801825 	move	v1,a0
     20e0:	00602025 	move	a0,v1
     20e4:	52e30002 	beql	s7,v1,0x20f0
     20e8:	00602025 	move	a0,v1
     20ec:	9c640030 	lwu	a0,48(v1)
     20f0:	12e4002f 	beq	s7,a0,0x21b0
     20f4:	02e02025 	move	a0,s7
     20f8:	8ee45f48 	lw	a0,24392(s7)	// sym: '*level-task-data-remap*'
     20fc:	8c840000 	lw	a0,0(a0)
     2100:	9c650030 	lwu	a1,48(v1)
     2104:	9ca50014 	lwu	a1,20(a1)
     2108:	9ca50010 	lwu	a1,16(a1)
     210c:	9ca50034 	lwu	a1,52(a1)
     2110:	8ca5000c 	lw	a1,12(a1)
     2114:	0085202a 	slt	a0,a0,a1
     2118:	14800025 	bnez	a0,0x21b0
     211c:	02e02025 	move	a0,s7
     2120:	9c630030 	lwu	v1,48(v1)
     2124:	9c630014 	lwu	v1,20(v1)
     2128:	9c630010 	lwu	v1,16(v1)
     212c:	9c630034 	lwu	v1,52(v1)
     2130:	8c63000c 	lw	v1,12(v1)
     2134:	6463ffff 	daddiu	v1,v1,-1
     2138:	000318b8 	dsll	v1,v1,0x2
     213c:	8ee45f48 	lw	a0,24392(s7)	// sym: '*level-task-data-remap*'
     2140:	0064182d 	daddu	v1,v1,a0
     2144:	8c74000c 	lw	s4,12(v1)
     2148:	029c182d 	daddu	v1,s4,gp
     214c:	90630018 	lbu	v1,24(v1)
     2150:	44950000 	mtc1	s5,$f0
     2154:	46000024 	cvt.w.s	$f0,$f0
     2158:	44040000 	mfc1	a0,$f0
     215c:	0064182d 	daddu	v1,v1,a0
     2160:	029c202d 	daddu	a0,s4,gp
     2164:	a0830018 	sb	v1,24(a0)
     2168:	c7800014 	lwc1	$f0,20(gp)
     216c:	44950800 	mtc1	s5,$f1
     2170:	46010000 	add.s	$f0,$f0,$f1
     2174:	e7800014 	swc1	$f0,20(gp)
     2178:	8ef95f38 	lw	t9,24376(s7)	// sym: 'get-game-count'
     217c:	02802025 	move	a0,s4
     2180:	0320f809 	jalr	t9
     2184:	001f1000 	sll	v0,ra,0x0
     2188:	8c430000 	lw	v1,0(v0)
     218c:	029c202d 	daddu	a0,s4,gp
     2190:	90840018 	lbu	a0,24(a0)
     2194:	14830006 	bne	a0,v1,0x21b0
     2198:	02e02025 	move	a0,s7
     219c:	8ef95f50 	lw	t9,24400(s7)	// sym: 'activate-orb-all'
     21a0:	02802025 	move	a0,s4
     21a4:	0320f809 	jalr	t9
     21a8:	001f1000 	sll	v0,ra,0x0
     21ac:	00402025 	move	a0,v0
     21b0:	c7800010 	lwc1	$f0,16(gp)
     21b4:	44950800 	mtc1	s5,$f1
     21b8:	46010000 	add.s	$f0,$f0,$f1
     21bc:	e7800010 	swc1	$f0,16(gp)
     21c0:	44800000 	mtc1	zero,$f0
     21c4:	44950800 	mtc1	s5,$f1
     21c8:	46010034 	c.olt.s	$f0,$f1
     21cc:	45000030 	bc1f	0x2290
     21d0:	02e01825 	move	v1,s7
     21d4:	c7800014 	lwc1	$f0,20(gp)
     21d8:	c7c114f8 	lwc1	$f1,5368(s8)
     21dc:	46010032 	c.eq.s	$f0,$f1
     21e0:	4500000d 	bc1f	0x2218
     21e4:	02e01825 	move	v1,s7
     21e8:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     21ec:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     21f0:	67c51398 	daddiu	a1,s8,5016	// rel: 0x0032f4=[string #9]
     21f4:	0320f809 	jalr	t9
     21f8:	001f1000 	sll	v0,ra,0x0
     21fc:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     2200:	24040024 	li	a0,36
     2204:	0320f809 	jalr	t9
     2208:	001f1000 	sll	v0,ra,0x0
     220c:	00401825 	move	v1,v0
     2210:	1000001f 	b	0x2290
     2214:	00000000 	nop
     2218:	c7c114ec 	lwc1	$f1,5356(s8)
     221c:	46010032 	c.eq.s	$f0,$f1
     2220:	4500000d 	bc1f	0x2258
     2224:	02e01825 	move	v1,s7
     2228:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     222c:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     2230:	67c51368 	daddiu	a1,s8,4968	// rel: 0x0032c4=[string #8]
     2234:	0320f809 	jalr	t9
     2238:	001f1000 	sll	v0,ra,0x0
     223c:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     2240:	24040025 	li	a0,37
     2244:	0320f809 	jalr	t9
     2248:	001f1000 	sll	v0,ra,0x0
     224c:	00401825 	move	v1,v0
     2250:	1000000f 	b	0x2290
     2254:	00000000 	nop
     2258:	c7c114e8 	lwc1	$f1,5352(s8)
     225c:	46010032 	c.eq.s	$f0,$f1
     2260:	4500000b 	bc1f	0x2290
     2264:	02e01825 	move	v1,s7
     2268:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     226c:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     2270:	67c51328 	daddiu	a1,s8,4904	// rel: 0x003284=[string #7]
     2274:	0320f809 	jalr	t9
     2278:	001f1000 	sll	v0,ra,0x0
     227c:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     2280:	24040026 	li	a0,38
     2284:	0320f809 	jalr	t9
     2288:	001f1000 	sll	v0,ra,0x0
     228c:	00401825 	move	v1,v0
     2290:	c7800010 	lwc1	$f0,16(gp)
     2294:	44020000 	mfc1	v0,$f0
     2298:	100000fe 	b	0x2694
     229c:	00000000 	nop
     22a0:	66e41948 	daddiu	a0,s7,6472	// sym: 'fuel-cell'
     22a4:	1464006d 	bne	v1,a0,0x245c
     22a8:	02e02025 	move	a0,s7
     22ac:	44950000 	mtc1	s5,$f0
     22b0:	46000024 	cvt.w.s	$f0,$f0
     22b4:	44140000 	mfc1	s4,$f0
     22b8:	03802025 	move	a0,gp
     22bc:	9c83fffc 	lwu	v1,-4(a0)
     22c0:	9c79003c 	lwu	t9,60(v1)
     22c4:	02802825 	move	a1,s4
     22c8:	0320f809 	jalr	t9
     22cc:	001f1000 	sll	v0,ra,0x0
     22d0:	00401825 	move	v1,v0
     22d4:	56e30005 	bnel	s7,v1,0x22ec
     22d8:	00601825 	move	v1,v1
     22dc:	24030001 	li	v1,1
     22e0:	0074202b 	sltu	a0,v1,s4
     22e4:	66e30008 	daddiu	v1,s7,8
     22e8:	02e4180b 	movn	v1,s7,a0
     22ec:	16e30023 	bne	s7,v1,0x237c
     22f0:	02e01825 	move	v1,s7
     22f4:	af8000a0 	sw	zero,160(gp)
     22f8:	8ee30348 	lw	v1,840(s7)	// sym: '*display*'
     22fc:	dc63030c 	ld	v1,780(v1)
     2300:	ff8300c4 	sd	v1,196(gp)
     2304:	8ee30348 	lw	v1,840(s7)	// sym: '*display*'
     2308:	dc63030c 	ld	v1,780(v1)
     230c:	001420f8 	dsll	a0,s4,0x3
     2310:	9f8500cc 	lwu	a1,204(gp)
     2314:	0085202d 	daddu	a0,a0,a1
     2318:	fc83000c 	sd	v1,12(a0)
     231c:	c7c01508 	lwc1	$f0,5384(s8)
     2320:	c781005c 	lwc1	$f1,92(gp)
     2324:	46010000 	add.s	$f0,$f0,$f1
     2328:	e780005c 	swc1	$f0,92(gp)
     232c:	9f830064 	lwu	v1,100(gp)
     2330:	00142138 	dsll	a0,s4,0x4
     2334:	0064182d 	daddu	v1,v1,a0
     2338:	94630014 	lhu	v1,20(v1)
     233c:	34630100 	ori	v1,v1,0x100
     2340:	9f840064 	lwu	a0,100(gp)
     2344:	00142938 	dsll	a1,s4,0x4
     2348:	0085202d 	daddu	a0,a0,a1
     234c:	a4830014 	sh	v1,20(a0)
     2350:	8ef90cf8 	lw	t9,3320(s7)	// sym: 'get-task-control'
     2354:	02802025 	move	a0,s4
     2358:	0320f809 	jalr	t9
     235c:	001f1000 	sll	v0,ra,0x0
     2360:	00401825 	move	v1,v0
     2364:	8ef90590 	lw	t9,1424(s7)	// sym: 'close-specific-task!'
     2368:	24050007 	li	a1,7
     236c:	02802025 	move	a0,s4
     2370:	0320f809 	jalr	t9
     2374:	001f1000 	sll	v0,ra,0x0
     2378:	00401825 	move	v1,v0
     237c:	44800000 	mtc1	zero,$f0
     2380:	44950800 	mtc1	s5,$f1
     2384:	46010034 	c.olt.s	$f0,$f1
     2388:	45000030 	bc1f	0x244c
     238c:	02e01825 	move	v1,s7
     2390:	c780005c 	lwc1	$f0,92(gp)
     2394:	c7c114fc 	lwc1	$f1,5372(s8)
     2398:	46010032 	c.eq.s	$f0,$f1
     239c:	4500000d 	bc1f	0x23d4
     23a0:	02e01825 	move	v1,s7
     23a4:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     23a8:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     23ac:	67c512f8 	daddiu	a1,s8,4856	// rel: 0x003254=[string #6]
     23b0:	0320f809 	jalr	t9
     23b4:	001f1000 	sll	v0,ra,0x0
     23b8:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     23bc:	2404001e 	li	a0,30
     23c0:	0320f809 	jalr	t9
     23c4:	001f1000 	sll	v0,ra,0x0
     23c8:	00401825 	move	v1,v0
     23cc:	1000001f 	b	0x244c
     23d0:	00000000 	nop
     23d4:	c7c114f4 	lwc1	$f1,5364(s8)
     23d8:	46010032 	c.eq.s	$f0,$f1
     23dc:	4500000d 	bc1f	0x2414
     23e0:	02e01825 	move	v1,s7
     23e4:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     23e8:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     23ec:	67c512c8 	daddiu	a1,s8,4808	// rel: 0x003224=[string #5]
     23f0:	0320f809 	jalr	t9
     23f4:	001f1000 	sll	v0,ra,0x0
     23f8:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     23fc:	2404001f 	li	a0,31
     2400:	0320f809 	jalr	t9
     2404:	001f1000 	sll	v0,ra,0x0
     2408:	00401825 	move	v1,v0
     240c:	1000000f 	b	0x244c
     2410:	00000000 	nop
     2414:	c7c114f0 	lwc1	$f1,5360(s8)
     2418:	46010032 	c.eq.s	$f0,$f1
     241c:	4500000b 	bc1f	0x244c
     2420:	02e01825 	move	v1,s7
     2424:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     2428:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     242c:	67c51298 	daddiu	a1,s8,4760	// rel: 0x0031f4=[string #4]
     2430:	0320f809 	jalr	t9
     2434:	001f1000 	sll	v0,ra,0x0
     2438:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     243c:	24040020 	li	a0,32
     2440:	0320f809 	jalr	t9
     2444:	001f1000 	sll	v0,ra,0x0
     2448:	00401825 	move	v1,v0
     244c:	c780005c 	lwc1	$f0,92(gp)
     2450:	44020000 	mfc1	v0,$f0
     2454:	1000008f 	b	0x2694
     2458:	00000000 	nop
     245c:	66e43a40 	daddiu	a0,s7,14912	// sym: 'buzzer'
     2460:	1464008c 	bne	v1,a0,0x2694
     2464:	02e01025 	move	v0,s7
     2468:	44950000 	mtc1	s5,$f0
     246c:	46000024 	cvt.w.s	$f0,$f0
     2470:	44030000 	mfc1	v1,$f0
     2474:	3064ffff 	andi	a0,v1,0xffff
     2478:	44950000 	mtc1	s5,$f0
     247c:	46000024 	cvt.w.s	$f0,$f0
     2480:	44030000 	mfc1	v1,$f0
     2484:	00039c3b 	dsra	s3,v1,0x10
     2488:	4480f000 	mtc1	zero,$f30
     248c:	0004182b 	sltu	v1,zero,a0
     2490:	1060004b 	beqz	v1,0x25c0
     2494:	02e01825 	move	v1,s7
     2498:	8ef90cf8 	lw	t9,3320(s7)	// sym: 'get-task-control'
     249c:	0320f809 	jalr	t9
     24a0:	001f1000 	sll	v0,ra,0x0
     24a4:	00409025 	move	s2,v0
     24a8:	02402025 	move	a0,s2
     24ac:	9c83fffc 	lwu	v1,-4(a0)
     24b0:	9c790050 	lwu	t9,80(v1)
     24b4:	24050000 	li	a1,0
     24b8:	0320f809 	jalr	t9
     24bc:	001f1000 	sll	v0,ra,0x0
     24c0:	0040a025 	move	s4,v0
     24c4:	0260182a 	slt	v1,s3,zero
     24c8:	66e40008 	daddiu	a0,s7,8
     24cc:	02e3200b 	movn	a0,s7,v1
     24d0:	52e40008 	beql	s7,a0,0x24f4
     24d4:	00801825 	move	v1,a0
     24d8:	8ee313b0 	lw	v1,5040(s7)	// sym: '*FACT-bank*'
     24dc:	c4600034 	lwc1	$f0,52(v1)
     24e0:	46000024 	cvt.w.s	$f0,$f0
     24e4:	44030000 	mfc1	v1,$f0
     24e8:	0263202a 	slt	a0,s3,v1
     24ec:	66e30008 	daddiu	v1,s7,8
     24f0:	02e4180a 	movz	v1,s7,a0
     24f4:	12e3001c 	beq	s7,v1,0x2568
     24f8:	02e01825 	move	v1,s7
     24fc:	24030001 	li	v1,1
     2500:	06630003 	bgezl	s3,0x2510
     2504:	02631814 	dsllv	v1,v1,s3
     2508:	0013202f 	dnegu	a0,s3
     250c:	00831817 	dsrav	v1,v1,a0
     2510:	02831824 	and	v1,s4,v1
     2514:	14600006 	bnez	v1,0x2530
     2518:	02e01825 	move	v1,s7
     251c:	c7c01508 	lwc1	$f0,5384(s8)
     2520:	c7810058 	lwc1	$f1,88(gp)
     2524:	46010000 	add.s	$f0,$f0,$f1
     2528:	e7800058 	swc1	$f0,88(gp)
     252c:	44030000 	mfc1	v1,$f0
     2530:	9e43fffc 	lwu	v1,-4(s2)
     2534:	9c790054 	lwu	t9,84(v1)
     2538:	24030001 	li	v1,1
     253c:	06630003 	bgezl	s3,0x254c
     2540:	02631814 	dsllv	v1,v1,s3
     2544:	0013202f 	dnegu	a0,s3
     2548:	00831817 	dsrav	v1,v1,a0
     254c:	0283a025 	or	s4,s4,v1
     2550:	02802825 	move	a1,s4
     2554:	24060000 	li	a2,0
     2558:	02402025 	move	a0,s2
     255c:	0320f809 	jalr	t9
     2560:	001f1000 	sll	v0,ra,0x0
     2564:	00401825 	move	v1,v0
     2568:	8ee313b0 	lw	v1,5040(s7)	// sym: '*FACT-bank*'
     256c:	c4600034 	lwc1	$f0,52(v1)
     2570:	46000024 	cvt.w.s	$f0,$f0
     2574:	44030000 	mfc1	v1,$f0
     2578:	1000000d 	b	0x25b0
     257c:	00000000 	nop
     2580:	6463ffff 	daddiu	v1,v1,-1
     2584:	24040001 	li	a0,1
     2588:	04630003 	bgezl	v1,0x2598
     258c:	00642014 	dsllv	a0,a0,v1
     2590:	0003282f 	dnegu	a1,v1
     2594:	00a42017 	dsrav	a0,a0,a1
     2598:	02842024 	and	a0,s4,a0
     259c:	10800004 	beqz	a0,0x25b0
     25a0:	02e02025 	move	a0,s7
     25a4:	c7c01508 	lwc1	$f0,5384(s8)
     25a8:	461e0780 	add.s	$f30,$f0,$f30
     25ac:	4404f000 	mfc1	a0,$f30
     25b0:	1460fff3 	bnez	v1,0x2580
     25b4:	00000000 	nop
     25b8:	02e01825 	move	v1,s7
     25bc:	02e01825 	move	v1,s7
     25c0:	44800000 	mtc1	zero,$f0
     25c4:	44950800 	mtc1	s5,$f1
     25c8:	46010034 	c.olt.s	$f0,$f1
     25cc:	45000030 	bc1f	0x2690
     25d0:	02e01825 	move	v1,s7
     25d4:	c7800058 	lwc1	$f0,88(gp)
     25d8:	c7c114e4 	lwc1	$f1,5348(s8)
     25dc:	46010032 	c.eq.s	$f0,$f1
     25e0:	4500000d 	bc1f	0x2618
     25e4:	02e01825 	move	v1,s7
     25e8:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     25ec:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     25f0:	67c51268 	daddiu	a1,s8,4712	// rel: 0x0031c4=[string #3]
     25f4:	0320f809 	jalr	t9
     25f8:	001f1000 	sll	v0,ra,0x0
     25fc:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     2600:	24040021 	li	a0,33
     2604:	0320f809 	jalr	t9
     2608:	001f1000 	sll	v0,ra,0x0
     260c:	00401825 	move	v1,v0
     2610:	1000001f 	b	0x2690
     2614:	00000000 	nop
     2618:	c7c114dc 	lwc1	$f1,5340(s8)
     261c:	46010032 	c.eq.s	$f0,$f1
     2620:	4500000d 	bc1f	0x2658
     2624:	02e01825 	move	v1,s7
     2628:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     262c:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     2630:	67c51238 	daddiu	a1,s8,4664	// rel: 0x003194=[string #2]
     2634:	0320f809 	jalr	t9
     2638:	001f1000 	sll	v0,ra,0x0
     263c:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     2640:	24040022 	li	a0,34
     2644:	0320f809 	jalr	t9
     2648:	001f1000 	sll	v0,ra,0x0
     264c:	00401825 	move	v1,v0
     2650:	1000000f 	b	0x2690
     2654:	00000000 	nop
     2658:	c7c114d8 	lwc1	$f1,5336(s8)
     265c:	46010032 	c.eq.s	$f0,$f1
     2660:	4500000b 	bc1f	0x2690
     2664:	02e01825 	move	v1,s7
     2668:	8ef90228 	lw	t9,552(s7)	// sym: 'format'
     266c:	66e40008 	daddiu	a0,s7,8	// sym: '#t'
     2670:	67c511f8 	daddiu	a1,s8,4600	// rel: 0x003154=[string #1]
     2674:	0320f809 	jalr	t9
     2678:	001f1000 	sll	v0,ra,0x0
     267c:	8ef95f40 	lw	t9,24384(s7)	// sym: 'trophy-func'
     2680:	24040023 	li	a0,35
     2684:	0320f809 	jalr	t9
     2688:	001f1000 	sll	v0,ra,0x0
     268c:	00401825 	move	v1,v0
     2690:	4402f000 	mfc1	v0,$f30
     2694:	dfbf0000 	ld	ra,0(sp)
     2698:	dfbe0008 	ld	s8,8(sp)
     269c:	c7be0060 	lwc1	$f30,96(sp)
     26a0:	7bbc0050 	lq	gp,80(sp)
     26a4:	7bb50040 	lq	s5,64(sp)
     26a8:	7bb40030 	lq	s4,48(sp)
     26ac:	7bb30020 	lq	s3,32(sp)
     26b0:	7bb20010 	lq	s2,16(sp)
     26b4:	03e00008 	jr	ra
     26b8:	67bd0070 	daddiu	sp,sp,112
	 
--]]

--[[###################################################################################################################
#######################################################################################################################

  Version detection (needed for Jak 1 because the actual C code is different between versions)

###################################################################################################################--]]

--Lua     (  10acf8-e cb158bee): --> LOADED SEGMENT alloc_len 000014d0 ver 00000003 segcount 00000003  name:"task-control"    
--Lua     (  10acf8-e cb158bee):     seg1linkptr 017fc0c0 sega1dataptr 008b2730 seg1size 0000b4a0 seg1flags 00000000    
--Lua     (  10acf8-e cb158bee):     seg2linkptr 017fd188 sega2dataptr 00000000 seg2size 00000000 seg2flags 00000000    
--Lua     (  10acf8-e cb158bee):     seg3linkptr 017fd1a8 sega3dataptr 017fbb80 seg3size 00000478 seg3flags 00000000   
	
eeOverlay.AddPostHook("task-control.seg1", 0x5A4C, 0x67BDFFE0, cstageFunc)
eeOverlay.AddPostHook("task-control.seg1", 0x5A78, 0x93830010, cstageFunc2) -- 008B81A8   93830010 lbu         v1,0x0010(gp)

--Lua     (  10acf8-e ba613675): --> LOADED SEGMENT alloc_len 00000ad0 ver 00000003 segcount 00000003  name:"game-info"    
--Lua     (  10acf8-e ba613675):     seg1linkptr 017fc0c0 sega1dataptr 00786970 seg1size 00002508 seg1flags 00000000    
--Lua     (  10acf8-e ba613675):     seg2linkptr 017fc7e6 sega2dataptr 00000000 seg2size 00000000 seg2flags 00000000    
--Lua     (  10acf8-e ba613675):     seg3linkptr 017fc99a sega3dataptr 017fbb60 seg3size 0000049c seg3flags 00000000   

-- 008b2730 base 008B817C function
-- Increase on Precursor Orbs?
-- this is total
eeOverlay.AddPostHook("game-info.seg1", 0x1638, 0x44950800, gameinfoFunc2) -- 00787FA8    mtc1        s5,f1
--eeOverlay.AddPostHook("game-info.seg1", 0x163C, 0x46010000, gameinfoFunc2) -- 00787FAC   46010000 add.s       f0,f0,f1 

-- 1 and 3 are currrent
--[[
eeOverlay.AddPostHook("game-info.seg1", 0x1528, 0x46010000, gameinfoFunc1) -- 00787E98   46010000 add.s       f0,f0,f1   
eeOverlay.AddPostHook("game-info.seg1", 0x1684, 0x46010000, gameinfoFunc3) -- 00787FF4   46010000 add.s       f0,f0,f1 
--]]

-- increase on Power Cells
eeOverlay.AddPostHook("game-info.seg1", 0x1718, 0xC781005C, gameinfoFunc4) -- 00788088   C781005C lwc1        f1,0x005C(gp)
--eeOverlay.AddPostHook("game-info.seg1", 0x171C, 0x46010000, gameinfoFunc4) -- 0078808C   46010000 add.s       f0,f0,f1 

-- increase on Scout Flies
-- this is total
eeOverlay.AddPostHook("game-info.seg1", 0x1848, 0xC7810058, gameinfoFunc5) -- 007881B8   C7810058 lwc1        f1,0x0058(gp)
--eeObj.AddHook(linkblock_allocate_seg1_dataptr + 0x184C, 0x46010000, gameinfoFunc5) -- 007881BC   46010000 add.s       f0,f0,f1  
-- this is current?
--eeObj.AddHook(linkblock_allocate_seg1_dataptr + 0x18D0, 0x461E0780, gameinfoFunc6) -- 00788240   461E0780 add.s       f30,f0,f30  


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


