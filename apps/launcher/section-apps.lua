
-- This gets called once - when the section is about to be shown for
-- the first time.

return
function( section , ui )

    local TOP_APP_COUNT = 3
    
    section.app_icons = {}
    
    section.top_apps = settings.top_apps or {}
    
    section.all_apps = apps:get_for_current_profile()
    
    section.icon_overlay_w_label = Image { src = "assets/icon-overlay-white-text-label.png" }
        
    section.icon_overlay_b_label = Image { src = "assets/icon-overlay-black-text-label.png" }
    
    screen:add( section.icon_overlay_w_label:set{ opacity = 0 } , section.icon_overlay_b_label:set{ opacity = 0 } )
    
    section.text_focus = Clone{ source = ui.button_focus , opacity = 0 }
    
    section.app_focus = Image{ src = "assets/app-icon-focus.png" , opacity = 0 }
    section.app_focus.anchor_point = section.app_focus.center
    
    section.dropdown:add( section.text_focus , section.app_focus )
    
    section.focus_functions = {}
    
    section.unfocus_functions = {}
    
    ---------------------------------------------------------------------------

    local function is_top_app( app_id )
        for _ , top in ipairs( section.top_apps ) do
            if app_id == top then
                return true
            end
        end
        return false
    end
    
    ---------------------------------------------------------------------------
    -- Make sure that there are TOP_APP_COUNT apps in section.top_apps, that
    -- they are all valid and that they all have icons.
    ---------------------------------------------------------------------------
    
    local function validate_top_apps()
    
        -- Load the apps and the most used apps
    
        local top_apps = section.top_apps
    
        section.top_apps = {}
    
        -- Look for each top app in all_apps and, if it is there, add it to
        -- section.top_apps until we have TOP_APP_COUNT.
        
        -- This ensures that the ids we have saved previously in top apps still
        -- exist.
        
        for _ , app_id in ipairs( top_apps ) do
            if section.all_apps[ app_id ] then
                table.insert( section.top_apps , app_id )
                if # section.top_apps == TOP_APP_COUNT then
                    break
                end
            end
        end

        -- If ui.top_apps has less than TOP_APP_COUNT, then add some from all_apps.
        -- In a cold start, top apps will be empty - this fills it. 
        
        if # section.top_apps < TOP_APP_COUNT then
            for app_id , app in pairs( section.all_apps ) do
                if not is_top_app( app_id ) then
                    table.insert( section.top_apps , app_id )
                    if # section.top_apps == TOP_APP_COUNT then
                        break
                    end
                end
            end
        end
    
        -- Make sure that the app icons for all the top apps are available
        -- in section.app_icons 
        
        for _ , app_id in ipairs( section.top_apps ) do
            if not section.app_icons[ app_id ] then

                local icon = Image()
                
                -- If we cannot load the app icon, we use the generic one
                
                if not icon:load_app_icon( app_id , "launcher-icon.png" ) then
                    if not section.generic_app_icon then
                        section.generic_app_icon = Image{ src = "assets/generic-app-icon.png" , opacity = 0 }
                        screen:add( section.generic_app_icon )
                    end                    
                    icon = Clone{ source = section.generic_app_icon , opacity = 255 }                
                end
                
                -- Now we have either the icon or a clone of the generic icon
            
                section.app_icons[ app_id ] = icon
            
            end
            
        end
        
    end

    ---------------------------------------------------------------------------
    -- Build the initial UI for the section
    ---------------------------------------------------------------------------
    
    local SELECTED   = 1
    local UNSELECTED = 2
    
    local MENU_ITEM_TEXT_STYLE =
    {
        [SELECTED]   = { font = "DejaVu Sans 26px", color = "FFFFFFFF" },
        [UNSELECTED] = { font = "DejaVu Sans 26px", color = "FFFFFFFF" },
    }
    
    local APP_LABEL_TEXT_STYLE =
    {
        [SELECTED]   = { font = "DejaVu Sans 24px" , color = "FFFFFFFF" },
        [UNSELECTED] = { font = "DejaVu Sans 24px" , color = "000000FF" },
    }

    local MENU_ITEM_HEIGHT  = 36    -- The height of each text menu item
    local TOP_PADDING       = 26    -- The vertical distance from the point of the dropdown to the first text menu item
    local MENU_ITEM_PADDING = 32    -- Vertical space between text menu items
    local APP_ITEM_PADDING  = 28    -- Vertical space between app items
    local BOT_PADDING       = 0     -- Vertical padding at the bottom of the dropdown
    local HORIZ_PADDING     = 26    -- Horizontal space from left of dropdown
    
    local group = section.dropdown
        
    ---------------------------------------------------------------------------
    -- The 'all apps' menu item and its ring
    ---------------------------------------------------------------------------
    
    local RING_WIDTH    = group.w - ( HORIZ_PADDING * 2 ) - 10
    local RING_HEIGHT   = MENU_ITEM_HEIGHT + 14
    local RING_BORDER_W = 2
    local RING_COLOR    = "FFFFFF"
    local RING_INSET    = 3
    local RING_RADIUS   = 12
    
    local ring = Canvas{ name = "all-apps-ring" , size = { RING_WIDTH , RING_HEIGHT } }
    
    ring:begin_painting()
    ring:set_line_width( RING_BORDER_W )
    ring:set_source_color( RING_COLOR )
    ring:round_rectangle( RING_INSET , RING_INSET , RING_WIDTH - ( RING_INSET * 2 ) , RING_HEIGHT - ( RING_INSET * 2 ) , RING_RADIUS )
    ring:stroke()
    ring:finish_painting()
    
    local all_apps_text = Text
    {
        name = "all-apps",
        text = section.ui.strings[ "View All My Apps" ],
        position = { 0 , TOP_PADDING + MENU_ITEM_PADDING }
    }
    
    all_apps_text:set( MENU_ITEM_TEXT_STYLE[ UNSELECTED ] )
    
    all_apps_text.x = group.w / 2 - all_apps_text.w / 2
    

    ring.anchor_point = ring.center
    ring.position = all_apps_text.center
       
    group:add( ring , all_apps_text )
    
    ---------------------------------------------------------------------------
    -- Put the text focus ring in place
    ---------------------------------------------------------------------------
    
    section.text_focus:set
    {
        name = "text-focus",
        size = { RING_WIDTH + 7 , RING_HEIGHT + 7 }
    }

    section.text_focus.anchor_point = section.text_focus.center
    
    -- This function will put the focus on the all apps text box

    section.focus_functions[ 1 ] =
    
        function()
    
            section.app_focus.opacity = 0

            section.text_focus.opacity = 255
            section.text_focus.position = { ring.x - 1 , ring.y }    
            section.text_focus:lower( all_apps_text )
            section.text_focus.w = RING_WIDTH + 7
        
        end
        
    
    ---------------------------------------------------------------------------
    -- The 'category' menu item and its arrows
    ---------------------------------------------------------------------------
    
    local ARROW_WIDTH   = MENU_ITEM_HEIGHT / 4 
    local ARROW_HEIGHT  = MENU_ITEM_HEIGHT / 2
    local ARROW_COLOR   = "FFFFFF"
    
    local arrow = Canvas{ name = "left-arrow" , size = { ARROW_WIDTH , ARROW_HEIGHT } }
    
    arrow:begin_painting()
    arrow:move_to( 0 , arrow.h / 2 )
    arrow:line_to( arrow.w , 0 )
    arrow:line_to( arrow.w , arrow.h )
    arrow:set_source_color( ARROW_COLOR )
    arrow:fill()
    arrow:finish_painting()
    
    local category_text = Text
    {
        text = section.ui.strings[ "Recently Used" ],
        position = { 0 , all_apps_text.y + all_apps_text.h + MENU_ITEM_PADDING }
    }
    
    category_text:set( MENU_ITEM_TEXT_STYLE[ UNSELECTED ] )
    
    category_text.x = group.w / 2 - category_text.w / 2
    
    arrow.anchor_point = arrow.center
    
    arrow.position = { HORIZ_PADDING + arrow.w * 2  , category_text.center[ 2 ] }
    
    local r_arrow = Clone{ name = "right-arrow" , source = arrow }
    
    r_arrow.anchor_point = r_arrow.center
    
    r_arrow:set
    {
        z_rotation = { 180 , 0 , 0 },
        position = { group.w - ( HORIZ_PADDING + arrow.w * 2 ) , category_text.center[ 2 ] }
    }
    
    arrow.opacity = 50
    r_arrow.opacity = 50
    category_text.opacity = 50
    
    group:add( arrow , r_arrow , category_text )
    
    -- Function to focus the category item        
        
    section.focus_functions[ 2 ] =
    
        function()
        
            section.app_focus.opacity = 0
    
            section.text_focus.opacity = 255
            section.text_focus.position = { ring.x - 1 + 34, ring.y + MENU_ITEM_HEIGHT + MENU_ITEM_PADDING - 6 }    
            section.text_focus:lower( arrow )
            section.text_focus.w = RING_WIDTH - 60
            arrow.opacity = 255
            r_arrow.opacity = 255
            category_text.opacity = 255
            
        end

    section.unfocus_functions[ 2 ] =
    
        function()
        
            arrow.opacity = 50
            r_arrow.opacity = 50
            category_text.opacity = 50
            
        end
        
    ---------------------------------------------------------------------------
    -- The top apps
    ---------------------------------------------------------------------------
    
    validate_top_apps()
    
    local y = category_text.y + category_text.h + MENU_ITEM_PADDING 
    
    local x = HORIZ_PADDING
    
    local h_left = group.h - ( y + BOT_PADDING )
    
    local w = group.w - ( HORIZ_PADDING * 2 )

    local h = ( h_left / TOP_APP_COUNT ) - APP_ITEM_PADDING
    
    local FRAME_PADDING     = 6
    local CAPTION_HEIGHT    = 36
    local CAPTION_X_PADDING = 2
    local CAPTION_Y_PADDING = 0
    
    local icon_w = w - ( FRAME_PADDING * 2 )
    local icon_h = h - ( ( FRAME_PADDING * 2 ) + CAPTION_HEIGHT ) + 4
    
        
    for i = 1 , TOP_APP_COUNT do
        
        local app_id = section.top_apps[ i ]
    
        local box = Clone
        {
            source = section.icon_overlay_w_label,
            size = { w , h },
            opacity = 255,
            position = { x , y + ( ( h + APP_ITEM_PADDING ) * ( i - 1 ) ) }
        }
        
        local black_box = Clone
        {
            source = section.icon_overlay_b_label,
            size = { w , h },
            opacity = 0,
            position = { x , y + ( ( h + APP_ITEM_PADDING ) * ( i - 1 ) ) }        
        }
        
        local icon = section.app_icons[ app_id ]
        
        icon:set
        {
            x = box.x + FRAME_PADDING,
            y = box.y + FRAME_PADDING,
            size = { icon_w , icon_h }
        }
        
        group:add( icon , black_box , box )
    
        local caption = Text
        {
            x = box.x + FRAME_PADDING + CAPTION_X_PADDING,
            y = box.y + box.h - CAPTION_HEIGHT + CAPTION_Y_PADDING,
            text = section.all_apps[ app_id ].name,
            ellipsize = "END",
            w = icon_w
        }
        
        caption:set( APP_LABEL_TEXT_STYLE[ UNSELECTED ] )
        
        group:add( caption )
        
        section.focus_functions[ i + 2 ] =
        
            function()
            
                section.text_focus.opacity = 0
                
                section.app_focus.opacity = 255
                section.app_focus.position = { box.center[ 1 ] , box.center[ 2 ] - 3 }
                section.app_focus:lower( icon )
                
                box.opacity = 0
                black_box.opacity = 255
                
                caption:set( APP_LABEL_TEXT_STYLE[ SELECTED ] )
            
            end
            
        section.unfocus_functions[ i + 2 ] =
        
            function()
            
                box.opacity = 255
                black_box.opacity = 0
                
                caption:set( APP_LABEL_TEXT_STYLE[ UNSELECTED ] )
            
            end
    
    end

    section.app_focus:raise_to_top()

    ---------------------------------------------------------------------------
    -- This function returns focus to the menu bar
    ---------------------------------------------------------------------------
    
    section.focus_functions[ 0 ] =
    
        function()
        
            section.app_focus.opacity = 0
            section.text_focus.opacity = 0
            
            ui:on_exit_section()
            
        end
    

    ---------------------------------------------------------------------------
    -- Called each time the drop down is about to be shown
    ---------------------------------------------------------------------------

    function section.on_show( section )
    
        section.app_focus.opacity = 0
        section.text_focus.opacity = 0
    end
    
    ---------------------------------------------------------------------------
    
    local function move_focus( delta )
    
        local unfocus = section.unfocus_functions[ section.focus ]
        
        local focus = section.focus_functions[ section.focus + delta ]
        
        if not focus then
            return
        end
        
        if unfocus then
            unfocus()
        end
        
        section.focus = section.focus + delta
    
        focus()
        
    end
    
    
    local key_map =
    {
        [ keys.Up   ] = function() move_focus( -1 ) end,
        [ keys.Down ] = function() move_focus( 1  ) end
    }

    ---------------------------------------------------------------------------
    -- Called when the section is entered, by pressing down from the
    -- main menu bar
    ---------------------------------------------------------------------------
    
    function section.on_enter( section )
    
        section.focus = 1
        
        pcall( section.focus_functions[ 1 ] )
        
        section.dropdown:grab_key_focus()
        
        section.dropdown.on_key_down =
        
            function( section , key )
                local f = key_map[ key ]
                if f then
                    f()
                end
            end
    
    end
    
end