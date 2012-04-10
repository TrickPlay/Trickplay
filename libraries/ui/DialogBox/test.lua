
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua") end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")      end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua") end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")            end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")            end
if not STYLE             then dofile("__CORE/Style.lua")                  end
if not WIDGET            then dofile("__CORE/Widget.lua")                 end
if not DIALOGBOX         then dofile("DialogBox/DialogBox.lua")           end
if not TOASTALERT        then dofile("ToastAlert/ToastAlert.lua")         end





screen:show()


d1 = DialogBox()

d1.style.fill_colors.default = "660000"

screen:add(d1)

