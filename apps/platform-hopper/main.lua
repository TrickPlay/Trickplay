screen:show_all()

math.randomseed(os.time())

local Settings = {
					BGROUND_MOVIE			= "assets/clouds-loop.mp4",
					JUMPER_IMAGE			= "assets/goat-medium.png",
					GREEN_PLATFORM_IMAGE	= "assets/platform-rock-medium.png",
					
					SCORE_GAME_BG			= "6ABE2F40",
					SCORE_GAME_POS			= { screen.w/20, screen.h/20, 5 },
					SCORE_DEAD_BG			= "BE2F2F80",

					JUMP_IMPULSE			=	150,

					NUM_PLATFORMS			=	25,
				}

physics.gravity = { 0, 100 }

mediaplayer.on_loaded = function( self ) self:play() end
mediaplayer.on_end_of_stream = function ( self ) self:seek(0) self:play() end
mediaplayer:load(Settings.BGROUND_MOVIE)

local green_platform = Image {
						src = Settings.GREEN_PLATFORM_IMAGE,
						keep_aspect_ratio = true,
						position = {-100, -100 },
					}

screen:add(green_platform)

player =	{
					live = false,

					jumper = Image {
						src = Settings.JUMPER_IMAGE,
					},
					
					physics = nil,

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

local sw = Stopwatch()
local spf = 1 / 60

local function idle_bouncer()

    if sw.elapsed_seconds < spf then return end

    physics:step()
    sw:start()

    local lin_velocity = player.physics.linear_velocity

    if(lin_velocity[2] == 0) then 
        player.physics:apply_linear_impulse( 0 , -Settings.JUMP_IMPULSE , player.jumper.x , player.jumper.y )
    end
    if ( player.jumper.x < 0 ) then
        print("Wrapping negative")
        player.jumper.x = screen.w
        -- Now restart the physics to get it in the correct position; this is a hack
        player.physics = physics:Body{
                                source = player.jumper,
                                dynamic = true,
                                density = 1,
                                friction = 0.1,
                                bounce = 0,
                                active = true,
                                awake = true,
                            }
        player.physics.fixed_rotation = true
        player.linear_velocity = lin_velocity,

        dumptable(player.jumper.position)
        dumptable(player.physics.position)
    elseif ( player.jumper.x > screen.w ) then
        print("Wrapping positive")
        player.jumper.x = 0
        -- Now restart the physics to get it in the correct position; this is a hack
        player.physics = physics:Body{
                                source = player.jumper,
                                dynamic = true,
                                density = 1,
                                friction = 0.1,
                                bounce = 0,
                                active = true,
                                awake = true,
                            }
        player.physics.fixed_rotation = true
        player.linear_velocity = lin_velocity,


        dumptable(player.jumper.position)
        dumptable(player.physics.position)
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
	physics:Body{
	                source = start_platform,
	                dynamic = false,
	                active = true,
	                bounce = 0.0,
	                friction = 1.0,
	                density = 1.0,
	                awake = false,
	                sleeping_allowed = true,
                }

	player.connected_controllers:game_on()

	-- Set the scale center to the bottom center point (relative to anchor point)
	score.scale = { 1, 1, score.w/2, score.h }
	score.position = Settings.SCORE_GAME_POS
	score_bg.color = Settings.SCORE_GAME_BG

	player.jumper.scale = { 1, 1, player.jumper.w/2, 0 }
	player.jumper.position =	{
									start_platform.x + (start_platform.w - player.jumper.w)/2 - 40,
									start_platform.y - 200
								}
    player.physics = physics:Body{
                                    source = player.jumper,
                                    dynamic = true,
                                    density = 1,
                                    friction = 0.1,
                                    bounce = 0,
                                    active = true,
                                    awake = true,
                	                fixed_rotation = true,
                        }
    player.physics.fixed_rotation = true
	player.jumper.opacity = 255


	-- Initially place platforms randomly on screen
	for i = 1,Settings.NUM_PLATFORMS do
		place_new_platform(platforms, green_platform, 100)
	end

    idle.on_idle = idle_bouncer

end
