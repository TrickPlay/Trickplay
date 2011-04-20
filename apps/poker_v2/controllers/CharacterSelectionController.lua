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
    local current_selector

--------------- Public methods ------------------

    function ctrl:get_players() return players end

--------------- Private methods ------------------

    local function start_a_game()
        ctrl:hide_start_button()
        for i,dog_selector in ipairs(dog_selectors) do
            dog_selector.dog_view:glow_off()
            if not players[i] then
                dog_selector.dog_view:fade_out()
            end
        end
        router:set_active_component(Components.GAME)
        local temp_table = {}
        for i = 1,6 do
            if players[i] then
                table.insert(temp_table, players[i])
            end
        end
        players = temp_table
        for i,player in ipairs(players) do
            player.players = players
        end

        game:initialize_game{
            sb = SMALL_BLIND,
            bb = BIG_BLIND,
            randomness = RANDOMNESS,
            players = players
        }
        router:notify()
    end

    local function correct_selector(dog_number)
        current_selector:off_focus()
        current_selector = dog_selectors[dog_number]
        current_selector:on_focus()
        view:update()
    end

    local function find_next_dog(dog_number)
        while players[dog_number] do
            dog_number = dog_number + 1
        end
        if dog_number > 6 then
            dog_number = 1
        end
        while players[dog_number] do
            dog_number = dog_number + 1
        end
        correct_selector(dog_number)
    end

    local function set_up_player(dog_number, human, controller)
        if not dog_number then error("no dog_number", 2) end
        if players[dog_number] then return false end
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

        local player = Player(players, args)
        if controller then controller.player = player end
        players[dog_number] = player

        if ctrl.number_of_players >= 2 then
            ctrl:display_start_button()
        end
        if ctrl.number_of_players >= 6 then
            start_a_game()
        else
            find_next_dog(dog_number)
        end

        return true
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

    current_selector = dog_selectors[1]
    current_selector:on_focus()


    function ctrl:move(dir)
        if current_selector[dir] then
            current_selector:off_focus()
            current_selector = current_selector[dir]
            current_selector:on_focus()
            view:update()
            mediaplayer:play_sound(ARROW_MP3)
        else
            mediaplayer:play_sound(BONK_MP3)
        end
    end

    function ctrl:return_pressed()
        mediaplayer:play_sound(ENTER_MP3)
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
        for k,player in pairs(players) do
            player:dealloc()
        end
        players = {}
        self:hide_start_button()
        ctrl.number_of_players = 0
        for i,dog_selector in ipairs(dog_selectors) do
            dog_selector.dog_view:reset()
            dog_selector.seat_button_view:reset()
        end
        current_selector = dog_selectors[1]

        ctrlman:choose_dog(players)
    end

    function ctrl:add_controller(controller)
        controller:choose_dog(players)
    end

    function ctrl:handle_click(controller, x, y)
        assert(controller)
        assert(x)
        assert(y)

        if controller.state == ControllerStates.CHOOSE_DOG then
            -- based off of click position grab the correct dog position (pos)
            local pos
            local col = 1
            local row = 1
            if x > controller.ui_size[1]/2 then
                col = 2
            end
            if y > (100+256)*controller.y_ratio then
                row = 2
                if y > (100+256*2)*controller.y_ratio then
                    row = 3
                end
            end
            pos = row*col
            if row == 2 and col == 1 then pos = 3 end
            if row == 3 and col == 1 then pos = 5 end

            correct_selector(pos)

            -- maybe being too redundant, but seems like the safest approach
            current_selector.dog_view:pressed()
            current_selector.seat_button_view:pressed()
            if not set_up_player(pos, true, controller) then return end
            controller:name_dog(pos)
            ctrlman:update_choose_dog(players)
        elseif controller.state == ControllerStates.WAITING then
            local pos = math.floor((y/controller.y_ratio-86)/115+1)
            -- AI selected
            if pos > 0 and pos <= 6 then
                correct_selector(pos)
                self:return_pressed()
                ctrlman:update_waiting_room(players)
            -- check x range for "Start" button press
            elseif pos > 6 and x/controller.x_ratio > 640/3
            and x/controller.x_ratio < 2*640/3 then
                if ctrl.number_of_players >= 2 then
                    start_a_game()
                end
            end
        end
    end

end)
