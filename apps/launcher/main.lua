
--dolater...
local function main()
    
    
    ----------------------------------------------------------------------------
    -- Image Sources
    ----------------------------------------------------------------------------
    
    local imgs = {
        --
        overlay    = Image{src = "assets/gloss-small.png"},
        featured   = Image{src = "assets/featured-banner.png"},
        tw_focus   = Image{src = "assets/share_menu/icon-twitter-on.png"},
        tw_unfocus = Image{src = "assets/share_menu/icon-twitter-off.png"},
        fb_focus   = Image{src = "assets/share_menu/icon-facebook-on.png"},
        fb_unfocus = Image{src = "assets/share_menu/icon-facebook-off.png"},
        icon_overlay = Image{src = "assets/icon-overlay.png"},
        --App Shop KB Pieces
        app_shop_1  = Image{ src = "assets/app_shop/appshop-1.jpg"},
        app_shop_2  = Image{ src = "assets/app_shop/appshop-2.jpg"},
        hulu_1      = Image{ src = "assets/app_shop/hulu-1.jpg"},
        trueblood_1 = Image{ src = "assets/app_shop/truebloodcomics-1.jpg"},
        
        --Showcase KB Pieces
        burberry_1  = Image{ src = "assets/showcase/burberry-1.jpg"},
        burberry_2  = Image{ src = "assets/showcase/burberry-2.jpg"},
        burberry_3  = Image{ src = "assets/showcase/burberry-3.jpg"},
        dew_1       = Image{ src = "assets/showcase/dew-1.jpg"},
        dew_2       = Image{ src = "assets/showcase/dew-2.jpg"},
        dew_3       = Image{ src = "assets/showcase/dew-3.jpg"},
        jype_1      = Image{ src = "assets/showcase/jype-1.jpg"},
        jype_2      = Image{ src = "assets/showcase/jype-2.jpg"},
        jype_3      = Image{ src = "assets/showcase/jype-3.jpg"},
        
        overlay = Image{src = "assets/gloss-medium.png"},
        caption_grad = Image{src = "assets/lower-gradient.png"},
    }
    
    
    local srcs = Group{name="Hidden Clone Sources"}
    
    srcs:hide()
    screen:add(srcs)
    
    for k,v in pairs(imgs) do
        srcs:add(v)
    end
    --srcs:add(unpack(imgs))
    
    
    local launcher_icons = {}
    launcher_icons["generic"] = Image{src="assets/generic-app-icon.jpg"}
    srcs:add( launcher_icons["generic"] )
    local app_list = apps:get_for_current_profile()
    for k,v in pairs(app_list) do
        
        local i = Image{}
        if not v.attributes.nolauncher    and
            i:load_app_icon(v.id,"launcher-icon.png") or
            i:load_app_icon(v.id,"launcher-icon.jpg") then
            
            launcher_icons[v.id] = i
            srcs:add(i)
        end
        
    end
    --dumptable(launcher_icons)
    shop_icons = {
        Image{src="assets/app_shop_icons/1945.jpg"},
        Image{src="assets/app_shop_icons/aquaria.jpg"},
        Image{src="assets/app_shop_icons/billiards.jpg"},
        Image{src="assets/app_shop_icons/candyland.jpg"},
        Image{src="assets/app_shop_icons/carlsberg.jpg"},
        Image{src="assets/app_shop_icons/cowtipper.jpg"},
        Image{src="assets/app_shop_icons/hbo.jpg"},
        Image{src="assets/app_shop_icons/hulu.jpg"},
        Image{src="assets/app_shop_icons/idol.jpg"},
        Image{src="assets/app_shop_icons/life.jpg"},
        Image{src="assets/app_shop_icons/nba.jpg"},
        Image{src="assets/app_shop_icons/nfl.jpg"},
        Image{src="assets/app_shop_icons/poker.jpg"},
        Image{src="assets/app_shop_icons/pvz.jpg"},
        Image{src="assets/app_shop_icons/solitaire.jpg"},
        Image{src="assets/app_shop_icons/spirals.jpg"},
        Image{src="assets/app_shop_icons/trueblood.jpg"},
    }
    
    srcs:add(unpack(shop_icons))
    
    
    
    do
        
        local l = dofile("localized:strings.lua")
        
        function _L(s) return l[s] or s end
        
    end
    
    ----------------------------------------------------------------------------
    -- dofiles's
    ----------------------------------------------------------------------------
    
    local canvas_srcs = dofile("CanvasCloneSources")
    
    local vt = dofile("VideoTile.lua")
    
    local vtb = dofile("VideoTileBar.lua")
    
    local kb =  dofile("KenBurns.lua")
    
    local my_app_list = dofile("MyAppsList.lua")
    
    local HL = dofile("VideoTileSlider.lua")
    
    local clouds =  dofile("MyAppsBg.lua")
    
    local mkb = dofile("MulitKenBurns.lua")
    
    local aic = dofile("AppIconCarousel.lua")
    
    ----------------------------------------------------------------------------
    -- init's
    ----------------------------------------------------------------------------
    
    canvas_srcs:init{
        
        launcher_frame_w               = 4*48,
        launcher_frame_h               = 4*27,
        launcher_frame_border          = 2,
        launcher_frame_border_gradient = 7,
        
        video_tile_inner_width   = 547,
        video_tile_border_width  = 3,
        video_tile_corner_radius = 10,
        video_tile_font          = "FreeSans Medium 32px",
        
        my_apps_hl_w        = 300,
        my_apps_hl_h        = 150,
        my_apps_hl_shadow_h = 20,
        
        arrow_size = 16,
        
    }
    
    vt:init{
        shrunken_h  = 100,
        expanded_h  = 900,
        inner_w     = 547,
        canvas_srcs = canvas_srcs,
        img_srcs    = srcs,
        max_vis_len = 12,
        font        = "FreeSans Medium 32px",
    }
    
    kb:init{}
    
    
    HL:init{
        imgs = imgs,
        img_srcs    = srcs,
        canvas_srcs = canvas_srcs,
        main_font   = "FreeSans Medium 28px",
        sub_font    = "FreeSans Bold 24px",
        icon_size   = {116/270*480,116},
    }
    
    mkb:init{
        overlay_src  = imgs.overlay,
        gradient_src = imgs.caption_grad,
        title_font   = "FreeSans Bold 24px",
        caption_font = "FreeSans Medium 24px",
        ken_burns    = kb,
    }
    
    ----------------------------------------------------------------------------
    -- Create Components
    ----------------------------------------------------------------------------
    
    
    -- My Apps   Video Tile
    ----------------------------------------------------------------------------
    
    my_apps_closed = aic:create{
        launcher_icons = launcher_icons,
        icon_w   = 480,
        vis_w    = 547,
        duration = 10000,
    }
    
    do
        local icon_size   = {116/270*480,116}
        local prev  = Clone{
            size = icon_size
        }
        local next  = Clone{
            size = icon_size,
            position = {icon_size[1]/2,icon_size[2]/2},
            anchor_point = {icon_size[1]/2,icon_size[2]/2}
        }
        local caption = Text{  name = "caption", font = "FreeSans Medium 30px",x = 240,y=35, ellipsize = "END", w = 310}
        
        myAppsHL = HL:create{
            logical_parent = my_app_list,
            contents = Group{
                children = {
                    prev,
                    next,
                    Clone{
                        source = imgs.icon_overlay,
                        w   = icon_size[1]+2, --stupid icons dont match up even though they're the same size...
                        h   = icon_size[2],
                    },
                    caption,
                }
            },
            focus = function(self,text,icon,id)
                self.app_id = id
                
                caption.text = text
                prev.source  = next.source
                next.source  = icon.source
                next.scale   = {0,0}
                
                next:animate{
                    duration = 100,
                    scale    = {1,1},
                }
            end
        }
    end
    
    
    my_app_list:init{
        launcher_icons=launcher_icons,
        app_list=app_list,
        max_vis_len = 10,
        slider = myAppsHL,
        frame=canvas_srcs.launcher_icon_frame,--imgs.icon_overlay,
    }
    
    clouds:init{
        img_srcs  = srcs,
        visible_w = 600,
        visible_h = 1000,
    }
    
    -- Showcase   Video Tile
    ----------------------------------------------------------------------------
    
    
    showcase = Group{}
    
    do
        
        local title   = Text{  name = "title",   font = "FreeSans Bold 26px",  x = 26,y=26}
        local caption = Text{  name = "caption", font = "FreeSans Medium 24px",x = 26,y=57}
        
        showcaseHL = HL:create{
            logical_parent = showcase,
            contents = Group{
                children = {
                    title,
                    caption,
                }
            },
            focus = function(self,new_title,new_caption,id)
                self.app_id = id
                
                title.text   = new_title
                caption.text = new_caption
            end
        }
    end
    
    showcase_closed = kb:create{
        visible_w = 547,
        visible_h = 306,
        q = {  imgs.burberry_1,imgs.dew_1,imgs.jype_2  },
    }
    showcase_closed.x = 8
    showcase=mkb:create{
        hl = showcaseHL,
        group = showcase,
        w = 547,
        panes = {
            {
                title   = "Burberry",
                caption = "Spring/Summer 2011 Collection",
                app_id  = "com.trickplay.burberry",
                h       = 306,
                imgs    = {
                    imgs.burberry_1,
                    imgs.burberry_2,
                    imgs.burberry_3,
                }
            },
            {
                title   = "Mountain Dew",
                caption = "Vote for the new green label bottle art",
                app_id  = "com.trickplay.mountain-dew",
                h       = 306,
                imgs    = {
                    imgs.dew_1,
                    imgs.dew_2,
                    imgs.dew_3,
                }
            },
            {
                title   = "JYPE",
                caption = "Greatest Hits Video Showcase",
                app_id  = "com.trickplay.jyp",
                h       = 316,
                imgs    = {
                    imgs.jype_1,
                    imgs.jype_2,
                    imgs.jype_3,
                }
            },
        },
    }
    
    
    -- App Shop   Video Tile
    ----------------------------------------------------------------------------
    
    app_shop_closed = aic:create{
        launcher_icons = shop_icons,
        icon_w   = 480,
        vis_w    = 547,
        duration = 10000,
    }
    
    shop = Group{}
    do
        
        local title   = Text{  name = "title",   font = "FreeSans Bold 26px",  x = 26,y=26}
        local caption = Text{  name = "caption", font = "FreeSans Medium 24px",x = 26,y=57}
        
        shopHL = HL:create{
            logical_parent = shop,
            contents = Group{
                children = {
                    title,
                    caption,
                }
            },
            focus = function(self,new_title,new_caption,id)
                self.app_id = id
                
                title.text   = new_title
                caption.text = new_caption
            end
        }
    end
    
    shop=mkb:create{
        group = shop,
        hl = shopHL,
        w = 547,
        panes = {
            {
                title   = "Enter the App Shop",
                caption = "Explore new apps for your smart TV",
                app_id  = "com.trickplay.app-shop",
                h       = 306,
                imgs    = {
                    imgs.app_shop_1,
                    imgs.app_shop_2,
                }
            },
            {
                title   = "HULU",
                caption = "Watch TV shows & movies free online",
                app_id  = "com.trickplay.app-shop",
                h       = 306,
                imgs    = {
                    imgs.hulu_1,
                    imgs.hulu_1,
                }
            },
            {
                title   = "True Blood Comics",
                caption = "The thrills continue in Bon Temp",
                app_id  = "com.trickplay.app-shop",
                h       = 316,
                imgs    = {
                    imgs.trueblood_1,
                    imgs.trueblood_1,
                }
            },
        },
    }
    
    
    -- The Video Tile Bar
    ----------------------------------------------------------------------------
    
    --defaults focus to the first tile
    vtb:init{
        video_tile = vt,
        tiles = {
            {
                text = "My Apps",
                contents = Group{y=-48,children={clouds,my_app_list,Clone{source =imgs.overlay,x=8,y = 48},my_apps_closed}, on_key_down = my_app_list.on_key_down},
                slider = myAppsHL,
                expanded_h =my_app_list.list_h-20,
                focus    = function() my_apps_closed:pause() end,
                unfocus  = function() my_apps_closed:play()  end,
            },
            {
                text = "Showcase",
                contents = Group{children={showcase,showcase_closed}, on_key_down = showcase.on_key_down},
                slider   = showcaseHL,
                focus    = function() showcase_closed:fade_out() showcase.focus()   end,
                unfocus  = function() showcase_closed:fade_in()  showcase.unfocus() end,
            },
            {
                text     = "App Store",
                contents = Group{children={shop,app_shop_closed}, on_key_down = shop.on_key_down},
                outer    = Group{
                    children = {
                    Clone{
                        source = imgs.featured,
                        x = 419,
                        y = 343,
                    },
                    Clone{
                        source = imgs.featured,
                        x = 419,
                        y =  652,
                    }
                    },
                },
                slider   = shopHL,
                focus    = function() app_shop_closed:pause() shop.focus()   end,
                unfocus  = function() app_shop_closed:play()  shop.unfocus() end,
            },
        },
    }
    
    screen:add(vtb)
    
    collectgarbage("collect")
    
end
    
--------------------------------------------------------------------------------
-- pretend background TV
--------------------------------------------------------------------------------

function mediaplayer:on_loaded()
    mediaplayer.volume = 0
    mediaplayer:play()
    
end

function mediaplayer:on_end_of_stream()
    
    mediaplayer:seek(0)
    
    mediaplayer:play()
    
end

mediaplayer:load("glee-1.mp4") --comment this line out to remove the video

    
--------------------------------------------------------------------------------
-- Launch the app
--------------------------------------------------------------------------------

dolater(main)

screen:show()






