# lua-rbtree
Red-black tree implementation on lua(based on ffi)

#Status
test ok

#Sample
```Lua
local rb = require "rbtree"

local tree, err = rb.new(1024)
if not tree then
  print("new failed:", err)
  return
end

local res, err = tree:insert("I'm key", "I'm value")
if not res then
  print("insert failed:", err)
  return
end

local res = tree:find("I'm key")
if not res or res ~= "I'm value" then
  print("find failed:")
  return
end

local res, err = tree:delete("I'm key")
if not reshen
  print("delete failed:", err)
  return
end
```
  
