local function make_wide_button(text)
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
        duration = 250*dur_mult,
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

local function make_icon(item)
    local instance = Group()

    local r = Sprite{sheet = assets,id=item.src}
    local checkbox = Sprite{sheet=assets,id="checkbox.png"}

    checkbox.x = -checkbox.w

    local t = Text{text = item.text,font = ICON_FONT, color = "white",y = r.h,x=r.w/2}

    t.anchor_point = {t.w/2,0}

    instance.anchor_point = {r.w/2,r.h/2}
    instance:add(r,checkbox,t)
    return instance

end


-------------------------------------------------------------
local function make_grid(items,cell_w,cell_h,x_spacing,y_spacing)

    local instance = Group()

    local entries = {}
    local function position_entry(item,r,c)
        item.x = (cell_w+x_spacing)*(c-1)
        item.y = (cell_h+y_spacing)*(r-1)
        item.r = r
        item.c = c
    end
    for r,row in ipairs(items) do
        entries[r] = {}
        for c,item in ipairs(row) do

            item = make_icon(item,cell_w,cell_h)

            position_entry(item,r,c)

            instance:add(item)

            entries[r][c] = item

            if r == 4 then item.opacity = 127 end

        end
    end

    local w = (cell_w+x_spacing)*#entries[1]-x_spacing
    instance.anchor_point = {w/2,0}


    return instance

end

--------------------------------------------------------------


return function ( items )

    local modal_menu_skim = Rectangle{
        name = "Modal Menu Skim",
        size=screen.size,
        color = "black",
        opacity=0
    }
    local modal_menu = Group{name = "Modal Menu",x=40,y=60}
    local modal_menu_grid = make_grid(
        items,100,100,80,110
    )

    modal_menu_grid.clip = {-120,-120,1100,742}
    modal_menu_grid.x    = screen_w*3/4 - 130
    modal_menu_grid.y    = 220


    modal_menu:add(
        Sprite{
            name  = "Background",
            sheet = assets,
            id = "bg-create-my-card.png",
            x  = -20,
            y  = -20,
        },
        Text{
            name  = "Menu Title",
            text  = "Create my own Card",
            font  = TITLE_FONT,
            color = "white",
            x     = 30,
            y     = 30,

        },
        Group{
            name = "Empty Card",
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
        modal_menu_grid,
        Group{
            name = "Modal Menu Scrollbar",
            x = 1800,
            y = 160,
            children = {
                Rectangle{
                    name = "Track",
                    w = 4,
                    h = 600,
                    opacity = 100,
                },
                Rectangle{
                    name = "Grip",
                    w = 4,
                    h = 100,
                },
            }
        },
        make_wide_button("Complete"):set{x=30,y=850},
        make_wide_button("Cancel"):set{x = 400,y=850}
    )

    modal_menu.opacity = 0

    --------------------------------------------------------------

    local loop = false
    local prev_menu
    function modal_menu:focus(called_from,f)
        prev_menu = called_from
        if modal_menu.parent == nil then screen:add(modal_menu) end
        modal_menu:raise_to_top()
        --dolater(function()
        modal_menu.z = -400
        modal_menu:animate{
            duration = 250*dur_mult,
            opacity = 255,
        }
        modal_menu:animate{
            duration = 300*dur_mult,
            mode = "EASE_OUT_BACK",
            z = 0,
            on_completed = function()
                if loop then
                    modal_menu:unfocus()
                end
                return f and f()
            end
        }
        modal_menu_skim:animate{
            duration = 250*dur_mult,
            opacity = 150,
        }
        --end)
    end
    function modal_menu:unfocus(f)
        modal_menu:animate{
            duration = 250*dur_mult,
            opacity = 0,
            z = -400,
            on_completed = function()
                if loop then
                    modal_menu:focus(prev_menu)
                else
                    modal_menu:unparent()
                    prev_menu:grab_key_focus()
                end
                return f and f()
            end
        }
        modal_menu_skim:animate{
            duration = 250*dur_mult,
            opacity = 0,
        }
    end

    modal_menu.key_events = {
        [keys.OK] = function()
            modal_menu:unfocus()
            screen:grab_key_focus()
        end,
        [keys.BACK] = function()
            modal_menu:unfocus()
            screen:grab_key_focus()
        end,
        [keys.RED] = function()
            if loop then
                loop = false
            elseif not modal_menu.is_animating then
                loop = true
                modal_menu:unfocus()
            end
        end,
    }
    function modal_menu:on_key_down(k)

        return (not loop or k == keys.RED) and

            self.key_events[k] and self.key_events[k]()

    end

    return modal_menu, modal_menu_skim

end
