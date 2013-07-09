-- Byte stream helpers
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

module("ByteStream")
local ffi = require("ffi")
local cstdlib = require("CStdLib")
local bit = require("bit")

local uint8_t = ffi.typeof("uint8_t[?]")

local self = {}

function StreamRead(self, size)
	assert(self.ofs+size <= self.size)
	local buf = uint8_t(size)
	ffi.copy(buf, self.data+self.ofs, size)
	self.ofs = self.ofs + size
	return buf
end

function StreamReadType(self, ctype, num)
	if (num == nil) then
		num = 1
	end
	local size = ffi.sizeof(ctype, num)
	assert(self.ofs+size <= self.size)
	local cdata = ctype(num)
	ffi.copy(cdata, self.data+self.ofs, size)
	self.ofs = self.ofs + size
	return cdata
end

function StreamSeek(self, ofs, origin)
	if (origin == nil) then
		origin = cstdlib.SEEK_CUR
	end
	
	if (origin == cstdlib.SEEK_CUR) then
		ofs = self.ofs + ofs
	elseif (origin == cstdlib.SEEK_END) then
		ofs = self.size + ofs
	end
	
	assert(ofs < self.size)
	self.ofs = ofs
	return ofs
end

function StreamReadInt(self, numBytes)
	local buf = self:Read(numBytes)
	local x = 0
	for i=0,(numBytes-1) do
		x = bit.bor(x, bit.lshift(buf[i], i*8))
	end
	return x
end

function StreamReadBigInt(self, numBytes)
	local buf = self:Read(numBytes)
	local x = 0
	for i=0,(numBytes-1) do
		x = bit.bor(x, bit.lshift(buf[i], (numBytes-i-1)*8))
	end
	return x
end

function StreamEOF(self)
	return self.ofs == self.size
end

function self.New(data, size)
	assert(ffi.istype(data, uint8_t))
	
	local stream = {
		ofs = 0,
		data = data,
		size = size,
		Read = StreamRead,
		ffiRead = StreamReadType,
		Seek = StreamSeek,
		ReadInt = StreamReadInt,
		ReadBigInt = StreamReadBigInt,
		EOF = StreamEOF
	}
	
	return stream
end

function self.ByteSwap(val, size)
	local x = 0
		
	for i=1,size do
		local s = size-i
		local m = bit.lshift(0xff, s*8)
		local z = bit.band(val, m)
		s = i-s-1
		if (s > 0) then
			x = bit.bor(x, bit.lshift(z, s*8))
		else
			x = bit.bor(x, bit.rshift(z, -s*8))
		end
	end
	
	return x
end

return self
