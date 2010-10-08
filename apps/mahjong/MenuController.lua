MenuController = Class(Controller,function(self, view, ...)
    self._base.init(self, view:get_router(), Components.MENU)

    local controller = self
    router = view:get_router()

    -- determines whether or not to hide the options menu
    local hide_options = false

    -- Create the tables used as nodes in the menu graph
    local New_Game = {}
    local Undo = {}
    local Shuffle = {}
    local Hint = {}
    local Help = {}
    local Show_Options = {}

    -- create the graph
    New_Game[Directions.DOWN] = Undo
    New_Game.object = view:get_object("new_game")
    New_Game.callback = 
        function()
        end

    Undo[Directions.UP] = New_Game
    Undo[Directions.DOWN] = Shuffle
    Undo.object = view:get_object("undo")
    Undo.callback = 
        function()
        end

    Shuffle[Directions.UP] = Undo
    Shuffle[Directions.DOWN] = Hint
    Shuffle.object = view:get_object("shuffle")
    Shuffle.callback = 
        function()
        end

    Help[Directions.UP] = Hint
    Help[Directions.DOWN] = Show_Options
    Help.object = view:get_object("help")
    Help.callback = 
        function()
        end

    Show_Options[Directions.UP] = Help
    Show_Options.object = view:get_object("show_options")
    Show_Options.callback =
        function()
        end

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
        -- if options are hidden and at the bottom level options can't move up!
        if (selection == Undo_Move or  selection == Next_Move
          or  selection == Deal_New_Hand or  selection == Hide_Options)
          and hide_options and dir == Directions.UP
          then
            return
        end

        -- move to the next node
        if selection[dir] then
            prev_selection = selection
            selection = selection[dir]
            view:move_focus()
        -- if moving down and nothing below then move down
        elseif 1 == dir[2] and (not game:get_state():must_restart()) then
            -- if options are not hidden then hide them first
            router:set_active_component(Components.GAME)
            if not self:is_options_hidden() then
                Hide_Options:callback(false)
            end
            router:notify()
        end
    end

    function self:run_callback()
        if not selection.callback then
            error("callback not defined for this element: "..tostring(selection))
        end

        selection:callback()
    end

end)
