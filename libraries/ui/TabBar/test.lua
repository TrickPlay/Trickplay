
local style = {
    border = {
        width = 10,
        colors = {
            default    = {255,255,155},
            focus      = {255,  0,  0},
            activation = {155,255,255},
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
        default    = { 80,  0,  0},
        focus      = {155,155,155},
        activation = {155,155,155},
    },
}
---[[
tb1 = WL.TabBar{
    position = {100,100},
    tabs = {
        {label="One",   contents = WL.Widget_Group{children={Rectangle{w=400,h=400,color="ff0000"},WL.Button()}}},
        {label="Two",   contents = WL.Widget_Group{children={Rectangle{w=400,h=400,color="00ff00"}}}},
        {label="Three", contents = WL.Widget_Group{children={Rectangle{w=400,h=400,color="0000ff"}}}},
        {label="Four",  contents = WL.Widget_Group{children={Rectangle{w=400,h=400,color="ffff00"}}}},
        {label="Five",  contents = WL.Widget_Group{children={Rectangle{w=400,h=400,color="ff00ff"}}}},
        {label="Six",   contents = WL.Widget_Group{children={Rectangle{w=400,h=400,color="00ffff"}}}},
    },
    tab_images = {
        default = WL.Widget_Image{src="Button/button3.png"},
        focus   = WL.Widget_Image{src="Button/button-focus.png"},
    }
}

print("\n\n\n inject new tab")
tb1.tabs:insert(2,{label="New",   contents = WL.Widget_Group{children={Rectangle{w=400,h=400,color="30f0f0"}}}})

tb1.tabs[3].label = "3333"
tb1.tabs[3].contents = WL.Widget_Group{children={Rectangle{w=40,h=40,color="30f0f0"}}}
dumptable(tb1.attributes)
--]]
---[[

b = WL.Button()
tb2 = WL.TabBar()
tb2:set{
    pane_w = 500,
    --tab_w  = 200,
    tab_h  = 100,
    --direction = "vertical",
    tab_location = "top",
    style = style,
    position = {100,600},
    tabs = {
        {label="One",   contents = WL.Widget_Group{on_key_focus_in =function() b:grab_key_focus() end,children={WL.Widget_Rectangle{w=500,h=400,color="ff0000"},b}}},
        {label="Two",   contents = WL.Widget_Group{children={WL.Widget_Rectangle{w=500,h=400,color="00ff00"}}}},
        {label="Three", contents = WL.Widget_Group{children={WL.Widget_Rectangle{w=500,h=400,color="0000ff"}}}},
        {label="Four",  contents = WL.Widget_Group{children={WL.Widget_Rectangle{w=500,h=400,color="ffff00"}}}},
        {label="Five",  contents = WL.Widget_Group{children={WL.Widget_Rectangle{w=500,h=400,color="ff00ff"}}}},
        {label="Six",   contents = WL.Widget_Group{children={WL.Widget_Rectangle{w=500,h=400,color="00ffff"}}}},
    }
}
--[[
s = tb2:to_json()
tb2 = WL.TabBar()
tb2:from_json(s)
--]]

dolater(tb2.grab_key_focus,tb2)
--tb2.style = style
--]]
--[[
tb3 = TabBar{
    tab_location = "left",
    style = style,
    position = {600,100},
    tabs = {
        {label="One",   contents = Widget_Group{children={Rectangle{w=400,h=400,color="ff0000"}}}},
        {label="Two",   contents = Widget_Group{children={Rectangle{w=400,h=400,color="00ff00"}}}},
        {label="Three", contents = Widget_Group{children={Rectangle{w=400,h=400,color="0000ff"}}}},
        {label="Four",  contents = Widget_Group{children={Rectangle{w=400,h=400,color="ffff00"}}}},
        {label="Five",  contents = Widget_Group{children={Rectangle{w=400,h=400,color="ff00ff"}}}},
        {label="Six",   contents = Widget_Group{children={Rectangle{w=400,h=400,color="00ffff"}}}},
    }
}
--]]
screen:add(tb1,tb2,tb3)
