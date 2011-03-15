screen:show()

widget = {}
--[[
Function: scrollWindow

Creates a 2D grid of items, that animate in with a flipping animation

Arguments:
    num_rows    - number of rows
    num_cols    - number of columns
    item_w      - width of an item
    item_h      - height of an item
    grid_gap    - the number of pixels in between the grid items
    duration_per_tile - how long a particular tile flips for
    cascade_delay     - how long a tile waits to start flipping after its neighbor began flipping

Return:

    loading_bar_group - group containing the loading bar
]]
function widget.scrollWindow(t)

    -- reference: http://www.csdgn.org/db/179

    --default parameters
    local p = {
        clip_w    =  600,
        color     = "FFFFFF",
        clip_h    =  600,
        border_w  =    2,
        content_h =  1000,
        content_w =  1000,
        arrow_clone_source = nil,
        arrow_sz  = 10,
        arrows_in_box = false,
        arrows_centered = false,
        grip_is_visible = true
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
    
    --Group that Clips the content
    local window  = Group{}
    --Group that contains all of the content
    local content = Group{}
    --declarations for dependencies from scroll_group
    local scroll
    --flag to hold back key presses while animating content group
    local animating = false

    
    

    --the umbrella Group, containing the full slate of tiles
    local scroll_group = Group{ 
        name     = "Scroll clip",
        position = {200,100},
        
        extra    = {
            type = "Scroll Group",
            get_content_group = function()
                return content
            end
        }
    }
    
    --Key Handler
    local keys={
        [keys.Left] = function()
            if p.content_w > p.clip_w then
                scroll_x(1)
            end
        end,
        [keys.Right] = function()
            if p.content_w > p.clip_w then
                scroll_x(-1)
            end
        end,
        [keys.Up] = function()
            if p.content_h > p.clip_h then
                scroll_y(1)
            end
        end,
        [keys.Down] = function()
            if p.content_h > p.clip_h then
                scroll_y(-1)
            end
        end,
    }
    scroll_group.on_key_down = function(self,key)
        if animating then return end
        if keys[key] then
            keys[key]()
        else
            print("Scroll Window does not support that key")
        end
    end
    local border = Rectangle{ color = "00000000" }
    
    local arrow_up, arrow_dn, arrow_l, arrow_r
    
    local track_h, track_w
    local grip_h, grip_w
    
    
    local grip_vert_base_y, grip_hor_base_x
    local grip_vert = Rectangle{reactive=true}
    local grip_hor  = Rectangle{reactive=true}
    
    scroll_y = function(dir)
        local new_y = content.y+ dir*10
        animating = true
        content:animate{
            duration = 200,
            y = new_y,
            on_completed = function()
                if content.y < -(p.content_h - p.clip_h) then
                    content:animate{
                        duration = 200,
                        y = -(p.content_h - p.clip_h),
                        on_completed = function()
                            animating = false
                        end
                    }
                elseif content.y > 0 then
                    content:animate{
                        duration = 200,
                        y = 0,
                        on_completed = function()
                            animating = false
                        end
                    }
                else
                    animating = false
                end
            end
        }
        
        if new_y < -(p.content_h - p.clip_h) then
            grip_vert.y = grip_vert_base_y+(track_h-grip_h)
        elseif new_y > 0 then
            grip_vert.y = grip_vert_base_y
        else
            grip_vert:complete_animation()
            grip_vert:animate{
                duration= 200,
                y = grip_vert_base_y-(track_h-grip_h)*new_y/(p.content_h - p.clip_h)
            }
        end
    end
    
    
    scroll_x = function(dir)
        local new_x = content.x+ dir*10
        animating = true
        content:animate{
            duration = 200,
            x = new_x,
            on_completed = function()
                if content.x < -(p.content_w - p.clip_w) then
                    content:animate{
                        duration = 200,
                        y = -(p.content_w - p.clip_w),
                        on_completed = function()
                            animating = false
                        end
                    }
                elseif content.x > 0 then
                    content:animate{
                        duration = 200,
                        x = 0,
                        on_completed = function()
                            animating = false
                        end
                    }
                else
                    animating = false
                end
            end
        }
        
        if new_x < -(p.content_w - p.clip_w) then
            grip_hor.x = grip_hor_base_x+(track_w-grip_h)
        elseif new_x > 0 then
            grip_hor.x = grip_hor_base_x
        else
            grip_hor:complete_animation()
            grip_hor:animate{
                duration= 200,
                x = grip_hor_base_x-(track_w-grip_h)*new_x/(p.content_w - p.clip_w)
            }
        end
    end
    
    
    local function create()
        content.position  = { p.border_w, p.border_w }
        window.clip = { p.border_w, p.border_w, p.clip_w, p.clip_h }
        border.w = p.clip_w+2*p.border_w
        border.h = p.clip_h+2*p.border_w
        border.border_width = p.border_w
        border.border_color = p.color
        
        if p.arrow_clone_source == nil then
            
            if arrow_up ~= nil then arrow_up:unparent() end
            
            arrow_up = Canvas{size={p.arrow_sz,p.arrow_sz}}
            arrow_up:begin_painting()
            arrow_up:move_to( arrow_up.w/2,          0 )
            arrow_up:line_to(   arrow_up.w, arrow_up.h )
            arrow_up:line_to(            0, arrow_up.h )
            arrow_up:line_to( arrow_up.w/2,          0 )
            arrow_up:set_source_color("FFFFFF")
            arrow_up:fill(true)
            arrow_up:finish_painting()
            if arrow_up.Image then
                arrow_up = arrow_up:Image()
            end
            
            
            if arrow_dn ~= nil then arrow_dn:unparent() end
            
            arrow_dn = Canvas{size={p.arrow_sz,p.arrow_sz}}
            arrow_dn:begin_painting()
            arrow_dn:move_to(            0,          0 )
            arrow_dn:line_to(   arrow_dn.w,          0 )
            arrow_dn:line_to( arrow_dn.w/2, arrow_dn.h )
            arrow_dn:line_to(            0,          0 )
            arrow_dn:set_source_color("FFFFFF")
            arrow_dn:fill(true)
            arrow_dn:finish_painting()
            if arrow_dn.Image then
                arrow_dn = arrow_dn:Image()
            end
            
            
            if arrow_l ~= nil then arrow_l:unparent() end
            
            arrow_l = Canvas{size={p.arrow_sz,p.arrow_sz}}
            arrow_l:begin_painting()
            arrow_l:move_to(   arrow_l.w,           0 )
            arrow_l:line_to(   arrow_l.w,   arrow_l.h )
            arrow_l:line_to(           0, arrow_l.h/2 )
            arrow_l:line_to(   arrow_l.w,           0 )
            arrow_l:set_source_color("FFFFFF")
            arrow_l:fill(true)
            arrow_l:finish_painting()
            if arrow_l.Image then
                arrow_l = arrow_l:Image()
            end
            
            
            if arrow_r ~= nil then arrow_r:unparent() end
            
            arrow_r = Canvas{size={p.arrow_sz,p.arrow_sz}}
            arrow_r:begin_painting()
            arrow_r:move_to(         0,           0 )
            arrow_r:line_to( arrow_r.w, arrow_l.h/2 )
            arrow_r:line_to(         0,   arrow_l.h )
            arrow_r:line_to(         0,           0 )
            arrow_r:set_source_color("FFFFFF")
            arrow_r:fill(true)
            arrow_r:finish_painting()
            if arrow_r.Image then
                arrow_r = arrow_r:Image()
            end
        else
            arrow_up = Clone{source=p.arrow_clone_source}
            arrow_dn = Clone{source=p.arrow_clone_source, z_rotation={180,0,0}}
            arrow_l  = Clone{source=p.arrow_clone_source, z_rotation={-90,0,0}}
            arrow_r  = Clone{source=p.arrow_clone_source, z_rotation={ 90,0,0}}
        end
        
        arrow_up.anchor_point = {arrow_up.w/2,arrow_up.h/2}
        arrow_dn.anchor_point = {arrow_dn.w/2,arrow_dn.h/2}
        arrow_l.anchor_point  = { arrow_l.w/2, arrow_l.h/2}
        arrow_r.anchor_point  = { arrow_r.w/2, arrow_r.h/2}
        
        
        
        
        
        scroll_group:add(arrow_up,arrow_dn,arrow_l,arrow_r)
        
        -- re-used values
        grip_vert_base_y =  arrow_up.h+5
        track_h     = (p.clip_h-2*arrow_up.h-10)
        grip_h      =  p.clip_h/p.content_h*track_h
        if grip_h < p.arrow_sz then
            grip_h = p.arrow_sz
        elseif grip_h > track_h then
            grip_h = track_h
        end
        
        grip_hor_base_x = arrow_l.w+5
        track_w     = (p.clip_w-2*arrow_l.w-10)
        grip_w      =  p.clip_w/p.content_w*track_w
        if grip_w < p.arrow_sz then
            grip_w = p.arrow_sz
        elseif grip_w > track_h then
            grip_w = track_h
        end
        
        
        grip_vert.w        = p.arrow_sz
        grip_vert.h        = grip_h
        grip_vert.color    = p.color
        grip_vert.position = {border.w+5,grip_vert_base_y}
        
        grip_hor.h        = p.arrow_sz
        grip_hor.w        = grip_h
        grip_hor.color    = p.color
        grip_hor.position = {grip_hor_base_x,border.h+5}
        
        if p.grip_is_visible and not p.arrows_centered then
            grip_hor.opacity  = 255
            grip_vert.opacity = 255
        else
            grip_hor.opacity  = 0
            grip_vert.opacity = 0
        end
        
        if p.arrows_centered then
            if p.arrows_in_box then
                arrow_up.position = {border.w/2+arrow_up.w/2+5,arrow_up.h/2+5 }
                arrow_dn.position = {border.w/2+arrow_dn.w/2+5,border.h-arrow_dn.h/2-5}
                arrow_l.position  = {arrow_l.w/2+5,border.h/2 + 5 + arrow_up.h/2}
                arrow_r.position  = {border.w-arrow_r.w/2-5,border.h/2 + 5 + arrow_up.h/2}
            else
                arrow_up.position = {border.w/2+arrow_up.w/2+5,-arrow_up.h/2-5}
                arrow_dn.position = {border.w/2+arrow_dn.w/2+5,border.h+arrow_dn.h/2+5}
                arrow_l.position  = {-arrow_l.w/2-5,border.h/2 + 5 + arrow_up.h/2}
                arrow_r.position  = {border.w+arrow_r.w/2+5,border.h/2 + 5 + arrow_up.h/2}
            end
        else
            if p.arrows_in_box then
            print("here")
                arrow_up.position = {border.w-arrow_up.w/2-5,arrow_up.h/2+5}
                arrow_dn.position = {border.w-arrow_dn.w/2-5,border.h-arrow_dn.h*3/2}
                arrow_l.position  = {         arrow_l.w/2+5,   border.h - 5 - arrow_up.h/2}
                arrow_r.position  = {border.w-arrow_r.w/2*3/2-5,   border.h - 5 - arrow_up.h/2}
                grip_hor_base_x = arrow_l.x + arrow_l.w+5
                grip_vert_base_y =  arrow_up.y+arrow_up.h+5
                grip_vert.position = {border.w-arrow_up.w-5,grip_vert_base_y}
                grip_hor.position = {grip_hor_base_x,border.h-5- arrow_up.h}
            else
                arrow_up.position = {border.w+arrow_up.w/2+5,arrow_up.h/2}
                arrow_dn.position = {border.w+arrow_dn.w/2+5,border.h-arrow_dn.h/2}
                arrow_l.position  = {         arrow_l.w/2,   border.h + 5 + arrow_up.h/2}
                arrow_r.position  = {border.w-arrow_r.w/2,   border.h + 5 + arrow_up.h/2}
                grip_vert.position = {border.w+5,grip_vert_base_y}
                grip_hor.position = {grip_hor_base_x,border.h+5}
            end
        end
        
        if p.content_w <= p.clip_w then
            arrow_r.opacity=0
            arrow_l.opacity=0
            grip_hor.opacity=0
        end
        
        if p.content_h <= p.clip_h then
            arrow_up.opacity=0
            arrow_dn.opacity=0
            grip_vert.opacity=0
        end
    end
    
    create()
    scroll_group:add(border,grip_hor,grip_vert,window)
    window:add(content)
    
    
    function grip_vert:on_button_down(x,y,button,num_clicks)
        
        dragging = {grip_vert, x - grip_vert.x, y - grip_vert.y }

        return true
    end 
---[[
    function grip_vert:on_button_up(x,y,button,num_clicks)
         if(dragging ~= nil) then 
              local actor , old_x , old_y = unpack( dragging )
            local dif
            
            grip_vert.y = y-old_y
            
            if grip_vert.y > grip_vert_base_y+(track_h-grip_h) then
                grip_vert.y = grip_vert_base_y+(track_h-grip_h)
            elseif grip_vert.y < grip_vert_base_y then
                grip_vert.y = grip_vert_base_y
            end
            
            content.y = -(grip_vert.y - grip_vert_base_y) * p.content_h/track_h 
            

              dragging = nil
         end 
        return true
    end
    --]]
    
    mt = {}
    mt.__newindex = function(t,k,v)
        
       p[k] = v
       create()
        
    end
    mt.__index = function(t,k)       
       return p[k]
    end
    setmetatable(scroll_group.extra, mt)
    return scroll_group
end

aaa = widget.scrollWindow()
screen:add(aaa)

function screen:on_motion(x,y)
    local actor, dx, dy = unpack(dragging)
                actor.x =  x - dx 
                actor.y =  y - dy
end
--]]

