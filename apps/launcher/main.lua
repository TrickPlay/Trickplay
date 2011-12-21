
local function make_text(title,caption,title_font,caption_font)
    
    local title = Text{
        text = title,
        font = title_font
    }
    local caption = Text{
        text = caption,
        font = caption_font
    }
    
    local c = Canvas(
        title.w > caption.w and title.w or caption.w,
        title.h + caption.h
    )
    
    c:text_element_path(title)
    
    c:set_source_color("000000")
    c:stroke(true)
    c:set_source_color("ffffff")
    c:fill()
    
    c:move_to(0,title.h)
    
    c:text_element_path(caption)
    
    c:set_source_color("000000")
    c:stroke(true)
    c:set_source_color("ffffff")
    c:fill()
    
    
    return c:Image()
end


--dolater...
local function main()
    
    
    local imgs = {
        --
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
        
        if
            i:load_app_icon(v.id,"launcher-icon.png") or
            i:load_app_icon(v.id,"launcher-icon.jpg") then
            
            launcher_icons[v.id] = i
            srcs:add(i)
        end
        
    end
    
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
    -- dofiles()
    ----------------------------------------------------------------------------
    
    local canvas_srcs = dofile("CanvasCloneSources")
    
    local vt = dofile("VideoTile.lua")
    
    local vtb = dofile("VideoTileBar.lua")
    
    local kb =  dofile("KenBurns.lua")
    
    local l = dofile("MyAppsList.lua")
    
    local HL = dofile("MyAppsHL.lua")
    
    local clouds =  dofile("MyAppsBg.lua")
    
    local mkb = dofile("MulitKenBurns.lua")
    
    local aic = dofile("AppIconCarousel.lua")
    
    ----------------------------------------------------------------------------
    -- init()
    ----------------------------------------------------------------------------
    
    canvas_srcs:init{
        
        launcher_frame_w               = 4*48,
        launcher_frame_h               = 4*27,
        launcher_frame_border          = 2,
        launcher_frame_border_gradient = 7,
        
        video_tile_inner_width   = 547,
        video_tile_border_width  = 3,
        video_tile_corner_radius = 20,
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
    tiles = {}
    
    kb:init{}
    
    
    HL:init{
        imgs = imgs,
        img_srcs    = srcs,
        canvas_srcs = canvas_srcs,
        main_font   = "FreeSans Medium 28px",
        sub_font    = "FreeSans Medium 24px",
        icon_size   = {116/270*480,116},
    }
    
    mkb:init{
        img_srcs    = srcs,
    }
    
    my_apps_aic = aic:create{
        launcher_icons = launcher_icons,
        icon_w   = 480,
        vis_w    = 547,
        duration = 10000,
    }
    
    app_shop_aic = aic:create{
        launcher_icons = shop_icons,
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
        local caption = Text{  name = "caption", font = "FreeSans Medium 28px",x = 240,y=35}
        
        myAppsHL = HL:create{
            logical_parent = l,
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
    showcase = Group{}
    do
        
        local title   = Text{  name = "title",   font = "FreeSans Bold 24px",  x = 26,y=10}
        local caption = Text{  name = "caption", font = "FreeSans Medium 24px",x = 26,y=50}
        
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
        q = {  imgs.burberry_1,imgs.dew_1,imgs.jype_1  },
    }
    showcase_closed.x = 3
    showcase=mkb:create{
        hl = showcaseHL,
        group = showcase,
        w = 547,
        kb = kb,
        panes = {
            {
                text    = make_text("Burberry","Spring/Summer 2011 Collection.","FreeSans Bold 24px","FreeSans Medium 24px"),
                title   = "Burberry",
                caption = "Spring/Summer 2011 Collection.",
                app_id  = "com.trickplay.burberry",
                h       = 306,
                imgs    = {
                    imgs.burberry_1,
                    imgs.burberry_2,
                    imgs.burberry_3,
                }
            },
            {
                text    = make_text("Mountain Dew","Vote for the new green label bottle art.","FreeSans Bold 24px","FreeSans Medium 24px"),
                title   = "Mountain Dew",
                caption = "Vote for the new green label bottle art.",
                app_id  = "com.trickplay.mountain-dew",
                h       = 306,
                imgs    = {
                    imgs.dew_1,
                    imgs.dew_2,
                    imgs.dew_3,
                }
            },
            {
                text    = make_text("JYPE","Greatest Hits Video Showcase.","FreeSans Bold 24px","FreeSans Medium 24px"),
                title   = "JYPE",
                caption = "Greatest Hits Video Showcase.",
                app_id  = "com.trickplay.jyp",
                h       = 316,
                imgs    = {
                    imgs.jype_1,
                    imgs.jype_2,
                    imgs.jype_3,
                }
            },
        },
        srcs = srcs,
    }
    
    
    shop = Group{}
    do
        
        local title   = Text{  name = "title",   font = "FreeSans Bold 24px",  x = 26,y=10}
        local caption = Text{  name = "caption", font = "FreeSans Medium 24px",x = 26,y=50}
        
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
        kb = kb,
        panes = {
            {
                text    = make_text("Enter the App Shop","Explore new apps for your smart TV.","FreeSans Bold 24px","FreeSans Medium 24px"),
                title   = "Enter the App Shop",
                caption = "Explore new apps for your smart TV.",
                app_id  = "com.trickplay.app-shop",
                h       = 306,
                imgs    = {
                    imgs.app_shop_1,
                    imgs.app_shop_2,
                }
            },
            {
                text    = make_text("HULU","Watch TV shows & movies free online.","FreeSans Bold 24px","FreeSans Medium 24px"),
                title   = "HULU",
                caption = "Watch TV shows & movies free online.",
                app_id  = "com.trickplay.app-shop",
                h       = 306,
                imgs    = {
                    imgs.hulu_1,
                    imgs.hulu_1,
                }
            },
            {
                text    = make_text("True Blood Comics","The thrills continue in Bon Temp.","FreeSans Bold 24px","FreeSans Medium 24px"),
                title   = "True Blood Comics",
                caption = "The thrills continue in Bon Temp.",
                app_id  = "com.trickplay.app-shop",
                h       = 316,
                imgs    = {
                    imgs.trueblood_1,
                    imgs.trueblood_1,
                }
            },
        },
        srcs = srcs,
    }
    
    l:init{
        launcher_icons=launcher_icons,
        app_list=app_list,
        max_vis_len = 10,
        slider = myAppsHL,
        frame=imgs.icon_overlay,
    }
    
    clouds:init{
        visible_w = 600,
        visible_h = 1000,
    }
    
    
    vtb:init{
        video_tile = vt,
        tiles = {
            {
                text = "My Apps",
                contents = Group{y=-48,children={clouds,l,my_apps_aic}, on_key_down = l.on_key_down},
                slider = myAppsHL,
                expanded_h =l.list_h-20,
                focus    = function() my_apps_aic:pause() end,
                unfocus  = function() my_apps_aic:play()  end,
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
                contents = Group{children={shop,app_shop_aic}, on_key_down = shop.on_key_down},
                slider   = shopHL,
                focus    = function() app_shop_aic:pause() shop.focus()   end,
                unfocus  = function() app_shop_aic:play()  shop.unfocus() end,
            },
        },
    }
    showcase_closed:fade_in()
    app_shop_aic:play()
    
    screen:add(vtb)
    
    ----------------------------------------------------------------------------
    -- key events()
    ----------------------------------------------------------------------------
    
    local screen_keys = {
        [keys["1"]] = function()
            vtb:move_anchor_point(0,0)
            vtb.position = {0,0}
            vtb:animate{
                --mode = "EASE_IN_BACK",
                duration = 400,
                x_rotation = -180,
            }
        end,
        [keys["2"]] = function()
            vtb:move_anchor_point(0,0)
            vtb.position = {0,0}
            vtb:animate{
                --mode = "EASE_OUT_BACK",
                duration = 400,
                x_rotation = 0,
            }
        end,
        [keys["3"]] = function()
            vtb:move_anchor_point(screen.w/2,screen.h/2)
            vtb.position = {screen.w/2,screen.h/2}
            vtb:animate{
                mode = "EASE_IN_QUAD",
                duration = 400,
                scale = {1.5,1.5},
                opacity = 0,
            }
        end,
        [keys["4"]] = function()
            vtb:move_anchor_point(screen.w/2,screen.h/2)
            vtb.position = {screen.w/2,screen.h/2}
            vtb:animate{
                mode = "EASE_OUT_QUAD",
                duration = 400,
                scale = {1,1},
                opacity = 255,
            }
        end,
        [keys["5"]] = function()
            vtb:move_anchor_point(screen.w/2,screen.h/2)
            vtb.position = {screen.w/2,screen.h/2}
            vtb:animate{
                mode = "EASE_IN_BACK",
                duration = 600,
                z=600,
                --z_rotation = 180,
            }
        end,
        [keys["6"]] = function()
            vtb:move_anchor_point(screen.w/2,screen.h/2)
            vtb.position = {screen.w/2,screen.h/2}
            vtb:animate{
                mode = "EASE_OUT_BACK",
                duration = 600,
                z=0,
                --z_rotation = 0,
            }
        end,
    }
    function screen:on_key_down(k)
        
        print("screen:on_key_down("..k..")")
        
        return screen_keys[k] and screen_keys[k]()
        
    end
    
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

mediaplayer:load("glee-1.mp4")

    
--------------------------------------------------------------------------------
-- Launch the app
--------------------------------------------------------------------------------

dolater(main)

screen:show()






