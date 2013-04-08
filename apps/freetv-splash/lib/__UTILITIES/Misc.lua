MISC = true

function bound_to(lower,value,upper)
    
    if lower > value then return lower
    elseif upper < value then return upper
    else return value end
    
end

function set_up_subscriptions(obj,mt,old__newindex,old_set)
    
    -- the table of callbacks for specific attributes, 
    local subscriptions     = {}
    local subscriptions_all = {}
    
    --helper function called by subscribe_to()
    local add = function(subscription,callback)
        --lazy creation of second dimension of tables
        if not subscriptions[subscription] then
            
            subscriptions[subscription] = {}
            
        end
        
        subscriptions[subscription][callback] = true
        
    end
    
    obj.subscribe_to = function(self,subscription,f)
        
        if type(f) ~= "function" then
            
            error( "2nd arg expected to be a function. Received "..type(f),2 )
            
        end
        
        if type(subscription) == "nil" then
            
            subscriptions_all[f] = true
            
        elseif type(subscription) == "table" then
            
            for _,key in ipairs(subscription) do
                
                add(key,f)
                
            end
            
        elseif type(subscription) == "string" then
            
            add(subscription,f)
            
        else
            
            error(
                "1st arg expects a string, a table of strings,"..
                " or nil. Received "..type(subscription),2
            )
            
        end
        
    end
    
    obj.set = function(self,t)
        
        old_set(self, t)
        
        if type(t) == "table" then
        local p = {}
        
        for key,_ in pairs(t) do
            if subscriptions[key] then
                
                for f,_ in pairs(subscriptions[key]) do f(key) end
                
            end
            table.insert(p,key)
        end
        --functionality of widgets relies on the callbacks in 
        -- 'subscriptions_all' happening after the callbacks
        -- in 'subscriptions'
        for f,_ in pairs(subscriptions_all ) do f(p) end
        end
        return self
        
    end
    mt.__newindex = function(self,key,value)
        
        old__newindex(self,key,value)
        
        if subscriptions[key] then
            
            for f,_ in pairs(subscriptions[key]) do f(key) end
        end
        for f,_ in pairs(subscriptions_all ) do f(key) end
        
    end
end