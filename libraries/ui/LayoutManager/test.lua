
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua")   end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")        end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua")   end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")              end
if not MISC              then dofile("__UTILITIES/Misc.lua")                end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")              end
if not STYLE             then dofile("__CORE/Style.lua")                    end
if not WIDGET            then dofile("__CORE/Widget.lua")                   end
if not LISTMANAGER       then dofile("__UTILITIES/ListManagement.lua")      end
if not LAYOUTMANAGER     then dofile("LayoutManager/LayoutManager.lua")     end
if not BUTTON            then dofile("Button/Button.lua")                 end

local test_group = Group()

screen:add(test_group)
local tests = {
    
}

for i,test in ipairs(tests) do
    
    if not test() then print("test "..i.." failed") end
    test_group:clear()
end

test_group:unparent()




screen:show()
--[[
lm0 = LayoutManager()
--]]
---[[
lm1 = LayoutManager{
    x = 1000,
    number_of_rows = 4,
    number_of_cols = 2,
    cells = {
        {Widget_Rectangle{w=100,h=100},Widget_Rectangle{w=100,h=100}},
        {Widget_Rectangle{w=100,h=100}},--Rectangle{w=100,h=100}},
        {Widget_Rectangle{w=100,h=100},Widget_Rectangle{w=100,h=100}},
        {Widget_Rectangle{w=100,h=100},Widget_Rectangle{w=100,h=100}},
        {Widget_Rectangle{w=100,h=100},Widget_Rectangle{w=100,h=100}},
    }
}
lm1.reactive = true
function lm1:on_button_down(x,y)
    print(lm1:r_c_from_abs_x_y(x,y))
end
--]]
--[[
lm2 = LayoutManager{
    y = 400,
    number_of_rows = 3,
    number_of_cols = 2,
    cells = {
        {Button(),Button()},
        {Button(),Button()},
        {Button(),Button()},
    }
}
dolater(function()
    lm2:grab_key_focus()
end)
--]]
--[[
lm3 = ListManager{
    x=500,
    length = 2,
    cells = {
        Widget_Rectangle{w=100,h=100},Widget_Rectangle{w=100,h=100}
    }
}
--]]
screen:add(lm0,lm1,lm2,lm3)
--]]
