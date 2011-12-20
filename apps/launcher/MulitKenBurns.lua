local mkb = {}


local hl_stop = 169

local text_x = 28

local text_y_off = 206

local has_been_initialized = false

local rule_h = 3


local img_srcs, caption_grad

function mkb:init(p)
    
    assert(not has_been_initialized)
    
    if type(p) ~= "table" then error("must pass a table",2) end
    
    img_srcs = p.img_srcs or error("must pass img_srcs")
    
    
    caption_grad = Image{src = "assets/lower-gradient.png"}
    
    img_srcs:add(caption_grad)
    
    has_been_initialized = true
end


function mkb:create(p)
    
    local instance = p.group or Group{}
    
    instance.x = 3
    
    local kb_s = {}
    assert(has_been_initialized)
    
    if type(p) ~= "table" then error("must pass a table",2) end
    
    local curr_y = 0
    
    local kb = p.kb or error("must pass 'kb'",2)
    
    for i,v in ipairs(p.panes or error("must pass 'panes'",2)) do
        
        p.srcs:add(unpack(v.imgs))
        
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
        
        v.text.x = text_x
        
        v.text.y = curr_y + text_y_off
        
        curr_y = curr_y + v.h
        
        instance:add( kb_s[i], Clone{source =caption_grad, y = curr_y - caption_grad.h} , v.text )
        
        if i < #p.panes then
            
            instance:add(Rectangle{y=curr_y,w = p.w,h = rule_h, color = "ffffff"})
            
            curr_y = curr_y + rule_h
            
        end
        
    end
    
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
            
            y        = kb_s[index].y + text_y_off + 23 ,
            
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
        [keys.OK] = function(instance)
            
            p.hl:show_sub_menu()
            --apps:launch(kb_s[index].app_id)
            
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