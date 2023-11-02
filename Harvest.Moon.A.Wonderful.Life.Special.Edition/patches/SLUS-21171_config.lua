apiRequest (1.7)

local eeObj = getEEObject()
local gpr = require("ee-gpr-alias")

-- 00107be0 <syncV>: idle loop on vsync
eeNativeHook (0x107c14, 0x3c03005d,"FastForwardClock", 0)

eeNativeFunction(0x44f3f8, 0x27bdffd0, 'ieee754_acosf')
eeNativeFunction(0x44f820, 0x27bdffd0, 'ieee754_asinf')
eeNativeFunction(0x450930, 0x44036000, 'ieee754_sqrtf')
eeNativeFunction(0x452848, 0x0080102d, 'fabs')
eeNativeFunction(0x453080, 0x27bdffd0, 'cosf')
eeNativeFunction(0x453158, 0x27bdfff0, 'fabsf')
eeNativeFunction(0x453320, 0x27bdffd0, 'sinf')
eeNativeFunction(0x4534b0, 0x27bdfff0, 'acosf')
eeNativeFunction(0x4534c8, 0x27bdfff0, 'asinf')
eeNativeFunction(0x453510, 0x27bdfff0, 'sqrtf')
eeNativeFunction(0x4552d8, 0x27bdffd0, 'fptoui')
eeNativeFunction(0x455298, 0x27bdffd0, 'fptodp')
eeNativeFunction(0x455d48, 0x27bdffd0, 'litodp')
eeNativeFunction(0x455e00, 0x27bdffc0, 'dptoli')
eeNativeFunction(0x455ed0, 0x27bdffc0, 'dptofp')
eeNativeFunction(0x45d580, 0x0080402d, 'memcpy')
eeNativeFunction(0x45d738, 0x2cc20008, 'memset')
eeNativeFunction(0x45fde8, 0x30820007, 'strlen')

eeInsnReplace(0x4443e0, 0x24030064, 0x03e00008)                 -- <FlushCache>
eeInsnReplace(0x4443e4, 0x0000000c, 0x00000000)
eeNativeHook (0x4443e0, 0x03e00008,'AdvanceClock',0x800)
eeInsnReplace(0x444410, 0x2403ff98, 0x03e00008)                 -- <iFlushCache>
eeInsnReplace(0x444414, 0x0000000c, 0x00000000)
eeNativeHook (0x444410, 0x03e00008,'AdvanceClock',0x800)
eeInsnReplace(0x444a58, 0x27bdffc0, 0x03e00008)                 -- <SyncDCache>
eeInsnReplace(0x444a5c, 0xffb20020, 0x00000000)
eeNativeHook (0x444a58, 0x03e00008,'AdvanceClock',0x800)
eeInsnReplace(0x444b98, 0x27bdffc0, 0x03e00008)                 -- <InvalidDCache>
eeInsnReplace(0x444b9c, 0xffb20020, 0x00000000)
eeNativeHook (0x444b98, 0x03e00008,'AdvanceClock',0x800)

-- bug#10318 : workaround...
eeObj.AddHook(0x3ce0fc,	0x0200202d, function()
				 local sign = (eeObj.GetGpr(gpr.v1) >> 31) & 1
				 if sign then
					eeObj.SetPc(0x3ce118)
				 end
end)

