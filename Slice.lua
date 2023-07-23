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
	foreach(fn)
	reduce(fn)
 Mathematical method(5)
	sum(fn)
	product(fn)
	average(fn)
	min()
	max()
Table mutating method(3)
	map(fn)
	fill(value)
	fill_with(fn)
Conversion method(4)
	table(): table
	string(seperator: string?): string
	concat(seperator: string?): string
	unpack()
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
function Slice:clone()
	return table.clone(self)
end

-- Getter method

function Slice:at(index: number)
	return self.t[index + self.i]
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
end

-- Functional method

function Slice:foreach(fn)
	for i = self.i, self.j or #self.t do
		fn(self.t[i])
	end
	return self
end

function Slice:reduce(fn)
	local result = self.t[1]	
	for i = self.i + 1, self.j or #self.t do
		result = fn(result, self.t[i])
	end
	return result
end

-- Mathematical method

function Slice:sum(fn)
	local result = self.t[1]	
	for i = self.i + 1, self.j or #self.t do
		result += self.t[i]
	end
	return result
end

function Slice:product(fn)
	local result = self.t[1]	
	for i = self.i + 1, self.j or #self.t do
		result *= self.t[i]
	end
	return result
end

function Slice:average(fn)
	local result = self.t[1]
	local fin = self.j or #self.t
	for i = self.i + 1, fin do
		result += self.t[i]
	end
	return result/(fin - self.i + 1)
end

function Slice:min()
	local result = self.t[1]
	local fin = self.j or #self.t
	for i = self.i + 1, fin do
		local item = self.t[i]
		result = result > item and item or result
	end
	return result
end

function Slice:max()
	local result = self.t[1]
	local fin = self.j or #self.t
	for i = self.i + 1, fin do
		local item = self.t[i]
		result = result > item and result or item
	end
	return result
end

-- Table mutating method

function Slice:map(fn)
	for i = self.i, self.j or #self.t do
		self.t[i] = fn(self.t[i])
	end
	return self
end

function Slice:fill(value)
	for i = self.i, self.j or #self.t do
		self.t[i] = value
	end
end

function Slice:fill_with(fn)
	for i = self.i, self.j or #self.t do
		self.t[i] = fn()
	end
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

-- Return

return Slice
