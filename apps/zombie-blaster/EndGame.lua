EndGame = Class(Controller,
function(end_game, router, distance, max_height, ...)
    end_game._base.init(end_game, router, Components.GAME_OVER)
    router:attach(end_game, Components.GAME_OVER)

    local id = Components.GAME_OVER

    enable_kbd()

    local blasted_image = Image{
        src = "assets/end_screen/you-blasted-the-zombie.png",
        position = {367, 165}
    }

    local blast_button = FocusableImage(530, 653,
        "assets/end_screen/btn-again-off.png", "assets/end_screen/btn-again-on.png")
    local exit_button = FocusableImage(962, 653,
        "assets/end_screen/btn-exit-off.png", "assets/end_screen/btn-exit-on.png")

    local distance_text = Text{
        text = string.format("%.2f", distance).." ft distance, soaring to "..string.format("%.2f", max_height).." ft",
        position = {screen.w/2, screen.h/2-60},
        font = END_GAME_FONT, 
        color = Colors.WHITE
    }
    distance_text.anchor_point = {distance_text.w/2, distance_text.h/2}

    screen:add(blasted_image, blast_button.group, exit_button.group, distance_text)
    
    local Exit = {}
    local Blast = {}

    Blast[Directions.RIGHT] = Exit
    Blast[Directions.LEFT] = Exit
    Blast.object = blast_button
    Blast.execute = function()
        mediaplayer:play_sound(
        "assets/audio/ZombieHit"..tostring(math.random(3))..".mp3")
        router:set_active_component(Components.GAME)
        router:delegate(ResetEvent())
    end

    Exit[Directions.RIGHT] = Blast
    Exit[Directions.LEFT]  = Blast
    Exit.object = exit_button
    Exit.execute = function() exit() end

    local selector = Blast
    Blast.object:on_focus_inst()

    function end_game:move(dir)
        if selector[dir] then
            selector.object:off_focus()
            selector = selector[dir]
            selector.object:on_focus()
            local file = math.random(TOTAL_AUDIO_FILES)
            game:get_audio_manager():play_file(
                AudioFilesByNumber[file], AudioLengthsByNumber[file]
            )
        end
    end

    function end_game:return_pressed()
        selector:execute()
    end

    function end_game:delete()
        router:detach(end_game, Components.GAME_OVER)
        screen:remove(
            blasted_image, blast_button.group,
            exit_button.group, distance_text
        )
    end

    function end_game:update(event)
        assert(event:is_a(Event))
        if event:is_a(KbdEvent) then
            end_game:on_key_down(event.key)
        elseif event:is_a(ResetEvent) then
            end_game:delete()
        end
    end

end)
