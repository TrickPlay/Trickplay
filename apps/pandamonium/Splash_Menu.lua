local Splash = Group{name = "Splash",opacity = 0}

--Visual Components
local title      = Clone{
	source       = assets.title,
	anchor_point = {assets.title.w/2,assets.title.h/2},
	position     = {screen.w/2, 150},
}

local start      = Clone{
	source       = assets.start,
	anchor_point = {0, assets.play_again.h/2},
	position     = {screen.w/2, 400},
}

local quit       = Clone{
	source       = assets.quit,
	anchor_point = {0, assets.quit.h/2},
	position     = {screen.w/2, 500},
}

local arrow      = Clone{
	source       = assets.arrow,
	anchor_point = {assets.arrow.w, assets.arrow.h/2},
	position     = {screen.w/2-50, start.y},
}

Splash:add(title,start,quit,arrow)


--Behavior

local menu_items = {
	start,
	quit
}

local curr_y = 0

function arrow:move_to(i)
	
	curr_y = arrow.y
	
	arrow:complete_animation()
	
	arrow.y = curr_y
	
	arrow:animate{
		duration = 200,
		y        = menu_items[i].y
	}
end


function quit:press_enter()
	exit()
end

local curr_opacity

function start:press_enter()
	
	curr_opacity = Splash.opacity
	
	Splash:complete_animation()
	
	Splash.opacity = curr_opacity
	
	Splash:animate{
		duration = 300,
		opacity  = 0,
		on_completed = function()
			screen.on_key_down = panda.on_key_down
			physics:start()
		end
	}
end

function Splash:fade_in()
	
	index = 1
	
	arrow.y = menu_items[index].y
	
	curr_opacity = Splash.opacity
	
	Splash:complete_animation()
	
	Splash.opacity = curr_opacity
	
	Splash:raise_to_top()
	
	Splash:animate{
		duration = 300,
		opacity  = 255,
		on_completed = function()
			screen.on_key_down = self.on_key_down
		end
	}
end

local index = 1

local keys = {
	
	[keys.Down] = function()
        
		if index == # menu_items then return end
		
		index = index + 1
		
		arrow:move_to(index)
		
    end,
	[keys.Up] = function()
		
		if index == 1 then return end
		
		index = index - 1
		
		arrow:move_to(index)
		
    end,
	[keys.OK] = function()
		menu_items[index]:press_enter()
    end,
}

function Splash:on_key_down(k)    if keys[k] then    keys[k]()    end    end

screen:add(Splash)

return Splash