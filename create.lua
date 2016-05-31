
math.randomseed(os.clock())
local f, err = io.open('data', 'w')
if not f then
    print('err:', err)
end


for i = 1, 4096 do
    local num = math.random(10240000)
    f:write(tostring(num) .. '\n')
end

f:close()


