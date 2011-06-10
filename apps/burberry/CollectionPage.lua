local TITLE_X = 245
local TITLE_Y = 438
local TITLE_SZ = 54
local SUB_TITLE_X = 275
local SUB_TITLE_Y = 547
local SUB_TITLE_SZ = 30
local PRIOR_X = 175
local PRIOR_Y = 20
local VIEW_COL_X = 591
local VIEW_COL_Y = 20
local NEXT_X = 1158
local NEXT_Y = 20
local RIGHT_PANE_X = 1545
local TILE_TEXT_Y_OFFSET = 236
local TILE_W = 260
local TILE_H = 236

local bottom_i = 1
local right_i  = 1

local umbrella = Group{opacity=0}

local bg = Image{src="assets/beauty-frames-for-video.png"}
local left_img = Image{src="assets/beauty-main-image.png",x=75,y=75}
local right_tiles = {
    Image{src="assets/tile-260x236-eyes.png", x=RIGHT_PANE_X, y= 31},
    Image{src="assets/tile-260x236-glow.png", x=RIGHT_PANE_X, y=290},
    Image{src="assets/tile-260x236-lips.png", x=RIGHT_PANE_X, y=550},
    Image{src="assets/tile-260x236-skin.png", x=RIGHT_PANE_X, y=810},
}
local right_focus = Group{x=RIGHT_PANE_X,y=30,opacity=0}
local top_buttons_base = {
    Group{
        x = PRIOR_X,
        y = PRIOR_Y,
        --opacity = 255*.3,
    },
    Group{
        x = VIEW_COL_X,
        y = VIEW_COL_Y,
        opacity = 255*.3,
    },
    Group{
        x = NEXT_X,
        y = NEXT_Y,
        opacity = 255*.3,
    },
}
local top_buttons_foci = {
    Group{
        x = PRIOR_X-10,
        y = PRIOR_Y-10,
        --opacity = 0,
    },
    Group{
        x = VIEW_COL_X-10,
        y = VIEW_COL_Y-10,
        opacity = 0,
    },
    Group{
        x = NEXT_X-10,
        y = NEXT_Y-10,
        opacity = 0,
    },
}

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
    right_focus:add(tl_corner,top,tr_corner,left,right,btm,bl_corner,br_corner)
    
    local rect = Rectangle{w=152,h=55,color="000000"}
    local text = Text{
        font="Engravers MT "..SUB_TITLE_SZ.."px",
        text="BACK",
        position={rect.w/2,rect.h/2},
        color="ffffff",
    }
    text.anchor_point={text.w/2,text.h/2}
    
    top_buttons_base[1]:add(rect,text)
    
    local left  = Clone{source=imgs.fp.foc_end}
    local mid   = Clone{source=imgs.fp.foc_mid,x=left.w,w=120,tiles}
    local right = Clone{source=imgs.fp.foc_end,x=2*left.w+mid.w,y_rotation={180,0,0}}
    
    top_buttons_foci[1]:add(left,mid,right)
    
       
    rect = Rectangle{w=304,h=55,color="000000"}
    text = Text{
        font="Engravers MT "..SUB_TITLE_SZ.."px",
        text="PLAY VIDEO",
        position={rect.w/2,rect.h/2},
        color="ffffff",
    }
    text.anchor_point={text.w/2,text.h/2}
    
    top_buttons_base[2]:add(rect,text)
    
    top_buttons_foci[2]:add(
        Clone{source=imgs.fp.foc_end},
        Clone{source=imgs.fp.foc_mid,x=26,w=272,tiles},
        Clone{source=imgs.fp.foc_end,x=26*2+272,y_rotation={180,0,0}}
    )
    
    
    rect = Rectangle{w=181,h=55,color="000000"}
    text = Text{
        font="Engravers MT "..SUB_TITLE_SZ.."px",
        text="BROWSE",
        position={rect.w/2,rect.h/2},
        color="ffffff",
    }
    text.anchor_point={text.w/2,text.h/2}

    
    top_buttons_base[3]:add(rect,text)
    
    top_buttons_foci[3]:add(
        Clone{source=imgs.fp.foc_end},
        Clone{source=imgs.fp.foc_mid,x=26,w=149,tiles},
        Clone{source=imgs.fp.foc_end,x=26*2+149,y_rotation={180,0,0}}
    )
end


umbrella:add(unpack(right_tiles))
umbrella:add(left_img,bg)
umbrella:add(unpack(top_buttons_base))
umbrella:add(unpack(top_buttons_foci))
umbrella:add(right_focus,overlay)
collection_page = {
    group = umbrella,
    func_tbls = {
        fade_in_from = {
            ["front_page"] = {
                duration = 300,
                func = function(this_obj,this_func_tbl,secs,p)
                    this_obj.group.opacity=255*p
                end
            }
        },
        fade_out_to = {
            ["front_page"] = {
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
                
                top_buttons_base[this_func_tbl.index].opacity=255*(.3+.7*(1-p))
                top_buttons_foci[this_func_tbl.index].opacity=255*(1-p)
            end
        },
        focus_in_button = {
            index = 1,
            duration = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                top_buttons_base[this_func_tbl.index].opacity=255*(.3+.7*(p))
                top_buttons_foci[this_func_tbl.index].opacity=255*(p)
            end
        },
        move_to_tile  = {
            next_tile = 2,
            curr_tile = 1,
            duration  = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                right_tiles[this_func_tbl.curr_tile].opacity=255*p
                right_focus.y=30+TILE_W*(this_func_tbl.curr_tile-1) +(this_func_tbl.next_tile-this_func_tbl.curr_tile)*TILE_W*p
                if p == 1 then
                    --mediaplayer:load()
                    this_obj.func_tbls.play_next_tile.next_tile = this_func_tbl.next_tile
                    animate_list[this_obj.func_tbls.play_next_tile] = this_obj
                end
            end
        },
        play_next_tile = {
            next_tile = 2,
            duration  = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                right_tiles[this_func_tbl.next_tile].opacity=255*(1-p)
            end
        },
        focus_tile_from_buttons = {
            index = 1,
            duration  = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                top_buttons_base[3].opacity=255*(.3+.7*(1-p))
                top_buttons_foci[3].opacity=255*(1-p)
                right_tiles[this_func_tbl.index].opacity=255*(1-p)
                right_focus.opacity=255*p
                if p == 1 then
                    --mediaplayer:load()
                    this_obj.func_tbls.play_next_tile.next_tile = right_i
                end
            end
        },
        fade_buttons_from_tile = {
            duration = 300,
            func = function(this_obj,this_func_tbl,secs,p)
                right_tiles[right_i].opacity=255*p
                top_buttons_base[3].opacity=255*(.3+.7*(p))
                top_buttons_foci[3].opacity=255*(p)
                right_focus.opacity=255*(1-p)
                if p == 1 then
                    --mediaplayer:load()
                    this_obj.func_tbls.focus_in_button.index = 3
                end
            end
        },
    },
    keys = {
        [keys.Up] = function(self)
            if bottom_i ~= 4 or right_i == 1 then return end
            self.func_tbls.move_to_tile.curr_tile = right_i
            self.func_tbls.move_to_tile.next_tile = right_i - 1
            animate_list[self.func_tbls.move_to_tile] = self
            
            right_i = right_i - 1
            
        end,
        [keys.Down] = function(self)
            if bottom_i ~= 4 or right_i == 4 then return end
            self.func_tbls.move_to_tile.curr_tile = right_i
            self.func_tbls.move_to_tile.next_tile = right_i + 1
            animate_list[self.func_tbls.move_to_tile] = self
            
            right_i = right_i + 1
        end,
        [keys.Left] = function(self)
            if bottom_i == 1 then return end
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
                change_page_to("front_page")
            elseif bottom_i == 3 then
                change_page_to("category_page")
            end
        end,
    }
}