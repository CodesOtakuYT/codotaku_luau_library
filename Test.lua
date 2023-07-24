local Std = require(script.Parent)
local Slice = Std.Slice

local function add(a, b) return a + b end
local function multiply(a, b) return a * b end
local function is_even(x) return x % 2 == 0 end

local slice = Slice.new{104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100, 44, 32, 115, 97, 108, 97, 109, 33}
local hash_byte = string.byte('#')

assert(slice:string() == 'hello world, salam!')
assert(slice:sum() == slice:reduce(add))
assert(slice:product() == slice:reduce(multiply))
assert(slice:min() == slice:reduce(math.min))
assert(slice:max() == slice:reduce(math.max))
assert(slice:average() == slice:reduce(add)/#slice)
assert(slice:advance(6):string() == 'world, salam!')
assert(slice:shrink(8):string() == 'world')
assert(slice:at(1) == string.byte('w'))
assert(slice:concat(', ') == '119, 111, 114, 108, 100')
assert(slice:map(add, 1):string() == 'xpsme')
assert(slice:concat(', ') == '120, 112, 115, 109, 101')
assert(slice:map(add, -1):string() == 'world')
local slice2 = slice:clone()
assert(slice:string() == slice2:string())
assert(slice2:sub(1, 1):string() == 'orl')
assert(slice:string() == 'world')
assert(slice2:fill(hash_byte):string() == '###')
assert(slice:string() == 'w###d')

local expr = '1234.345 + 235 * 345'
local s = Slice.new{string.byte(expr, 1, #expr)}
assert(s:string() == expr)

local TokenKind = {
	Unknown = 0,
	Operator = 1,
	Number = 2,
	Whitespace = 3,
}

local function classifier(byte: number)
	local b = string.byte
	if byte == b(' ') then return TokenKind.Whitespace end
	if byte == b('+') or byte == b('*') or byte == b('/') or byte == b('') then
		return TokenKind.Operator
	end
	if (byte >= b('0') and byte <= b('9')) or byte == b('.') then
		return TokenKind.Number
	end
	return TokenKind.Unknown
end

--[[ Expected output:
  2 1234.345
  1 +
  2 235
  1 *
  2 345
]]
for kind, token in s:group_by(classifier) do
	if kind == TokenKind.Whitespace then continue end
	print(kind, token:string())
end

local s = Slice.new{1, 2, 3, 4, 5, 6, 7}

--[[ Expected output:
  2
  4
  6
]]
for x in s:filter(is_even) do
	print(x)
end

--[[ Expected output:
  1:2
  3:4
  5:6
  7
]]
for x in s:chunk(2) do
	print(x:concat(':'))
end

--[[ Expected output:
  1:2
  3:4
  5:6
]]
for x in s:chunk_exact(2) do
	print(x:concat(':'))
end
