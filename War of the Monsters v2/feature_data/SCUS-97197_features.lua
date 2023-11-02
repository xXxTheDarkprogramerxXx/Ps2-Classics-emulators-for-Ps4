--Lua 5.3
-- Title:   War of the Monsters™
-- Features version: 1.00
-- Author:  Tim Lindquist
-- Date: December 10, 2015

-- Changelog:

-- Load screen unthrottling

apiRequest(0.2)	-- request version 0.1 API. Calling apiRequest() is mandatory.

local eeObj		= getEEObject()
local emuObj	= getEmuObject()

local titleid = emuObj.GetDiscTitleId() -- returns string as read from iso img SYSTEM.CNF

local LS = -- Turn off throttling
	function()
		emuObj.ThrottleMax()
	end

local LE = -- Turn on throttling
	function()
		emuObj.ThrottleNorm()
	end

if titleid == 'SCUS-97197' then
	loadstart = eeObj.AddHook(0x1ab1a8, 0x27bdff30, LS) -- Load start
	loadend = eeObj.AddHook(0x1ab3e4, 0xc7b400c0, LE) -- Load end
	memcardstart = eeObj.AddHook(0x1abacc, 0x03ace823, LS) -- Load start
	memcardend = eeObj.AddHook(0x1abc3c, 0x79b0ffd0, LE) -- Load end
end

if titleid == 'SCES-51224' then
	loadstart = eeObj.AddHook(0x1ae218, 0x27bdff30, LS) -- Load start
	loadend = eeObj.AddHook(0x1ae454, 0xc7b400c0, LE) -- Load end
	memcardstart = eeObj.AddHook(0x1aeb84, 0x03ace823, LS) -- Load start
	memcardend = eeObj.AddHook(0x1aecf4, 0x79b0ffd0, LE) -- Load end
end

if titleid == 'SLPM-65412' then
	loadstart = eeObj.AddHook(0x1acda8, 0x27bdff30, LS) -- Load start
	loadend = eeObj.AddHook(0x1acfe4, 0xc7b400c0, LE) -- Load end
	memcardstart = eeObj.AddHook(0x1ad704, 0x03ace823, LS) -- Load start
	memcardend = eeObj.AddHook(0x1ad874, 0x79b0ffd0, LE) -- Load end
end

