MenuController = Class(Controller,function(self, view, ...)
    self._base.init(self, view:get_router(), Components.MENU)

    local controller = self
    router = view:get_router()

    -- determines whether or not to hide the options menu
    local hide_options = true
    -- the value which represent the current image used of the tiles,
    -- index's global TILE_IMAGES
    local current_tile_image = 2
    -- the current layout type, defaults to the classic "turtle"
    local current_layout = 7
    -- facilitate the MenuView() function view:move_layout(current_layout, dir)
    local direction = Directions.UP
    local last_layout = 7

    function controller:get_current_layout() return current_layout end
    function controller:get_direction() return direction end
    function controller:get_last_layout() return last_layout end
    function controller:restore_layout_indicator() current_layout=last_layout end

    -- Create the tables used as nodes in the menu graph
    local New_Game = {}
    local Undo = {}
    local Shuffle = {}
    local Hint = {}
    local Help = {}
    local Show_Options = {}
    local Exit = {}
    local Choose_Map = {}
    local Choose_Tile = {}

    -- create the graph
    New_Game[Directions.UP] =
        function()
            mediaplayer:play_sound("assets/audio/bonk.mp3")
        end
    New_Game[Directions.DOWN] = Undo
    New_Game.object = view:get_object("new_game")
    New_Game.callback =
        function()
            game:reset_game(current_layout)
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

    local wait = false
    local timer = Timer()
    Hint[Directions.UP] = Shuffle
    Hint[Directions.DOWN] = Help
    Hint.object = view:get_object("hint")
    Hint.callback =
        function()
            if not wait then game:get_state():hint() end
            wait = true
            timer.interval = 2000
            function timer:on_timer()
                timer:stop()
                wait = false
            end
            timer:start()
        end

    Help[Directions.UP] = Hint
    Help[Directions.DOWN] = Show_Options
    Help.object = view:get_object("help")
    Help.callback = 
        function()
            HelpScreen(router)
            router:set_active_component(Components.HELP)
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
    Exit[Directions.DOWN] =
        function()
            mediaplayer:play_sound("assets/audio/bonk.mp3")
        end
    Exit.object = view:get_object("exit")
    Exit.callback = function() exit() end

    Choose_Map[Directions.UP] =
        function()
            Choose_Map.object:up_arrow_focus()
            last_layout = current_layout
            if current_layout > 1 then
                current_layout = current_layout - 1
            else
                current_layout = Layouts.LAST
            end
            direction = Directions.DOWN
            view:move_layout(current_layout, Directions.UP)
            mediaplayer:play_sound("assets/audio/arrow.mp3")
        end
    Choose_Map[Directions.DOWN] =
        function()
            Choose_Map.object:down_arrow_focus()
            last_layout = current_layout
            if current_layout < Layouts.LAST then
                current_layout = current_layout + 1
            else
                current_layout = 1
            end
            direction = Directions.UP
            view:move_layout(current_layout, Directions.DOWN)
            mediaplayer:play_sound("assets/audio/arrow.mp3")
        end
    Choose_Map[Directions.LEFT] = Show_Options
    Choose_Map[Directions.RIGHT] = Choose_Tile
    Choose_Map.object = view:get_object("choose_map")

    Choose_Tile[Directions.UP] =
        function()
            Choose_Tile.object:up_arrow_focus()
            current_tile_image = game:get_current_tile_image()
            if current_tile_image > 1 then
                current_tile_image = current_tile_image - 1
            else
                current_tile_image = #TILE_IMAGES
            end
            view:change_tiles(current_tile_image, Directions.UP)
            mediaplayer:play_sound("assets/audio/arrow.mp3")
        end
    Choose_Tile[Directions.DOWN] =
        function()
            Choose_Tile.object:down_arrow_focus()
            current_tile_image = game:get_current_tile_image()
            if current_tile_image < #TILE_IMAGES then
                current_tile_image = current_tile_image + 1
            else
                current_tile_image = 1
            end
            view:change_tiles(current_tile_image, Directions.DOWN)
            mediaplayer:play_sound("assets/audio/arrow.mp3")
        end
    Choose_Tile[Directions.LEFT] = Choose_Map
    Choose_Tile.object = view:get_object("choose_tile")


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

    function self:move_selector(dir)
        -- move to the next node
        if 1 == dir[1] and selection ~= Choose_Map and selection ~= Choose_Tile
        and not self:is_options_hidden() then
            prev_selection = selection
            selection = Choose_Map
            mediaplayer:play_sound("assets/audio/arrow.mp3")
            view:move_focus()
        elseif selection[dir] then
            if type(selection[dir]) == "function" then
                selection[dir]()
            else
                prev_selection = selection
                selection = selection[dir]
                mediaplayer:play_sound("assets/audio/arrow.mp3")
                view:move_focus()
            end
        -- if moving right and only the game is to the right
        elseif 1 == dir[1] and (not game:get_state():must_restart()) then
            -- if options are not hidden then hide them first
            router:set_active_component(Components.GAME)
            if not self:is_options_hidden() then
                Show_Options:callback()
            end
            router:notify()
            -- if in the hidden options then return to Show Options
            if selection == Choose_Map or selection == Choose_Tile then
                selection = Show_Options
            end
        end
    end

    function self:return_pressed()
        if not selection.callback then
            return
--            error("callback not defined for this element: "..tostring(selection))
        end

        selection:callback()
        mediaplayer:play_sound("assets/audio/enter.mp3")
    end

end)
