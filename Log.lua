-- Log.lua
--[[
The MIT License (MIT)

Copyright (c) 2013 Joe Riedel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]

local ffi = require("ffi")
local msgBox = nil

if (ffi.os == "Windows") then
	ffi.cdef[[
		int MessageBoxA(void*, const char*, const char*, int type);
	]]
	msgBox = function(str)
		ffi.C.MessageBoxA(nil, str, "DarkGL Fatal Error", 0)
	end
end

module("Log")

kLevel_Debug = 1
kLevel_Normal = 2
kLevel_Error = 3
Level = kLevel_Debug

function Debug(str, ...)
	if (Level <= kLevel_Debug) then
		ffi.C.printf("DEBUG: %s", str:format(...))
	end
end

function Print(str, ...)
	if (Level <= kLevel_Normal) then
		ffi.C.printf("%s", str:format(...))
	end
end

function Error(str, ...)
	if (Level <= kLevel_Error) then
		ffi.C.printf("ERROR: %s", str:format(...))
	end
end

function FatalError(str, ...)
	str = str:format(...)
	ffi.C.printf("ERROR: %s", str)
	if (msgBox) then
		msgBox(str)
	end
	ffi.C.exit(-1)
end
