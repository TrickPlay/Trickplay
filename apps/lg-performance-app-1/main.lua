
local icon_font = "Lato 40px"
local screen_w = screen.w

screen:show()

local function make_icon(text,w,h)
    local instance = Group()

    local r = Rectangle{w=w,h=h}

    local t = Text{text = text,font = icon_font, color = "white",y = h,x=w/2}

    t.anchor_point = {t.w/2,0}

    instance:add(r,t)
    return instance
end


local function make_grid(items,cell_w,cell_h,x_spacing,y_spacing)

    local instance = Group()

    local entries = {}
    local function position_entry(item,r,c)
        item.x = (cell_w+x_spacing)*(c-1)
        item.y = (cell_h+y_spacing)*(r-1)
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
            duration = deletion_duration,
            properties = properties--[[{
                {
                    source = entries[d_r][d_c],
                    name   = "opacity",
                    keys   = {
                        {0.0,"EASE_OUT_CIRC",255},
                        {1.0,"EASE_OUT_CIRC",  0},
                    },
                },
                {
                    source = wrapping_around,
                    name   = "x",
                    keys   = {
                        {0.0,"EASE_OUT_CIRC",0},
                        {1.0,"EASE_OUT_CIRC",w-(cell_w)},
                    },
                },
                {
                    source = wrapping_around,
                    name   = "y",
                    keys   = {
                        {0.0,"EASE_OUT_CIRC",0},
                        {1.0,"EASE_OUT_CIRC", -(cell_h+y_spacing)},
                    },
                },
                {
                    source = sliding_left,
                    name   = "x",
                    keys   = {
                        {0.0,"EASE_OUT_CIRC", 0},
                        {1.0,"EASE_OUT_CIRC", -(cell_w+x_spacing)},
                    },
                },
            }--]]
        }
---[=[
        function a.timeline.on_completed()
--[[
            local items = sliding_left.children
            sliding_left:clear()
            sliding_left:unparent()
            instance:add(unpack(items))

            items = wrapping_around.children
            wrapping_around:clear()
            wrapping_around:unparent()
            instance:add(unpack(items))
--]]
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

    return instance

end

-------------------------------------------------------------
local items = {}
for i=1,4 do
    items[i] = {}
    for j=1,10 do
        items[i][j] = "Icon "..i.." "..j
    end
end
grid = make_grid(items,100,100,80,80)

grid.x = screen_w/2
grid.y = 400
screen:add(grid)

-------------------------------------------------------------
items = {}
for i=1,4 do
    items[i] = {}
    for j=1,9 do
        items[i][j] = "Icon "..i.." "..j
    end
end
modal_menu = make_grid(items,100,100,80,80)

modal_menu.x = screen_w/2
modal_menu.y = 100

r = Rectangle{w=1700,h=800,x=-50,y=-50,color = "red"}

modal_menu:add(r)
r:lower_to_bottom()

modal_menu.opacity = 0

function modal_menu:focus()
    modal_menu:animate{
        duration = 250,
        opacity = 255,
    }
    modal_menu:animate{
        duration = 300,
        mode = "EASE_OUT_BOUNCE",
        z = 0,
    }
end
function modal_menu:unfocus()
    modal_menu:animate{
        duration = 250,
        opacity = 0,
        z = -100,
    }
end

screen:add(modal_menu)
modal_menu.z = -100

