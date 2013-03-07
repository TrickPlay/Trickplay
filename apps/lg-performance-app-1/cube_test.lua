local cube = Group()

local card_src = Sprite{sheet = assets,id="card.png"}
local live_card_src = Sprite{sheet = assets,id="card-live.png"}
local card_reflection_src = Sprite{sheet = assets,id="card-shadow.png"}
local card_src_w = card_src.w
local card_src_h = card_src.h
local live_card_src_w = live_card_src.w*3/2
local live_card_src_h = live_card_src.h*3/2
local card_reflection_src_w = card_reflection_src.w
local card_reflection_src_h = card_reflection_src.h

card_src = nil
card_reflection_src = nil

w = screen.w
h = 700

end_angle = 90


local function first_card_icon(item_data)
    local instance = Group()

    local icon = Sprite{sheet = assets,id=item_data.src,x=5,y=5}

    --icon.w = icon.w*3/2
    --icon.h = icon.h*3/2

    local title = Text{
        text = item_data.text,
        font = CARD_TITLE_FONT,
        w     = card_src_w/3-10,
        wrap  = true,
        wrap_mode = "WORD_CHAR",
        color = "black",
        x     = icon.x,
        y     = icon.y+icon.h+5,
    }
    local more = Text{
        text = "More...",
        font = ICON_FONT,
        color = "666666",
    }
    more.x = card_src_w/3 - more.w
    more.y = card_src_h/3 - more.h

    instance:add(icon,title,more)

    return instance
end
local function make_card_icon(item)
    local instance = Group()

    local r = Sprite{sheet = assets,id=item.src}

    --r.w = r.w*3/2
    --r.h = r.h*3/2

    local t = Text{text = item.text,font = ICON_FONT, color = "666666",y = r.h,x=r.w/2}

    t.anchor_point = {t.w/2,0}

    instance.anchor_point = {r.w/2,r.h/2}
    instance:add(r,t)
    return instance

end
function make_icon_card(items_data)

    local n_rows = 3
    local n_cols = 3

    if #items_data ~= (n_cols*n_rows) then
        error("need "..tostring(n_cols*n_rows)..
            ", got "..tostring(#items_data),2)
    end

    local instance = Group{
        name="Card",
        children={
            Sprite{
                sheet = assets,
                id="card.png",
                w = card_src_w,
                h = card_src_h,
            },
            Sprite{
                sheet = assets,
                id = "card-shadow.png",
                y=card_src_h,
                x=card_src_w/2,
                anchor_point = {card_reflection_src_w/2,0},
                w = card_reflection_src_w,
                h = card_reflection_src_h,
            },
        }
    }

    local items={{}}
    local icon = first_card_icon(items_data[1])

    items[1][1] =icon
    instance:add(icon)

    for i=2,#items_data do
        if i%n_cols == 1 then
            items[#items+1] = {}
        end

        icon = make_card_icon(items_data[i])

        table.insert(items[#items], icon )
        icon.x = (2*#items[#items]-1)*card_src_w/6
        icon.y = (2*#items        -1)*card_src_h/6
        instance:add(icon)

    end

    return instance

end
local function make_live_card(item_data)

    local pip = Sprite{
        sheet = assets,
        id = "live-image.png",
    }

    pip.w = pip.w*3/2-20
    pip.h = pip.h*3/2
    pip.x = 2

    local ad = Sprite{
        sheet = assets,
        id = "ad-worldnews-abc.png",
    }

    --ad.w = ad.w*3/2-10
    --ad.h = ad.h*3/2+10
    ad.w = ad.w-20
    ad.x = 2
    ad.y = card_src_h-ad.h+26

    local instance = Group{
        name="Card",
        children={
            Sprite{
                sheet = assets,
                id = "card-live.png",
                w = card_src_w,
                h = card_src_h,
            },
            ad,pip,
            Sprite{
                sheet = assets,
                id = "card-shadow.png",
                y=live_card_src_h,
                x=live_card_src_w/2,
                anchor_point = {card_reflection_src_w/2,0},
                w = card_reflection_src_w,
                h = card_reflection_src_h,
            },
            Text{
                font = CARD_TITLE_FONT,
                color = "111111",
                text  = item_data.title,
                y=card_src_h/2,
                x=5,
                w = card_src_w - 10,
                ellipsize = "END",
            },
            Text{
                font = ICON_FONT,
                color = "999999",
                text  = item_data.sub_t,
                y=card_src_h/2+40,
                x=5,
                w = card_src_w - 10,
                ellipsize = "END",
            },
        }
    }

    return instance

end
local function make_side(cards)--w,h,bg_color)
    local instance = Group{
        anchor_point={w/2,h/2},
        clip = {0,0,screen_w,screen_h}
    }


    for i,card in ipairs(cards) do
        instance:add(card:set{
                x = (card_src_w+50)*(i-1),
                y = 100,
            })
    end
    return instance
end


--r1 = make_side(w,h,bg.color)
r1 = make_side{
    make_icon_card{
        {text="3D WORLD",     src="title-icon-3d-world.png"},
        {text="Settings",     src="icon-settings.png"},
        {text="Now & Hot",    src="icon-now-hot.png"},
        {text="Search",       src="icon-search.png"},
        {text="Input List",   src="icon-input-list.png"},
        {text="3d On",        src="icon-3d-on.png"},
        {text="TV Guide",     src="icon-tv-guide.png"},
        {text="User Guide",   src="icon-user-guide.png"},
        {text="Internet",     src="icon-internet.png"},
    },
    make_icon_card{
        {text="GAMES",        src="title-icon-game.png"},
        {text="Settings",     src="icon-settings.png"},
        {text="Now & Hot",    src="icon-now-hot.png"},
        {text="Search",       src="icon-search.png"},
        {text="Input List",   src="icon-input-list.png"},
        {text="3d On",        src="icon-3d-on.png"},
        {text="TV Guide",     src="icon-tv-guide.png"},
        {text="User Guide",   src="icon-user-guide.png"},
        {text="Internet",     src="icon-internet.png"},
    },
    make_icon_card{
        {text="MY CARD",      src="title-icon-my-card.png"},
        {text="Settings",     src="icon-settings.png"},
        {text="Now & Hot",    src="icon-now-hot.png"},
        {text="Search",       src="icon-search.png"},
        {text="Input List",   src="icon-input-list.png"},
        {text="3d On",        src="icon-3d-on.png"},
        {text="TV Guide",     src="icon-tv-guide.png"},
        {text="User Guide",   src="icon-user-guide.png"},
        {text="Internet",     src="icon-internet.png"},
    },
}:set{opacity=0}
r2 = make_side{
    make_live_card{
        title = "11-1 LGC HD The Blue Earth",
        sub_t = "PM 10:20 - 11:20",
    },
    make_icon_card{
        {text="GAME WORLD",    src="title-icon-game.png"},
        {text="Quick Menu",    src="icon-quick-menu.png"},
        {text="Netflix",       src="icon-netflix.png"},
        {text="Youtube",       src="icon-youtube.png"},
        {text="Accuweather",   src="icon-accuweather.png"},
        {text="Skype",         src="icon-skype.png"},
        {text="Facebook",      src="icon-facebook.png"},
        {text="Adobe TV",      src="icon-lg-adobetvb.png"},
        {text="TED",           src="icon-ted.png"},
    },
    make_icon_card{
        {text="LG SMART WORLD", src="title-icon-lg-smart-world.png"},
        {text="LG B",         src="icon-lg-b.png"},
        {text="Mable",        src="icon-lg-mable.png"},
        {text="Adobe TV",     src="icon-lg-adobetvb.png"},
        {text="iVillage",     src="icon-lg-ivillage.png"},
        {text="Highcut",      src="icon-lg-highcut.png"},
        {text="Easy Map",     src="icon-lg-easy-map.png"},
        {text="nPoint",       src="icon-lg-npoint.png"},
        {text="Astronaut",    src="icon-lg-astronaut.png"},
    },
    make_icon_card{
        {text="MY CARD",      src="title-icon-my-card.png"},
        {text="Settings",     src="icon-settings.png"},
        {text="Now & Hot",    src="icon-now-hot.png"},
        {text="Search",       src="icon-search.png"},
        {text="LG Smart",     src="icon-lg-cloud.png"},
        {text="3d On",        src="icon-3d-on.png"},
        {text="TV Guide",     src="icon-tv-guide.png"},
        {text="User Guide",   src="icon-user-guide.png"},
        {text="Internet",     src="icon-internet.png"},
    },
}
--r2 = make_side(w,h,bg.color)

g = Group{
    position={screen.w/2,h/2+50}
}


g:add(r1,r2)
cube:add(bg,g)


local phase_one, phase_two
local animating = false
local curr_r = r2
local next_r = r1
function cube:rotate(outgoing,incoming,direction)
    if animating then return end
    animating = true
    outgoing.y_rotation={ 0,0,-w/2}
    incoming.y_rotation={(direction == "LEFT" and -end_angle or end_angle),0,-w/2}
    incoming.opacity = 0
    phase_one = Animator{
        duration = 400,
        properties = {
            {
                source = outgoing,
                name   = "y_rotation",
                keys   = {
                    {0.0,"EASE_IN_SINE",  0},
                    {1.0,"EASE_IN_SINE", (direction == "LEFT" and end_angle/2 or -end_angle/2)},
                },
            },
            {
                source = incoming,
                name   = "y_rotation",
                keys   = {
                    {0.0,"EASE_IN_SINE", (direction == "LEFT" and -end_angle   or end_angle)},
                    {1.0,"EASE_IN_SINE", (direction == "LEFT" and -end_angle/2 or end_angle/2)},
                },
            },
            {
                source = incoming,
                name   = "opacity",
                keys   = {
                    {0.0,"EASE_IN_SINE",   0},
                    {1.0,"EASE_IN_SINE", 255},
                },
            },
            {
                source = g,
                name   = "z",
                keys   = {
                    {0.0,"EASE_IN_OUT_QUAD", 0},
                    {1.0,"EASE_IN_OUT_QUAD", -w/2},
                },
            },
        }
    }
    function phase_one.timeline.on_completed()
        incoming:raise_to_top()
        phase_two = Animator{
            duration = 400,
            properties = {
                {
                    source = outgoing,
                    name   = "y_rotation",
                    keys   = {
                        {0.0,"EASE_OUT_SINE",(direction == "LEFT" and end_angle/2 or -end_angle/2)},
                        {1.0,"EASE_OUT_SINE",(direction == "LEFT" and end_angle   or -end_angle)},
                    },
                },
                {
                    source = incoming,
                    name   = "y_rotation",
                    keys   = {
                        {0.0,"EASE_OUT_SINE", (direction == "LEFT" and -end_angle/2 or end_angle/2)},
                        {1.0,"EASE_OUT_SINE",  0},
                    },
                },
                {
                    source = g,
                    name   = "z",
                    keys   = {
                        {0.0,"EASE_IN_OUT_QUAD", -w/2},
                        {1.0,"EASE_IN_OUT_QUAD",  0},
                    },
                },
                {
                    source = outgoing,
                    name   = "opacity",
                    keys   = {
                        {0.0,"EASE_OUT_SINE", 255},
                        {1.0,"EASE_OUT_SINE",   0},
                    },
                },
            }
        }
        function phase_two.timeline.on_completed()
            animating = false

            curr_r = incoming
            next_r = outgoing
        end
        dolater(phase_two.start,phase_two)
    end
    dolater(phase_one.start,phase_one)
end












local key_events = {
    [keys.Right] = function()
        cube:rotate(curr_r,next_r,"RIGHT")
    end,
    [keys.Left] = function()
        cube:rotate(curr_r,next_r,"LEFT")
    end,
}
cube.key_events = key_events
function cube:on_key_down(k)
    return key_events[k] and key_events[k]()
end

return cube
