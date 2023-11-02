require("ee-gpr-alias")
apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

-- bug#8201
-- this game clear sound handlers if something errant situation happened.
-- just remove clearing memory code from the error check-ups.
eeInsnReplace(  0x1f71e8,	0xac400000, 0 ) -- 	sw	zero,0(v0)
eeInsnReplace(  0x1f7200,	0xae000000, 0 ) -- 	sw	zero,0(s0)
