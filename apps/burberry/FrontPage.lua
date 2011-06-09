--  constant values
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
local TILE_H = 310
local TILE_W = screen_w-RIGHT_PANE_X

--  state variables
local bottom_i = 1
local right_i  = 1
local left_is_playing = false
local right_is_playing = false
local umbrella = Group{}



-- Initiating and place visual elements
local left_panes = Assets:Clone{src="assets/main-2011-image.jpg",  scale={2,2},}

local right_tiles = {
    Assets:Clone{src="assets/tile-main-womens1.png", x=RIGHT_PANE_X,y=TILE_H*0},
    Assets:Clone{src="assets/tile-main-mens1.png"  , x=RIGHT_PANE_X,y=TILE_H*1},
    Assets:Clone{src="assets/tile-main-beauty1.png", x=RIGHT_PANE_X,y=TILE_H*2},
    Assets:Clone{src="assets/tile-main-biker1a.png", x=RIGHT_PANE_X,y=TILE_H*3},
}
local right_blurs = {
    Assets:Clone{src="assets/tile-main-womens2.png", opacity=0, x=RIGHT_PANE_X,y=TILE_H*0},
    Assets:Clone{src="assets/tile-main-mens2.png"  , opacity=0, x=RIGHT_PANE_X,y=TILE_H*1},
    Assets:Clone{src="assets/tile-main-beauty2.png", opacity=0, x=RIGHT_PANE_X,y=TILE_H*2},
    Assets:Clone{src="assets/tile-main-biker1b.png", opacity=0, x=RIGHT_PANE_X,y=TILE_H*3},
}
local right_text = {
    Assets:Clone{src="assets/342x310-text-womens.png", x=RIGHT_PANE_X+TILE_W/2,y=TILE_H*0+TILE_H*3/4},
    Assets:Clone{src="assets/342x310-text-mens.png"  , x=RIGHT_PANE_X+TILE_W/2,y=TILE_H*1+TILE_H*3/4},
    Assets:Clone{src="assets/342x310-text-beauty.png", x=RIGHT_PANE_X+TILE_W/2,y=TILE_H*2+TILE_H*3/4},
    Assets:Clone{src="assets/342x150-text-biker.png",  x=RIGHT_PANE_X+TILE_W/2,y=TILE_H*3+TILE_H*1/4},
}
for i = 1, #right_text do
    right_text[i].anchor_point={
        right_text[i].w/2,
        right_text[i].h/2
    }
end

local title = Assets:Clone{src="assets/main-txt-2011.png",x=TITLE_X,y=TITLE_Y}
local right_focus = Group{x=RIGHT_PANE_X,opacity=0}
local bottom_buttons_base = Assets:Clone{src="assets/btn-playvideo-off.png",opacity=255,x = VIEW_COL_X, y = VIEW_COL_Y,}
local bottom_buttons_foci = Assets:Clone{src="assets/btn-playvideo-on.png",x = VIEW_COL_X, y = VIEW_COL_Y,}

local overlay = Rectangle{
    w=screen_w-RIGHT_PANE_X,
    x=RIGHT_PANE_X,
    h=screen_h,
    opacity=255*.5,
    color="000000"
}

-- Creates the Right Focus
do
    local tl_corner = Assets:Clone{src=imgs.box_foc_corner,x=-2,y=-2}
    local top  = Assets:Clone{
        src=imgs.box_foc_side,
        x=tl_corner.w-2,
        y=-2,
        w=screen_w-RIGHT_PANE_X-2*tl_corner.w+4,
        tiles
    }
    local tr_corner = Assets:Clone{
        src=imgs.box_foc_corner,
        z_rotation={90,0,0},
        x=screen_w-RIGHT_PANE_X+2,
        y=-2
    }
    local left = Assets:Clone{
        src=imgs.box_foc_side,
        z_rotation={-90,0,0},
        w=TILE_H-2*tl_corner.w+4,
        y=TILE_H-tl_corner.w+2,
        x=-2,
        tiles
    }
    local right = Assets:Clone{
        src=imgs.box_foc_side,
        z_rotation={90,0,0},
        w=TILE_H-2*tl_corner.w+4,
        x=screen_w-RIGHT_PANE_X+2,
        y=tl_corner.w-2,
        tiles
    }
    local btm  = Assets:Clone{
        src=imgs.box_foc_side,
        z_rotation={180,0,0},
        x=screen_w-RIGHT_PANE_X-tl_corner.w+2,
        y=TILE_H+2,
        w=screen_w-RIGHT_PANE_X-2*tl_corner.w+4,
        tiles
    }
    local bl_corner = Assets:Clone{
        src=imgs.box_foc_corner,
        z_rotation={-90,0,0},
        y=TILE_H+2,
        x=-2
    }
    local br_corner = Assets:Clone{
        src=imgs.box_foc_corner,
        z_rotation={180,0,0},
        y=TILE_H+2,
        x=screen_w-RIGHT_PANE_X+2
    }
    right_focus:add(tl_corner,top,tr_corner,left,right,btm,bl_corner,br_corner)
end
umbrella:add(left_panes,title_s,title,sub_title)
umbrella:add(unpack(right_blurs))
umbrella:add(unpack(right_tiles))
umbrella:add(unpack(right_text))
umbrella:add(bottom_buttons_base,bottom_buttons_foci,right_focus,overlay,title)

umbrella.func_tbls = {
        fade_in_from = {
            ["collection_page"] = {
                duration = 300,
                func = function(this_obj,this_func_tbl,secs,p)
                    this_obj.group.opacity=255*p
                end
            },
            ["category_page"] = {
                duration = 300,
                func = function(this_obj,this_func_tbl,secs,p)
                    if p == 1 then
                        restore_keys()
                    end
                end
            }
        },
        fade_out_to = {
            ["collection_page"] = {
                duration = 300,
                func = function(this_obj,this_func_tbl,secs,p)
                    this_obj.group.opacity=255*(1-p)
                end
            },
            ["category_page"] = {
                duration = 300,
                func = function(this_obj,this_func_tbl,secs,p)
                    if p==1 then
                        if right_is_playing then
                            mediaplayer:pause()
                        end
                        right_is_playing = false
                        right_blurs[right_i].opacity=0
                        right_tiles[right_i].opacity=255
                    end
                end
            }
        },
        focus_out_button = {
            index = 1,
            duration = 300,
            focus = Interval(255,0),
            func = function(this_obj,this_func_tbl,secs,p)
                bottom_buttons_foci.opacity=this_func_tbl.focus:get_value(p)
            end
        },
        focus_in_button = {
            index = 1,
            duration = 300,
            --base  = Interval(255,255*.4),
            focus = Interval(0,255),
            func = function(this_obj,this_func_tbl,secs,p)
               -- bottom_buttons_base.opacity=255*(.4+.6*(p))
                bottom_buttons_foci.opacity=this_func_tbl.focus:get_value(p)
                if p == 1 then
                    restore_keys()
                end
            end,
        },
        
        focus_out_tile = {
            index = 1,
            duration = 300,
            focus = Interval(255,0),
            func = function(this_obj,this_func_tbl,secs,p)
                bottom_buttons_foci.opacity=this_func_tbl.focus:get_value(p)
            end
        },
        
        focus_in_tile = {
            index = 1,
            duration = 300,
            --base  = Interval(255,255*.4),
            focus = Interval(0,255),
            func = function(this_obj,this_func_tbl,secs,p)
               -- bottom_buttons_base.opacity=255*(.4+.6*(p))
                bottom_buttons_foci.opacity=this_func_tbl.focus:get_value(p)
                if p == 1 then
                    restore_keys()
                end
            end,
        },
        
        
        move_to_tile  = {
            curr_tile = 1,
            duration  = 300,
            focus = Interval(0,255),
            func = function(this_obj,this_func_tbl,secs,p)
                right_tiles[this_func_tbl.curr_tile].opacity=this_func_tbl.focus:get_value(p)
                right_focus.opacity=255-this_func_tbl.focus:get_value(p)
                if not right_is_playing then
                    right_blurs[this_func_tbl.curr_tile].opacity=255-this_func_tbl.focus:get_value(p)
                end
                if p == 1 then
                    right_focus.y = TILE_H*(this_func_tbl.next_tile-1)
                    mediaplayer:seek(0)
                    mediaplayer:play()
                    right_is_playing = true
                    
                    this_obj.func_tbls.play_next_tile.next_tile = this_func_tbl.next_tile
                    animate_list[this_obj.func_tbls.play_next_tile] = this_obj
                end
            end
        },
        play_next_tile = {
            next_tile = 2,
            duration  = 300,
            --delay = 350,
            focus = Interval(0,255),
            func = function(this_obj,this_func_tbl,secs,p)
                right_tiles[this_func_tbl.next_tile].opacity=255-this_func_tbl.focus:get_value(p)
                right_focus.opacity=this_func_tbl.focus:get_value(p)
                if p == 1 then
                    restore_keys()
                end
            end
        },
        fade_in_blur = {
            next_tile = 2,
            duration  = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                right_blurs[this_func_tbl.next_tile].opacity=255*(p)
            end
        },
        focus_tile_from_buttons = {
            index = 1,
            duration  = 300,
            int = Interval(0,255),
            func = function(this_obj,this_func_tbl,secs,p)
                --bottom_buttons_base[3].opacity=255*(.4+.6*(1-p))
                --bottom_buttons_foci[3].opacity=255*(1-p)
                bottom_buttons_base.opacity = 255 *    p--255*(.4+.6*(1-p))
                bottom_buttons_foci.opacity = 255 * (1-p)--255*(1-p)
                if left_is_playing then
                    left_panes.opacity=255*p
                end
                --right_tiles[this_func_tbl.index].opacity=255*(1-p)
                --right_focus.opacity=255*p
                overlay.opacity=255*.5*(1-p)
                if p == 1 then
                    --mediaplayer:load()
                    left_is_playing=false
                    --this_obj.func_tbls.play_next_tile.next_tile = right_i
                    --restore_keys()
                end
            end
        },
        fade_buttons_from_tile = {
            duration = 300,
            int = Interval(0,255),
            func = function(this_obj,this_func_tbl,secs,p)
                right_tiles[right_i].opacity=255*p
                --bottom_buttons_base[3].opacity=255*(.3+.7*(p))
                --bottom_buttons_foci[3].opacity=255*(p)
                bottom_buttons_base.opacity=255*(1-p)--255*(.3+.7*(p))
                bottom_buttons_foci.opacity=255*p--255*(p)
                
                right_focus.opacity=255*(1-p)
                overlay.opacity=255*.5*p
                if p == 1 then
                    --mediaplayer:load()
                    this_obj.func_tbls.focus_in_button.index = 3
                    restore_keys()
                    
                end
            end
        },
        fade_out_overlay= {
            duration = 300,
            int = Interval(255*.5,0),
            func = function(this_obj,f_t,secs,p)
                overlay.opacity=f_t.int:get_value(p)
            end
        },
        fade_in_overlay= {
            duration = 300,
            ovly = Interval(0,255*.5),
            tile = Interval(0,255),
            func = function(this_obj,f_t,secs,p)
                overlay.opacity=f_t.ovly:get_value(p)
                right_tiles[right_i].opacity=f_t.tile:get_value(p)
                right_focus.opacity = 255-f_t.tile:get_value(p)
            end
        },
        slide_main_pane_right = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                left_panes.x=left_panes.w*2*p
                left_panes.opacity=255*(.5+.5*(1-p))
                if p == 1 then
                    left_panes[this_func_tbl.index].opacity=255
                end
            end,
        },
        slide_new_pane_right = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                left_panes.x=-left_panes.w*2*(1-p)
                if p == 1 then
                    restore_keys()
                end
            end,
        },
        slide_main_pane_left = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                left_panes.x=-left_panes.w*2*p
                left_panes.opacity=255*(.6+.4*(1-p))
                if p == 1 then
                    left_panes.opacity=255
                end
            end,
        },
        slide_new_pane_left = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                left_panes.x=left_panes.w*2*(1-p)
                if p == 1 then
                    restore_keys()
                end
            end,
        },
        fade_in_left_pane = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                left_panes.opacity=255*p
            end,
        },
        fade_out_left_pane = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                left_panes.opacity=255*(1-p)
            end,
        },
    }
umbrella.keys = {
        [keys.Up] = function(self)
            if bottom_i ~= 2 or right_i == 1 then return end
            --if bottom_i ~= 4 or right_i == 1 then return end
            lose_keys()
            self.func_tbls.move_to_tile.curr_tile         = right_i
            self.func_tbls.move_to_tile.next_tile         = right_i - 1
            self.func_tbls.play_next_tile.next_tile       = right_i - 1
            animate_list[ self.func_tbls.move_to_tile   ] = self
            animate_list[ self.func_tbls.play_next_tile ] = self
            right_i = right_i - 1
            
        end,
        [keys.Down] = function(self)
            if bottom_i ~= 2 or right_i == 4 then return end
            --if bottom_i ~= 4 or right_i == 4 then return end
            lose_keys()
            self.func_tbls.move_to_tile.curr_tile         = right_i
            self.func_tbls.move_to_tile.next_tile         = right_i + 1
            self.func_tbls.play_next_tile.next_tile       = right_i + 1
            animate_list[ self.func_tbls.move_to_tile   ] = self
            animate_list[ self.func_tbls.play_next_tile ] = self
            
            right_i = right_i + 1
        end,
        [keys.Left] = function(self)
            if bottom_i == 1 then return end
            lose_keys()
            --if bottom_i == 4 then
                
            animate_list[self.func_tbls.fade_buttons_from_tile] = self
            bottom_i = bottom_i - 1
        end,
        [keys.Right] = function(self)
            if bottom_i == 2 then return end
            --if bottom_i == 4 then return end
            lose_keys()
            mediaplayer:seek(0)
            mediaplayer:play()
            right_is_playing = true
            --if bottom_i == 3 then
                
            self.func_tbls.focus_tile_from_buttons.index = right_i
            self.func_tbls.play_next_tile.next_tile = right_i
            animate_list[self.func_tbls.focus_tile_from_buttons] = self
            animate_list[self.func_tbls.play_next_tile] = self
            bottom_i = bottom_i + 1
        end,
        [keys.OK] = function(self)
            
            if bottom_i == 1 then
                if not left_is_playing then
                    
                    animate_list[self.func_tbls.fade_out_left_pane] = self
                    mediaplayer:seek(0)
                    mediaplayer:play()
                else
                    animate_list[self.func_tbls.fade_in_left_pane] = self
                end
                
                left_is_playing = not left_is_playing
            elseif bottom_i == 2 then --4 then
                lose_keys()
                change_page_to("category_page")
            end
        end,
    }
    
left_panes.reactive = true
function left_panes:on_enter()
    
    animate_list[umbrella.func_tbls.fade_out_overlay] = nil
    
    umbrella.func_tbls.fade_in_overlay.ovly.from       = overlay.opacity
    
    umbrella.func_tbls.fade_in_overlay.tile.from       = right_tiles[right_i].opacity
    
    animate_list[umbrella.func_tbls.fade_in_overlay]  = umbrella
    
end
function left_panes:on_leave()
    
    animate_list[umbrella.func_tbls.fade_in_overlay]  = nil
    
    umbrella.func_tbls.fade_out_overlay.int.from      = overlay.opacity
    
    animate_list[umbrella.func_tbls.fade_out_overlay] = umbrella
    
end

local function tile_on_enter(i)
    
    if get_curr_page() ~= "front_page" then return end
    
    bottom_i = 2
    
    --if the animation is not still in the fading out phase
    if not animate_list[umbrella.func_tbls.move_to_tile] then
        
        --if the animation is in the fading in phase, then cancel it
        if animate_list[umbrella.func_tbls.play_next_tile] then
            
            animate_list[umbrella.func_tbls.play_next_tile] = nil
            
        end
        
        --fade out the tile currently being faded in (or that was last faded in)
        umbrella.func_tbls.move_to_tile.curr_tile = umbrella.func_tbls.play_next_tile.next_tile
        
        --fade out from its current opacity
        umbrella.func_tbls.move_to_tile.focus.from = right_tiles[right_i].opacity
        
        --begin fade out
        animate_list[umbrella.func_tbls.move_to_tile] = umbrella
        
    end
    
    --update the next tile to be itself
    umbrella.func_tbls.play_next_tile.next_tile = i
    
    umbrella.func_tbls.move_to_tile.next_tile   = i
    
    right_i = i
    
end
local function tile_on_leave(i)
    
    if get_curr_page() ~= "front_page" then return end
    
    
end
for i,t in ipairs(right_tiles) do
    
    t.reactive = true
    print(i,t)
    function t:on_enter()
        
        if get_curr_page() ~= "front_page" then return end
        
        tile_on_enter(i)
        
    end
    
    function t:on_leave()
        
        if get_curr_page() ~= "front_page" then return end
        
        tile_on_leave(i)
        
    end
    
    function t:on_button_down()
        
        if get_curr_page() ~= "front_page" then return end
        
        assert( bottom_i == 2 )
        
        umbrella.keys[keys.OK](umbrella)
        
    end
end

bottom_buttons_base.reactive = true

function bottom_buttons_base:on_enter()
    
    bottom_i = 1
    
    animate_list[umbrella.func_tbls.focus_out_button] = nil
    
    umbrella.func_tbls.focus_in_button.focus.from = bottom_buttons_foci.opacity
    
    animate_list[umbrella.func_tbls.focus_in_button] = umbrella
    
end

function bottom_buttons_base:on_leave()
    
    bottom_i = 0
    
    animate_list[umbrella.func_tbls.focus_in_button] = nil
    
    umbrella.func_tbls.focus_out_button.focus.from = bottom_buttons_foci.opacity
    
    animate_list[umbrella.func_tbls.focus_out_button] = umbrella

end

function bottom_buttons_base:on_button_down()
    
    assert( bottom_i == 1 )
    
    umbrella.keys[keys.OK](umbrella)
    
end

mediaplayer.on_end_of_stream = function()
    if left_is_playing then
        print("l")
        left_is_playing = false
        animate_list[front_page.func_tbls.fade_in_left_pane] = front_page
    elseif right_is_playing and bottom_i == 2 then
        print("r")
        front_page.func_tbls.fade_in_blur.next_tile=right_i
        animate_list[front_page.func_tbls.fade_in_blur] = front_page
        right_is_playing=false
    end
    print("end")
end
mediaplayer:load("videos/Burberry 1080p.mp4")

return umbrella