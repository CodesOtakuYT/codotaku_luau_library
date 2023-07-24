--[[ LICENCE
MIT License

Copyright (c) 2023 Codotaku

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

--[[ API(23)
Class(1)
	Slice = {ClassName = 'Slice'}
Metamethod(1)
	__len()
Constructor(1)
	new(t: table, i: number?, j: number?)
Copy Constructor(1)
	clone()
Getter method(1)
	at(index: number)
Self mutating method(3)
	shrink(length: number)
	advance(offset: number)
	sub(offset: number, length: number?)
Functional method(2)
	foreach(fn, ...)
	reduce(fn, ...)
 Mathematical method(5)
	sum()
	product()
	average()
	min()
	max()
Table mutating method(3)
	map(fn, ...)
	fill(value)
	fill_with(fn, ...)
Conversion method(4)
	table(): table
	string(seperator: string?): string
	concat(seperator: string?): string
	unpack()
Iterator method(4)
	filter(predicate)
	chunk_exact(chunk_size: number)
	chunk(chunk_size: number)
	group_by(classifier)
]]

--[[ Goals
	-- Performance before readability
	-- Using the standard library when possible
	-- Independent methods as much as reasonable
]]

--[[ Inspiration
	-- Rust standard library (https://doc.rust-lang.org/std/primitive.slice.html)
]]

-- Class
local Slice = {ClassName = 'Slice'}

-- Metamethod

Slice.__index = Slice

function Slice:__len()
	return (self.j or #self.t) - self.i + 1
end

-- Constructor

function Slice.new(t: table, i: number?, j: number?)
	return setmetatable({
		t = t,
		i = i or 1,
		j = j,
	}, Slice)
end

-- Copy Constructor
Slice.clone = table.clone

-- Getter method

function Slice:at(index: number)
	return self.t[index + self.i - 1]
end

-- Self mutating method

function Slice:shrink(length: number)
	length = length or 1
	self.j = self.j and self.j - length or #self.t - length
	return self
end

function Slice:advance(offset: number)
	offset = offset or 1
	self.i += offset
	return self
end

function Slice:sub(offset: number, length: number?)
	self.i += offset
	self.j = self.j and self.j - length or #self.t - length
	return self
end

-- Functional method

function Slice:foreach(fn, ...)
	for i = self.i, self.j or #self.t do
		fn(self.t[i], ...)
	end
	return self
end

function Slice:reduce(fn, ...)
	local result = self.t[self.i]	
	for i = self.i + 1, self.j or #self.t do
		result = fn(result, self.t[i], ...)
	end
	return result
end

-- Mathematical method

function Slice:sum()
	local result = self.t[self.i]	
	for i = self.i + 1, self.j or #self.t do
		result += self.t[i]
	end
	return result
end

function Slice:product()
	local result = self.t[self.i]	
	for i = self.i + 1, self.j or #self.t do
		result *= self.t[i]
	end
	return result
end

function Slice:average()
	local result = self.t[self.i]
	local fin = self.j or #self.t
	for i = self.i + 1, fin do
		result += self.t[i]
	end
	return result/(fin - self.i + 1)
end

function Slice:min()
	local result = self.t[self.i]
	local fin = self.j or #self.t
	for i = self.i + 1, fin do
		local item = self.t[i]
		result = result > item and item or result
	end
	return result
end

function Slice:max()
	local result = self.t[self.i]
	local fin = self.j or #self.t
	for i = self.i + 1, fin do
		local item = self.t[i]
		result = result > item and result or item
	end
	return result
end

-- Table mutating method

function Slice:map(fn, ...)
	for i = self.i, self.j or #self.t do
		self.t[i] = fn(self.t[i], ...)
	end
	return self
end

function Slice:fill(value)
	for i = self.i, self.j or #self.t do
		self.t[i] = value
	end
	return self
end

function Slice:fill_with(fn, ...)
	for i = self.i, self.j or #self.t do
		self.t[i] = fn(...)
	end
	return self
end

-- Conversion method

function Slice:table(): table
	local copy = table.create((self.j or #self.t) - self.i + 1)
	table.move(self.t, self.i, self.j or #self.t, 1, copy)
	return copy
end

function Slice:string(seperator: string?): string
	local t = table.create((self.j or #self.t) - self.i + 1)
	for i = self.i, self.j or #self.t do
		t[i - self.i + 1] = string.char(self.t[i])
	end
	return table.concat(t, seperator)
end

function Slice:concat(seperator: string?): string
	return table.concat(self.t, seperator, self.i, self.j)
end

function Slice:unpack()
	return table.unpack(self.t, self.i, self.j)
end

-- Iterator method

function Slice:filter(predicate)
	local i, j = self.i - 1, self.j or #self.t

	return function()
		while true do
			i += 1
			if i > j then return end 
			local item = self.t[i]
			if predicate(item) then return item end
		end
	end
end

function Slice:chunk_exact(chunk_size: number)
	local i = self.i - chunk_size
	local j = self.j or #self.t

	return function()
		i += chunk_size
		local fin = i + chunk_size - 1
		if fin > j then return end
		return setmetatable({
			t = self.t,
			i = i,
			j = fin,
		}, Slice)
	end
end

function Slice:chunk(chunk_size: number)
	local i = self.i - chunk_size
	local j = self.j or #self.t
	
	return function()
		i += chunk_size
		local fin = i + chunk_size - 1
		if fin > j then
			if i > j then return end
			return setmetatable({
				t = self.t,
				i = i,
				j = j,
			}, Slice)
		end
		return setmetatable({
			t = self.t,
			i = i,
			j = fin,
		}, Slice)
	end
end

function Slice:group_by(classifier)
	local i = self.i
	local prev_i = i
	local prev = classifier(self.t[i])
	local j = self.j or #self.t
	
	return function()
		while true do
			i += 1
			if i > j then return end
			local current = classifier(self.t[i])
			if i == j then
				return current, setmetatable({
					t = self.t,
					i = prev_i,
					j = i,
				}, Slice)
			end
			if prev ~= current then
				local slice = setmetatable({
					t = self.t,
					i = prev_i,
					j = i - 1,
				}, Slice)
				prev_i = i
				local tmp = prev
				prev = current
				return tmp, slice
			end
		end
	end
end

-- Return

return Slice
