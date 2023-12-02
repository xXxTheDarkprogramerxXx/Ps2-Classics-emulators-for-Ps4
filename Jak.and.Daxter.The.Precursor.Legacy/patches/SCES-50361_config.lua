-- Jak EU
apiRequest(2.2)

local gpr    		= require("ee-gpr-alias")
local emuObj 		= getEmuObject()
local eeObj			= getEEObject()
local gsObj			= getGsObject()
local eeOverlay 	= eeObj.getOverlayObject()

-- Disable internal field shift compensation, part of post-process removal feature.
gsObj.SetDeinterlaceShift(0)

-- Fix shadow 
emuObj.SetGsTitleFix( "forceSimpleFetch", "reserved", { texMode=1  } )

-- Reduce flush count 
emuObj.SetGsTitleFix( "SetSelfRender", "reserved", { fbmask= 0x00FFFFFF , renderSelf=1 , zmsk=1 , alpha=0 , texMode=1  } )

-- Disable post-processing
-- update: removed due to occasional regression (bug#10608).  post-processing is now skipped in the EE via 'depth-cue'
-- emuObj.SetGsTitleFix( "ignoreSprite", "reserved", {  texType=1 , tw=5 , th=8, zmsk=1 , alpha=0x80000044  } )

-- ------------------------- OVERLAY MANAGER --------------------------
g_OnOverlayRegistered = function(filename, start, size)
	-- global function provided for adding per-overlay callback handlers.
end

local DH8 = function()
	local s0 = eeObj.GetGpr(gpr.s0)
	local linkblock = eeObj.ReadMem32(s0+0x5c)
	
	--print( string.format("--> PRELOAD %08x %08x",s0, linkblock) )
	
	local linkblock_allocate_length 		= eeObj.ReadMem32 (linkblock + 0x00)
	local linkblock_allocate_version 		= eeObj.ReadMem32 (linkblock + 0x04)
	local linkblock_allocate_segment_count 	= eeObj.ReadMem32 (linkblock + 0x08)
	local linkblock_allocate_name 			= eeObj.ReadMemStr(linkblock + 0x0c)
	
	local linkblock_allocate_seg1_linkptr 	= eeObj.ReadMem32 (linkblock + 0x4C)
	local linkblock_allocate_seg1_dataptr 	= eeObj.ReadMem32 (linkblock + 0x50)
	local linkblock_allocate_seg1_size 		= eeObj.ReadMem32 (linkblock + 0x54)
	local linkblock_allocate_seg1_flags 	= eeObj.ReadMem32 (linkblock + 0x58)
                                                              
	local linkblock_allocate_seg2_linkptr 	= eeObj.ReadMem32 (linkblock + 0x5C)
	local linkblock_allocate_seg2_dataptr 	= eeObj.ReadMem32 (linkblock + 0x60)
	local linkblock_allocate_seg2_size 		= eeObj.ReadMem32 (linkblock + 0x64)
	local linkblock_allocate_seg2_flags 	= eeObj.ReadMem32 (linkblock + 0x68)
                                                              
	local linkblock_allocate_seg3_linkptr 	= eeObj.ReadMem32 (linkblock + 0x6C)
	local linkblock_allocate_seg3_dataptr 	= eeObj.ReadMem32 (linkblock + 0x70)
	local linkblock_allocate_seg3_size 		= eeObj.ReadMem32 (linkblock + 0x74)
	local linkblock_allocate_seg3_flags 	= eeObj.ReadMem32 (linkblock + 0x78)
	
	-- seg1 is equiv to main in Jak3
	-- seg3 is equiv to top  in Jak3
	-- seg2 appears to be unused ... ?   --jstine

	if emuObj.IsToolingVerbose() then
		print( string.format("--> LOADED SEGMENT alloc_len %08x ver %08x segcount %08x  name:\"%s\"", linkblock_allocate_length, linkblock_allocate_version, linkblock_allocate_segment_count, linkblock_allocate_name) )
		print( string.format("    seg1linkptr %08x seg1dataptr %08x seg1size %08x seg1flags %08x", linkblock_allocate_seg1_linkptr, linkblock_allocate_seg1_dataptr, linkblock_allocate_seg1_size, linkblock_allocate_seg1_flags) )
		print( string.format("    seg2linkptr %08x seg2dataptr %08x seg2size %08x seg2flags %08x", linkblock_allocate_seg2_linkptr, linkblock_allocate_seg2_dataptr, linkblock_allocate_seg2_size, linkblock_allocate_seg2_flags) )
		print( string.format("    seg3linkptr %08x seg3dataptr %08x seg3size %08x seg3flags %08x", linkblock_allocate_seg3_linkptr, linkblock_allocate_seg3_dataptr, linkblock_allocate_seg3_size, linkblock_allocate_seg3_flags) )
	end

	if linkblock_allocate_seg1_size ~= 0 then eeOverlay.Register(linkblock_allocate_name .. ".seg1",  linkblock_allocate_seg1_dataptr, linkblock_allocate_seg1_size, false) end
	if linkblock_allocate_seg3_size ~= 0 then eeOverlay.Register(linkblock_allocate_name .. ".seg3",  linkblock_allocate_seg3_dataptr, linkblock_allocate_seg3_size, true)  end

	if (g_OnOverlayRegistered ~= nil) then
		-- Make sure to execute any previously registered OnOverlay handler
		if linkblock_allocate_seg1_size ~= 0 then g_OnOverlayRegistered(linkblock_allocate_name .. ".seg1", linkblock_allocate_seg1_dataptr, linkblock_allocate_seg1_size)	end
		if linkblock_allocate_seg1_size ~= 0 then g_OnOverlayRegistered(linkblock_allocate_name .. ".seg3", linkblock_allocate_seg3_dataptr, linkblock_allocate_seg3_size)	end
	end
end

assert(g_OnOverlayRegistered ~= nil)
local prev_OnOverlayRegistered = g_OnOverlayRegistered

g_OnOverlayRegistered = function(filename, start, size)
	
	if filename == "depth-cue.seg1" then
		-- Disable full-screen post process via depth-cue.
		-- This also removes half-pixel shift during interlacing.
		-- <depth-cue.seg1+00039c>
		-- 00701DFC:67BDFFF0                daddiu       $sp,$sp,-0x10 (0xfffffff0)		-> 	03E00008                jr           $ra
		-- 00701E00:FFBE0008                sd           $fp,8($sp)                     -> 	00000000				nop

		eeObj.WriteMem32(start + 0x39c, 0x03E00008)
		eeObj.WriteMem32(start + 0x3a0, 0x00000000)
		eeObj.WriteMem32(start + 0x004, 0x03E00008)
		eeObj.WriteMem32(start + 0x008, 0x00000000)
	end

	if (prev_OnOverlayRegistered ~= nil) then
		-- Make sure to execute any previously registered OnOverlay handler
		prev_OnOverlayRegistered(filename, start, size)
	end
end

-- hooked in link_control::finish(void)>:
eeObj.AddHook(0x0010ACF8, 0x040C825, DH8)  -- this is address US:0010abe0 JP:0010abd8 EU:0010ACF8
