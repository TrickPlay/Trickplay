
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua") end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")      end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua") end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")            end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")            end
if not STYLE             then dofile("__CORE/Style.lua")                  end
if not WIDGET            then dofile("__CORE/Widget.lua")                 end
if not TEXTINPUT         then dofile("TextInput/TextInput.lua")           end



text = "This is a sample message. This is a sample message. This is a sample message. This is a sample message. This is a sample message. "

screen:show()


t1 = TextInput()

t1.style.fill_colors.default = "660000"

t2 = TextInput{h=400,x = 200}

t2.text = "default"

screen:add(t1,t2)


controllers:start_pointer()
