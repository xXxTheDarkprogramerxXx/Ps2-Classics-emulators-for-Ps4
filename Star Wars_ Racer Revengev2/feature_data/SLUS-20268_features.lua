-- Lua 5.3
-- Title:   Star Wars Racer Revenge PS2 - SLUS-20268 (USA)
-- Author:  Ernesto Corvi

-- Changelog:

apiRequest(0.2)	-- request version 0.2 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()

local L1 =  -- PodUILoadingPage::PodUILoadingPage
	function()
		emuObj.ThrottleMax()
	end
	
local L2 =  -- PodUILoadingPage::~PodUILoadingPage
	function()
		emuObj.ThrottleNorm()
	end
	
local load1 = eeObj.AddHook(0x1ca940, 0x27bdffe0, L1)	-- PodUILoadingPage::PodUILoadingPage
local load2 = eeObj.AddHook(0x1ca980, 0x27bdffd0, L2)	-- PodUILoadingPage::~PodUILoadingPage



-- BUG 9244 - This title exhibits memory allocation problems as described on the
-- PS2 tech note titled "malloc() Issues". Overlay the FullAllocAndFree() and hook it to main()

local overlay_addr = InsnOverlay( {
	0x27bdfff0, --		addiu $sp, -0x10
	0x7fbf0000, --		sq $ra, 0($sp)
	0x0c0c15c0, --  	jal malloc
	0x3c0401e0, --  	lui $a0, 0x01e0
	0x0c0c15ca, --  	jal free
	0x70402628, --  	paddub $a0, $v0, 0
	0x7bbf0000, --  	lq	$ra, 0($sp)
	0x03e00008, --  	jr $ra
	0x27bd0010  --  	addiu   $sp, 0x10
} )
local call_insn = (overlay_addr >> 2) | 0x0c000000
eeInsnReplace(0x239c60, 0x0c0bdf52, call_insn) -- jal scePrintf

-- BUG 9244 - move stack down to 0x01f80000 to free up an extra 512KB
eeInsnReplace(0x100038, 0x3c0501f0, 0x3c0501f8)