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

local umbrella = Group{}

--local left_img = Image{src="assets/main-2011-image.png"}
local left_i = 1
local left_panes = {
    Image{src="assets/main-2011-image.jpg",  scale={2,2},},
    Image{src="assets/main-beauty-image.jpg",scale={2,2},x=screen_w},
    Image{src="assets/main-biker-image.jpg", scale={2,2},x=screen_w},
    Image{src="assets/main-mens-image.jpg",  scale={2,2},x=screen_w},
    Image{src="assets/main-womens-image.jpg",scale={2,2},x=screen_w},
}
local left_videos = {
    "videos/front_page_left_pane/1.mp4",
    "videos/front_page_left_pane/2.mp4",
    nil,
    nil,
    "videos/front_page_left_pane/5.mp4",
}
local right_tiles = {
    Image{src="assets/tile-main-womens1.png" , x=RIGHT_PANE_X,y=TILE_H*0},
    Image{src="assets/tile-main-mens1.png"  , x=RIGHT_PANE_X,y=TILE_H*1},
    Image{src="assets/tile-main-beauty1.png", x=RIGHT_PANE_X,y=TILE_H*2},
    Image{src="assets/tile-main-biker1a.png", x=RIGHT_PANE_X,y=TILE_H*3},
}
local right_videos = {
    "videos/front_page_right_col/1.mp4",
    "videos/front_page_right_col/2.mp4",
    "videos/front_page_right_col/3.mp4",
    "videos/front_page_right_col/4.mp4",
}
local right_focus = Group{x=RIGHT_PANE_X,opacity=0}
local bottom_buttons_base = {
    Group{
        x = PRIOR_X,
        y = PRIOR_Y,
        --opacity = 255*.3,
    },
    Group{
        x = VIEW_COL_X,
        y = VIEW_COL_Y,
        opacity = 255*.4,
    },
    Group{
        x = NEXT_X,
        y = NEXT_Y,
        opacity = 255*.4,
    },
}
local bottom_buttons_foci = {
    Group{
        x = PRIOR_X-10,
        y = PRIOR_Y-11,
        --opacity = 0,
    },
    Group{
        x = VIEW_COL_X-10,
        y = VIEW_COL_Y-11,
        opacity = 0,
    },
    Group{
        x = NEXT_X-10,
        y = NEXT_Y-11,
        opacity = 0,
    },
}
local overlay = Rectangle{
    w=screen_w-RIGHT_PANE_X,
    x=RIGHT_PANE_X,
    h=screen_h,
    opacity=255*.5,
    color="000000"
}
do
    
    local tl_corner = Clone{source=imgs.box_foc_corner}
    local top  = Clone{
        source=imgs.box_foc_side,
        x=tl_corner.w,w=screen_w-RIGHT_PANE_X-2*tl_corner.w,
        tiles
    }
    local tr_corner = Clone{
        source=imgs.box_foc_corner,
        z_rotation={90,0,0},
        x=screen_w-RIGHT_PANE_X
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
        x=screen_w-RIGHT_PANE_X,
        y=tl_corner.w,
        tiles
    }
    local btm  = Clone{
        source=imgs.box_foc_side,
        z_rotation={180,0,0},
        x=screen_w-RIGHT_PANE_X-tl_corner.w,
        y=TILE_H,
        w=screen_w-RIGHT_PANE_X-2*tl_corner.w,
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
        x=screen_w-RIGHT_PANE_X
    }
    right_focus:add(tl_corner,top,tr_corner,left,right,btm,bl_corner,br_corner)
    
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
    
    bottom_buttons_base[2]:add(rect,arrow,text)
    
    bottom_buttons_foci[2]:add(
        Clone{source=imgs.fp.foc_end},
        Clone{source=imgs.fp.foc_mid,x=26,w=272,tiles},
        Clone{source=imgs.fp.foc_end,x=26*2+272,y_rotation={180,0,0}}
    )
    
    
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
end
umbrella:add(unpack(left_panes))
umbrella:add(title_s,title,sub_title)
umbrella:add(unpack(right_tiles))
umbrella:add(unpack(bottom_buttons_base))
umbrella:add(unpack(bottom_buttons_foci))
umbrella:add(right_focus,overlay)
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
                    this_obj.group.opacity=255*p
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
                    this_obj.group.opacity=255*(1-p)
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
            next_tile = 2,
            curr_tile = 1,
            duration  = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                right_tiles[this_func_tbl.curr_tile].opacity=255*p
                --right_focus.y=TILE_H*(this_func_tbl.curr_tile-1) +(this_func_tbl.next_tile-this_func_tbl.curr_tile)*TILE_H*p
                right_focus.opacity=255*(1-p)
                if p == 1 then
                    --mediaplayer:load()
                    right_focus.y = TILE_H*(this_func_tbl.next_tile-1)
                    this_obj.func_tbls.play_next_tile.next_tile = this_func_tbl.next_tile
                    
                    
                    mediaplayer.on_loaded = function()
                        mediaplayer:set_viewport_geometry(
                            RIGHT_PANE_X*screen.scale[1],
                            TILE_H*(this_func_tbl.next_tile-1)*screen.scale[2],
                            TILE_W*screen.scale[1],
                            TILE_H*screen.scale[2]
                        )
                        mediaplayer:play()
                        animate_list[this_obj.func_tbls.play_next_tile] = this_obj
                        print(mediaplayer.state)
                    end
                    mediaplayer.on_end_of_stream = function()
                        --animate_list[self.func_tbls.fade_in_left_pane] = self
                    end
                    mediaplayer:load(right_videos[this_func_tbl.next_tile])
                end
            end
        },
        play_next_tile = {
            next_tile = 2,
            duration  = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                right_tiles[this_func_tbl.next_tile].opacity=255*(1-p)
                right_focus.opacity=255*p
                if p == 1 then
                    restore_keys()
                end
            end
        },
        focus_tile_from_buttons = {
            index = 1,
            duration  = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                bottom_buttons_base[3].opacity=255*(.4+.6*(1-p))
                bottom_buttons_foci[3].opacity=255*(1-p)
                right_tiles[this_func_tbl.index].opacity=255*(1-p)
                right_focus.opacity=255*p
                overlay.opacity=255*.5*(1-p)
                if p == 1 then
                    --mediaplayer:load()
                    this_obj.func_tbls.play_next_tile.next_tile = right_i
                    restore_keys()
                end
            end
        },
        fade_buttons_from_tile = {
            duration = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                right_tiles[right_i].opacity=255*p
                bottom_buttons_base[3].opacity=255*(.3+.7*(p))
                bottom_buttons_foci[3].opacity=255*(p)
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
            if bottom_i ~= 4 or right_i == 1 then return end
            lose_keys()
            self.func_tbls.move_to_tile.curr_tile = right_i
            self.func_tbls.move_to_tile.next_tile = right_i - 1
            animate_list[self.func_tbls.move_to_tile] = self
            
            right_i = right_i - 1
            
        end,
        [keys.Down] = function(self)
            if bottom_i ~= 4 or right_i == 4 then return end
            lose_keys()
            self.func_tbls.move_to_tile.curr_tile = right_i
            self.func_tbls.move_to_tile.next_tile = right_i + 1
            animate_list[self.func_tbls.move_to_tile] = self
            
            right_i = right_i + 1
        end,
        [keys.Left] = function(self)
            if bottom_i == 1 then return end
            lose_keys()
            if bottom_i == 4 then
                
                animate_list[self.func_tbls.fade_buttons_from_tile] = self
                
                
            else
                
                self.func_tbls.focus_out_button.index = bottom_i
                animate_list[self.func_tbls.focus_out_button] = self
                
                self.func_tbls.focus_in_button.index = bottom_i-1
                animate_list[self.func_tbls.focus_in_button] = self
                
            end
            bottom_i = bottom_i - 1
        end,
        [keys.Right] = function(self)
            if bottom_i == 4 then return end
            lose_keys()
            if bottom_i == 3 then
                
                self.func_tbls.focus_tile_from_buttons.index = right_i
                animate_list[self.func_tbls.focus_tile_from_buttons] = self
                
            else
                
                self.func_tbls.focus_out_button.index = bottom_i
                animate_list[self.func_tbls.focus_out_button] = self
                
                self.func_tbls.focus_in_button.index = bottom_i+1
                animate_list[self.func_tbls.focus_in_button] = self
                
            end
            bottom_i = bottom_i + 1
        end,
        [keys.OK] = function(self)
            
            if bottom_i == 1 then
                lose_keys()
                if mediaplayer.state ~= "PLAYING" then
                    self.func_tbls.slide_main_pane_right.index=left_i
                    animate_list[self.func_tbls.slide_main_pane_right] = self
                end
                left_i = (left_i-2)%#left_panes+1
                self.func_tbls.slide_new_pane_right.index=left_i
                animate_list[self.func_tbls.slide_new_pane_right] = self
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
            elseif bottom_i == 4 then
                lose_keys()
                change_page_to("category_page")
            end
        end,
    }
}