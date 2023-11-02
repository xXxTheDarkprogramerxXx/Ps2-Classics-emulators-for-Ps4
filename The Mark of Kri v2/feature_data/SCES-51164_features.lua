--Lua 5.3
-- Title:   The Mark of Kri
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

if titleid == 'SCUS-97140' then
	loadstart = eeObj.AddHook(0x103ad4, 0x24026400, LS) -- Load start
	loadend = eeObj.AddHook(0x103bac, 0xdfb00010, LE) -- Load end
	memcardstart = eeObj.AddHook(0x100234, 0xffb20020, LS) -- Load start
	memcardend = eeObj.AddHook(0x100360, 0xdfb00000, LE) -- Load end
end

if titleid == 'SCES-51164' then
	loadstart = eeObj.AddHook(0x103d14, 0x24040032, LS) -- Load start
	loadend = eeObj.AddHook(0x103e44, 0xdfb00010, LE) -- Load end
	memcardstart = eeObj.AddHook(0x100394, 0xffb20020, LS) -- Load start
	memcardend = eeObj.AddHook(0x1004c0, 0xdfb00000, LE) -- Load end
end

if titleid == 'SLPM-65310' then
	loadstart = eeObj.AddHook(0x103d1c, 0x24040032, LS) -- Load start
	loadend = eeObj.AddHook(0x103e4c, 0xdfb00010, LE) -- Load end
	memcardstart = eeObj.AddHook(0x10039c, 0xffb20020, LS) -- Load start
	memcardend = eeObj.AddHook(0x1004c8, 0xdfb00000, LE) -- Load end
end

