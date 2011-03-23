local TITLE_X = 245
local TITLE_Y = 438
local TITLE_SZ = 54
local SUB_TITLE_X = 275
local SUB_TITLE_Y = 547
local SUB_TITLE_SZ = 30
local PRIOR_X = 280
local PRIOR_Y = 898
local VIEW_COL_X = 585
local VIEW_COL_Y = 898
local NEXT_X = 1113
local NEXT_Y = 898
local RIGHT_PANE_X = 1578
local TILE_TEXT_Y_OFFSET = 236
local TILE_H = 310

local bottom_i = 1
local right_i  = 1

local umbrella = Group{}

local left_img = Image{src="assets/main-bg-frame.jpg"}
local right_tiles = {
    Image{src="assets/tile-main-womes1.png" , x=RIGHT_PANE_X,y=TILE_H*0},
    Image{src="assets/tile-main-mens1.png"  , x=RIGHT_PANE_X,y=TILE_H*1},
    Image{src="assets/tile-main-beauty1.png", x=RIGHT_PANE_X,y=TILE_H*2},
    Image{src="assets/tile-main-biker1a.png", x=RIGHT_PANE_X,y=TILE_H*3},
}
local bottom_buttons_base = {
    Group{
        x = PRIOR_X,
        y = PRIOR_Y
    },
    Group{
        x = VIEW_COL_X,
        y = VIEW_COL_Y
    },
    Group{
        x = NEXT_X,
        y = NEXT_Y
    },
}
local bottom_buttons_foci = {
    Group{
        x = PRIOR_X,
        y = PRIOR_Y
    },
    Group{
        x = VIEW_COL_X,
        y = VIEW_COL_Y
    },
    Group{
        x = NEXT_X,
        y = NEXT_Y
    },
}
do
    local rect = Rectangle{w=204,h=55}
    local text = Text{
        font="Engravers MT "..SUB_TITLE_SZ.."px",
        text="PRIOR",
        position={rect.w/2+47-22,rect.h/2}
    }
    text.anchor_point={text.w/2,text.h/2}
    
    bottom_buttons_base[1]:add(rect,text)
    
    
    rect = Rectangle{w=421,h=55}
    text = Text{
        font="Engravers MT "..SUB_TITLE_SZ.."px",
        text="VIEW COLLECTION",
        position={rect.w/2,rect.h/2}
    }
    text.anchor_point={text.w/2,text.h/2}
    
    bottom_buttons_base[2]:add(rect,text)
    
    
    rect = Rectangle{w=181,h=55}
    text = Text{
        font="Engravers MT "..SUB_TITLE_SZ.."px",
        text="VIEW COLLECTION",
        position={rect.w/2,rect.h/2}
    }
    text.anchor_point={text.w/2,text.h/2}
    
    bottom_buttons_base[3]:add(rect,text)
end

front_page = {
    func_tbls = {
        fade_in_from = {
            
        },
        fade_out_from = {
            
        },
        focus_to_tiles_from_bottom = {
            
        },
        focus_to_bottom_from_tiles = {
            
        },
    },
    keys = {
        [keys.Up] = function()
            if bottom_i ~= 4 then return end
        end,
        [keys.Down] = function()
            if bottom_i ~= 4 then return end
        end,
        [keys.Left] = function()
        end,
        [keys.Right] = function()
        end,
        [keys.Ok] = function()
        end,
    }
}