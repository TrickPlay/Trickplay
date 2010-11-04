
return
function( ui , api )

    local assets    = ui.assets
    local factory   = ui.factory
    
    local section = {}
    
    local get_button
    
    local keepers = {}
    
    local function hold( thing )
        keepers[ thing ] = true
    end
    local function letgo( thing )
        keepers[ thing ] = nil
    end
   
    local function build_ui()
    
        local APP_TITLE_STYLE   = { font = "DejaVu Sans 48px" , color = "000000FF" }
        local APP_TITLE_X       = 514
        local APP_TITLE_Y       = 7 
        local APP_TITLE_W       = 974
        local APP_TITLE_H       = 50
        
        local APP_DESC_STYLE    = { font = "DejaVu Sans 34px" , color = "FFFFFFFF" }
        local APP_DESC_X        = 514
        local APP_DESC_Y        = 94
        local APP_DESC_W        = 974
        local APP_DESC_H        = 330
        
        local BACKGROUND_FADE_DURATION  = 500
        
        local ANIMATE_IN_DURATION       = 200
        local ANIMATE_IN_MODE           = nil -- "EASE_IN_QUAD"
        
        local ANIMATE_OUT_DURATION      = 200
        
        local SCRIM_HIDDEN_Y            = screen.h * 1.25
        
        local TILE_SCALE                = 0.90
        local TILE_X                    = 250
        local TILE_Y                    = 32
        
        local GET_BUTTON_X              = 250 --center
        local GET_BUTTON_Y              = 260
        
        local STAR_SIZE                 = 40
        local STAR_FULL_COLOR           = "BBBBBB"
        local STAR_EMPTY_COLOR          = "333333"
        local STAR_PADDING              = 10
        local STAR_GROUP_X              = 1560
        local STAR_GROUP_Y              = 16
        
        local REVIEW_TEXT_STYLE         = { font = "DejaVu Sans 30px", color = STAR_FULL_COLOR } 
        

        local group = Group{ position = { 0 , 0 } , size = screen.size , opacity = 0 , name = "app-shop-details" }
            

        local scrim_background = assets( "assets/app-screen-scrim.png" )
                
        local SCRIM_Y           = group.h - scrim_background.h

        local app_title = Text( APP_TITLE_STYLE )
        
        local app_desc = Text( APP_DESC_STYLE )
                
        get_button = factory.make_text_menu_item( assets , "Get it" )
        
        local full_star = factory.make_star( STAR_SIZE , 1 , STAR_EMPTY_COLOR , STAR_FULL_COLOR )
        local empty_star = factory.make_star( STAR_SIZE , 0 , STAR_EMPTY_COLOR , STAR_FULL_COLOR )
        local half_star = factory.make_star( STAR_SIZE , 0.5 , STAR_EMPTY_COLOR , STAR_FULL_COLOR )
        
        local star_group = Group{ size = { STAR_SIZE * 5 + STAR_PADDING * 4 , STAR_SIZE } }
        
        local review_text = Text( REVIEW_TEXT_STYLE )
                
        local scrim = Group
        {
            position = { 0 , SCRIM_Y } ,
            
            children =
            {
                scrim_background:set
                {
                    position = { 0 , 0 }
                },
                
                ---------------------------------------------------------------
                -- TODO : stars and review count are hard-coded
                
                star_group:set
                {
                    position = { STAR_GROUP_X , STAR_GROUP_Y },
                    
                    children =
                    {
                        full_star ,
                        
                        Clone
                        {
                            source = full_star,
                            x = STAR_SIZE + STAR_PADDING
                        },
                            
                        Clone
                        {
                            source = full_star,
                            x = STAR_SIZE * 2 + STAR_PADDING * 2
                        },
                        
                        half_star:set
                        {
                            x = STAR_SIZE * 3 + STAR_PADDING * 3
                        },

                        empty_star:set
                        {
                            x = STAR_SIZE * 4 + STAR_PADDING * 4
                        },
                    }
                },
                
                -- Text showing number of star ratings
                
                review_text:set
                {
                    x = STAR_GROUP_X + STAR_SIZE * 5 + STAR_PADDING * 6,
                    y = STAR_GROUP_Y + 2,
                },
                
                ---------------------------------------------------------------

                app_title:set
                {
                    position = { APP_TITLE_X , APP_TITLE_Y },
                    size = { APP_TITLE_W , APP_TITLE_H },
                    clip = { 0 , 0 , APP_TITLE_W , APP_TITLE_H },
                    ellipsize = "END",
                },
                
                app_desc:set
                {
                    position = { APP_DESC_X , APP_DESC_Y },
                    wrap = true,
                    size = { APP_DESC_W , APP_DESC_H },
                    clip = { 0 , 0 , APP_DESC_W , APP_DESC_H },
                    ellipsize = "END"
                },
                
                get_button:set
                {
                    anchor_point = get_button.center,
                    position = { GET_BUTTON_X , GET_BUTTON_Y }
                }
            }
        }
        
        group:add( scrim )
        
        local background = nil
        
        local tile = nil
        
        local me = { readonly = { group = function() return group end } }
        
        local review_cache = {} -- For keeping fake review numbers
        
        function me:populate( shop_app )
        
            -- Remove and let go of an old background if it is there
            
            if background then
                background:unparent()
                background = nil
            end
            
            -- If there is a background URL, start loading a new background
            -- but only add it when it arrives.
            
            local background_url = shop_app.medias[ "background" ]
            
            if background_url then
            
                background = Image
                {
                    src = background_url ,
                    async = true,
                    size = screen.size ,
                    position = { 0 , 0 },
                    opacity = 0
                }
                
                function background.on_loaded( image , failed )
                    image.on_loaded = nil
                    if not failed then
                        group:add( image )
                        image:lower_to_bottom()
                        image:animate{ duration = BACKGROUND_FADE_DURATION , opacity = 255 }
                    else
                        background = nil
                    end
                end
                
            end
            
            -- Remove old tile if there
            
            if tile then            
                tile:unparent()
                tile = nil
            end
            
            -- Add new tile
            
            tile = factory.make_shop_floor_tile( assets , shop_app.icon )
            
            tile:set
            {
                position = { TILE_X , TILE_Y },
                scale = { TILE_SCALE , TILE_SCALE }
            }
            
            scrim:add( tile )
            
            tile:raise( scrim_background )
        
            -- Now, populate the text
            
            app_title.text = shop_app.name
            
            app_desc.text = shop_app.description or ""
            
            get_button:set_caption( ui.strings[ "Get it now" ]..": "..( api:price_to_string( shop_app.price ) or ui.strings[ "Free" ] ) )

            -- TODO: Fake review count
            
            local reviews = review_cache[ shop_app.id ]
            
            if not reviews then
                reviews = math.random( 30 , 200 )
                review_cache[ shop_app.id ] = reviews
            end
            
            review_text.text = "["..tostring( reviews ).."]"
            
        end
        
        function me:animate_in( callback )
        
            if not group.parent then
                screen:add( group )
            end
            
            ui:lower( group )
            
            group.opacity = 255
            
            local to_animate = {}
            
            scrim.y = SCRIM_HIDDEN_Y
            local interval = Interval( SCRIM_HIDDEN_Y , SCRIM_Y )
            table.insert( to_animate , function( progress ) scrim.y = interval:get_value( progress ) end )
            
            local timeline = FunctionTimeline{ mode = ANIMATE_IN_MODE , duration = ANIMATE_IN_DURATION , functions = to_animate }
            
            function timeline.on_completed( timeline )
                                
                -- Set up an on_idle to rotate the icon tile after some delay
                
                old_idle = idle.on_idle

                local delay = 1.0
                local angle = 0
                local rotation = { 0 , 0 , 0 }
                
                local tile_rotate_d         = -1
                local TILE_ROTATE_ANGLE     = 20
                local TILE_ROTATE_SPEED     = TILE_ROTATE_ANGLE / 3

                function idle.on_idle( idle , seconds )
                
                    if delay then
                        delay = delay - seconds
                        if delay <= 0 then
                            delay = nil
                        end
                        return
                    end
                
                
                    angle = angle + tile_rotate_d * ( TILE_ROTATE_SPEED * seconds )
                    
                    if angle >= TILE_ROTATE_ANGLE then
                        angle = TILE_ROTATE_ANGLE
                        tile_rotate_d = - tile_rotate_d
                    elseif angle <= -TILE_ROTATE_ANGLE then
                        angle = -TILE_ROTATE_ANGLE
                        tile_rotate_d = - tile_rotate_d
                    end
                    
                    rotation[ 1 ] = angle
                    
                    tile.y_rotation = rotation
                    
                end

                -- Invoke the callback
                
                callback()               
                
            end
            
            timeline:start()

        end
        
        function me:animate_out( callback )
        
            idle.on_idle = nil
        
            local to_animate = {}
            
            do
                local interval = Interval( scrim.y , SCRIM_HIDDEN_Y )
                table.insert( to_animate , function( progress ) scrim.y = interval:get_value( progress ) end )
            end
            
            if background then
                background.on_loaded = nil
                if background.parent and background.opacity > 0 then
                    local interval = Interval( background.opacity , 0 )
                    table.insert( to_animate , function( progress ) background.opacity = interval:get_value( progress ) end )
                end
            end

            local timeline = FunctionTimeline{ duration = ANIMATE_OUT_DURATION , functions = to_animate }
            
            function timeline.on_completed( timeline )
                
                if background then
                    background:unparent()
                    background = nil
                end
                if tile then
                    tile:unparent()
                    tile = nil
                end
                
                group.opacity = 0
                
                letgo( timeline )

                if callback then
                    callback()
                end
                
            end

            
            timeline:start()
            
            -- In one special case, this timeline gets garbage collected right
            -- after we leave this function. This is an engine issue that I've
            -- noted - bug # 192.
            --
            -- To reproduce it, run this, go to the store drop down, click on
            -- an item to bring up the app details page, then go to the 'Apps'
            -- menu item and bring up the list of apps - the app details
            -- screen does not get animated out properly.
            
            hold( timeline )            
        
        end
        
        return Encapsulate( me )
        
    end
    
    local me 
    
    local go_back
    
    function section:show_app( shop_app , back_callback )
    
        go_back = back_callback
    
        if not me then
            me = build_ui()
        end
        
        local function finished_in()
        end
        
        get_button:on_focus_out()
        
        me:populate( shop_app )
        me:animate_in( finished_in )
    
    end
    
    function section:on_enter()
        get_button:on_focus_in()

        local group = me.group
        
        group:grab_key_focus()
        function group.on_key_down( group , key )
            if key == keys.Return then
                group.on_key_down = nil
                me:animate_out( go_back )
            elseif key == keys.Up then
                get_button:on_focus_out()
                ui:on_exit_section()
            end
        end
    end
    
    function section:on_hide()
        get_button:on_focus_out()
        me:animate_out( )
    end
    
    function section:go_back()
        get_button:on_focus_out()
        me:animate_out( go_back )
    end
    
    function section:on_clear()
        local group = me.group
        if group then
            group:unparent()
            group=nil
        end
        if background then
            background:unparent()
            background = nil
        end
    end
    
    return Encapsulate( section )
    
end
    