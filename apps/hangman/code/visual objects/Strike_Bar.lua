

local strike_bar = Group{ name = "Strike Bar", x = 100, y = 730}
local strikes    = {}

local strike_off, strike_on, bg


function strike_bar:init(t)
    
    if type(t)          ~= "table"    then error("must pass table as the parameter", 2) end
    if type(t.bg)       ~= "userdata" then error("must pass bg",                     2) end
    if type(t.img_srcs) ~= "table"    then error("must pass img_srcs",               2) end
    
    bg = t.bg
    
    strike_on  = t.img_srcs.strike_on
    strike_off = t.img_srcs.strike_off
    
    strike_bar:add(Clone{ source = t.img_srcs.strikes_txt})
    
    for i = 1, (t.num_strikes or error("must pass num_strikes",2)) do
        
        strikes[i]       = Clone{
            
            source       = strike_off,
            x            = 40*(i-1) + strike_off.w/2 + t.img_srcs.strikes_txt.w+20,
            y            = strike_off.w/2+3,
            anchor_point = {strike_off.w/2,strike_off.w/2},
        }
        
        strike_bar:add(strikes[i])
        
    end
    
end

local curr_i = 0

function strike_bar:num_strikes(amt)
    
    curr_i = amt
    
    for i = 1, # strikes do
        
        if i <= amt then
            
            strikes[i].source       =  strike_on
            strikes[i].anchor_point = {strike_on.w/2,strike_on.w/2}
            
        else
            
            strikes[i].source       =  strike_off
            strikes[i].anchor_point = {strike_off.w/2,strike_off.w/2}
            
        end
        
    end
    
end

function strike_bar:add_strike()
    
    curr_i = curr_i + 1
    
    bg:fade_in_victim(curr_i)
    
    strikes[curr_i].source       =  strike_on
    strikes[curr_i].anchor_point = {strike_on.w/2,strike_on.w/2}
    
    
    if curr_i >= # strikes then
        return true
    else
        return false
    end
    
end

return strike_bar