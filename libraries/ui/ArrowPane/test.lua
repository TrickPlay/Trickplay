--[[
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua")   end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")        end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua")   end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")              end
if not MISC              then dofile("__UTILITIES/Misc.lua")                end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")              end
if not STYLE             then dofile("__CORE/Style.lua")                    end
if not WIDGET            then dofile("__CORE/Widget.lua")                   end
if not BUTTON            then dofile("Button/Button.lua")                   end
if not CLIPPINGREGION    then dofile("ClippingRegion/ClippingRegion.lua")   end
if not LISTMANAGER       then dofile("__UTILITIES/ListManagement.lua")      end
if not LAYOUTMANAGER     then dofile("LayoutManager/LayoutManager.lua")     end
if not ARROWPANE         then dofile("ArrowPane/ArrowPane.lua")             end
--]]
--WL.add_verbosity("STYLE_SUBSCRIPTIONS")
---[[
ap1 = WL.ArrowPane()
---[[
print("here\n\n\n")
ap1.style.arrow.size = 40
ap1.style.arrow.colors.default = "009999"
---[[
s = ap1:to_json()
ap1 = WL.ArrowPane()
ap1:from_json(s)
ap2 = WL.ArrowPane{x = 500,virtual_w = 400}
ap2.horizontal_arrows_are_visible = true
ap2.vertical_arrows_are_visible = false
ap2.arrow_move_by = 40
ap2:add(WL.Widget_Rectangle{w=1000,h=1000,color="ffff00"},WL.Widget_Rectangle{w=100,h=100,color="ff0000"},WL.Widget_Rectangle{x = 300,y=300,w=100,h=100,color="00ff00"})
--]]
---[[
ap3 = WL.ArrowPane{style = "new style",x = 1000,virtual_w = 400,virtual_h = 400}
print("\n\n\nhhh\n\n\n")
ap3.style.border.colors.default = "00000000"
ap3.style.arrow.colors.default = "009999"
--]]
--[[
ap3.style.arrow.size = 40
ap3.style.arrow.offset = -45
ap3:add(Widget_Rectangle{w=1000,h=1000,color="ffff00"},Widget_Rectangle{w=100,h=100,color="ff0000"},Widget_Rectangle{x = 300,y=300,w=100,h=100,color="00ff00"})
--dumptable(ap2.attributes)
ap3.virtual_w = 1000
--]]
--[[
r = Rectangle{ 
        name="Border",
        color = "00000000",
        border_width =5,
        border_color = "ffffffff",
        position = ap3.position,
        size = ap3.size
    }
    --]]
--r.border_width =50
--]]
screen:add(ap1,ap2,ap3,r)
