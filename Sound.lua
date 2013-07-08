-- Sound support
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
local pairs = pairs
local math = math
local table = table
module("Sound")

local ffi = require("ffi")
local openal = require("OpenAL")
local timers = require("Timers")
local vecLib = require("VecLib")

local self = {}

local ALuint = ffi.typeof("ALuint[?]")
local ALint = ffi.typeof("ALint[?]")
local ALuintSize = ffi.sizeof("ALuint")
local ALuintptr = ffi.typeof("ALuint*")
local ALintptr = ffi.typeof("ALint*")

local ALuintBuf = ALuint(32)
local ALintBuf = ALint(32)

function UnqueueBuffers(instance)
	openal.C.alGetSourcei(instance.source[0], openal.consts.AL_BUFFERS_PROCESSED, ALintBuf);
	local num = ALintBuf[0]
	
	if (num > 0) then
		assert(num <= instance.numQueued)
		openal.C.alSourceUnqueueBuffers(instance.source[0], num, ALuintBuf);
		instance.numQueued = instance.numQueued - num
	end
	
	return num
end

function SoundState(instance)
	openal.C.alGetSourcei(instance.source[0], openal.consts.AL_SOURCE_STATE, ALintBuf)
	return ALintBuf[0]
end

function FindFreeInstance(sound)
	for i=1,#sound.instances do
		local instance = sound.instances[i]
		if (not sound:IsPlaying(instance)) then
			return instance
		end
	end
	
	return nil
end

function QueueNextBuffer(sound, instance)
	UnqueueBuffers(instance)
	
	if (instance.buffer) then
		if (instance.reps+1 < instance.buffer.reps) then
			-- can we queue another buffer?
			assert(instance.buffer.num > 1)
			if (instance.numQueued < instance.buffer.num) then
				if (instance.buffer.reps ~= 65536) then
					instance.reps = instance.reps + 1
				end
				
				-- bufferI is ready
				openal.C.alSourceQueueBuffers(instance.source[0], 1, instance.buffer.id + instance.bufferI)
				instance.numQueued = instance.numQueued + 1
				instance.bufferI = instance.bufferI + 1
				if (instance.bufferI == instance.buffer.num) then
					instance.bufferI = 0
				end
				
				return true, true
			end
			
			return true, false
		end
		
		instance.bufferI = 0
		instance.buffer = nil
		instance.reps = 1
	end

	if (instance.nextBuffer > #sound.buffers) then
		return (instance.numQueued > 0), false
	end
	
	instance.buffer = sound.buffers[instance.nextBuffer]
	instance.nextBuffer = instance.nextBuffer + 1

	openal.C.alSourceQueueBuffers(instance.source[0], 1, instance.buffer.id)
	instance.bufferI = 1
	instance.numQueued = instance.numQueued + 1
	
	return true, true
end

function TickInstance(sound, instance)

	local playing, queued = QueueNextBuffer(sound, instance)
	if (not playing) then
		sound.numPlaying = sound.numPlaying - 1
		openal.C.alSourceStop(instance.source[0])
		return
	end

	if (sound.positional) then
		if ((instance.pos == nil) or (not vecLib.Vec3ExactlyEqual(instance.pos, sound.pos))) then
			if (instance.pos == nil) then
				instance.pos = vecLib.Vec3New()
			end
			vecLib.Copy(sound.pos, instance.pos)
			openal.C.alSource3f(instance.source[0], openal.consts.AL_POSITION, sound.pos);
		end
		if (instance.refDistance ~= sound.refDistance) then
			instance.refDistance = sound.refDistance
			openal.C.alSourcef(instance.source[0], openal.consts.AL_REFERENCE_DISTANCE, sound.refDistance)
		end
		if (instance.maxDistance ~= sound.maxDistance) then
			instance.maxDistance = sound.maxDistance
			openal.C.alSourcef(instance.source[0], openal.consts.AL_MAX_DISTANCE, sound.maxDistance)
		end
	end
	
	if (instance.volume ~= sound.volume[1]) then
		instance.volume = sound.volume[1]
		openal.C.alSourcef(instance.source[0], openal.consts.AL_GAIN, instance.volume)
	end

end

function TickSound(sound, dt)

	if (sound.volumeTime[2] > 0) then
		sound.volumeTime[1] = sound.volumeTime[1] + dt
		if (sound.volumeTime[1] >= sound.volumeTime[2]) then
			sound.volumeTime[1] = 0
			sound.volumeTime[2] = 0
			sound.volume[1] = sound.volume[3]
		else
			sound.volume[1] = library.Lerp(sound.volume[2], sound.volume[3], sound.volumeTime[1]/sound.volumeTime[2])
		end
	end
	
	for k,v in pairs(sound.instances) do
		TickInstance(sound, v)
	end

end

function PlaySound(sound)

	local instance = FindFreeInstance(sound)
	if (instance == nil) then
		return false
	end
	
	instance.reps = 1
	instance.nextBuffer = 1
	instance.bufferI = 0
	instance.buffer = nil
	instance.overflow = false
	instance.volume = -1
	instance.numQueued = 0
	sound.numPlaying = sound.numPlaying + 1
	
	TickInstance(sound, instance)
	
	openal.C.alSourcePlay(instance.source[0])
	
	if (sound.timer == nil) then
		local f = function(dt)
			TickSound(sound, dt)
		end
		sound.timer = timers.Add(f, 0, true)
	end
	
	return true
end

function StopSound(sound)
	if (sound.timer) then
		timers.Remove(sound.timer)
		sound.timer = nil
	end
	
	for k,v in pairs(sound.instances) do
		if (sound:IsPlaying(v)) then
			openal.C.alSourceStop(v.source[0])
			UnqueueBuffers(v)
			v.playing = false
		end
	end
	
	sound.numPlaying = 0
end

function IsPlaying(sound, instance)
	if (instance) then
		local state = SoundState(instance)
		if ((state == openal.consts.AL_PLAYING) or (state == openal.consts.AL_PAUSED)) then
			return true
		end
		return false
	end
	
	return sound.numPlaying > 0
end

function SetPositional(sound, positional, refDistance, maxDistance)

	sound.refDistance = refDistance
	sound.maxDistance = maxDistance

	if (sound.position == positional) then
		return
	end
	
	sound.positional = positional
	
end

function FadeVolume(sound, volume, time)

end

function CacheNew(buffers, maxInstances)
	assert(#buffers <= 32)
	if (maxIntances == nil) then
		maxInstances = 1
	end
	
	local sound = {
		buffers = buffers,
		instances = {}
	}
	
	for i=1,maxInstances do
		local source = ffi.cast(ALuintptr, ffi.C.malloc(ALuintSize))
		ffi.gc(source, function()
			openal.C.alDeleteSources(1, source[0])
			ffi.C.free(source)
		end)
		openal.C.alGenSources(1, source)
		local instance = {
			source = source,
			refDistance = -1,
			maxDistance = -1
		}
		table.insert(sound.instances, instance)
	end
	
	sound.Play = PlaySound
	sound.Stop = StopSound
	sound.SetPositional = SetPositional
	sound.FadeVolume = FadeVolume
	sound.IsPlaying = IsPlaying
	sound.volume = {1, 1, 1}
	sound.volumeTime = {0, 0}
	sound.numPlaying = 0
	sound.positional = false
	sound.pos = vecLib.Vec3New(0, 0, 0)
	return sound
	
end

function self.Create(pcm)
	local buffers = {}
	
	for k,v in pairs(pcm.blocks) do
	
		local numBufs = math.min(v.reps, 2)
	
		local id = ffi.cast(ALuintptr, ffi.C.malloc(ALuintSize*numBufs))
		ffi.gc(id, function() 
			for i=0,(numBufs-1) do
				openal.C.alDeleteBuffers(1, id[i])
			end
			ffi.C.free(id)
		end)
		
		openal.C.alGenBuffers(numBufs, id)
		
		local format = openal.consts.AL_FORMAT_MONO8
		if (v.channels == 2) then
			if (v.bits == 16) then
				format = openal.consts.AL_FORMAT_STEREO16
			else
				format = openal.consts.AL_FORMAT_STEREO8
			end
		elseif (v.bits == 16) then
			format = openal.consts.AL_FORMAT_MONO16
		end
		
		for i=0,(numBufs-1) do
			openal.C.alBufferData(id[i], format, v.pcm, v.size, v.freq)
		end
		
		local buf = {
			id = id,
			reps = v.reps,
			num = numBufs
		}
		
		table.insert(buffers, buf)
	end
	
	buffers.New = CacheNew
	return buffers
end

return self
