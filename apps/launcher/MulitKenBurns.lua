local mkb = {}


local hl_stop = 169

local text_x = 28

local text_y_off = 206

local rule_h = 3


local caption_grad, overlay, title_font, caption_font, kb

local function make_text(title,caption)
    
    local title = Text{
        text = title,
        font = title_font
    }
    local caption = Text{
        text = caption,
        font = caption_font
    }
    
    local c = Canvas(
        title.w > caption.w and title.w or caption.w,
        title.h + caption.h
    )
    
    c:text_element_path(title)
    
    c:set_source_color("000000")
    c:stroke(true)
    c:set_source_color("ffffff")
    c:fill()
    
    c:move_to(0,title.h)
    
    c:text_element_path(caption)
    
    c:set_source_color("000000")
    c:stroke(true)
    c:set_source_color("ffffff")
    c:fill()
    
    
    return c:Image()
end

local has_been_initialized = false

    
--------------------------------------------------------------------------------
-- Init the Class
--------------------------------------------------------------------------------
function mkb:init(p)
    
    assert(not has_been_initialized)
    
    if type(p) ~= "table" then error("must pass a table",2) end
    
    overlay      = p.overlay_src  or error("must pass 'overlay_src'",  2)
    caption_grad = p.gradient_src or error("must pass 'gradient_src'", 2)
    title_font   = p.title_font   or error("must pass 'title_font'",   2)
    caption_font = p.caption_font or error("must pass 'caption_font'", 2)
    kb           = p.ken_burns    or error("must pass 'ken_burns'",     2)
    
    
    has_been_initialized = true
    
end

    
--------------------------------------------------------------------------------
-- The Object Constructor
--------------------------------------------------------------------------------

function mkb:create(p)
    
    assert(has_been_initialized)
    
    if type(p) ~= "table" then error("must pass a table",2) end
    
    local instance = p.group or Group{}
    instance.name = "Multi Ken Burns"
    instance.x = 8
    
    local kb_s = {}
    
    local curr_y = 0
    
    
    local hl_y_off = {}
    for i,v in ipairs(p.panes or error("must pass 'panes'",2)) do
        
        kb_s[i] = kb:create{
            visible_w = p.w or error("must pass 'w'",2),
            visible_h = v.h,
            q = v.imgs,
        }
        
        kb_s[i].title   = v.title
        kb_s[i].caption = v.caption
        
        kb_s[i]:pause()
        
        kb_s[i].app_id = v.app_id
        
        kb_s[i].y = curr_y
        
        local text = make_text(v.title,v.caption)
        
        text.x = text_x
        
        text.y = curr_y + text_y_off
        
        curr_y = curr_y + v.h
        
        instance:add( kb_s[i], Clone{source =overlay, y = curr_y - v.h}, Clone{source =caption_grad, y = curr_y - caption_grad.h} , text )
        
        if i < #p.panes then
            
            instance:add(Rectangle{y=curr_y,w = p.w,h = rule_h, color = "ffffff"})
            
            curr_y = curr_y + rule_h
            
        end
        
        hl_y_off[i] = 23
        
    end
    
    hl_y_off[#hl_y_off] = 11
    
    local animating = false
    
    local index = 1
    
    function instance:focus()
        
        if index ~= 1 then
            kb_s[index]:play()
            kb_s[1]:pause()
        end
        
    end
    
    function instance:unfocus()
        
        if index ~= 1 then
            kb_s[index]:pause()
            kb_s[1]:play()
        end
        
    end
    kb_s[1]:play()
    
    local function update_hl()
        
        p.hl:focus(kb_s[index].title,kb_s[index].caption,kb_s[index].app_id)
        p.hl:animate{
            
            duration = 300,
            
            y        = kb_s[index].y + text_y_off + hl_y_off[index] ,
            
            on_completed = function()  animating = false  end
            
        }
        
    end
    
    p.hl.opacity = 0
    update_hl()
    
    local key_events = {
        [keys.Up] = function(instance)
            
            if index == 1 then
                
                return false
                
            else
                
                kb_s[index]:pause()
                index = index - 1
                kb_s[index]:play()
                
                update_hl()
                
                return true
                
            end
            
        end,
        [keys.Down] = function(instance)
            
            if index == #kb_s then
                
                return false
                
            else
                kb_s[index]:pause()
                index = index + 1
                kb_s[index]:play()
                update_hl()
                
                return true
                
            end
            
        end,
        [keys.YELLOW] = function(instance)
            
            p.hl:show_sub_menu()
            --apps:launch(kb_s[index].app_id)
            
            return true
            
        end,
        [keys.OK] = function(instance)
            
            apps:launch(kb_s[index].app_id)
            
            return true
            
        end,
    }
    
    function instance:on_key_down(k)
        
        return not animating and key_events[k] and key_events[k](instance)
        
    end
    
    has_been_initialized = true
    
    return instance
    
end

return mkb