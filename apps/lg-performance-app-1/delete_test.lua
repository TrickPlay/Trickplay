
local icon_font = "Lato 40px"
local screen_w = screen.w

local recycle_bin = Image{src="recycle bin.png"}
screen:add(recycle_bin)
-------------------------------------------------------------
local function make_icon(item)
    local instance = Group()

    local r = Sprite{sheet = assets,id=item.src}
    --r.w = r.w*3/2
    --r.h = r.h*3/2

    local w = r.w
    local h = r.h

    local t = Text{text = item.text,font = ICON_FONT, color = "white",y = r.h,x=r.w/2}

    t.anchor_point = {t.w/2,0}

    instance:add(r,t)

    local grabbed = false
    local last_x, last_y,orig_x,orig_y
    function instance:on_button_down(x,y)
        instance:grab_pointer()
        grabbed = true
        last_y = y
        last_x = x
        orig_y = instance.y
        orig_x = instance.x
    end
    function instance:on_motion( x,y )
        if grabbed then
            instance:move_by(x-last_x,y-last_y)
            last_x = x
            last_y = y
        end
    end
    function instance:on_button_up(x,y)
        if grabbed then
            grabbed = false
            instance:ungrab_pointer()

            if
                x > recycle_bin.x and
                x < recycle_bin.x + recycle_bin.w and
                y > recycle_bin.y and
                y < recycle_bin.y + recycle_bin.h then

                instance.parent:delete(
                    instance.r,instance.c
                )

            else
                instance:animate{
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
return function(items,cell_w,cell_h,x_spacing,y_spacing)

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
        end
    end

    local w = (cell_w+x_spacing)*#entries[1]-x_spacing
    instance.anchor_point = {w/2,0}

    local deletion_duration = 250
    function instance:delete(d_r,d_c,n)
        n = n or 1

        local sliding_left = Group()
        local wrapping_around = Group()
        instance:add(sliding_left,wrapping_around)
        local dur = .5
        local properties = {}

        for r,row in ipairs(entries) do
            for c,item in ipairs(row) do
                local t_start = dur*(r-1+(c-1)/#entries[1])/(#entries+1)
                local t_end   = 0--t_start+dur
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
                                    {0.0,"EASE_OUT_CIRC",255},
                                    {t_start,"EASE_OUT_CIRC",255},
                                    {t_end,"EASE_OUT_CIRC",  0},
                                    {1.0,"EASE_OUT_CIRC",  0},
                                },
                            }
                        )
                    end
                elseif c == 1 then
                    --these wrap around
                    --item:unparent()
                    --wrapping_around:add(item)
                    table.insert(
                        properties,
                        {
                            source = item,
                            name   = "x",
                            keys   = {
                                {0.0,"EASE_OUT_CIRC",item.x},
                                {t_start,"EASE_OUT_CIRC",item.x},
                                {t_end,"EASE_OUT_CIRC",w-(cell_w)},
                                {1.0,"EASE_OUT_CIRC",w-(cell_w)},
                            },
                        }
                    )
                    table.insert(
                        properties,
                        {
                            source = item,
                            name   = "y",
                            keys   = {
                                {0.0,"EASE_OUT_CIRC",item.y},
                                {t_start,"EASE_OUT_CIRC",item.y},
                                {t_end,"EASE_OUT_CIRC",item.y-(cell_h+y_spacing)},
                                {1.0,"EASE_OUT_CIRC",item.y-(cell_h+y_spacing)},
                            },
                        }
                    )
                else
                    --these slide left
                    --item:unparent()
                    --sliding_left:add(item)
                    table.insert(
                        properties,
                        {
                            source = item,
                            name   = "x",
                            keys   = {
                                {0.0,"EASE_OUT_CIRC",item.x},
                                {t_start,"EASE_OUT_CIRC",item.x},
                                {t_end,"EASE_OUT_CIRC",item.x-(cell_w+x_spacing)},
                                {1.0,"EASE_OUT_CIRC",item.x-(cell_w+x_spacing)},
                            },
                        }
                    )
                end
            end
        end

        local a = Animator{
            duration = deletion_duration*dur_mult,
            properties = properties
        }
---[=[
        function a.timeline.on_completed()

            if entries[d_r][d_c].parent then
                entries[d_r][d_c]:unparent()
            end
            for c=d_c+1,#entries[d_r] do
                entries[d_r][c-1] = entries[d_r][c]
                position_entry(entries[d_r][c-1],d_r,c-1)
            end
            for r=d_r+1,#entries do
                entries[r-1][#entries[r-1]] = entries[r][1]
                position_entry(
                    entries[r-1][#entries[r-1]],r-1,#entries[r-1]
                )
                for c=2,#entries[r] do
                    entries[r][c-1] = entries[r][c]
                    position_entry(entries[r][c-1],r,c-1)
                end
            end

            entries[#entries][#entries[#entries]] = nil
            if #entries[#entries] == 0 then entries[#entries] = nil end
            if n > 1 then
                dolater(
                    instance.delete,
                    instance,
                    d_r,d_c,n-1
                )
            end
        end
--]=]
        dolater(a.start,a)
    end

    function instance:make_icons_reactive()
        for i,row in ipairs(entries) do
            for i,icon in ipairs(row) do
                icon.reactive = true
            end
        end
    end

    local sel_r = 1
    local sel_c = 1
    local hl  = Sprite{
        sheet = assets,
        id    = "focus-block.png",
        opacity = 0,
        x = entries[sel_r][sel_c].x+55,
        y = entries[sel_r][sel_c].y+70,
    }
    instance.hl = hl
    hl.w = (cell_w+x_spacing)
    hl.h = (cell_h+x_spacing)
    hl.anchor_point = {hl.w/2,hl.h/2}
    instance:add(hl)
    local function move_hl()
        hl:stop_animation()
        hl:animate{
            duration = 100*dur_mult,
            mode="EASE_OUT_QUAD",
            x = entries[sel_r][sel_c].x+55,
            y = entries[sel_r][sel_c].y+70,
        }
    end
    local key_events = {
        [keys.OK] = function()
            if entries[1][2] then
                instance:delete(sel_r,sel_c)
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
    }
    instance.key_events = key_events
    function instance:on_key_down(k)
        return key_events[k] and key_events[k]()
    end
    return instance

end


