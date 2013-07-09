-- iMuse support
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

local require = require

module("iMuse")
local ffi = require("ffi")

ffi.cdef[[
	typedef void* (*MIDIHOOK) (const char *args);
	void darkgl_scumm_init();
	void darkgl_scumm_set_midi_hook(MIDIHOOK hook);
	void darkgl_scumm_midi_start(const void *sound);
	void darkgl_scumm_midi_stop();
]]

local imuse = ffi.load("scummvm")

local self = {}

function self.Initialize()
	imuse.darkgl_scumm_init()
end

function self.Play(gmdfile)
	imuse.darkgl_scumm_midi_start(gmdfile)
end

function self.Stop()
	imuse.darkgl_scumm_midi_stop()
end

return self