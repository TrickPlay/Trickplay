MenuController = Class(Controller,function(self, view, ...)
    self._base.init(self, view:get_router(), Components.MENU)

    local controller = self
    router = view:get_router()

    -- determines whether or not to hide the options menu
    local hide_options = true
    local current_theme = settings.theme

    -- Create the tables used as nodes in the menu graph
    local Blue_Card = {}
    local Red_Card = {}
    local Black_Card = {}
    local Forest_Card = {}
    local Brown_Table = {}
    local Green_Table = {}
    local Black_Table = {}
    local Auto_Hide = {}
    local Deal_3_Cards = {}
    local Auto_Finish = {}
    local Hide_Options = {}
    local Deal_New_Hand = {}
    local Next_Move = {}
    local Undo_Move = {}
    local Help = {}



    -- create the graph
    Blue_Card[Directions.DOWN] = Undo_Move
    Blue_Card[Directions.RIGHT] = Red_Card
    Blue_Card.object = view:get_object("blue_card")
    Blue_Card.callback =
        function ()
            view:change_card_back(1)
        end

    Red_Card[Directions.DOWN] = Undo_Move
    Red_Card[Directions.RIGHT] = Forest_Card
    Red_Card[Directions.LEFT] = Blue_Card
    Red_Card.object = view:get_object("red_card")
    Red_Card.callback =
        function ()
            view:change_card_back(2)
        end

    Forest_Card[Directions.DOWN] = Next_Move
    Forest_Card[Directions.RIGHT] = Black_Card
    Forest_Card[Directions.LEFT] = Red_Card
    Forest_Card.object = view:get_object("forest_card")
    Forest_Card.callback =
        function ()
            view:change_card_back(3)
        end

    Black_Card[Directions.DOWN] = Next_Move
    Black_Card[Directions.RIGHT] = Brown_Table
    Black_Card[Directions.LEFT] = Forest_Card
    Black_Card.object = view:get_object("black_card")
    Black_Card.callback =
        function ()
            view:change_card_back(4)
        end

    Brown_Table[Directions.DOWN] = Deal_New_Hand
    Brown_Table[Directions.RIGHT] = Green_Table
    Brown_Table[Directions.LEFT] = Black_Card
    Brown_Table.object = view:get_object("brown_table")
    Brown_Table.callback =
        function()
            if current_theme == 1 then return end

            change_background(1)
            change_theme(1)
            current_theme = 1
        end

    Green_Table[Directions.DOWN] = Deal_New_Hand
    Green_Table[Directions.RIGHT] = Black_Table
    Green_Table[Directions.LEFT] = Brown_Table
    Green_Table.object = view:get_object("green_table")
    Green_Table.callback =
        function()
            if current_theme == 2 then return end

            change_background(2)
            change_theme(2)
            current_theme = 2
        end


    Black_Table[Directions.DOWN] = Deal_New_Hand
    Black_Table[Directions.RIGHT] = Auto_Hide
    Black_Table[Directions.LEFT] = Green_Table
    Black_Table.object = view:get_object("black_table")
    Black_Table.callback =
        function()
            if current_theme == 3 then return end

            change_background(3)
            change_theme(3)
            current_theme = 3
        end

    
    Auto_Hide[Directions.DOWN] = Deal_3_Cards
    Auto_Hide[Directions.LEFT] = Black_Table
    Auto_Hide.object = view:get_object("auto_hide")
    Auto_Hide.callback =
        function()
            view:change_auto_hide()
        end

    Deal_3_Cards[Directions.DOWN] = Auto_Finish
    Deal_3_Cards[Directions.UP] = Auto_Hide
    Deal_3_Cards[Directions.LEFT] = Black_Table
    Deal_3_Cards.object = view:get_object("deal_3")
    Deal_3_Cards.callback =
        function()
            if game:get_state():is_new_game() then
                game:get_state():change_deal_3()
                view:change_deal_3()
            end
        end

    Auto_Finish[Directions.DOWN] = Hide_Options
    Auto_Finish[Directions.UP] = Deal_3_Cards
    Auto_Finish[Directions.LEFT] = Black_Table
    Auto_Finish.object = view:get_object("auto_finish")
    Auto_Finish.callback =
        function()
            game:get_state():change_auto_finish()
            view:change_auto_finish()
        end

    Hide_Options[Directions.UP] = Auto_Finish
    Hide_Options[Directions.LEFT] = Deal_New_Hand
    Hide_Options[Directions.RIGHT] = Help
    Hide_Options.object = view:get_object("hide_options")
    Hide_Options.callback =
        function()
            hide_options = not hide_options
            -- if the component changed then more than one notify
            -- maybe sent, which is redundant and unnecessary
            if router:get_active_component() == Components.MENU then
                view:update(NotifyEvent())
            end
        end
    
    Deal_New_Hand[Directions.UP] = Brown_Table
    Deal_New_Hand[Directions.RIGHT] = Hide_Options
    Deal_New_Hand[Directions.LEFT] = Next_Move
    Deal_New_Hand.object = view:get_object("deal_hand")
    Deal_New_Hand.callback =
        function()
            if not self:is_options_hidden() then
                Hide_Options.callback()
            end
            router:delegate(ResetEvent(), Components.GAME)
        end
    
    Next_Move[Directions.UP] = Black_Card
    Next_Move[Directions.RIGHT] = Deal_New_Hand
    Next_Move[Directions.LEFT] = Undo_Move
    Next_Move.object = view:get_object("next_move")
    Next_Move.callback =
        function()
            game:hint()
            -- move focus back to the game so player may use hint
            controller:move_selector(Directions.DOWN)
        end
    
    Undo_Move[Directions.UP] = Blue_Card
    Undo_Move[Directions.LEFT] = Help
    Undo_Move[Directions.RIGHT] = Next_Move
    Undo_Move.object = view:get_object("undo_move")
    Undo_Move.callback = 
        function()
            if (not game:get_undo_orig_selector())
              or (not game:get_undo_latest_selector()) then
                DialogDisplay("Nothing to Undo", CHANGE_VIEW_TIME*2)
                return
            end

            game:undo()
            -- move focus back to the game so player may use hint
            controller:move_selector(Directions.DOWN)
        end

    Help[Directions.UP] = Auto_Finish
    Help[Directions.LEFT] = Hide_Options
    Help[Directions.RIGHT] = Undo_Move
    Help.object = view:get_object("help")
    Help.callback =
        function()
            HelpScreen(router)
            router:set_active_component(Components.HELP)
        end

    -- the default selected index
    local selection = Undo_Move
    local prev_selection = Next_Move
   
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
          or  selection == Deal_New_Hand or  selection == Hide_Options
          or selection == Help)
          and hide_options and dir == Directions.UP
          then
            mediaplayer:play_sound("assets/sounds/bonk.mp3")
            return
        end

        -- move to the next node
        if selection[dir] then
            prev_selection = selection
            selection = selection[dir]
            view:move_focus()
            mediaplayer:play_sound("assets/sounds/arrow.mp3")
        -- if moving down and nothing below then move down
        elseif 1 == dir[2] and (not game:get_state():must_restart()) then
            -- if options are not hidden then hide them first
            router:set_active_component(Components.GAME)
            if not self:is_options_hidden() then
                Hide_Options.callback()
            end
            router:notify()
        end
    end

    function self:run_callback()
        if not selection.callback then
            error("callback not defined for this element: "..tostring(selection))
        end

        mediaplayer:play_sound("assets/sounds/enter.mp3")
        selection:callback()
    end

end)
