
return
function( section )

    local ui = section.ui

    local assets    = ui.assets
    
    local factory   = ui.factory

    local group     = section.dropdown
    
    ---------------------------------------------------------------------------
    
    local api = dofile( "shop-api" )
    
    ---------------------------------------------------------------------------

    local section_items = {}

    local loading_text = nil
    
    ---------------------------------------------------------------------------
    -- This one always runs before the drop down is shown
    
    local function build_loading_ui()
    
        local TOP_PADDING = 48
        
        loading_text = Text
        {
            font = "DejaVu Sans 30px" ,
            color = "FFFFFF" ,
            text = ui.strings[ "Loading..." ],
            y = TOP_PADDING
        }
        
        loading_text.x = group.w / 2 - loading_text.w / 2
        
        group:add( loading_text )
        
    end
    
    ---------------------------------------------------------------------------
    -- This one runs only when there is a problem fetching the data
    
    local function build_error_ui()
        
        assert( loading_text )
        
        loading_text.text = ui.strings[ "Error" ]
        
        loading_text.x = group.w / 2 - loading_text.w / 2        
    end
    
    ---------------------------------------------------------------------------
    -- This one runs once the data is here
    
    local function build_ui( shop_apps )
    
        -- Remove the loading "UI"
        
        loading_text:unparent()
        loading_text = nil
    
        -- Now, build the dropdown
        
        local TOP_PADDING = 48
        local BOTTOM_PADDING = 12
        
        local space = group.h - ( TOP_PADDING + BOTTOM_PADDING )
        local items_height = 0
    
    
--        local credit = factory.make_text_menu_item( assets , ui.strings[ "Credit" ]..": $15.00" )
        
        local categories = factory.make_text_side_selector( assets , ui.strings[ "Recommended" ] )
    
--        table.insert( section_items , credit )
        
        table.insert( section_items , categories )
        
--        items_height = items_height + credit.h + categories.h
        items_height = items_height + categories.h
--[[        
        credit.extra.on_activate =
        
            function()
                -- TODO: What happens when you hit the credit button
            end
]]        
        -----------------------------------------------------------------------
        -- Add the app tiles
        -----------------------------------------------------------------------
        
        for i = 1 , # shop_apps do
            
            local a = shop_apps[ i ]
        
            local tile = factory.make_store_tile( assets , a.name , a.icon )
            
            table.insert( section_items , tile )
            
            items_height = items_height + tile.h
            
            tile.extra.on_activate =
            
                function( )
                    ui:on_exit_section( section )
                    local shop = dofile( "fs-shop")( ui , a , section.featured_apps , section.all_apps )
                    ui:on_section_full_screen( shop )
                end
        
        end
        
        
        -----------------------------------------------------------------------
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

    local function fetch_initial_data()
    
        -- The result of getting a list of featured apps from the API
        
        local featured_apps
        
        -- The result of getting a list of all apps from the API
        
        local all_apps
        
        -- Whether we have enough results to build the main UI
        
        local INITIAL_DATA_FETCHING = 1 -- We are getting the data
        local INITIAL_DATA_MISSING  = 2 -- We were unable to get all the data (store is down)
        local INITIAL_DATA_COMPLETE = 3 -- We got all the data
        
        local initial_data = INITIAL_DATA_FETCHING
        
        -- The functions that receive the initial data
        
        local function featured_apps_callback( results )
            
            if initial_data ~= INITIAL_DATA_FETCHING then
                return
            end
            
            if results.stat ~= "ok" then
                initial_data = INITIAL_DATA_MISSING
                section:data_arrived( )
                return
            end
            
            if tonumber( results.results ) < 2 then
                initial_data = INITIAL_DATA_MISSING
                section:data_arrived( )
                return
            end
            
            featured_apps = results
            
            if all_apps then
                initial_data = INITIAL_DATA_COMPLETE
                section:data_arrived( featured_apps , all_apps )
            end
        end
        
        local function all_apps_callback( results )
            if initial_data ~= INITIAL_DATA_FETCHING then
                return
            end
            
            if results.stat ~= "ok" then
                initial_data = INITIAL_DATA_MISSING
                section:data_arrived( )
                return
            end
            
            all_apps = results
            
            if featured_apps then
                initial_data = INITIAL_DATA_COMPLETE
                section:data_arrived( featured_apps , all_apps )
            end
            
        end
        
        -- Now, fetch the initial data
        
        -- TODO: Add a 'max' parameter when that is functional
        
        api:search( { category = "featured" } , featured_apps_callback )
        api:search( { } , all_apps_callback )
        
    end

    ---------------------------------------------------------------------------
    
    function section.data_arrived( section , featured_apps , all_apps )
  
        if featured_apps == nil or all_apps == nil then
            build_error_ui()
        else
            
            section.featured_apps = featured_apps
            section.all_apps = all_apps
            
            local shop_apps = {}
            
            -- Add up to 3 from featured_apps
            
            for i = 1 , math.min( # featured_apps.applications , 3 ) do
                table.insert( shop_apps , featured_apps.applications[ i ] )
            end
            
            -- If we still don't have 3 in shop_apps, add others from all_apps
            
            if # shop_apps < 3 then
            
                for i = 1 , # all_apps.applications do
                
                    -- A candidate to be added to the master list
                    
                    local a = all_apps.applications[ i ]
                    
                    -- If it already exists in the master list, skip it
                    
                    for j = 1 , # shop_apps do
                        if shop_apps[ j ].id == a.id then
                            a = nil
                            break
                        end
                    end
                    
                    if a then
                        table.insert( shop_apps , a )
                        if # shop_apps == 3 then
                            break
                        end
                    end
                
                end
            
            end
            
            for i = 1 , # shop_apps do
            
                local medias = {}
                
                for _ , media in ipairs( shop_apps[ i ].medias or {} ) do
                    medias[ media.imageType ] = media.url
                end
            
                shop_apps[ i ].medias = medias
            
            end
            
            
            build_ui( shop_apps )
        end
    
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
    
    function section.on_show()
    end
    
    function section.on_hide()
    end

    function section.on_enter()
        
        if # section_items == 0 then
            return false
        end
        
        section.focus = 0
        
        move_focus( 1 )
        
        section.dropdown:grab_key_focus()
        
        section.dropdown.on_key_down =
        
            function( section , key )
                local f = key_map[ key ]
                if f then
                    f()
                end
            end
    
        return true
    end
    
    function section.on_default_action()
        ui:on_exit_section( section )
        local fs_shop = dofile( "fs-shop" )( ui )
        ui:on_section_full_screen( fs_shop )
        return true
    end

    if group then
        build_loading_ui()
    
        fetch_initial_data()
    end
end