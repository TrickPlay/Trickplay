
function apply_func_to_leaves(t,f,p)
    for k,v in pairs(t) do
        --recurse through other tables
        if type(v) == "table" then
            apply_func_to_leaves(v,f,p)
        else
            f(p,v)
        end
    end
end

function Shadow_Text(t)
    local g = Group{}
    local base_txt = Text(t)
    local shadow_txt = Text(t)
    
    if t.x ~= nil then g.x = t.x end

    if t.y ~= nil then g.y = t.y end
    
    if t.position ~= nil then g.position = {t.position[1],t.position[2]} end
    
    base_txt.position   = {0,0}
    shadow_txt.position = {2,2}
    shadow_txt.color    = {0,0,0}
    shadow_txt.opacity  = 255*.4
    
    g:add(shadow_txt,base_txt)
    
    
    local mt = {}
    
    function mt.__newindex(t,k,v)
        
        base_txt[k]   = v
        shadow_txt[k] = v
        
        base_txt.position   = {0,0}
        shadow_txt.position = {2,2}
        shadow_txt.color    = {0,0,0}
        shadow_txt.opacity  = 255*.4
    end
    setmetatable(g.extra,mt)
    
    return g
end


imgs = {
	rain_clouds = {
		lg = {
			--Image{src="assets/clouds/clouds-stormy1.png"},
			"assets/clouds/clouds-stormy2.png",
		},--[[
		sm = {
			Image{src="assets/clouds/clouds-stormy-small1.png"},
			Image{src="assets/clouds/clouds-stormy-small2.png"},
		}--]]
	},
	reg_clouds = {
		lg = {
			"assets/clouds/clouds-fluffy1.png",
			"assets/clouds/clouds-fluffy2.png",
			"assets/clouds/clouds-fluffy4.png",
			"assets/clouds/clouds-fluffy6.png",
			"assets/clouds/clouds-fluffy7.png",
			"assets/clouds/clouds-fluffy8.png",
			"assets/clouds/clouds-fluffy9.png",
		},
		sm = {
			"assets/clouds/clouds-fluffy-small1.png",
			"assets/clouds/clouds-fluffy-small2.png",
			"assets/clouds/clouds-fluffy-small3.png",
			"assets/clouds/clouds-fluffy-small4.png",
			"assets/clouds/clouds-fluffy-small5.png",
		},
	},
	fog = "assets/clouds/fog.png",
	glow_cloud = "assets/clouds/clouds-stormy-glow.png",
	moon  = "assets/night/moon.png",
	star  = "assets/night/star.png",
	stars = "assets/night/stars.png",
	rain  = {
		falling = "assets/rain/falling.png",
		--[[
		streak = {
			Image{src="assets/rain/rain-streak.png"},
			Image{src="assets/rain/rain-streak2.png"},
		},--]]
		light  = "assets/rain/rain-light.png",
		--[[
		clump  = Image{src="assets/rain/rain-clump.png"},
		--]]
		drops  = {
			"assets/rain/raindrop1.png",
			"assets/rain/raindrop2.png",
			"assets/rain/raindrop3.png",
			"assets/rain/raindrop4.png",
			"assets/rain/raindrop5.png",
		},
	},
	--frost_corner = Image{src="assets/snow/frost.png"},
	snow_corner  = "assets/snow/snow.png",
	snow_flake = {
		lg = {
			"assets/snow/snowflake-lg1.png",
			"assets/snow/snowflake-lg2.png",
			"assets/snow/snowflake-lg3.png",
			"assets/snow/snowflake-lg4.png",
		},--[[
		lg_blur = {
			Image{src="assets/snow/snowflake-lg-blur1.png"},
			Image{src="assets/snow/snowflake-lg-blur2.png"},
			Image{src="assets/snow/snowflake-lg-blur3.png"},
			Image{src="assets/snow/snowflake-lg-blur4.png"},
			Image{src="assets/snow/snowflake-lg-blur5.png"},
		},--]]
		sm = {
			"assets/snow/snowflake-small1.png",
			"assets/snow/snowflake-small2.png",
			"assets/snow/snowflake-small3.png",
		}
	},
	sun = {
		base  = "assets/sun/sun_base.png",
		flare = {
			"assets/sun/sun_flare1.png",
			"assets/sun/sun_flare2.png",
			"assets/sun/sun_flare3.png",
		}
	},
	arrows = {
		left  = "assets/ui/arrow_left.png",
		right = "assets/ui/arrow_right.png",
	},
	bar = {
		side = "assets/ui/bar/end.png",
		mid  = "assets/ui/bar/middle.png",
		--full = Image{src="assets/ui/bar-full.png"},
		--mini = Image{src="assets/ui/bar-mini.png"},
	},
	gradient = {
		full = "assets/ui/gradient-full.png",
		mini = "assets/ui/gradient-mini.png"
	},
	color_button = {
		green_less  = "assets/ui/button-less.png",
		green_more  = "assets/ui/button-more.png",
		blue_5_day  = "assets/ui/button-5day.png",
		blue_today  = "assets/ui/button-today.png",
		yellow      = "assets/ui/button-options.png",
	},
	logo      = "assets/ui/logo.png",
	lightning = {
		"assets/lightning/lightning-bolt.png",
		"assets/lightning/lightning-bolt2.png",
		"assets/lightning/lightning-bolt3.png",
	},
	wiper     = {
		arm        = "assets/rain/rain-wiper-arm.png",
		blade      = "assets/rain/rain-wiper-blade.png",
		snow_blade = "assets/rain/rain-wiper-blade-snow.png",
		corner     = "assets/rain/rain-corner.png",
		freezing   = "assets/rain/frost2.png",
	},
	qmark = "assets/ui/questionmark.png",
	load = {
		sun_base    = "assets/ui/loading/load-sun-center.png",
		light_flare = "assets/ui/loading/load-sun-spin.png",
		dark_flare  = "assets/ui/loading/load-sun-shadow.png",
		error       = "assets/ui/loading/load-error.png"
	},
	
	icons = {
		chanceflurries = "assets/icons/icon-chanceflurries.png",
		chancerain     = "assets/icons/icon-chancerain.png",
		chancesleet    = "assets/icons/icon-chancesleet.png",
		chancesnow     = "assets/icons/icon-chancesnow.png",
		chancetstorms  = "assets/icons/icon-chancetstorm.png",
		clear          = nil,
		cloudy         = "assets/icons/icon-cloudy.png",
		flurries       = "assets/icons/icon-flurries.png",
		fog            = "assets/icons/icon-fog.png",
		hazy           = "assets/icons/icon-hazy.png",
		mostlycloudy   = "assets/icons/icon-mostlycloudy.png",
		mostlysunny    = nil,
		partlycloudy   = "assets/icons/icon-partlycloudy.png",
		partlysunny    = nil,
		rain           = "assets/icons/icon-rain.png",
		sleet          = "assets/icons/icon-sleet.png",
		snow           = "assets/icons/icon-snow.png",
		sunny          = "assets/icons/icon-sunny.png",
		tstorms        = "assets/icons/icon-tstorm.png",
		unknown        = "assets/icons/icon-unknown.png",
	}
}
imgs.icons.partlysunny = imgs.icons.mostlycloudy
imgs.icons.mostlysunny = imgs.icons.partlycloudy
imgs.icons.clear       = imgs.icons.sunny

local clone_sources_group = Group{name="clone sources"}
local clone_sources_table = {}

screen:add(clone_sources_group)
clone_sources_group:hide()

--save the function pointer to the old Clone constructor
local TP_Clone = Clone
local TP_Image = Image
--Image = nil
--local deletion_spy
--The new Clone Constructor
Clone = function(t)
	
	--must be created the same way you typically create Clones
	assert(type(t) == "table","Clone receives a table as its parameter,"..
		" received a parameter of type "..type(t))
    if t.source == nil then
        dumptable(t)
        error("Clone requires a source")
    end
	
	
	--If an asset has not been loaded in yet, then load it
	if clone_sources_table[t.source] == nil then
		
		clone_sources_table[t.source] = TP_Image{src=t.source,extra={count=0}}
		
		clone_sources_group:add(clone_sources_table[t.source])
		
	end
	
	
	clone_sources_table[t.source].count = clone_sources_table[t.source].count+1
	
	--print("I HAVE THIS MANY",clone_sources_table[t.source].count)
	
	local deletion_spy = newproxy(true)
	
	local sauce = t.source
	
	getmetatable( deletion_spy ).__gc = function()
		
		clone_sources_table[sauce].count = clone_sources_table[sauce].count - 1
		
		--print("DECREMENTTTTTT",clone_sources_table[sauce].count)
		
		if clone_sources_table[sauce].count == 0 then
			
			clone_sources_table[sauce]:unparent()
			
			clone_sources_table[sauce] = nil
			
		end
	end
	
	--replace the string with the UI_Element
	t.source = clone_sources_table[t.source]
	
	
	--return a Clone
	t= TP_Clone(t)
	
	t.deletion_spy = deletion_spy

	return t
end




ENUM = function(array_of_states)
    
    assert(type(array_of_states) == "table")
    assert(#array_of_states > 1)
    
    --object
    local enum = {}
    
    --attributes
    
    local current_state = array_of_states[1]
    local states = {}
    local state_change_functions = {}
    
    --init attributes
    for _,state_name in pairs(array_of_states) do
        assert(states[state_name] == nil)
        states[state_name] = state_name
    end
    
    for _,prev_state in pairs(states) do
        state_change_functions[prev_state] = {}
        for _,next_state in pairs(states) do
            if prev_state ~= next_state then 
            state_change_functions[prev_state][next_state] = {}
            end
        end
    end
    --dumptable(states)
    --methods
    enum.has_state = function(self,state)
        if states[state] == state then
            return true
        else
            return false
        end
    end
    
    enum.add_state_change_function = function(self, new_function, old_state, new_state)
	assert(type(new_function)=="function", "You attempted to add an element of type \""..type(new_function).."\". This function only accepts other functions")
	if old_state ~= nil then assert(states[old_state] ~= nil, tostring(old_state).." is not a State") end
	if new_state ~= nil then assert(states[new_state] ~= nil, tostring(new_state).." is not a State") end
	if old_state == nil then
        for _,old_state in pairs(states) do
            if new_state == nil then
                for _,new_state in pairs(states) do
                    if old_state ~= new_state then 
                        table.insert(state_change_functions[old_state][new_state],new_function)
                    end
                end
            else
                if old_state ~= new_state then 
                    table.insert(state_change_functions[old_state][new_state],new_function)
                end
            end
        end
	else
	    if new_state == nil then
                for _,new_state in pairs(states) do
                    if old_state ~= new_state then 
                        table.insert(state_change_functions[old_state][new_state],new_function)
                    end
                end
            else
                assert(
                    old_state ~= new_state,
                    "Attempting to assign a state change function for same state"
                )
                table.insert(state_change_functions[old_state][new_state],new_function)
            end
        end
    end

    enum.change_state_to = function(self, new_state)
	
        if current_state == new_state then
	    
            print("warning changing state to current state")
            
	    return
            
	end
	
        assert(states[new_state] ~= nil, tostring(new_state).." is not a State")
        
	for i,func in ipairs(state_change_functions[current_state][new_state]) do
	    
            func(current_state,new_state)
            
	end
	
        current_state = new_state
        
    end
    
    enum.current_state = function()
        
        return current_state
        
    end
    
    enum.states = function()
        
        return array_of_states
        
    end
    
    return enum
    
end
