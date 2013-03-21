

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
if not BUTTONPICKER      then dofile("ButtonPicker/ButtonPicker.lua")       end




screen:show()


bp1 = ButtonPicker{items={"one","two","333","for"}}
bp2 = ButtonPicker{style = false, x = 400,window_h = 200,orientation="vertical",items={"item1","item2","ite","itdddem2"}}

bp2.style.arrow.colors.default = "009999"
bp2.style.arrow.size = 40
bp2.style.arrow.offset = 0

screen:add(Rectangle{size=screen.size,color="666600"},bp1,bp2)

dolater(function() bp1:grab_key_focus() end)