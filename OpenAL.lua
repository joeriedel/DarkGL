-- LuaJIT FFI OpenALSoft bindings
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

module("LuaJIT")

local ffi = require("ffi")

ffi.cdef[[

/** Opaque device handle */
typedef struct ALCdevice_struct ALCdevice;
/** Opaque context handle */
typedef struct ALCcontext_struct ALCcontext;

/** 8-bit boolean */
typedef char ALCboolean;

/** character */
typedef char ALCchar;

/** signed 8-bit 2's complement integer */
typedef signed char ALCbyte;

/** unsigned 8-bit integer */
typedef unsigned char ALCubyte;

/** signed 16-bit 2's complement integer */
typedef short ALCshort;

/** unsigned 16-bit integer */
typedef unsigned short ALCushort;

/** signed 32-bit 2's complement integer */
typedef int ALCint;

/** unsigned 32-bit integer */
typedef unsigned int ALCuint;

/** non-negative 32-bit binary integer size */
typedef int ALCsizei;

/** enumerated 32-bit value */
typedef int ALCenum;

/** 32-bit IEEE754 floating-point */
typedef float ALCfloat;

/** 64-bit IEEE754 floating-point */
typedef double ALCdouble;

/** void type (for opaque pointers only) */
typedef void ALCvoid;

/** Context management. */
ALCcontext* alcCreateContext(ALCdevice *device, const ALCint* attrlist);
ALCboolean  alcMakeContextCurrent(ALCcontext *context);
void        alcProcessContext(ALCcontext *context);
void        alcSuspendContext(ALCcontext *context);
void        alcDestroyContext(ALCcontext *context);
ALCcontext* alcGetCurrentContext(void);
ALCdevice*  alcGetContextsDevice(ALCcontext *context);

/** Device management. */
ALCdevice* alcOpenDevice(const ALCchar *devicename);
ALCboolean alcCloseDevice(ALCdevice *device);

/**
 * Error support.
 *
 * Obtain the most recent Device error.
 */
ALCenum alcGetError(ALCdevice *device);

/**
 * Extension support.
 *
 * Query for the presence of an extension, and obtain any appropriate
 * function pointers and enum values.
 */
ALCboolean alcIsExtensionPresent(ALCdevice *device, const ALCchar *extname);
void*      alcGetProcAddress(ALCdevice *device, const ALCchar *funcname);
ALCenum    alcGetEnumValue(ALCdevice *device, const ALCchar *enumname);

/** Query function. */
const ALCchar* alcGetString(ALCdevice *device, ALCenum param);
void           alcGetIntegerv(ALCdevice *device, ALCenum param, ALCsizei size, ALCint *values);

/** Capture function. */
ALCdevice* alcCaptureOpenDevice(const ALCchar *devicename, ALCuint frequency, ALCenum format, ALCsizei buffersize);
ALCboolean alcCaptureCloseDevice(ALCdevice *device);
void       alcCaptureStart(ALCdevice *device);
void       alcCaptureStop(ALCdevice *device);
void       alcCaptureSamples(ALCdevice *device, ALCvoid *buffer, ALCsizei samples);

/** 8-bit boolean */
typedef char ALboolean;

/** character */
typedef char ALchar;

/** signed 8-bit 2's complement integer */
typedef signed char ALbyte;

/** unsigned 8-bit integer */
typedef unsigned char ALubyte;

/** signed 16-bit 2's complement integer */
typedef short ALshort;

/** unsigned 16-bit integer */
typedef unsigned short ALushort;

/** signed 32-bit 2's complement integer */
typedef int ALint;

/** unsigned 32-bit integer */
typedef unsigned int ALuint;

/** non-negative 32-bit binary integer size */
typedef int ALsizei;

/** enumerated 32-bit value */
typedef int ALenum;

/** 32-bit IEEE754 floating-point */
typedef float ALfloat;

/** 64-bit IEEE754 floating-point */
typedef double ALdouble;

/** void type (for opaque pointers only) */
typedef void ALvoid;

void alDopplerFactor(ALfloat value);
void alDopplerVelocity(ALfloat value);
void alSpeedOfSound(ALfloat value);

/**
 * Distance attenuation model.
 * Type:    ALint
 * Range:   [AL_NONE, AL_INVERSE_DISTANCE, AL_INVERSE_DISTANCE_CLAMPED,
 *           AL_LINEAR_DISTANCE, AL_LINEAR_DISTANCE_CLAMPED,
 *           AL_EXPONENT_DISTANCE, AL_EXPONENT_DISTANCE_CLAMPED]
 * Default: AL_INVERSE_DISTANCE_CLAMPED
 *
 * The model by which sources attenuate with distance.
 *
 * None     - No distance attenuation.
 * Inverse  - Doubling the distance halves the source gain.
 * Linear   - Linear gain scaling between the reference and max distances.
 * Exponent - Exponential gain dropoff.
 *
 * Clamped variations work like the non-clamped counterparts, except the
 * distance calculated is clamped between the reference and max distances.
 */
void alDistanceModel(ALenum distanceModel);

/** Renderer State management. */
void alEnable(ALenum capability);
void alDisable(ALenum capability);
ALboolean alIsEnabled(ALenum capability);

/** State retrieval. */
const ALchar* alGetString(ALenum param);
void alGetBooleanv(ALenum param, ALboolean *values);
void alGetIntegerv(ALenum param, ALint *values);
void alGetFloatv(ALenum param, ALfloat *values);
void alGetDoublev(ALenum param, ALdouble *values);
ALboolean alGetBoolean(ALenum param);
ALint alGetInteger(ALenum param);
ALfloat alGetFloat(ALenum param);
ALdouble alGetDouble(ALenum param);

/**
 * Error retrieval.
 *
 * Obtain the first error generated in the AL context since the last check.
 */
ALenum alGetError(void);

/**
 * Extension support.
 *
 * Query for the presence of an extension, and obtain any appropriate function
 * pointers and enum values.
 */
ALboolean alIsExtensionPresent(const ALchar *extname);
void* alGetProcAddress(const ALchar *fname);
ALenum alGetEnumValue(const ALchar *ename);


/** Set Listener parameters */
void alListenerf(ALenum param, ALfloat value);
void alListener3f(ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
void alListenerfv(ALenum param, const ALfloat *values);
void alListeneri(ALenum param, ALint value);
void alListener3i(ALenum param, ALint value1, ALint value2, ALint value3);
void alListeneriv(ALenum param, const ALint *values);

/** Get Listener parameters */
void alGetListenerf(ALenum param, ALfloat *value);
void alGetListener3f(ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
void alGetListenerfv(ALenum param, ALfloat *values);
void alGetListeneri(ALenum param, ALint *value);
void alGetListener3i(ALenum param, ALint *value1, ALint *value2, ALint *value3);
void alGetListeneriv(ALenum param, ALint *values);


/** Create Source objects. */
void alGenSources(ALsizei n, ALuint *sources);
/** Delete Source objects. */
void alDeleteSources(ALsizei n, const ALuint *sources);
/** Verify a handle is a valid Source. */
ALboolean alIsSource(ALuint source);

/** Set Source parameters. */
void alSourcef(ALuint source, ALenum param, ALfloat value);
void alSource3f(ALuint source, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
void alSourcefv(ALuint source, ALenum param, const ALfloat *values);
void alSourcei(ALuint source, ALenum param, ALint value);
void alSource3i(ALuint source, ALenum param, ALint value1, ALint value2, ALint value3);
void alSourceiv(ALuint source, ALenum param, const ALint *values);

/** Get Source parameters. */
void alGetSourcef(ALuint source, ALenum param, ALfloat *value);
void alGetSource3f(ALuint source, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
void alGetSourcefv(ALuint source, ALenum param, ALfloat *values);
void alGetSourcei(ALuint source,  ALenum param, ALint *value);
void alGetSource3i(ALuint source, ALenum param, ALint *value1, ALint *value2, ALint *value3);
void alGetSourceiv(ALuint source,  ALenum param, ALint *values);


/** Play, replay, or resume (if paused) a list of Sources */
void alSourcePlayv(ALsizei n, const ALuint *sources);
/** Stop a list of Sources */
void alSourceStopv(ALsizei n, const ALuint *sources);
/** Rewind a list of Sources */
void alSourceRewindv(ALsizei n, const ALuint *sources);
/** Pause a list of Sources */
void alSourcePausev(ALsizei n, const ALuint *sources);

/** Play, replay, or resume a Source */
void alSourcePlay(ALuint source);
/** Stop a Source */
void alSourceStop(ALuint source);
/** Rewind a Source (set playback postiton to beginning) */
void alSourceRewind(ALuint source);
/** Pause a Source */
void alSourcePause(ALuint source);

/** Queue buffers onto a source */
void alSourceQueueBuffers(ALuint source, ALsizei nb, const ALuint *buffers);
/** Unqueue processed buffers from a source */
void alSourceUnqueueBuffers(ALuint source, ALsizei nb, ALuint *buffers);


/** Create Buffer objects */
void alGenBuffers(ALsizei n, ALuint *buffers);
/** Delete Buffer objects */
void alDeleteBuffers(ALsizei n, const ALuint *buffers);
/** Verify a handle is a valid Buffer */
ALboolean alIsBuffer(ALuint buffer);

/** Specifies the data to be copied into a buffer */
void alBufferData(ALuint buffer, ALenum format, const ALvoid *data, ALsizei size, ALsizei freq);

/** Set Buffer parameters, */
void alBufferf(ALuint buffer, ALenum param, ALfloat value);
void alBuffer3f(ALuint buffer, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
void alBufferfv(ALuint buffer, ALenum param, const ALfloat *values);
void alBufferi(ALuint buffer, ALenum param, ALint value);
void alBuffer3i(ALuint buffer, ALenum param, ALint value1, ALint value2, ALint value3);
void alBufferiv(ALuint buffer, ALenum param, const ALint *values);

/** Get Buffer parameters. */
void alGetBufferf(ALuint buffer, ALenum param, ALfloat *value);
void alGetBuffer3f(ALuint buffer, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
void alGetBufferfv(ALuint buffer, ALenum param, ALfloat *values);
void alGetBufferi(ALuint buffer, ALenum param, ALint *value);
void alGetBuffer3i(ALuint buffer, ALenum param, ALint *value1, ALint *value2, ALint *value3);
void alGetBufferiv(ALuint buffer, ALenum param, ALint *values);
]]

local openal = ffi.load("OpenAL32")

local consts = {
['ALC_INVALID']                           = 0,
['ALC_VERSION_0_1']                       = 1,
['ALC_FALSE']                             = 0,
['ALC_TRUE']                              = 1,
['ALC_FREQUENCY']                         = 0x1007,
['ALC_REFRESH']                           = 0x1008,
['ALC_SYNC']                              = 0x1009,
['ALC_MONO_SOURCES']                      = 0x1010,
['ALC_STEREO_SOURCES']                    = 0x1011,
['ALC_NO_ERROR']                          = 0,
['ALC_INVALID_DEVICE']                    = 0xA001,
['ALC_INVALID_CONTEXT']                   = 0xA002,
['ALC_INVALID_ENUM']                      = 0xA003,
['ALC_INVALID_VALUE']                     = 0xA004,
['ALC_OUT_OF_MEMORY']                     = 0xA005,
['ALC_MAJOR_VERSION']                     = 0x1000,
['ALC_MINOR_VERSION']                     = 0x1001,
['ALC_ATTRIBUTES_SIZE']                   = 0x1002,
['ALC_ALL_ATTRIBUTES']                    = 0x1003,
['ALC_DEFAULT_DEVICE_SPECIFIER']          = 0x1004,
['ALC_DEVICE_SPECIFIER']                  = 0x1005,
['ALC_EXTENSIONS']                        = 0x1006,
['ALC_EXT_CAPTURE']                       = 1,
['ALC_CAPTURE_DEVICE_SPECIFIER']          = 0x310,
['ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER']  = 0x311,
['ALC_CAPTURE_SAMPLES']                   = 0x312,
['ALC_ENUMERATE_ALL_EXT']                 = 1,
['ALC_DEFAULT_ALL_DEVICES_SPECIFIER']     = 0x1012,
['ALC_ALL_DEVICES_SPECIFIER']             = 0x1013,
['AL_NONE']                               = 0,
['AL_FALSE']                              = 0,
['AL_TRUE']                               = 1,
['AL_SOURCE_RELATIVE']                    = 0x202,
['AL_CONE_INNER_ANGLE']                   = 0x1001,
['AL_CONE_OUTER_ANGLE']                   = 0x1002,
['AL_PITCH']                              = 0x1003,
['AL_POSITION']                           = 0x1004,
['AL_DIRECTION']                          = 0x1005,
['AL_VELOCITY']                           = 0x1006,
['AL_LOOPING']                            = 0x1007,
['AL_BUFFER']                             = 0x1009,
['AL_GAIN']                               = 0x100A,
['AL_MIN_GAIN']                           = 0x100D,
['AL_MAX_GAIN']                           = 0x100E,
['AL_ORIENTATION']                        = 0x100F,
['AL_SOURCE_STATE']                       = 0x1010,
['AL_INITIAL']                            = 0x1011,
['AL_PLAYING']                            = 0x1012,
['AL_PAUSED']                             = 0x1013,
['AL_STOPPED']                            = 0x1014,
['AL_BUFFERS_QUEUED']                     = 0x1015,
['AL_BUFFERS_PROCESSED']                  = 0x1016,
['AL_REFERENCE_DISTANCE']                 = 0x1020,
['AL_ROLLOFF_FACTOR']                     = 0x1021,
['AL_CONE_OUTER_GAIN']                    = 0x1022,
['AL_MAX_DISTANCE']                       = 0x1023,
['AL_SEC_OFFSET']                         = 0x1024,
['AL_SAMPLE_OFFSET']                      = 0x1025,
['AL_BYTE_OFFSET']                        = 0x1026,
['AL_SOURCE_TYPE']                        = 0x1027,
['AL_STATIC']                             = 0x1028,
['AL_STREAMING']                          = 0x1029,
['AL_UNDETERMINED']                       = 0x1030,
['AL_FORMAT_MONO8']                       = 0x1100,
['AL_FORMAT_MONO16']                      = 0x1101,
['AL_FORMAT_STEREO8']                     = 0x1102,
['AL_FORMAT_STEREO16']                    = 0x1103,
['AL_FREQUENCY']                          = 0x2001,
['AL_BITS']                               = 0x2002,
['AL_CHANNELS']                           = 0x2003,
['AL_SIZE']                               = 0x2004,
['AL_UNUSED']                             = 0x2010,
['AL_PENDING']                            = 0x2011,
['AL_PROCESSED']                          = 0x2012,
['AL_NO_ERROR']                           = 0,
['AL_INVALID_NAME']                       = 0xA001,
['AL_INVALID_ENUM']                       = 0xA002,
['AL_INVALID_VALUE']                      = 0xA003,
['AL_INVALID_OPERATION']                  = 0xA004,
['AL_OUT_OF_MEMORY']                      = 0xA005,
['AL_VENDOR']                             = 0xB001,
['AL_VERSION']                            = 0xB002,
['AL_RENDERER']                           = 0xB003,
['AL_EXTENSIONS']                         = 0xB004,
['AL_DOPPLER_FACTOR']                     = 0xC000,
['AL_DOPPLER_VELOCITY']                   = 0xC001,
['AL_SPEED_OF_SOUND']                     = 0xC003,
['AL_DISTANCE_MODEL']                     = 0xD000,
['AL_INVERSE_DISTANCE']                   = 0xD001,
['AL_INVERSE_DISTANCE_CLAMPED']           = 0xD002,
['AL_LINEAR_DISTANCE']                    = 0xD003,
['AL_LINEAR_DISTANCE_CLAMPED']            = 0xD004,
['AL_EXPONENT_DISTANCE']                  = 0xD005,
['AL_EXPONENT_DISTANCE_CLAMPED']          = 0xD006
}

local self = {}

local Shutdown = function()
	if (self.ctx) then
		openal.alcDestroyContext(ffi.gc(self.ctx, nil))
		self.ctx = nil
	end
	if (self.dev) then
		openal.alcCloseDevice(ffi.gc(self.dev, nil))
		self.dev = nil
	end
end

local Initialize = function(driver, attrs)

	self.dev = ffi.gc(openal.alcOpenDevice(driver), openal.alcCloseDevice)
	self.ctx = nil
	
	if (self.dev) then
		self.ctx = ffi.gc(openal.alcCreateContext(self.dev, attrs), openal.alcDestroyContext)
		if (self.ctx) then
			openal.alcMakeContextCurrent(self.ctx)
		end
	end
	
	if (not (self.dev and self.ctx)) then
		Shutdown()
		log.Warning("Audio initialization failed.\n")
	end
end

self.C = openal
self.consts = consts
self.Initialize = Initialize
self.Shutdown = Shutdown

return self