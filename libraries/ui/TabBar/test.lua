
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua")   end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")        end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua")   end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")              end
if not MISC              then dofile("__UTILITIES/Misc.lua")                end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")              end
if not STYLE             then dofile("__CORE/Style.lua")                    end
if not WIDGET            then dofile("__CORE/Widget.lua")                   end
if not BUTTON            then dofile("Button/Button.lua")                   end
if not TOGGLEBUTTON      then dofile("ToggleButton/ToggleButton.lua")       end
if not RADIOBUTTONGROUP  then dofile("RadioButtonGroup/RadioButtonGroup.lua") end
if not CLIPPINGREGION    then dofile("ClippingRegion/ClippingRegion.lua")   end
if not LISTMANAGER       then dofile("__UTILITIES/ListManagement.lua")      end
if not LAYOUTMANAGER     then dofile("LayoutManager/LayoutManager.lua")     end
if not ARROWPANE         then dofile("ArrowPane/ArrowPane.lua")             end
if not TABBAR            then dofile("TabBar/TabBar.lua")                   end

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
---[[
tb1 = TabBar{
    position = {100,100},
    tabs = {
        {label="One",   contents = Widget_Group{children={Rectangle{w=400,h=400,color="ff0000"},Button()}}},
        {label="Two",   contents = Widget_Group{children={Rectangle{w=400,h=400,color="00ff00"}}}},
        {label="Three", contents = Widget_Group{children={Rectangle{w=400,h=400,color="0000ff"}}}},
        {label="Four",  contents = Widget_Group{children={Rectangle{w=400,h=400,color="ffff00"}}}},
        {label="Five",  contents = Widget_Group{children={Rectangle{w=400,h=400,color="ff00ff"}}}},
        {label="Six",   contents = Widget_Group{children={Rectangle{w=400,h=400,color="00ffff"}}}},
    },
    tab_images = {
        default = Widget_Image{src="Button/button3.png"},
        focus   = Widget_Image{src="Button/button-focus.png"},
    }
}
print("\n\n\n inject new tab")
tb1.tabs:insert(2,{label="New",   contents = Widget_Group{children={Rectangle{w=400,h=400,color="30f0f0"}}}})

tb1.tabs[3].label = "3333"
tb1.tabs[3].contents = Widget_Group{children={Rectangle{w=40,h=40,color="30f0f0"}}}
dumptable(tb1.attributes)
--]]
---[[
tb2 = TabBar{
    pane_w = 500,
    tab_h  = 100,
    style = style,
    position = {100,600},
    tabs = {
        {label="One",   contents = Widget_Group{children={Rectangle{w=500,h=400,color="ff0000"},Button()}}},
        {label="Two",   contents = Widget_Group{children={Rectangle{w=500,h=400,color="00ff00"}}}},
        {label="Three", contents = Widget_Group{children={Rectangle{w=500,h=400,color="0000ff"}}}},
        {label="Four",  contents = Widget_Group{children={Rectangle{w=500,h=400,color="ffff00"}}}},
        {label="Five",  contents = Widget_Group{children={Rectangle{w=500,h=400,color="ff00ff"}}}},
        {label="Six",   contents = Widget_Group{children={Rectangle{w=500,h=400,color="00ffff"}}}},
    }
}
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
