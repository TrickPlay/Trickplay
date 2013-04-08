
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
d2 = DialogBox{style = false,x = 500}

d2.title = "This is a really really really long title"
d2.style.fill_colors.default = "660000"
d2.style.border.corner_radius = 40

d3 = DialogBox{style = false,x = 1000,separator_y = 200}
d3.style.border.width = 10

d4 = DialogBox{style = false,y = 400, image = "DialogBox/panel.png"}
d4.style.text.font = "Sans 80px"

print(d1:to_json())
print(d2:to_json())
print(d3:to_json())
print(d4:to_json())
screen:add(Rectangle{size = screen.size,color = "000033"},d1,d2,d3,d4)

