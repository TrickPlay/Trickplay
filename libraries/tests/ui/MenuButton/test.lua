
local test_group = Group()

screen:add(test_group)
local tests = {
    
}

for i,test in ipairs(tests) do
    
    if not test() then print("test "..i.." failed") end
    test_group:clear()
end

test_group:unparent()




local style = {
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



screen:show()

mb0 = WL.MenuButton()
---[[
mb1 = WL.MenuButton{
    x = 300,
    items = {
        WL.Button(),WL.Button(),WL.Button{enabled = false},WL.Button()
    }
}
--]]
---[[
mb2 = WL.MenuButton{
    x = 600,
    direction = "up",
    items = {
        WL.Button(),WL.Button()
    }
}
--]]
---[[
mb3 = WL.MenuButton{
    x = 300, y = 350,
    direction = "right",
    items = {
        WL.Button(),WL.Button()
    }
}
dolater(function()
    mb3:grab_key_focus()
end)
--]]
---[[
mb4 = WL.MenuButton{
    x = 300, y = 500,
    style = style,
    direction = "left",
    items = {
        WL.Button(),WL.Button()
    }
}
mb4.items:insert(2,WL.Button())
--]]
---[[

mb4.neighbors[keys.Up] = mb3
mb3.neighbors[keys.Down] = mb4

--]]
wg = WL.Widget_Group()
screen:add(wg)
wg:add(
    WL.Widget_Rectangle{x=300,size = {20,1000}},
    WL.Widget_Rectangle{x=600,size = {20,1000}},
    mb0,mb1,mb2,mb3,mb4
)

--print(get_all_styles())
print("\n\n\n")
--print(wg:to_json())

