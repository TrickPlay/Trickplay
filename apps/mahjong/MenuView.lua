MenuView = Class(View, function(view, model, ...)
    view._base.init(view,model)

------------ Load Assets ------------

    local menu_bars = {
    }

    --
    view.items = {}

    -- score related stuff
    local time_text = game_timer.text
    local score_text = Text{
        text="Score: 0",
        position = {1145, 301},
        font = MENU_FONT_BOLD,
        color = Colors.WHITE,
    }
    score_text.extra.score = 0
    local moves_text = Text{
        text="0 Moves",
        position = {1390, 301},
        font = MENU_FONT_BOLD,
        color = Colors.WHITE
    }
    moves_text.extra.moves = 0

    -- menu ui
    local menu_open_x = 0
    local menu_closed_x = -265
    local menu_hiden_x = -385
    view.menu_ui = Group{name = "menu_ui", position = {0, menu_closed_x}}
    view.menu_ui:add(unpack(menu_bars))
    view.menu_ui:add(unpack(view.items))

    -- all ui junk for this view
    view.ui=Group{name="start_menu_ui", position={0,0}}
    view.ui:add(view.menu_ui)

    screen:add(view.ui)

--------- Variables ----------------------


    view.auto_hide_menu = false


--------- Getters/Setters ----------------


    --[[
        Retrieves a focusable item. Controller uses this (for controlling).
    --]]
    function view:get_object(hash_key)
        return focusable_items[hash_key]
    end
    
    --[[
        global setters
    --]]
    function set_moves(moves)
        moves_text.extra.moves = moves
        moves_text.text = moves_text.extra.moves.." Moves"
    end
    function increase_moves()
        moves_text.extra.moves = moves_text.extra.moves + 1
        moves_text.text = moves_text.extra.moves.." Moves"
    end
    function set_score(score)
        score_text.extra.score = score
        score_text.text = "Score: "..score
    end
    function increase_score()
        score_text.extra.score = score_text.extra.score + 100
        score_text.text = "Score: "..score_text.extra.score
    end

    --[[
        global getters
    --]]
    function get_score() return score_text.extra.score end


---------- View Mutators ----------------------------


    function change_theme(number)
        assert(number > 0 and number <= 3, "number must be between 0 and 3")
        -- buttons

        -- menu bar
        for i,v in ipairs(menu_bars) do
            if i == number then menu_bars[i].opacity = 255
            else menu_bars[i].opacity = 0
            end
        end

    end

    function view:change_auto_hide()
        view.auto_hide_menu = not view.auto_hide_menu

        if view.auto_hide_menu then checkmarks.auto_hide.opacity = 255
        else checkmarks.auto_hide.opacity = 0
        end
    end


---------- Main View Functionality -------------------

    -- initialize the View/Controller pair
    function view:initialize()
        self:set_controller(MenuController(self))
    end

    -- reset the View/Controller pair
    function view:reset()
        set_score(0)
        set_moves(0)
    end

    function view:move_focus()
        local selected_object = self.controller:get_selection().object
        local prev_selected_object = self.controller:get_prev_selection().object
        assert(selected_object)
        if prev_selected_object.off_focus then prev_selected_object:off_focus() end
        if selected_object.on_focus then selected_object:on_focus() end
    end

    function view:hide_menu_completely()
        if view.menu_ui.y == menu_hiden_y then return end

        local intervals = {["y"] = Interval(view.menu_ui.y, menu_hiden_y)}
        gameloop:add(view.menu_ui, CHANGE_VIEW_TIME, nil, intervals)
    end

    function view:update(event)
        if not event:is_a(NotifyEvent) then return end

        local controller = self:get_controller()
        local comp = self.router:get_active_component()
        local selected_object = controller:get_selection().object

        if controller:is_options_hidden() then
            options_text.text = "Show Options"
        else
            options_text.text = "Hide Options"
        end

        -- hide focus if not the active component
        if controller:is_active_component() then
            if selected_object.on_focus then selected_object:on_focus() end
        else
            if selected_object.off_focus then selected_object:off_focus() end
        end

        if comp ~= Components.MENU then
            if view.auto_hide_menu then view:hide_menu_completely()
            elseif view.menu_ui.y ~= menu_closed_y then
                local intervals = {["x"] = Interval(view.menu_ui.x, menu_closed_x)}
                gameloop:add(view.menu_ui, CHANGE_VIEW_TIME, nil, intervals)
            end
        else
            if controller:is_options_hidden() and view.menu_ui.x ~= menu_closed_x then
                local intervals = {["x"] = Interval(view.menu_ui.x, menu_closed_x)}
                gameloop:add(view.menu_ui, CHANGE_VIEW_TIME, nil, intervals)
            elseif not controller:is_options_hidden() and view.menu_ui.x ~= menu_open_x then
                local intervals = {["x"] = Interval(view.menu_ui.x, menu_open_x)}
                gameloop:add(view.menu_ui, CHANGE_VIEW_TIME, nil, intervals)
            end
        end
    end

end)
