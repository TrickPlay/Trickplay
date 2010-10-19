
-- This gets called once - when the section is about to be shown for
-- the first time.

return
function( section )

--    dofile("editor.lua")

    local ui = section.ui
    local assets = ui.assets
    local factory = ui.factory

    ---------------------------------------------------------------------------

    local TOP_APP_COUNT = 3
    
    
    -- The list of focusable items in the dropdown        
        
    local section_items = {}
    
        
    ---------------------------------------------------------------------------
    -- Build the initial UI for the section
    ---------------------------------------------------------------------------
     local dropdown_map =
     {
	["Transparency Grid 20"]   = function() BG_IMAGE:set{src = "transparency-grid-20.png", opacity = 255} end,
	["Transparency Grid 40"]   = function() BG_IMAGE:set{src = "transparency-grid-40.png", opacity = 255} end,
	["Transparency Grid 80"]   = function() BG_IMAGE:set{src = "transparency-grid-80.png", opacity = 255} end,
        ["White"]   = function() BG_IMAGE:set{src = "white.png", opacity = 255} end,
        ["Black"]   = function() BG_IMAGE:set{opacity = 0} end
     }
    local function build_dropdown_ui()
    
        local group = section.dropdown
        
        local TOP_PADDING = 48
        local BOTTOM_PADDING = 12
        
        local space = group.h - ( TOP_PADDING + BOTTOM_PADDING )
        local items_height = 0
    
    
        --local all_apps = factory.make_text_menu_item( assets , ui.strings[ "View All My Apps" ] )
        local f_tp_20  = factory.make_text_menu_item( assets , ui.strings[ "Transparency Grid 20" ] )
        local f_tp_40  = factory.make_text_menu_item( assets , ui.strings[ "Transparency Grid 40" ] )
        local f_tp_80  = factory.make_text_menu_item( assets , ui.strings[ "Transparency Grid 80" ] )
        local f_white  = factory.make_text_menu_item( assets , ui.strings[ "White" ] )
        local f_black  = factory.make_text_menu_item( assets , ui.strings[ "Black" ] )
        
        --local categories = factory.make_text_side_selector( assets , ui.strings[ "Recently Used" ] )
    
        table.insert( section_items , f_tp_20)
        table.insert( section_items , f_tp_40)
        table.insert( section_items , f_tp_80)
        table.insert( section_items , f_white)
        table.insert( section_items , f_black)

	for _,item in ipairs( section_items ) do
	     item.reactive = true
             function item:on_button_down(x,y,button,num_clicks)
        	if item.on_activate then
	    		item:on_focus_out()
            		animate_out_dropdown()
            		item:on_activate()
            		screen.grab_key_focus(screen)
			
        	end
		return true 
	     end
             if item:find_child("caption") then
                local dropmenu_item = item:find_child("caption")
                dropmenu_item.reactive = true
                function dropmenu_item:on_button_down(x,y,button,num_clicks)
            		animate_out_dropdown()
            		screen.grab_key_focus(screen)
                        if(dropdown_map[dropmenu_item.text]) then dropdown_map[dropmenu_item.text]() end
                        return true
                end
             end
       end

        items_height = items_height + f_tp_20.h + f_tp_40.h + f_tp_80.h + f_white.h + f_black.h
        
        f_tp_20.extra.on_activate =
            function()
		BG_IMAGE:set{src = "transparency-grid-20.png", opacity = 255}
                screen.grab_key_focus(screen)
            end
        f_tp_40.extra.on_activate =
            function()
		BG_IMAGE:set{src = "transparency-grid-40.png", opacity = 255}
                screen.grab_key_focus(screen)
            end
        f_tp_80.extra.on_activate =
            function()
		BG_IMAGE:set{src = "transparency-grid-80.png", opacity = 255}
                screen.grab_key_focus(screen)
            end
        f_black.extra.on_activate =
            function()
		BG_IMAGE:set{opacity = 0}
                screen.grab_key_focus(screen)
            end
        f_white.extra.on_activate =
            function()
		BG_IMAGE:set{src = "white.png", opacity = 255}
                screen.grab_key_focus(screen)
            end
        
        -- This spaces all items equally.
        -- TODO: If there are less than 3 app tiles, it will be wrong.
        
        local margin = ( space - items_height ) / ( # section_items - 1 )
        
        local y = TOP_PADDING
        
        for _ , item in ipairs( section_items ) do
        
            item.x = ( group.w - item.w ) / 2
            item.y = y
            
            y = y + item.h - 5.45			-- margin
            
            group:add( item )
            
        end
        
    end
    
    ---------------------------------------------------------------------------
    -- Called each time the drop down is about to be shown
    ---------------------------------------------------------------------------

    function section.on_show( section )
    end
    
    ---------------------------------------------------------------------------
    
    local function move_focus( delta )
    
        local unfocus = section_items[ section.focus ]
        local focus = section_items[ section.focus + delta ]
        
        if not focus then
            if section.focus + delta == 0 then
                if unfocus then
                    unfocus:on_focus_out()
                end
                ui:on_exit_section()
            end
            return
        end
        
        if unfocus then
            unfocus:on_focus_out()
        end
        
        section.focus = section.focus + delta
    
        focus:on_focus_in()
        
    end
    
    local function activate_focused()
    
        local focused = section_items[ section.focus ]
        
        if focused and focused.on_activate then
	    focused:on_focus_out()
            animate_out_dropdown()
            focused:on_activate()
        end
    
    end
    
    
    local key_map =
    {
        [ keys.Up     ] = function() move_focus( -1 ) end,
        [ keys.Down   ] = function() move_focus( 1  ) end,
        [ keys.Return ] = activate_focused,
    }

    ---------------------------------------------------------------------------
    -- Called when the section is entered, by pressing down from the
    -- main menu bar
    ---------------------------------------------------------------------------
    
    function section.on_enter( section )
    
        section.focus = 0
        
        move_focus( 1 )
        
        section.dropdown:grab_key_focus()
        
        section.dropdown.on_key_down =
        
            function( section , key )
                local f = key_map[ key ]
                if f then
                    f()
                end
		return true -- hjk
            end
    
        return true
    end

    ---------------------------------------------------------------------------
    -- Called when the user presses enter on this section's menu button
    ---------------------------------------------------------------------------
    
    function section.on_default_action( section )
    
        
        return true
    
    end
    
    
    build_dropdown_ui()
end
