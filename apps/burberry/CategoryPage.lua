local TITLE_X = 245
local TITLE_Y = 438
local TITLE_SZ = 54
local SUB_TITLE_X = 275
local SUB_TITLE_Y = 547
local SUB_TITLE_SZ = 30
local PRIOR_X = 280
local PRIOR_Y = 898
local VIEW_COL_X = 646
local VIEW_COL_Y = 898
local NEXT_X = 1113
local NEXT_Y = 898
local RIGHT_PANE_X = 1578
local TILE_TEXT_Y_OFFSET = 236
local TILE_W = 504--493
local TILE_H = 650--640

local bottom_i = 1
local right_i  = 1
local back_sel = false

local umbrella = Group{opacity=0}

local left_img = Image{src="assets/category-bg.jpg",size={screen_w,screen_h}}
local tile_group = Group{}
local shadow_group = Group{}
--[[
local tiles = {
    Image{src="assets/tile-category-eye-definer.png"},
    Image{src="assets/tile-category-eye-mascara.png"},
    Image{src="assets/tile-category-eye-sheer-shadow.png"},
    Image{src="assets/tile-category-glow-brush.png"},
    Image{src="assets/tile-category-glow-light.png"},
    Image{src="assets/tile-category-glow-warm.png"},
    Image{src="assets/tile-category-lip-cover.png"},
    Image{src="assets/tile-category-lip-glow.png"},
    Image{src="assets/tile-category-skin-brush.png"},
    Image{src="assets/tile-category-skin-compact.png"},
    Image{src="assets/tile-category-skin-foundation.png"},
}--]]
local tiles = {
    Image{src="assets/img-burberry-bty-brush.png"},
    Image{src="assets/img-burberry-bty-brush2.png"},
    Image{src="assets/img-eye-definer.png"},
    Image{src="assets/img-light-glow.png"},
    Image{src="assets/img-lip-cover.png"},
    Image{src="assets/img-lip-definer.png"},
    Image{src="assets/img-lip-glow.png"},
    Image{src="assets/img-mascara.png"},
    Image{src="assets/img-sheer-compact.png"},
    Image{src="assets/img-sheer-eye-shadow.png"},
    Image{src="assets/img-sheer-foundation.png"},
    Image{src="assets/img-warm-glow.png"},
}
local shadows ={}

local primary_focus = Group{}
--local glare_clip = Group{}
local top_button = Group{x=210,y=60,opacity = 255*.3}
local top_focus  = Group{x=200,y=50,opacity = 0}
local shine=Image{src="assets/highlight-alone.png"}
shine.anchor_point={shine.w/2,shine.h/2}
shine.x=TILE_W/2
shine.y=shine.h/2+5
--shine.scale={2,1}
shine.opacity=255*.25--.75
umbrella:add(left_img,top_focus,top_button,shadow_group,tile_group,primary_focus)

--[[local idled = Timer{interval=2000}
idled.on_timer = function()--]]

    --idled:stop()
--end
local left_i = 1
local right_i = 9
function set_tile_attrib(this_tile,this_shadow,i)
    this_tile.scale   = {1-.1*math.abs(5-i),1-.1*math.abs(5-i)}
    this_tile.opacity = 255*(1-.1*math.abs(5-i))
    this_shadow.scale = {1-.1*math.abs(5-i),(1-.1*math.abs(5-i))*2}
    if i <= 4 then
        this_tile.x=screen_w/2/5*(i-1)
        --tiles[i].y=screen_h/2-5*(5-i)+10
        --tiles[i].opacity=255*(1-.1*(5-i))
        --tiles[i].scale={1-.1*(5-i),1-.1*(5-i)}
        this_tile.y            =screen_h/2-70*math.abs(5-i)+50
        --this_tile.y_rotation={15,0,0}
        this_tile:raise_to_top()
    elseif i < 6 then
        --tiles[i].position={screen_w/2,screen_h/2+10}
        this_tile.x=screen_w/2+screen_w/5*(i-5)
        this_tile.y            =screen_h/2-70*math.abs(5-4)+50+75*(1-math.abs(i-5))
        --this_tile.y_rotation={-15*(i-5),0,0}
        this_tile:raise_to_top()
    elseif i < 10 then
        this_tile.x=screen_w/2/5*(i)+screen_w/2/5
        --tiles[i].y=screen_h/2-5*(i-5)+10
        --tiles[i].opacity=255*(1-.1*(i-5))
        --tiles[i].scale={1-.1*(i-5),1-.1*(i-5)}
        this_tile.y            =screen_h/2-70*math.abs(5-i)+50
        --this_tile.y_rotation={-15,0,0}
        this_tile:lower_to_bottom()
    end
    this_shadow.position={
        this_tile.x,--TILE_W/2*this_shadow.scale[1],
        this_tile.y+TILE_H/2*this_shadow.scale[1]-(this_shadow.h-43+5)*this_shadow.scale[1]
    }
    this_shadow.y_rotation={this_tile.y_rotation[1],0,0}
end
do
    
    local tl_corner = Clone{source=imgs.box_foc_corner}
    local top  = Clone{
        source=imgs.box_foc_side,
        x=tl_corner.w,w=TILE_W-2*tl_corner.w,
        tiles
    }
    local tr_corner = Clone{
        source=imgs.box_foc_corner,
        z_rotation={90,0,0},
        x=TILE_W
    }
    local left = Clone{
        source=imgs.box_foc_side,
        z_rotation={-90,0,0},
        w=TILE_H-2*tl_corner.w,
        y=TILE_H-tl_corner.w,
        tiles
    }
    local right = Clone{
        source=imgs.box_foc_side,
        z_rotation={90,0,0},
        w=TILE_H-2*tl_corner.w,
        x=TILE_W,
        y=tl_corner.w,
        tiles
    }
    local btm  = Clone{
        source=imgs.box_foc_side,
        z_rotation={180,0,0},
        x=TILE_W-tl_corner.w,
        y=TILE_H,
        w=TILE_W-2*tl_corner.w,
        tiles
    }
    local bl_corner = Clone{
        source=imgs.box_foc_corner,
        z_rotation={-90,0,0},
        y=TILE_H,
    }
    local br_corner = Clone{
        source=imgs.box_foc_corner,
        z_rotation={180,0,0},
        y=TILE_H,
        x=TILE_W
    }
    primary_focus:add(shine)--glare_clip)
    primary_focus:add(tl_corner,top,tr_corner,left,right,btm,bl_corner,br_corner)
    --glare_clip.clip={0,0,TILE_W,TILE_H}
    --glare_clip:add(shine)
    --glare_clip.y=3
    
    
    local rect = Rectangle{w=152,h=55,color="000000"}
    local text = Text{
        font="Engravers MT "..SUB_TITLE_SZ.."px",
        text="BACK",
        position={rect.w/2,rect.h/2},
        color="ffffff",
    }
    text.anchor_point={text.w/2,text.h/2}
    
    top_button:add(rect,text)
    
    local left  = Clone{source=imgs.fp.foc_end}
    local mid   = Clone{source=imgs.fp.foc_mid,x=left.w,w=120,tiles}
    local right = Clone{source=imgs.fp.foc_end,x=2*left.w+mid.w,y_rotation={180,0,0}}
    
    top_focus:add(left,mid,right)
    local c,img
    for i = 1,#tiles do
        img=tiles[i]
        img.anchor_point={img.w/2,img.h/2}
        tiles[i] = Group{}
        c = Clone{source="assets/tile-bg-50.png"}
        c.anchor_point={c.w/2,c.h/2}
        c.scale={2,2}
        c.position={c.w,c.h}
        img.position={c.w,c.h}
        tiles[i]:add(c,img)
        tile_group:add(tiles[i])
        shadows[i]=Clone{source="assets/shadow-center-tile.png"}
        shadows[i].anchor_point={60+TILE_W/2,0}
        shadow_group:add(shadows[i])
        
        tiles[i].anchor_point={c.w,c.h}
        set_tile_attrib(tiles[i],shadows[i],i)
        tiles[i].func_tbls = {
            diana_left = {
                duration=5000,
                loop=true,
                func=function(this_obj,this_func_tbl,secs,p)
                    tiles[i].y_rotation={15+10*math.sin(math.pi*2*p),0,0}
                    shadows[i].y_rotation={15+20*math.sin(math.pi*2*p),0,0}
                end
            },
            diana_mid = {
                duration=5000,
                loop=true,
                func=function(this_obj,this_func_tbl,secs,p)
                    tiles[i].y_rotation={10*math.sin(math.pi*2*p),0,0}
                    shadows[i].y_rotation={10*math.sin(math.pi*2*p),0,0}
                end
            },
            diana_right = {
                duration=5000,
                loop=true,
                func=function(this_obj,this_func_tbl,secs,p)
                    tiles[i].y_rotation={-15+10*math.sin(math.pi*2*p),0,0}
                    shadows[i].y_rotation={-15+20*math.sin(math.pi*2*p),0,0}
                end
            },
            diana = {
                duration=5000,
                loop=true,
                center = 0,
                phase=(i-1)/#tiles,
                func=function(this_obj,this_func_tbl,secs,p)
                    tiles[i].y_rotation={
                        this_func_tbl.center+10*math.sin(
                            math.pi*2*(p+this_func_tbl.phase)
                        ),
                        0,
                        0
                    }
                    shadows[i].y_rotation={
                        this_func_tbl.center+20*math.sin(
                            math.pi*2*(p+this_func_tbl.phase)
                        ),
                        0,
                        0
                    }
                end
            },
            recenter={
                duration=1000,
                start=0,
                targ=0,
                func=function(this_obj,this_func_tbl,secs,p)
                    tiles[i].func_tbls.diana.center =
                        this_func_tbl.start + (this_func_tbl.targ-this_func_tbl.start)*p
                end
            }
        }
        
        --[[
        tiles[i].scale={1-.1*math.abs(5-i),1-.1*math.abs(5-i)}
        tiles[i].opacity=255*(1-.1*math.abs(5-i))
        tiles[i].y=screen_h/2-5*math.abs(5-i)+10
        if i <= 4 then
            tiles[i].x=screen_w/2/5*(i-1)
            --tiles[i].y=screen_h/2-5*(5-i)+10
            --tiles[i].opacity=255*(1-.1*(5-i))
            --tiles[i].scale={1-.1*(5-i),1-.1*(5-i)}
            tiles[i].y_rotation={-10,0,0}
            tiles[i]:raise_to_top()
        elseif i < 6 then
            --tiles[i].position={screen_w/2,screen_h/2+10}
            tiles[i].x=screen_w/2+screen_w/5*(i-5)
            tiles[i]:raise_to_top()
        elseif i < 10 then
            tiles[i].x=screen_w/2/5*(i)+screen_w/2/5
            --tiles[i].y=screen_h/2-5*(i-5)+10
            --tiles[i].opacity=255*(1-.1*(i-5))
            --tiles[i].scale={1-.1*(i-5),1-.1*(i-5)}
            tiles[i].y_rotation={10,0,0}
            tiles[i]:lower_to_bottom()
        else
            tiles[i].opacity=0
        end
        --]]
        if i >= 10 then
            tiles[i].scale={0,0}
            shadows[i].scale={0,0}
        end

    end
    left_img:lower_to_bottom()
    primary_focus:raise_to_top()
    primary_focus.anchor_point={TILE_W/2,TILE_H/2}
    primary_focus.position={screen_w/2,screen_h/2+55}
    primary_focus.func_tbls = {
        diana = {
            duration=5000,
            loop=true,
            phase=(5-1)/#tiles,
            func=function(this_obj,this_func_tbl,secs,p)
                primary_focus.y_rotation={10*math.sin(math.pi*2*(p+this_func_tbl.phase)),0,0}
                shine.x=TILE_W/2-TILE_W/30*math.sin(math.pi*2*(p+this_func_tbl.phase))
                --shine.y=-10-10*math.cos(math.pi*4*(p+this_func_tbl.phase))
                shine.opacity=255*(.25+.2*math.sin(math.pi*2*(p+this_func_tbl.phase)))
            end
        },
        rephase = {
            duration=1000,
            start=0,
            targ=0,
            func=function(this_obj,this_func_tbl,secs,p)
                primary_focus.func_tbls.diana.phase =
                    this_func_tbl.start + (this_func_tbl.targ-this_func_tbl.start)*p
            end
        }
    }
end

local start_dianas = function()
    local index
    for i=1,9 do
        index = (left_i+i-2)%#tiles+1
        if i < 5 then
            tiles[index].func_tbls.diana.center=15
        elseif i == 5 then
            tiles[index].func_tbls.diana.center=0
            primary_focus.func_tbls.diana.phase = tiles[index].func_tbls.diana.phase
            animate_list[primary_focus.func_tbls.diana] = primary_focus
        elseif i > 5 then
            tiles[index].func_tbls.diana.center=-15
        end
        --tiles[index].func_tbls.diana.delay = 800*(index-1)
        animate_list[tiles[index].func_tbls.diana] = tiles[index]
        tiles[index].func_tbls.diana.delay=0
        tiles[index].func_tbls.diana.elapsed=0
        
    end
end
local stop_dianas = function()
    local index
    for i=1,9 do
        index = (left_i+i-2)%#tiles+1
        
        animate_list[tiles[index].func_tbls.diana] = nil
    end
    animate_list[primary_focus.func_tbls.diana] = nil
end
category_page = {
    group = umbrella,
    func_tbls = {
        fade_in_from = {
            ["collection_page"] = {
                duration = 300,
                func = function(this_obj,this_func_tbl,secs,p)
                    this_obj.group.opacity=255*p
                end
            },
            ["front_page"] = {
                duration = 300,
                first = true,
                func = function(this_obj,this_func_tbl,secs,p)
                    if this_func_tbl.first then
                        start_dianas()
                        this_func_tbl.first = false
                    end
                    this_obj.group.opacity=255*p
                    if p == 1 then
                        restore_keys()
                        this_func_tbl.first = true
                    end
                end
            },
            ["product_page"] = {
                duration = 300,
                first=true,
                func = function(this_obj,this_func_tbl,secs,p)
                    if this_func_tbl.first then
                        start_dianas()
                        print("lala")
                        this_func_tbl.first = false
                    end
                    this_obj.group.opacity=255*p
                    if p == 1 then
                        restore_keys()
                        this_func_tbl.first = true
                    end
                end
            }
        },
        fade_out_to = {
            ["front_page"] = {
                duration = 300,
                func = function(this_obj,this_func_tbl,secs,p)
                    this_obj.group.opacity=255*(1-p)
                    if p == 1 then
                        back_sel=false
                        primary_focus.opacity=255
                        top_focus.opacity=0
                        top_button.opacity=255*.3
                        stop_dianas()
                    end
                end
            },
            ["product_page"] = {
                duration = 300,
                func = function(this_obj,this_func_tbl,secs,p)
                    this_obj.group.opacity=255*(1-p)
                    if p == 1 then
                        back_sel=false
                        primary_focus.opacity=255
                        top_focus.opacity=0
                        top_button.opacity=255*.3
                        stop_dianas()
                    end
                end
            },
        },
        fade_out_back_button = {
            duration = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                top_button.opacity=255*(.3+.7*(1-p))
                top_focus.opacity=255*(1-p)
                primary_focus.opacity=255*(p)
                if p == 1 then
                    restore_keys()
                end
            end
        },
        fade_in_back_button = {
            duration = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                top_button.opacity=255*(.3+.7*(p))
                top_focus.opacity=255*(p)
                primary_focus.opacity=255*(1-p)
                if p == 1 then
                    restore_keys()
                end
            end
        },
        shift_left = {
            duration=200,
            func=function(this_obj,this_func_tbl,secs,p)
                primary_focus.opacity=255*(1-p)
                if p == 1 then
                    animate_list[this_obj.func_tbls.cycle_left]=this_obj
                    animate_list[tiles[(left_i+6-2)%#tiles+1].func_tbls.recenter] = tiles[(left_i+6-2)%#tiles+1]
                    animate_list[tiles[(left_i+5-2)%#tiles+1].func_tbls.recenter] = tiles[(left_i+5-2)%#tiles+1]
                    animate_list[primary_focus.func_tbls.rephase] = primary_focus
                end
            end
        },
        cycle_left = {
            duration=1000,
            func = function(this_obj,this_func_tbl,secs,p)
                --for i = left_i+1,right_i do
               
                for i = 2,9 do
                    --[[
                    set_tile_attrib(tiles[(left_i+i-2)%#tiles+1],shadows[(left_i+i-2)%#tiles+1],i-p)
                    
                    if i ==5 then
                        if p < .5 then
                            tiles[(left_i+i-2)%#tiles+1].scale={1-.1*math.abs(5-5),1-.1*math.abs(5-5)}
                            tiles[(left_i+i-2)%#tiles+1].x=screen_w/2+screen_w/5*((i-p*2)-5)
                        else
                            tiles[(left_i+i-2)%#tiles+1].scale={1-.1*math.abs(5-(i-(p*2-1))),1-.1*math.abs(5-(i-(p*2-1)))}
                            tiles[(left_i+i-2)%#tiles+1].x=screen_w/2+screen_w/5*(4-5)
                        end
                    elseif i == 6 then
                        if p < .5 then
                            tiles[(left_i+i-2)%#tiles+1].scale={1-.1*math.abs(5-(i-p*2)),1-.1*math.abs(5-(i-p*2))}
                            tiles[(left_i+i-2)%#tiles+1].x=screen_w/2+screen_w/5*(6-5)
                        else
                            tiles[(left_i+i-2)%#tiles+1].scale={1-.1*math.abs(5-5),1-.1*math.abs(5-5)}
                            tiles[(left_i+i-2)%#tiles+1].x=screen_w/2+screen_w/5*((i-(p*2-1))-5)
                        end
                    end
                    --]]
                    
                    
                    if i ==6 then---[[
                        if p < .2 then
                            --tiles[(left_i+i-2)%#tiles+1].scale={1-.1*math.abs(5-5),1-.1*math.abs(5-5)}
                            --tiles[(left_i+i-2)%#tiles+1].x=screen_w/2+screen_w/5*((i-p*2)-5)
                            tiles[(left_i+i-2)%#tiles+1]:raise_to_top()
                        else
                            set_tile_attrib(tiles[(left_i+i-2)%#tiles+1],shadows[(left_i+i-2)%#tiles+1],i-(p-.2)/.8)
                            
                        end--]]
                    elseif i == 5 then
                        if p < .8 then
                            set_tile_attrib(tiles[(left_i+i-2)%#tiles+1],shadows[(left_i+i-2)%#tiles+1],i-p/.8)
                            tiles[(left_i+i-2)%#tiles+1]:raise_to_top()
                        else
                            --tiles[(left_i+i-2)%#tiles+1].y_rotation={-15,0,0}
                            set_tile_attrib(tiles[(left_i+i-2)%#tiles+1],shadows[(left_i+i-2)%#tiles+1],i-1)
                        end
                    else
                        set_tile_attrib(tiles[(left_i+i-2)%#tiles+1],shadows[(left_i+i-2)%#tiles+1],i-p)
                    end
                    
                end
                tiles[(left_i+10-2)%#tiles+1]:lower_to_bottom()
                tiles[left_i].x=TILE_W*-.6*(p)
                shadows[left_i].x=TILE_W*-.6*(p)
                tiles[(left_i+10-2)%#tiles+1].x=screen_w+TILE_W*.6*(1-p)
                shadows[(left_i+10-2)%#tiles+1].x=screen_w+TILE_W*.6*(1-p)
                if p == 1 then
                    
                    animate_list[this_obj.func_tbls.end_left]=this_obj
                    animate_list[tiles[left_i].func_tbls.diana]=nil
                    left_i = (left_i)%#tiles+1
                end
            end
        },
        end_left = {
            duration=200,
            func=function(this_obj,this_func_tbl,secs,p)
                primary_focus.opacity=255*(p)
                if p == 1 then
                    restore_keys()
                end
            end
        },
        shift_right = {
            duration=200,
            func=function(this_obj,this_func_tbl,secs,p)
                primary_focus.opacity=255*(1-p)
                if p == 1 then
                    animate_list[this_obj.func_tbls.cycle_right]=this_obj
                    animate_list[tiles[(left_i+4-2)%#tiles+1].func_tbls.recenter] = tiles[(left_i+4-2)%#tiles+1]
                    animate_list[tiles[(left_i+5-2)%#tiles+1].func_tbls.recenter] = tiles[(left_i+5-2)%#tiles+1]
                    animate_list[primary_focus.func_tbls.rephase] = primary_focus
                end
            end
        },
        cycle_right = {
            duration=1000,
            func = function(this_obj,this_func_tbl,secs,p)
                --[[
                if p < 200/1400 then
                    primary_focus.opacity=255*(200/1400-p)
                    return
                elseif p > 1200/1400 then
                    primary_focus.opacity=255*(p-1200/1400)
                    return
                end
                p = (p-200/1400)*(1400/1200)
                print(p)
                --]]
                --for i = left_i+1,right_i do
                for i = 1,8 do
                    
                    
                    if i ==4 then---[[
                        if p < .2 then
                            --tiles[(left_i+i-2)%#tiles+1].scale={1-.1*math.abs(5-5),1-.1*math.abs(5-5)}
                            --tiles[(left_i+i-2)%#tiles+1].x=screen_w/2+screen_w/5*((i-p*2)-5)
                            tiles[(left_i+i-2)%#tiles+1]:raise_to_top()
                        else
                            set_tile_attrib(tiles[(left_i+i-2)%#tiles+1],shadows[(left_i+i-2)%#tiles+1],i+(p-.2)/.8)
                            
                        end--]]
                    elseif i == 5 then
                        if p < .8 then
                            set_tile_attrib(tiles[(left_i+i-2)%#tiles+1],shadows[(left_i+i-2)%#tiles+1],i+p/.8)
                            tiles[(left_i+i-2)%#tiles+1]:raise_to_top()
                        else
                            --tiles[(left_i+i-2)%#tiles+1].y_rotation={-15,0,0}
                            set_tile_attrib(tiles[(left_i+i-2)%#tiles+1],shadows[(left_i+i-2)%#tiles+1],i+1)
                        end
                    else
                        set_tile_attrib(tiles[(left_i+i-2)%#tiles+1],shadows[(left_i+i-2)%#tiles+1],i+p)
                    end
                end
                shadows[(left_i-2)%#tiles+1].x=TILE_W*-.6*(1-p)
                shadows[(left_i+9-2)%#tiles+1].x=screen_w+TILE_W*.6*(p)
                tiles[(left_i-2)%#tiles+1].x=TILE_W*-.6*(1-p)
                tiles[(left_i+9-2)%#tiles+1].x=screen_w+TILE_W*.6*(p)
                if p == 1 then
                    animate_list[tiles[(left_i+9-2)%#tiles+1].func_tbls.diana]=nil
                    left_i = (left_i-2)%#tiles+1
                    animate_list[this_obj.func_tbls.end_right]=this_obj
                end
            end
        },
        end_right = {
            duration=200,
            func=function(this_obj,this_func_tbl,secs,p)
                primary_focus.opacity=255*(p)
                if p == 1 then
                    restore_keys()
                end
            end
        },
    },
    keys = {
        [keys.Up] = function(self)
            --idled:start()
            if not back_sel then
                lose_keys()
                animate_list[self.func_tbls.fade_in_back_button]=self
                back_sel = true
            end
        end,
        [keys.Down] = function(self)
            --idled:start()
            if back_sel then
                lose_keys()
                animate_list[self.func_tbls.fade_out_back_button]=self
                back_sel = false
            end
        end,
        [keys.Right] = function(self)
            --idled:start()
            if back_sel then return end
            lose_keys()
            set_tile_attrib(tiles[(left_i+10-2)%#tiles+1],shadows[(left_i+10-2)%#tiles+1],9)
            
            animate_list[self.func_tbls.end_right] = nil
            animate_list[self.func_tbls.end_left] = nil
            
            tiles[(left_i+10-2)%#tiles+1].func_tbls.diana.delay =
                -tiles[(left_i+9-2)%#tiles+1].func_tbls.diana.elapsed
            tiles[(left_i+10-2)%#tiles+1].func_tbls.diana.center=-15
            animate_list[tiles[(left_i+10-2)%#tiles+1].func_tbls.diana] = tiles[(left_i-2)%#tiles+1]
            
            tiles[(left_i+6-2)%#tiles+1].func_tbls.recenter.start=-15
            tiles[(left_i+6-2)%#tiles+1].func_tbls.recenter.targ = 0
            
            tiles[(left_i+5-2)%#tiles+1].func_tbls.recenter.start= 0
            tiles[(left_i+5-2)%#tiles+1].func_tbls.recenter.targ =15
            
            
            primary_focus.func_tbls.rephase.start = tiles[(left_i+5-2)%#tiles+1].func_tbls.diana.phase
            primary_focus.func_tbls.rephase.targ  = tiles[(left_i+6-2)%#tiles+1].func_tbls.diana.phase
            
            
            
            tiles[(left_i+10-2)%#tiles+1].x=screen_w+TILE_W*.6
            shadows[(left_i+10-2)%#tiles+1].x=screen_w+TILE_W*.6
            tiles[(left_i+10-2)%#tiles+1]:lower_to_bottom()
            animate_list[self.func_tbls.shift_left]=self
        end,
        [keys.Left] = function(self)
            --idled:start()
            if back_sel then return end
            lose_keys()
            set_tile_attrib(tiles[(left_i-2)%#tiles+1],shadows[(left_i-2)%#tiles+1],1)
            
            animate_list[self.func_tbls.end_right] = nil
            animate_list[self.func_tbls.end_left] = nil
            
            tiles[(left_i-2)%#tiles+1].func_tbls.diana.delay =
                -tiles[(left_i+1-2)%#tiles+1].func_tbls.diana.elapsed
            tiles[(left_i-2)%#tiles+1].func_tbls.diana.center=15
            animate_list[tiles[(left_i-2)%#tiles+1].func_tbls.diana] = tiles[(left_i-2)%#tiles+1]
            
            tiles[(left_i+4-2)%#tiles+1].func_tbls.recenter.start=15
            tiles[(left_i+4-2)%#tiles+1].func_tbls.recenter.targ = 0
            
            tiles[(left_i+5-2)%#tiles+1].func_tbls.recenter.start= 0
            tiles[(left_i+5-2)%#tiles+1].func_tbls.recenter.targ =-15
            
            
            
            primary_focus.func_tbls.rephase.start = tiles[(left_i+5-2)%#tiles+1].func_tbls.diana.phase
            primary_focus.func_tbls.rephase.targ  = tiles[(left_i+4-2)%#tiles+1].func_tbls.diana.phase
            
            
            
            tiles[(left_i-2)%#tiles+1].x=TILE_W*-.6
            shadows[(left_i-2)%#tiles+1].x=TILE_W*-.6
            tiles[(left_i-2)%#tiles+1]:lower_to_bottom()
            animate_list[self.func_tbls.shift_right]=self
        end,
        [keys.OK] = function(self)
            if back_sel then
                lose_keys()
                change_page_to("front_page")
            else
                lose_keys()
                change_page_to("product_page")
            end
        end,
    }
}
    