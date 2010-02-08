screen.size = { 960 , 540 }
screen:show_all()

math.randomseed(os.time())

Timer{ interval = 2 , on_timer = function() collectgarbage() end }

local Settings = {
					BGROUND_IMAGE			= "grid.gif",
					JUMPER_IMAGE			= "jumper.png",
					GREEN_PLATFORM_IMAGE	= "platforms/green.png",

					JUMP_TIME				=	300,
					JUMP_HEIGHT				=	screen.h/5,
				}

local bground = Image {
				src = Settings.BGROUND_IMAGE,
				tile = {true, true},
				size = { screen.w, screen.h },
}

local green_platform = Image {
						src = Settings.GREEN_PLATFORM_IMAGE,
						keep_aspect_ratio = true,
						width = 100,
						position = {-100, -100 },
					}

screen:add(bground)
screen:add(green_platform)

player =	{
					-- Horizontal momentum is measured in pixels per second
					horizontal_momentum = 0,

					jumper = Image {
						src = Settings.JUMPER_IMAGE,
						size = { 60, 60 }
					},

					score = 0,
				}
-- Handle the jumper by his bottom-left corner (to align bottom with top of platforms more easily)
player.jumper:move_anchor_point( 0, player.jumper.h )

dofile('placement.lua')

local platforms = Group {}

-- We need to place the first platform under the player's start location so he doesn't instantly die
local start_platform = Clone { source = green_platform }
start_platform.position = { screen.w/2, 5 * screen.h / 6 }
platforms:add(start_platform)

screen:add(platforms)


-- Initially place 10 platforms randomly on screen
for i = 1,10 do
	place_new_platform(platforms, green_platform, Settings.JUMP_HEIGHT)
end

player.jumper.position =	{
								start_platform.x + (start_platform.w - player.jumper.w)/2,
								start_platform.y
							}

screen:add(player.jumper)


local spin = false

local bounce_up_timeline = Timeline { duration = Settings.JUMP_TIME }
local bounce_up_interval = Interval ( player.jumper.y, player.jumper.y - Settings.JUMP_HEIGHT )
local bounce_up_alpha = Alpha { timeline = bounce_up_timeline, mode = "EASE_OUT_QUAD" }

function bounce_up_timeline.on_new_frame( t , msecs )
    player.jumper.y = bounce_up_interval:get_value( bounce_up_alpha.alpha )

    player.jumper.x = player.jumper.x + t.delta * player.horizontal_momentum/1000
    if(player.jumper.x > screen.w) then
    	player.jumper.x = 0
    elseif player.jumper.x < 0 then
    	player.jumper.x = screen.w
    end

    if spin then
    	player.jumper.z_rotation = { -bounce_up_alpha.alpha * 360, player.jumper.w/2, -player.jumper.w/2 }
    end
end

function bounce_up_timeline.on_completed( )
	bounce_up_timeline:reverse()
	if bounce_up_timeline.direction == "FORWARD" then
		if math.random() < 0.2 then
			spin = true
		else
			spin = false
		end
	else
		spin = false
	end
	bounce_up_timeline:start()
end

bounce_up_timeline:start()

dofile('controller.lua')
