
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
        {label="One",   contents = {Rectangle{w=400,h=400,color="ff0000"},Button()}},
        {label="Two",   contents = {Rectangle{w=400,h=400,color="00ff00"}}},
        {label="Three", contents = {Rectangle{w=400,h=400,color="0000ff"}}},
        {label="Four",  contents = {Rectangle{w=400,h=400,color="ffff00"}}},
        {label="Five",  contents = {Rectangle{w=400,h=400,color="ff00ff"}}},
        {label="Six",   contents = {Rectangle{w=400,h=400,color="00ffff"}}},
    }
}
--]]
tb2 = TabBar{
    pane_w = 500,
    tab_h  = 100,
    style = style,
    position = {100,600},
    tabs = {
        {label="One",   contents = {Rectangle{w=400,h=400,color="ff0000"},Button()}},
        {label="Two",   contents = {Rectangle{w=400,h=400,color="00ff00"}}},
        {label="Three", contents = {Rectangle{w=400,h=400,color="0000ff"}}},
        {label="Four",  contents = {Rectangle{w=400,h=400,color="ffff00"}}},
        {label="Five",  contents = {Rectangle{w=400,h=400,color="ff00ff"}}},
        {label="Six",   contents = {Rectangle{w=400,h=400,color="00ffff"}}},
    }
}
---[[
tb3 = TabBar{
    tab_location = "left",
    style = style,
    position = {600,100},
    tabs = {
        {label="One",   contents = {Rectangle{w=400,h=400,color="ff0000"}}},
        {label="Two",   contents = {Rectangle{w=400,h=400,color="00ff00"}}},
        {label="Three", contents = {Rectangle{w=400,h=400,color="0000ff"}}},
        {label="Four",  contents = {Rectangle{w=400,h=400,color="ffff00"}}},
        {label="Five",  contents = {Rectangle{w=400,h=400,color="ff00ff"}}},
        {label="Six",   contents = {Rectangle{w=400,h=400,color="00ffff"}}},
    }
}
--]]
screen:add(tb1,tb2,tb3)
