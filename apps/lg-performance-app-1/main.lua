
screen:show()
screen_w = screen.w
screen_h = screen.h
assets = SpriteSheet{ map = "assets/images.json" }

dur_mult = 1

FONT            = "LG Display"
ICON_FONT       = FONT.." 24px"
CARD_TITLE_FONT = FONT.." 30px"
TITLE_FONT      = FONT.." Bold 60px"

-------------------------------------------------------------
--load the other files

local cube              = dofile("cube")

local make_modal_menu   = dofile("modal_menu")

local my_apps_top       = dofile("my_apps_top_bar")

local make_my_apps_grid = dofile("my_apps_grid")

local top_bar           = dofile("top_bar")

-------------------------------------------------------------
-- create all the on screen entities
-------------------------------------------------------------

--Background Gradient
local bg  = Sprite{
    name  = "Background Gradient",
    sheet = assets,
    id    = "bg-gradient.png",
    size  = screen.size,
    opacity = 255*.6,
}

--------------------------------------------------------------
-- Create the Modal Menu
local modal_menu_items = {
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
        {text="MLB",           src="icon-mlb.png"},
        {text="Orange",        src="icon-orange.png"},
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

        {text="Hulu+",         src="icon-hulu-plus.png"},
        {text="Youtube",       src="icon-youtube.png"},
        {text="Accuweather",   src="icon-accuweather.png"},
    },
}

local modal_menu, modal_menu_skim =

    make_modal_menu(modal_menu_items)

-------------------------------------------------------------
-- Make the pieces that sit below the cube
-- These objects also slide up to create the 'My Apps' screen

local btm = Group()

local btm_row_tab = Group()
local btm_row_backing = Sprite{
    sheet = assets,
    id    = "main-bar.png",
    w     = screen_w,
    h     = 152*1920/1280,
}
btm_row_tab.y = screen.h-btm_row_backing.h

local btm_row_gradient = Sprite{
    sheet = assets,
    id    = "gradient-my-apps.png",
    w     = screen.w,
}
btm_row_gradient.h = btm_row_gradient.h*3/2
btm_row_gradient.y = btm_row_tab.y+35

local btm_row_backing_text = Text{
    text  = "More",
    font  = CARD_TITLE_FONT,
    color = "white",
    x     = screen.w/2,
    y     = 15,
}
btm_row_backing_text.anchor_point = {btm_row_backing_text.w/2,0}

btm_row_tab:add(btm_row_backing,btm_row_backing_text)

-------------------------------------------------------------
-- Create the my apps grid
local my_apps_items = {
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
        {text="Orange",        src="icon-orange.png"},
    },
    {
        {text="Picasa",        src="icon-picasa.png"},
        {text="AP",            src="icon-ap.png"},
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

local grid = make_my_apps_grid(my_apps_items,75,75,105,120)
grid.x = screen.w/2
grid.y = 930

btm:add(btm_row_gradient,btm_row_tab,grid)

--------------------------------------------------------------
-- Add everything to the screen

screen:add(bg,cube,btm,top_bar,modal_menu_skim)


--------------------------------------------------------------
-- Add key events for screen-to-screen transitions
--------------------------------------------------------------

cube.key_events[keys.OK] = function()
    modal_menu:focus(cube)
    screen:grab_key_focus()
end

--------------------------------------------------------------
-- Green causes the animation from the 'My Apps' screen to the
-- 'Cube' screen to repeat
my_apps_to_cube_repeat = false
my_apps_to_cube_animating = false

--pressing green from either screen will cause it to repeat
cube.key_events[keys.GREEN] = function()

    my_apps_to_cube_repeat = not my_apps_to_cube_repeat

    return my_apps_to_cube_repeat and
        not my_apps_to_cube_animating and
        cube.key_events[keys.Down]()
end

grid.key_events[keys.GREEN] = function()

    my_apps_to_cube_repeat = not my_apps_to_cube_repeat

    return my_apps_to_cube_repeat and
        not my_apps_to_cube_animating and
        grid.key_events[keys.BACK]()
end


--------------------------------------------------------------
-- Pressing DOWN from the cube causes the 'My Apps' screen to
-- slide up
cube.key_events[keys.Down] = function()

    --Don't animate if this transition if it's already animating
    if my_apps_to_cube_animating then return end
    my_apps_to_cube_animating = true

    if my_apps_top.parent == nil then
        screen:add(my_apps_top)
        my_apps_top:raise_to_top()
    end

    local a = Animator{
        duration = 400*dur_mult,
        mode = "EASE_OUT_SINE",
        properties = {
            {
                source = bg,
                name   = "h",
                keys   = {
                    {0.0,"EASE_OUT_SINE",  bg.h},
                    {1.0,"EASE_OUT_SINE", 375},
                },
            },
            {
                source = my_apps_top,
                name   = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE", my_apps_top.opacity},
                    {1.0,"EASE_OUT_SINE", 255},
                },
            },
            {
                source = my_apps_top,
                name   = "z",
                keys   = {
                    {0.0,"EASE_OUT_SINE", my_apps_top.z},
                    {1.0,"EASE_OUT_SINE",   0},
                },
            },
            {
                source = cube,
                name   = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE", cube.opacity},
                    {1.0,"EASE_OUT_SINE",   0},
                },
            },
            {
                source = cube,
                name   = "z",
                keys   = {
                    {0.0,"EASE_OUT_SINE", cube.z},
                    {1.0,"EASE_OUT_SINE", -400},
                },
            },
            {
                source = btm_row_tab,
                name   = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE", btm_row_tab.opacity},
                    {1.0,"EASE_OUT_SINE",   0},
                },
            },
            {
                source = btm,
                name   = "y",
                keys   = {
                    {0.0,"EASE_OUT_SINE", btm.y},
                    {1.0,"EASE_OUT_SINE",   -515},
                },
            },
            {
                source = grid.hl,
                name   = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE", grid.hl.opacity},
                    {1.0,"EASE_OUT_SINE", 255},
                },
            },
        }
    }
    function a.timeline.on_completed()
        my_apps_to_cube_animating = false

        --if repeating, then fire off the reciprocal animation
        if my_apps_to_cube_repeat then
            grid.key_events[keys.BACK]()
        --give the key focus to the 'My Apps' screen
        else
            grid:grab_key_focus()
        end
    end
    a:start()

    --Steal the key focus if not repeating
    if not my_apps_to_cube_repeat then screen:grab_key_focus() end
end

--------------------------------------------------------------
-- Press BACK from the 'My Apps' Screen causes the screen to slide
-- down and the cube to animate in
grid.key_events[keys.BACK] = function()

    --Don't animate if this transition if it's already animating
    if my_apps_to_cube_animating then return end
    my_apps_to_cube_animating = true

    local a = Animator{
        duration = 400*dur_mult,
        mode = "EASE_OUT_SINE",
        properties = {
            {
                source = bg,
                name   = "h",
                keys   = {
                    {0.0,"EASE_OUT_SINE",  bg.h},
                    {1.0,"EASE_OUT_SINE", screen_h},
                },
            },
            {
                source = my_apps_top,
                name   = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE", my_apps_top.opacity},
                    {1.0,"EASE_OUT_SINE",   0},
                },
            },
            {
                source = my_apps_top,
                name   = "z",
                keys   = {
                    {0.0,"EASE_OUT_SINE", my_apps_top.z},
                    {1.0,"EASE_OUT_SINE", 300},
                },
            },
            {
                source = cube,
                name   = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE", cube.opacity},
                    {1.0,"EASE_OUT_SINE", 255},
                },
            },
            {
                source = cube,
                name   = "z",
                keys   = {
                    {0.0,"EASE_OUT_SINE", cube.z},
                    {1.0,"EASE_OUT_SINE",    0},
                },
            },
            {
                source = btm_row_tab,
                name   = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE", btm_row_tab.opacity},
                    {1.0,"EASE_OUT_SINE", 255},
                },
            },
            {
                source = btm,
                name   = "y",
                keys   = {
                    {0.0,"EASE_OUT_SINE", btm.y},
                    {1.0,"EASE_OUT_SINE",     0},
                },
            },
            {
                source = grid.hl,
                name   = "opacity",
                keys   = {
                    {0.0,"EASE_OUT_SINE", grid.hl.opacity},
                    {1.0,"EASE_OUT_SINE",   0},
                },
            },
        }
    }
    function a.timeline.on_completed()
        my_apps_to_cube_animating = false

        --if repeating, then fire off the reciprocal animation
        if my_apps_to_cube_repeat then
            cube.key_events[keys.Down]()
        --give the key focus to the 'My Apps' screen
        else
            my_apps_top:unparent()
            cube:grab_key_focus()
        end
    end
    a:start()

    --Steal the key focus if not repeating
    if not my_apps_to_cube_repeat then screen:grab_key_focus() end

end

dolater(cube.grab_key_focus,cube)
