
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua") end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")      end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua") end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")            end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")            end
if not STYLE             then dofile("__CORE/Style.lua")                  end
if not WIDGET            then dofile("__CORE/Widget.lua")                 end
if not TEXTINPUT         then dofile("TextInput/TextInput.lua")           end
if not LISTMANAGER       then dofile("__UTILITIES/ListManagement.lua")    end
if not LAYOUTMANAGER     then dofile("LayoutManager/LayoutManager.lua")   end
if not NINESLICE         then dofile("NineSlice/NineSlice.lua")           end



text = "This is a sample message. This is a sample message. This is a sample message. This is a sample message. This is a sample message. "

screen:show()


t1 = TextInput{style = false,}
--[[
print("t2 t2 t2 t2 t2 t2 t2 t2 t2 t2 t2 ")
t2 = TextInput{style = false,h=400,w=200,x = 200,text = "default"}

t2.style.text.colors.default = "00d000"
--t2.style.text.single_line = false
--]]
print("changing fill colors")
--t1.style.fill_colors.default = "660000"
screen:add(t1,t2)


controllers:start_pointer()
