
local icon_font = "Lato 30px"
-------------------------------------------------------------
local function make_icon(text,w,h)
    local instance = Group()

    local r = Rectangle{w=w,h=h}

    local t = Text{text = text,font = icon_font, color = "666666",y = h,x=w/2}

    t.anchor_point = {t.w/2,0}

    instance:add(r,t)
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
