
-- This gets called once - when the section is about to be shown for
-- the first time.

return
function( section )

    local TOP_APP_COUNT = 3
    
    section.app_icons = {}
    
    section.top_apps = settings.top_apps or {}
    
    section.all_apps = apps:get_for_current_profile()
    
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
        [SELECTED]   = { font = "DejaVu Sans 28px", color = "FFFFFFFF" },
        [UNSELECTED] = { font = "DejaVu Sans 28px", color = "FFFFFFFF" },
    }
    
    local APP_LABEL_TEXT_STYLE =
    {
        [SELECTED]   = { font = "DejaVu Sans 24px" , color = "FFFFFFFF" },
        [UNSELECTED] = { font = "DejaVu Sans 24px" , color = "000000FF" },
    }

    local MENU_ITEM_HEIGHT  = 40
    local TOP_PADDING       = 46
    local ITEM_PADDING      = 26
    local BOT_PADDING       = 0
    local HORIZ_PADDING     = 20
    
    local group = section.dropdown
        
    ---------------------------------------------------------------------------
    -- The 'all apps' menu item
    ---------------------------------------------------------------------------
    
    local all_apps_text = Text
    {
        text = section.ui.strings[ "View All My Apps" ],
        position = { 0 , TOP_PADDING + ITEM_PADDING }
    }
    
    all_apps_text:set( MENU_ITEM_TEXT_STYLE[ UNSELECTED ] )
    
    all_apps_text.x = group.w / 2 - all_apps_text.w / 2
    
    group:add( all_apps_text )
    
    ---------------------------------------------------------------------------
    -- The 'category' menu item
    ---------------------------------------------------------------------------
    
    local category_text = Text
    {
        text = section.ui.strings[ "Recently Used" ],
        position = { 0 , all_apps_text.y + all_apps_text.h + ITEM_PADDING }
    }
    
    category_text:set( MENU_ITEM_TEXT_STYLE[ UNSELECTED ] )
    
    category_text.x = group.w / 2 - category_text.w / 2
    
    group:add( category_text )
        
    ---------------------------------------------------------------------------
    -- The top apps
    ---------------------------------------------------------------------------
    
    validate_top_apps()
    
    local y = category_text.y + category_text.h + ITEM_PADDING
    
    local x = HORIZ_PADDING
    
    local h_left = group.h - ( y + BOT_PADDING )
    
    local w = group.w - ( HORIZ_PADDING * 2 )

    local h = ( h_left / TOP_APP_COUNT ) - ITEM_PADDING
    
    local FRAME_PADDING     = 8
    local CAPTION_HEIGHT    = 32
    
    local icon_w = w - ( FRAME_PADDING * 2 )
    local icon_h = h - ( ( FRAME_PADDING * 1 ) + CAPTION_HEIGHT )
    
    for i = 1 , TOP_APP_COUNT do
        
        local app_id = section.top_apps[ i ]
    
        local box = Rectangle
        {
            color = "FFFFFF" ,
            size = { w , h },
            position = { x , y + ( ( h + ITEM_PADDING ) * ( i - 1 ) ) }
        }
        
        group:add( box )
    
        local icon = section.app_icons[ app_id ]
        
        icon:set
        {
            x = box.x + FRAME_PADDING,
            y = box.y + FRAME_PADDING,
            size = { icon_w , icon_h }
        }
        
        group:add( icon )
        
        local caption = Text
        {
            x = box.x + FRAME_PADDING,
            y = box.y + box.h - CAPTION_HEIGHT,
            text = section.all_apps[ app_id ].name,
            ellipsize = "END",
            w = icon_w
        }
        
        caption:set( APP_LABEL_TEXT_STYLE[ UNSELECTED ] )
        
        group:add( caption )
    
    end


    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------

    function section.on_show( section )
    
   
    end
    
end