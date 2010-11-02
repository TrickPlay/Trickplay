
-- This gets called once - when the section is about to be shown for
-- the first time.

return
function( section )

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
	["LEFT SIDE      "]   = function() editor.left() input_mode = S_SELECT end,
        ["RIGHT SIDE    "]   = function() editor.right() input_mode = S_SELECT end,
        ["TOP             "]= function() editor.top() input_mode = S_SELECT end,
        ["BOTTOM        "] = function() editor.bottom() input_mode = S_SELECT end,
        ["HORIZ. CENTER   "] = function() editor.hcenter() input_mode = S_SELECT end,
        ["VERT. CENTER    "] = function() editor.vcenter() input_mode = S_SELECT end,
        ["HORIZONTALLY	  "] = function() editor.hspace() input_mode = S_SELECT end,
        ["VERTICALLY 	  "] = function() editor.vspace() input_mode = S_SELECT end,
        ["BRING TO FRONT"] = function() editor.bring_to_front() input_mode = S_SELECT end,
        ["BRING FORWARD "] = function() editor.bring_forward() input_mode = S_SELECT end,
        ["SEND TO BACK "] = function() editor.send_to_back() input_mode = S_SELECT end,
        ["SEND BACKWARD "] = function() editor.send_backward() input_mode = S_SELECT end
     }
    local function build_dropdown_ui()
    
        local group = section.dropdown
        
        local TOP_PADDING = 48
        local BOTTOM_PADDING = 12
        
        local space = group.h - ( TOP_PADDING + BOTTOM_PADDING )
        local items_height = 0
    
    
        --local all_apps = factory.make_text_menu_item( assets , ui.strings[ "View All My Apps" ] )
        local f_left  = factory.make_text_menu_item( assets , ui.strings[ "LEFT SIDE      " ] )
        local f_right  = factory.make_text_menu_item( assets , ui.strings[ "RIGHT SIDE    " ] )
        local f_top  = factory.make_text_menu_item( assets , ui.strings[ "TOP             " ] )
        local f_bottom = factory.make_text_menu_item( assets , ui.strings[ "BOTTOM        " ] )
        local f_hcenter  = factory.make_text_menu_item( assets , ui.strings[ "HORIZ. CENTER   " ] )
        local f_vcenter = factory.make_text_menu_item( assets , ui.strings[ "VERT. CENTER    " ] )
        local f_hspace = factory.make_text_menu_item( assets , ui.strings[ "HORIZONTALLY	  " ] )
        local f_vspace = factory.make_text_menu_item( assets , ui.strings[ "VERTICALLY 	  " ] )
        local f_bring_to_front  = factory.make_text_menu_item( assets , ui.strings[ "BRING TO FRONT" ] )
        local f_bring_forward = factory.make_text_menu_item( assets , ui.strings[ "BRING FORWARD "] )
        local f_send_to_back = factory.make_text_menu_item( assets , ui.strings[ "SEND TO BACK " ] )
        local f_send_backward = factory.make_text_menu_item( assets , ui.strings[ "SEND BACKWARD " ] )
        
        --local categories = factory.make_text_side_selector( assets , ui.strings[ "Recently Used" ] )
    
        table.insert( section_items , f_left )
        table.insert( section_items , f_right )
        table.insert( section_items , f_top )
        table.insert( section_items , f_bottom )
        table.insert( section_items , f_hcenter )
        table.insert( section_items , f_vcenter )
        table.insert( section_items , f_hspace )
        table.insert( section_items , f_vspace )
        table.insert( section_items , f_bring_to_front )
        table.insert( section_items , f_bring_forward )
        table.insert( section_items , f_send_to_back )
        table.insert( section_items , f_send_backward )
        
	for _,item in ipairs( section_items ) do
	     item.reactive = true
             function item:on_button_down(x,y,button,num_clicks)
        	if item.on_activate then
	    		item:on_focus_out()
            		animate_out_dropdown()
            		item:on_activate()
            		-- screen.grab_key_focus(screen) 1101 
			
        	end
		--return true  1101 
	     end
             if item:find_child("caption") then
                local dropmenu_item = item:find_child("caption")
                --dropmenu_item.reactive = true
                function dropmenu_item:on_button_down(x,y,button,num_clicks)
		        local s= ui.sections[ui.focus]
        		ui.button_focus.position = s.button.position
        		ui.button_focus.opacity = 0
            		animate_out_dropdown()
                        if(dropdown_map[dropmenu_item.text]) then dropdown_map[dropmenu_item.text]() end
                        return true
            		--screen.grab_key_focus(screen)
                end
             end
       end

        items_height = items_height + f_left.h + f_right.h + f_top.h + f_bottom.h + f_hcenter.h + 
		       f_vcenter.h + f_hspace.h + f_vspace.h + f_bring_to_front.h + f_bring_forward.h + 
		       f_send_to_back.h + f_send_backward.h
        
        f_left.extra.on_activate =
            function()
		input_mode = S_SELECT
		editor.left()
            end
        
        f_right.extra.on_activate =
            function()
		input_mode = S_SELECT
		editor.right()
            end

        f_top.extra.on_activate =
            function()
		input_mode = S_SELECT
		editor.top()
            end

        f_bottom.extra.on_activate =
            function()
		input_mode = S_SELECT
		editor.bottom()
            end

        f_hcenter.extra.on_activate =
            function()
		input_mode = S_SELECT
		editor.hcenter()
            end

        f_vcenter.extra.on_activate =
            function()
		input_mode = S_SELECT
		editor.vcenter()
            end

        f_hspace.extra.on_activate =
            function()
		input_mode = S_SELECT
		editor.hspace()
            end

        f_vspace.extra.on_activate =
            function()
		input_mode = S_SELECT
		editor.vspace()
            end

        f_bring_to_front.extra.on_activate =
            function()
		input_mode = S_SELECT
		editor.bring_to_front()
            end

        f_bring_forward.extra.on_activate =
            function()
		input_mode = S_SELECT
		editor.bring_forward()
            end

        f_send_to_back.extra.on_activate =
            function()
		input_mode = S_SELECT
		editor.send_to_back()
            end

        f_send_backward.extra.on_activate =
            function()
		input_mode = S_SELECT
		editor.send_backward()
            end

        -- This spaces all items equally.
        -- TODO: If there are less than 3 app tiles, it will be wrong.
        
        local margin = ( space - items_height ) / ( # section_items - 1 )
        
        local y = TOP_PADDING
        
        for _ , item in ipairs( section_items ) do
        
            item.x = ( group.w - item.w ) / 2
            item.y = y
            
            y = y + item.h - 5.45			
            
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
