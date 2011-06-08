local page_bgs = {
	"assets/middle/1.png",
	"assets/middle/2.png",
	"assets/middle/3.png",
	"assets/middle/4.png",
	"assets/middle/5.png",
	"assets/middle/6.png",
	"assets/middle/7.png",
	"assets/middle/8.png",
}

local carousel = Group{name="CAROUSEL"}

carousel.pages = {}

for i,src in ipairs(page_bgs) do
    
    carousel.pages[i] = PAGE_CONSTRUCTOR(src)
    
    carousel.pages[i].name = "PAGE "..i
    
    carousel:add(carousel.pages[i])
end

carousel.x=LEFT_BAR.w + carousel.pages[1].w*4/3

local lock = Timer{
	interval = TRANS_DUR,
	on_timer = function(self)
		self:stop()
		KEY_HANDLER.release()
	end
}
lock:stop()
local curr_focus = 1

carousel.pages[curr_focus]:bring_to_front()

local keys_BOTTLES = {
    [keys.Left] = function()
		
		if curr_focus==1 then
			--GLOBAL_STATE:change_state_to("STOPPED")
			return
		end	
		
		carousel.pages[curr_focus].state:change_state_to("ANIMATING_OUT_TO_RIGHT")
		
		curr_focus = curr_focus - 1
		
		carousel.pages[curr_focus].state:change_state_to("ANIMATING_IN_FROM_LEFT")
		
		KEY_HANDLER.hold()
		
		lock:start()
	end,
	[keys.Right] = function()
		if curr_focus==#page_bgs then
			--GLOBAL_STATE:change_state_to("STOPPED")
			return
		end
		
		carousel.pages[curr_focus].state:change_state_to("ANIMATING_OUT_TO_LEFT")
		
		curr_focus = curr_focus + 1
		
		carousel.pages[curr_focus].state:change_state_to("ANIMATING_IN_FROM_RIGHT")
		
		KEY_HANDLER.hold()
		
		lock:start()
	end,
}

KEY_HANDLER:add_keys("BOTTLES",keys_BOTTLES)


return carousel