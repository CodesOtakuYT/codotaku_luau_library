# Codotaku Luau Library
Luau's standard libary is raw and minimal, unlike other programming languages like Rust and Zig's standard library and C++'s STL.
So luau is far behind by ages in terms of `modern programming techniques`.

Examples:
  - Rust and Zig have slices, C++ have views.
  - Rust have iterators, C++ have ranges.

A slice or a `fat pointer` in lua's terms is basically a table with a start index and an end index. or a table with an offset and a length.
A slice is very useful when you want to pass or receive only a portion of a table, a view into a table (without ownership of the table)
without having to copy the table or construct a new one. it does exist in lua's standard library but in its naked form table.fn(t, i, j).
And slices also give the property that if you modify the table directly or through one of its slices, the table and overlapping slices also
see the changes, since it doesn't have a copy of the table, merely a reference to it.
Slices are also very cheap and small tables to copy and pass around, unlike copying or creating a new big table just to return one of the
portions of the existing table.

An iterator or a generator is very useful as it allows a declarative functional approach into computation and transforming data but its
also useful to save on resources, since iterators are usually `lazy` which means that you only pay for what you want although they come with
some overhead for each iteration. and they work by basically requesting the next computation result, which also avoids creating a new table
with all results, when the user may be interested only in the first result, here is some pseudo code example:
```lua
print(split('hello world, and salam in arabic!')[1])
```
here split will return all words on the sentence although we're only printing the first word, but this problem is avoided with an iterator
```lua
print(split_iterator('hello world, and salam in arabic!').next())
```
