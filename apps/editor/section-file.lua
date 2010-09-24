
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
    
    --local profile_apps = apps:get_for_current_profile()
    
    -- Take myself out
    
    --profile_apps[ app.id ] = nil

    -- The list of focusable items in the dropdown        
        
    local section_items = {}
    
    ---------------------------------------------------------------------------
    -- Build the initial UI for the section
    ---------------------------------------------------------------------------

local dropdown_map =
{
     ["NEW                [N] "]   = function() Editor().close() mouse_mode = S_SELECT end,
     ["OPEN               [O] "]   = function() Editor().open() mouse_mode = S_SELECT end,
     ["SAVE               [S] "]   = function() Editor().save() mouse_mode = S_SELECT end,
     ["QUIT               [Q] "]   = function() exit() end,
     ["VIEW CODES   [V]"]          = function() Editor().view_codes() mouse_mode = S_SELECT end
}

    local function build_dropdown_ui()
    
        local group = section.dropdown
        
        local TOP_PADDING = 48
        local BOTTOM_PADDING = 12
        
        local space = group.h - ( TOP_PADDING + BOTTOM_PADDING )
        local items_height = 0
    
        --local all_apps = factory.make_text_menu_item( assets , ui.strings[ "View All My Apps" ] )
        local f_new  = factory.make_text_menu_item( assets , ui.strings[ "NEW                [N] " ] )
        local f_open = factory.make_text_menu_item( assets , ui.strings[ "OPEN               [O] " ] )
        local f_save = factory.make_text_menu_item( assets , ui.strings[ "SAVE               [S] " ] )
        local f_quit = factory.make_text_menu_item( assets , ui.strings[ "QUIT               [Q] " ] )
        local f_view = factory.make_text_menu_item( assets , ui.strings[ "VIEW CODES   [V]" ] )
        
        --local categories = factory.make_text_side_selector( assets , ui.strings[ "Recently Used" ] )
    
        table.insert( section_items , f_new )
        table.insert( section_items , f_open)
        table.insert( section_items , f_save )
        table.insert( section_items , f_view )
        table.insert( section_items , f_quit )
        
        for _,item in ipairs( section_items ) do
             function item:on_button_down(x,y,button,num_clicks)
        	  if (item.on_activate) then
	    		item:on_focus_out()
	    		animate_out_dropdown()
            		item:on_activate()
        	  end
	     end 
--[[ 
	     if item:find_child("caption") then
		local dropmenu_item = item:find_child("caption") 
		--dropmenu_item.reactive = true
    		function dropmenu_item:on_button_down(x,y,button,num_clicks)
         		animate_out_dropdown()
         		if(dropdown_map[dropmenu_item.text]) then dropdown_map[dropmenu_item.text]() end 
        		return true
		end 
	     end 
]]
       end

        -- table.insert( section_items , categories )
        
        --items_height = items_height + f_new.h + categories.h
        items_height = items_height + f_new.h + f_open.h + f_save.h + f_view.h + f_quit.h 
        
        f_new.extra.on_activate =
            function()
	    	Editor().close() 
		mouse_mode = S_SELECT
            end
        
        f_open.extra.on_activate =
            function()
		Editor().open()
		mouse_mode = S_SELECT
            end
        
        f_save.extra.on_activate =
            function()
		Editor().save()
		mouse_mode = S_SELECT
            end
        
        f_view.extra.on_activate =
            function()
		Editor().view_codes()
		mouse_mode = S_SELECT
            end
        
        f_quit.extra.on_activate =
            function()
		exit()
            end
        

        -- This spaces all items equally.
        -- TODO: If there are less than 3 app tiles, it will be wrong.
        
        local margin = ( space - items_height ) / ( # section_items - 1 )
        
        local y = TOP_PADDING
        
        for _ , item in ipairs( section_items ) do
        
            item.x = ( group.w - item.w ) / 2
            item.y = y
            
            y = y + item.h + margin
            
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
	print("unfocus : ") print(section.focus)
        
        local focus = section_items[ section.focus + delta ]
	print("focus : ") print(section.focus + delta)
        
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
	    -- return true 
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
                return true --hjk 
            end
    
        return true
    end

    ---------------------------------------------------------------------------
    -- Called when the user presses enter on this section's menu button
    ---------------------------------------------------------------------------
    
    function section.on_default_action( section )
    
        -- hjk : menu 에서 리턴 눌렸을 때 그 항목 중 디폴트 처리 할 기능
        
        return true
    
    end
    
    
    build_dropdown_ui()
end
