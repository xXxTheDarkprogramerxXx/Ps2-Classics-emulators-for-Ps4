require("ee-gpr-alias")
require("ps2")
apiRequest(0.6)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj = getEEObject()

-- bug#8740
-- SPSetDirect(addr, char-pos, char-pos, x-coord, y-coord, width, height)
-- reduce width just 1 pix.
local Replace_1a1fb0 = InsnOverlay( {
	0x0806720a, --        j       0x19c828
	0x2529ffff, --        addiu   t1,t1,-1
})
eeInsnReplace(0x1a1fb0,	0x0c06720a, 0x0c000000 | (Replace_1a1fb0>>2)) -- 	jal	19c828 <SPSetDirect>
