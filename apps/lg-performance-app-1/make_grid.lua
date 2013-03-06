
-------------------------------------------------------------

local function make_icon(item)
    local instance = Group()

    local r = Sprite{sheet = assets,id=item.src}
    local checkbox = Sprite{sheet=assets,id="checkbox.png"}
    checkbox.w = checkbox.w*3/2
    checkbox.h = checkbox.h*3/2
    checkbox.x = -checkbox.w

    r.w = r.w*3/2
    r.h = r.h*3/2

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
        end
    end

    local w = (cell_w+x_spacing)*#entries[1]-x_spacing
    instance.anchor_point = {w/2,0}


    return instance

end

return make_grid
