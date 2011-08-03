local init_dist  = 100
local digit_dist = 72

local coin  = Clone{
	source  = assets.coin_symbol,
	x       = screen_w - assets.coin_symbol.w - 20,
	y       = screen_h - assets.coin_symbol.h - 20,
	opacity = 0,
}

coin:move_anchor_point(
	coin.w/2,
	coin.h/2
)

local score = 0
local nums = {
}

local add_a_digit = function()
	
	nums[#nums+1] = {
		
		value = 0,
		
		text = Clone{
			name         = "Digit " .. ( # nums + 1 ),
			source       = assets.num[0],
			x            = coin.x - init_dist - digit_dist * ( # nums ),
			y            = coin.y,
			anchor_point = {
				assets.num[0].w/2,
				assets.num[0].h/2
			},
		}
		
	}
	
	layers.hud:add( nums[ # nums ].text )
	
end

local i = 1
local val
local hud = {
	
	add_to_score = function(_,amt)
		
		score = score + amt
		
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
				
				nums[i].text.source = assets.num[nums[i].value]
				
				nums[i].text.anchor_point = {
					nums[i].text.w/2,
					nums[i].text.h/2
				}
			else
				
				amt = 0
				
				nums[i].text.source = assets.num[nums[i].value]
				
			end
			--print(i,nums[i].value,amt,"\n" )
			i = i + 1
		end
		
	end,
	
	reset = function()
		
		score = 0
		
		if #nums == 0 then
			add_a_digit()
			return
		end
		
		for i,n in ipairs(nums) do
			
			n.value = 0
			
			if i == 1 then
				n.text.source = assets.num[0]
			else
				n.text:hide()
			end
		end
		
	end,
	
	get_score = function()
		
		return score
		
	end
}

GameState:add_state_change_function(
	hud.reset,
	nil,"GAME"
)
GameState:add_state_change_function(
	function()
		coin:animate{
			duration = 300,
			opacity  = 255,
		}
	end,
	"SPLASH","GAME"
)
layers.hud:add(coin)

return hud