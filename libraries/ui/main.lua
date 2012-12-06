
WL = dofile("Widget_Library.lua")
dofile("load_json.lua")
--add_verbosity("STYLE_SUBSCRIPTIONS")
--add_verbosity("DEBUG")
--add_verbosity("TABBAR")
--add_verbosity("ArrayManager")


dofile("ButtonPicker/test.lua")
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

r:animate{
    loop = true,
    duration = 60000,
    w = screen.w
}