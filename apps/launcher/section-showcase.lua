
return
function( section )
    
    local ui = section.ui

    function section.on_enter( section )
    end
    
    local r = nil
    
    function section.on_default_action( section )
    
--[[    
        function section.on_show( section )
        
            if not r then
            
                local cr = ui:get_client_rect()
                r = Rectangle
                {
                    color = "99999955",
                    size = { cr.w , cr.h },
                    position = { cr.x , cr.y },
                }
                screen:add( r )
            end

            r.opacity = 255            
            r:raise_to_top()
            r:grab_key_focus()
            
            function r.on_key_down(r,k)
                if k == keys.Up then
                    ui:on_exit_section()
                end
            end
        end
        
        function section.on_hide( section )
            
            if r then
                r.opacity = 0
            end
        
        end
        
        ui:on_section_full_screen( section )
        
        return true
]]
        
        
    end

end