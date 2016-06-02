local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_sizeof = ffi.sizeof
local ffi_cast = ffi.cast
local ffi_fill = ffi.fill
local setmetatable = setmetatable
local tonumber = tonumber
local assert = assert
local RED = 1
local BLACK = 0


local _M = { version = 1.0 }
local mt = { __index = _M }


ffi.cdef[[
    typedef uintptr_t   rbtree_key;
    typedef struct rbtree_node_s rbtree_node;
    typedef rbtree_node *         rbtree_index;
    struct rbtree_node_s {
        rbtree_key      key;
        rbtree_index    parent;
        rbtree_index    left;
        rbtree_index    right;
        int             color;
    };
]]


local uintptr_t = ffi.typeof("uintptr_t")
local NULL = ffi.NULL


local function array_init(size)
    if not size then
        return nil, "size not number"
    end

    size = tonumber(size)
    if size <= 0 then
        return nil, "size too small"
    end
    
    if size > 1048576 then
        return nil, "size too large"
    end

    -- q[0].parent points to root node
    -- q[0].right points to next free node
    -- q[0].left points to last free node
    -- q[1] sentinel node
    local q = ffi_new("rbtree_node[?]", size + 2)
    ffi_fill(q, ffi_sizeof("rbtree_node", size + 2), 0)

    local sentinel = q[1]
    sentinel.color = BLACK

    local prev = q[0]
    for i = 2, size + 1 do
        local e = q[i]
        prev.right = e
        e.left = prev
        prev = e
    end

    local last = q[size + 1]
    last.right = q[0]
    q[0].left = last;
    q[0].parent = q[1]

    return q
end


local function queue_remove_head(head)
    local node = head.right
    if node == head then
        return nil, "full"
    end

    local n = node.right
    n.left = head
    head.right = n

    return node
end


local function queue_insert_head(head, node)
    local n = head.right

    node.right = n
    node.left = head
    head.right = node
    n.left = node

    return
end


local function ptr2num(ptr)
    return tonumber(ffi_cast(uintptr_t, ptr))
end


local function rbtree_min(node, sentinel)
    --[[
    --This code could not get the minium node,
    --Maybe there is some bugs,
    --if use jit.off(),It would ok.
    while node.left ~= sentinel do
        node = node.left
    end

    ]]--

    while true do
        if node.left == sentinel then
            break
        end
        node = node.left
    end

    return node
end


local function rbtree_left_rotate(array, sentinel, node)
    local temp = node.right
    node.right = temp.left

    if temp.left ~= sentinel then
        temp.left.parent = node
    end

    temp.parent = node.parent
    if node == array[0].parent then
        array[0].parent = temp

    elseif node == node.parent.left then
        node.parent.left = temp

    else
        node.parent.right = temp
    end

    temp.left = node
    node.parent = temp
    return
end


local function rbtree_right_rotate(array, sentinel, node)
    local temp = node.left
    node.left = temp.right

    if (temp.right ~= sentinel) then
        temp.right.parent = node
    end

    temp.parent = node.parent
    if node == array[0].parent then
        array[0].parent = temp

    elseif node == node.parent.left then
        node.parent.left = temp

    else
        node.parent.right = temp
    end

    temp.right = node
    node.parent = temp
    return
end


local function rbtree_insert_value(temp, node, sentinel)
    local p
    while true do
        if node.key < temp.key then
            p = temp.left

        else
            p = temp.right
        end

        if p == sentinel then
            break
        end

        temp = p
    end

    if node.key < temp.key then
        temp.left = node

    else
        temp.right = node
    end

    node.parent = temp
    node.left = sentinel
    node.right = sentinel
    node.color = RED
    return
end


local function rbtree_insert(array, node, insert)
    local root = array[0].parent
    local sentinel = array[1]

    if root == sentinel then
        node.parent = NULL
        node.left = sentinel
        node.right = sentinel
        node.color = BLACK
        array[0].parent = node
        return
    end

    insert(root, node, sentinel)
    -- re-balance tree
    while node ~= array[0].parent and node.parent.color == RED do
        if node.parent == node.parent.parent.left then
            local temp = node.parent.parent.right

            if temp.color == RED then
                node.parent.color = BLACK
                temp.color = BLACK
                node.parent.parent.color = RED
                node = node.parent.parent

            else
                if node == node.parent.right then
                    node = node.parent
                    rbtree_left_rotate(array, sentinel, node)
                end

                node.parent.color = BLACK
                node.parent.parent.color = RED
                rbtree_right_rotate(array, sentinel, node.parent.parent)
            end
        
        else
            local temp = node.parent.parent.left

            if temp.color == 1 then
                node.parent.color = BLACK
                temp.color = BLACK
                node.parent.parent.color = RED
                node = node.parent.parent

            else
                if node == node.parent.left then
                    node = node.parent
                    rbtree_right_rotate(array, sentinel, node)
                end

                node.parent.color = BLACK
                node.parent.parent.color = RED
                rbtree_left_rotate(array, sentinel, node.parent.parent)
            end
        end
    end

    array[0].parent.color = BLACK           
    return
end


local function rbtree_delete(array, node)
    local sentinel = array[1]
    local temp, subst
    if node.left == sentinel then
        temp = node.right
        subst = node

    elseif node.right == sentinel then
        temp = node.left
        subst = node
    else

        subst = rbtree_min(node.right, sentinel)
        assert(subst.left == sentinel)
        temp = subst.right
    end

    if subst == array[0].parent then
        array[0].parent = temp
        temp.parent = NULL
        temp.color = BLACK

        node.left = NULL
        node.right = NULL
        node.parent = NULL
        node.key = 0

        return
    end

    local red = (subst.color == RED)

    if subst == subst.parent.left then
        subst.parent.left = temp

    else
        subst.parent.right = temp
    end

    if subst == node then
        temp.parent = subst.parent

    else
        if subst.parent == node then
            temp.parent = subst
        
        else
            temp.parent = subst.parent
        end

        subst.left = node.left
        subst.right = node.right
        subst.parent = node.parent
        subst.color = node.color
        
        if node == array[0].parent then
            array[0].parent = subst

        else
            if node == node.parent.left then
                node.parent.left = subst

            else
                node.parent.right = subst
            end
        end

        if subst.left ~= sentinel then
            subst.left.parent = subst
        end

        if subst.right ~= sentinel then
            subst.right.parent = subst
        end
    end

    node.left = NULL
    node.right = NULL
    node.parent = NULL
    node.key = 0

    if red then
        return
    end

    -- a delete fixup
    while temp ~= array[0].parent and temp.color == BLACK do

        if temp == temp.parent.left then
            local w = temp.parent.right
            if w.color == RED then
                w.color = BLACK
                temp.parent.color = RED
                rbtree_left_rotate(array, sentinel, temp.parent)

                w = temp.parent.right
            end

            if w.left.color == BLACK and w.right.color == BLACK then
                w.color = RED
                temp = temp.parent

            else
                if w.right.color == BLACK then
                    w.left.color = BLACK
                    w.color = RED
                    rbtree_right_rotate(array, sentinel, w)
                    w = temp.parent.right
                end

                w.color = temp.parent.color
                temp.parent.color = BLACK
                w.right.color = BLACK
                rbtree_left_rotate(array, sentinel, temp.parent)

                temp = array[0].parent
            end

        else
            w = temp.parent.left

            if w.color == RED then
                w.color = BLACK
                temp.parent.color = RED
                rbtree_right_rotate(array, sentinel, temp.parent)

                w = temp.parent.left
            end

            if w.left.color == BLACK and w.right.color == BLACK then
                w.color = RED
                temp = temp.parent
            
            else
                if w.left.color == BLACK then
                    w.right.color = BLACK
                    w.color = RED
                    rbtree_left_rotate(array, sentinel, w)
                    w = temp.parent.left
                end

                w.color = temp.parent.color
                temp.parent.color = BLACK
                w.left.color = BLACK
                rbtree_right_rotate(array, sentinel, temp.parent)

                temp = array[0].parent
            end
        end
    end

    temp.color = BLACK
end


--for debug only
local function traverse(array, size)
    for i = 0, size + 1 do
        print('i:', i, ' node:', array[i], ' nodekey:', array[i].key, ' node.parent:', array[i].parent, ' node.left:', array[i].left, ' node.right:', array[i].right, ' color:', array[i].color)
    end
end
    

local function rbtree_find(node, key, sentinel)
    while node ~= sentinel do
        if key < node.key then
            node = node.left

        elseif key > node.key then
            node = node.right

        else
            return node
        end
    end

    return NULL
end


function _M.new(size)
    if size < 1 then
        return nil, "size too small"
    end

    local self = {
        array = array_init(size),
        node2value = {},
        size = size,
    }

    return setmetatable(self, mt)
end


function _M.find(self, key)
    local array = self.array
    local node = array[0].parent
    local sentinel = array[1]

    while node ~= sentinel do
        if key < node.key then
            node = node.left

        elseif key > node.key then
            node = node.right

        else
            local values = self.node2value
            local index = ptr2num(node)
            local value = values[index]
            assert(value)
            return value
        end
    end

    return nil
end



function _M.insert(self, key, value)
    local array = self.array
    local values = self.node2value

    --TODO  array grow  dynamic
    local node, err = queue_remove_head(array[0])
    if not node then
        return nil, err
    end

    values[ptr2num(node)] = value
    node.key = key
    rbtree_insert(array, node, rbtree_insert_value)
    --traverse(array, self.size)
    return true
end


function _M.delete(self, key)
    local array = self.array
    local sentinel = array[1]
    local node = rbtree_find(array[0].parent, key, sentinel)
    if not node then
        return nil, "not exist"
    end

    rbtree_delete(array, node)
    queue_insert_head(array[0], node)

    return true
end


--for debug 
function _M.all(self)
    traverse(self.array, self.size)
end


function _M.min(self)
    local array = self.array
    local sentinel = array[1]
    local root = array[0].parent
    if root == sentinel then
        return nil
    else
        return rbtree_min(root, sentinel)
    end
end


return _M
