local masks = {
    Image{src="assets/left/masks/1.png"},
    Image{src="assets/left/masks/2.png",opacity=0},
    Image{src="assets/left/masks/3.png",opacity=0},
    Image{src="assets/left/masks/4.png",opacity=0},
    Image{src="assets/left/masks/5.png",opacity=0},
    Image{src="assets/left/masks/6.png",opacity=0},
    Image{src="assets/left/masks/7.png",opacity=0},
    Image{src="assets/left/masks/8.png",opacity=0},
}

local bottle_bg = {
    Image{src="assets/left/bottle_bg/3d-bottle-bg-1.png",tile={true,false}},
    Image{src="assets/left/bottle_bg/3d-bottle-bg-2.png",opacity=0,tile={true,false}},
    Image{src="assets/left/bottle_bg/3d-bottle-bg-3.png",opacity=0,tile={true,false}},
    Image{src="assets/left/bottle_bg/3d-bottle-bg-4.png",opacity=0,tile={true,false}},
    Image{src="assets/left/bottle_bg/3d-bottle-bg-5.png",opacity=0,tile={true,false}},
    Image{src="assets/left/bottle_bg/3d-bottle-bg-6.png",opacity=0,tile={true,false}},
    Image{src="assets/left/bottle_bg/3d-bottle-bg-7.png",opacity=0,tile={true,false}},
    Image{src="assets/left/bottle_bg/3d-bottle-bg-8.png",opacity=0,tile={true,false}},
}
local bottle_bg_scale = 1.5--468
for i,v in ipairs(masks) do
	v.scale = {4/3,4/3}
	bottle_bg[i].scale = {bottle_bg_scale,bottle_bg_scale}
end


local bottle_bg_w = bottle_bg[1].w

local curr_focus = 1

local left_bar = Group{}
left_bar:add(Rectangle{color="#000000",w=masks[1].w*4/3,h=screen_h})


local bottle_w = bottle_bg_w*bottle_bg_scale

local bottles = Group{y=351}

bottles:add(bottle_bg[1])

left_bar:add(bottles)
left_bar:add(Image{src="assets/left/mask.png",scale = {4/3,4/3}})
left_bar:add(unpack(masks))
left_bar:add(BOTTLE_DOCK)

local bottle_turn = function(self,msecs,p)
    
	bottles.x = -bottle_bg_w*p*bottle_bg_scale - 200
    
    bottle_w = bottle_bg_w+p*bottle_bg_w+100
    
    for _,child in pairs(bottles.children) do
        
        child.w = bottle_w
        
    end
    
end

local spinning_bottle = Timeline{
	duration = 90000,
	loop = true,
	on_new_frame = bottle_turn,
}
spinning_bottle:start()

--[[
local vert_focus_old = Image{src="assets/left/btn-round-focus.png"}

vert_focus_old.anchor_point = {vert_focus_old.w/2,vert_focus_old.h/2}

vert_focus_old.opacity = 0

local vert_focus_new = Clone{source = vert_focus_old}

vert_focus_new.anchor_point = {vert_focus_new.w/2,vert_focus_new.h/2}

vert_focus_new.opacity = 0
--]]

local vert_buttons = {
	Image{src="assets/left/btn-video.png"},
	Image{src="assets/left/btn-vote.png"}
}

local vert_focus = {Image{src="assets/left/btn-round-focus.png"}}

for i,v in ipairs(vert_buttons) do
	
	v.anchor_point = {v.w/2,v.h/2}
	
	v.x = 160
	
	v.y = 210*(i-1) + 420
	
	if i ~= 1 then
		vert_focus[i] = Clone{source = vert_focus[1]}
	end
	
	vert_focus[i].anchor_point = {vert_focus[i].w/2,vert_focus[i].h/2}
	
	vert_focus[i].opacity = 0
	
	vert_focus[i].x = v.x
	
	vert_focus[i].y = v.y
	
end
--vert_focus_old.x = 160

--vert_focus_new.x = 160

left_bar:add(unpack(vert_focus))--vert_focus_new,vert_focus_old)

left_bar:add(unpack(vert_buttons))

local vert_i = 1

local prev_opacity = 0

local function buttons_focus_out(i)
	
	assert(i > 0 and i <= #vert_buttons)
	
	prev_opacity = vert_focus[i].opacity
	
	vert_focus[i]:complete_animation()
	
	vert_focus[i].opacity = prev_opacity
	
	vert_focus[i]:animate{
		
		duration = TRANS_DUR/2,
		
		opacity  = 0,
		
	}
	
	--[[
	
	vert_focus_old:complete_animation()
	
	vert_focus_old.y = vert_buttons[index].y
	
	vert_focus_old.opacity=255
	
	vert_focus_new.opacity = 0
	
	vert_focus_old:animate{
		
		duration = TRANS_DUR,
		
		opacity  = 0,
		
	}
	
	--]]
	
end

local function buttons_focus_in(i)
	
	assert(i > 0 and i <= #vert_buttons)
	
	prev_opacity = vert_focus[i].opacity
	
	vert_focus[i]:complete_animation()
	
	vert_focus[i].opacity = prev_opacity
	
	vert_focus[i]:animate{
		
		duration = TRANS_DUR/2,
		
		opacity  = 255,
		
	}
	
	--[[
	
	assert(index > 0 and index <= #vert_buttons)
	
	vert_focus_new.y = vert_buttons[index].y
	
	vert_focus_new.opacity = 0
	
	vert_focus_new:animate{
		duration = TRANS_DUR,
		opacity  = 255,
		on_completed = KEY_HANDLER.release
	}
	
	--]]
	
end


local bottles_focus_out = function(index)
	
	assert(index > 0 and index <= #masks)
	
	masks[index]:complete_animation()
	
	masks[index]:animate{
		duration = TRANS_DUR,
		opacity = 0
	}
	
	bottle_bg[index]:complete_animation()
	
	bottle_bg[index]:animate{
		duration = TRANS_DUR,
		opacity = 0,
		on_completed = function(self)
			bottle_bg[index]:unparent()
		end
	}
	
	BOTTLE_DOCK:focus_out(index,TRANS_DUR)
end
local bottles_focus_in = function(index)
	
	assert(index > 0 and index <= #masks)
	
	BOTTLE_DOCK:focus_in(index,TRANS_DUR)
	
	masks[index]:complete_animation()
	
	masks[index]:animate{
		duration = TRANS_DUR,
		opacity = 255
	}
	
	bottles:add(bottle_bg[index])
	
	bottle_bg[index]:complete_animation()
	
	bottle_bg[index]:animate{
		duration = TRANS_DUR,
		opacity = 255
	}
end

GLOBAL_STATE:add_state_change_function(
	function(prev_state,new_state)
		buttons_focus_in(vert_i)
	end,
	nil,
	"LEFT_BUTTONS"
)
GLOBAL_STATE:add_state_change_function(
	function(prev_state,new_state)
		buttons_focus_out(vert_i)
	end,
	"LEFT_BUTTONS",
	nil
)
GLOBAL_STATE:add_state_change_function(
	function(prev_state,new_state)
		BOTTLE_DOCK:focus_in(curr_focus,TRANS_DUR)
	end,
	nil,
	"BOTTLES"
)
GLOBAL_STATE:add_state_change_function(
	function(prev_state,new_state)
		BOTTLE_DOCK:focus_out(curr_focus,TRANS_DUR)
	end,
	"BOTTLES",
	nil
)
local keys_BOTTLES = {
    [keys.Left] = function()
		
		if curr_focus==1 then return end	
		
		--KEY_HANDLER.hold()
		
		bottles_focus_out(curr_focus)
		
		curr_focus = curr_focus - 1
		
		bottles_focus_in(curr_focus)
		
	end,
	[keys.Right] = function()
		
		
		
		if curr_focus == #masks then
			
			GLOBAL_STATE:change_state_to("RIGHT_BUTTONS")
			
		else
			
			--KEY_HANDLER.hold()
			
			bottles_focus_out(curr_focus)
			
			curr_focus = curr_focus + 1
			
			bottles_focus_in(curr_focus)
			
		end
	end,
	[keys.Down] = function()
		
		--KEY_HANDLER.hold()
		
		GLOBAL_STATE:change_state_to("LEFT_BUTTONS")
		
	end,
}
local keys_BUTTONS = {
    [keys.Up] = function()
		--[[
		if vert_i == 0 then
			
			GLOBAL_STATE:change_state_to("STOPPED")
			
			return
			
		end
		--]]
		
		
		
		buttons_focus_out(vert_i)
		
		if vert_i == 1 then
			
			--KEY_HANDLER.hold()
			
			GLOBAL_STATE:change_state_to("BOTTLES")
			
		else
			
			vert_i = vert_i - 1
			
			buttons_focus_in(vert_i)
			
		end
		
	end,
	[keys.Down] = function()
		
		if vert_i == #vert_buttons then return end
		
		--KEY_HANDLER.hold()
		
		buttons_focus_out(vert_i)
		
		vert_i = vert_i + 1
		
		buttons_focus_in(vert_i)
		
	end,
	[keys.Right] = function()
		
		--KEY_HANDLER.hold()
		
		GLOBAL_STATE:change_state_to("RIGHT_BUTTONS")
		
	end,
	[keys.OK] = function()
        if vert_i == 1 then
			
			VIDEO:load(curr_focus)
			
			GLOBAL_STATE:change_state_to("VIDEO")
			
		elseif vert_i == 2 then
			
			KEY_HANDLER.hold()
			
			if Voted then
				
				MODAL_MENU:set_fields{
					title     = "Sorry, only 1 vote per day.",
					message   = "Please check back tomorrow.",
				}
				
			elseif not Registered then
				
				MODAL_MENU:set_fields{
					title     = "You must register first.",
					message   = "",
				}
				
			else
				
				MODAL_MENU:set_fields{
					title     = "Thank you for your vote.",
					message   = "Only 1 vote per day.",
				}
				
				Voted = true
				
			end
			GLOBAL_STATE:change_state_to("MODAL_MENU")
			
		else
			
			error("vert_i does not have an expected value")
			
		end
    end
}

KEY_HANDLER:add_keys("BOTTLES",keys_BOTTLES)
KEY_HANDLER:add_keys("LEFT_BUTTONS",keys_BUTTONS)


left_bar.w = masks[1].w*4/3

return left_bar