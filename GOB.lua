-- GOB file support
-- Loads all DarkForces file formats
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
module("GOB")

local ffi = require("ffi")
local cstdlib = require("CStdLib")
local log = require("Log")
local voc = require("VOC")
local gmd = require("GMD")
local byteStream = require("ByteStream")

ffi.cdef[[
	struct GOBHeader {
		char id[4];
		int32_t dirOfs;
	} __attribute((packed));
	
	struct GOBFile {
		int32_t fileOfs;
		int32_t fileLen;
		char name[13];
	} __attribute((packed));
]]

local gobFileType = ffi.typeof("struct GOBFile")
local gobDirType = ffi.typeof("struct GOBFile[?]")
local gobFileTypeSize = ffi.sizeof(gobFileType)
	
local self = {
	gobs = {},
	files = {},
	cache = {}
}

function self.FileType(name)
	name = name:upper()
	local ext = name:match("%.%w+$")
	ext = ext:sub(2)
	return ext
end

function self.Open(name)
	local fp = ffi.C.fopen(name, "rb")
	if (fp == nil) then
		log.FatalError("Unable to open %s.\n", name)
	end
	
	local headerType = ffi.typeof("struct GOBHeader")
	local header = ffi.new(headerType)
	assert(ffi.sizeof(headerType) == 8)
	
	if (ffi.C.fread(header, 1, 8, fp) ~= 8) then
		log.FatalError("Failed to read %s.\n", name)
		ffi.C.fclose(fp)
		return false
	end
	
	if ((header.id[0] ~= 71) or (header.id[1] ~= 79) or (header.id[2] ~= 66) or (header.id[3] ~= 0xA)) then
		log.FatalError("%s is not a GOB file.", name)
		ffi.C.fclose(fp)
		return false
	end
	
	if (ffi.C.fseek(fp, header.dirOfs, cstdlib.SEEK_SET) ~= 0) then
		log.FatalError("%s io error.", name)
		ffi.C.fclose(fp)
		return false
	end
	
	local numFiles = ffi.new("int32_t[1]")
	if (ffi.C.fread(numFiles, 1, 4, fp) ~= 4) then
		log.FatalError("%s io error.", name)
		ffi.C.fclose(fp)
		return false
	end
	numFiles = numFiles[0]
	
	local gobDir = gobDirType(numFiles)
	local numFilesRead = ffi.C.fread(gobDir, gobFileTypeSize, numFiles, fp)
	
	if (numFilesRead ~= numFiles) then
		log.FatalError("%s io error.", name)
		ffi.C.fclose(fp)
		return false
	end
	
	local gob = {
		name = name,
		fp = fp
	}
	
	self.gobs[name] = gob
	
	for i=0,(numFiles-1) do
		local gobFile = gobDir[i]
		if (gobFile.fileLen > 0) then
			local filename = ffi.string(gobFile.name):upper()
			local file = {
				ofs = gobFile.fileOfs,
				len = gobFile.fileLen,
				name = filename,
				type = self.FileType(filename),
				gob = gob
			}
			self.files[file.name] = file
			log.Debug("%s: %s\n", name, file.name)
		end
	end
	
	return true
end

local uint8_t = ffi.typeof("uint8_t[?]")

function self.Load(name, ...)
	name = name:upper()
	
	local cache = self.cache[name]
	if (cache) then
		return cache:New(...)
	end
	
	local file = self.files[name]
	if (file == nil) then
		log.FatalError("File '%s' was not found.", name)
	end
	
	local buf = uint8_t(file.len)
	
	if (ffi.C.fseek(file.gob.fp, file.ofs, cstdlib.SEEK_SET) ~= 0) then
		log.FatalError("Could not seek to '%s'.", name)
	end
	
	if (ffi.C.fread(buf, 1, file.len, file.gob.fp) ~= file.len) then
		log.FatalError("Could not read '%s'.", name)
	end
	
	local stream = byteStream.New(buf, file.len)
	
	if (file.type == "VOC") then
		cache = voc.Load(name, stream)
	elseif (file.type == "GMD") then
		cache = gmd.Load(name, stream)
	end

	if (cache) then
		self.cache[name] = cache
		return cache:New(...)
	else
		log.FatalError("'%s' has an unrecognized type.")
	end
end

return self