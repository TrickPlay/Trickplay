
-- Global

-------------------------------------------------------------------------------
-- logging

--local print = function() end

-------------------------------------------------------------------------------


return
function( ui , details_shop_app , featured_apps , all_apps )

    local section   = {}
    
    local assets    = ui.assets
    
    local factory   = ui.factory
    
    ---------------------------------------------------------------------------
    -- Shop data
    ---------------------------------------------------------------------------
    
    -- The shop API
    
    local api = dofile( "shop-api" )
    
    -- The details screen object
    
    local details = dofile( "fs-shop-app" )( ui , api )
    
    local showing = false
    
    local STATE_LOADING     = 1
    local STATE_ERROR       = 2
    local STATE_MAIN_IN     = 3
    local STATE_MAIN_OUT    = 4
    local STATE_DETAILS     = 5
    
    local state = STATE_LOADING
        
    
    local function fetch_initial_data()
    
        -- If these results were passed to us when we were created, we just
        -- use them as they are and don't send out requests.
        
        if featured_apps and all_apps then
            print( "USING EXISTING APP LISTS" )
            section:data_arrived( featured_apps , all_apps )
            return
        end
    
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
    
    local background = nil
    
    -- This builds the initial 'loading UI' until the data comes back
    
    local function build_ui()
    
        print( "BUILDING UI" )
        
        if group then
            group:raise_to_top()
            group.opacity = 255
            print( "UI ALREADY BUILT - MADE VISIBLE" )
            return
        end
        
        print( "BUILDING NEW UI" )
        
        local client_rect = ui:get_client_rect()
        
        group = Group
        {
            name = "app-shop-main",
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
            
    function section.data_arrived( section , featured_apps , all_apps )
    
        group:clear()
    
        -- center guide
        --group:add( Rectangle{ color = "FF0000" , size = { 3 , group.h } , x = group.w / 2 - 1 , y = 0 } )

        if not featured_apps or not all_apps then
            group:add( Text{ font = "60px" , text = "Error!" , color = "FFFFFF" } )
            state = STATE_ERROR
            return
        end
        
        local had_background = background ~= nil
        
        if not had_background then
        
            background = assets( "assets/app-shop-bkgd-temp.jpg" )
        
            screen:add( background )
            
            background.name = "app-shop-main-background"
            
        end
        
        -----------------------------------------------------------------------
        -- The initial data is here, we can build the UI
        
        section.main =
        {
            focused = nil,          -- Points to either featured or apps
            
            featured =
            {
                items = {},
                
                focused = nil,      -- The index of the focused item in items
            },
            
            apps =
            {
                items = {},
                
                focused = nil,      -- The index of the current center item in items
                
                name_text = nil,    -- The text for the focused item's name
                
                price_text = nil,   -- The text for the focused item's price
                
                focus_ring = nil,   -- The focus ring around the center item
                
                floor = nil,        -- A group holding all the 'floor' items
                
            }
        }
        
        local featured_items = section.main.featured.items
    
        local app_items = section.main.apps.items
        
        
        -----------------------------------------------------------------------
        -- First the two featured boxes
        
        -- TODO: featured boxes will scroll left and right - we need to account
        -- for that.
        
        local featured_x        = 113
        local featured_y        = 89
        local FEATURED_SPACE    = 34
        
        for _ , shop_app in ipairs( featured_apps.applications ) do
        
            if # shop_app.medias > 0 then
        
                local medias = {}
                
                for _ , media in ipairs( shop_app.medias or {} ) do
                    medias[ media.imageType ] = media.url
                end
                
                shop_app.medias = medias
            
            end
            
            local featured_icon_url = shop_app.medias[ "featuredIcon" ]
            
            if featured_icon_url and # featured_items < 2 then
                
                local item = factory.make_featured_app_tile( assets , shop_app.name , shop_app.description , featured_icon_url )
                
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
        
        local floor_background = assets( "assets/app-shop-floor.png" )
        
        local floor = Group
        {
            size = floor_background.size,
            position = { 0 , group.h - floor_background.h },
            children =
            {
                floor_background:set{ position = { 0 , 0 } }
            }
        }
        
        group:add( floor )
        
        section.main.apps.floor = floor
        
        -----------------------------------------------------------------------
        -- Now the app tiles at the floor
        
        -- TODO: We should not create tiles for ALL of them right here...there
        -- could be thousands. Need to add paging mechanism
                
        for _ , shop_app in ipairs( all_apps.applications ) do

            if # shop_app.medias then
            
                local medias = {}
                
                for _ , media in ipairs( shop_app.medias or {} ) do
                    medias[ media.imageType ] = media.url
                end
                
                shop_app.medias = medias
            
            end
            
            local tile = factory.make_shop_floor_tile( assets , shop_app.icon )

            tile.extra.shop_app = shop_app
            
            table.insert( app_items , tile )
        
        end
        
        -----------------------------------------------------------------------
        -- Position the tiles
        
        local CENTER_TILE_Y     = ( floor.h / 2  ) + 30        
        local CENTER_TILE_SCALE = 0.87
        
        local SIDE_TILE_SCALE   = 0.70
        local SIDE_TILE_Y       = CENTER_TILE_Y 
        local SIDE_TILE_X_SPACE = 280
        local SIDE_TILE_ANGLE   = 20
        local SIDE_TILE_X_PAD   = 130
        
        -- This is a function that gives us the position of a tile relative to
        -- the center tile. We use it to place the tiles and also when
        -- animating them. It also returns whether the tile would be on screen
        -- at that distance.
        
        function section.main.apps.get_tile_position( center_distance )
            local x
            local y
            local onscreen = math.abs( center_distance ) <= 3
            
            if center_distance == 0 then
                return { floor.w / 2 , CENTER_TILE_Y } , onscreen , 0 , CENTER_TILE_SCALE
            elseif center_distance < 0 then
                return { ( floor.w / 2 ) - ( SIDE_TILE_X_PAD + ( math.abs( center_distance ) * SIDE_TILE_X_SPACE ) ) , SIDE_TILE_Y } , onscreen , SIDE_TILE_ANGLE , SIDE_TILE_SCALE
            else
                return { ( floor.w / 2 ) + ( SIDE_TILE_X_PAD + ( math.abs( center_distance ) * SIDE_TILE_X_SPACE ) ) , SIDE_TILE_Y } , onscreen , -SIDE_TILE_ANGLE , SIDE_TILE_SCALE
            end                    
        end
        
        if # app_items > 0 then
        
            -------------------------------------------------------------------
            -- First, the center focus ring
            
            local focus = assets( "assets/app-shop-app-list-focus.png" )
            
            focus:set
            {
                anchor_point = focus.center,
                x = floor.w / 2,
                y = CENTER_TILE_Y - 3,
                opacity = 0
            }
            
            floor:add( focus )
                        
            section.main.apps.focus_ring = focus

            -------------------------------------------------------------------                    
            -- Next, put down the center tile
            
            local center = math.ceil( ( # app_items / 2 ) )
            
            section.main.apps.focused = center

            local tile = app_items[ center ]
                        
            tile:set
            {
                scale = { CENTER_TILE_SCALE , CENTER_TILE_SCALE },
                position = section.main.apps.get_tile_position( 0 )
            }
            
            floor:add( tile )
            
            -------------------------------------------------------------------
            -- The text for the focused app's name and price
            
            local APP_NAME_TEXT_STYLE   = { font = "DejaVu Sans bold 30px" , color = "FFFFFF" }            
            local APP_PRICE_TEXT_STYLE  = { font = "DejaVu Sans 24px" , color = "FFFFFF" }
            local APP_NAME_Y_OFFSET     = 60
            local APP_PRICE_Y_OFFSET    = 26  
            
            local sa = tile.extra.shop_app
            
            local focused_name = Text{ text = sa.name }:set( APP_NAME_TEXT_STYLE )
            
            focused_name:set
            {
                anchor_point = focused_name.center,
                x = floor.w / 2,
                y = floor.h - APP_NAME_Y_OFFSET
            }
            
            floor:add( focused_name )
            
            local focused_price = Text(  APP_PRICE_TEXT_STYLE )

            focused_price.text = api:price_to_string( sa.price ) or ui.strings[ "Free" ]
                        
            focused_price:set
            {
                anchor_point = focused_price.center,
                x = floor.w / 2,
                y = floor.h - APP_PRICE_Y_OFFSET
            }
                        
            floor:add( focused_price )
            
            section.main.apps.name_text = focused_name
            section.main.apps.price_text = focused_price
            
            
            
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
                        position = section.main.apps.get_tile_position( left - center ),
                        y_rotation = { SIDE_TILE_ANGLE , 0 , 0 }
                    }
                                        
                    floor:add( tile )
                    
                    tile:raise( floor_background )
                
                end
                
                if right <= # app_items then
                
                    done = false

                    tile = app_items[ right ]
                    
                    tile:set
                    {
                        scale = { SIDE_TILE_SCALE , SIDE_TILE_SCALE },
                        position = section.main.apps.get_tile_position( right - center ),
                        y_rotation = { - SIDE_TILE_ANGLE , 0 , 0 }
                    }
                    
                    floor:add( tile )
                    
                    tile:raise( floor_background )
                
                end
            
                left = left - 1
                right = right + 1
            end
            
            focus:raise_to_top()
            
            focus:lower( section.main.apps.items[ section.main.apps.focused ] )
            
        end
        
        -----------------------------------------------------------------------
        
        
        section:animate_out( nil , true , had_background )
        
        state = STATE_MAIN_OUT
        
        if showing then
            state = STATE_MAIN_IN
            section:animate_in( nil , had_background )
        end 
    end

    ---------------------------------------------------------------------------
    -- Focus
    ---------------------------------------------------------------------------
    
    -- Move the focus among featured tiles left and right
    
    local function move_featured_focus( d )
        
        local f = section.main.featured
        
        local new_focus = f.focused + d
        
        local item = f.items[ new_focus ]
        
        if item then
            f.items[ f.focused ]:on_focus_out()
            item:on_focus_in()
            f.focused = new_focus
        end
        -- TODO: will scroll when we have more than two
    end
    
    -- Move the focus among app tiles left and right
    
    local function move_apps_focus( d )
    
        local a = section.main.apps
    
        local old_center = a.focused
        
        local new_center = old_center + d
        
        if new_center > # a.items or new_center < 1 then
            return
        end
        
        local to_animate = {}
        
        for i , item in ipairs( a.items ) do
        
            local old_pos , old_onscreen , old_angle , old_scale = a.get_tile_position( i - old_center )
            
            local new_pos , new_onscreen , new_angle , new_scale = a.get_tile_position( i - new_center )
            
            -- Only animate tiles that are on screen now or will be onscreen
            
            if old_onscreen or new_onscreen then
            
                local t = { item = item }
                
                t.x = Interval( old_pos[ 1 ] , new_pos[ 1 ] )
                t.y = Interval( old_pos[ 2 ] , new_pos[ 2 ] )
                
                if old_angle ~= new_angle then
                    t.angle = Interval( old_angle , new_angle )
                end
                
                if old_scale ~= new_scale then
                    t.scale = Interval( old_scale , new_scale )
                end
                
                table.insert( to_animate , t )
            
                if i == new_center then
                    t.new_center = true
                    item:raise_to_top()
                elseif i == old_center then
                    t.old_center = true
                    item:raise_to_top()
                end
                
            end
        
        end
        
        -- Disable key down while animating
        
        local on_key_down = group.on_key_down
        
        group.on_key_down = nil

        -----------------------------------------------------------------------
        -- Prepare the text and adjust its position
        
        a.name_text.opacity = 0
        a.name_text.text = a.items[ new_center ].extra.shop_app.name
        local ap = a.name_text.anchor_point
        a.name_text.anchor_point = { a.name_text.w / 2 , ap[ 2 ] }
        a.name_text:raise_to_top()
        

        a.price_text.opacity = 0
        a.price_text.text = api:price_to_string( a.items[ new_center ].extra.shop_app.price ) or ui.strings[ "Free" ]
        local ap = a.price_text.anchor_point
        a.price_text.anchor_point = { a.price_text.w / 2 , ap[ 2 ] }
        a.price_text:raise_to_top()
        
        -----------------------------------------------------------------------
        -- Create the timeline and start it
        
        local timeline = Timeline{ duration = 300 }
        
        function timeline.on_new_frame( timeline , elapsed , progress )
            for _ , t in ipairs( to_animate ) do
                t.item.x = t.x:get_value( progress )
                t.item.y = t.y:get_value( progress )
                if t.angle then
                    t.item.y_rotation = { t.angle:get_value( progress ) , 0 , 0 }
                end
                if t.scale then
                    local s = t.scale:get_value( progress )
                    t.item.scale = { s , s }
                end
                if t.old_center then
                    t.item:set_focus_opacity( 255 * ( 1 - progress ) )
                elseif t.new_center then
                    t.item:set_focus_opacity( 255 * progress )
                end
            end
            a.name_text.opacity = 255 * progress
            a.price_text.opacity = 255 * progress
        end
        
        function timeline.on_completed( timeline )
            a.focused = new_center
            group.on_key_down = on_key_down
        end
        
        timeline:start()
    
    end
    
    
    local function move_focus_left()
        local m = section.main        
        if not m then
            return
        end
        if m.focused == m.featured then
            move_featured_focus( -1 )
        elseif m.focused == m.apps then
            move_apps_focus( -1 )        
        end
    end

    local function move_focus_right()
        local m = section.main        
        if not m then
            return
        end
        if m.focused == m.featured then
            move_featured_focus( 1 )
        elseif m.focused == m.apps then
            move_apps_focus( 1 )        
        end
    end

    local function move_focus_up()
        local m = section.main        
        if not m then
            return
        end
        
        -- If we are on featured, we exit the section (give focus back to the menu)
        
        if m.focused == m.featured then
        
            m.featured.items[ m.featured.focused ]:on_focus_out()
            m.focused = nil
            ui:on_exit_section( section )
        
        -- If we are on apps and there are no featured, we do the same thing.
        -- Otherwise, we focus from apps to featured.
        
        elseif m.focused == m.apps then
        
            if # m.featured.items == 0 then
            
                m.apps.focus_ring.opacity = 0
                m.apps.items[ m.focused ]:on_focus_out()
                m.focused = nil
                ui:on_exit_section( section )
                
            else
            
                m.apps.focus_ring.opacity = 0
                m.apps.items[ m.apps.focused ]:on_focus_out()
                m.focused = m.featured
                m.featured.items[ m.featured.focused ]:on_focus_in()
            
            end
        
        end
    end

    local function move_focus_down()
        
        local m = section.main        
        if not m then
            return
        end
        
        -- We can only go down if the focus is on the featured items
        
        if m.focused == m.featured then
        
            if m.apps.focused then
            
                m.featured.items[ m.featured.focused ]:on_focus_out()
                
                m.apps.focus_ring.opacity = 255
                
                m.apps.items[ m.apps.focused ]:on_focus_in()
                
                m.focused = m.apps
            
            end
        
        end
    end
    
    function section:animate_out( callback , skip_animation , leave_background )

        local ANIMATE_OUT_DURATION = 150
        local ANIMATE_OUT_MODE     = nil
        
        
        local function finished()
            group.opacity = 0
            if callback then
                callback()
            end
        end
        
        local m = section.main        
        if not m then
            finished()
            return
        end
        
        -- Turn off the focus rings
        
        if m.focused == m.featured then
            m.featured.items[ m.featured.focused ]:on_focus_out()
        elseif m.focused == m.apps then
            m.apps.items[ m.apps.focused ]:on_focus_out()
            m.apps.focus_ring.opacity = 0
        end

        -- Now, prepare a list of things to animate out of the screen
                
        local to_animate = {}
        
        for _ , item in ipairs( m.featured.items ) do
        
            if not item.extra.original_position then
                item.extra.original_position = item.position
            end
            
            if item.x < group.w / 2 then
                local interval = Interval( item.x , - item.w )
                table.insert( to_animate , function( progress ) item.x = interval:get_value( progress ) end )
            else
                local interval = Interval( item.x , group.w )
                table.insert( to_animate , function( progress ) item.x = interval:get_value( progress ) end )
            end
            
        end
        
        do
            local floor = m.apps.floor
            
            if not floor.extra.original_position then
                floor.extra.original_position = floor.position
            end
            
            local interval = Interval( floor.y , group.h )
            table.insert( to_animate , function( progress ) floor.y = interval:get_value( progress ) end )
        end
        
        if background and not leave_background then
            table.insert( to_animate , function( progress ) background.opacity = 255 * ( 1 - progress ) end )
        end
        
        if skip_animation then
        
            -- Call all the functions with a progress of 1 - which will set
            -- everything to its final position.
            
            for i = 1 , # to_animate do
                to_animate[ i ]( 1 )
            end
            
            finished()
            
        else
        
            -- Timeline
            
            local timeline = FunctionTimeline
            {
                mode = ANIMATE_OUT_MODE ,
                duration = ANIMATE_OUT_DURATION ,
                functions = to_animate,
                on_completed = finished
            }
            
            timeline:start()
            
        end
        
    end
    
    function section:animate_in( callback , leave_background )
    
        local ANIMATE_IN_DURATION = 150
        local ANIMATE_IN_MODE     = nil
        
        local function finished()
            if callback then
                callback()
            end
        end
        
        group.opacity = 255
        
        local m = section.main        
        if not m then
            finished()
            return
        end
        
        -- Need to put everything back in place
                    
        local to_animate = {}
    
        for _ , item in ipairs( m.featured.items ) do
            local x = item.extra.original_position[ 1 ]
            local interval = Interval( item.x , x )
            table.insert( to_animate , function( progress ) item.x = interval:get_value( progress ) end )
        end
        
        do
            local floor = m.apps.floor
            local y = floor.extra.original_position[ 2 ]
            local interval = Interval( floor.y , y )
            table.insert( to_animate , function( progress ) floor.y = interval:get_value( progress ) end )
        end
        
        if background and not leave_background then
            ui:lower( background )
            table.insert( to_animate , function( progress ) background.opacity = 255 * progress end )
        end
        
        local timeline = FunctionTimeline
        {
            duration = ANIMATE_IN_DURATION ,
            mode = ANIMATE_IN_MODE,
            functions = to_animate,
            on_completed = finished
        }

                
        timeline:start()
    end
    
    local function back_from_details()
    
        local function finished()
            group:grab_key_focus()
            local m = section.main        
            if m.focused == m.featured then
                m.featured.items[ m.featured.focused ]:on_focus_in()
            elseif m.focused == m.apps then
                m.apps.items[ m.apps.focused ]:on_focus_in()
                m.apps.focus_ring.opacity = 255
            else
                section:on_enter()
            end
        end
        
        state = STATE_MAIN_IN
        
        section:animate_in( finished , true )
    
    end
    
    local function back_from_straight_details()
    
        -- This happens when we went straight to a details screen from the
        -- shop dropdown. We are coming back with no UI.
        
        state = STATE_LOADING
        section:on_show()
        section:on_enter()
        
    end
    
    local function show_focused_app_details()
        if state ~= STATE_MAIN_IN then
            return
        end
        
        local m = section.main        
        if not m then
            return
        end
        
        -- Find the selected app
        
        local shop_app
        
        if m.focused == m.featured then
            shop_app = m.featured.items[ m.featured.focused ].extra.shop_app
        elseif m.focused == m.apps then
            shop_app = m.apps.items[ m.apps.focused ].extra.shop_app
        end
        
        if not shop_app then
            return
        end
        
        -- Give the focus back to the main menu
        
        ui:on_exit_section( section )
        
        local function show_details()
            details:show_app( shop_app , back_from_details )
        end
        
        section:animate_out( show_details , false , true )
        
        state = STATE_DETAILS
        
    end
    
    ---------------------------------------------------------------------------
    -- Handlers for the main menu events
    ---------------------------------------------------------------------------
    
    local key_map =
    {
        [ keys.Left     ] = move_focus_left,
        [ keys.Right    ] = move_focus_right,
        [ keys.Up       ] = move_focus_up,
        [ keys.Down     ] = move_focus_down,
        [ keys.Return   ] = show_focused_app_details,
    }
    
    function section:on_show( )
    
        print( "ON SHOW" , state )
    
        showing = true
    
        if state == STATE_LOADING or state == STATE_ERROR then
        
            -- Here, we are going straight to the details screen without
            -- building our own UI.
            
            if details_shop_app then
            
                background = assets( "assets/app-shop-bkgd-temp.jpg" )
        
                screen:add( background:set{ opacity = 0 } )
                
                ui:lower( background )
                
                background:animate{ duration = 100 , opacity = 255 }
                
            
            
                details:show_app( details_shop_app , back_from_straight_details )
                
                details_shop_app = nil
                
                state = STATE_DETAILS
                
                return
            
            else
        
                build_ui()
                
            end
            
        elseif state == STATE_MAIN_IN then
        
            self:animate_out( nil , true )
            self:animate_in()
        
        elseif state == STATE_MAIN_OUT then
        
            self:animate_in()
            state = STATE_MAIN_IN
            
        end
        
        function group.on_key_down( group , key )
            
            local handler = key_map[ key ]
            if handler then
                handler()
            end
        
        end
        
    end
    
    function section.on_enter( section )
    
        -- If the screen has not been built, we cannot enter
        
        if state == STATE_LOADING or state == STATE_ERROR then
            
            return false
            
        elseif state == STATE_MAIN_IN then
        
            if # section.main.featured.items > 0 then
            
                section.main.focused = section.main.featured
                
                if not section.main.featured.focused then
                
                    section.main.featured.focused = 1
                    
                end
                
                section.main.featured.items[ section.main.featured.focused ]:on_focus_in()
                
                group:grab_key_focus()
                
                return true
            
            end
            
            if # section.main.apps.items > 0 then
            
                section.main.focused = section.main.apps
                
                section.main.focus_ring.opacity = 255
                
                group:grab_key_focus()
                
                return true
            
            end
        
        elseif state == STATE_MAIN_OUT then
        
            assert( false )
        
        elseif state == STATE_DETAILS then
        
            details:on_enter()
            
            return true
        
        end
                
        return false
        
    end
    
    function section.on_default_action( section )
    
        ui:on_section_full_screen( section )
        
        return true
    
    end

    function section.on_hide( section )
    
        print( "ON HIDE" , state )
    
        showing = false
        
        if state == STATE_LOADING or state == STATE_ERROR then
            
            group.opacity = 0
            
        elseif state == STATE_MAIN_IN then
        
            section:animate_out()
        
            state = STATE_MAIN_OUT
            
        elseif state == STATE_MAIN_OUT then
        
            -- do nothing
            
        elseif state == STATE_DETAILS then
        
            details:on_hide()
            
            if group then
            
                state = STATE_MAIN_OUT
                
            else
                
                state = STATE_LOADING
                
            end
        
        end
   
        if background then
            background.opacity = 0
        end
        
    end
   
    function section.on_clear()
        if group then
            group:unparent()
            group = nil
        end
        if background then
            background:unparent()
            background = nil
        end
        if details then
            details:on_clear()
        end
    end
    
    ---------------------------------------------------------------------------

    return section
        
end
