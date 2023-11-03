
local PadConnectType = {}

PadConnectType.DS4				= 0
PadConnectType.HID              = 1		-- any 3rd party USB controller (fight stick, turbo controller, etc), always local.
PadConnectType.REMOTE_DS4       = 2		-- remote DS4 should behave just like regular DS4
PadConnectType.REMOTE_VITA      = 3		-- remote VITA lacks analog L2/R2

return PadConnectType