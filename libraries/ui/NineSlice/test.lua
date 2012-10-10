
---[[
ns1 = WL.NineSlice()
print("DONE WITH NS1")
---[[
ns2 = WL.NineSlice{w=200,h=50,x=100}
--]]
---[[
ns3 = WL.NineSlice{
    x = 400,
    w = 400,
    h = 300,
    reactive = true,
    cells --[[= {
        default--]] = {
            {
                WL.Widget_Rectangle{w=30,h=30,color="440055"},
                WL.Widget_Rectangle{w=10,h=30,color="000055"},
                WL.Widget_Rectangle{w=30,h=30,color="440055"},
            },
            {
                WL.Widget_Rectangle{w=30,h=10,color="000055"},
                WL.Widget_Rectangle{w=10,h=10,color="777777"},
                WL.Widget_Rectangle{w=30,h=10,color="000055"},
            },
            {
                WL.Widget_Rectangle{w=30,h=30,color="440055"},
                WL.Widget_Rectangle{w=10,h=30,color="000055"},
                WL.Widget_Rectangle{w=30,h=30,color="440055"},
            },
        --[[},
        focus = {
            {
                Widget_Rectangle{w=30,h=30,color="777777"},
                Widget_Rectangle{w=10,h=30,color="0000bb"},
                Widget_Rectangle{w=30,h=30,color="777777"},
            },
            {
                Widget_Rectangle{w=30,h=10,color="0000bb"},
                Widget_Rectangle{w=10,h=10,color="999999"},
                Widget_Rectangle{w=30,h=10,color="0000bb"},
            },
            {
                Widget_Rectangle{w=30,h=30,color="777777"},
                Widget_Rectangle{w=10,h=30,color="0000bb"},
                Widget_Rectangle{w=30,h=30,color="777777"},
            },
        },--]]
    }
}
--]]
print("changing colors")
--ns1.style.fill_colors.default = {0,255,0}
screen:add(Rectangle{size = screen.size,color = "444444"},ns1,ns2,ns3)
print(WL.get_all_styles())