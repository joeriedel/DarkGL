-- Timers
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
module("Timers")

local library = require("Library")

local timers = library.LL_New()
local tick = -1

local self = {}

function self.Add(func, time, repeats)
	local timer = {
		func = func,
		time = 0,
		period = time,
		repeats = repeats,
		tick = 0
	}
	if (tick < 0) then
		timer.tick = -99
	end
	
	return library.LL_Append(timers, timer)
end

function self.Remove(timer)
	local list = library.LL_List(timer)
	assert(list)
	library.LL_Remove(list, timer)
end

function self.Tick(dt)
	tick = tick + 1
	local item = library.LL_Head(timers)
	
	while (item) do
		local next = library.LL_Next(item)
		
		if (item.tick ~= tick) then
			-- don't tick new timers added in timer refresh
			if (item.tick ~= 0) then
				item.time = item.time + dt
				if (item.time >= item.period) then
					item.func(item.time, dt)
					item.time = 0
					if (not item.repeats) then
						library.LL_Remove(timers, item)
					end
				end
			end
			
			item.tick = tick
		end
		
		-- next timer was removed, breaking our ability to move forward
		if (next and (library.LL_List(next) == nil)) then
			item = library.LL_Head(timers) -- start from the top again
		else
			item = next
		end
	end
end

return self