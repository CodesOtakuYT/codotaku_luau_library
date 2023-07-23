local Std = require(script.Parent)
local Slice = Std.Slice

local function add(a, b) return a + b end
local function multiply(a, b) return a * b end

local slice = Slice.new{104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100, 44, 32, 115, 97, 108, 97, 109, 33}
local hash_byte = string.byte('#')

assert( slice:string() 					== 'hello world, salam!' 	)
assert( slice:sum() 					== slice:reduce(add) 		)
assert( slice:product() 				== slice:reduce(multiply) 	)
assert( slice:min() 					== slice:reduce(math.min) 	)
assert( slice:max() 					== slice:reduce(math.max) 	)
assert( slice:average() 				== slice:reduce(add)/#slice )
assert( slice:advance(6):string() 		== 'world, salam!' 			)
assert( slice:shrink(8):string() 		== 'world' 					)
assert( slice:at(1) 					== string.byte('w') 		)
assert( slice:concat(', ')				== '119, 111, 114, 108, 100')
assert(	slice:map(add, 1):string()		== 'xpsme'					)
assert( slice:concat(', ')				== '120, 112, 115, 109, 101')
assert(	slice:map(add, -1):string()		== 'world'					)
local slice2 = slice:clone()
assert( slice:string() 					== slice2:string()			)
assert( slice2:sub(1, 1):string()		== 'orl'					)
assert(	slice:string()					== 'world'					)
assert(	slice2:fill(hash_byte):string()	== '###'					)
assert( slice:string()					== 'w###d'					)
