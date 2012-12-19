
--[[
local test_group = Group()
screen:add(test_group)
local tests = {
    function()
        local cr = ClippingRegion()
        test_group:add(cr)
        return ps.image == img and ps.animating == true and ps.duration == 3000
    end,
}

for i,test in ipairs(tests) do
    
    if not test() then print("test "..i.." failed") end
    test_group:clear()
end

test_group:unparent()
--]]


style =  {
    border = {
        width = 10,
        colors = {
            default    = {255,255,155},
            focus      = {255,255,155},
            activation = {155,255,255}
        }
    },
    text = {
        font = "Sans 50px",
        colors = {
            default    = {255,255,155},
            focus      = {255,255,155},
            activation = {155,255,255}
        }
    },
    fill_colors = {
        default_upper = {200, 40, 99,255},
        default_lower = {127,255,127,255},
        focus_upper   = {255,  0,255,255},
        focus_lower   = { 96,  0, 48,255},
    }
}



screen:show()


pb1 = WL.ProgressBar{w = 200, h = 50}
pb2 = WL.ProgressBar{x = 250,progress = 1,w = 200, h = 50}
pb3 = WL.ProgressBar{x = 500,progress = .5,style = style,w = 200, h = 50}
tl = Timeline{loop = true,on_new_frame = function(self,ms,p) pb1.progress = p end}
tl:start()

screen:add(Rectangle{size=screen.size,color="003300"},pb1,pb2,pb3)

