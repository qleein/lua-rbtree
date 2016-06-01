local rb = require "rbtree"




local function test_insert()
    local size = 1024
    local tree, err = rb.new(size)
    assert(tree and not err, "new rbtree failed")

    local t = {}
    local index = 1
    while index <= size do
        local num = math.random(10240000)
        if not t[num] then
            local res, err = tree:insert(num, "Num-" .. tostring(num))
            assert(res and not err, "insert failed")
            t[num] = true
            index = index + 1
        end
    end

    for k, _ in pairs(t) do
        local res, err = tree:find(k)
        assert(res and not err, "insert but not found")
    end

    for i = 1, size do
        local num = math.random(10240000)
        if not t[num] then
            local res, err = tree:find(num)
            assert(not res)
            res, err = tree:insert(num, "Num-" .. tostring(num))
            assert(not res and err == "full")
        else
            local res, err = tree:find(num)
            assert((res == "Num-" .. tostring(num)) and not err)
        end
    end

    return
end


local function test_delete()
    local size = 1024
    local tree, err = rb.new(size)
    assert(tree and not err, "new rbtree failed")

    local t = {}
    local index = 1
    while index <= size do
        local num = math.random(10240000)
        if not t[num] then
            local res, err = tree:insert(num, "Num-" .. tostring(num))
            assert(res and not err, "insert failed")
            t[num] = true
            index = index + 1
        end
    end

    for k, _ in pairs(t) do
        local res, err = tree:find(k)
        assert(res and not err, "insert but not found")
    end

    for k, v in pairs(t) do
        local res = tree:find(k)
        assert(res and res == "Num-" .. tostring(k), "not found")

        local res, err = tree:delete(k)
        assert(res and not err, "delete failed")

        res = tree:find(k)
        assert(not res, "delete but found")
    end

    for k, _ in pairs(t) do
        local res = tree:find(k)
        assert(not res, "insert but not found")
    end

    return
end



local function test_insert_and_delete1()
    local size = 10240
    local tree, err = rb.new(size)
    assert(tree and not err, "new rbtree failed")

    local t = {}
    for i = 1, 10 do
        local index = 1
        while index <= size  do
            local num = math.random(10240000)
            if not t[num] then
                local res, err = tree:insert(num, "Num-" .. tostring(num))
                assert(res and not err, "insert failed")
                t[num] = true
                index = index + 1
            end
        end

        for k, _ in pairs(t) do
            local res, err = tree:find(k)
            assert(res and not err, "insert but not found")
        end

        for k, v in pairs(t) do
            local res = tree:find(k)
            assert(res and res == "Num-" .. tostring(k), "not found")

            local res, err = tree:delete(k)
            assert(res and not err, "delete failed")

            res = tree:find(k)
            assert(not res, "delete but found")
            
            t[k] = nil
        end

        for k, v in pairs(t) do
            assert(not k and not v, "not empty")
        end

    end
    return
end


local function test_insert_and_delete2()
    local size = 10240
    local tree, err = rb.new(size * 2)
    assert(tree and not err, "new rbtree failed")

    local t = {}
    for i = 1, 10 do
        local index = 1
        while index <= size  do
            local num = math.random(10240000)
            if not t[num] then
                local res, err = tree:insert(num, "Num-" .. tostring(num))
                assert(res and not err, "insert failed")
                t[num] = true
                index = index + 1
            end
        end

        for k, _ in pairs(t) do
            local res, err = tree:find(k)
            assert(res and not err, "insert but not found")
        end

        index = 0
        for k, v in pairs(t) do
            local res = tree:find(k)
            assert(res and res == "Num-" .. tostring(k), "not found")

            local res, err = tree:delete(k)
            assert(res and not err, "delete failed")

            res = tree:find(k)
            assert(not res, "delete but found")
            
            t[k] = nil
            index = index + 1
            if index >= size / 10 * 9 then
                break
            end
        end

    end

    for k, v in pairs(t) do
        local res = tree:find(k)
        assert(res and res == "Num-" .. tostring(k), "not found")
    end


    for i = 1, size do
        local num = math.random(10240000)
        if not t[num] then
            local res, err = tree:find(num)
            assert(not res)
        else
            local res, err = tree:find(num)
            assert((res == "Num-" .. tostring(num)) and not err)
        end
    end

    for k, v in pairs(t) do
        local res, err = tree:delete(k)
        assert(res and not err, "delete failed")
        t[k] = nil
    end

    for k, v in pairs(t) do
        assert(not k and not v, "not empty")
    end

    return
end



math.randomseed(os.clock())
test_insert()
test_delete()
test_insert_and_delete1()
test_insert_and_delete2()

--[[

local size = 1024
local tree, err = rb.new(size)
if not tree then
    print('err:', err)
end


for iiiii = 1, 10 do

local t = {}

--tree:all()
local count = 0
while count <= size do
    local num = math.random(10240000)
    local val = 'Num-' .. tostring(num)
    if not t[num] then
        local res , err = tree:insert(num, val)
        if not res then
            print('insert:',err)
            break
        end
        t[num] = true
        count = count + 1
    else
       -- print('dulplicate, key:', num)
    end
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
--[[
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
        print('error key:', num, ' val:', res, ' t.num:', t[num])
    end
end

--return
--[[
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
]]--
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
