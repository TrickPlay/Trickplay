
screen:show()


bp1 = WL.ButtonPicker{items={"one","two","333","for"}}
print("fjfhjfjfjfjfjfjfjf")
bp1.items = {"one","two"}
bp1.orientation ="vertical"
---[[
bp2 = WL.ButtonPicker{style = "new style", x = 400,window_h = 200,orientation="vertical",items={"item1","item2","ite","itdddem2"}}

bp2.style.arrow.colors.default = "009999"
bp2.style.arrow.size = 40
bp2.style.arrow.offset = 0
--]]
screen:add(Rectangle{size=screen.size,color="666600"},bp1,bp2)

dolater(function() bp1:grab_key_focus() end)
