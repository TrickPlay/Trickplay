MenuController = Class(Controller,function(self, view, ...)
    self._base.init(self, view:get_router(), Components.MENU)

    local controller = self
    router = view:get_router()

    -- determines whether or not to hide the options menu
    local hide_options = true

    -- Create the tables used as nodes in the menu graph
    local New_Game = {}
    local Undo = {}
    local Shuffle = {}
    local Hint = {}
    local Help = {}
    local Show_Options = {}
    local Exit = {}

    -- create the graph
    New_Game[Directions.DOWN] = Undo
    New_Game.object = view:get_object("new_game")
    New_Game.callback = 
        function()
            game:reset_game()
        end

    Undo[Directions.UP] = New_Game
    Undo[Directions.DOWN] = Shuffle
    Undo.object = view:get_object("undo")
    Undo.callback = 
        function()
            game:undo_move()
        end

    Shuffle[Directions.UP] = Undo
    Shuffle[Directions.DOWN] = Hint
    Shuffle.object = view:get_object("shuffle")
    Shuffle.callback = 
        function()
            game:shuffle_game()
        end

    Hint[Directions.UP] = Shuffle
    Hint[Directions.DOWN] = Help
    Hint.object = view:get_object("hint")
    Hint.callback =
        function()
            game:get_state():hint()
        end

    Help[Directions.UP] = Hint
    Help[Directions.DOWN] = Show_Options
    Help.object = view:get_object("help")
    Help.callback = 
        function()
        end

    Show_Options[Directions.UP] = Help
    Show_Options[Directions.DOWN] = Exit
    Show_Options.object = view:get_object("show_options")
    Show_Options.callback =
        function()
            hide_options = not hide_options
            view:update(NotifyEvent())
        end

    Exit[Directions.UP] = Show_Options
    Exit.object = view:get_object("exit")
    Exit.callback = function() exit() end

    -- the default selected index
    local selection = New_Game
    local prev_selection = Undo
   
    -- getters
    function self:is_active_component()
        return Components.MENU == router:get_active_component()
    end
    function self:get_selection() return selection end
    function self:get_prev_selection() return prev_selection end
    function self:is_options_hidden() return hide_options end

    local function start_a_game()
        router:set_active_component(Components.GAME)
        game:initialize_game()
        router:notify()
        old_on_key_down = nil
    end

    local MenuCallbacks = {
    }

    local function check_for_valid(dir)
    end

    function self:move_selector(dir)
        -- move to the next node
        if selection[dir] then
            prev_selection = selection
            selection = selection[dir]
            view:move_focus()
        -- if moving down and nothing below then move down
        elseif 1 == dir[1] and (not game:get_state():must_restart()) then
            -- if options are not hidden then hide them first
            router:set_active_component(Components.GAME)
            if not self:is_options_hidden() then
                hide_options = true
                Show_Options:callback()
            end
            router:notify()
        end
    end

    function self:return_pressed()
        if not selection.callback then
            error("callback not defined for this element: "..tostring(selection))
        end

        selection:callback()
    end

end)
