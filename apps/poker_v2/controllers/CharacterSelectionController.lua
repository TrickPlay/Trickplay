CharacterSelectionController = Class(Controller,
function(ctrl, router, ...)
    ctrl._base.init(ctrl, router, Components.CHARACTER_SELECTION)
    router:attach(ctrl, Components.CHARACTER_SELECTION)

    local view = CharacterSelectionView(ctrl)
    local players = {}
    local dog_selectors = {}
    local button_selectors

--------------- Some helper variables --------------

    ctrl.number_of_players = 0

--------------- Private methods ------------------

    local function start_a_game()
        ctrl:reset()
        for i,dog_selector in ipairs(dog_selectors) do
            dog_selector.dog_view:glow_off()
        end
        router:set_active_component(Components.GAME)
        game:initialize_game{
            sb = SMALL_BLIND,
            bb = BIG_BLIND,
            randomness = RANDOMNESS,
            players = players
        }
        router:notify()
    end

    local function set_up_player(dog_number, human, controller)
        if players[dog_number] then return end
        ctrl.number_of_players = ctrl.number_of_players + 1

        local is_human = human or false
        if ctrl.number_of_players == 1 then
            is_human = true
            mediaplayer:play_sound(FIRST_PLAYER_MP3)
        end

        local args = {
            is_human = is_human,
            player_number = ctrl.number_of_players,
            dog_number = dog_number,
            endowment = INITIAL_ENDOWMENT,
            controller = controller,
            dog_view = dog_selectors[dog_number].dog_view
        }

        local player = Player(args)
        if controller then controller.player = player end
        players[dog_number] = player

        if ctrl.number_of_players >= 2 then
            ctrl:display_start_button()
        end
        if ctrl.number_of_players >= 6 then
            start_a_game()
        end
    end

--------------- Here lies the model for the ui ------------------
    
    local help_button_selector = {
        object = ButtonView("help_button", HELP_MENU_POSITION[1],
                            HELP_MENU_POSITION[2])
    }
    local start_button_selector = {
        object = ButtonView("start_button", START_MENU_POSITION[1],
                            START_MENU_POSITION[2])
    }
    start_button_selector.object:hide()
    local exit_button_selector = {
        object = ButtonView("exit_button", EXIT_MENU_POSITION[1],
                            EXIT_MENU_POSITION[2])
    }
    button_selectors = {
        help_button_selector, start_button_selector, exit_button_selector
    }
    for i,selector in ipairs(button_selectors) do
        view:add(selector.object.view)
        selector.on_focus = function()
            selector.object:on_focus()
        end
        selector.off_focus = function()
            selector.object:off_focus()
        end
    end

    help_button_selector.press = function()
        router:set_active_component(Components.TUTORIAL)
        router:notify()
    end
    start_button_selector.press = function()
        start_a_game()
    end
    exit_button_selector.press = function()
        exit()
    end

    for i = 1,6 do
        dog_selectors[i] = {}
        dog_selectors[i].dog_view = DogView(i)
        dog_selectors[i].seat_button_view = SeatButtonView(i)
        dog_selectors[i].press = function()
            dog_selectors[i].dog_view:pressed()
            dog_selectors[i].seat_button_view:pressed()

            set_up_player(i)
        end
        dog_selectors[i].on_focus = function()
            dog_selectors[i].dog_view:on_focus()
            dog_selectors[i].seat_button_view:on_focus()
        end
        dog_selectors[i].off_focus = function()
            dog_selectors[i].dog_view:off_focus()
            dog_selectors[i].seat_button_view:off_focus()
        end
        screen:add(dog_selectors[i].dog_view.view)
        view:add(dog_selectors[i].seat_button_view.view)
    end

    dog_selectors[1][Directions.UP] = dog_selectors[2]
    dog_selectors[1][Directions.RIGHT] = help_button_selector

    dog_selectors[2][Directions.DOWN] = dog_selectors[1]
    dog_selectors[2][Directions.RIGHT] = dog_selectors[3]
    
    dog_selectors[3][Directions.RIGHT] = dog_selectors[4]
    dog_selectors[3][Directions.LEFT] = dog_selectors[2]
    dog_selectors[3][Directions.DOWN] = help_button_selector

    dog_selectors[4][Directions.LEFT] = dog_selectors[3]
    dog_selectors[4][Directions.RIGHT] = dog_selectors[5]
    dog_selectors[4][Directions.DOWN] = exit_button_selector

    dog_selectors[5][Directions.LEFT] = dog_selectors[4]
    dog_selectors[5][Directions.DOWN] = dog_selectors[6]

    dog_selectors[6][Directions.UP] = dog_selectors[5]
    dog_selectors[6][Directions.LEFT] = exit_button_selector

    help_button_selector[Directions.LEFT] = dog_selectors[1]
    help_button_selector[Directions.UP] = dog_selectors[3]
    help_button_selector[Directions.RIGHT] = exit_button_selector

    exit_button_selector[Directions.RIGHT] = dog_selectors[6]
    exit_button_selector[Directions.UP] = dog_selectors[4]
    exit_button_selector[Directions.LEFT] = help_button_selector

    start_button_selector[Directions.RIGHT] = exit_button_selector
    start_button_selector[Directions.UP] = dog_selectors[4]
    start_button_selector[Directions.LEFT] = help_button_selector

------------------- Here lies the controls -----------------

    function ctrl:display_start_button()
        help_button_selector[Directions.RIGHT] = start_button_selector
        exit_button_selector[Directions.LEFT] = start_button_selector

        start_button_selector.object:show()
    end

    function ctrl:hide_start_button()
        help_button_selector[Directions.RIGHT] = exit_button_selector
        exit_button_selector[Directions.LEFT] = help_button_selector

        start_button_selector.object:hide()
    end

    local current_selector = dog_selectors[1]
    current_selector:on_focus()


    function ctrl:move(dir)
        if current_selector[dir] then
            current_selector:off_focus()
            current_selector = current_selector[dir]
            current_selector:on_focus()
            view:update()
        end
    end

    function ctrl:return_pressed()
        current_selector.press()
    end

    -- Update all the views
    function ctrl:notify(event)
        if self:is_active_component() then
            for i,selector in ipairs(button_selectors) do
                if current_selector ~= selector then
                    selector:off_focus()
                else
                    selector:on_focus()
                end
            end
            for i,selector in ipairs(dog_selectors) do
                if current_selector ~= selector then
                    selector:off_focus()
                else
                    selector:on_focus()
                end
            end
        end

        view:update()
    end

    function ctrl:reset()
        self:hide_start_button()
    end

end)
