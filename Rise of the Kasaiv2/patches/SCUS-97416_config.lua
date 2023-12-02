-- rise_of_kasai
require("ee-gpr-alias")

apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.


local emuObj = getEmuObject()
local eeObj  = getEEObject()

-- bug #9037. 
-- Force point sampling when max mip map > 0 and min filter is set to nearest( 0).   
-- This is done generically when mipmaping is On , however  we prefer to disable mip maps for this title.
emuObj.SetGsTitleFix( "forcePoint", "reserved", {mipIsGt=0,  mmin=0} )

-- bug#9241
-- SwapMemCard to Mark of Kri
-- bug#136347 (SCEI bugzilla)
-- we re-use US image for Rise of Kasai EU package and want to let use be able to have Mark of Kri completion bonus.
-- unfortunately we don't have any ways to distinguish which PS4 package we are working on.
-- instead of US => EU reading out modification, let the game retry EU saved data when it fails.
--
-- NOTE: you can write down the filepath directly(onto strptr) at boot time if we can distinguish the differences of the packages.
local first_attempt = true
local buffer = -1
local strptr = -1
local write_str = function (ptr, str)
   for i=1,string.len(str) do
	  eeObj.WriteMem8(ptr + i - 1, string.byte(str, i, i))
   end
end
eeObj.AddHook(0x1aa904,	0x0040382d, function()
				 strptr = eeObj.GetGpr(gpr.a2)
				 local fname = eeObj.ReadMemStr(strptr)
				 -- print(string.format("%s", fname))
				 if fname == "BASCUS-97140/BASCUS-97140" then
					if first_attempt then
					   buffer = eeObj.GetGpr(gpr.a3)
					   --print("Trying to read out SCUS-97140 Mark of Kri US saved data");
					   --print(string.format("%x:ReadFile(%x, %x, %x)", eeObj.GetGpr(gpr.a0), 0, eeObj.GetGpr(gpr.a2), eeObj.GetGpr(gpr.a3)))
					   emuObj.SwapMemCard(0, 0, "SCUS-97140")	-- 2nd argument, user-id isn't used in the current implementation.
					else
					   -- this is the case of re-trying : reading out EU mark of kri
					   --print("Trying to read out SCES-51164 Mark of Kri EU saved data");
					   write_str(strptr, "BESCES-51164/BESCES-51164")
					   eeObj.SetGpr(gpr.a3, buffer);
					   --print(string.format("%x:ReadFile(%x, %x, %x)", eeObj.GetGpr(gpr.a0), 0, eeObj.GetGpr(gpr.a2), eeObj.GetGpr(gpr.a3)))
					   emuObj.SwapMemCard(0, 0, "SCES-51164")
					end
				 end
end)
eeInsnReplace(0x1aa910,	0x10400020, 0x00000000)
eeObj.AddHook(0x1aa910, 0x00000000, function()
				 local v0 = eeObj.GetGpr(gpr.v0)
				 if v0 == 0 then	-- failed
					--print("File Load Failed")
					if first_attempt then
					   first_attempt = false
					   eeObj.SetPc(0x1aa8fc)
					else
					   first_attempt = true
					   eeObj.SetPc(0x1aa994)
					end
				 end
end)
-- SwapMemCard to Rise of Kasai
eeObj.AddHook(0x1aa9e8,	0xdfbf0000, function()
				 emuObj.SwapMemCard(0, 0, "SCUS-97416")
				 write_str(strptr, "BASCUS-97140/BASCUS-97140")	-- write back the original string to the place.
				 strptr = -1
				 buffer = -1
end)
