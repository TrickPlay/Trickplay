local bar = Group{name = "VideoTileBar", position = {screen.w/2,screen.h/2},anchor_point = {screen.w/2,screen.h/2}}

local wrap_around_tile
local wrap_around_clone = Clone()

local tiles = {}

local state

local function wrap_i(i)
    
    return ( i - 1 ) % ( # tiles ) + 1
    
end
local end_x_s = {
    30-300,30+600,30+600*2+300
}
local x_s = {
    30,30+600,30+600*2
}
local item_spacing = 600

function bar:init(p)
    
    if type(p) ~= "table" then error("must pass a table",2) end
    
    tile_spacing = screen.w / # p.tiles
    
    
    wrap_around_tile = p.video_tile:create{
        text = " ",
        contents = wrap_around_clone
    }
    wrap_around_tile.x = -1000
    wrap_around_tile.y = 50
    self:add(wrap_around_tile)
    
    for i,v in ipairs(p.tiles) do
        
        tiles[i] = p.video_tile:create(v)
        tiles[i].x = x_s[i]
        tiles[i].y = 50
    end
    
    self:add(unpack(tiles))
    
    local curr_i = 1
    
    local transitions = {}
    
    
    local on_started   = { }
    
    
    for i,v in ipairs(tiles) do
        on_started[i]   = {}
    end
    
    
    --press left
    
    for i,v in ipairs(tiles) do
        
        local keys = {}
        
        --previously focused item is one index greater
        local prev = wrap_i(i + 1)
        
        on_started[prev][i] = function()
            
            wrap_around_tile.y_rotation = {0,0,0}
            
            wrap_around_tile.x = tiles[i].x 
            
            wrap_around_tile.text = tiles[i].text
            
            wrap_around_tile.expanded_h = tiles[i].expanded_h
            
            wrap_around_clone.source    = tiles[i].content
            
            wrap_around_clone.position  = tiles[i].content.position
            
            tiles[i].x = x_s[1]
            
            tiles[i].y_rotation = {180,0,0}
            
            tiles[i]:lower_to_bottom()
            
            tiles[prev].state = "CONTRACT"
            
            wrap_around_tile:warp("CONTRACT")
            
            tiles[i]:warp("EXPAND")
            
            tiles[i].state = "EXPAND"
            
        end
        
        table.insert(keys,{wrap_around_tile,"x", screen.w })
        
        for ii,vv in ipairs(tiles) do
            
            if i == ii then
                
                table.insert(keys,{vv,"y_rotation", 0})
                
            else
                
                table.insert(keys,{vv,"x", x_s[wrap_i(ii-i+1)] })
                
            end
            
        end
        
        transitions[ i ] = {
            source   = prev ,
            target   = i,
            duration = p.duration,
            keys     = keys
        }
        
    end
    
    
    --press right
    
    for i,v in ipairs(tiles) do
        
        local keys = {}
        
        --previously focused item is one index less
        local prev = wrap_i(i - 1)
        
        on_started[prev][i] = function()
            
            wrap_around_tile.x = tiles[prev].x
            
            wrap_around_tile.text = tiles[prev].text
            
            wrap_around_tile.expanded_h = tiles[prev].expanded_h
            
            wrap_around_clone.source   = tiles[prev].content
            
            wrap_around_clone.position = tiles[prev].content.position
            
            wrap_around_tile.y_rotation = {0,0,0}
            
            tiles[prev].x = screen.w
            
            tiles[prev]:warp("CONTRACT")
            
            wrap_around_tile:warp("EXPAND")
            
            tiles[i].state = "EXPAND"
            
            wrap_around_tile:lower_to_bottom()
            
            
            --wrap_around_tile.state = "CONTRACT"
            
        end
        
        table.insert(keys,{wrap_around_tile,"y_rotation", 180 })
        
        for ii,vv in ipairs(tiles) do
            
            table.insert(keys,{vv,"x", x_s[wrap_i(ii-i+1)] })
            
        end
        
        --table.insert(keys,{tiles[prev],"y_rotation", 180)
        
        transitions[ i + # tiles] = {
            source   = prev,
            target   = i,
            duration = p.duration,
            keys     = keys
        }
        
    end
    
    local animating = false
    
    local animate_out = Timeline{
        duration = 500,
        on_new_frame = function(tl,ms,p)
            
            self.scale = {1+.3*p,1+.3*p}
            
            self.opacity = 255*(1-p)
            
            for i = 1,#tiles do
                
                --i=wrap_i(i)
                --print(i)
                tiles[wrap_i(i+curr_i-1)].x = x_s[i] + (end_x_s[i] - x_s[i])*p
                
                tiles[wrap_i(i+curr_i-1)].y =     50 + (      -200 -     50)*p
                
            end
            
        end,
        on_completed = function(tl)
            animating = false
            tl.direction = dismissed and "BACKWARD" or "FORWARD"
            
        end
        
    }
        
    function self:dismiss()
        
        if animating then return false end
        
        dismissed = true
        animating = true
        animate_out:start()
        self:grab_key_focus()
    end
    
    
    
    state = AnimationState{
        
        duration = 500,
        
        transitions = transitions,
        
    }    
    
    
    
    state.timeline.on_completed = function()
        
        animating = false
        
    end
    state.state = curr_i
    
    dolater(function() tiles[curr_i].state = "EXPAND" end)
    --tiles[state.state+0].state = "EXPAND"
    local key_press = {
        
        [keys.Left] = function()
            
            animating = true
            
            on_started[curr_i][wrap_i(state.state - 1)]()
            
            curr_i = wrap_i(curr_i - 1)
            
            state.state = curr_i
            
        end,
        
        [keys.Right] = function()
            
            animating = true
            
            on_started[curr_i][wrap_i(state.state + 1)]()
            
            curr_i = wrap_i(curr_i + 1)
            
            state.state = curr_i
            
        end,
        
        [keys.BACK] = function()
            
            self:dismiss()
            
        end,
        
    }
    
    function self:on_key_down(k)
        
        if dismissed then
            
            if k == keys.OK then
                animate_out:start()
                dismissed = false
                tiles[curr_i].state = "EXPAND"
            end
            return
        end
        return not animating and key_press[k] and key_press[k]()
        
    end
    
    --dolater(function() self:grab_key_focus() end)
    
end


return bar