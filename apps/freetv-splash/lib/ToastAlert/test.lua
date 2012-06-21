
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua") end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")      end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua") end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")            end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")            end
if not STYLE             then dofile("__CORE/Style.lua")                  end
if not WIDGET            then dofile("__CORE/Widget.lua")                 end
if not DIALOGBOX         then dofile("DialogBox/DialogBox.lua")           end
if not TOASTALERT        then dofile("ToastAlert/ToastAlert.lua")         end



text = "This is a sample message. This is a sample message. This is a sample message. This is a sample message. This is a sample message. "

screen:show()


t1 = ToastAlert()

t2 = ToastAlert{message = text,icon = "ToastAlert/load-error.png",x = 1000}
t3 = ToastAlert{message = text,icon = "ToastAlert/load-error.png",x =  500, h =120}
t4 = ToastAlert{style = false,message = text,icon = "ToastAlert/load-error.png",x = 1500, message_font = "Sans 30px",message_color="00ff00"}
t4.style.border.colors.default = "00ff00"


print(t1:to_json())
print(t2:to_json())
print(t3:to_json())
print(t4:to_json())

screen:add(t1,t2,t3,t4)

