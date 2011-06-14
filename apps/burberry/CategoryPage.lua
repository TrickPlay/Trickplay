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

local umbrella = Group{opacity=0,name="Category Page"}

local sw = Stopwatch()
sw:start()
local hold = false

local left_img = Assets:Clone{src="assets/category-bg.jpg",size={screen_w,screen_h}}
local tile_group = Group{}
local shadow_group = Group{}

local tiles = {
    Assets:Clone{src="assets/img-burberry-bty-brush.png"},
    Assets:Clone{src="assets/img-burberry-bty-brush2.png"},
    Assets:Clone{src="assets/img-eye-definer.png"},
    Assets:Clone{src="assets/img-light-glow.png"},
    Assets:Clone{src="assets/img-lip-cover.png"},
    Assets:Clone{src="assets/img-lip-definer.png"},
    Assets:Clone{src="assets/img-lip-glow.png"},
    Assets:Clone{src="assets/img-mascara.png"},
    Assets:Clone{src="assets/img-sheer-compact.png"},
    Assets:Clone{src="assets/img-sheer-eye-shadow.png"},
    Assets:Clone{src="assets/img-sheer-foundation.png"},
    Assets:Clone{src="assets/img-warm-glow.png"},
}
local shadows ={}

local primary_focus = Group{}
--local glare_clip = Group{}

local top_button=Assets:Clone{src="assets/btn-back-off.png",x = 200,y = 50,}
local top_focus=Assets:Clone{src="assets/btn-back-on.png",opacity=0,x = 200,y = 50,}


local shine=Assets:Clone{src="assets/highlight-alone.png"}
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
local function rel_i(i)   return (left_i+i-2)%#tiles+1 end

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
        
        this_tile.func_tbls.diana.center = 15
        --this_tile.y_rotation={15,0,0}
        this_tile:raise_to_top()
    elseif i < 4.2 then
        i=4
        --tiles[i].position={screen_w/2,screen_h/2+10}
        this_tile.x=screen_w/2+screen_w/5*(i-5)
        this_tile.y            =screen_h/2-70*math.abs(5-4)+50+75*(1-math.abs(i-5))
        
        this_tile.func_tbls.diana.center = -15*(i-5)
        
        --this_tile.y_rotation={-15*(i-5),0,0}
        this_tile:raise_to_top()
    elseif i < 5.8 then
        i = (i-5)/.8+5
        --tiles[i].position={screen_w/2,screen_h/2+10}
        this_tile.x=screen_w/2+screen_w/5*(i-5)
        this_tile.y            =screen_h/2-70*math.abs(5-4)+50+75*(1-math.abs(i-5))
        
        this_tile.func_tbls.diana.center = -15*(i-5)
        
        --this_tile.y_rotation={-15*(i-5),0,0}
        this_tile:raise_to_top()
    elseif i < 6 then
        i=6
        --tiles[i].position={screen_w/2,screen_h/2+10}
        this_tile.x=screen_w/2+screen_w/5*(i-5)
        this_tile.y            =screen_h/2-70*math.abs(5-4)+50+75*(1-math.abs(i-5))
        
        this_tile.func_tbls.diana.center = -15*(i-5)
        
        --this_tile.y_rotation={-15*(i-5),0,0}
        this_tile:lower_to_bottom()
    else--if i < 10 then
        this_tile.x=screen_w/2/5*(i)+screen_w/2/5
        --tiles[i].y=screen_h/2-5*(i-5)+10
        --tiles[i].opacity=255*(1-.1*(i-5))
        --tiles[i].scale={1-.1*(i-5),1-.1*(i-5)}
        this_tile.y            =screen_h/2-70*math.abs(5-i)+50
        this_tile.func_tbls.diana.center = -15
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
    
    local tl_corner = Assets:Clone{src=imgs.box_foc_corner}
    local top  = Assets:Clone{
        src=imgs.box_foc_side,
        x=tl_corner.w,w=TILE_W-2*tl_corner.w,
        tiles
    }
    local tr_corner = Assets:Clone{
        src=imgs.box_foc_corner,
        z_rotation={90,0,0},
        x=TILE_W
    }
    local left = Assets:Clone{
        src=imgs.box_foc_side,
        z_rotation={-90,0,0},
        w=TILE_H-2*tl_corner.w,
        y=TILE_H-tl_corner.w,
        tiles
    }
    local right = Assets:Clone{
        src=imgs.box_foc_side,
        z_rotation={90,0,0},
        w=TILE_H-2*tl_corner.w,
        x=TILE_W,
        y=tl_corner.w,
        tiles
    }
    local btm  = Assets:Clone{
        src=imgs.box_foc_side,
        z_rotation={180,0,0},
        x=TILE_W-tl_corner.w,
        y=TILE_H,
        w=TILE_W-2*tl_corner.w,
        tiles
    }
    local bl_corner = Assets:Clone{
        src=imgs.box_foc_corner,
        z_rotation={-90,0,0},
        y=TILE_H,
    }
    local br_corner = Assets:Clone{
        src=imgs.box_foc_corner,
        z_rotation={180,0,0},
        y=TILE_H,
        x=TILE_W
    }
    primary_focus:add(shine)--glare_clip)
    primary_focus:add(
        tl_corner,top,tr_corner,left,right,btm,bl_corner,br_corner)
    --glare_clip.clip={0,0,TILE_W,TILE_H}
    --glare_clip:add(shine)
    --glare_clip.y=3
    
    --[[
    local rect = Rectangle{w=152,h=55,color="000000"}
    local text = Text{
        font="Engravers MT "..SUB_TITLE_SZ.."px",
        text="BACK",
        position={rect.w/2,rect.h/2},
        color="ffffff",
    }
    text.anchor_point={text.w/2,text.h/2}
    
    top_button:add(rect,text)
    
    local left  = Assets:Clone{source=imgs.fp.foc_end}
    local mid   = Assets:Clone{source=imgs.fp.foc_mid,x=left.w,w=120,tiles}
    local right = Assets:Clone{source=imgs.fp.foc_end,x=2*left.w+mid.w,y_rotation={180,0,0}}
    
    top_focus:add(left,mid,right)
    --]]
    
    local c,img
    for i = 1,#tiles do
        img=tiles[i]
        img.anchor_point={img.w/2,img.h/2}
        tiles[i] = Group{}
        c = Assets:Clone{src="assets/tile-bg-50.png"}
        c.anchor_point={c.w/2,c.h/2}
        c.scale={2,2}
        c.position={c.w,c.h}
        img.position={c.w,c.h}
        tiles[i]:add(c,img)
        tile_group:add(tiles[i])
        shadows[i]=Assets:Clone{src="assets/shadow-center-tile.png"}
        shadows[i].anchor_point={60+TILE_W/2,0}
        shadow_group:add(shadows[i])
        
        
        
        tiles[i].anchor_point={c.w,c.h}
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
                duration = 5000,
                loop     = true,
                center   = 0,
                delay    = 0,
                phase    = (i-1)/#tiles,
                func     = function( this_obj, this_func_tbl, secs, p)
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
        set_tile_attrib(tiles[i],shadows[i],i)
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
    local tile
    for i=0,10 do
        tile = tiles[rel_i(i)]
        if i < 5 then
            tile.func_tbls.diana.center=15
        elseif i == 5 then
            tile.func_tbls.diana.center=0
            primary_focus.func_tbls.diana.phase = tile.func_tbls.diana.phase
            primary_focus.delay   = 0
            primary_focus.elapsed = 0
            animate_list[primary_focus.func_tbls.diana] = primary_focus
        elseif i > 5 then
            tile.func_tbls.diana.center=-15
        end
        
        
        tile.func_tbls.diana.delay   = 0--tile.func_tbls.diana.delay+tile.func_tbls.diana.elapsed
        tile.func_tbls.diana.elapsed = 0
        
        animate_list[tile.func_tbls.diana] = tile
    end
end
local stop_dianas = function()
    
    for i = 1, 9 do
        
        animate_list[tiles[rel_i(i)].func_tbls.diana] = nil
        
    end
    
    animate_list[primary_focus.func_tbls.diana] = nil
end
umbrella.extra = {
    func_tbls = {
        fade_in_from = {
            ["collection_page"] = {
                duration = 300,
                func = function(this_obj,this_func_tbl,secs,p)
                    this_obj.opacity=255*p
                end
            },
            ["front_page"] = {
                duration = 300,
                first = true,
                func = function(this_obj,this_func_tbl,secs,p)
                    if this_func_tbl.first then
                        print("old phase",primary_focus.func_tbls.diana.phase)
                        start_dianas()
                        print("new phase",primary_focus.func_tbls.diana.phase)
                        this_func_tbl.first = false
                    end
                    this_obj.opacity=255*p
                    if p == 1 then
                        restore_keys()
                        this_func_tbl.first = true
                        hold = false
                    end
                end
            },
            ["product_page"] = {
                duration = 300,
                first=true,
                func = function(this_obj,this_func_tbl,secs,p)
                    if this_func_tbl.first then
                        print("old phase",primary_focus.func_tbls.diana.phase)
                        start_dianas()
                        print("new phase",primary_focus.func_tbls.diana.phase)
                        --print("lala")
                        this_func_tbl.first = false
                    end
                    --this_obj.opacity=255*p
                    if p == 1 then
                        restore_keys()
                        this_func_tbl.first = true
                        hold = false
                    end
                end
            }
        },
        fade_out_to = {
            ["front_page"] = {
                duration = 300,
                func = function(this_obj,this_func_tbl,secs,p)
                    this_obj.opacity=255*(1-p)
                    if p == 1 then
                        back_sel=false
                        primary_focus.opacity=255
                        top_focus.opacity=0
                        --top_button.opacity=255
                        stop_dianas()
                    end
                end
            },
            ["product_page"] = {
                duration = 300,
                func = function(this_obj,this_func_tbl,secs,p)
                    --this_obj.opacity=255*(1-p)
                    if p == 1 then
                        back_sel=false
                        primary_focus.opacity=255
                        top_focus.opacity=0
                        top_button.opacity=255
                        stop_dianas()
                    end
                end
            },
        },
        fade_out_back_button = {
            duration = 300,
            focus = Interval(255,0),
            func = function(this_obj,this_func_tbl,secs,p)
                --top_button.opacity=255*p
                top_focus.opacity=this_func_tbl.focus:get_value(p)
                primary_focus.opacity=255-this_func_tbl.focus:get_value(p)
                if p == 1 then
                    restore_keys()
                end
            end
        },
        fade_in_back_button = {
            duration = 300,
            focus = Interval(0,255),
            func = function(this_obj,this_func_tbl,secs,p)
                --top_button.opacity=255*(1-p)
                top_focus.opacity=this_func_tbl.focus:get_value(p)
                primary_focus.opacity=255-this_func_tbl.focus:get_value(p)
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
                    animate_list[tiles[rel_i(6)].func_tbls.recenter] = tiles[rel_i(6)]
                    animate_list[tiles[rel_i(5)].func_tbls.recenter] = tiles[rel_i(5)]
                    animate_list[primary_focus.func_tbls.rephase] = primary_focus
                end
            end
        },
        cycle_left = {
            duration=1000,
            func = function(this_obj,this_func_tbl,secs,p)
                --for i = left_i+1,right_i do
               
                for i = 1,10 do
                    
                    set_tile_attrib(
                        tiles[rel_i(i)],
                        shadows[rel_i(i)],
                        i-p
                    )
                    
                end
                
                if p == 1 then
                    
                    animate_list[this_obj.func_tbls.end_left]=this_obj
                    animate_list[tiles[left_i].func_tbls.diana]=nil
                    left_i = rel_i(2)
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
                    animate_list[tiles[rel_i(4)].func_tbls.recenter] = tiles[rel_i(4)]
                    animate_list[tiles[rel_i(5)].func_tbls.recenter] = tiles[rel_i(5)]
                    animate_list[primary_focus.func_tbls.rephase] = primary_focus
                end
            end
        },
        cycle_right = {
            duration=1000,
            func = function(this_obj,this_func_tbl,secs,p)
                
                for i = 0,9 do
                    
                    set_tile_attrib(
                        tiles[rel_i(i)],
                        shadows[rel_i(i)],
                        i+p
                    )
                    
                end
                
                if p == 1 then
                    animate_list[tiles[rel_i(9)].func_tbls.diana]=nil
                    left_i = rel_i(0)
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
        high_speed_spin = {
            duration = 500,
            x        = 0,
            vx       = 1500,
            dir      = 1,
            func     = function(this_obj,f_t,secs,p)
                
                f_t.x = f_t.x + f_t.dir*f_t.vx*secs
                
                this_obj:on_motion_x(f_t.x)
                
                if p == 1 then
                    
                    this_obj.func_tbls.low_speed_spin.x   = f_t.x
                    this_obj.func_tbls.low_speed_spin.dir = f_t.dir
                    
                    animate_list[this_obj.func_tbls.low_speed_spin] = this_obj
                    
                end
            end
        },
        low_speed_spin = {
            duration = 500,
            x        = 0,
            vx       = 1000,--Interval(0,1)
            dir      = 1,
            func     = function(this_obj,f_t,secs,p)
                
                f_t.x = f_t.x + f_t.dir*f_t.vx*secs
                
                this_obj:on_motion_x(f_t.x)
                
                if p == 1 then
                    
                    local glide_range = this_obj.func_tbls.glide_to_next.p_range
                    
                    this_obj.func_tbls.glide_to_next.curr_pos, p = this_obj:translate_x_to_i(f_t.x)
                    
                    glide_range.from   = p - this_obj.p_offset
                    
                    if f_t.dir == 1 then
                        if glide_range.from < .8 then
                            glide_range.to = 1
                        else
                            glide_range.to = 2
                        end
                    else
                        if glide_range.from < .2 then
                            glide_range.to = -1
                        else
                            glide_range.to = 0
                        end
                    end
                    
                    this_obj.func_tbls.glide_to_next.duration = math.abs(
                        500 * ( glide_range.to - glide_range.from )
                    )
                    
                    animate_list[ this_obj.func_tbls.glide_to_next ] = this_obj
                    
                end
            end
        },
        glide_to_next = {
            duration = 500,
            p_range  = Interval(0,1),
            curr_pos = 1,
            func     = function(this_obj,this_func_tbl,secs,p)
                --print("p",p)
                this_obj:on_motion_p(
                    this_func_tbl.curr_pos,
                    this_func_tbl.p_range:get_value(p)
                )
                
                if p == 1 then
                    this_obj:on_motion_p(
                        this_func_tbl.curr_pos+this_func_tbl.p_range.to,
                        0
                    )
                end
            end
        },
        release = {
            --duration=200,
            vx = 0,
            x  = 0,
            --vy = 0,
            func=function(this_obj,this_func_tbl,secs,p)
                
                if this_func_tbl.vx < 0 then
                    
                    this_func_tbl.vx = this_func_tbl.vx + 20000 * secs
                    
                    if this_func_tbl.vx > 0 then
                        
                        animate_list[this_func_tbl] = nil
                        
                    else
                        
                        this_func_tbl.x = this_func_tbl.x + this_func_tbl.vx*secs/4
                        
                        this_obj:on_motion_x(this_func_tbl.x)
                        
                    end
                    
                else
                    
                    this_func_tbl.vx = this_func_tbl.vx - 20000 * secs
                    
                    if this_func_tbl.vx < 0 then
                        
                        animate_list[this_func_tbl] = nil
                        
                    else
                        
                        this_func_tbl.x = this_func_tbl.x + this_func_tbl.vx*secs/4
                        
                        this_obj:on_motion_x(this_func_tbl.x)
                        
                    end
                    
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
            set_tile_attrib(
                tiles[rel_i(10)],
                shadows[rel_i(10)],
                9
            )
            
            animate_list[self.func_tbls.end_right] = nil
            animate_list[self.func_tbls.end_left] = nil
            
            tiles[rel_i(10)].func_tbls.diana.delay =
                -tiles[rel_i( 9)].func_tbls.diana.elapsed
            tiles[rel_i(10)].func_tbls.diana.center=-15
            animate_list[tiles[rel_i(10)].func_tbls.diana] = tiles[rel_i(10)]
            
            tiles[rel_i(6)].func_tbls.recenter.start=-15
            tiles[rel_i(6)].func_tbls.recenter.targ = 0
            
            tiles[rel_i(5)].func_tbls.recenter.start= 0
            tiles[rel_i(5)].func_tbls.recenter.targ =15
            
            primary_focus.func_tbls.rephase.start = tiles[rel_i(5)].func_tbls.diana.phase
            primary_focus.func_tbls.rephase.targ  = tiles[rel_i(6)].func_tbls.diana.phase
            
            tiles[rel_i(10)].x=screen_w+TILE_W*.6
            shadows[rel_i(10)].x=screen_w+TILE_W*.6
            tiles[rel_i(10)]:lower_to_bottom()
            animate_list[self.func_tbls.shift_left]=self
        end,
        [keys.Left] = function(self)
            --idled:start()
            if back_sel then return end
            lose_keys()
            set_tile_attrib(
                tiles[rel_i(0)],
                shadows[rel_i(0)],
                1
            )
            
            animate_list[self.func_tbls.end_right] = nil
            animate_list[self.func_tbls.end_left] = nil
            
            tiles[rel_i(0)].func_tbls.diana.delay =
                -tiles[rel_i(1)].func_tbls.diana.elapsed
            tiles[rel_i(0)].func_tbls.diana.center=15
            animate_list[tiles[rel_i(0)].func_tbls.diana] = tiles[rel_i(0)]
            
            tiles[rel_i(4)].func_tbls.recenter.start=15
            tiles[rel_i(4)].func_tbls.recenter.targ = 0
            tiles[rel_i(5)].func_tbls.recenter.start= 0
            tiles[rel_i(5)].func_tbls.recenter.targ =-15
            
            
            
            primary_focus.func_tbls.rephase.start = tiles[rel_i(5)].func_tbls.diana.phase
            primary_focus.func_tbls.rephase.targ  = tiles[rel_i(4)].func_tbls.diana.phase
            
            
            
            tiles[rel_i(0)].x=TILE_W*-.6
            shadows[rel_i(0)].x=TILE_W*-.6
            tiles[rel_i(0)]:lower_to_bottom()
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
        [keys.BACK] = function(self)
            lose_keys()
            change_page_to("front_page")
        end
    },
    
    translate_x_to_i = function(self,x)
        if x < screen_w/2-screen_w/5 then
            return math.floor(x/(screen_w/2/5)+1), x%(screen_w/2/5)/(screen_w/2/5)
        elseif x >screen_w/2+screen_w/5 then
            return math.floor(x/(screen_w/2/5)-1), x%(screen_w/2/5)/(screen_w/2/5)
        else
            return  math.floor((x - screen_w/2)/(screen_w/5) + 5),
                    (x - screen_w/2)%(screen_w/5)/(screen_w/5)
        end
    end,
    
    on_motion_p = function(self,curr_pos,p)
        if curr_pos < self.curr_pos then
            
            animate_list[tiles[left_i].func_tbls.diana]=nil
            
            tiles[rel_i(10)].func_tbls.diana.delay =
                -tiles[rel_i( 9)].func_tbls.diana.elapsed
            
            animate_list[tiles[rel_i(10)].func_tbls.diana] = tiles[rel_i(10)]
            
            left_i = rel_i(2)
            --print("old phase",primary_focus.func_tbls.diana.phase)
            primary_focus.func_tbls.diana.phase = tiles[rel_i(5)].func_tbls.diana.phase
            --print("new phase",primary_focus.func_tbls.diana.phase)
            self.curr_pos = curr_pos
            
        elseif curr_pos > self.curr_pos then
            
            animate_list[tiles[rel_i(9)].func_tbls.diana]=nil
            
            tiles[rel_i(0)].func_tbls.diana.delay =
                -tiles[rel_i(1)].func_tbls.diana.elapsed
            
            animate_list[tiles[rel_i(0)].func_tbls.diana] = tiles[rel_i(0)]
            
            left_i = rel_i(0)
            --print("old phase",primary_focus.func_tbls.diana.phase)
            primary_focus.func_tbls.diana.phase = tiles[rel_i(5)].func_tbls.diana.phase
            --print("new phase",primary_focus.func_tbls.diana.phase)
            self.curr_pos = curr_pos
            
        end
        
        for i = 0, 10 do
            set_tile_attrib(
                tiles[  rel_i(i)],
                shadows[rel_i(i)],
                i+p
            )
        end
        
    end,
    
    on_motion_x = function(self,x,y)
        --print("gah",x,y)
        local c_p,p = self:translate_x_to_i(x)
        self:on_motion_p( c_p, p - self.p_offset )
    end,
    
    hold = function(self,x,y)
        
        --if get_curr_page() ~= "category_page" then return end
        
        animate_list[self.func_tbls.high_speed_spin] = nil
        animate_list[self.func_tbls.low_speed_spin]  = nil
        animate_list[self.func_tbls.glide_to_next]   = nil
        
        self.curr_pos, self.p_offset = self:translate_x_to_i(x)
        
        self.hold_time = sw.elapsed
        --self.curr_pos = self.curr_pos - 1
        --print(self.curr_pos, self.p_offset)
    end,
    
    release = function(self,x,avx)
        
        if sw.elapsed -self.hold_time < 100 then
            
            dolater(change_page_to,"product_page")
            
        end
        
        --if get_curr_page() ~= "category_page" then return end
        
        print(avx)
        if math.abs(avx) > 24000 then
            print("high")
            --high speed
            self.func_tbls.high_speed_spin.x = x
            
            if avx > 0 then
                
                self.func_tbls.high_speed_spin.dir =  1
                
            else
                
                self.func_tbls.high_speed_spin.dir = -1
                
            end
            
            animate_list[self.func_tbls.high_speed_spin] = self
            
        elseif math.abs(avx) > 8000 then
            print("low")
            --low speed
            self.func_tbls.low_speed_spin.x = x
            
            if avx > 0 then
                
                self.func_tbls.low_speed_spin.dir =  1
                
            else
                
                self.func_tbls.low_speed_spin.dir = -1
                
            end
            
            animate_list[self.func_tbls.low_speed_spin] = self
            
        else--if avx >800 then
            print("glide")
            --glide to next card
            self.func_tbls.glide_to_next.curr_pos,
            self.func_tbls.glide_to_next.p_range.from = self:translate_x_to_i(x)
            
            self.func_tbls.glide_to_next.p_range.from = self.func_tbls.glide_to_next.p_range.from - self.p_offset
            
            if --[[p > .5 then--]]avx > 0 then
                
                if self.func_tbls.glide_to_next.p_range.from < 0 then
                    self.func_tbls.glide_to_next.p_range.to = 0
                else
                    self.func_tbls.glide_to_next.p_range.to = 1
                end
                
            else
                
                self.func_tbls.glide_to_next.p_range.to = 0
                
            end
            
            self.func_tbls.glide_to_next.duration = math.abs(500*
                        (self.func_tbls.glide_to_next.p_range.to -
                         self.func_tbls.glide_to_next.p_range.from))
            
            animate_list[self.func_tbls.glide_to_next] = self
            
        --else
            
        end
        
    end,
}


local prev_on_motion = {x=nil,y=nil,t=nil}

local vxs = {}
local avx = 0


local t = nil

function umbrella:on_motion(x,y)
    
    if hold then
        
        umbrella:on_motion_x(x,y)
        
        t = sw.elapsed
        
        if prev_on_motion.t ~= nil then
            
            table.insert(vxs,(x - prev_on_motion.x)/((t-prev_on_motion.t)/1000))
            
            if #vxs > 5 then table.remove(vxs,1) end
            
        end
        
        prev_on_motion.x = x
        prev_on_motion.y = y
        prev_on_motion.t = t
        
    end
    
end
function umbrella:on_button_down(x,y)
    
    hold = true
    
    vxs = {}
    
    umbrella:hold(x,y)
    
end

function umbrella:on_button_up(x,y)
    
    hold = false
    
    avx = 0
    
    for _,v in ipairs(vxs) do avx = avx+v; print(avx) end
    
    if #vxs ~= 0 then avx = avx/#vxs end
    
    umbrella:release(x,avx)
    
end
    
function umbrella:on_leave(x,y)
    
    print("meeeee")
    if hold then umbrella:on_button_up(x,y) end
    
end



umbrella.reactive_list = {}

table.insert( umbrella.reactive_list, umbrella  )
table.insert( umbrella.reactive_list, top_button)

function top_button:on_enter()
    
    if get_curr_page() ~= "category_page" then return end
    
    back_sel = true
    
    animate_list[umbrella.func_tbls.fade_out_back_button] = nil
    
    umbrella.func_tbls.fade_in_back_button.focus.from = top_focus.opacity
    
    animate_list[umbrella.func_tbls.fade_in_back_button] = umbrella
    
    return true
end
local tb_hold = false
function top_button:on_leave(x,y)
    
    if get_curr_page() ~= "category_page" then return end
    
    back_sel = false
    
    animate_list[umbrella.func_tbls.fade_in_back_button] = nil
    
    umbrella.func_tbls.fade_out_back_button.focus.from = top_focus.opacity
    
    animate_list[umbrella.func_tbls.fade_out_back_button] = umbrella
    
    if tb_hold then
        
        tb_hold = false
        
        umbrella:on_button_down(x,y)
        
    end
    
    return true
end

function top_button:on_button_down()
    
    tb_hold = true
    
    return true
    
end
function top_button:on_button_up()
    
    if get_curr_page() ~= "category_page" then return end
    
    assert( back_sel == true )
    
    dolater(change_page_to,"front_page")
    
    tb_hold = false
    
    return true
    
end




function umbrella:to_keys()
    
    --if mouse_pos ~= nil then
    --    
    --    bottom_buttons_base[mouse_pos]:launch_fade_out()
    --    
    --end
    
    --bottom_buttons_base[bottom_i]:launch_fade_in()
    
end

function umbrella:to_mouse()
    
    if back_sel then
        top_button:on_leave()
    end
    
end

return umbrella