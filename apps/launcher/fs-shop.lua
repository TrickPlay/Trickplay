
return
function( ui )

    local section   = {}
    
    local assets    = ui.assets
    
    local factory   = ui.factory
    
    ---------------------------------------------------------------------------
    -- Shop data
    ---------------------------------------------------------------------------
    
    -- The shop API
    
    local api = dofile( "shop-api" )
    
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
    -- UI
    ---------------------------------------------------------------------------
    
    local group = nil
    
    -- This builds the initial 'loading UI' until the data comes back
    
    local function build_ui()
        
        if group then
            group:raise_to_top()
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
                Text{ text = "Loading..." , color = "FFFFFF" , font = "60px" }
            }
        }
        
        screen:add( group )
        
        group:raise_to_top()
        
        fetch_initial_data()
               
    end
    
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    
    local featured_items = {}
    
    local app_items = {}
    
    function section.data_arrived( section , featured_apps , all_apps )
    
        group:clear()
    
        -- center guide
        --group:add( Rectangle{ color = "FF0000" , size = { 3 , group.h } , x = group.w / 2 - 1 , y = 0 } )

        if not featured_apps or not all_apps then
            group:add( Text{ font = "60px" , text = "Error!" , color = "FFFFFF" } )
            return
        end
        
        -- The initial data is here, we can build the UI
        
        -----------------------------------------------------------------------
        -- First the two featured boxes
        
        -- TODO: featured boxes will scroll left and right - we need to account
        -- for that.
        
        local featured_x        = 113
        local featured_y        = 89
        local FEATURED_SPACE    = 34
        
        for _ , shop_app in ipairs( featured_apps.applications ) do
        
            local medias = {}
            
            for _ , media in ipairs( shop_app.medias or {} ) do
                medias[ media.imageType ] = media.url
            end
            
            shop_app.medias = medias
            
            local featured_icon_url = medias[ "featuredIcon" ]
            
            if featured_icon_url and # featured_items < 2 then
                
                local item = factory.make_featured_app_tile( assets , shop_app.name , featured_icon_url )
                
                -- Store the data from the app store in its extra
                
                item.extra.shop_app = shop_app
                
                table.insert( featured_items , item )
                
                item.position = { featured_x , featured_y }
                
                featured_x = featured_x + item.w + FEATURED_SPACE
                
                group:add( item )
            
            end
        
        end
        
        -----------------------------------------------------------------------
        -- The floor
        
        local floor = assets( "assets/app-shop-floor.png" )
        
        group:add( floor:set{ x = 0 , y = group.h - floor.h } )
        
        -----------------------------------------------------------------------
        -- Now the app tiles at the floor
        
        -- TODO: We should not create tiles for ALL of them right here...there
        -- could be thousands. Need to add paging mechanism
        
        local REFLECTION_OPACITY = 0.1 * 255
        
        for _ , shop_app in ipairs( all_apps.applications ) do

            local medias = {}
            
            for _ , media in ipairs( shop_app.medias or {} ) do
                medias[ media.imageType ] = media.url
            end
            
            shop_app.medias = medias
            
            local tile_group = Group() 
            
            local tile = factory.make_shop_floor_tile( assets , shop_app.icon )
            
            local reflection = Clone
            {
                source = tile,
                x = 0,
                y = tile.h - 16 ,
                x_rotation = { 180 , tile.h / 2 , 0 },
                opacity = REFLECTION_OPACITY
            }
            
            tile_group:add( reflection , tile )
            
            -- The anchor point is in the center of the tile, not the reflection,
            -- or the whole group.
            
            tile_group.anchor_point = tile.center 
            
            tile_group.extra.shop_app = shop_app
            
            
            table.insert( app_items , tile_group )
        
        end
        
        -----------------------------------------------------------------------
        -- Position the tiles
        
        local CENTER_TILE_Y     = floor.y + floor.h / 2 + 30        
        local CENTER_TILE_SCALE = 0.87
        
        local SIDE_TILE_SCALE   = 0.70
        local SIDE_TILE_Y       = CENTER_TILE_Y 
        local SIDE_TILE_X_SPACE = 280
        local SIDE_TILE_ANGLE   = 20
        local SIDE_TILE_X_PAD   = 130
        
        
        if # app_items > 0 then
        
            -------------------------------------------------------------------
            -- First, the center focus ring
            
            local focus = assets( "assets/app-shop-app-list-focus.png" )
            
            focus:set
            {
                anchor_point = focus.center,
                x = group.w / 2,
                y = CENTER_TILE_Y - 3
            }
            
            group:add( focus )

            -------------------------------------------------------------------                    
            -- Next, put down the center tile
            
            local center = math.ceil( ( # app_items / 2 ) )

            local tile = app_items[ center ]
            
            tile:set
            {
                scale = { CENTER_TILE_SCALE , CENTER_TILE_SCALE },
                x = group.w / 2,
                y = CENTER_TILE_Y
            }
            
            group:add( tile )

            -------------------------------------------------------------------
            -- The text for the focused app's name and price
            
            local APP_NAME_TEXT_STYLE   = { font = "DejaVu Sans bold 34px" , color = "FFFFFF" }            
            local APP_PRICE_TEXT_STYLE  = { font = "DejaVu Sans 24px" , color = "FFFFFF" }
            local APP_NAME_Y_OFFSET     = 60
            local APP_PRICE_Y_OFFSET    = 26  
            
            local sa = tile.extra.shop_app
            
            local focused_name = Text{ text = sa.name }:set( APP_NAME_TEXT_STYLE )
            
            focused_name:set
            {
                anchor_point = focused_name.center,
                x = group.w / 2,
                y = group.h - APP_NAME_Y_OFFSET
            }
            
            group:add( focused_name )
            
            local focused_price = Text( APP_PRICE_TEXT_STYLE )
                        
            local price = tonumber( sa.price )
            
            if price == 0 then
                price = ui.strings[ "Free" ]
            else
                -- TODO: Use the right currency
                price = "$ "..sa.price
            end
            
            focused_price.text = price
            
            focused_price:set
            {
                anchor_point = focused_price.center,
                x = group.w / 2,
                y = group.h - APP_PRICE_Y_OFFSET            
            }
            
            
            group:add( focused_price )
            
            -------------------------------------------------------------------                    
            -- Now, extend from the center outwards until we run out
    
            local left = center - 1
            local right = center + 1
            
            local done = false
            
            while not done do
            
                done = true
                
                if left >= 1 then
                
                    done = false
                    
                    tile = app_items[ left ]
                    
                    tile:set
                    {
                        scale = { SIDE_TILE_SCALE , SIDE_TILE_SCALE },
                        x = ( group.w / 2 ) - ( SIDE_TILE_X_PAD + ( ( center - left ) * SIDE_TILE_X_SPACE ) ),
                        y = SIDE_TILE_Y,
                        y_rotation = { SIDE_TILE_ANGLE , 0 , 0 }
                    }
                                        
                    group:add( tile )
                    
                    tile:raise( floor )
                
                end
                
                if right <= # app_items then
                
                    done = false

                    tile = app_items[ right ]
                    
                    tile:set
                    {
                        scale = { SIDE_TILE_SCALE , SIDE_TILE_SCALE },
                        x = ( group.w / 2 ) + ( SIDE_TILE_X_PAD + ( ( right - center ) * SIDE_TILE_X_SPACE ) ),
                        y = SIDE_TILE_Y,
                        y_rotation = { - SIDE_TILE_ANGLE , 0 , 0 }
                    }
                    
                    group:add( tile )
                    
                    tile:raise( floor )
                
                end
            
                left = left - 1
                right = right + 1
            end
            
        end
        

        -----------------------------------------------------------------------
    
    end
    
    ---------------------------------------------------------------------------
    -- Handlers for the main menu events
    ---------------------------------------------------------------------------
    
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
    
        --group:grab_key_focus()
        
        return false
        
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