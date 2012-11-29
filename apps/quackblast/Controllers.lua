--local sensitivity = 1 -- used to determine how fast a swipe on the iphone moves the cursor
local cursor_class
local has_been_initialized = false

local external_devices = {}
function external_devices:init(t)
    
    if has_been_initialized then error("Already initialized",2) end
    
    has_been_initialized = true
    
    if type(t) ~= "table" then error("Parameter must be a table",2) end
    
    cursor_class = t.cursor or error("must pass cursor",2)
    
end



function external_devices:start()
    
    if not has_been_initialized then error("Must initialize",2) end
    
    function controllers:on_controller_connected( c )
        
        --print("CONTROLLER ADDED")
        
        if c.has_pointer then
            
            --print("new controller has pointer")
            
            local cursor = cursor_class:make_cursor()
            
            function c:on_pointer_button_down()   cursor:highlight()     end
            function c:on_pointer_button_up()     cursor:unhighlight()   end
            
            function c:on_pointer_move(x,y)
                
                cursor.x = x
                cursor.y = y
                
            end
            
            c:start_pointer()
            
        --[[code that might be used for the iphone
        
        elseif c.has_touches then
            
            local ui_w, ui_h = unpack(c.ui_size)
            
            if ui_w == 435 then
                c:declare_resource("splash","iphone_assets/ipod-start.png")
                
                --print("Connected IPOD")
            elseif ui_w == 640 then
                c:declare_resource("splash","iphone_assets/iphone-start.png")
                
                --print("Connected IPHONE")
            else
                c:declare_resource("splash","iphone_assets/ipad-start.png")
                
                --print("Connected IPAD")
            end
            
            controller:set_ui_background("splash","STRETCH")
            
            
            local touch_down
            function c:on_touch_up(f,x,y)
                if touch_down + 500 > os.time() then
                    cursor:fire()
                end
            end
            function c:on_touch_down(f,x,y)
                touch_down = os.time()
            end
            function c:on_touch_move(f,x,y)
                
                cursor:move_by(
                    (x - ui_w/2) * sensitivity,
                    (y - ui_h/2) * sensitivity
                )
                
                if     cursor.x <        0 then cursor.x = 0
                elseif cursor.x > screen_w then cursor.x = screen_w end
                
                if     cursor.y <        0 then cursor.y = 0
                elseif cursor.y > screen_h then cursor.y = screen_h end
                
            end
            
            c:start_touches()
            --]]
        end
    end
    
    
    for _,controller in pairs(controllers.connected) do
        controllers:on_controller_connected( controller )
    end
    
end

return external_devices
