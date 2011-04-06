local base = {
    straight_road = Image{src="road-straight.png"},
    straight_road = Image{src="road-curve2.png"}
}
for _,v in ipairs(base) do
    clone_sources:add(base)
end
sections = {}

local function make_straight_section(tiles)
    local section = {
        endpoint = {0,0},
        line_up  = {0,0},
        setup = function(self)
            self.group = Group{}
            
        end,
    }
    
    return section
end

local function make_curved_section(dir)
    local section = {
        endpoint = {0,0},
        line_up  = {0,0},
        setup = function(self)
            
        end,
    }
    
    return section
end

sections[1] = {
    endpoint = {0,0},
    line_up  = {0,0},
    setup = function(self)
        Clone
    end
}