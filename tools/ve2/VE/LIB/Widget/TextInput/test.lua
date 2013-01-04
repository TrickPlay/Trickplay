
text = "This is a sample message. This is a sample message. This is a sample message. This is a sample message. This is a sample message. "

screen:show()


t1 = WL.TextInput{style = "s1",}
---[[
print("t2 t2 t2 t2 t2 t2 t2 t2 t2 t2 t2 ")
t2 = WL.TextInput{style = "s2",h=400,w=200,x = 200,text = "default",enabled=false}

t2.style.text.colors.default = "00d000"
t2.style.text.single_line = false
--]]
print("changing fill colors")
--t1.style.fill_colors.default = "660000"
screen:add(t1,t2)


controllers:start_pointer()
