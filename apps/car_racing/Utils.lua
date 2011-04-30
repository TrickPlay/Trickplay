local old_nodes = {}

local node


local insert_data_element = function(self, new_object, insert_after_this_object)
    
    --print(self, new_object, insert_after_this_object)
    assert(type(self)      == "table")
    assert(type(self.list) == "table")
    assert(new_object ~= nil)
    
    --if there are no old nodes then make a new one
    if #old_nodes == 0 then
        node = {}
    else
        node = table.remove(old_nodes)
    end
    
    --if user specified an object for the new object to be after
    if insert_after_this_object ~= nil then
        
        assert(self.list[insert_after_this_object]~=nil)
        
        if self.tail == insert_after_this_object then
            
            self.tail = new_object
            
        else
            
            node.next = self.list[insert_after_this_object].next
            self.list[self.list[insert_after_this_object].next].prev = new_object
            
        end
        
        self.list[insert_after_this_object].next = new_object
        node.prev = insert_after_this_object
        
        
    else
        
        if self.head ~= nil then
            self.list[self.head].prev = new_object
            node.next = self.head
        end
        self.head = new_object
        
    end
    
    self.list[new_object] = node
    
    self.len = self.len + 1
end
local delete_data_element = function(self,old_object)
    
    assert(type(self)      == "table")
    assert(type(self.list) == "table")
    if self.list[old_object] == nil then
        print("Warning. trying to delete object when object is not present")
        return
    end
    
    if  self.head == old_object then
        self.head = self.list[old_object].next
    else
        self.list[self.list[old_object].prev].next = self.list[old_object].next
    end
    
    
    if  self.tail == old_object then
        self.tail = self.list[old_object].prev
    else
        self.list[self.list[old_object].next].prev = self.list[old_object].prev
    end
    
    
    table.insert(old_nodes,self.list[old_object])
    self.list[old_object].next = nil
    self.list[old_object].prev = nil
    
    self.list[old_object] = nil
    self.len = self.len - 1
end
local move_down = function(self,object)
    
    assert(type(self)             == "table")
    assert(type(self.list)        == "table")
    assert(self.list[object]      ~= nil)
    assert(self.list[object].next ~= nil)
    --[[
    print("before moving",object,"below",self.list[object].next)
    local node = self.head
    while(node ~= nil) do
        print(node)
        node = self.list[node].next
    end
    --]]
    --node = self.list[object].next
    
    if self.list[object].prev ~= nil then
        self.list[self.list[object].next].prev = self.list[object].prev
        self.list[self.list[object].prev].next = self.list[object].next
    else
        self.list[self.list[object].next].prev = nil
        self.head = self.list[object].next
    end
    
    self.list[object].prev = self.list[object].next
    self.list[object].next = self.list[self.list[object].next].next
    
    self.list[self.list[object].prev].next = object
    if self.list[object].next ~= nil then
        
        self.list[self.list[object].next].prev = object
    else
        self.tail = object
    end
    
    --[[
    print("after")
    node = self.head
    while(node ~= nil) do
        print(node)
        node = self.list[node].next
    end
    --]]
end
local clear_list = function(self)
    
    assert(type(self)      == "table")
    assert(type(self.list) == "table")
    
    for k,v in pairs(self.list) do
        table.insert(old_nodes,v)
        v.next = nil
        v.prev = nil
        self.list[k] = nil
    end
    self.head = nil
    self.tail = nil
    self.len = 0
end
make_Linked_List = function()
    return {
        list = {},
        head = nil,
        tail = nil,
        len  = 0,
        insert = insert_data_element,
        remove = delete_data_element,
        clear  = clear_list,
        move_down = move_down,
    }
    
end