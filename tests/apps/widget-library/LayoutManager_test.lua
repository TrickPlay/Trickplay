
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
lm1 = WL.LayoutManager()
lm1:set{
    x = 1000,
    number_of_rows = 4,
    number_of_cols = 2,
    vertical_alignment = "top",
    --placeholder = Widget_Rectangle{w=300,h=300},
    cells = {
        {WL.Widget_Rectangle{w=100,h=100},WL.Widget_Rectangle{w=100,h=100}},
        {WL.Widget_Rectangle{w=100,h=100},false},--Rectangle{w=100,h=100}},
        {WL.Widget_Rectangle{w=100,h=100},WL.Widget_Rectangle{w=100,h=100}},
        {WL.Widget_Rectangle{w=100,h=100},WL.Widget_Rectangle{w=100,h=100}},
        {WL.Widget_Rectangle{w=100,h=100},WL.Widget_Rectangle{w=100,h=100}},
    }
}
lm1.reactive = true
function lm1:on_button_down(x,y)
    print(lm1:r_c_from_abs_x_y(x,y))
end

lm1.cells:insert_row(3,{})

print("===============================================================")
print("===============================================================")
print("===============================================================")
lm1.placeholder = WL.Widget_Rectangle{w=300,h=300}
lm1.cells[2][2] = WL.Widget_Rectangle{size={200,10}}
--]]
---[[

tj = lm1:to_json()
lm1 = nil
lmj = WL.LayoutManager()
print("===============================================================")
print("===============================================================")
print("===============================================================")
dumptable(json:parse(tj))
print("===============================================================")
print("===============================================================")
print("===============================================================")
lmj:from_json(tj)
screen:add(lmj)
lmj.placeholder = WL.Widget_Rectangle{w=300,h=300}


--]]
---[[
lm2 = WL.LayoutManager{
    y = 400,
    number_of_rows = 3,
    number_of_cols = 2,
    cells = {
        {WL.Button(),WL.Button()},
        {WL.Button(),WL.Button{enabled = false}},
        {WL.Button(),WL.Button()},
    }
}
lm2.cell_w = 400
dolater(function()
    lm2:grab_key_focus()
end)
--]]
---[[
lm3 = WL.ListManager{
    x=500,
    length = 2,
    cells = {
        WL.Widget_Rectangle{w=100,h=100},WL.Widget_Rectangle{w=100,h=100}
    }
}
--]]
screen:add(lm0,lm1,lm2,lm3)
--]]
