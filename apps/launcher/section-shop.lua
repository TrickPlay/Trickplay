
return
function( section )

    local ui = section.ui

    function section.on_enter()
        -- grab key focus
        -- return true
    end
    
    function section.on_default_action()
        ui:on_exit_section( section )
        local fs_shop = dofile( "fs-shop" )( ui )
        ui:on_section_full_screen( fs_shop )
        return true
    end

end