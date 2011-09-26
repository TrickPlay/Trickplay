local init_dist  = 100
local digit_dist = 60
local h_digit_dist = 40

local yellow_digits = {}
local green_digits  = {}

for i = 0,9 do
	yellow_digits[i] = make_text(
		Text{
			font = "Sigmar 80px",
			text = i,
		},
		"yellow"
	)
	green_digits[i]  = make_text(
		Text{
			font = "Sigmar 50px",
			text = i,
		},
		"green"
	)
end

layers.clone_srcs:add(yellow_digits[0],green_digits[0])

layers.clone_srcs:add(unpack(yellow_digits))
layers.clone_srcs:add(unpack( green_digits))

local coin  = Clone{
	source  = assets.coin_symbol,
	x       = screen_w - assets.coin_symbol.w - 20,
	y       = screen_h - assets.coin_symbol.h - 20,
}

local h_h = 1030
local height = make_text(
	Text{
		font = "Sigmar 50px",
		text = "Height:",
		y    = h_h,
	},
	"green"
)
height.x = height.w/2
local height_g       = Group{
	x    = height.x + height.w/2 + 10,
	y    = h_h+10
}
--[[
local multiplier_g   = Group{
	x    = height.x + height.w/2 + 35,
	y    = h_h,
	opacity = 0,
}
local multiplier_txt = make_text(
	Text{
		font = "Sigmar 50px",
		text = "(   x)",
		
	},
	"green"
)
multiplier_txt.x = multiplier_txt.w/2
local multiplier_value = Clone{
	--name         = "Digit " .. ( # nums + 1 ),
	source       = green_digits[1],
	scale        = {4/7,4/7},
	--x            = coin.x - init_dist - digit_dist * ( # nums ),
	x            = 50,
	y            = 7,
	anchor_point = {
		green_digits[1].w/2,
		green_digits[1].h/2
	},
}
--multiplier_value.x = 5
multiplier_g:add(multiplier_txt,multiplier_value)
--]]

layers.hud:add(height,height_g)--,multiplier_g)

coin:move_anchor_point(
	coin.w/2,
	coin.h/2
)
local dist = 0
--local multiplier = 1
local score = 0
local score_nums = {}
local dist_nums  = {}

local add_score_digit = function()
	
	score_nums[#score_nums+1] = {
		
		value = 0,
		
		text = Clone{
			name         = "Digit " .. ( # score_nums + 1 ),
			source       = yellow_digits[0],
			x            = coin.x - init_dist - digit_dist * ( # score_nums ),
			y            = coin.y,
			anchor_point = {
				yellow_digits[0].w/2,
				yellow_digits[0].h/2
			},
		},
	}
	
	layers.hud:add( score_nums[ # score_nums ].text )
	--print(yellow_digits[0])
end

local add_h_digit = function()
	
	dist_nums[#dist_nums+1] = {
		
		value = 0,
		
		text = Clone{
			name         = "Digit " .. ( # dist_nums + 1 ),
			source       = green_digits[0],
			x            = - h_digit_dist * ( # dist_nums ),
			--y            = coin.y,
			anchor_point = {
				green_digits[0].w/2,
				green_digits[0].h/2
			},
		},
	}
	
	height_g:add( dist_nums[ # dist_nums ].text )
	dist_nums[ # dist_nums ].text:lower_to_bottom()
	height_g.x     =     height_g.x + h_digit_dist
	--multiplier_g.x = multiplier_g.x + h_digit_dist
end

local i = 1
local val


local function add_to(nums,amt,digits,add_a_digit)
	i = 1
	
	while amt > 0 do
		
		if nums[i] == nil then
			
			add_a_digit()
			
		elseif not nums[i].text.is_visible then
			
			nums[i].text:show()
			
		end
		
		--print(i,nums[i].value,amt )
		nums[i].value = nums[i].value + amt
		
		if nums[i].value > 9 then
			
			amt = math.floor(nums[i].value/10)
			
			nums[i].value = nums[i].value%10
			
			nums[i].text.source = digits[nums[i].value]
			
		else
			
			amt = 0
			
			nums[i].text.source = digits[nums[i].value]
			
		end
		
		
		if nums[i].value == 1 then
			nums[i].text.anchor_point = {
				nums[i].text.w/2,
				nums[i].text.h/2
			}
		else
			nums[i].text.anchor_point = {
				nums[i].text.w/2,
				nums[i].text.h/2
			}
		end
		
		--print(i,nums[i].value,amt,"\n" )
		i = i + 1
	end
end
--[[
local multiplier_index = 1
local multiplier_thresholds = {
	{dist = 1000, multiplier = 2},
	{dist = 2000, multiplier = 3}
}
--]]
local hud = {
	
	add_to_dist = function(_,amt)
		
		dist = dist + amt
		--[[
		if multiplier_index <= # multiplier_thresholds and
			multiplier_thresholds[multiplier_index].dist < dist then
			print("seety")
			multiplier = multiplier_thresholds[multiplier_index].multiplier
			multiplier_value.source = yellow_digits[multiplier]
			multiplier_value.anchor_point = {
				multiplier_value.w/2,
				multiplier_value.h/2
			}
			multiplier_g.opacity = 255
			multiplier_index = multiplier_index + 1
		end
		--]]
		add_to(dist_nums,amt,green_digits,add_h_digit)
		
	end,
	add_to_score = function(_,amt)
		
		--amt = amt*multiplier
		
		score = score + amt
		
		add_to(score_nums,amt,yellow_digits,add_score_digit)
		
	end,
	
	reset = function()
		--multiplier_index = 1
		--multiplier = 1
		dist  = 0
		score = 0
		
		if #score_nums == 0 then
			add_score_digit(score_nums,yellow_digits)
			
		else
			
			for i,n in ipairs(score_nums) do
				
				n.value = 0
				
				if i == 1 then
					n.text.source = yellow_digits[0]
					n.text.anchor_point = {
						n.text.w/2,
						n.text.h/2
					}
				else
					n.text:hide()
				end
			end
		end
		
		for i,n in ipairs(dist_nums) do
			n.text:unparent()
		end
		dist_nums = {}
		height_g.x     = height.x + height.w/2 + 10
		--multiplier_g.x = height.x + height.w/2 + 35
		add_h_digit(score_nums,yellow_digits)
		--[[
		multiplier_g.opacity = 0
		multiplier_value.source = yellow_digits[1]
		multiplier_value.anchor_point = {
			multiplier_value.w/2,
			multiplier_value.h/2
		}
		--]]
	end,
	
	get_score = function()
		
		return score+dist
		
	end
}

GameState:add_state_change_function(
	hud.reset,
	nil,"GAME"
)
layers.hud.opacity = 0
GameState:add_state_change_function(
	function()
		if layers.hud.opacity == 0 then
			layers.hud:animate{
				duration = 300,
				opacity  = 255,
			}
		end
	end,
	nil,"GAME"
)
layers.hud:add(coin)

return hud