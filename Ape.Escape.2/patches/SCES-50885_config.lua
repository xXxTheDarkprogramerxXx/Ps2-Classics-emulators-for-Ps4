local gpr = require("ee-gpr-alias")
require( "ee-hwaddr" )
apiRequest(0.1)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj = getEEObject()

-- -- never gonna die
-- eeInsnReplace(  0x2bd0a0, 0x27bdfff0, 0x03e00008) --  	addiu	sp,sp,-16
-- eeInsnReplace(  0x2bd0a4, 0x3c02003e, 0x00000000) --  	lui	v0,0x3e


-- performance fix bug #9789
local emuObj = getEmuObject()
emuObj.SetGsTitleFix( "ignoreAreaUpdate", 0, { } )
emuObj.SetGsTitleFix( "includeAreaUpdate", "reserved" , {alpha = 0x80000048 } ) 
emuObj.SetGsTitleFix( "ignoreUpRender", 50 , { } )


