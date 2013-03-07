
screen:show()
screen_w = screen.w
screen_h = screen.h
assets = SpriteSheet{
    map = "assets/images.json"
}

FONT = "Lato"
ICON_FONT = FONT.." 24px"
CARD_TITLE_FONT = FONT.." 30px"
TITLE_FONT = FONT.." Bold 60px"
dumptable(assets:get_ids())
--dofile("delete_test")
make_grid = dofile('make_grid')
--[=[]]
-------------------------------------------------------------
local items = {}
for i=1,4 do
    items[i] = {}
    for j=1,10 do
        items[i][j] = "Icon "..i.." "..j
    end
end
grid = make_grid(items,100,100,80,80)
grid:make_icons_reactive()
grid.x = screen_w/2
grid.y = 400
screen:add(grid)
--]=]

-------------------------------------------------------------
function make_wide_button(text)
    local instance = Group{name=text.." Button"}

    local unfocused = Sprite{sheet=assets,id="button-default.png"}
    local   focused = Sprite{sheet=assets,id="button-focus.png"  }


    local text = Text{
        text = text,
        font = CARD_TITLE_FONT,
        color = "black",
        x = focused.w/2,
        y = focused.h/2,
    }
    text.anchor_point = {text.w/2,text.h/2}

    instance:add(unfocused,focused,text)

    local as = AnimationState {
        duration = 250,
        mode = "EASE_OUT_SINE",
        transitions = {
            {
                source = "*",
                target = "focus",
                keys = {
                    { focused,   "opacity", 255 },
                    { unfocused, "opacity",   0 },
                },
            },
            {
                source = "*",
                target = "unfocus",
                keys = {
                    { focused,   "opacity",   0 },
                    { unfocused, "opacity", 255 },
                },
            },
        },
    }

    function instance:focus(self)
        as.state = "focus"
    end

    function instance:unfocus(self)
        as.state = "unfocus"
    end
    as:warp("unfocus")

    return instance
end
-------------------------------------------------------------
local bg = Sprite{
    sheet = assets,
    id="bg-gradient.png",
    size = screen.size,
}

local cards = dofile("cube_test")


--------------------------------------------------------------
local items = {
    {
        {text="Input List",    src="icon-input-list.png"},
        {text="Settings",      src="icon-settings.png"},
        {text="Internet",      src="icon-internet.png"},

        {text="Search",        src="icon-search.png"},
        {text="Now & Hot",     src="icon-now-hot.png"},
        {text="CNN",           src="icon-cnn.png"},
    },
    {
        {text="Cinema Now",    src="icon-cinema-now.png"},
        {text="AP",            src="icon-ap.png"},
        {text="User Guide",    src="icon-user-guide.png"},

        {text="Ch. List",      src="icon-ch-list.png"},
        {text="Dual Play",     src="icon-dual-play.png"},
        {text="Camera",        src="icon-camera.png"},
    },
    {
        {text="LG Smart",      src="icon-lg-smart.png"},
        {text="3D World",      src="icon-3d-on.png"},
        {text="Nat Geo",       src="icon-national-geo.png"},

        {text="Gystle",        src="icon-gystle.png"},
        {text="Netflix",       src="icon-netflix.png"},
        {text="NHL",           src="icon-nhl.png"},
    },
    {
        {text="O2",            src="icon-o2.png"},
        {text="Simplelink",    src="icon-simple-link.png"},
        {text="Quick Menu",    src="icon-quick-menu.png"},

        {text="Netflix",       src="icon-netflix.png"},
        {text="Youtube",       src="icon-youtube.png"},
        {text="Accuweather",   src="icon-accuweather.png"},
    },
}
modal_menu_skim = Rectangle{size=screen.size,color = "black",opacity=0}
modal_menu = Group{name = "Modal Menu",x=40,y=60}
modal_menu_grid = make_grid(items,100,100,90,70)

modal_menu_grid.x = screen_w*3/4 - 130
modal_menu_grid.y = 200

modal_menu_bg = Sprite{
    sheet = assets,
    id = "bg-create-my-card.png",
    x  = -20,
    y  = -20,
}
--modal_menu_bg.w = screen_w-modal_menu.x*2--modal_menu_bg.w*3/2
--modal_menu_bg.h = screen_h-modal_menu.y*2--modal_menu_bg.h*3/2
modal_menu:add(
    modal_menu_bg,
    Text{
        text = "Create my own Card",
        font = TITLE_FONT,
        color = "white",
        x     = 30,
        y     = 30,

    },
    Group{
                x  = 100,
                y  = 120,
        children = {
            Sprite{
                sheet = assets,
                id = "card-my.png",
                w  = 357*3/2,
                h  = 438*3/2,
            },
            Sprite{
                sheet = assets,
                id = "title-icon-my-card.png",
                x  = 10,
                y  = 10,
                --w  = 30*3/2,
                --h  = 29*3/2,
            },
            Text{
                text = "My Card 1",
                font = CARD_TITLE_FONT,
                color = "black",
                x     = 10,
                y     = 60,
            },
            Text{
                text = "Select the App",
                font = CARD_TITLE_FONT,
                color = "999999",
                x     = 170,
                y     = 330,
            },
            Text{
                text = "or drag the App to this Area",
                font = CARD_TITLE_FONT,
                color = "999999",
                x     = 80,
                y     = 370,
            },
        }
    },
    --[[
    make_icon_card{
        {text="My Card 1",    src="title-icon-my-card.png"},
        {text="", src="icon-settings.png"},
        {text="", src="icon-now-hot.png"},
        {text="", src="icon-search.png"},
        {text="Select the App or drag the App to this Area", src="icon-lg-cloud.png"},
        {text="", src="icon-3d-on.png"},
        {text="", src="icon-tv-guide.png"},
        {text="", src="icon-user-guide.png"},
        {text="", src="icon-internet.png"},
    }:set{x = 80,y=100},
    --]]
    modal_menu_grid,
    make_wide_button("Complete"):set{x=30,y=850},
    make_wide_button("Cancel"):set{x = 400,y=850}
)

modal_menu.opacity = 0

function modal_menu:focus(f)
    modal_menu.z = -400
    modal_menu:animate{
        duration = 250,
        opacity = 255,
    }
    modal_menu:animate{
        duration = 300,
        mode = "EASE_OUT_BACK",
        z = 0,
        on_completed = f
    }
    modal_menu_skim:animate{
        duration = 250,
        opacity = 150,
    }
end
function modal_menu:unfocus(f)
    modal_menu:animate{
        duration = 250,
        opacity = 0,
        z = -400,
        on_completed = f
    }
    modal_menu_skim:animate{
        duration = 250,
        opacity = 0,
    }
end

modal_menu.key_events = {
    [keys.OK] = function()
        modal_menu:unfocus(
            function()
                cards:grab_key_focus()
            end
        )
        screen:grab_key_focus()
    end,
}
function modal_menu:on_key_down(k)
    return self.key_events[k] and self.key_events[k]()
end
--modal_menu.z = -100

controllers:start_pointer()
-------------------------------------------------------------
--]=]


local btm_row_tab = Group()
local btm_row_backing = Sprite{
    sheet = assets,
    id="main-bar.png",
    w = screen.w,
    h = 152*1920/1280,
}
btm_row_tab.y = screen.h-btm_row_backing.h
local btm_row_gradient = Sprite{
    sheet = assets,
    id="gradient-my-apps.png",
    w = screen.w,
}
btm_row_gradient.h = btm_row_gradient.h*3/2
btm_row_gradient.y = btm_row_tab.y+35
local btm_row_backing_text = Text{
    text = "More",
    font = CARD_TITLE_FONT,
    color = "white",
    x  = screen.w/2,
    y  = 15,
}
btm_row_backing_text.anchor_point = {btm_row_backing_text.w/2,0}
btm_row_tab:add(btm_row_backing,btm_row_backing_text)
local items = {
    {
        {text="Input List",    src="icon-input-list.png"},
        {text="Settings",      src="icon-settings.png"},
        {text="Internet",      src="icon-internet.png"},
        {text="Search",        src="icon-search.png"},
        {text="Now & Hot",     src="icon-now-hot.png"},
        {text="CNN",           src="icon-cnn.png"},
        {text="Cinema Now",    src="icon-cinema-now.png"},
        {text="AP",            src="icon-ap.png"},
        {text="User Guide",    src="icon-user-guide.png"},
        {text="Ch. List",      src="icon-ch-list.png"},
    },
    {
        {text="Google Earth",  src="icon-google-earth.png"},
        {text="Forky",         src="icon-forky.png"},
        {text="LG Smart",      src="icon-lg-smart.png"},
        {text="3D World",      src="icon-3d-on.png"},
        {text="Nat Geo",       src="icon-national-geo.png"},
        {text="Gystle",        src="icon-gystle.png"},
        {text="Netflix",       src="icon-netflix.png"},
        {text="NHL",           src="icon-nhl.png"},
        {text="O2",            src="icon-o2.png"},
        {text="Simplelink",    src="icon-simple-link.png"},
    },
    {
        {text="Quick Menu",    src="icon-quick-menu.png"},
        {text="Netflix",       src="icon-netflix.png"},
        {text="Youtube",       src="icon-youtube.png"},
        {text="Accuweather",   src="icon-accuweather.png"},
        {text="Skype",         src="icon-skype.png"},
        {text="Facebook",      src="icon-facebook.png"},
        {text="Adobe TV",      src="icon-lg-adobetvb.png"},
        {text="TED",           src="icon-ted.png"},
        {text="MLB",           src="icon-mlb.png"},
        {text="Find Ball",     src="icon-game-find-ball.png"},
    },
    {
        {text="Picasa",        src="icon-picasa.png"},
        {text="Twitter",       src="icon-twitter.png"},
        {text="Mable",         src="icon-lg-mable.png"},
        {text="N Point",       src="icon-lg-npoint.png"},
        {text="iVillage",      src="icon-lg-ivillage.png"},
        {text="Highcut",       src="icon-lg-highcut.png"},
        {text="Easy Map",      src="icon-lg-easy-map.png"},
        {text="Hulu+",         src="icon-hulu-plus.png"},
        {text="LG B",          src="icon-lg-b.png"},
        {text="Astronaut",     src="icon-lg-astronaut.png"},
    },
}
local grid = dofile("delete_test")(items,75,75,105,120)
grid.x = screen.w/2
grid.y = 930

local btm = Group()
btm:add(btm_row_gradient,btm_row_tab,grid)

--------------------------------------------------------------

local my_apps_top = Group{
    name="my_apps_top",
    opacity=0,z=300,
    --x_rotation={90,0,-150},
    anchor_point = {screen_w/2,200},
    position = {screen_w/2,200},
}

do
    local icon = Sprite{
        sheet=assets,
        id="icon-top-my-apps.png",
        x = 30,
        y = 20,
    }
    icon.w = icon.w*3/2
    icon.h = icon.h*3/2

    local my_apps_text = Text{
        text = "MY APPS",
        color = "white",
        font = TITLE_FONT,
        x = icon.x + icon.w+10,
        y = icon.y-5
    }

    local pip = Sprite{
        sheet=assets,
        id="my-apps-mad-men.png",
        x = 100,
        y =  90,
    }
    pip.w = pip.w*3/2
    pip.h = pip.h*3/2

    local prog_bar = Sprite{
        sheet=assets,
        id="my-apps-progress-bar-whole.png",
        x = 800,
        y = 300,
    }
    prog_bar.w = prog_bar.w*3/2
    prog_bar.h = prog_bar.h*3/2

    local hdd_usb = Sprite{
        sheet=assets,
        id="button-hdd-usb-default.png",
        x = 1150,
        y = 280,
    }
    hdd_usb.w = hdd_usb.w*3/2
    hdd_usb.h = hdd_usb.h*3/2

    local lrg_btn = Sprite{
        sheet=assets,
        id="button-recently-added.png",
        x = hdd_usb.x+hdd_usb.w+20,
        y = hdd_usb.y,
    }
    lrg_btn.w = lrg_btn.w*3/2
    lrg_btn.h = lrg_btn.h*3/2

    local lrg_btn_text = Text{
        text = "Recently Added",
        font = CARD_TITLE_FONT,
        color = "black",
        x = lrg_btn.x+lrg_btn.w/2,
        y = lrg_btn.y+lrg_btn.h/2,
    }
    lrg_btn_text.anchor_point = {lrg_btn_text.w/2,lrg_btn_text.h/2}

    local lrg_btn_arrow = Sprite{
        sheet=assets,
        id="arrow-small-buttons.png",
        x = lrg_btn.x+lrg_btn.w-50,
        y = lrg_btn.y+lrg_btn.h/2,
    }
    lrg_btn_arrow.w = lrg_btn_arrow.w*3/2
    lrg_btn_arrow.h = lrg_btn_arrow.h*3/2
    lrg_btn_arrow.anchor_point = {lrg_btn_arrow.w/2,lrg_btn_arrow.h/2}

    local banner = Sprite{
        sheet=assets,
        id="ad-banner-lg-my-apps.png",
        x = 780,
        y = 120,
    }
    banner.w = banner.w*3/2
    banner.h = banner.h*3/2


    my_apps_top:add(icon,my_apps_text,pip,prog_bar,hdd_usb,lrg_btn,lrg_btn_text,lrg_btn_arrow,banner)
end
--------------------------------------------------------------

local top_bar = Group()

local top_items = {
    Sprite{
        sheet = assets,
        id = "top-icon-connection-on.png",
    },
    Sprite{
        sheet = assets,
        id = "top-icon-edit.png",
    },
    Sprite{
        sheet = assets,
        id = "top-bar-line-separator.png",
    },
    Sprite{
        sheet = assets,
        id = "top-icon-search.png",
    },
    Sprite{
        sheet = assets,
        id = "top-icon-notice.png",
    },
    Sprite{
        sheet = assets,
        id = "top-icon-logout.png",
    },
    Sprite{
        sheet = assets,
        id = "top-bar-line-separator.png",
    },
    Sprite{
        sheet = assets,
        id = "top-icon-exit.png",
    },
}

top_bar:add(unpack(top_items))

for i=1,#top_items do
    local v =top_items[i]

    v.anchor_point = {0,v.h/2}
    if v.id == "top-bar-line-separator.png" then
        v.w = v.w*3/2
        v.h = v.h*3/2
    end
    v.x = i == 1 and 0 or (top_items[i-1].x+top_items[i-1].w+20)--(i-1)*(v.w+20)
end

top_bar.x = screen.w - top_items[#top_items].x - 100
top_bar.y = 60

screen:add(bg,cards,btm,top_bar,modal_menu_skim,modal_menu,my_apps_top)


--------------------------------------------------------------

dolater(cards.grab_key_focus,cards)

cards.key_events[keys.OK] = function()
    modal_menu:focus(function()
            modal_menu:grab_key_focus()
        end
    )
    screen:grab_key_focus()
end
cards.key_events[keys.Down] = function()
    bg:animate{
        mode = "EASE_OUT_SINE",
        duration = 250,
        h = 375
    }
    my_apps_top:animate{
        mode = "EASE_OUT_SINE",
        duration = 250,
        opacity = 255,
        --x_rotation = 0,
        z=0,
    }
    btm_row_tab:animate{
        mode = "EASE_OUT_SINE",
        duration = 250,
        opacity = 0,
    }
    g:animate{
        mode = "EASE_OUT_SINE",
        duration = 250,
        opacity = 0,
        z = -400,
    }
    grid.hl:animate{
        mode = "EASE_OUT_SINE",
        duration = 250,
        opacity = 255,
    }
    btm:animate{
        mode = "EASE_OUT_SINE",
        duration = 250,
        y = -515,
        on_completed = function()
            grid:grab_key_focus()
        end,
    }
    screen:grab_key_focus()
end

grid.key_events[keys.BACK] = function()
    bg:animate{
        mode = "EASE_OUT_SINE",
        duration = 250,
        h = screen_h
    }
    my_apps_top:animate{
        mode = "EASE_OUT_SINE",
        duration = 250,
        opacity = 0,
        --x_rotation = -90,
        z=300,
    }
    btm_row_tab:animate{
        mode = "EASE_OUT_SINE",
        duration = 250,
        opacity = 255,
    }
    g:animate{
        mode = "EASE_OUT_SINE",
        duration = 250,
        opacity = 255,
        z = -0,
        on_completed = function()
            g:grab_key_focus()
        end,
    }
    grid.hl:animate{
        mode = "EASE_OUT_SINE",
        duration = 250,
        opacity = 0,
    }
    btm:animate{
        mode = "EASE_OUT_SINE",
        duration = 250,
        y = 0,
    }
    screen:grab_key_focus()

end
