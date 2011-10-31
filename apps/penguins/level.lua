local def = ...
local group = Group()
local layout = {}
local events = {}
local scenery = {}
local ap, g, e, l

if def[5] then
    g = Group()
    group:add(Clone{source = bg_slice, position = {0,640}})
    gentrees(group,640+536)
    group:add(Clone{source = bg_floor, position = {0,640+536}},
            Clone{source = bg_floor, position = {1920,640+536}, scale = {-1,1}})
    
    events = loadfile("/screens/"..def[5]..".lua")(g) or {}
    
    l = ui_element.populate_to(g,{})
    for k,v in pairs(l) do
        v.name = v.name .. "_r2"
        v.y = v.y + 640
        layout[v.name] = v
    end
    
    group.text1 = Text{text = def[4], font = "Sigmar 52px",
                    position = {30,-140}, color = "036BB4", opacity = 0}
    group.text2 = Text{text = def[6], font = "Sigmar 52px",
                    position = {900,640-130}, color = "036BB4",
                    alignment = "RIGHT", w = 990, opacity = 0}
    group:add(g,Clone{source = bg_slice, position = {0,0}},
            Clone{source = bg_sun, position = {math.random(300,1600),100}})
    gentrees(group,536)
    group:add(group.text1,group.text2,Clone{source = bg_floor, position = {0,536}},
            Clone{source = bg_floor, position = {1920,536}, scale = {-1,1}},
            Clone{source = igloo_back, position = {235,374,0}})
end


g = Group()
e = loadfile("/screens/"..def[3]..".lua")(g) or {}
for k,v in ipairs(e) do
    events[#events+1] = v
end

ui_element.populate_to(g,layout)
for k,v in pairs(layout) do
    ap = v.anchor_point
    v.bb = {l = v.x - ap[1], r = v.x - ap[1] + v.w*v.scale[1],
            t = v.y - ap[2], b = v.y - ap[2] + v.h*v.scale[2]}
    v.collide = v.reactive
    v.reactive = false
end

group:add(g)

group.layout = layout
group.events = events
group.name = def[1]
group.snow = def[2]
group.id = #levels+1

return group