
local collapsed_spacing = 20

local ws = {
    183,
    168,
    153,
    140,
    124,
}
local hs = {
    270,
    247,
    225,
    205,
    183,
}

local tot_w = 0
for i,w in ipairs(ws) do tot_w = tot_w + w end
local collapsed_w = ws[1] + collapsed_spacing*(#ws-1)


return function(dur)
    local instance = Group{w = tot_w}
    local items
    if items == nil then
        items = {}
        for i = 1,#ws do
            items[i] = Clone{--Rectangle{
                source = random_poster(),
                w = ws[i],
                h = hs[i],
                y = hs[1] - hs[i],
                --color = {rand(),rand(),rand(),}
            }
        end
    end
    dur = dur or 200
    local intervals = {}
    
    for i,c in ipairs(items) do
        instance:add(c) 
        c:lower_to_bottom() 
        intervals[i] = Interval(
            intervals[i-1] and collapsed_spacing +(ws[i-1] - ws[i])+intervals[i-1].from or (tot_w - collapsed_w)/2,
            ws[i-1] and ws[i-1]+intervals[i-1].to or 0
        )
    end
    for i,c in ipairs(instance.children) do 
        c.x = intervals[#intervals-i+1].to
    end
    
    local expand = Timeline{
        duration = 200,--dur,
        on_new_frame = function(tl,ms,p)
            for i,c in ipairs(instance.children) do
                c.x = intervals[#intervals - i+1]:get_value(p)
            end
        end
    }
    local collapse = Timeline{
        duration = 200,--dur,
        on_new_frame = function(tl,ms,p)
            for i,c in ipairs(instance.children) do
                c.x = intervals[#intervals - i+1]:get_value(1-p)
            end
        end
    }
    instance.on_key_focus_in  = function(self) expand:start()   end
    instance.on_key_focus_out = function(self) collapse:start() end
    
    return instance
end