
pad = {}

-- Left Side
pad.LU	= 0x0010	-- Up
pad.LD	= 0x0040	-- Down
pad.LL	= 0x0080	-- Left
pad.LR	= 0x0020	-- Right

-- Right Side
pad.RU	= 0x1000	-- Up (Triangle)
pad.RD	= 0x4000	-- Down (Cross)
pad.RL	= 0x8000	-- Left (Square)
pad.RR	= 0x2000	-- Right (Circle)

-- aliases
pad.UP		= 0x0010	-- LU
pad.DOWN	= 0x0040	-- LD
pad.LEFT	= 0x0080	-- LL
pad.RIGHT	= 0x0020	-- LR
pad.TRIANGLE= 0x1000
pad.CROSS	= 0x4000
pad.SQUARE	= 0x8000
pad.CIRCLE	= 0x2000

pad.L1	= 0x0400
pad.L2	= 0x0100
pad.L3	= 0x0002

pad.R1	= 0x0800
pad.R2	= 0x0200
pad.R3	= 0x0004

pad.SELECT	= 0x0001
pad.START	= 0x0008

keyboard = {}

keyboard.ESCAPE		= 0x1000
keyboard.SLASH		= 0x1001
keyboard.SEPARATOR	= 0x1002	-- backslash or pipe (\|)
keyboard.BACKQUOTE	= 0x1003
keyboard.PAGEDOWN	= 0x1004
keyboard.PAGEUP		= 0x1005
keyboard.F1			= 0x1006
keyboard.F2			= 0x1007
keyboard.F3			= 0x1008
keyboard.F4			= 0x1009
keyboard.F5			= 0x100a
keyboard.F6			= 0x100b
keyboard.F7			= 0x100c
keyboard.F8			= 0x100d
keyboard.F9			= 0x100e
keyboard.F10		= 0x100f
keyboard.F11		= 0x1010
keyboard.F12		= 0x1011

