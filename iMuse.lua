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
local gob = require("GOB")
 
ffi.cdef[[
	void darkgl_scumm_init();
	void darkgl_scumm_midi_start(const void *stalk, const void  *fight);
	void darkgl_scumm_midi_stop();
	void darkgl_set_transition(int);
]]

local imuse = ffi.load("scummvm")

local self = {}
local stalk = nil
local fight = nil

function self.Initialize()
	imuse.darkgl_scumm_init()
end

function self.PlaySong(songnumber)
	self:Stop()
	
	stalk = gob.Load("STALK-"..songnumber..".GMD")
	fight = gob.Load("FIGHT-"..songnumber..".GMD")
	
	if (stalk and fight) then
		imuse.darkgl_scumm_midi_start(stalk.stream.data, fight.stream.data)
	end
end

function self.Stalk()
	imuse.darkgl_set_transition(0)
end

function self.Fight()
	imuse.darkgl_set_transition(1)
end

function self.Stop()
	imuse.darkgl_scumm_midi_stop()
end

return self