
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
    app =
    {
        background          = { f = "background.jpg" ,            position = { 0 , 0 }      },
        buy_off             = { f = "button-buy-off.png",         position = { 96 , 919 }   , name = "buy_off"  , other = "buy_on" },
        buy_on              = { f = "button-buy-on.png",          position = { 96 , 919 }   , name = "buy_on"   , other = "buy_off" , nav = { u = "menu_games_app_off" , r = "screen1" } },
        loading             = { f = "button-loading.png",         position = { 96 , 919 }   , name = "loading"  },
        play_off            = { f = "button-play-off.png",        position = { 96 , 919 }   , name = "play_off" , other = "play_on"  },
        play_on             = { f = "button-play-on.png",         position = { 96 , 919 }   , name = "play_on"  , other = "play_off" , nav = { u = "menu_games_app_off" , r = "screen1" } },
        menu_search_off     = { f = "menu-0-search-off.png" ,     position = { 40 , 14 }    , name = "menu_search_off" },
        menu_apps_off       = { f = "menu-1-apps-off.png",        position = { 121 , 14 }   , name = "menu_apps_off" },
        menu_games_on       = { f = "menu-2-games-on.png",        position = { 260,  14 }   , name = "menu_games_on" }, 
        menu_games_app_off  = { f = "menu-2-games-app-off.png",   position = { 260 , 14 }   , name = "menu_games_app_off" , other = "menu_games_app_on" },
        menu_games_app_on   = { f = "menu-2-games-app-on.png",    position = { 260 , 14 }   , name = "menu_games_app_on" , other = "menu_games_app_off" , nav = { d = "buy_off" } },
        screen1_on          = { f = "screenshot-1-on.png",        position = { 1285 , 609 } , name = "screen1_on" , other = "screen1" , nav = { u = "menu_games_app_off" , d = "screen2" , l = "buy_off" } },
        screen2_on          = { f = "screenshot-2-on.png",        position = { 1285 , 753 } , name = "screen2_on" , other = "screen2" , nav = { u = "screen1" , d = "screen3" , l = "buy_off" } },
        screen3_on          = { f = "screenshot-3-on.png",        position = { 1285 , 897 } , name = "screen3_on" , other = "screen3" , nav = { u = "screen2" , l = "buy_off" } },
        screen1             = { f = "screenshot-1.png",           position = { 1285 , 609 } , name = "screen1" , other = "screen1_on" },
        screen2             = { f = "screenshot-2.png",           position = { 1285 , 753 } , name = "screen2" , other = "screen2_on" },
        screen3             = { f = "screenshot-3.png",           position = { 1285 , 897 } , name = "screen3" , other = "screen3_on" },
    },
    
    main_screen = nil,  -- A group that holds the main screen
    
    app_screen = nil,   -- A group that holds the app details screen
    
    x_scale = screen.w / 1920,
    
    y_scale = screen.h / 1080,
    
    app_screen_focus = "buy_on",
    
    load_app_screen =
    
        function( self , app_id )
            
            local scale = { self.x_scale , self.y_scale }
            
            local function prepare_image( style , hide )
            
                local image = Image{ scale = scale }
                
                image.src = app_id.."/"..style.f
                
                image.x = style.position[ 1 ] * scale[ 1 ]
                image.y = style.position[ 2 ] * scale[ 2 ]
                
                if style.name then
                    
                    image.name = style.name
                    
                end
                
                image.extra.other = style.other
                
                image.extra.nav = style.nav
                
                if hide then
                    image:hide()
                end
                
                return image
            
            end
            
            
            self.app_screen = Group{ size = screen.size , position = { 0 , 0 } }
            
            self.app_screen:add(
                prepare_image( self.app.background ),
                prepare_image( self.app.menu_search_off ),
                prepare_image( self.app.menu_apps_off ),
                prepare_image( self.app.menu_games_app_off ),
                prepare_image( self.app.menu_games_app_on , true ),
                prepare_image( self.app.buy_on ),
                prepare_image( self.app.buy_off , true ),
                prepare_image( self.app.screen1 ),
                prepare_image( self.app.screen1_on , true ),
                prepare_image( self.app.screen2 ),
                prepare_image( self.app.screen2_on , true ),
                prepare_image( self.app.screen3 ),
                prepare_image( self.app.screen3_on , true )
            )
            
            screen:add( self.app_screen )
    
        end,
        
    app_screen_swap =
    
        function( self , name )
        
            if not self.app_screen then
            
                return
                
            end
            
            local e = self.app_screen:find_child( name )
            
            if e then
            
                e:hide()
                
                e = self.app_screen:find_child( e.extra.other )
                
                if e then
                
                    e:show()
                    
                    return e.name

                end
            
            end
        
        end,
        
    on_key_down =
    
        function( self , keyval )

            if self.app_screen then
            
                local focused = self.app_screen:find_child( self.app_screen_focus )
                
                if focused then
                
                    local nav = focused.extra.nav
                    
                    if nav then
                    
                        local new_one = nil
                        
                        if keyval == keys.Right then new_one = nav.r                            
                        elseif keyval == keys.Left then new_one = nav.l                            
                        elseif keyval == keys.Up then new_one = nav.u                            
                        elseif keyval == keys.Down then new_one = nav.d
                        end
                        
                        if new_one then
                        
                            self:app_screen_swap( self.app_screen_focus )
                            
                            self.app_screen_focus = self:app_screen_swap( new_one )
                            
                        end
                    
                    end
                
                end
                
            end

        end,
}


ui:load_app_screen( "com.trickplay.1945" )

screen:show()

function screen.on_key_down( screen , keyval )

    ui:on_key_down( keyval )

end
