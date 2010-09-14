
return
function( ui )

    local section   = {}
    
    local assets    = ui.assets
    
    local factory   = ui.factory
    
    
    
    local group = nil
    
    local function build_ui()
    
        if group then
            group:raise_to_top()
            group:grab_key_focus()
            group.opacity = 255
            return
        end
        
        local client_rect = ui:get_client_rect()
        
        group = Group
        {
            size = { client_rect.w , client_rect.h } ,
            position = { client_rect.x , client_rect.y },
            clip = { 0 , 0 , client_rect.w , client_rect.h },
            children =
            {
                Rectangle{ color = "00FF0088" , size = { client_rect.w , client_rect.h } }
            }
        }
        
        screen:add( group )
        
        group:raise_to_top()
        
        -- Prevent keys from going to the menu while we are animating
        
        group:grab_key_focus()
        
    end
    
    
    function section.on_show( section )
    
        build_ui()
        
        function group.on_key_down( group , key )
            
            print( "SHOP FS" , "KEY" , key )
            
            if key == keys.Up then
            
                ui:on_exit_section()  
            
            end
        
        end
            
    end
    
    function section.on_enter( section )
    
        group:grab_key_focus()
        
        return true
        
    end
    
    function section.on_default_action( section )
    
        ui:on_section_full_screen( section )
        
        return true
    
    end

    function section.on_hide( section )
        
        if group then
            group.opacity = 0
        end
        
    end
    
    ---------------------------------------------------------------------------

    return section
        
end