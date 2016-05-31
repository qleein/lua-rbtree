local rb = require "rbtree"


local size = 10240
local tree, err = rb.new(size)
if not tree then
    print('err:', err)
end

local f = io.open('data', 'r')
if not f then
    print('open err')
    return
end

local t = {}
for line in f:lines() do
    t[tonumber(line)] = true
end



for k, v in pairs(t) do
    print('k:', k)
        tree:insert(k, 'Num-' .. tostring(k))
end

--tree:all()
for k, v in pairs(t) do
    local res = tree:find(k)
    if not res or res ~= ('Num-' .. tostring(k)) then
        print('fatal error, not found')
    else
       -- print('successful, key:', k, ' val:', res)
    end

end

for i = 1, 102400 do
    local num = math.random(10240000)
    local res = tree:find(num)
    local exist
    if not res or res ~= ('Num-' .. tostring(num)) then
        exist = false
    else
        exist = true
    end

    if (not t[num] and exist) or (t[num] and not exist)then
        print('error ker:', num, ' val:', res, ' t.num:', t[num])
    end
end

--return

for k, v in pairs(t) do
    local res = tree:delete(k)
    if not res then
        return
    end
end

for k, v in pairs(t) do
    local res = tree:find(k)
    if not res then
        --print('successful, key:', k, ' val:', res)
    else
        print('fatal error not delete, res:', res, ' k:', k)
    end
end

--[[
tree:insert(4, 'First')
tree:insert(443, 'Second')
tree:insert(453, 'Third')
tree:insert(4344312, 'Num-4344312')
tree:insert(434312, 'Num-434312')
tree:insert(34312, 'Num-34312')
tree:insert(34352, 'Num-34352')
tree:insert(3352, 'Num-3352')
]]--


--[[
local res = tree:find(5)
print('find 5 res:', res)

res = tree:find(4)
print('find 4 res:', res)

res = tree:find(444)
print('find 444 res:', res)

res = tree:find(443)
print('find 443 res:', res)

res = tree:find(453)
print('find 453 res:', res)

tree:delete(4)
res = tree:find(4)
print('find 4 res:', res)
]]--
