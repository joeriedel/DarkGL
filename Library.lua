-- Utility Functions
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

local string = string
local table = table
local math = math
local assert = assert

module("Library")

local self = {}

function self.Lerp(a, b, t)
	return  a + (b-a)*t
end

function self.FloatRand(a, b)
	local x = self.Lerp(a, b, math.random())
	return x
end

function self.IntRand(a, b)
	local x = self.Lerp(a, b, math.random())
	return math.floor(x + 0.5)
end

--[[---------------------------------------------------------------------------
	split string
	http://lua-users.org/wiki/SplitJoin
-----------------------------------------------------------------------------]]

function string:split(delim, maxNb)
    -- Eliminate bad cases...
    if self:find(delim) == nil then
        return { self }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in self:gfind(pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
		local z = self:sub(lastPos)
		if (z ~= "") then
			result[nb + 1] = z
		end
    end
    return result
end

function self.Map(list, f, ...)
	for k,v in pairs(list) do
		list[k] = f(v, ...)
	end
	return list
end

--[[---------------------------------------------------------------------------
	Tokenize a string
-----------------------------------------------------------------------------]]

function self.FindArrayElement(array, value)
	for k,v in pairs(array) do
		if (v == value) then
			return true, k
		end
	end
	return false
end

function self.Tokenize(s)

	local x = {}
	
	if ((s == nil) or (s == "")) then
		return x
	end
	
	local z = ""
	
	local i = 1
	while (i <= #s) do
		local c = s:sub(i, i)
		local b = s:byte(i)
		
		if (b <= 32) then
			if (z ~= "") then
				table.insert(x, z)
				z = "" -- new token
			end
		else
			if (c == "\"") then -- quoted
			
				if (z ~= "") then
					table.insert(x, z)
					z = "" -- new token
				end
			
				-- go until end of quote
				local k = i+1
				while (k <= #s) do
					c = s:sub(k, k)
					if (c == "\"") then
						if (z ~= "") then
							table.insert(x, z)
							z = "" -- new token
						end
						break
					else
						z = z..c
					end
					k = k+1
				end
				
				i = k
				
				if (z ~= "") then
					table.insert(x, z)
					z = "" -- new token
				end
			else
				z = z..c -- build token
			end
		end
	
		i = i+1
	end
	
	if (z ~= "") then
		table.insert(x, z)
		z = "" -- new token
	end
	
	return x

end

function self.GetToken(s, i)

	if (i == nil) then
		i = 1
	end
	
	local z = ""
	
	while (i <= #s) do
		local c = s:sub(i, i)
		local b = s:byte(i)
		
		if (b <= 32) then
			if (z ~= "") then
				return z, i
			end
		else
			if (c == "\"") then -- quoted
			
				if (z ~= "") then
					return z, i
				end
			
				-- go until end of quote
				local k = i+1
				while (k <= #s) do
					c = s:sub(k, k)
					if (c == "\"") then
						return z, (k+1)
					else
						z = z..c
					end
					k = k+1
				end
				
				i = k
				
				if (z ~= "") then
					return z, i
				end
			else
				z = z..c -- build token
			end
		end
	
		i = i+1
	end
	
	if (z == "") then
		z = nil
	end
	
	return z, i

end

function self.SkipWhitespace(s, i)

	if (i == nil) then
		i = 1
	end
	
	while (i <= #s) do
		local b = s:byte(i)
		if (b > 32) then
			return i
		end
		i = i + 1
	end
	
	return nil

end

--[[---------------------------------------------------------------------------
	Linked List
-----------------------------------------------------------------------------]]

function self.LL_New(list)

	list = list or {}
	list.ll_head = nil
	list.ll_tail = nil
	list.ll_size = 0
	
	return list

end

function self.LL_List(item)
	return item.ll_list
end

function self.LL_Head(list)
	return list.ll_head
end

function self.LL_Tail(list)
	return list.ll_tail
end

function self.LL_Next(item)
	return item.ll_next
end

function self.LL_Prev(item)
	return item.ll_prev
end

function self.LL_Size(list)
	return list.ll_size
end

function self.LL_Empty(list)
	return list.ll_head == nil
end

function self.LL_Append(list, item)
	return self.LL_Insert(list, item, list.ll_tail)
end

function self.LL_Do(list, f)

	local item = self.LL_Head(list)
	
	while (item) do
		f(item)
		item = self.LL_Next(item)
	end

end

function self.LL_Insert(list, item, after)

	assert(item.ll_list == nil)
	
	-- special case insert at head
	if after == nil then
		item.ll_prev = nil
		item.ll_next = list.ll_head
		if list.ll_head then
			list.ll_head.ll_prev = item
		end
		list.ll_head = item
		if list.ll_tail == nil then
			list.ll_tail = item
		end
	else
		if after.ll_next then
			after.ll_next.ll_prev = item
		end
		item.ll_next = after.ll_next
		item.ll_prev = after
		after.ll_next = item
		
		if list.ll_tail == after then
			list.ll_tail = item
		end
	end
	
	item.ll_list = list
	list.ll_size = list.ll_size + 1
	
	return item

end

function self.LL_Remove(list, item) -- removes item, and returns next item in list

	if not item then
		return nil
	end
	
	assert(item.ll_list == list)
	
	local next = item.ll_next
	
	if (list.ll_head == item) then
		list.ll_head = item.ll_next
	end
	if (list.ll_tail == item) then
		list.ll_tail = item.ll_prev
	end
	
	if item.ll_prev then
		item.ll_prev.ll_next = item.ll_next
	end
	if item.ll_next then
		item.ll_next.ll_prev = item.ll_prev
	end
	
	item.ll_next = nil
	item.ll_prev = nil
	item.ll_list = nil
	
	list.ll_size = list.ll_size - 1
	
	return next

end

function self.LL_Pop(list)
	local item = list.ll_head
	self.LL_Remove(list, item)
	return item
end

function self.LL_PopTail(list)
	local item = list.ll_tail
	self.LL_Remove(list, item)
	return item
end

return self