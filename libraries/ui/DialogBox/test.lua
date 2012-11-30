
screen:show()


d1 = WL.DialogBox()
d2 = WL.DialogBox{style = "s1",x = 500}

d2.title = "This is a really really really long title"
d2.style.fill_colors.default = "660000"
d2.style.border.corner_radius = 40

d3 = WL.DialogBox{style = "s2",x = 1000,separator_y = 200}
d3.style.border.width = 10

d4 = WL.DialogBox{style = "s3",y = 400, image = "DialogBox/panel.png",children = {WL.Button{reactive=true}}}
d4.style.text.font = "Sans 80px"
print("da")
d4.style.text.colors.default = "red"
--[[
print(d1:to_json())
print(d2:to_json())
print(d3:to_json())
print(d4:to_json())
--]]
screen:add(Rectangle{size = screen.size,color = "000033"},d1,d2,d3,d4)

