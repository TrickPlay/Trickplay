
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
    --screen:add(Rectangle{size = screen.size,color = "606060"})
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
    hidden_assets_group:add(Image{name="epg_row_hl",  src="assets/epg/epg-focus-bg.png"})
    hidden_assets_group:add(Image{name="show_border", src="assets/epg/show-border.png"})
    hidden_assets_group:add(Image{name="tp-bold-beg",   src="assets/control_menu/control-bar-bold-beg.png"})
    hidden_assets_group:add(Image{name="tp-bold-end",   src="assets/control_menu/control-bar-bold-end.png"})
    hidden_assets_group:add(Image{name="tp-bold-ff",    src="assets/control_menu/control-bar-bold-ff.png"})
    hidden_assets_group:add(Image{name="tp-bold-pause", src="assets/control_menu/control-bar-bold-pause.png"})
    hidden_assets_group:add(Image{name="tp-bold-rew",   src="assets/control_menu/control-bar-bold-rew.png"})
    hidden_assets_group:add(Image{name="tp-bold-stop",  src="assets/control_menu/control-bar-bold-stop.png"})
    hidden_assets_group:add(Image{name="tp-thin-beg",   src="assets/control_menu/control-bar-thin-beg.png"})
    hidden_assets_group:add(Image{name="tp-thin-end",   src="assets/control_menu/control-bar-thin-end.png"})
    hidden_assets_group:add(Image{name="tp-thin-ff",    src="assets/control_menu/control-bar-thin-ff.png"})
    hidden_assets_group:add(Image{name="tp-thin-pause", src="assets/control_menu/control-bar-thin-pause.png"})
    hidden_assets_group:add(Image{name="tp-thin-rew",   src="assets/control_menu/control-bar-thin-rew.png"})
    hidden_assets_group:add(Image{name="tp-thin-stop",  src="assets/control_menu/control-bar-thin-stop.png"})
    hidden_assets_group:add(Image{name="epg_glow",  src="assets/new-glow-logos.png"})
    screen:add(hidden_assets_group)
    --------------------------------------------------------------------
    posters = Group { name = "posters" }
    posters:add(Image{src="assets/posters-220x320/70336-2.png"})
    posters:add(Image{src="assets/posters-220x320/70708-2.png"})
    posters:add(Image{src="assets/posters-220x320/70814-2.png"})
    posters:add(Image{src="assets/posters-220x320/71256-2.png"})
    posters:add(Image{src="assets/posters-220x320/71753-1.png"})
    posters:add(Image{src="assets/posters-220x320/71998-3.png"})
    posters:add(Image{src="assets/posters-220x320/72480-1.png"})
    posters:add(Image{src="assets/posters-220x320/73244-7.png"})
    posters:add(Image{src="assets/posters-220x320/73387-1.png"})
    posters:add(Image{src="assets/posters-220x320/73532-1.png"})
    posters:add(Image{src="assets/posters-220x320/74326-1.png"})
    posters:add(Image{src="assets/posters-220x320/75088-2.png"})
    posters:add(Image{src="assets/posters-220x320/75864-1.png"})
    posters:add(Image{src="assets/posters-220x320/76703-9.png"})
    posters:add(Image{src="assets/posters-220x320/79274-2.png"})
    posters:add(Image{src="assets/posters-220x320/79488-7.png"})
    posters:add(Image{src="assets/posters-220x320/79491-2.png"})
    posters:add(Image{src="assets/posters-220x320/79824-6.png"})
    posters:add(Image{src="assets/posters-220x320/81391-1.png"})
    posters:add(Image{src="assets/posters-220x320/81559-1.png"})
    posters:add(Image{src="assets/posters-220x320/84041-1.png"})
    posters:add(Image{src="assets/posters-220x320/84489-2.png"})
    posters:add(Image{src="assets/posters-220x320/84912-2.png"})
    posters:add(Image{src="assets/posters-220x320/85190-3.png"})
    posters:add(Image{src="assets/posters-220x320/85355-3.png"})
    posters:add(Image{src="assets/posters-220x320/110381-2.png"})
    posters:add(Image{src="assets/posters-220x320/114851-1.png"})
    posters:add(Image{src="assets/posters-220x320/127351-1.png"})
    posters:add(Image{src="assets/posters-220x320/138981-1.png"})
    posters:add(Image{src="assets/posters-220x320/165591-1.png"})
    posters:add(Image{src="assets/posters-220x320/183231-3.png"})
    posters:add(Image{src="assets/posters-220x320/193941-1.png"})
    posters:add(Image{src="assets/posters-220x320/194751-4.png"})
    posters:add(Image{src="assets/posters-220x320/205731-2.png"})
    posters:add(Image{src="assets/posters-220x320/219621-1.png"})
    posters:add(Image{src="assets/posters-220x320/242801-2.png"})
    posters:add(Image{src="assets/posters-220x320/248735-3.png"})
    posters:add(Image{src="assets/posters-220x320/248943-2.png"})
    posters:add(Image{src="assets/posters-220x320/252290-1.png"})
    posters:add(Image{src="assets/posters-220x320/253682-1.png"})
    posters:add(Image{src="assets/posters-220x320/253931-1.png"})
    posters:add(Image{src="assets/posters-220x320/254734-1.png"})
    posters:add(Image{src="assets/posters-220x320/255573-1.png"})
    posters:add(Image{src="assets/posters-220x320/256523-1.png"})
    hidden_assets_group:add(posters)
    posters = posters.children
    random_poster = function()
        return posters[math.ceil(math.random()*(#posters-1))+1]
    end
    --------------------------------------------------------------------
    local backdrop_maker = dofile("backdrop.lua")
    backdrop = backdrop_maker:make_backdrop()
    screen:add(backdrop)
    
    --------------------------------------------------------------------
    
    make_cursor = function(w)
        local cursor_line = hidden_assets_group:find_child("cursor_line")
        local box = Rectangle{
            w = w,
            h = 16,
            x = -w/2,
            anchor_point = {0,8},
        }
        cursor_line =  Group{
            name = "cursor",
            children = {
                Clone{
                    source = cursor_line,
                    anchor_point = {cursor_line.w/2,cursor_line.h/2},
                    scale = {screen_w / cursor_line.w,1080/720},
                },
                box,
            }
        }
        function cursor_line:change_w(new_w)
            box:animate{
                duration = 300,
                w =  new_w,
                x = -new_w/2,
            }
        end
        
        return cursor_line
    end
    
    
    dofile("Internet.lua")
    
    make_proxy, clone_proxy  = dofile("ChannelIconProxy.lua")
    make_bolding_text        = dofile("BoldingText.lua")
    --------------------------------------------------------------------
    --floor = dofile("Floor.lua")
    main_menu = dofile("MainMenu.lua")
    main_menu.y = 790
    main_menu.name = "main_menu"
    
    --------------------------------------------------------------------
    
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
        local icon = make_4movies_icon(350)
        function icon:on_key_down(k) 
            if keys.OK == k then
                if  my_library_menu.is_animating or 
                    my_dvr_menu.is_animating or 
                    animating then 
                        
                        return 
                end
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
    
    local my_dvr_menu_animating = false
    local animate_to_recording_menu = function()
        if  my_dvr_menu.is_animating or 
            recording_menu.is_animating or 
            my_dvr_menu_animating then 
                
                return 
        end
        my_dvr_menu_animating = true
        
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
                my_dvr_menu_animating = false
            end
        }
        recording_menu:grab_key_focus()
        end)
    end
    my_dvr_menu = make_dosado_menu{
        prev_menu = my_library_menu,
        upper = make_movie_menu{
            w = 200,h=300,
            next_menu = animate_to_recording_menu,
            {label = "Recording A", icon = random_poster()},
            {label = "Recording B", icon = random_poster()},
            {label = "Recording C", icon = random_poster()},
            {label = "Recording D", icon = random_poster()},
            {label = "Recording E", icon = random_poster()},
            {label = "Recording F", icon = random_poster()},
            {label = "Recording G", icon = random_poster()},
            {label = "Recording H", icon = random_poster()},
            {label = "Recording I", icon = random_poster()},
            {label = "Recording J", icon = random_poster()},
        },
        lower = make_movie_menu{
            w = 200,h=300,
            next_menu = animate_to_recording_menu,
            {label = "Recording A", icon = random_poster()},
            {label = "Recording B", icon = random_poster()},
            {label = "Recording C", icon = random_poster()},
            {label = "Recording D", icon = random_poster()},
            {label = "Recording E", icon = random_poster()},
            {label = "Recording F", icon = random_poster()},
            {label = "Recording G", icon = random_poster()},
            {label = "Recording H", icon = random_poster()},
            {label = "Recording I", icon = random_poster()},
            {label = "Recording J", icon = random_poster()},
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
        local icon = make_4movies_icon(350)
        function icon:on_key_down(k) 
            if keys.OK == k then
                if  all_videos_menu.parent or
                    store_menu.is_animating or 
                    all_videos_menu.is_animating or 
                    animating then 
                        
                        return 
                end
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
            w=180,h=270,
            --next_menu = store_menu,
            --Rectangle{w=180,h=270,color={rand(),rand(),rand(),}}
            {label = "Movie A", icon = random_poster()},
            {label = "Movie B", icon = random_poster()},
            {label = "Movie C", icon = random_poster()},
            {label = "Movie D", icon = random_poster()},
            {label = "Movie E", icon = random_poster()},
            {label = "Movie F", icon = random_poster()},
            {label = "Movie G", icon = random_poster()},
            {label = "Movie H", icon = random_poster()},
            {label = "Movie I", icon = random_poster()},
            {label = "Movie J", icon = random_poster()},
        }:set{extra={icon_w = 180}},
        lower = make_category_menu{
            {label = "ALL VIDEOS",            icon = make_all_videos_icon()},
            {label = "RECOMMENDATIONS",       icon = make_4movies_icon(350)},
            {label = "SERVICES & ACCESSORIES",icon = make_4movies_icon(350)},
            {label = "APPS & WIDGETS",        icon = make_4movies_icon(350)},
        }:set{extra={icon_w = (183+168+153+140+124)}},
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
        local icon = make_4movies_icon(350)
        function icon:on_key_down(k) 
            if keys.OK == k then
                if  movies_menu.parent or
                    all_videos_menu.is_animating or 
                    movies_menu.is_animating or 
                    animating then 
                        
                        return 
                end
                
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
            w=200,h=300,
            --Rectangle{w=200,h=300,color={rand(),rand(),rand(),}}
            {label = "Movie A", icon = random_poster()},
            {label = "Movie B", icon = random_poster()},
            {label = "Movie C", icon = random_poster()},
            {label = "Movie D", icon = random_poster()},
            {label = "Movie E", icon = random_poster()},
            {label = "Movie F", icon = random_poster()},
            {label = "Movie G", icon = random_poster()},
            {label = "Movie H", icon = random_poster()},
            {label = "Movie I", icon = random_poster()},
            {label = "Movie J", icon = random_poster()},
        },
        lower = make_movie_menu{
            w=200,h=300,
            {label = "Movie A", icon = random_poster()},
            {label = "Movie B", icon = random_poster()},
            {label = "Movie C", icon = random_poster()},
            {label = "Movie D", icon = random_poster()},
            {label = "Movie E", icon = random_poster()},
            {label = "Movie F", icon = random_poster()},
            {label = "Movie G", icon = random_poster()},
            {label = "Movie H", icon = random_poster()},
            {label = "Movie I", icon = random_poster()},
            {label = "Movie J", icon = random_poster()},
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
    
    trick_play_menu = dofile("TrickPlayMenu.lua")
    
    
    trick_play_menu.x = screen_w/2
    trick_play_menu.y = 715
    --------------------------------------------------------------------
    
    currently_playing_content = dofile("CurrentContent.lua")
    --------------------------------------------------------------------
    
    get_channel_list(function(channels)
        
        if  type(channels) ~= "table" or 
            type(channels.Channels) ~= "table" or 
            type(channels.Channels.Channel) ~= "table" then
            
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
            
            local pic
            for i,p in ipairs(channel.Pictures.Picture) do
                if p.type == "Logo" then
                    pic = p.Value
                    break;
                end
            end
            make_proxy(
                
                channel.Name,
                
                pic
                
            )
        end
        
        epg_menu:setup_icons(  channels.Channels.Channel )
        channel_menu:populate( channels.Channels.Channel )
    end)
    ---[[
    get_scheduling(function(t,old)
        if  type(t) ~= "table" or 
            type(t.Channels) ~= "table" or 
            type(t.Channels.Channel) ~= "table" then
            
            print("get_scheduling got bad data")
            return
        end
        epg_menu:load_scheduling(t,old)
    end)--]]
    --[[
    local titles_callback = function(t,parent)
        
        if type(t) ~= "table" then
            return
        end
        t = t.Category
        if type(t) ~= "table" then
            return
        end
        t = t.Titles
        if type(t) ~= "table" then
            return
        end
        t = t.Title
        if type(t) ~= "table" then
            return
        end
        for i,t in pairs(t) do
            --dumptable(t)
            if  type(t) == "table" and
                type(t.Pictures) == "table" and
                type(t.Pictures.Picture) == "table" and
                type(t.Pictures.Picture[1]) == "table" and
                type(t.Pictures.Picture[1].Value) == "table" then
                
                parent[t.Name] = t.Pictures.Picture[1].Value
            else
                 parent[t.Name] = false
            end
        end
        
    end
    local category_response
    tree = {}
   category_response = function(response,parent,only_tranverse_this)
        
        if type(response) ~= "table" then
            return
        end
        if type(response.Category) ~= "table" then
            return
        end
        response = response.Category
        
        print(response.Name)
        if only_tranverse_this ~= nil and only_tranverse_this ~= response.Name then
            parent[response.Name] = "Do not traverse"
            return
        end
        parent[response.Name] = {}
        if response.TitleCount > 1 then
            get_titles(response.id,titles_callback,parent[response.Name])
            return
        end
        if response.ChildCategoryCount < 1 then
            return
        end
        if type(response.ChildCategories) ~= "table" then
            return
        end
        --dumptable(tree)
        for i=1,response.ChildCategoryCount do
            if type(response.ChildCategories.Category[i]) ~= "table" then
                return
            end
            get_category_info(response.ChildCategories.Category[i].id,category_response,parent[response.Name])
        end
    end
    get_root_categories(function(response)
        
        if type(response) ~= "table" then
            return
        end
        if type(response.Categories) ~= "table" then
            return
        end
        response = response.Categories
        if response.resultCount < 1 then
            return
        end
        if response.resultCount > 1 then
            return
        end
        if type(response.Category) ~= "table" then
            return
        end
        response = response.Category[1]
        
        if response.ChildCategoryCount < 1 then
            return
        end
        if type(response.ChildCategories) ~= "table" then
            return
        end
        tree[response.Name] = {}
        for i=1,response.ChildCategoryCount do
            if type(response.ChildCategories.Category[i]) ~= "table" then
            end
            get_category_info(response.ChildCategories.Category[i].id,category_response,tree[response.Name],"Demo")
        end
    end,tree)
    --]]
    --------------------------------------------------------------------
    menu_layer:add(
        --movies_menu,
        --all_videos_menu,
        --store_menu,
        --recording_menu,
        --my_dvr_menu,
        --my_library_menu,
        main_menu--,trick_play_menu
        --channel_menu,
        --curr_ch_menu,
        --epg_menu,
        --currently_playing_content
    )
    --my_library_menu:hide()
    screen:add(menu_layer)
    
    main_menu:grab_key_focus()
    --[[
    mediaplayer:load("glee-1.mp4")
    
    function mediaplayer:on_loaded()
        
        mediaplayer:play()
        mediaplayer.volume = 0
    end
    function mediaplayer:on_end_of_stream()
        mediaplayer:seek(0)
        mediaplayer:play()
    end
    --]]
end

dolater(main)
     