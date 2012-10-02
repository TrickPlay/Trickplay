
WL = dofile("Widget_Library.lua")
--add_verbosity("STYLE_SUBSCRIPTIONS")
--add_verbosity("DEBUG")
--add_verbosity("TABBAR")
--add_verbosity("ArrayManager")


dofile("TabBar/test.lua")

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