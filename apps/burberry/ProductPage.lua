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

product.func_tbls = {
    diana = {
            duration=10000,
            loop=true,
            func=function(this_obj,this_func_tbl,secs,p)
                this_obj.y_rotation={5*math.sin(math.pi*2*p),0,0}
            end
        }
}
local bottom_buttons_base = {
--[[
    Group{
        x = BACK_X,
        y = BACK_Y,
        --opacity = 255*.3,
    },
    Group{
        x = PLAY_X,
        y = PLAY_Y,
        opacity = 255*.4,
    },--]]
    Assets:Clone{src="assets/btn-back-off.png",opacity=0,x = BACK_X,y = BACK_Y,},
    Assets:Clone{src="assets/btn-playvideo-off.png",x = PLAY_X,y = PLAY_Y,},
    Assets:Clone{src="assets/btn-share-off.png",x = SHARE_X,y = SHARE_Y,},
}
local bottom_buttons_foci = {
--[[
    Group{
        x = BACK_X-10,
        y = BACK_Y-11,
        --opacity = 0,
    },
    Group{
        x = PLAY_X-10,
        y = PLAY_Y-11,
        opacity = 0,
    },--]]
    Assets:Clone{src="assets/btn-back-on.png",x = BACK_X,y = BACK_Y,},
    Assets:Clone{src="assets/btn-playvideo-on.png",opacity=0,x = PLAY_X,y = PLAY_Y,},
    Assets:Clone{src="assets/btn-share-on.png",opacity=0,x = SHARE_X,y = SHARE_Y,},
}
do
    --[[
    local arrow = Clone{source=imgs.fp.arrow, y_rotation={180,0,0}}
    local rect = Rectangle{w=204,h=55,color="000000"}
    local text = Text{
        font="Engravers MT ".. 30 .."px",
        text="BACK",
        position={rect.w/2+(arrow.w+22)/2,rect.h/2},
        color="ffffff",
    }
    text.anchor_point={text.w/2,text.h/2}
    arrow.anchor_point={0,arrow.h/2}
    arrow.y=rect.h/2
    arrow.x=text.x-text.w/2-(arrow.w+22)/2
    
    bottom_buttons_base[1]:add(rect,arrow,text)
    
    local left  = Clone{source=imgs.fp.foc_end}
    local mid   = Clone{source=imgs.fp.foc_mid,x=left.w,w=172,tiles}
    local right = Clone{source=imgs.fp.foc_end,x=2*left.w+mid.w,y_rotation={180,0,0}}
    
    bottom_buttons_foci[1]:add(left,mid,right)
    
    
    arrow = Clone{source=imgs.fp.arrow}
    
    rect = Rectangle{w=304,h=55,color="000000"}
    text = Text{
        font="Engravers MT ".. 30 .."px",
        text="PLAY VIDEO",
        position={rect.w/2+(arrow.w+22)/2,rect.h/2},
        color="ffffff",
    }
    text.anchor_point={text.w/2,text.h/2}
    arrow.anchor_point={0,arrow.h/2}
    arrow.y=rect.h/2
    arrow.x=text.x-text.w/2-(2*arrow.w+22)/2
    
    bottom_buttons_base[2]:add(rect,arrow,text)
    
    bottom_buttons_foci[2]:add(
        Clone{source=imgs.fp.foc_end},
        Clone{source=imgs.fp.foc_mid,x=26,w=272,tiles},
        Clone{source=imgs.fp.foc_end,x=26*2+272,y_rotation={180,0,0}}
    )
    --]]
end

umbrella:add(bg,product_text,product)
umbrella:add(unpack(bottom_buttons_base))
umbrella:add(unpack(bottom_buttons_foci))
product_page = {
    group = umbrella,
    func_tbls = {
        fade_in_from = {
            ["category_page"] = {
                duration = 300,
                first = true,
                func = function(this_obj,this_func_tbl,secs,p)
                    if this_func_tbl.first then
                        animate_list[product.func_tbls.diana] = product
                        this_func_tbl.first = false
                    end
                    this_obj.group.opacity=255*p
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
                    this_obj.group.opacity=255*(1-p)
                    if p == 1 then
                        animate_list[product.func_tbls.diana] = nil
                        bottom_buttons_base[1].opacity=0
                        bottom_buttons_foci[1].opacity=255
                        bottom_buttons_base[2].opacity=255
                        bottom_buttons_foci[2].opacity=0
                        bottom_buttons_base[3].opacity=255
                        bottom_buttons_foci[3].opacity=0
                        bottom_i = 1
                    end
                end
            }
        },
        focus_out_button = {
            index = 1,
            duration = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                
                bottom_buttons_base[this_func_tbl.index].opacity=255*p
                bottom_buttons_foci[this_func_tbl.index].opacity=255*(1-p)
            end
        },
        focus_in_button = {
            index = 1,
            duration = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                bottom_buttons_base[this_func_tbl.index].opacity=255*(1-(p))
                bottom_buttons_foci[this_func_tbl.index].opacity=255*(p)
                if p == 1 then
                    restore_keys()
                end
            end
        },
        diana_txt = {
            duration = 5000,
            loop = true,
            func = function(this_obj,this_func_tbl,secs,p)
                
            end
        }
    },
    keys = {
        [keys.Left] = function(self)
            if bottom_i == 1 then return end
            lose_keys()
            
            self.func_tbls.focus_out_button.index = bottom_i
            animate_list[self.func_tbls.focus_out_button] = self
            
            self.func_tbls.focus_in_button.index = bottom_i-1
            animate_list[self.func_tbls.focus_in_button] = self
            
            
            bottom_i = bottom_i - 1
        end,
        [keys.Right] = function(self)
            if bottom_i == 3 then return end
            lose_keys()
            
            self.func_tbls.focus_out_button.index = bottom_i
            animate_list[self.func_tbls.focus_out_button] = self
            
            self.func_tbls.focus_in_button.index = bottom_i+1
            animate_list[self.func_tbls.focus_in_button] = self
            
            bottom_i = bottom_i + 1
        end,
        [keys.OK] = function(self)
            if bottom_i == 1 then
                lose_keys()
                change_page_to("category_page")
            end
        end,
        [keys.BACK] = function(self)
            lose_keys()
            change_page_to("category_page")
        end
    }
}