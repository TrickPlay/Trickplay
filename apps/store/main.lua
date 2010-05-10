
dofile( "Json.lua" )

STORE_URL="http://store.trickplay.com"

app_list = nil

-------------------------------------------------------------------------------

function get_app_base_url( index )

    assert( app_list )

    return STORE_URL.."/"..app_list[ index ].id.."/"..tostring( app_list[ index ].release )
    
end

function get_app_zip_url( index )

    assert( app_list )
    
    return get_app_base_url( index ).."/app.zip" 

end

function get_app_icon_url( index )

    assert( app_list )
    
    return get_app_base_url( index ).."/launcher-icon.png" 

end

-------------------------------------------------------------------------------
-- Make the initial request for an app list

local apps_request = URLRequest( STORE_URL.."/apps.json" )

function apps_request.on_complete( request , response )

    if response.failed then
    
        print( "THE REQUEST FOR THE APP LIST FAILED" )
    
    else
    
        local ok , list = pcall( Json.Decode , response.body )
        
        if not ok then
        
            -- list is not really the list but the error message from pcall
            
            print( "FAILED TO DECODE THE APP LIST : "..list )
            
        else
        
            app_list = list
            
            print( "APP LIST HAS" , #app_list , "ITEMS" )
            
        end
    
    end

end

apps_request:send()

-------------------------------------------------------------------------------

function apps.on_install_progress( apps , info )
    
    print( "PROGRESS" , info.status , info.percent_downloaded , info.percent_installed )
    
end

function apps.on_install_finished( apps , info )
    
    local failed = info.failed

    if not failed then
    
        failed = not apps:complete_install( info.id )
    
    end
    
    if failed then
        
        print( "FAILED TO INSTALL" , info.app_id )
        
    else
    
        print( "FINISHED INSTALL OF" , info.app_id )
    
    end

end

-------------------------------------------------------------------------------
--[[
function test()

    local icon = Image{ src = get_app_icon_url( 1 ) }
    
    screen:add( icon )

    screen:show()
end

function install( index )

    index = index or 1

    local app_id = app_list[ index ].id
    local app_name = app_list[ index ].name
    local url = get_app_zip_url( index )
    local extra = { icon = get_app_icon_url( index ) }
    
    local install_id = apps:download_and_install_app( app_id , app_name , true , url , extra )

end
]]
-------------------------------------------------------------------------------

ui =
{
    main =
    {
        background          = { f = "appshop-all-background-LG.tif",    position = { 0 , 0 } },
        castle_info         = { f = "featured-app-castle-info.tif",     position = { 978 , 290 + 140 } , name = "castle_info" },
        zombie_info         = { f = "featured-app-zombie-info.tif",     position = { 52 , 290 + 140 } , name = "zombie_info" },
        stroke              = { f = "featured-apps-stroke-white.tif",   position = { 48 , 132 } },
        focus               = { f = "focus-yellow-all.tif" ,            position = { 0 , 0 } }
        
    },
    
    app =
    {
        background          = { f = "background.jpg" ,            position = { 0 , 0 }      },
        buy_off             = { f = "button-buy-off.png",         position = { 96 , 919 }   , name = "buy_off"  , other = "buy_on" },
        buy_on              = { f = "button-buy-on.png",          position = { 96 , 919 }   , name = "buy_on"   , other = "buy_off" , nav = { u = "menu_off" , r = "screen1" } },
        loading             = { f = "button-loading.png",         position = { 96 , 919 }   , name = "loading"  },
        play_off            = { f = "button-play-off.png",        position = { 96 , 919 }   , name = "play_off" , other = "play_on"  },
        play_on             = { f = "button-play-on.png",         position = { 96 , 919 }   , name = "play_on"  , other = "play_off" , nav = { u = "menu_off" , r = "screen1" } },
        
        search_off          = { f = "menu-search-off.png",        position = { 40 , 14 }    , name = "search_off" , other = "search_on" },
        search_on           = { f = "menu-search-on.png",         position = { 40 , 14 }    , name = "search_on"  , other = "search_off" , nav = { d = "buy_off" , r = "menu_off" } },
        
        menu_off            = { f = "menu-all-off.png" ,          position = { 121 , 14 }   , name = "menu_off" , other = "menu_apps_on" , nav = { d = "buy_off"  } },
        menu_apps_on        = { f = "menu-apps-on.png" ,          position = { 121 , 14 }   , name = "menu_apps_on" , other = "menu_off" , nav = { l = "search_off" , d = "buy_off" , r = { hide = true , target = "menu_games_on" } } },
        
        menu_games_on       = { f = "menu-games-on.png",          position = { 121 , 14 }   , name = "menu_games_on" , other = "menu_off" , nav = { d = "buy_off" , l = { hide = true, target = "menu_apps_on" } } },
        
        screen1_on          = { f = "screenshot-1-on.png",        position = { 1285 , 609 } , name = "screen1_on" , other = "screen1" , nav = { u = "menu_off" , d = "screen2" , l = "buy_off" } },
        screen2_on          = { f = "screenshot-2-on.png",        position = { 1285 , 753 } , name = "screen2_on" , other = "screen2" , nav = { u = "screen1" , d = "screen3" , l = "buy_off" } },
        screen3_on          = { f = "screenshot-3-on.png",        position = { 1285 , 897 } , name = "screen3_on" , other = "screen3" , nav = { u = "screen2" , l = "buy_off" } },
        screen1             = { f = "screenshot-1.png",           position = { 1285 , 609 } , name = "screen1" , other = "screen1_on" },
        screen2             = { f = "screenshot-2.png",           position = { 1285 , 753 } , name = "screen2" , other = "screen2_on" },
        screen3             = { f = "screenshot-3.png",           position = { 1285 , 897 } , name = "screen3" , other = "screen3_on" },
    },
    
    main_screen = nil,  -- A group that holds the main screen
    
    app_screen = nil,   -- A group that holds the app details screen
    
    app_screen_focus = nil,
    
    prepare_image = 
    
        function( self , base , style , hide )
        
            local image = Image()
                       
            image.src = base.."/"..style.f
            
            image.x = style.position[ 1 ] 
            image.y = style.position[ 2 ] 
            
            if style.name then
                
                image.name = style.name
                
            end
            
            image.extra.other = style.other
            
            image.extra.nav = style.nav
            
            if hide then
                image:hide()
            end
            
            return image
        
        end,
    
    load_app_screen =
    
        function( self , app_id )
            
            self.app_screen = Group{ size = screen.size , position = { 0 , 0 } }
            
            self.app_screen:add(
                self:prepare_image( app_id, self.app.background ),
                self:prepare_image( app_id, self.app.search_off ),
                self:prepare_image( app_id, self.app.search_on , true ),
                self:prepare_image( app_id, self.app.menu_off ),
                self:prepare_image( app_id, self.app.menu_apps_on , true ),
                self:prepare_image( app_id, self.app.menu_games_on , true ),
                self:prepare_image( app_id, self.app.buy_on ),
                self:prepare_image( app_id, self.app.buy_off , true ),
                self:prepare_image( app_id, self.app.screen1 ),
                self:prepare_image( app_id, self.app.screen1_on , true ),
                self:prepare_image( app_id, self.app.screen2 ),
                self:prepare_image( app_id, self.app.screen2_on , true ),
                self:prepare_image( app_id, self.app.screen3 ),
                self:prepare_image( app_id, self.app.screen3_on , true )
            )
            
            self.app_screen_focus = "buy_on"
            
            return self.app_screen
    
        end,
        
    app_screen_swap =
    
        function( self , name , hide )
        
            if not self.app_screen then
            
                return
                
            end
            
            local e = self.app_screen:find_child( name )
            
            if e then
            
                e:hide()
                
                local other = e.extra.other 
                
                if other then
                
                    e = self.app_screen:find_child( other )
                        
                    if e then
                    
                        if not hide then
                        
                            e:show()
                            
                        end
                        
                        return e.name
    
                    end
            
                end
                
            end
        
        end,
        
    main_focus = nil,
    
    main_focus_change =
    
        function( self , old , new )
        
            local info_down = nil
            
            local info_up = nil
        
            if old == 1 then
            
                info_down = self.main_screen:find_child( "zombie_info" )
                
            elseif old == 2 then
            
                info_down = self.main_screen:find_child( "castle_info" )
            
            end

            if new == 1 then
            
                info_up = self.main_screen:find_child( "zombie_info" )
                
            elseif new == 2 then
            
                info_up = self.main_screen:find_child( "castle_info" )
            
            end
            
            if info_up then
            
                info_up:animate{ duration = 150 , y = 290 }
            
            end
            
            if info_down then
            
                info_down:animate{ duration = 150 , y = 290 + 140 }
                
            end
        
        end,
        
    main_set_focus =
    
        function( self , what )
        
            old_focus = self.main_focus
        
            self.main_focus = what
        
            if self.main_focus == 1 then self.main_focus_rings.clip = { 39 , 123 , 911 , 454 }
            elseif self.main_focus == 2 then self.main_focus_rings.clip = { 966 , 123 , 911 , 454 }
            elseif self.main_focus == 3 then self.main_focus_rings.clip = { 823 , 591 , 277 , 75 }
            elseif self.main_focus == 4 then self.main_focus_rings.clip = { 823 , 686 , 277 , 275 }
            end
        
            self:main_focus_change( old_focus , self.main_focus )
        end,
        
    main_tiles = {},
    
    main_tile_positions = {},
    
    main_focused_tile = 11,
        
    load_main_screen =
    
        function( self )
            
            local base = "main"
        
            self.main_screen = Group{ size = screen.size , position = { 0 , 0 } }
                        
            self.main_screen:add(
                self:prepare_image( base , self.main.background ),
                
                Group{
                    size = screen.size ,
                    position = { 0 , 0 } ,
                    clip = { 53 , 0 , 885 , 559 } ,
                    children = { self:prepare_image( base , self.main.zombie_info , false , true ) } },

                Group{
                    size = screen.size ,
                    position = { 0 , 0 } ,
                    clip = { 978 , 0 , 886 , 559 },
                    children = { self:prepare_image( base , self.main.castle_info , false , true ) } },
                
                self:prepare_image( base , self.main.stroke )
            )
            
            
            local tile_group =
                
                Group{
                    name = "tiles",
                    size = { screen.w , 275 },
                    position = { 0 , 696 }
                }
                
            local function add_reflection( image )
            
                local clone = Clone{
                    source = image ,
                    position = image.position ,
                    anchor_point = image.anchor_point ,
                    x_rotation = { 180 , image.h , 0 } ,
                    scale = image.scale ,
                    opacity = 40 }
                    
                image.parent:add( clone )
                
                image.extra.reflection = clone
            
            end
            
            local x = 0
            
            local image = self:prepare_image( base .."/tiles" , { f = "1.tif" , position = { 0 , 0 } } , false , true )
            
            image.anchor_point = { image.w / 2 , 0 }
            
            image.x = 960
            
            print( image.w , screen.w , image.x )
            
            tile_group:add( image )
            
            add_reflection( image )

            table.insert( self.main_tiles , image )
            

            local lx = image.x - image.w + 2
            
            local rx = image.x + image.w - 2
            
            for i = 2 , 11 do
            
                image = self:prepare_image( base .."/tiles" , { f = tostring( i )..".tif" , position = { lx , 31 } } , false , true )
            
                image.anchor_point = { image.w / 2 , 0 }
                
                image.scale = { 0.75 , 0.75 }
                
                tile_group:add( image )

                add_reflection( image )

                lx = lx - ( ( image.w * 0.75 ) + 14 )
                
                table.insert( self.main_tiles , 1 , image )

            end
            

            for i = 12 , 20 do
            
                image = self:prepare_image( base .."/tiles" , { f = tostring( i )..".tif" , position = { rx , 31 } } , false , true )
            
                image.anchor_point = { image.w / 2 , 0 }
                
                image.scale = { 0.75 , 0.75 }
                
                tile_group:add( image )

                add_reflection( image )

                rx = rx + ( ( image.w * 0.75 ) + 14 )
                
                table.insert( self.main_tiles , image )
                
                if i == 20 then
                
                    image.extra.app_id = "com.trickplay.1945"
                
                end

            end
                        
            self.main_screen:add( tile_group )
            
            for i = 1 , 11 do
            
                table.insert( self.main_tile_positions , self.main_tiles[ 5 + i ].position )
            
            end
            
            self.main_focus_rings =

                Group{
                    name = "focus",
                    size = screen.size,
                    position = { 0 , 0 },
                    children = { self:prepare_image( base , self.main.focus , false , true ) } 
                }
            
            self.main_screen:add( self.main_focus_rings )
                        
                        
            self:main_set_focus( 4 )                        
            
            screen:add( self.main_screen )
        
        end,
        
    main_scrolling = false,
        
    main_tile_key_down =
    
        function( self , keyval )
        
            if self.main_scrolling then
            
                return
                
            end
        
            if keyval == keys.Right then
            
                -- first, we move a tile to the offscreen position
                
                local far_right_tile = self.main_focused_tile + 5
                
                if far_right_tile > #self.main_tiles then
                
                    far_right_tile = far_right_tile - #self.main_tiles 
                
                end
                
                self.main_tiles[ far_right_tile ].position = self.main_tile_positions[ 11 ]
                
                self.main_tiles[ far_right_tile ].extra.reflection.position = self.main_tile_positions[ 11 ]
                
                local timeline = Timeline{ duration = 150 }
                
                function timeline.on_new_frame( timeline , delta, progress )
                
                    local index = self.main_focused_tile - 4
                    
                    if index < 1 then
                    
                        index = index + #self.main_tiles
                    
                    end
                    
                    for i = 2 , 11 do
                    
                        local start_x = self.main_tile_positions[ i ][ 1 ]
                        local end_x = self.main_tile_positions[ i - 1 ][ 1 ]
                        
                        local tile = self.main_tiles[ index ]
                        
                        tile.x = start_x - ( start_x - end_x ) * progress
                        
                        tile.extra.reflection.x = tile.x
                        
                        if i == 6 then
                        
                            tile.y = 0 + 31 * progress                            
                            tile.scale = { 1 - 0.25 * progress , 1 - 0.25 * progress }
                            
                            tile.extra.reflection.y = tile.y
                            tile.extra.reflection.scale = tile.scale
                            
                        elseif i == 7 then
                        
                            tile.y = 31 - 31 * progress                            
                            tile.scale = { 0.75 + 0.25 * progress , 0.75 + 0.25 * progress }

                            tile.extra.reflection.y = tile.y
                            tile.extra.reflection.scale = tile.scale                        
                        end
                        
                        index = index + 1
                        
                        if index > #self.main_tiles then
                        
                            index = index - #self.main_tiles
                        
                        end
                    
                    end
                
                end
                
                function timeline.on_completed( timeline )
                
                    timeline.on_new_frame = nil
                    timeline.on_completed = nil
                    
                    self.main_focused_tile = self.main_focused_tile + 1
                    
                    self.main_scrolling = false
                    
                    if self.main_focused_tile > #self.main_tiles then
                    
                        self.main_focused_tile = self.main_focused_tile - #self.main_tiles
                    
                    end
                
                end
                
                timeline:start()

                self.main_scrolling = true
            
            elseif keyval == keys.Left then

                -- first, we move a tile to the offscreen position
                
                local far_left_tile = self.main_focused_tile - 5
                
                if far_left_tile < 1 then
                
                    far_left_tile = far_left_tile + #self.main_tiles 
                
                end
                
                self.main_tiles[ far_left_tile ].position = self.main_tile_positions[ 1 ]                
                self.main_tiles[ far_left_tile ].extra.reflection.position = self.main_tile_positions[ 1 ]

                local timeline = Timeline{ duration = 150 }
                
                function timeline.on_new_frame( timeline , delta, progress )
                
                    local index = self.main_focused_tile - 5
                    
                    if index < 1 then
                    
                        index = index + #self.main_tiles
                    
                    end
                    
                    for i = 1 , 10 do
                    
                        local start_x = self.main_tile_positions[ i ][ 1 ]
                        local end_x = self.main_tile_positions[ i + 1 ][ 1 ]
                        
                        local tile = self.main_tiles[ index ]
                        
                        tile.x = start_x + ( end_x - start_x ) * progress
                        tile.extra.reflection.x = tile.x
                        
                        if i == 6 then
                        
                            tile.y = 0 + 31 * progress                            
                            tile.scale = { 1 - 0.25 * progress , 1 - 0.25 * progress }

                            tile.extra.reflection.y = tile.y
                            tile.extra.reflection.scale = tile.scale                        
                            
                        elseif i == 5 then
                        
                            tile.y = 31 - 31 * progress                            
                            tile.scale = { 0.75 + 0.25 * progress , 0.75 + 0.25 * progress }
                        
                            tile.extra.reflection.y = tile.y
                            tile.extra.reflection.scale = tile.scale                                                
                        end
                        
                        index = index + 1
                        
                        if index > #self.main_tiles then
                        
                            index = index - #self.main_tiles
                        
                        end
                    
                    end
                
                end
                
                function timeline.on_completed( timeline )
                
                    timeline.on_new_frame = nil
                    timeline.on_completed = nil
                    
                    self.main_focused_tile = self.main_focused_tile - 1
                    
                    self.main_scrolling = false

                    if self.main_focused_tile < 1 then
                    
                        self.main_focused_tile = self.main_focused_tile + #self.main_tiles
                    
                    end
                
                end
                
                timeline:start()

                self.main_scrolling = true
            
            elseif keyval == keys.Return then
            
                local app_id = self.main_tiles[ self.main_focused_tile ].extra.app_id
                
                if app_id then
                
                    local app_screen = self:load_app_screen( app_id )
                    
                    app_screen.y = screen.h
                    
                    screen:add( app_screen )
                    
                    self.main_screen:animate{ duration = 500 , y = -screen.h }
                    app_screen:animate{ duration = 500 , y = 0 }
                    
                end
            
            end
        
        end,
        
    on_key_down =
    
        function( self , keyval )
            
            if self.app_screen then
            
                local focused = self.app_screen:find_child( self.app_screen_focus )
                
                if focused then
                
                    if keyval == keys.Return and focused.name == "menu_apps_on" then
                    
                        self.main_screen.position = { -screen.w , 0 }
                        
                        self.app_screen:animate{
                            duration = 250 ,
                            x = screen.w ,
                            on_completed =
                                function()
                                    self.app_screen:unparent()
                                    self.app_screen = nil
                                end
                                }
                                
                        self.main_screen:animate{ duration = 250 , x = 0 }
                    
                    else
                    
                        local nav = focused.extra.nav
                        
                        if nav then
                        
                            local new_one = nil
                            
                            if keyval == keys.Right then new_one = nav.r                            
                            elseif keyval == keys.Left then new_one = nav.l                            
                            elseif keyval == keys.Up then new_one = nav.u                            
                            elseif keyval == keys.Down then new_one = nav.d
                            end
                            
                            if new_one then
                            
                                local hide = false
                                
                                if type( new_one ) == "table" then
                                
                                    hide = new_one.hide or false
                                    
                                    new_one = new_one.target
                                
                                end
        
                            
                                self:app_screen_swap( self.app_screen_focus , hide )
                                
                                if hide then
                                
                                    self.app_screen_focus = new_one
                                    
                                    self.app_screen:find_child( new_one ):show()
                                    
                                else
                                
                                    self.app_screen_focus = self:app_screen_swap( new_one )
                                    
                                end
                                
                            end
                        
                        end
                
                    end            
                
                end
                
            elseif self.main_screen then
            
                local main_nav = {
                    { [ keys.Right ] = 2 , [ keys.Down ] = 3 },    -- left featured
                    { [ keys.Left ] = 1 , [ keys.Down ] = 3 },    -- right featured
                    { [ keys.Up ] = 1 , [ keys.Down ] = 4 },    -- categories
                    { [ keys.Up ] = 3 }     -- tiles               
                }
                
                local target = main_nav[ self.main_focus ][ keyval ]
                
                if target then
                
                    self:main_set_focus( target )
                    
                elseif self.main_focus == 4 then
                
                    self:main_tile_key_down( keyval )
                end
                
            end

        end,
}


--ui:load_app_screen( "com.trickplay.1945" )

ui:load_main_screen()

screen:show()

function screen.on_key_down( screen , keyval )

    ui:on_key_down( keyval )

end
