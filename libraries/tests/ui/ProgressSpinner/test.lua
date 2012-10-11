
--[[
local test_group = Group()

local img = Image{src="ProgressSpinner/load-sun-spin.png"}

screen:add(test_group)
local tests = {
    function()
        local ps = ProgressSpinner{
            animating = true,
            duration  = 3000,
            image     = img,
        }
        test_group:add(ps)
        return ps.image == img and ps.animating == true and ps.duration == 3000
    end,
    function()
        local ps = ProgressSpinner{
            animating = true,
            duration  = 3000,
            image     = img,
        }
        test_group:add(ps)
        ps:set{
            animating = false,
            duration  = 2000,
        }
        ps.image = nil
        return ps.animating == false and ps.duration == 2000
    end,
    function()
        local w = img.w*2
        local ps = ProgressSpinner{image = img,w=w}
        test_group:add(ps)
        
        return ps.w == w and ps.h == img.h
        
    end,
    function()
        
        local ps = ProgressSpinner{image = img}
        test_group:add(ps)
        
        ps.image = nil
        
        return ps.w == img.w and ps.h == img.h
        
    end,
    function()
        
        local ps = ProgressSpinner()
        test_group:add(ps)
        
        ps.image = img
        
        return ps.w == img.w and ps.h == img.h
        
    end,
}

for i,test in ipairs(tests) do
    
    if not test() then print("test "..i.." failed") end
    test_group:clear()
end

test_group:unparent()



--]]


local style = {
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
    fill_colors    = {
        default    = {80,0,0},
        focus      = {155,155,155},
        activation = {155,155,155}
    }
}




ps1 = WL.ProgressSpinner{w=100,h=100}
---[[
ps2 = WL.ProgressSpinner{x = 200,image = "ProgressSpinner/load-sun-spin.png",animating = true,}
---[[
ps3 = WL.ProgressSpinner{w=100,h=100,x = 400,style = style,animating = true, duration = 4000}

ps3.image = "ProgressSpinner/load-sun-spin.png"
ps3.image = nil

print(ps1:to_json())
print(ps2:to_json())
print(ps3:to_json())
--]]
screen:add(ps1,ps2,ps3)

