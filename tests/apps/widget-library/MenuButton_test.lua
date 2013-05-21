
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
    name = "heer",
    border = {
        width = 10,
        colors = {
            default    = {255,255,155},
            focus      = {255,255,155},
            activation = {155,255,255},
            selection  = {255,255,155},
        }
    },
    text = {
        font = "Sans 50px",
        colors = {
            default    = {255,255,155},
            focus      = {255,255,155},
            activation = {155,255,255},
        }
    },
    fill_colors    = {
        default    = {80,0,0},
        focus      = {155,155,155},
        activation = {155,155,155},
        selection  = "ffffff66",
    }
}



screen:show()

mb0 = WL.MenuButton{name="MB0",}
---[[
mb1 = WL.MenuButton{name="MB1",
    x = 300,
    items = {
        WL.Button{name="b0"},WL.Button{name="b3"},WL.Button{name="b2",enabled = false},WL.Button{name="b1"}
    }
}
--]]
---[[
mb2 = WL.MenuButton{name="MB2",
    x = 600,
    direction = "up",
    items = {
        WL.Button{name="b5"},WL.Button{name="b4"}
    }
}
--]]
---[[
mb3 = WL.MenuButton{name="MB3",
    x = 300, y = 350,
    direction = "right",
    items = {
        WL.Button{name="b7"},WL.Button{name="b6"}
    }
}
dolater(function()
    mb3:grab_key_focus()
end)
--]]
---[[
mb4 = WL.MenuButton{name="MB4",
    x = 300, y = 500,
    style = style,
    direction = "left",
    items = {
        WL.Button{name="b9"},WL.Button{name="b8"}
    }
}
mb4.items:insert(2,WL.Button{name="b10"})
--]]
---[[

mb4.neighbors.Up = mb3
mb3.neighbors.Down = mb4

--]]
--[[
mb5 = WL.MenuButton(mb4.attributes)
mb5.name = "MB5"
mb5.x = 1400
--]]
wg = WL.Widget_Group{name="WG"}
screen:add(wg)
wg:add(
    WL.Widget_Rectangle{name="r1",x=300,size = {20,1000}},
    WL.Widget_Rectangle{name="r2",x=600,size = {20,1000}},
    mb0,mb1,mb2,mb3,mb4,mb5
)

--print(get_all_styles())
print("\n\n\n")
--print(wg:to_json())
js = wg:to_json()
print(js)
screen:clear()

screen:add(load_layer(js))

