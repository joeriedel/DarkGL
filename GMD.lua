-- GMD file support
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
local assert = assert

module("GMD")
local ffi = require("ffi")
local log = require("Log")
local byteStream = require("ByteStream")
local imuse = require("iMuse")

ffi.cdef[[
	struct GMDChunk {
		char id[4]; // MIDI
		int32_t size; // big endian
	} __attribute((packed));
	struct MThd {
		int32_t format;
		int32_t numTracks;
		int32_t tempo;
	};
]]

local gmdChunkType = ffi.typeof("struct GMDChunk[?]")
local mthdChunkType = ffi.typeof("struct MThd[?]")

function ReadChunk(stream)
	local chunk = stream:ffiRead(gmdChunkType)[0]
	local id = ffi.string(chunk.id, 4)
	chunk.size = byteStream.ByteSwap(chunk.size, 4)
	return id, size
end

local self = {}

function PlayGMD(gmd)
	imuse.Play(gmd.stream.data)
end

function self.Load(name, stream)
	local gmd = {}
	gmd.New = function(x) return x end
	gmd.stream = stream
	gmd.Play = PlayGMD
	return gmd
	
	--[[local id, size = ReadChunk(stream)
	
	if (id ~= "MIDI") then
		log.Error("GMD does not have MIDI header!")
		return nil
	end
	
	local MThd = nil
	while (not stream:EOF()) do
		id, size = ReadChunk(stream)
		if (id == "MThd") then
			if (size ~= 6) then
				log.Error("GMD malformed MThd chunk!")
				return nil
			end
			MThd = stream:ffiRead(mthdChunkType)[0]
			break
		end
	end]]--
end

return self