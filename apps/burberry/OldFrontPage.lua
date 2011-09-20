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

local bottom_i = 1
local right_i  = 1
local left_is_playing = false
local right_is_playing = false
local umbrella = Group{}



--local left_img = Image{src="assets/main-2011-image.png"}
local left_i = 1
local left_panes = {
    Assets:Clone{src="assets/main-2011-image.jpg",  scale={2,2},},--[[
    Assets:Clone{src="assets/main-beauty-image.jpg",scale={2,2},x=screen_w},
    Assets:Clone{src="assets/main-biker-image.jpg", scale={2,2},x=screen_w},
    Assets:Clone{src="assets/main-mens-image.jpg",  scale={2,2},x=screen_w},
    Assets:Clone{src="assets/main-womens-image.jpg",scale={2,2},x=screen_w},--]]
}
local left_videos = {
    "videos/front_page_left_pane/1.mp4",
    "videos/front_page_left_pane/2.mp4",
    nil,
    nil,
    "videos/front_page_left_pane/5.mp4",
}
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
    right_text[i].anchor_point={right_text[i].w/2,right_text[i].h/2}
end
local right_videos = {
    "videos/front_page_right_col/1.mp4",
    "videos/front_page_right_col/2.mp4",
    "videos/front_page_right_col/3.mp4",
    "videos/front_page_right_col/4.mp4",
}
local title = Assets:Clone{src="assets/main-txt-2011.png",x=TITLE_X,y=TITLE_Y}
local right_focus = Group{x=RIGHT_PANE_X,opacity=0}
local bottom_buttons_base = {
--[[
    Group{
        x = PRIOR_X,
        y = PRIOR_Y,
        --opacity = 255*.3,
    },
    --]]
    --[[
    Group{
        x = VIEW_COL_X,
        y = VIEW_COL_Y,
        --opacity = 255*.4,
    },
    --]]
    Assets:Clone{src="assets/btn-playvideo-off.png",opacity=0,x = VIEW_COL_X, y = VIEW_COL_Y,},
    --[[
    Group{
        x = NEXT_X,
        y = NEXT_Y,
        opacity = 255*.4,
    },
    --]]
}
local bottom_buttons_foci = {
    --[[
    Group{
        x = PRIOR_X-10,
        y = PRIOR_Y-11,
        --opacity = 0,
    },
    --]]--[[
    Group{
        x = VIEW_COL_X-10,
        y = VIEW_COL_Y-11,
        --opacity = 0,
    },--]]
    Assets:Clone{src="assets/btn-playvideo-on.png",x = VIEW_COL_X, y = VIEW_COL_Y,},
    --[[
    Group{
        x = NEXT_X-10,
        y = NEXT_Y-11,
        opacity = 0,
    },
    --]]
}
local overlay = Rectangle{
    w=screen_w-RIGHT_PANE_X,
    x=RIGHT_PANE_X,
    h=screen_h,
    opacity=255*.5,
    color="000000"
}
---[[

--]]
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
    --[[
    local arrow = Clone{source=imgs.fp.arrow, y_rotation={180,0,0}}
    local rect = Rectangle{w=204,h=55,color="000000"}
    local text = Text{
        font="Engravers MT "..SUB_TITLE_SZ.."px",
        text="PRIOR",
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
    --]]
    --[[
    arrow = Clone{source=imgs.fp.arrow}
    
    rect = Rectangle{w=304,h=55,color="000000"}
    text = Text{
        font="Engravers MT "..SUB_TITLE_SZ.."px",
        text="PLAY VIDEO",
        position={rect.w/2+(arrow.w+22)/2,rect.h/2},
        color="ffffff",
    }
    text.anchor_point={text.w/2,text.h/2}
    arrow.anchor_point={0,arrow.h/2}
    arrow.y=rect.h/2
    arrow.x=text.x-text.w/2-(2*arrow.w+22)/2
    
    bottom_buttons_base[1]:add(rect,arrow,text)
    
    bottom_buttons_foci[1]:add(
        Clone{source=imgs.fp.foc_end},
        Clone{source=imgs.fp.foc_mid,x=26,w=272,tiles},
        Clone{source=imgs.fp.foc_end,x=26*2+272,y_rotation={180,0,0}}
    )
    --]]
    --[[
    arrow = Clone{source=imgs.fp.arrow}
    rect = Rectangle{w=181,h=55,color="000000"}
    text = Text{
        font="Engravers MT "..SUB_TITLE_SZ.."px",
        text="NEXT",
        position={rect.w/2-(2*arrow.w+22)/2,rect.h/2},
        color="ffffff",
    }
    text.anchor_point={text.w/2,text.h/2}
    arrow.anchor_point={0,arrow.h/2}
    arrow.y=rect.h/2
    arrow.x=text.x+text.w/2+(2*arrow.w+22)/2
    
    bottom_buttons_base[3]:add(rect,text,arrow)
    
    bottom_buttons_foci[3]:add(
        Clone{source=imgs.fp.foc_end},
        Clone{source=imgs.fp.foc_mid,x=26,w=149,tiles},
        Clone{source=imgs.fp.foc_end,x=26*2+149,y_rotation={180,0,0}}
    )
    --]]
end
umbrella:add(unpack(left_panes))
umbrella:add(title_s,title,sub_title)
umbrella:add(unpack(right_tiles))
umbrella:add(unpack(right_blurs))
umbrella:add(unpack(right_text))
umbrella:add(unpack(bottom_buttons_base))
umbrella:add(unpack(bottom_buttons_foci))
umbrella:add(right_focus,overlay,title)
front_page = {
    group = umbrella,
    func_tbls = {
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
                    --this_obj.group.opacity=255*p
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
                    --this_obj.group.opacity=255*(1-p)
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
            func = function(this_obj,this_func_tbl,secs,p)
                
                bottom_buttons_base[this_func_tbl.index].opacity=255*(.4+.6*(1-p))
                bottom_buttons_foci[this_func_tbl.index].opacity=255*(1-p)
            end
        },
        focus_in_button = {
            index = 1,
            duration = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                bottom_buttons_base[this_func_tbl.index].opacity=255*(.4+.6*(p))
                bottom_buttons_foci[this_func_tbl.index].opacity=255*(p)
                if p == 1 then
                    restore_keys()
                end
            end
        },
        move_to_tile  = {
            --next_tile = 2,
            curr_tile = 1,
            duration  = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                right_tiles[this_func_tbl.curr_tile].opacity=255*p
                --right_focus.y=TILE_H*(this_func_tbl.curr_tile-1) +(this_func_tbl.next_tile-this_func_tbl.curr_tile)*TILE_H*p
                right_focus.opacity=255*(1-p)
                if not right_is_playing then
                    right_blurs[this_func_tbl.curr_tile].opacity=255*(1-p)
                end
                if p == 1 then
                    --mediaplayer:load()
                    right_focus.y = TILE_H*(this_func_tbl.next_tile-1)
                    --this_obj.func_tbls.play_next_tile.next_tile = this_func_tbl.next_tile
                    mediaplayer:seek(0)
                    mediaplayer:play()
                    right_is_playing = true
                    --[[
                    mediaplayer.on_loaded = function()
                        mediaplayer:set_viewport_geometry(
                            RIGHT_PANE_X*screen.scale[1],
                            TILE_H*(this_func_tbl.next_tile-1)*screen.scale[2],
                            TILE_W*screen.scale[1],
                            TILE_H*screen.scale[2]
                        )
                        mediaplayer:play()
                        --]]
                        --animate_list[this_obj.func_tbls.play_next_tile] = this_obj
                        --[[
                        print(mediaplayer.state)
                    end
                    mediaplayer.on_end_of_stream = function()
                        --animate_list[self.func_tbls.fade_in_left_pane] = self
                    end
                    mediaplayer:load(right_videos[this_func_tbl.next_tile])
                    --]]
                end
            end
        },
        play_next_tile = {
            next_tile = 2,
            duration  = 300,
            delay = 350,
            func = function(this_obj,this_func_tbl,secs,p)
                right_tiles[this_func_tbl.next_tile].opacity=255*(1-p)
                right_focus.opacity=255*p
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
            func = function(this_obj,this_func_tbl,secs,p)
                --bottom_buttons_base[3].opacity=255*(.4+.6*(1-p))
                --bottom_buttons_foci[3].opacity=255*(1-p)
                bottom_buttons_base[1].opacity = 255 *    p--255*(.4+.6*(1-p))
                bottom_buttons_foci[1].opacity = 255 * (1-p)--255*(1-p)
                if left_is_playing then
                    left_panes[left_i].opacity=255*p
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
            func = function(this_obj,this_func_tbl,secs,p)
                right_tiles[right_i].opacity=255*p
                --bottom_buttons_base[3].opacity=255*(.3+.7*(p))
                --bottom_buttons_foci[3].opacity=255*(p)
                bottom_buttons_base[1].opacity=255*(1-p)--255*(.3+.7*(p))
                bottom_buttons_foci[1].opacity=255*p--255*(p)
                
                right_focus.opacity=255*(1-p)
                overlay.opacity=255*.5*p
                if p == 1 then
                    --mediaplayer:load()
                    this_obj.func_tbls.focus_in_button.index = 3
                    restore_keys()
                    
                end
            end
        },
        slide_main_pane_right = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                left_panes[this_func_tbl.index].x=left_panes[this_func_tbl.index].w*2*p
                left_panes[this_func_tbl.index].opacity=255*(.5+.5*(1-p))
                if p == 1 then
                    left_panes[this_func_tbl.index].opacity=255
                end
            end,
        },
        slide_new_pane_right = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                left_panes[this_func_tbl.index].x=-left_panes[this_func_tbl.index].w*2*(1-p)
                if p == 1 then
                    restore_keys()
                end
            end,
        },
        slide_main_pane_left = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                left_panes[this_func_tbl.index].x=-left_panes[this_func_tbl.index].w*2*p
                left_panes[this_func_tbl.index].opacity=255*(.6+.4*(1-p))
                if p == 1 then
                    left_panes[this_func_tbl.index].opacity=255
                end
            end,
        },
        slide_new_pane_left = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                left_panes[this_func_tbl.index].x=left_panes[this_func_tbl.index].w*2*(1-p)
                if p == 1 then
                    restore_keys()
                end
            end,
        },
        fade_in_left_pane = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                left_panes[left_i].opacity=255*p
            end,
        },
        fade_out_left_pane = {
            duration = 500,
            func = function(this_obj,this_func_tbl,secs,p)
                left_panes[left_i].opacity=255*(1-p)
            end,
        },
    },
    keys = {
        [keys.Up] = function(self)
            if bottom_i ~= 2 or right_i == 1 then return end
            --if bottom_i ~= 4 or right_i == 1 then return end
            lose_keys()
            self.func_tbls.move_to_tile.curr_tile = right_i
            self.func_tbls.play_next_tile.next_tile = right_i - 1
            animate_list[self.func_tbls.move_to_tile] = self
            animate_list[self.func_tbls.play_next_tile] = self
            right_i = right_i - 1
            
        end,
        [keys.Down] = function(self)
            if bottom_i ~= 2 or right_i == 4 then return end
            --if bottom_i ~= 4 or right_i == 4 then return end
            lose_keys()
            self.func_tbls.move_to_tile.curr_tile = right_i
            self.func_tbls.play_next_tile.next_tile = right_i + 1
            animate_list[self.func_tbls.move_to_tile] = self
            animate_list[self.func_tbls.play_next_tile] = self
            
            right_i = right_i + 1
        end,
        [keys.Left] = function(self)
            if bottom_i == 1 then return end
            lose_keys()
            --if bottom_i == 4 then
                
            animate_list[self.func_tbls.fade_buttons_from_tile] = self
                
                --[[
            else
                
                self.func_tbls.focus_out_button.index = bottom_i
                animate_list[self.func_tbls.focus_out_button] = self
                
                self.func_tbls.focus_in_button.index = bottom_i-1
                animate_list[self.func_tbls.focus_in_button] = self
                
            end--]]
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
            animate_list[self.func_tbls.focus_tile_from_buttons] = self
                --[[
            else
                
                self.func_tbls.focus_out_button.index = bottom_i
                animate_list[self.func_tbls.focus_out_button] = self
                
                self.func_tbls.focus_in_button.index = bottom_i+1
                animate_list[self.func_tbls.focus_in_button] = self
                
            end-]]
            bottom_i = bottom_i + 1
        end,
        [keys.OK] = function(self)
            
            if bottom_i == 1 then
                --[[
                lose_keys()
                if mediaplayer.state ~= "PLAYING" then
                    self.func_tbls.slide_main_pane_right.index=left_i
                    animate_list[self.func_tbls.slide_main_pane_right] = self
                end
                left_i = (left_i-2)%#left_panes+1
                self.func_tbls.slide_new_pane_right.index=left_i
                animate_list[self.func_tbls.slide_new_pane_right] = self
                --]]
                if not left_is_playing then
                    
                    animate_list[self.func_tbls.fade_out_left_pane] = self
                    mediaplayer:seek(0)
                    mediaplayer:play()
                else
                    animate_list[self.func_tbls.fade_in_left_pane] = self
                end
                
                left_is_playing = not left_is_playing
            --[[
            elseif bottom_i == 2 then
                
                if mediaplayer.state == mediaplayer.PLAYING then return end
                
                mediaplayer.on_loaded = function()
                    mediaplayer:set_viewport_geometry(0,0,screen_w*screen.scale[1],screen_h*screen.scale[2])
                    mediaplayer:play()
                    animate_list[self.func_tbls.fade_out_left_pane] = self
                    print(mediaplayer.state)
                end
                mediaplayer.on_end_of_stream = function()
                    animate_list[self.func_tbls.fade_in_left_pane] = self
                end
                mediaplayer:load(left_videos[left_i])
                
                
                
            elseif bottom_i == 3 then
                lose_keys()
                
                if mediaplayer.state ~= mediaplayer.PLAYING then
                    self.func_tbls.slide_main_pane_left.index=left_i
                    animate_list[self.func_tbls.slide_main_pane_left] = self
                end
                left_i = (left_i)%#left_panes+1
                self.func_tbls.slide_new_pane_left.index=left_i
                animate_list[self.func_tbls.slide_new_pane_left] = self
            --]]
            elseif bottom_i == 2 then --4 then
                lose_keys()
                change_page_to("category_page")
            end
        end,
    }
}
--[[
overlay.reactive = true

function overlay:on_enter()
    
    if get_curr_page() == "front_page" then
        
        if mouse_manager.busy then
            
            if mouse_manager.on_enters[front_page.keys[keys.Left] ] then
                
                mouse_manager.on_enters[front_page.keys[keys.Left] ] = nil
                
            else
                
                mouse_manager.on_enters[front_page.keys[keys.Right] ] = front_page
                
            end
            
        else
            
            front_page.keys[keys.Right](front_page)
            
        end
        
    end
    
end
function overlay:on_leave()
    
    if get_curr_page() == "front_page" then
        
        if mouse_manager.busy then
            
            if mouse_manager.on_enters[front_page.keys[keys.Right] ] then
                
                mouse_manager.on_enters[front_page.keys[keys.Right] ] = nil
                
            else
                
                mouse_manager.on_enters[front_page.keys[keys.Left] ] = front_page
                
            end
            
        else
            
            front_page.keys[keys.Left](front_page)
            
        end
        
    end
    
end
--]]
--[[
function overlay:on_button_down()
    if get_curr_page() == "front_page" then
        print("ol")
    end
end
--]]
local function tile_on_enter(self,i)
    
    if get_curr_page() ~= "front_page" then return end
    
    lose_keys()
    
    mediaplayer:seek(0)
    
    mediaplayer:play()
    
    right_is_playing = true
    
    self.func_tbls.play_next_tile.next_tile = i
    
    right_i = i
    
    animate_list[self.func_tbls.play_next_tile] = self
    
end
local function tile_on_leave(self,i)
    
    if get_curr_page() ~= "front_page" then return end
    
    self.func_tbls.move_to_tile.curr_tile = right_i
    
    animate_list[self.func_tbls.move_to_tile] = self
    
end
for i,t in ipairs(right_tiles) do
    
    t.reactive = true
    print(i,t)
    function t:on_enter()
        print("ffff")
        if get_curr_page() ~= "front_page" then return end
        
        if mouse_manager.busy then
            
            mouse_manager.on_enters[tile_on_enter] = i
            
        else
            
            tile_on_enter(i)
            
        end
        
    end
    
    function t:on_leave()
        print("dddd")
        if get_curr_page() ~= "front_page" then return end
        
        if mouse_manager.busy then
            
            mouse_manager.on_enters[tile_on_leave] = i
            
        else
            
            tile_on_leave(i)
            
        end
        
    end
    
end

mediaplayer.on_end_of_stream = function()
    if left_is_playing then
        left_is_playing = false
        animate_list[front_page.func_tbls.fade_in_left_pane] = front_page
    elseif right_is_playing and bottom_i == 2 then
        front_page.func_tbls.fade_in_blur.next_tile=right_i
        animate_list[front_page.func_tbls.fade_in_blur] = front_page
        right_is_playing=false
    end
end
mediaplayer:load("videos/Burberry 1080p.mp4")