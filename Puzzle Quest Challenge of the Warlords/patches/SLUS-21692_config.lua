require("ee-gpr-alias")
require( "ee-hwaddr" )
apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

eeObj = getEEObject()

-- Bug#8536
-- the game has a discrepancy between PATH1+2(for env+polygon) and PATH3(tex)
-- At here, we will replace VIF packet including MSKPATH3 just only the first one in a frame.
-- The packet sits at 0x35cbd0 statically and the game uses CALL tag to refer it for each draw-calls.
-- Because it's shared among all drawcalls, we can't rewrite it directly.
-- Instead of that, changing the address of CALL tag and placing our own packet excluding MSKPATH3=OFF on Overlay area.

-- Strategy
--		- Create our special packet on Overlay area
--		- just before kicking Ch1DMA, replace CALL tag's address to our own one.
--
-- the original packets at 0x35cbd0
-- 6000001f 00000000 11000000 50000002	: RET QWC=1f
-- 00008001 10000000 0000000e 00000000
-- 00000000 00000000 0000007f 00000000
-- 00000000 00000000 13000000 50000002
-- 00008001 10000000 0000000e 00000000
-- 00000000 00000000 0000003f 00000000
-- 00000000 00000000 00000000 06000000	: MSKPATH3=OFF
-- 00000000 00000000 00000000 00000000 x 23 qword

-- Reserve memory area for our packet.
-- Because InsnOverlay is for instructions, we can't use directly the API for 'data'.
local addrReplacePacket = InsnOverlay( {
	  0, 0, 0, 0,
	  0, 0, 0, 0,
	  0, 0, 0, 0,
	  0, 0, 0, 0,
	  0, 0, 0, 0,
	  0, 0, 0, 0,
	  0, 0, 0, 0
})

-- Create our packet at the top of 'main'
eeObj.AddHook( 0x205be0, 0x27bdff80, function()
				  local addr = addrReplacePacket
				  -- create replace packet on the reserved area.
				  eeObj.WriteMem128(addr + 0x00, 0x60000006, 0x00000000, 0x11000000, 0x50000002)
				  eeObj.WriteMem128(addr + 0x10, 0x00008001, 0x10000000, 0x0000000e, 0x00000000)
				  eeObj.WriteMem128(addr + 0x20, 0x00000000, 0x00000000, 0x0000007f, 0x00000000)
				  eeObj.WriteMem128(addr + 0x30, 0x00000000, 0x00000000, 0x13000000, 0x50000002)
				  eeObj.WriteMem128(addr + 0x40, 0x00008001, 0x10000000, 0x0000000e, 0x00000000)
				  eeObj.WriteMem128(addr + 0x50, 0x00000000, 0x00000000, 0x0000003f, 0x00000000)
				  eeObj.WriteMem128(addr + 0x60, 0x00000000, 0x00000000, 0x00000000, 0x00000000)
end)

-- Replace the address of CALL to our own packet.
eeObj.AddHook( 0x1faff0, 0x24030145, function()
				  local ee   = eeObj
				  local tadr = ee.ReadMem32(vif1_hw.TADR)
				  local addr_openClosePATH3Chain = 0x35cbd0
				  -- the first VIF tag of the chain must be 'CALL 0x35cbd0'.
				  if ee.ReadMem32(tadr) ~= 0x50000000 or ee.ReadMem32(tadr+4) ~= addr_openClosePATH3Chain then
					 -- print(stirng.format("***** UNEXPECTED PACKET *****"))
					 return
				  end
				  -- change call address to our own no-mskpath3 packets.
				  ee.WriteMem32(tadr+4, addrReplacePacket)
				  -- print(string.format("=== replace packet %08x ===", addrReplacePacket))
				  -- for i=0,6 do
				  -- 	 print(string.format("  %08x %08x %08x %08x", ee.ReadMem128(addrReplacePacket + i*16)))
				  -- end
end)
