
require("ee-gpr-alias")
require("utils")

MipsInsn = {}
MipsInsn.IsAddi			= function(insn) return (insn & 0xfc000000) == 0x20000000 end	-- addi rt,rs,simm
MipsInsn.IsAddiu		= function(insn) return (insn & 0xfc000000) == 0x24000000 end	-- addiu rt,rs,simm
MipsInsn.IsDaddu		= function(insn) return (insn & 0xfc0007ff) == 0x0000002d end	-- daddu rd,rs,rt
MipsInsn.IsAddu			= function(insn) return (insn & 0xfc0007ff) == 0x00000021 end	-- addu rd,rs,rt
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

local dbgPrintf = function(s,...)
	-- Uncomment to enable debug trace logging of MipsStackTrace.
    -- print (string.format(...))
end
		 
-- return FIFO queue of stack trace
-- the queue item is { caller-addr, return-from }
--
-- example:
--    print("=== stack trace ===")
--	  local stack_trace = MipsStackTrace(eeObj, eeObj.GetPc()+4, eeObj.GetGpr(gpr.ra), eeObj.GetGpr(gpr.sp))
--	  while not stack_trace:isEmpty() do
--		 local caller = stack_trace:dequeue()
--       local symName,symPc = debugObj.GetSymbol(caller[1])
--		 print( string.format(" 0x%08x %-48s [will return from : %x]", caller[1], synName, caller[2]) )
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
	  pc = pc & 0x01ffffff
	  sp = sp & 0x01ffffff
	  local insn = obj.ReadMem32(pc)
	  dbgPrintf(string.format("trace .. pc=%x insn=%x", pc, insn))
	  -- result:enqueue( { pc, insn } )

	  if MipsInsn.IsJr(insn) and MipsInsn.GetRs(insn) == gpr.ra then
		 bdl_count = 1
		 depth = depth + 1
		 new_pc = ra
		 dbgPrintf(string.format("jr ra : ra=%x", ra))
		 icount = 0
		 dbgPrintf(string.format("enqueue caller pc=%x ret addr=%x", new_pc-8, pc))
		 result:enqueue( {new_pc-8, pc} )	-- {return-addr, where-from}
	  elseif MipsInsn.IsAddiu(insn) and MipsInsn.GetRt(insn) == gpr.sp and MipsInsn.GetRs(insn) == gpr.sp then
		 sp = sp + MipsInsn.GetSimm(insn) -- ((insn<<48) >>48)
		 dbgPrintf(string.format("addiu sp,sp,** : new sp = %x", sp))
	  elseif (MipsInsn.IsAddu(insn) or MipsInsn.IsDaddu(insn)) and MipsInsn.GetRd(insn) == gpr.sp then
		 dbgPrintf(string.format("addiu sp,**,**  ... we can't get new sp value..."))
		 return result
	  elseif MipsInsn.IsLq(insn) or MipsInsn.IsLd(insn) or MipsInsn.IsLw(insn) then
		 if MipsInsn.GetRt(insn) == gpr.ra and MipsInsn.GetRs(insn) == gpr.sp then
			-- the code might push $ra on the stack after start pc.
			-- in such case, we must not retrieve $ra value from the memory.
			if pushed_ra:isEmpty() then
			   local imm = MipsInsn.GetSimm(insn) -- ((insn<<48) >>48)
			   dbgPrintf(string.format("retrieve ra from stack(%x) : sp=%x imm=%x", sp+imm, sp, imm))
			   ra = obj.ReadMem32(sp + imm)
			   dbgPrintf(string.format("load ra,%x(sp) : sp = %x+%x, ra = %x", imm, sp, imm, ra))
			else
			   dbgPrintf(string.format("retrieve ra from pushed one"))
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
			dbgPrintf(string.format("j ** : new_pc = %x", new_pc))
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
		 dbgPrintf(string.format("beq zero,** : new_pc=%x", new_pc))
		 if offset < 0 then
			-- it's ... back loop. ignore
		 else
			if pc == new_pc then
			   -- jump to self? maybe we can ignore it
			else
			   -- print(string.format("beq zero,** : new_pc=%x", new_pc))
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
		 end
	  elseif MipsInsn.IsEnd(insn) then	-- end
		 dbgPrintf(string.format("end"))
		 -- Ignore 'end/break'
		 -- Most use cases of end/break are 'unreachable' debug code in titles.
		 -- If ignoring this is a problem on some specific title, then perhaps analysis of
         -- end/break should be instead controllable via parameter. --jstine
		 -- return result
	  elseif MipsInsn.IsJal(insn) then	-- jal **
		 local imm = insn & 0x03ffffff
		 imm = imm << 2
		 dbgPrintf(string.format("jal ** : addr = %x", imm))
		 -- call
	  end

	  icount = icount + 1
	  pc = pc + 4

	  -- dbgPrintf(string.format("bdl_count=%d", bdl_count))
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
