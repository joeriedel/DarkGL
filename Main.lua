-- DarkGL Main Entry Point
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

require("CStdLib") -- load ffi.C with stdlib

local ffi = require("ffi")
local ljgl = require("lujgl")
local gl = ljgl.gl
local glconst = ljgl.glconst
local log = require("Log")
local gob = require("GOB")
local timers = require("Timers")
local openal = require("OpenAL")
local imuse = require("iMuse")

log.Print("DarkGL starting...\n")

openal.Initialize()
imuse.Initialize()

--gob.Open("DARK.GOB")
gob.Open("SOUNDS.GOB")

--[[for k,v in pairs(gob.files) do

	if (v.type == "GMD") then
		gob.Load(v.name)
	end

end]]

--local sound = gob.Load("WELD-2.VOC")
--sound:Play()

imuse.PlaySong("01")


ljgl.initialize("DarkGL", 1280, 720, {})

function Render()
	gl.glClear(bit.bor(glconst.GL_COLOR_BUFFER_BIT, glconst.GL_DEPTH_BUFFER_BIT))
end

ljgl.setRenderCallback(Render)

local lastTickTime = nil
function TickState()
	if (lastTickTime == nil) then
		lastTickTime = ljgl.getTime()
	end
	
	local time = ljgl.getTime()
	local dt = time - lastTickTime
	lastTickTime = time
	
	if (dt > 0) then
		timers.Tick(dt)
	end
	
end
ljgl.setIdleCallback(TickState)

local mode = 0

function Event(event,...)
	
--	print("Event", event, ...)
	if (event == "key") then
		local key, scancode, pressed, rep = ...
		if (pressed and not rep) then
			if (mode == 0) then
				log.Print("triggering fight\n")
				imuse.Fight()
				mode = 1
			else
				log.Print("triggering stalk\n")
				imuse.Stalk()
				mode = 0
			end
		end
	end
	
end
ljgl.setEventCallback(Event)

ljgl.mainLoop()

print("Done")