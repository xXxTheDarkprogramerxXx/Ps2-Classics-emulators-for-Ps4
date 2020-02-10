
MipsInsn = {}
MipsInsn.IsAddi			= function(insn) return (insn & 0xfc000000) == 0x20000000 end	-- addi rt,rs,simm
MipsInsn.IsAddiu		= function(insn) return (insn & 0xfc000000) == 0x24000000 end	-- addiu rt,rs,simm
MipsInsn.IsDaddu		= function(insn) return (insn & 0xfc0007ff) == 0x0000002d end	-- daddu rd,rs,rt
MipsInsn.IsAddu			= function(insn) return (insn & 0xfc0007ff) == 0x00000021 end	-- addu rd,rs,rt
MipsInsn.IsBeq			= function(insn) return (insn & 0xfc000000) == 0x10000000 end	-- beq rs,rt,off
MipsInsn.IsJ			= function(insn) return (insn & 0xfc000000) == 0x08000000 end	-- j target
MipsInsn.IsJal			= function(insn) return (insn & 0xfc000000) == 0x0c000000 end	-- jal target
MipsInsn.IsJalr			= function(insn) return (insn & 0xfc1f07ff) == 0x00000009 end	-- jalr rd, rs
MipsInsn.IsJr			= function(insn) return (insn & 0xfc1fffff) == 0x00000008 end	-- jr rs
MipsInsn.IsLq			= function(insn) return (insn & 0xfc000000) == 0x78000000 end	-- lq rt,simm(rs)
MipsInsn.IsLd			= function(insn) return (insn & 0xfc000000) == 0xdc000000 end	-- ld rt,simm(rs)
MipsInsn.IsLw			= function(insn) return (insn & 0xfc000000) == 0x8c000000 end	-- lw rt,simm(rs)
MipsInsn.IsSq			= function(insn) return (insn & 0xfc000000) == 0x7c000000 end	-- sq rt,simm(rs)
MipsInsn.IsSd			= function(insn) return (insn & 0xfc000000) == 0xfc000000 end	-- sd rt,simm(rs)
MipsInsn.IsSw			= function(insn) return (insn & 0xfc000000) == 0xac000000 end	-- sw rt,simm(rs)
MipsInsn.IsEnd			= function(insn) return (insn & 0xfc00003f) == 0x0000000d end	-- break [code]

MipsInsn.GetRt			= function(insn) return (insn >> 16) & 0x1f end
MipsInsn.GetRs			= function(insn) return (insn >> 21) & 0x1f end
MipsInsn.GetRd			= function(insn) return (insn >> 11) & 0x1f end
--MipsInsn.GetSimm		= function(insn) return ((insn << 48) >> 48) end	-- this can't create a negative value correctly
MipsInsn.GetSimm		= function(insn)
   -- Lua5.3 shifts are all logical (WHY!?). threfore (insn<<48)>>48 cannot extend the sign.
   -- Instead of using shift, do following
   local bit = 16		-- sign bit place.
   local v = insn & 0xffff
   local m = 1 << (bit - 1)
   v = v & ((1 << bit) - 1)
   return (v ~ m) - m		-- '~' is xor in Lua... how strange it is.
end
MipsInsn.GetOff			= function(insn) return MipsInsn.GetSimm(insn) end
MipsInsn.GetTarget		= function(insn) return insn & 0x3ffffff end

return MipsInsn
