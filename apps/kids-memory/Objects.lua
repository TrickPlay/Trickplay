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
local win_txt = Text{
    text     = "You've Won!",
    font     = "Sans 32px",
    opacity  =  0,
    position = {screen_w/2,screen_h/2}
}
win_txt.anchor_point = {win_txt.w/2,win_txt.h/2}

local win_animation = {
    duration = {1000,1000},
    setup = function()
        screen:add(win_txt)
        win_txt.opacity=0
    end,
    stages = {
        function(self,delta,p)
            win_txt.opacity = p*255
        end,
        function()
        end
    },
    on_remove = function(self)
        win_txt:unparent()
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
    
    
    --clone each part of the face
    local function init_face()
        obj.tbl     = {}
        for i = 1, #tile_faces[face_source].tbl do
            obj.tbl[i] = Clone{ source = tile_faces[face_source].tbl[i] }
            obj.tbl[i].position = {tile_faces[face_source].tbl[i].x,tile_faces[face_source].tbl[i].y}
            obj.tbl[i].scale = {tile_faces[face_source].tbl[i].scale[1],tile_faces[face_source].tbl[i].scale[2]}
            obj.face:add(obj.tbl[i])
        end
    end
    init_face()
    
    --Umbrella group for the instance
    obj.group = Group{name="Tile"}
    obj.group:add(obj.backing,obj.face_backing)
    
    --flag for whether the tile is flipped or not
    local flipped = false
    local first_choice = nil
    
    --Animation for flipping the tile over
    --[[
    local flip_over = function(first_choice)
        init_face()
        local tl = Timeline{duration=500}
        function tl:on_new_frame()
            obj.group.y_rotation={180*tl.progress,0,0}
            obj.backing.z = 1-tl.progress
            obj.face.z    = tl.progress
        end
        function tl:on_completed()
            obj.group.y_rotation={180,0,0}
            tl = nil
            obj.backing.z = 0
            obj.face.z    = 1
            
            --animation for the face
            tl = Timeline{duration=1000}
            function tl:on_new_frame()
                tile_faces[face_source].on_new_frame(obj.tbl,tl.progress)
            end
            function tl:on_completed()
                tile_faces[face_source].on_completed(obj.tbl)
                print(first_choice)
                if first_choice ~= nil then
                    if obj.index ~= first_choice.index then
                        first_choice.flip()
                        obj.flip()
                    else
                        first_choice.remove()
                        obj.remove()
                        
                    end
                end
                tl=nil
                
            end
            tl:start()
        end
        tile_faces[face_source].reset(obj.tbl)
        tl:start()
    end
    --]]
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
        end,
        stages = {
            function(self,delta,p)
                obj.group.y_rotation={180*p,0,0}
                obj.backing.z = 1-p
                obj.face.z    = p
            end,
            function(self,delta,p)
                animate_list[face_animation] = face_animation
                self.stage = self.stage + 1
            end,
            function(self,delta,p)
            end,
            
        },
        on_remove = function(self)
            if first_choice ~= nil then
                if obj.index ~= first_choice.index then
                    first_choice.flip_b()
                    obj.flip_b()
                elseif first_choice ~= obj then
                    animate_list[first_choice.remove]=first_choice.remove
                    animate_list[obj.remove]=obj.remove
                end
            end
            flipping = false
        end
    }
    
    --animation for flipping the tile back down
    --[[
    local flip_back = function()
        local tl = Timeline{duration=500}
        function tl:on_new_frame()
            obj.group.y_rotation={180*(1-tl.progress),0,0}
            obj.backing.z = tl.progress
            obj.face.z    = 1-tl.progress
        end
        function tl:on_completed()
            obj.group.y_rotation={0,0,0}
            tl = nil
            obj.backing.z = 1
            obj.face.z    = 0
            tl = nil
            obj.face:clear()
        end
        tl:start()
    end
    --]]
    local flip_back = {
        duration = {500},
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
                animate_list[win_txt]=win_txt
            end
            flipped = false
        end
    }
    --[[
    obj.remove = function()
        game_state.board[ parent[1] ][ parent[2] ] = 0
        
        obj.group:animate{
            duration = 300,
            opacity  = 0,
            on_completed = function()
                obj = nil
                game_state.tot = game_state.tot - 1
                if game_state.tot == 0 then
                    local tl = Timeline{duration=2000}
                    local txt = Text{
                        text="You've Won!",
                        font="Sans 32px",
                        opacity=0,
                        position={screen_w/2,screen_h/2}
                    }
                    txt.anchor_point = {txt.w/2,txt.h/2}
                    screen:add(txt)
                    function tl:on_new_frame()
                        local p = tl.progress*2
                        if p < 1 then
                            txt.opacity = p*255
                        else
                            txt.opacity = 255
                        end
                    end
                    function tl:on_completed()
                        txt:unparent()
                        game_state.in_game=false
                        give_keys("SPLASH")
                    end
                    tl:start()
                end
            end
        }
    end
    --]]
    obj.flip_b = function()
        --[[
        if flipped then  flip_back()
        else             flip_over(first_choice)  end
        --]]
        --print(flipped)
        if flipped then animate_list[flip_back]=flip_back
        --else            animate_list[#animate_list+1]=flip_back
        end
        --flipped = not flipped
        
        --return face_source
    end
    obj.flip = function(f)
        if flipping or flipped then return false end
        flipping = true
        first_choice = f
        --[[
        if flipped then  flip_back()
        else             flip_over(first_choice)  end
        --]]
        animate_list[flip_over]=flip_over
        --else            animate_list[#animate_list+1]=flip_back
        
        --flipped = not flipped
        flipped = true
        return true
        
    end
end)