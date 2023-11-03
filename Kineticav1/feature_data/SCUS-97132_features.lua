--Lua 5.3
-- Title:   Kinetica
-- Features version: 1.01
-- Author:  Tim Lindquist
-- Date: March 3, 2016

-- Changelog:
-- Legacy bug fix 9414
-- Load screen unthrottling
-- Updated to API 1.1

apiRequest(1.1)

local gpr   = require( "ee-gpr-alias" )

local eeObj		= getEEObject()
local emuObj	= getEmuObject()

local LS = -- Turn off throttling
	function()
		emuObj.ThrottleMax()
	end

local LE = -- Turn on throttling
	function()
		emuObj.ThrottleNorm()
	end

local SWAP = -- swap mono and stereo strings
	function()
		local a1 = eeObj.GetGpr(gpr.a1)
		local string = eeObj.ReadMemStr(a1)
		if string == 'STEREO' then
			string = 'MONO'
			eeObj.SetGpr(gpr.v0,0x4d) -- v0 gets written after the hook so need to patch it
			eeObj.WriteMemStrZ(a1,string)
		elseif string == 'MONO' then
			string = 'STEREO'
			eeObj.SetGpr(gpr.v0,0x53) -- v0 gets written after the hook so need to patch it
			eeObj.WriteMemStrZ(a1,string)
		end
	end

local DEF = -- swap default stereo/mono setting
	function()
		eeObj.SetGpr(gpr.t1,1)
	end

local	loadstart = eeObj.AddHook(0x189064, 0x27bdff90, LS) -- Load start
local	loadend = eeObj.AddHook(0x1892e4, 0x7bb00000, LE) -- Load end
local	stringread = eeObj.AddHook(0x1c3744,0x90a20000,SWAP) -- String read
local	default = eeObj.AddHook(0x12adc0,0x8f82c3f4,DEF) -- Change default to stereo
