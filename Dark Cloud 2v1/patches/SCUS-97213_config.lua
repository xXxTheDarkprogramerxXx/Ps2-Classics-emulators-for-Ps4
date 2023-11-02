require("ee-gpr-alias")
apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

eeObj = getEEObject()

-- Bug#8934 (see bugzilla for details)
-- There is a bug in one of the game's scripts which causes crashes even on a real PS2.
-- The bug is present in the SCUS version, but not in the SCES one. We intercept when
-- the script is loaded, and change it to match the behavior of the SCES version.
local PatchScript =
	function()
		local namePtr = eeObj.GetGpr(gpr.s1)
		local name = eeObj.ReadMemStr(namePtr)
		if name == "map/i/i04/h01/i04h01.stb" then
			local addr = eeObj.GetGpr(gpr.s0)
			local len = eeObj.GetGpr(gpr.v1)

			local offs = 0x3d210
			local op1 = eeObj.ReadMem32(addr + offs)
			local op2 = eeObj.ReadMem32(addr + offs + 4)

			if		len == 0x3e210 and
					op1 == 0x00000001 and
					op2 == 0x0000000b then
				-- everything matches so patch the script
				eeObj.WriteMem32(addr + offs,     0x00000003)
				eeObj.WriteMem32(addr + offs + 4, 0x00000000)
			end
		end
	end

eeObj.AddHook(0x2df4d8, 0x8fa3015c, PatchScript)	-- <LoadScript(char *)>:



-- Bug#8968 (see bugzilla for details)
-- There is a bug which causes a hang (even on a real PS2) when the Boost fish stat goes above 100.
-- We intercept when the infinite loop would happen, and force it to end.
local PatchFish =
	function()
		local t0 = eeObj.GetGpr(gpr.t0)
		local t4 = eeObj.GetGpr(gpr.t4)
		local stat = eeObj.GetGpr(gpr.v1)
		if t0 == t4 and stat > 100 then	-- infinite loop
			eeObj.SetGpr(gpr.v1, 100)
		end
	end

eeObj.AddHook(0x1997cc, 0x2463ffff, PatchFish)	-- <CGameDataUsed::CheckParamLimmit(void)>
