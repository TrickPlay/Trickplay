-- Objects.lua - Used to defing the various objects used by this app
--
-- this file defines:
--   -   the Tile class



--the source for cloning the backs of the tiles
local backing = Image{src="assets/tile-front.png"}
tile_size = backing.w
screen:add(backing)
backing:hide()
local face_base = Image{src="assets/tile-back.png"}
screen:add(face_base)
face_base:hide()
local win_img = Image{src="assets/win_txt.png",position={screen_w/2,screen_h/2}}
win_img.anchor_point = {win_img.w/2,win_img.h/2}

local match     = 1
local no_match  = 1
local win_sound = 1


local win_animation = {
    duration = {1000,2000},
    setup = function()
        screen:add(win_img)
        win_img.opacity=0
        win_sound = win_sound%(#audio.win)+1
        play_sound_wrapper(audio.win[win_sound])
    end,
    stages = {
        function(self,delta,p)
            get_gs_focus().opacity=255*(1-p)
            win_img.opacity = p*255
            win_img.scale = {p,p}
        end,
        function()
        end
    },
    on_remove = function(self)
        win_img:unparent()
        game_state.in_game=false
        give_keys("SPLASH")
    end
}

local flipping = false
Tile = Class(function(obj, face_source, parent, ...)
    
    --Clone of the backing
    obj.backing = Clone{
        source = backing,
        anchor_point={backing.w/2,backing.h/2},
        z=1
    }
    obj.face_backing = Clone{
        source = face_base,
        anchor_point={face_base.w/2,face_base.h/2},
        y_rotation={180,0,0},
        z=0
    }
    --Container group for all of the Clones of the face of the tile
    obj.face    = Group{
        y_rotation={180,0,0},
        anchor_point={backing.w/2,backing.h/2}
    }
    --save the source integer
    obj.index   = face_source
    
    --Umbrella group for the instance
    obj.group = Group{name="Tile",opacity=0}
    obj.group:add(obj.backing,obj.face_backing)
    
    --clone each part of the face
    local function init_face()
        obj.tbl     = {}
        local v, child
        --for i, v in ipairs(tile_faces[face_source].tbl)
        for i = 1, #tile_faces[face_source].tbl do
            v = tile_faces[face_source].tbl[i]
            if type(v.children) == "table" then
                obj.tbl[i] = Group{x=v.x,y=v.y}
                for j = 1, #v.children do
                    child = v.children[j]
                    obj.tbl[i]:add(
                        Clone{
                            source = child,
                            name   = child.name,
                            x      = child.x,
                            y      = child.y,
                            scale  = {child.scale[1],child.scale[2]}
                        }
                    )
                end
            else
                obj.tbl[i] = Clone{
                    source =  v,
                    x      =  v.x,
                    y      =  v.y,
                    scale  = {v.scale[1],v.scale[2]}
                }
            end
            obj.face:add(obj.tbl[i])
        end
        if tile_faces[face_source].clip then
            obj.face.clip = {1,0,tile_size-2,tile_size}
        end
    end
    init_face()
    
    
    
    --flag for whether the tile is flipped or not
    local flipped = false
    local first_choice = nil
    
    --Animation for flipping the tile over

    local face_animation = {
        tbl      = obj.tbl,
        g        = obj.face,
        loop     = true,
        duration = {},
        stages   = {},
    }
    
    for i, v in ipairs(tile_faces[face_source].stages) do
        face_animation.duration[i] = tile_faces[face_source].duration[i]
        face_animation.stages[i] = v
    end
    
    
    local flip_over = {
        duration = {500,nil,1000},
        setup  = function()
            --init_face()
            obj.group:add(obj.face)
            tile_faces[face_source].reset(obj.tbl)
            play_sound_wrapper(audio.card_flip)
        end,
        stages = {
            function(self,delta,p)
                obj.group.y_rotation={180*p,0,0}
                obj.backing.z = 1-p
                obj.face.z    = p
            end,
            function(self,delta,p)
                face_animation.played = false
                animate_list[face_animation] = face_animation
                self.stage = self.stage + 1
            end,
            function(self,delta,p)
            end,
            
        },
        on_remove = function(self)
            if first_choice ~= nil then
                if obj.index ~= first_choice.index then
                    no_match = no_match%(#audio.no_match)+1
                    play_sound_wrapper(audio.no_match[no_match])
                    first_choice.flip_b()
                    obj.flip_b()
                elseif first_choice ~= obj then
                    animate_list[first_choice.remove]=first_choice.remove
                    animate_list[obj.remove]=obj.remove
                    match = match%(#audio.match)+1
                    play_sound_wrapper(audio.match[match])
                end
            end
            flipping = false
        end
    }
    
    --animation for flipping the tile back down
    local flip_back = {
        duration = {500},
        setup = function()
            play_sound_wrapper(audio.card_flip)
        end,
        stages = {
            function(self,delta,p)
                obj.group.y_rotation={180*(1-p),0,0}
                obj.backing.z = p
                obj.face.z    = 1-p
            end
        },
        on_remove = function(self)
            --obj.face:clear()
            animate_list[face_animation] = nil
            obj.face:unparent()
            flipped = false
            collectgarbage("collect")
        end
    }
    
    obj.remove = {
        duration = {300},
        setup = function(self)
            game_state.board[ parent[1] ][ parent[2] ] = 0
        end,
        stages = {
            function(self,delta,p)
                obj.group.opacity = 255 * (1-p)
            end
        },
        on_remove = function(self)
            animate_list[face_animation] = nil
            obj.group:unparent()
            game_state.tot = game_state.tot - 1
            if game_state.tot == 0 then
                animate_list[win_animation]=win_animation
            end
            flipped = false
            obj.face.clip = {}
            obj = nil
            collectgarbage("collect")
        end
    }

    obj.flip_b = function()
        if flipped then animate_list[flip_back]=flip_back
        end
    end
    obj.flip = function(f)
        if flipping or flipped then return false end
        flipping = true
        first_choice = f
        animate_list[flip_over]=flip_over
        flipped = true
        return true
        
    end
end)