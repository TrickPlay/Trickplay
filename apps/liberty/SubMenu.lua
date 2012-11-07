
local normal_fount = "InterstateProLight 40px"
local focus_fount = "InterstateProBold 40px"

local spacing = 70
return function(options)
    local instance = Group()
    local index = 1
    local items = {}
    for i,o in ipairs(options) do
        items[i] = make_bolding_text{
            text = o,
            color="white",
            sz=40,
            duration = 100,
            center = true,
        }--[[
        Text{
            text = o,
            font = "InterstateProLight 40px",
            color = "ffffff",
        }
        --]]
        instance:add(items[i])
    end
    instance.w = instance.w
    for i,o in ipairs(options) do
        items[i].x = instance.w/2
        items[i].y = (i-1)*spacing
        --[[
        items[i].anchor_point = {
            items[i].w/2,
            items[i].h/2,
        }
        --]]
    end
    
    function instance:on_key_focus_in()
        --[[
        index = 1
        items[index].font = focus_fount
        items[index].anchor_point = {
            items[index].w/2,
            items[index].h/2,
        }
        --]]
        items[index].expand:start()
    end
    function instance:on_key_focus_out()
        --[[
        index = 1
        items[index].font = normal_fount
        items[index].anchor_point = {
            items[index].w/2,
            items[index].h/2,
        }
        --]]
        items[index].contract:start()
        index = 1
    end
    
    local keypress = {
        [keys.Up] = function()
            if index == 1 then return end
            
            --[[
            items[index].font = normal_fount
            items[index].anchor_point = {
                items[index].w/2,
                items[index].h/2,
            }
            --]]
            items[index].contract:start()
            index = index - 1
            items[index].expand:start()
            --[[
            items[index].font = focus_fount
            items[index].anchor_point = {
                items[index].w/2,
                items[index].h/2,
            }
            --]]
        end,
        [keys.Down] = function()
            if index == #items then return end
            
            --[[
            items[index].font = normal_fount
            items[index].anchor_point = {
                items[index].w/2,
                items[index].h/2,
            }
            --]]
            items[index].contract:start()
            index = index + 1
            items[index].expand:start()
            --[[
            items[index].font = focus_fount
            items[index].anchor_point = {
                items[index].w/2,
                items[index].h/2,
            }
            --]]
        end,
        [keys.VOL_UP]   = raise_volume,
        [keys.VOL_DOWN] = lower_volume,
    }
    
    function instance:on_key_down(k)
        return keypress[k] and keypress[k]()
    end
    
    return instance
end