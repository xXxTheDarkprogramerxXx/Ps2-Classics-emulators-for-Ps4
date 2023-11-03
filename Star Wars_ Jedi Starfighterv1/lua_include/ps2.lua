
require("ee-gpr-alias")
require("utils")

MipsInsn = {}
MipsInsn.IsAddi			= function(insn) return (insn & 0xfc000000) == 0x20000000 end	-- addi rt,rs,simm
MipsInsn.IsAddiu		= function(insn) return (insn & 0xfc000000) == 0x24000000 end	-- addiu rt,rs,simm
MipsInsn.IsBeq			= function(insn) return (insn & 0xfc000000) == 0x10000000 end	-- beq rs,rt,off
MipsInsn.IsJ			= function(insn) return (insn & 0xfc000000) == 0x08000000 end	-- j target
MipsInsn.IsJal			= function(insn) return (insn & 0xfc000000) == 0x0c000000 end	-- jal target
MipsInsn.IsJr			= function(insn) return (insn & 0xfc1fffff) == 0x00000008 end	-- jr rs
MipsInsn.IsLq			= function(insn) return (insn & 0xfc000000) == 0x78000000 end	-- lq rt,simm(rs)
MipsInsn.IsLd			= function(insn) return (insn & 0xfc000000) == 0xdc000000 end	-- ld rt,simm(rs)
MipsInsn.IsLw			= function(insn) return (insn & 0xfc000000) == 0x8c000000 end	-- lw rt,simm(rs)
MipsInsn.IsSq			= function(insn) return (insn & 0xfc000000) == 0x7c000000 end	-- sq rt,simm(rs)
MipsInsn.IsSd			= function(insn) return (insn & 0xfc000000) == 0xfc000000 end	-- sd rt,simm(rs)
MipsInsn.IsSw			= function(insn) return (insn & 0xfc000000) == 0xac000000 end	-- sw rt,simm(rs)
MipsInsn.IsEnd			= function(insn) return (insn & 0xfc00003f) == 0x0000000d end

MipsInsn.GetRt			= function(insn) return (insn >> 16) & 0x1f end
MipsInsn.GetRs			= function(insn) return (insn >> 21) & 0x1f end
MipsInsn.GetSimm		= function(insn) return ((insn << 48) >> 48) end
MipsInsn.GetOff			= function(insn) return MipsInsn.GetSimm(insn) end
MipsInsn.GetTarget		= function(insn) return insn & 0x3ffffff end

-- return FIFO queue of stack trace
-- the queue item is { caller-addr, return-from }
--
-- example:
--    print("=== stack trace ===")
--	  local stack_trace = MipsStackTrace(eeObj, eeObj.GetPc()+4, eeObj.GetGpr(gpr.ra), eeObj.GetGpr(gpr.sp))
--	  while not stack_trace:isEmpty() do
--		 local caller = stack_trace:dequeue()
--		 print( string.format(" 0x%08x [will return from : %x]", caller[1], caller[2]) )
--	  end
--
-- NOTE: you must +4 against GetPc() if you in a EE/IOP hook.
--		 Because EE/IOP jit executed the instruction at the address already and it might affect $sp or $ra.
--
-- obj : eeObj or iopObj
-- pc  : current pc (from GetPC or readout from thread context)
-- ra  : current ra (from GetGpr or readout from thread context)
-- sp  : current sp (from GetGpr or readout from thread context)
MipsStackTrace = function (obj, pc, ra, sp, depth)
   local max_depth = depth or 10		-- max trace depth
   local n_j = 1
   local jmax = {}
   local depth = 0
   local bdl_count = 0
   local new_pc    = 0
   local icount    = 0

   local result = Queue.new()
   local pushed_ra = Queue.new()
   while depth < max_depth and icount < 2048 do
	  -- TODO: error checks
	  if (pc & 3) ~= 0 then
		 return result
	  end
	  pc = pc & 0x03ffffff
	  local insn = obj.ReadMem32(pc)
	  -- print(string.format("trace .. pc=%x insn=%x", pc, insn))
	  -- result:enqueue( { pc, insn } )

	  if MipsInsn.IsJr(insn) and MipsInsn.GetRs(insn) == gpr.ra then
		 bdl_count = 1
		 depth = depth + 1
		 new_pc = ra
		 -- print(string.format("jr ra : ra=%x", ra))
		 icount = 0
		 -- print(string.format("enqueue caller pc=%x ret addr=%x", new_pc-8, pc))
		 result:enqueue( {new_pc-8, pc} )	-- {return-addr, where-from}
	  elseif MipsInsn.IsAddiu(insn) and MipsInsn.GetRt(insn) == gpr.sp and MipsInsn.GetRs(insn) == gpr.sp then
		 sp = sp + MipsInsn.GetSimm(insn) -- ((insn<<48) >>48)
		 -- print(string.format("addiu sp,sp,** : new sp = %x", sp))
	  elseif MipsInsn.IsLq(insn) or MipsInsn.IsLd(insn) or MipsInsn.IsLw(insn) then
		 if MipsInsn.GetRt(insn) == gpr.ra and MipsInsn.GetRs(insn) == gpr.sp then
			-- the code might push $ra on the stack after start pc.
			-- in such case, we must not retrieve $ra value from the memory.
			if pushed_ra:isEmpty() then
			   local imm = MipsInsn.GetSimm(insn) -- ((insn<<48) >>48)
			   ra = obj.ReadMem32(sp + imm)
			   -- print(string.format("load ra,%x(sp) : sp = %x+%x, ra = %x", imm, sp, imm, ra))
			else
			   pushed_ra:dequeue()
			end
		 end
	  elseif MipsInsn.IsSq(insn) or MipsInsn.IsSd(insn) or MipsInsn.IsSw(insn) then
		 if MipsInsn.GetRt(insn) == gpr.ra and MipsInsn.GetRs(insn) == gpr.sp then
			pushed_ra:enqueue(pc);
		 end
	  elseif MipsInsn.IsJ(insn) then	-- j **
		 local imm = MipsInsn.GetTarget(insn)
		 imm = imm << 2
		 if pc == imm then
			-- jump to self? maybe we can ignore it.
		 else
			new_pc = imm
			-- -- print(string.format("j ** : new_pc = %x", new_pc))
			bdl_count = 1
			for t=1, n_j do
			   if jmax[t] == new_pc then
				  return result							-- closed loop
			   end
			end
			if n_j > 1024 then
			   return result							-- jump buffer overflow
			end
			jmax[n_j] = new_pc
			n_j = n_j + 1
		 end
	  elseif MipsInsn.IsBeq(insn) and MipsInsn.GetRs(insn) == gpr.zero then	-- beq zero,**
		 local offset = MipsInsn.GetOff(insn) -- ((insn<<48) >> 48)
		 offset = offset << 2
		 new_pc = pc + 4 + offset

		 if pc == new_pc then
			-- jump to self? maybe we can ignore it
		 else
			-- -- print(string.format("beq zero,** : new_pc=%x", new_pc))
			bdl_count = 1
			for t = 1, n_j do
			   if jmax[t] == new_pc then
				  return result
			   end
			end
			if n_j > 1024 then
			   return result
			end
			jmax[n_j] = new_pc
			n_j = n_j + 1
		 end
	  elseif MipsInsn.IsEnd(insn) then	-- end
		 -- -- print(string.format("end"))
		 return result
	  elseif MipsInsn.IsJal(insn) then	-- jal **
		 local imm = insn & 0x03ffffff
		 imm = imm << 2
		 -- -- print(string.format("jal ** : addr = %x", imm))
		 -- call
	  end

	  icount = icount + 1
	  pc = pc + 4

	  -- -- print(string.format("bdl_count=%d", bdl_count))
	  if bdl_count > 0 then
		 if bdl_count == 2 then
			pc = new_pc
			bdl_count = 0
		 else
			bdl_count = bdl_count + 1
		 end
	  end
   end
   return result
end

PS2 = {}
PS2.GetCurrentThread	= function(eeObj) return eeObj.ReadMem32(0x12fac) end
PS2.GetThreads			= function(eeObj)
   local EE_THREAD_BASE	= 0x18000
   local EE_NUM_THREADS = 0x100
   local th = EE_THREAD_BASE
   local result = Queue.new()
   for t = 0, EE_NUM_THREADS-1 do
	  -- 0 : node_prev
	  -- 4 : node_next
	  -- 8 : status
	  -- 12: pc
	  -- 16: sp
	  -- 20: gp
	  -- 24: init_pri
	  -- 26: curr_pri
	  -- 28: wstat
	  -- 32: waitId
	  -- 36: wakeupCount
	  -- 40: attr
	  -- 44: option
	  -- 48: func
	  -- 52: argc
	  -- 56: args
	  -- 60: stack
	  -- 64: size
	  -- 68: root
	  -- 72: endOfHeap
	  local status = eeObj.ReadMem32(th + 8)
	  if status ~= 0 then
		 local id    = t
		 local pri   = eeObj.ReadMem16(th + 26)
		 local gp    = eeObj.ReadMem32(th + 20)
		 local pc    = eeObj.ReadMem32(th + 12)
		 local sp    = eeObj.ReadMem32(th + 16)
		 result:enqueue( {id=id, status=status, pri=pri, gp=gp, pc=pc, sp=sp} )
	  end
	  th = th + 76
   end
   return result
end
