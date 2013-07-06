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
local log = require("Log")
local gl = ljgl.gl
local glconst = ljgl.glconst

log.Print("DarkGL starting...\n")
ljgl.initialize("DarkGL", 1280, 720, {})

function Render()
	gl.glClear(bit.bor(glconst.GL_COLOR_BUFFER_BIT, glconst.GL_DEPTH_BUFFER_BIT))
end

ljgl.setRenderCallback(Render)

function TickState()

end
ljgl.setIdleCallback(TickState)

function Event(event,...)
	print("Event", event, ...)
end
ljgl.setEventCallback(Event)

ljgl.mainLoop()

print("Done")