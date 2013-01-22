
do
    local old_print = print
    local old_dumptable = dumptable
    
    dumptable = function(...) 
        old_print( (( {pcall(error,"Dumptable:",3)} )[2]) ) 
        old_dumptable(...)
    end
    print = function(...) 
        local m = ""
        for i,v in ipairs({...}) do   m = m..tostring(v).." "   end
        old_print( (( {pcall(error,m,3)} )[2]) )
    end
end

WL = dofile("Widget_Library.lua")
dofile("load_json.lua")
--add_verbosity("STYLE_SUBSCRIPTIONS")
--add_verbosity("DEBUG")
--add_verbosity("TABBAR")
--add_verbosity("ArrayManager")


dofile("Button/test.lua")
--[[
wg = WL.Widget_Group{name='wg'}

wg:add(WL.MenuButton{
    name = "lm",
    y = 400,
})

str = wg:to_json()
print(str)
screen:add(load_layer(str))
--]]
screen:show()
controllers:start_pointer()

---------------------------------------------------------------------
r = Rectangle{w=10,h=10,y = 1070}
screen:add(r)

tl = Timeline{
    loop = true,
    duration = 10000,
    on_new_frame = function(tl,ms,p)
        --print(p)
        r.w = 1920*p
    end
}
tl:start()

--[[
w = WL.Widget_Group()
g = Group()
g:add(w)
screen:add(g)
w:unparent()
screen:add(w)
print(w:to_json())
--]]
