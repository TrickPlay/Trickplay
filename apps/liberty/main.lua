
screen_w = screen.w
screen_h = screen.h

screen:show()

RECORDING_MENU_SIZE = 75
RECORDING_MENU_FONT_FOCUS = "InterstateProBold 75px"
RECORDING_MENU_FONT  = "InterstateProExtraLight 75px"
RECORDING_MENU_COLOR = "FFFFFF"

STORE_MENU_FONT_FOCUS = "InterstateProBold 36px"
STORE_MENU_FONT  = "InterstateProLight 27px"
STORE_MENU_COLOR = "FFFFFF"

MAIN_MENU_FONT_FOCUS = "InterstateProBold 90px"
MAIN_MENU_FONT  = "InterstateProExtraLight 90px"
MAIN_MENU_COLOR = "FFFFFF"
function rand() return 55+20*math.ceil(10*math.random()) end


main = function()
    screen:add(Rectangle{size = screen.size,color = "606060"})
    --------------------------------------------------------------------
    menu_layer = Group()
    make_4movies_icon = dofile("FourMoviesIcon.lua")
    make_sub_menu = dofile("SubMenu.lua")
    --------------------------------------------------------------------
    hidden_assets_group = Group { name = "hidden_assets" }
    hidden_assets_group:hide()
    hidden_assets_group:add(Image{name="cartoon",     src="assets/logos/cartoon.png" })
    hidden_assets_group:add(Image{name="cnn",         src="assets/logos/cnn.png" })
    hidden_assets_group:add(Image{name="mtv",         src="assets/logos/mtv.png" })
    hidden_assets_group:add(Image{name="nationalgeo", src="assets/logos/nationalgeo.png" })
    hidden_assets_group:add(Image{name="nationalgeo1",src="assets/logos/nationalgeo1.png" })
    hidden_assets_group:add(Image{name="netherland1", src="assets/logos/netherland1.png" })
    hidden_assets_group:add(Image{name="netherland2", src="assets/logos/netherland2.png" })
    hidden_assets_group:add(Image{name="rtl4",        src="assets/logos/rtl4.png" })
    hidden_assets_group:add(Image{name="rtl4-1",      src="assets/logos/rtl4-1.png" })
    hidden_assets_group:add(Image{name="sb6",         src="assets/logos/sb6.png" })
    hidden_assets_group:add(Image{name="sport1",      src="assets/logos/sport1.png" })
    hidden_assets_group:add(Image{name="upclogo",     src="assets/logos/upclogo.png" })
    hidden_assets_group:add(Image{name="cursor_line", src="assets/menu-cursor-laser.png"})
    hidden_assets_group:add(Image{name="tp_sprite",   src="assets/trick-play_02.png"    })
    hidden_assets_group:add(Image{name="epg_row_bg",  src="assets/epg/channel-bg.png",tile = {true,true},w = screen_w    })
    hidden_assets_group:add(Image{name="show_border", src="assets/epg/show-border.png"})
    screen:add(hidden_assets_group)
    --------------------------------------------------------------------
    local backdrop_maker = dofile("backdrop.lua")
    backdrop = backdrop_maker:make_backdrop()
    screen:add(backdrop)
    
    --------------------------------------------------------------------
    
    make_cursor = function(w)
        local cursor_line = hidden_assets_group:find_child("cursor_line")
        return Group{
            name = "cursor",
            children = {
                Clone{
                    source = cursor_line,
                    anchor_point = {cursor_line.w/2,cursor_line.h/2},
                    scale = {screen_w / cursor_line.w,1080/720},
                },
                Rectangle{
                    w = w,
                    h = 16,
                    anchor_point = {w/2,8},
                },
            }
        }
    end
    
    
    --------------------------------------------------------------------
    --floor = dofile("Floor.lua")
    main_menu = dofile("MainMenu.lua")
    main_menu.y = 790
    main_menu.name = "main_menu"
    
    --------------------------------------------------------------------
    
    dofile("Internet.lua")
    
    make_proxy, clone_proxy  = dofile("ChannelIconProxy.lua")
    make_bolding_text        = dofile("BoldingText.lua")
    local make_curr_ch_menu  = dofile("CurrentChannel.lua")
    local make_category_menu = dofile("CategoryMenu.lua")
    local make_dosado_menu   = dofile("DosadoMenu.lua")
    local make_movie_menu    = dofile("MovieMenu.lua")
    local make_vertical_menu = dofile("VerticalList.lua")
    local make_channel_menu  = dofile("ChannelMenu.lua")
    --------------------------------------------------------------------
    --  My Current Channel Menu
    --------------------------------------------------------------------
    curr_ch_menu = make_curr_ch_menu()
    --------------------------------------------------------------------
    --  EPG Menu
    --------------------------------------------------------------------
    epg_menu = dofile("EPG.lua")
    --------------------------------------------------------------------
    --  My Library Menu
    --------------------------------------------------------------------
    function make_my_library_category()
        local animating = false
        local icon = make_4movies_icon()
        function icon:on_key_down(k) 
            if keys.OK == k then
                if animating then return end
                animating = true
                
                menu_layer:add(my_dvr_menu)
                my_dvr_menu:lower_to_bottom()
                my_dvr_menu.z = -300
                my_dvr_menu.opacity = 0
                
                dolater(function()
                my_library_menu:animate{
                    duration = 300,
                    z = 300,
                    opacity = 0,
                    on_completed = function()
                        animating = false
                    end
                }
                my_dvr_menu:grab_key_focus()
                end)
            end
        end
        return icon
    end
    my_library_menu = make_dosado_menu{
        prev_menu = main_menu,
        upper = make_category_menu{
            {label = "RECENTLY ADDED", icon = make_my_library_category()},
            {label = "MY DEVICES",     icon = make_my_library_category()},
            {label = "PLANNER",        icon = make_my_library_category()},
            {label = "MY MUSIC",       icon = make_my_library_category()},
        },
        lower = make_category_menu{
            {label = "MY DVR",    icon = make_my_library_category()},
            {label = "MY VIDEOS", icon = make_my_library_category()},
            {label = "MY PHOTOS", icon = make_my_library_category()},
            {label = "MY APPS",   icon = make_my_library_category()},
        },
    }
    my_library_menu.z = -300
    --------------------------------------------------------------------
    --  My Library Menu > My DVR Menu
    --------------------------------------------------------------------
    function make_recording()
        local animating = false
        local icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}
        function icon:on_key_down(k) 
            if keys.OK == k then
                if animating then return end
                animating = true
                
                menu_layer:add(recording_menu)
                recording_menu:lower_to_bottom()
                recording_menu.z = -300
                recording_menu.opacity = 0
                
                dolater(function()
                my_dvr_menu:animate{
                    duration = 300,
                    z = 300,
                    opacity = 0,
                    on_completed = function()
                        animating = false
                    end
                }
                recording_menu:grab_key_focus()
                end)
            end
        end
        return icon
    end
    my_dvr_menu = make_dosado_menu{
        prev_menu = my_library_menu,
        upper = make_movie_menu{
            {label = "Recording A", icon = make_recording()},
            {label = "Recording B", icon = make_recording()},
            {label = "Recording C", icon = make_recording()},
            {label = "Recording D", icon = make_recording()},
            {label = "Recording E", icon = make_recording()},
            {label = "Recording F", icon = make_recording()},
            {label = "Recording G", icon = make_recording()},
            {label = "Recording H", icon = make_recording()},
            {label = "Recording I", icon = make_recording()},
            {label = "Recording J", icon = make_recording()},
        },
        lower = make_movie_menu{
            {label = "Recording A", icon = make_recording()},
            {label = "Recording B", icon = make_recording()},
            {label = "Recording C", icon = make_recording()},
            {label = "Recording D", icon = make_recording()},
            {label = "Recording E", icon = make_recording()},
            {label = "Recording F", icon = make_recording()},
            {label = "Recording G", icon = make_recording()},
            {label = "Recording H", icon = make_recording()},
            {label = "Recording I", icon = make_recording()},
            {label = "Recording J", icon = make_recording()},
        },
        upper_y = 500,
        type = "flat",
    }
    my_dvr_menu.z = -300
    --------------------------------------------------------------------
    --  My Library Menu > My DVR Menu > Recording Menu
    --------------------------------------------------------------------
    recording_menu = make_vertical_menu{
        "PAUSE",
        "RECORD",
        "START OVER",
        "RELATED",
        "RATE",
        "ADD TO FAVORITES",
        "SEARCH",
        "A/V SETTINGS",
        "MORE LIKE THIS",
        "INFO",
    }
    recording_menu.y = screen_h - recording_menu.h
    recording_menu.x = 1000
    recording_menu.z = -300
    --------------------------------------------------------------------
    --  Store Menu
    --------------------------------------------------------------------
    function make_all_videos_icon()
        local animating = false
        local icon = make_4movies_icon()
        function icon:on_key_down(k) 
            if keys.OK == k then
                if animating then return end
                animating = true
                
                menu_layer:add(all_videos_menu)
                all_videos_menu:lower_to_bottom()
                all_videos_menu.z = -300
                all_videos_menu.opacity = 0
                
                dolater(function()
                store_menu:animate{
                    duration = 300,
                    z = 300,
                    opacity = 0,
                    on_completed = function()
                        animating = false
                    end
                }
                all_videos_menu:grab_key_focus()
                end)
            end
        end
        return icon
    end
    store_menu = make_dosado_menu{
        prev_menu = main_menu,
        upper = make_movie_menu{
            {label = "Movie A", icon = Rectangle{w=180,h=270,color={rand(),rand(),rand(),}}},
            {label = "Movie B", icon = Rectangle{w=180,h=270,color={rand(),rand(),rand(),}}},
            {label = "Movie C", icon = Rectangle{w=180,h=270,color={rand(),rand(),rand(),}}},
            {label = "Movie D", icon = Rectangle{w=180,h=270,color={rand(),rand(),rand(),}}},
            {label = "Movie E", icon = Rectangle{w=180,h=270,color={rand(),rand(),rand(),}}},
            {label = "Movie F", icon = Rectangle{w=180,h=270,color={rand(),rand(),rand(),}}},
            {label = "Movie G", icon = Rectangle{w=180,h=270,color={rand(),rand(),rand(),}}},
            {label = "Movie H", icon = Rectangle{w=180,h=270,color={rand(),rand(),rand(),}}},
            {label = "Movie I", icon = Rectangle{w=180,h=270,color={rand(),rand(),rand(),}}},
            {label = "Movie J", icon = Rectangle{w=180,h=270,color={rand(),rand(),rand(),}}},
        },
        lower = make_category_menu{
            {label = "ALL VIDEOS",            icon = make_all_videos_icon()},
            {label = "RECOMMENDATIONS",       icon = make_4movies_icon()},
            {label = "SERVICES & ACCESSORIES",icon = make_4movies_icon()},
            {label = "APPS & WIDGETS",        icon = make_4movies_icon()},
        },
        upper_y = 250,
        lower_y = 825,
    }
    store_menu.z = -300
    store_menu.name = "store_menu"
    --------------------------------------------------------------------
    --  Store Menu > All Videos Menu
    --------------------------------------------------------------------
    function make_all_videos_category()
        local animating = false
        local icon = make_4movies_icon()
        function icon:on_key_down(k) 
            if keys.OK == k then
                if animating then return end
                animating = true
                
                menu_layer:add(movies_menu)
                movies_menu:lower_to_bottom()
                movies_menu.z = -300
                movies_menu.opacity = 0
                
                dolater(function()
                all_videos_menu:animate{
                    duration = 300,
                    z = 300,
                    opacity = 0,
                    on_completed = function()
                        animating = false
                    end
                }
                movies_menu:grab_key_focus()
                end)
            end
        end
        return icon
    end
    all_videos_menu = make_dosado_menu{
        prev_menu = store_menu,
        upper = make_category_menu{
            {label = "MOVIES", icon = make_all_videos_category()},
            {label = "SPORT",  icon = make_all_videos_category()},
            {label = "SERIES", icon = make_all_videos_category()},
            {label = "KIDS",   icon = make_all_videos_category()},
        },
        lower = make_category_menu{
            {label = "DOCUMENTARY", icon = make_all_videos_category()},
            {label = "ACTION",      icon = make_all_videos_category()},
            {label = "ANIME",       icon = make_all_videos_category()},
            {label = "INFO",        icon = make_all_videos_category()},
        },
    }
    all_videos_menu.z = -300
    --------------------------------------------------------------------
    --  Store Menu > All Videos Menu > Movie Menu
    --------------------------------------------------------------------
    movies_menu = make_dosado_menu{
        prev_menu = all_videos_menu,
        upper = make_movie_menu{
            {label = "Movie A", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie B", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie C", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie D", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie E", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie F", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie G", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie H", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie I", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie J", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
        },
        lower = make_movie_menu{
            {label = "Movie A", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie B", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie C", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie D", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie E", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie F", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie G", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie H", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie I", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
            {label = "Movie J", icon = Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}},
        },
        upper_y = 500,
        type = "flat",
    }
    movies_menu.z = -300
    --------------------------------------------------------------------
    channel_menu = make_channel_menu{
        "cartoon",     
        "cnn",         
        "mtv",         
        "nationalgeo", 
        "nationalgeo1",
        "netherland1", 
        "netherland2", 
        "rtl4",        
        "rtl4-1",      
        "sb6",         
        "sport1", 
    }
    channel_menu.x = 200
    --------------------------------------------------------------------
    
    currently_playing_content = dofile("CurrentContent.lua")
    --------------------------------------------------------------------
    
    get_channel_list(function(channels)
        
        if type(channels) ~= "table" or type(channels.Channels) ~= "table" or type(channels.Channels.Channel) ~= "table" then
            print("get_channel_list got bad data")
            return
        end
        
        for i,channel in ipairs(channels.Channels.Channel) do
            --print("--------------------------------------------------------------------")
            --dumptable(channel)
            if type(channel) ~= "table" or 
                type(channel.Name) ~= "string" or 
                type(channel.Pictures) ~= "table" or 
                type(channel.Pictures.Picture[1]) ~= "table" or 
                type(channel.Pictures.Picture[1].Value) ~= "string" then 
                
                print("get_channel_list got bad entry")
                return 
            end
            make_proxy(
                
                channel.Name,
                
                channel.Pictures.Picture[1].Value
                
            )
        end
        
        epg_menu:setup_icons(channels.Channels.Channel)
        
    end)
    ---[[
    get_scheduling(function(t)
        epg_menu:load_scheduling(t)
    end)--]]
    --------------------------------------------------------------------
    menu_layer:add(
        --movies_menu,
        --all_videos_menu,
        --store_menu,
        --recording_menu,
        --my_dvr_menu,
        --my_library_menu,
        main_menu
        --channel_menu,
        --curr_ch_menu,
        --epg_menu,
        --currently_playing_content
    )
    --my_library_menu:hide()
    screen:add(menu_layer)
    
    main_menu:grab_key_focus()
end

dolater(main)
     