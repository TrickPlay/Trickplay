

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
if not BUTTON            then dofile("Button/Button.lua")                   end
if not MENUBUTTON        then dofile("MenuButton/MenuButton.lua")           end

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

mb0 = MenuButton()
---[[
mb1 = MenuButton{
    x = 300,
    items = {
        Button(),Button()
    }
}
mb2 = MenuButton{
    x = 600,
    direction = "up",
    items = {
        Button(),Button()
    }
}
mb3 = MenuButton{
    x = 300, y = 250,
    direction = "right",
    items = {
        Button(),Button()
    }
}
mb4 = MenuButton{
    x = 300, y = 500,
    style = style,
    direction = "left",
    items = {
        Button(),Button()
    }
}
mb4.items:insert(2,Button())
--]]
wg = Widget_Group()
screen:add(wg)
wg:add(
    Widget_Rectangle{x=300,size = {20,1000}},
    Widget_Rectangle{x=600,size = {20,1000}},
    mb0,mb1,mb2,mb3,mb4
)

print(get_all_styles())
print("\n\n\n")
print(wg:to_json())

