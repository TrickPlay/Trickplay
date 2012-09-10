
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua") end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")      end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua") end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")            end
if not MISC              then dofile("__UTILITIES/Misc.lua")            end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")            end
if not STYLE             then dofile("__CORE/Style.lua")                  end
if not WIDGET            then dofile("__CORE/Widget.lua")                 end

add_verbosity("DEBUG")

t1 = {}
t2 = {}
t3 = {}
t1.t2 = t2
t2.t3 = t3


setmetatable(t1,{__newindex = function(t,k,v) print("t1") rawset(t,k,v) end})
setmetatable(t2,{__newindex = function(t,k,v) print("t2") rawset(t,k,v) end})
setmetatable(t3,{__newindex = function(t,k,v) print("t3") rawset(t,k,v) end})

t1.t2.t3.t4 = {}

do
    
    local instance, env = Widget()
    
    -------------------------------------------------------
    env.old_update = env.update
    env.update = function()
        print("\tupdate called")
        --[[
        if env.old_update then 
            print("old_update being called")
            env.old_update() 
        end
        --]]
    end
    -------------------------------------------------------
    env.subscribe_to_sub_styles = function()
        print("subscribe_to_sub_styles called")
        instance.style.border:subscribe_to( nil, function(t)
            print("border changed",t)
            env.call_update()
        end )
        instance.style.border.colors:subscribe_to( nil, function(t)
            print("border.colors changed",t)
            env.call_update()
        end )
        instance.style.fill_colors:subscribe_to( nil, function(t)
            print("fill_colors changed",t)
            env.call_update()
        end )
        instance.style.text.colors:subscribe_to( nil, function()
            print("text.colors changed")
            env.call_update()
        end )
        instance.style.text:subscribe_to( nil, function()
            print("text changed")
            env.call_update()
        end )
        instance.style:subscribe_to( nil, function(t)
            print("style changed",t)
            dumptable(t)
            env.call_update()
        end )
        print("done subscribing tom sub styles")
        --env.call_update() [[ after the setter, update will get called
        print("done setting style")
    end
    -------------------------------------------------------
	override_property(instance,"style", nil,
		function(oldf,self,v)
            oldf(self,v)
            
            env.subscribe_to_sub_styles()
            
        end
	)
    env.subscribe_to_sub_styles()
    
    
    w1 = instance
end
print("\n\n")
---[[
print("set w1.x")
w1.x = 200
print("done setting w1.x\n\n")
--[[
print("set w1.style")
w1.style = { -- this creates a new style object
    border = {
        width = 10,
        colors = {
            default    = {255,255,155},
            focus      = {255,255,155},
            activation = {155,255,255}
        }
    },
    text = {
        font = "Sans 50px",
        colors = {
            default    = {255,255,155},
            focus      = {255,255,155},
            activation = {155,255,255}
        }
    },
    fill_colors    = {
        default    = {80,0,0},
        focus      = {155,155,155},
        activation = {155,155,155}
    }
}
print("done setting w1.style\n\n")



--]]

---[[
print("tables: style = ",w1.style,"style.border = ",w1.style.border,"style.border.colors = ",w1.style.border.colors)
print("set w1.style.border.colors.default")
w1.style.border.colors.default = {80,0,0}

print("done setting w1.style.border.colors.default\n\n")
--]]

--[[
print("set w1.style.border.colors")
w1.style.border.colors = {
        default    = {80,0,0},
        focus      = {155,155,155},
        activation = {155,155,155}
    }
print("done setting w1.style.border.colors\n\n")
--]]