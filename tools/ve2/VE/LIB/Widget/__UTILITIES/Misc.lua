MISC = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


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
        
        return function()
            --print("unsubscribing")
            if type(subscription) == "nil" then
                
                subscriptions_all[f] = nil
                
            elseif type(subscription) == "table" then
                
                for _,key in ipairs(subscription) do
                    
                    subscriptions[key][f] = nil
                    
                end
                
            elseif type(subscription) == "string" then
                
                subscriptions[subscription][f] = nil
                
            else
                
                error(
                    "THIS SHOULD NOT BE POSSIBLE",2
                )
                
            end
        end
    end
    local setting = false
    do
        
        obj.set = function(self,t)
            if setting then
                old_set(self, t)
            else
                setting = true
                old_set(self, t)
                setting = false
                self:notify(t)
            end
            
            return self
            
        end
    end
    do
        local notifying = false
        local p = {}
        obj.notify = function(self,t,force)
            
            if (setting or notifying) and not force then 
                print("WARNING. Object is already notifying subscribers")
                return 
            end
            mesg("DEBUG",0,self,":notify() was called ")
            notifying = true
            p = nil
            if type(t) == "table" then
                --dumptable(t)
                p = {}
                for k,v in pairs(t) do
                    if subscriptions[key] then
                        
                        for f,_ in pairs(subscriptions[key]) do 
                            mesg("NOTIFY",0,tostring(self)..":notify() calling subscriber",f) 
                            f(key) 
                        end
                        
                    end
                    table.insert(p,key)
                end
            end
            --TODO: the following should no longer be the case, make sure
            --functionality of widgets relies on the callbacks in 
            -- 'subscriptions_all' happening after the callbacks
            -- in 'subscriptions'
            for f,_ in pairs(subscriptions_all ) do 
                mesg("NOTIFY",0,tostring(self)..":notify() calling allsubscriber",f) 
                f(t) 
            end
            notifying = false
        end
    end
    --------------------------------------------------------------
    --This function is called every time an Attribute is being set
    mt.__newindex = function(self,key,value)
        --print(self,"old__newindex",key,"being called")
        old__newindex(self,key,value)
        --print(self,"old__newindex",key,"was called")
        if not(setting or notifying) then
        if subscriptions[key] then
            
            for f,_ in pairs(subscriptions[key]) do 
                mesg("NOTIFY",0,"newindex",key," calling subscriber",f) 
                f({[key]=value}) 
            end
        end
        for f,_ in pairs(subscriptions_all ) do 
            mesg("NOTIFY",0,"newindex",key," calling allsubscriber",f) 
            f({[key]=value}) 
        end
        end
    end
end