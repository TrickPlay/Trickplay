-- Objects.lua - this file defines the Tile class



--the source for cloning the backs of the tiles
local backing = Image{src="assets/tile-front.png"}
tile_size = backing.w
screen:add(backing)
backing:hide()

Tile = Class(function(obj, face_source, parent, ...)
    
    --Clone of the backing
    obj.backing = Clone{
        source = backing,
        anchor_point={backing.w/2,backing.h/2},
        z=1
    }
    --Container group for all of the Clones of the face of the tile
    obj.face    = Group{
        y_rotation={180,0,0},
        anchor_point={backing.w/2,backing.h/2}
    }
    --save the source integer
    obj.index   = face_source
    
    
    --clone each part of the face
    obj.tbl     = {}
    for i = 1, #tile_faces[face_source].tbl do
        obj.tbl[i] = Clone{ source = tile_faces[face_source].tbl[i] }
        obj.face:add(obj.tbl[i])
    end
    
    
    --Umbrella group for the instance
    obj.group = Group{name="Tile"}
    obj.group:add(obj.backing,obj.face)
    
    --flag for whether the tile is flipped or not
    local flipped = false
    
    --Animation for flipping the tile over
    local flip_over = function(first_choice)
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
            end
            tl:start()
        end
        tile_faces[face_source].reset(obj.tbl)
        tl:start()
    end
    
    
    --animation for flipping the tile back down
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
        end
        tl:start()
    end
    
    
    --
    obj.remove = function()
        game_state.board[parent[1]][parent[2]] = 0
        
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
    
    obj.flip = function(first_choice)
        if flipped then  flip_back()
        else             flip_over(first_choice)  end
        
        flipped = not flipped
        return face_source
        
    end
end)