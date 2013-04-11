

-------------------------------------------------------------
local function make_icon(item)
    local instance = Group()

    instance.app = item.app

    local s = Sprite{sheet = assets,id=item.src}

    instance.icon = s

    local t   = Text{
        text  = item.text,
        font  = ICON_FONT,
        color = "white",
        y = s.h,
        x = s.w/2
    }

    t.anchor_point = {t.w/2,0}

    instance:add(s,t)

    --Mouse/MMR Events
    local grabbed = false
    local last_x, last_y,orig_x,orig_y
    function instance:on_button_down(x,y)
        self:grab_pointer()
        grabbed = true
        last_y = y
        last_x = x
        orig_y = self.y
        orig_x = self.x
    end
    function instance:on_motion( x,y )
        if grabbed then
            self:move_by( x-last_x, y-last_y )
            last_x = x
            last_y = y
        end
    end
    function instance:on_button_up(x,y)
        if grabbed then
            grabbed = false
            self:ungrab_pointer()

            if
                x > recycle_bin.x and
                x < recycle_bin.x + recycle_bin.w and
                y > recycle_bin.y and
                y < recycle_bin.y + recycle_bin.h then

                self.parent:delete(
                    self.r,self.c
                )

            else
                self:animate{
                    duration = 100,
                    x = orig_x,
                    y = orig_y,
                }
            end
        end
    end
    return instance
end


-------------------------------------------------------------
-- The Constructor for the 'My Apps' Grid
return function(items,cell_w,cell_h,x_spacing,y_spacing)

    local instance = Group()

    local entries = {}
    ----------------------------------------------------------
    --positions each item according to row/col
    local function position_entry(item,r,c)
        item.x = (cell_w+x_spacing)*(c-1)
        item.y = (cell_h+y_spacing)*(r-1)
        --item.r = r
        --item.c = c
    end
    ----------------------------------------------------------
    --create all the items
    for r,row in ipairs(items) do
        entries[r] = {}
        for c,item in ipairs(row) do

            item = make_icon(item,cell_w,cell_h)

            position_entry(item,r,c)

            instance:add(item)

            entries[r][c] = item

            --the last visible row needs to be at half opacity
            if r == 4 then item.opacity = 127 end
        end
    end

    local w = (cell_w+x_spacing)*#entries[1]-x_spacing
    instance.anchor_point = {w/2,0}

    ----------------------------------------------------------
    local        fly_duration = 1250
    local grid_slide_duration = 1000
    local     mode = "EASE_OUT_EXPO"
    local fly_mode = "EASE_IN_OUT_BACK"
    local deleting = false
    local again = false
    function instance:delete(d_r,d_c)

        if deleting then return end

        deleting = true

        local dur = (.5*grid_slide_duration)/fly_duration
        local grid_end = grid_slide_duration/fly_duration
        local properties = {}

        for r,row in ipairs(entries) do
            for c,item in ipairs(row) do

                --items towards the upper-left begin moving before the items
                --towards the lower-right
                local t_start = dur*(r-1+(c-1)/#entries[1])/(#entries+1)

                if r < d_r or r==d_r and c < d_c then
                    --ignore these
                elseif r == d_r and c == d_c then
                    --delete this one
                    if item.parent then
                        table.insert(
                            properties,
                            {
                                source = item,
                                name   = "opacity",
                                keys   = {
                                    {0.0,    mode,255},
                                    {t_start,mode,255},
                                    {grid_end,    mode,  0},
                                },
                            }
                        )
                    end
                elseif c == 1 then
                    --these wrap around
                    item:raise_to_top()
                    table.insert(
                        properties,
                        {
                            source = item,
                            name   = "x",
                            keys   = {
                                {0.0,    fly_mode,item.x},
                                {t_start,fly_mode,item.x},
                                {1.0,    fly_mode,w-(cell_w)},
                            },
                        }
                    )
                    table.insert(
                        properties,
                        {
                            source = item,
                            name   = "y",
                            keys   = {
                                {0.0,    fly_mode,item.y},
                                {t_start,fly_mode,item.y},
                                {1.0,    fly_mode,item.y-(cell_h+y_spacing)},
                            },
                        }
                    )
                    --set items coming in from the last visible row to full opacity
                    if r == 4 then --hooray hardcoding
                        table.insert(
                            properties,
                            {
                                source = item,
                                name   = "opacity",
                                keys   = {
                                    {0.0,    mode,item.opacity},
                                    {t_start,mode,item.opacity},
                                    {1.0,    mode,         255},
                                },
                            }
                        )
                    end
                else
                    --these slide left
                    table.insert(
                        properties,
                        {
                            source = item,
                            name   = "x",
                            keys   = {
                                {0.0,      mode,item.x},
                                {t_start,  mode,item.x},
                                {grid_end, mode,item.x-(cell_w+x_spacing)},
                            },
                        }
                    )
                end
            end
        end

        local a = Animator{
            duration   = grid_slide_duration*dur_mult,
            properties = properties
        }
        function a.timeline.on_completed()

            --unparent the entry the is being deleted and
            --shift the indices of all the entries
            --the row of the deleted entry is handled separately
            table.remove(entries[d_r],d_c):unparent()

            --all the rows below
            for r=d_r+1,#entries do
                --the left most index wraps around to the row above
                --all the others are shifted left
                entries[r-1][#entries[r-1]+1] = table.remove(entries[r],1)
            end

            --if the deletion caused the last row to be empty, set to nil
            if #entries[#entries] == 0 then entries[#entries] = nil end

            -----------------------------------------------------------
            --if there are only 2 rows left, add 2 more
            if #entries < 3 then
                local new_rows = {
                    {
                        {text="Poker",         src="icons-poker-dawgz.png",        app="com.trickplay.poker-dawgz"},
                        {text="Physics",       src="icon-physics-trickplay.png",   app="com.trickplay.physics-showcase"},
                        {text="Weather",       src="icon-weather-trickplay.png",   app="com.trickplay.weather"},
                        {text="Groupon",       src="icon-groupon-trickplay.png",   app="com.trickplay.groupon"},
                        {text="Dawn",          src="icon-liberty-global.png",      app="com.lgi.dawn-ui"},
                        {text="App Shop",      src="icon-apps-trickplay.png",      app="com.trickplay.app-shop"},
                        {text="On Demand",     src="icon-vod-trickplay.png",       app="com.trickplay.jyp"},
                        {text="Penguins",      src="icon-penguin.png",             app="com.trickplay.penguins"},
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
                }
                for r,row in ipairs(new_rows) do
                    --need to add 2 to append to the end of the existing rows
                    r = r + 2
                    entries[r] = {}
                    for c,item in ipairs(row) do

                        item = make_icon(item,cell_w,cell_h)

                        position_entry(item,r,c)

                        instance:add(item)

                        entries[r][c] = item

                        if r == 4 then item.opacity = 127 end
                    end
                end
            end
            -----------------------------------------------------------
            --deleting = false

            if again then
                if deletion_delay and deletion_delay > 0 then
                    dolater(deletion_delay,function()
                        deleting = false
                        instance:delete(d_r,d_c)
                    end)
                else
                    deleting = false
                    instance:delete(d_r,d_c)
                end
            else
                deleting = false
            end
        end

        a:start()
    end

    ----------------------------------------------------------
    function instance:make_icons_reactive()
        for i,row in ipairs(entries) do
            for i,icon in ipairs(row) do
                icon.reactive = true
            end
        end
    end

    ----------------------------------------------------------
    --Create the highlight that traverses the icons
    local sel_r = 1
    local sel_c = 1

    local hl  = Sprite{
        name  = "My Apps Highlight",
        sheet = assets,
        id    = "focus-block.png",
        opacity = 0,
        w       = (cell_w+x_spacing),
        h       = (cell_h+x_spacing),
    }
    instance.hl = hl
    hl.anchor_point = {hl.w/2,hl.h/2}
    instance:add(hl)
    --sets the position of the highlight to sel_r,sel_c
    local function move_hl()
        hl:stop_animation()
        hl:animate{
            duration = 100*dur_mult,
            mode="EASE_OUT_QUAD",
            x = (cell_w+x_spacing)*(sel_c-1)+55,
            y = (cell_h+y_spacing)*(sel_r-1)+70,
        }
    end
    move_hl()
    ----------------------------------------------------------
    --key events
    local key_events = {
        --delete the selected icon
        [keys.OK] = function()
            print(apps,entries[sel_r][sel_c].app)
            if apps and entries[sel_r][sel_c].app then

                local dur = 250

                screen:animate{duration=dur,opacity=0}

                local c = entries[sel_r][sel_c].icon
                c = Clone{source =c,position= c.transformed_position}
                screen:add(c)

                c:animate{
                    duration = dur,
                    scale = {screen.w/c.w,screen.w/c.w},
                    x=0,y=0,
                    on_completed = function()
                        apps:launch(entries[sel_r][sel_c].app)
                    end
                }
                screen:grab_key_focus()
            elseif not deleting then
                --if there more than one left
                if entries[1][2] then
                    instance:delete(sel_r,sel_c)
                    --if you are deleting to icon at the very end,
                    --then move the highlight to the next one
                    if sel_r == #entries and sel_c == #entries[#entries] then
                        --if the last icon is in the leftmost column
                        if  sel_c == 1 then
                            --then the highlight needs to wrap around to
                            --the rightmost columns
                            sel_r = sel_r-1
                            sel_c = #entries[sel_r-1]
                        else
                            sel_c = sel_c - 1
                        end
                        move_hl()
                    end
                end
            end
        end,
        [keys.Up] = function()
            if entries[sel_r-1] and entries[sel_r-1][sel_c] then
                sel_r = sel_r-1
                move_hl()
                return true
            end
        end,
        [keys.Down] = function()
            if entries[sel_r+1] and entries[sel_r+1][sel_c] then
                sel_r = sel_r+1
                move_hl()
                return true
            end
        end,
        [keys.Left] = function()
            if entries[sel_r][sel_c-1] then
                sel_c = sel_c-1
                move_hl()
                return true
            end
        end,
        [keys.Right] = function()

            if entries[sel_r][sel_c+1] then
                sel_c = sel_c+1
                move_hl()
                return true
            end
        end,
        [keys.RED] = function()
            if again then
                again = false
            else
                again = true
                sel_r = 1
                sel_c = 1
                move_hl()
                if not deleting then instance:delete(sel_r,sel_c) end
            end
        end,
    }
    instance.key_events = key_events
    function instance:on_key_down(k)
        --block the event if the deletion animation is repeating
        return (not again or k == keys.RED) and
            --block the even if the animation to the cube is repeating
            (not my_apps_to_cube_repeat  or k == keys.GREEN) and
            --otherwise call the event, if there is an event setup
            key_events[k] and key_events[k]()
    end

    return instance

end


