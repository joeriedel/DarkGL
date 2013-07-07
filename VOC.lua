-- VOC file support
-- Handles VOC files
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
local table = table

module("VOC")
local ffi = require("ffi")
local log = require("Log")
local cstdlib = require("CStdLib")

local uint8Type = ffi.typeof("uint8_t[?]")

local DecodeBlock = function(pcm, encoding, size)

	if (encoding == 0x00) then -- 8 bit PCM
		return pcm,size
	elseif (encoding == 0x01) then -- 4 bits -> 8 bits
		local new = ffi.new(uint8Type, size*2)
		local ofs = 0
		for i=0,size-1 do
			new[ofs] = bit.lshift(bit.band(pcm[i], 0xf), 4)
			new[ofs+1] = bit.band(pcm[i], 0xf0)
			ofs = ofs + 2
		end
		return new, size*2
	elseif (encoding == 0x03) then -- 2 bits -> 8 bits
		local new = ffi.new(uint8Type, size*4)
		local ofs = 0
		for i=0,size-1 do
			new[ofs] = bit.lshift(bit.band(pcm[i], 0x3), 6)
			new[ofs+1] = bit.lshift(bit.band(pcm[i], 0xc), 4)
			new[ofs+2] = bit.lshift(bit.band(pcm[i], 0x30), 2)
			new[ofs+3] = bit.band(pcm[i], 0xc0)
			ofs = ofs + 4
		end
		return new, size*4
	end
	
	log.FatalError("Unsupported VOC PCM format.\n")
	
end

local MergeBlocks = function(src, srcSize, dst, dstSize)

	local new = ffi.new(uint8Type, srcSize+dstSize)
	ffi.copy(new, src, srcSize)
	ffi.copy(new+srcSize, dst, dstSize)
	return new, srcSize+dstSize

end

local MergeSilence = function(src, srcSize, silenceSize)

	local new = ffi.new(uint8Type, srcSize+silenceSize)
	ffi.copy(new, src, srcSize)
	
	for i=0,silenceSize-1 do
		new[i+srcSize] = 0
	end
	
	return new,srcSize+silenceSize
end

local CalcFreq = function (freq)
	freq = 1000000/(256-freq)
	if (freq > 44000) then
		freq = 48000
	elseif (freq > 22000) then
		freq = 44000
	elseif (freq > 11000) then
		freq = 22000
	elseif (freq > 8000) then
		freq = 11000
	elseif (freq > 4000) then
		freq = 8000
	else
		freq = 4000
	end
	return freq
end

function Load(name, stream)

	log.Debug("VOCLOAD %s\n", name)
		
	-- verify it's a VOC file
	local ident = ffi.string(stream:Read(19), 19)
	if (ident ~= "Creative Voice File") then
		log.Error("%s is not a VOC file.\n", name)
		return nil
	end
	
	-- skip main header
	stream:Seek(1)
	
	local headerSize = stream:ReadInt(2)
	stream:Seek(headerSize, cstdlib.SEEK_SET)
	
	local voc = { blocks = {} }
	
	while (true) do
	
		if (stream:EOF()) then
			break
		end
		
		local blockType = stream:ReadInt(1)
		
		if (blockType == 0x00) then -- terminator
			break
		end
		
		local blockSize = stream:ReadInt(3)
		local encoding = nil
		local rep = 0
		local block = nil
		
		if (blockType == 0x01) then -- sound header + data
			local freq = stream:ReadInt(1)
			encoding = stream:ReadInt(1)
			local pcm = stream:Read(blockSize-2)
			block = {
				freq = CalcFreq(freq),
				rep = rep
			}
			block.pcm, block.size = DecodeBlock(pcm, encoding, blockSize-2)
			table.insert(voc.blocks, block)
		elseif (blockType == 0x02) then -- sound continuation
			assert(block)
			local pcm = stream:Read(blockSize)
			local pcm, size = DecodeBlock(pcm, encoding, blockSize)
			block.pcm, block.size = MergeBlocks(block.pcm, block.size, pcm, size)
		elseif (blockType == 0x03) then -- silence
			assert(block)
			local numSamples = stream:ReadInt(2)
			local freq = stream:ReadInt(1)			
			freq = CalcFreq(freq)
			block.pcm, block.size = MergeSilence(block.pcm, block.size, numSamples)
		elseif (blockType == 0x04) then -- marker
			stream:Seek(2)
		elseif (blockType == 0x05) then -- text
			stream:Seek(blockSize)
		elseif (blockType == 0x06) then -- repeat
			rep = stream:ReadInt(2)
		elseif (blockType == 0x07) then -- repeat end
			rep = 0
		else
			stream:Seek(blockSize)
		end
	
	end
	
end
