local BACK_X = 659
local BACK_Y = 883
local PLAY_X = 896
local PLAY_Y = 883
local SHARE_X = 1273
local SHARE_Y = 883

local umbrella = Group{opacity=0}
local bottom_i = 1
local bg = Assets:Clone{src="assets/bg-product.jpg",scale={2,2}}
local product_text = Assets:Clone{src="assets/text-product.png",x=707,y=99}

local product = Assets:Clone{src="assets/product-image.png",x=100,y=280}
product:move_anchor_point(product.w/2,product.h/2)

product.diana = {
    duration=10000,
    loop=true,
    func=function(this_obj,this_func_tbl,secs,p)
        this_obj.y_rotation={5*math.sin(math.pi*2*p),0,0}
    end
}

local bottom_buttons_base = {
    Assets:Clone{src="assets/btn-back-off.png",      x = BACK_X,  y = BACK_Y  },
    Assets:Clone{src="assets/btn-playvideo-off.png", x = PLAY_X,  y = PLAY_Y  },
    Assets:Clone{src="assets/btn-share-off.png",     x = SHARE_X, y = SHARE_Y },
}
local bottom_buttons_foci = {
    Assets:Clone{src="assets/btn-back-on.png",       x = BACK_X,  y = BACK_Y  },
    Assets:Clone{src="assets/btn-playvideo-on.png",  x = PLAY_X,  y = PLAY_Y  },
    Assets:Clone{src="assets/btn-share-on.png",      x = SHARE_X, y = SHARE_Y },
}

umbrella:add(bg,product_text,product)
umbrella:add(unpack(bottom_buttons_base))
umbrella:add(unpack(bottom_buttons_foci))

umbrella.reactive_list = {}
local mouse_pos = nil

for i,button in ipairs(bottom_buttons_base) do
    
    table.insert(umbrella.reactive_list,button)
    
    local focus = bottom_buttons_foci[i]
    
    button.fade_out = {
        focus = Interval(255,0),
        duration = 300,
        func = function(this_obj,this_func_tbl,secs,p)
            focus.opacity=this_func_tbl.focus:get_value(p)
        end
    }
    button.fade_in = {
        focus = Interval(0,255),
        duration = 300,
        func = function(this_obj,this_func_tbl,secs,p)
            focus.opacity=this_func_tbl.focus:get_value(p)
        end
    }
    
    function button:launch_fade_in()
        
        bottom_i = i
        
        animate_list[button.fade_out] = nil
        
        button.fade_in.focus.from = focus.opacity
        
        animate_list[button.fade_in] = button
        
    end
    
    function button:launch_fade_out()
        
        animate_list[button.fade_in] = nil
        
        button.fade_out.focus.from = focus.opacity
        
        animate_list[button.fade_out] = button
        
    end
    
    function button:on_enter()
        
        mouse_pos = i
        
        button:launch_fade_in()
        
    end
    
    function button:on_leave()
        
        mouse_pos = nil
        
        button:launch_fade_out()
        
    end
    
    
    if i == 1 then
        function button:on_button_up()
                        
            dolater(change_page_to,"category_page")
            
        end
    end
end

umbrella.func_tbls = {
    fade_in_from = {
        ["category_page"] = {
            duration = 300,
            first = true,
            func = function(this_obj,this_func_tbl,secs,p)
                
                if this_func_tbl.first then
                    
                    animate_list[product.diana] = product
                    
                    if using_keys then
                        
                        for i, v in ipairs(bottom_buttons_foci) do
                            
                            if i == 1 then
                                
                                v.opacity=255
                                
                                bottom_i = i
                                
                            else
                                
                                v.opacity=0
                                
                            end
                            
                        end
                        
                    else
                        
                        for _, v in ipairs(bottom_buttons_foci) do
                            
                            v.opacity=0
                            
                        end
                        
                    end
                    
                    this_func_tbl.first = false
                    
                end
                
                this_obj.opacity=255*p
                
                if p == 1 then
                    
                    restore_keys()
                    
                    this_func_tbl.first = true
                    
                end
            end
        },
    },
    fade_out_to = {
        ["category_page"] = {
            duration = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                this_obj.opacity=255*(1-p)
                if p == 1 then
                    animate_list[product.diana] = nil
                    mouse_pos = nil
                end
            end
        }
    },
}

umbrella.keys = {
    
    [keys.Left] = function(self)
        
        if bottom_i == 1 then return end
        
        bottom_buttons_base[bottom_i  ]:launch_fade_out()
        
        bottom_buttons_base[bottom_i-1]:launch_fade_in()
        
    end,
    
    [keys.Right] = function(self)
        
        if bottom_i == 3 then return end
        
        bottom_buttons_base[bottom_i  ]:launch_fade_out()
        
        bottom_buttons_base[bottom_i+1]:launch_fade_in()
        
    end,
    
    [keys.OK] = function(self)
        
        if bottom_i == 1 then
            
            bottom_buttons_base[bottom_i]:on_button_up()
            
        end
        
    end,
    
    [keys.BACK] = function(self)
        
        bottom_buttons_base[1]:on_button_up()
        
    end
    
}



function umbrella:to_keys()
    
    --if mouse_pos ~= nil then
    --    
    --    bottom_buttons_base[mouse_pos]:launch_fade_out()
    --    
    --end
    
    --bottom_buttons_base[bottom_i]:launch_fade_in()
    
end

function umbrella:to_mouse()
    
    bottom_buttons_base[bottom_i]:launch_fade_out()
    
    if mouse_pos ~= nil then
        
        bottom_buttons_base[mouse_pos]:launch_fade_in()
        
    end
    
end

return umbrella

