screen.size = { 960 , 540 }
screen:show_all()

math.randomseed(os.time())

local Settings = {
					BGROUND_IMAGE			= "grid.gif",
					JUMPER_IMAGE			= "jumper.png",
					GREEN_PLATFORM_IMAGE	= "platforms/green.png",
					
					SCORE_GAME_BG			= "6ABE2F40",
					SCORE_GAME_POS			= { 20, 20, 5 },
					SCORE_DEAD_BG			= "BE2F2F80",

					JUMP_TIME				=	500,
					JUMP_HEIGHT				=	screen.h/4,

					NUM_PLATFORMS			=	25,
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

					live = false,

					jumper = Image {
						src = Settings.JUMPER_IMAGE,
						size = { 60, 60 }
					},

					score = 0,
					connected_controllers = { _ = {}},
				}
-- Handle the jumper by his bottom-left corner (to align bottom with top of platforms more easily)
player.jumper:move_anchor_point( 0, player.jumper.h )

start_text = Text { font="Diavlo,DejaVu Sans,Sans 36px", text="Press ENTER to start", color="000000" }
start_text.x = (screen.w-start_text.w)/2
start_text.y = (screen.h-start_text.h)/2

screen:add(start_text)

dofile('placement.lua')

local score = Group { position = Settings.SCORE_GAME_POS }
local score_bg = Rectangle { color = Settings.SCORE_GAME_BG, position = { 0, 0, -1 } }
local score_label = Text { font="Diavlo,DejaVu Sans,Sans 24px", text="Score", color="000000", position = { 5, 5 } }
local score_text = Text { font="Diavlo,DejaVu Sans,Sans 24px", text=player.score, color="000000", position = { 5+score_label.size[1]+10, 5 } }
score_bg.h = 5+score_label.size[2]

score:add(score_bg)
score:add(score_label)
score:add(score_text)
screen:add(score)

function player.set_score( newscore )
	player.score = newscore
	score_text.text = newscore
	score_bg.w = 5+score_label.size[1]+10+score_text.size[1]+5
end


local platforms = Group {}
screen:add(platforms)

screen:add(player.jumper)

--[[
	Controller functions are defined separately -- the controller will affect the player's x-direction momentum
	in a way TBD by the capabilities of the controller device
]]--
dofile('controller.lua')

--[[
	Bouncing up launches us to go up to a maximum jump height off where we started
	over a period of time, on a quadratic curve, just like real gravity!
]]--
local bounce_up_timeline = Timeline { duration = Settings.JUMP_TIME }
local bounce_up_alpha = Alpha { timeline = bounce_up_timeline, mode = "EASE_OUT_QUAD" }
local bounce_up_interval = Interval ( 0, 0 ) -- The actual interval will be set when we start bouncing up based on location at that time
local spin = false
--[[
	We need to move according to gravity in the y-direction, but also respond to the player's momentum to move in the x-direction.
	This horizontal momentum will be controlled by the controller
]]--
function bounce_up_timeline.on_new_frame( t , msecs )
	-- The quadratic alpha simulates gravity quite nicely

	if player.jumper.y < screen.h/2 then
		-- We moved up!  Score!
		player.set_score(player.score +
						math.floor(player.jumper_delta + (player.jumper.y - bounce_up_interval:get_value( bounce_up_alpha.alpha ))*10)/10)

		-- If the player is at or above the half-way point on the screen on the way up, scroll all the platforms, and not the player!
		platforms:foreach_child(
									function (child)
										child.y = child.y - player.jumper_delta + (player.jumper.y - bounce_up_interval:get_value( bounce_up_alpha.alpha ))
									end
								)
		-- This delta tracks how far the player should have moved, so we can deal with that offset on the next frame
		player.jumper_delta = player.jumper.y - bounce_up_interval:get_value( bounce_up_alpha.alpha )
	else
		-- Otherwise, just move him up
		player.jumper.y = bounce_up_interval:get_value( bounce_up_alpha.alpha )
	end
	

	-- x movement is determined by momentum over time
	player.jumper.x = player.jumper.x + t.delta * player.horizontal_momentum/1000
	-- If you hit the edge of the screen, wrap around to the far side.
	if(player.jumper.x > screen.w) then
		player.jumper.x = (5-player.jumper.w)
	elseif player.jumper.x < (5-player.jumper.w) then
		player.jumper.x = screen.w
	end

	if spin then
		player.jumper.z_rotation = { -bounce_up_alpha.alpha * 360, player.jumper.w/2, -player.jumper.w/2 }
	end
end

--[[
	Once we complete out bounce up, we're going to start falling.
]]--
function bounce_up_timeline.on_completed( )
	fall_down()
end

function bounce_up()
	-- About 1/5 of the time, jumper will do a little summersault on the way up
	if math.random() < 0.2 then
		spin = true
	else
		spin = false
	end

	-- Set up the starting and ending y-position for the player on this upward bounce, re-using the existing Interval object
	bounce_up_interval.from, bounce_up_interval.to = player.jumper.y, player.jumper.y - Settings.JUMP_HEIGHT
	player.jumper_delta = 0

	bounce_up_timeline:rewind()
	bounce_up_timeline:start()
end

--[[
  Falling is aimed at the bottom of the screen, over a time period that depends on the height of the
  player at the start.  If we hit a platform on the way down, then we stop the fall.  If we hit the
  bottom of the screen, it's death.
]]--
local fall_timeline = Timeline { }
local fall_alpha = Alpha { timeline = fall_timeline, mode = "EASE_IN_QUAD" }
local fall_interval = Interval ( 0, 0 )
--[[
	We need to move according to gravity in the y-direction, but also respond to the player's momentum to move in the x-direction.
	This horizontal momentum will be controlled by the controller
]]--
function fall_timeline.on_new_frame( t , msecs )
	-- The quadratic alpha simulates gravity quite nicely
	local old_player_y = player.jumper.y
	player.jumper.y = fall_interval:get_value( fall_alpha.alpha )

	-- x movement is determined by momentum over time
	local old_player_x = player.jumper.x
	local theoretical_new_x = player.jumper.x + t.delta * player.horizontal_momentum/1000
	player.jumper.x = theoretical_new_x

	-- If you hit the edge of the screen, wrap around to the far side.
	if(player.jumper.x > screen.w) then
		player.jumper.x = (5-player.jumper.w)
	elseif player.jumper.x < (5-player.jumper.w) then
		player.jumper.x = screen.w
	end

	-- Check for each platform on the board if the line segment we just travelled intersects any platform
	local hit = false
	platforms:foreach_child(
								function (child)
									-- If we're not in the right y-ballpark then no hit
									if math.abs(child.y - player.jumper.y) > 10 then return end
									-- If the left side of the player is to the right of the right of the platform, then no hit
									if player.jumper.x > ( child.x + child.w ) then return end
									-- If the right side of the player is to the left of the left of the platform, then no hit
									if (player.jumper.x + player.jumper.w) < child.x then return end
									-- Otherwise we have a hit!
									hit = true
								end
							)

	if hit then
		-- We hit a platform, so stop falling, and start bouncing
		t:stop()
		bounce_up()
	end
	
	-- If we didn't hit a platform, just keep falling on the timeline
end

--[[
	If the falling loop completes, it's because we're dead.
]]--
function fall_timeline.on_completed( t )
	t:stop()
	print('AIYEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE!')
	player.connected_controllers:death_splat()

	player.jumper:animate({
							duration = 100,
							mode = "EASE_OUT_BACK",
							scale = { 3, 3 },
							opacity = 0,
							on_completed = function () screen:add(start_text) end,
						})
	score:animate({
					duration = 500,
					mode = 'EASE_OUT_SINE',
					x = (screen.w-score_bg.w)/2,
					y = screen.h/2 - 80,
 					scale = { 1.5, 1.5 },
				})
	score_bg.color = Settings.SCORE_DEAD_BG
	player.live = false
end


function fall_down()
	fall_timeline.duration = Settings.JUMP_TIME
	fall_interval.from, fall_interval.to = player.jumper.y, screen.h

	fall_timeline:rewind()
	fall_timeline:start()

	platform_cleanup()

end


function platform_cleanup()
	local platforms_to_clean = {}
	platforms:foreach_child(
								function(child)
									if child.y > screen.h + 10 then
										table.insert(platforms_to_clean,child)
										place_new_platform(platforms, green_platform, Settings.JUMP_HEIGHT)
									end
								end
							)

	for i,v in ipairs(platforms_to_clean) do
		v:unparent()
	end
end

function player.reset()

	start_text:unparent()

	platforms:clear()
	platforms.opacity = 255

	player.set_score(0)
	player.horizontal_momentum = 0

	-- We need to place the first platform under the player's start location so he doesn't instantly die
	local start_platform = Clone { source = green_platform }
	start_platform.position = { screen.w/2, 5 * screen.h / 6 }
	platforms:add(start_platform)

	player.connected_controllers:game_on()

	-- Set the scale center to the bottom center point (relative to anchor point)
	score.scale = { 1, 1, score.w/2, score.h }
	score.position = Settings.SCORE_GAME_POS
	score_bg.color = Settings.SCORE_GAME_BG

	player.jumper.scale = { 1, 1, player.jumper.w/2, 0 }
	player.jumper.position =	{
									start_platform.x + (start_platform.w - player.jumper.w)/2,
									start_platform.y
								}
	player.jumper.opacity = 255


	-- Initially place platforms randomly on screen
	for i = 1,Settings.NUM_PLATFORMS do
		place_new_platform(platforms, green_platform, Settings.JUMP_HEIGHT)
	end


	bounce_up()
end

