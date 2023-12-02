-- Star Wars: Jedi Starfighter [SLES-50371] [EU]

require("ee-gpr-alias")
require("pad-and-key")
apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj = getEEObject()
local emuObj = getEmuObject()

-- Bug#9013 - title calls PS2::Exit() at the end of a bonus stage.
eeInsnReplace(0x323398, 0x0c116bb4, 0x00000000) --   jal     Stop__12CTaskManagerFv
 
-- Bug#8905
-- The game sets a little bit big DH values for GS Display Register.
-- mimic overscan cropping (generic crop happens in GsScanoutArea::Populate)
local dump_display = function()
   local a5 = eeObj.GetGpr(gpr.t1)
   local ds1_h = eeObj.ReadMem32(a5+892)
   local ds2_h = eeObj.ReadMem32(a5+908)
   local dh1   = (ds1_h>>(44-32))&0x7ff
   local dh2   = (ds2_h>>(44-32))&0x7ff
   if dh1 >= 574 then
	  dh1 = 558 -- 574-16
	  ds1_h = (ds1_h & 0xfff) | (dh1 << (44-32))
	  eeObj.WriteMem32(a5+892, ds1_h)
   end
   if dh2 >= 575 then
	  dh2 = 559 -- 575-16
	  ds2_h = (ds2_h & 0xfff) | (dh2 << (44-32))
	  eeObj.WriteMem32(a5+908, ds2_h)
   end
end
eeObj.AddHook(0x4fc33c,	0x02084821, dump_display)
eeObj.AddHook(0x4fc068,	0x02084821, dump_display)

-- Bug#8944
-- The game doesn't clear the framebuffer on movie-startup and movie-display.
-- call clear functions at the appropriate points by using Replacement.
local Replace_CVideoDecoder_Draw = InsnOverlay( {
	0x27bdfff0, -- 	addiu	sp,sp,-16
	0xffbf0000, -- 	sd	ra,0(sp)

	-- swap
	0x0c13f044, -- 	jal	0x4fc110
	0x00000000, -- 	nop
	-- clear
	0x0c13f228, -- 	jal	0x4fc8a0
	0x24044000, -- 	li	a0,16384

	0xdfbf0000, -- 	ld	ra,0(sp)
	0x03e00008, -- 	jr	ra
	0x27bd0010, -- 	addiu	sp,sp,16
})
eeInsnReplace(0x427fe0,	0x0c13f044,0x0c000000 | (Replace_CVideoDecoder_Draw>>2))
local Replace_CPS2MpegPlayer_Open = InsnOverlay( {
	0x27bdfff0, -- 	addiu	sp,sp,-16
	0xffbf0000, -- 	sd	ra,0(sp)

	-- clear color
	0x44806000, -- 	mtc1	zero,$f12
	0x46006346, -- 	mov.s	$f13,$f12
	0x0c13f1d8, -- 	jal	0x4fc760
	0x46006386, -- 	mov.s	$f14,$f12
	-- clear
	0x0c13f228, -- 	jal	0x4fc8a0
	0x24044000, --  li	a0,16384
	-- swap
	0x0c13f044, --  jal	4fc110 <glSwapBuffersPSX2>	
	0x00000000, --  nop

	-- restore some registers
	0x0220302d, -- 	move	a2,s1
	0x0200382d, -- 	move	a3,s0

	0xdfbf0000, -- 	ld	ra,0(sp)
	0x03e00008, -- 	jr	ra
	0x27bd0010, -- 	addiu	sp,sp,16
})
eeInsnReplace(0x423c3c,	0x0220302d, 0x0c000000 | (Replace_CPS2MpegPlayer_Open>>2))

--
-- Bug#8981 / Bug#9006
--
local std_string_c_str = function(ptr)
   return eeObj.ReadMemStr(eeObj.ReadMem32(eeObj.ReadMem32(ptr) + 12))
end
local player_obj_found_flag = 0
local player_obj = 0
eeObj.AddHook(0x464530,	0x27bdff90, function()
				 if std_string_c_str(eeObj.GetGpr(gpr.a1)) == "_player" then
					--print(string.format("LookupGameObject %s", std_string_c_str(eeObj.GetGpr(gpr.a1))))
					player_obj_found_flag = 1
				 end
end)
eeObj.AddHook(0x464720,	0x7bb10010, function()
				 if player_obj_found_flag == 1 then
					player_obj = eeObj.ReadMem32(eeObj.GetGpr(gpr.v0)+92)
					--print(string.format("    obj    = %x", eeObj.GetGpr(gpr.v0)))
					--print(string.format("    92(v0) = %x", player_obj))
					--print(string.format("    [%f, %f, %f]", eeObj.ReadMemFloat(player_obj+116), eeObj.ReadMemFloat(player_obj+120), eeObj.ReadMemFloat(player_obj+124)))
					--print(string.format("    [%f, %f, %f]", eeObj.ReadMemFloat(player_obj+52), eeObj.ReadMemFloat(player_obj+56), eeObj.ReadMemFloat(player_obj+60)))
					player_obj_found_flag = 0
				 end
end)

eeObj.AddHook(0x147444,	0x0040282d, function()
				 local strptr = eeObj.GetGpr(gpr.v0)
				 local str    = std_string_c_str(strptr)
				 if string.match(str, "ExplosionFire")
					-- or string.match(str, "ExplosionSpark")
				 then
					local explosion_object = eeObj.ReadMem32(eeObj.GetGpr(gpr.s0)+92)
					local eo_x = eeObj.ReadMemFloat(explosion_object+116)
					local eo_y = eeObj.ReadMemFloat(explosion_object+120)
					local eo_z = eeObj.ReadMemFloat(explosion_object+124)
					-- print(string.format("exp obj : %x", explosion_object))
					-- print(string.format("        [%f, %f, %f]", eo_x, eo_y, eo_z))
					-- print(string.format("        [%f, %f, %f]", eeObj.ReadMemFloat(explosion_object+52), eeObj.ReadMemFloat(explosion_object+56), eeObj.ReadMemFloat(explosion_object+60)))

					local pl_x = eeObj.ReadMemFloat(player_obj+116)
					local pl_y = eeObj.ReadMemFloat(player_obj+120)
					local pl_z = eeObj.ReadMemFloat(player_obj+124)
					-- print(string.format("pl  obj : %x", player_obj))
					-- print(string.format("        [%f, %f, %f]", pl_x, pl_y, pl_z));

					local len = (eo_x-pl_x)*(eo_x-pl_x) + (eo_y-pl_y)*(eo_y-pl_y) + (eo_z-pl_z)*(eo_z-pl_z)
					-- print(string.format("lengh^2 = %f", len))

					-- print(string.format("str : %s", std_string_c_str(strptr)))

					if len < 960000.0 then
					   -- print("    REMOVED")
					   eeObj.SetPc(0x1474b0)
					end
				 end
end)

local overlay_addr = InsnOverlay( {
 0x8c700008, --  lw      $s0, 8($v1)
 0x8e040000, --  lw      $a0, 0($s0)
 0x8c840000, --  lw      $a0, 0($a0)
 0x3c05006c, --  lui     $a1,0x6c
 0x34a5ce28, --  ori     $a1,$a1,0xce28
 0x14850002, --  bne     $a0, $a1, <ret>
 0x00000000, --  nop
 0xac600004, --  sw      zero, 4($v1)
 0x03e00008, -- ret: jr      $ra
 0x8c630004, --  lw      $v1, 4($v1) 
} )
local call_insn = (overlay_addr >> 2) | 0x0c000000
eeInsnReplace( 0x267f84, 0x8c700008, call_insn ) -- lw $s0, 8($v1) -> jal overlay_addr
eeInsnReplace( 0x267f88, 0x8c630004, 0x00000000 ) -- lw $v1, 4($v1) -> nop

-- The game has a bug when you replay the last campaign mission in coop mode ("The Jedi Master").
-- Upon completing the mission successfully, the game asks to "Continue" or "Quit".
-- Selecting "Continue" causes the game to hang, as there's nothing to continue to (it's the last mission)
-- The following patch fixes this problem by changing to prompt to "Retry" or "Quit", as it behaves in 1p mode
 
eeObj.AddHook(0x39debc, 0x0220202d, function()
     local strptr = eeObj.GetGpr(gpr.v0)
     local str    = std_string_c_str(strptr)
     if string.match(str, "m16_fleet") then
     eeObj.SetGpr(gpr.s0, 1)
     end
end)
 
-- fix for a node corruption.
-- here's what happens (from Ernesto)
--
-- Well, I was finally able to track down the issue. It's actually difficult to explain and the actual trigger is still unknown to me, as it seems to be timing related somehow.
-- But, I found a way to reliably detect it and work around it. Basically, when the bug happens, CSGNode::AddChild will try to add a child node that's already a children of a different root node.
-- That causes all sorts of havok and it's what ends up causing the node child list to eventually be deallocated and the render to crash.
eeObj.AddHook(0x266A70, 0x27bdffc0, function()
--   local obj = eeObj.GetGpr(gpr.a0)
    local node = eeObj.GetGpr(gpr.a1)
    local parent = eeObj.ReadMem32(node+0x10)
--   local caller = eeObj.GetGpr(gpr.ra)

    if parent ~= 0 then
--      print(string.format("Node %08x already has a parent (%08x, caller: %08x)", node, parent, caller))
       eeObj.SetPC(0x266B80)
    end
end)
