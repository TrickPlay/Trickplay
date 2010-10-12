MenuView = Class(View, function(view, model, ...)
    view._base.init(view,model)

------------ Load Assets ------------

    -- main menu
    local menu_bars = {
        Image{src = "assets/menus/menu.jpg"}
    }
    local menu_drop_shadow = Image{
        src="assets/menus/menu-drop-shadow.png",
        x = 395
    }

    -- map selection, tile selection menu
    local menu_options_back = Image{src = "assets/options/OptionsPanel-5.png"}
    local menu_options = Group()
    menu_options:add(menu_options_back)
    local menu_open_x = 385
    local menu_closed_x = -170
    menu_options.y = 980 - menu_options.height
    menu_options.x = menu_closed_x


    --
    view.items = {
        FocusableImage(40, 392, "assets/menus/button-large-off.png",
            "assets/menus/button-large-on.png", "New Game"),
        FocusableImage(40, 392, "assets/menus/button-large-off.png",
            "assets/menus/button-large-on.png", "Undo Last Move"),
        FocusableImage(40, 392, "assets/menus/button-large-off.png",
            "assets/menus/button-large-on.png", "Shuffle Tiles"),
        FocusableImage(40, 392, "assets/menus/button-large-off.png",
            "assets/menus/button-large-on.png", "Show a Hint"),
        FocusableImage(40, 392, "assets/menus/button-large-off.png",
            "assets/menus/button-large-on.png", "Help"),
        FocusableImage(40, 392, "assets/menus/button-large-off.png",
            "assets/menus/button-large-on.png", "Show Options"),
        FocusableImage(40, 392, "assets/menus/button-large-off.png",
            "assets/menus/button-large-on.png", "Exit"),
        FocusableImage(20,54, nil, "assets/options/options-layout-focus.png"),
        FocusableImage(307,54, nil, "assets/options/options-tile-focus.png")
    }
    for i = 1,7 do
        view.items[i].group.y = 392+(i-1)*(view.items[1].image.height+10)
        view.items[i].text.y = view.items[i].text.y - 3
    end
    menu_options:add(view.items[8].group, view.items[9].group)

    local focusable_items = {
        new_game = view.items[1],
        undo = view.items[2],
        shuffle = view.items[3],
        hint = view.items[4],
        help = view.items[5],
        show_options = view.items[6],
        exit = view.items[7],
        choose_map = view.items[8],
        choose_tile = view.items[9]
    }

    -- Show/Hide Options arrow
    local show_options = focusable_items.show_options
    show_options.arrow_right = Image
    {
        src="assets/menus/arrow-right-off.png",
        position = {270, 10}
    }
    show_options.arrow_left = Image
    {
        src="assets/menus/arrow-left-off.png",
        position = {270, 10},
        opacity = 0
    }
    show_options.group:add(
        show_options.arrow_right,
        show_options.arrow_left
    )

    -- Choose map arrows
    local choose_map = focusable_items.choose_map
    choose_map.arrow_up = FocusableImage(125,35, "assets/options/arrow-up-off.png",
        "assets/options/arrow-up-on.png")
    choose_map.arrow_down = FocusableImage(125,220, "assets/options/arrow-down-off.png",
        "assets/options/arrow-down-on.png")
    choose_map.group:add(choose_map.arrow_up.group, choose_map.arrow_down.group)
    choose_map.up_arrow_focus = function()
        choose_map.arrow_up:on_focus_inst()
        choose_map.arrow_up:off_focus()
    end
    choose_map.down_arrow_focus = function()
        choose_map.arrow_down:on_focus_inst()
        choose_map.arrow_down:off_focus()
    end
    -- Choose tile arrows
    local choose_tile = focusable_items.choose_tile
    choose_tile.arrow_up = FocusableImage(80,35, "assets/options/arrow-up-off.png",
        "assets/options/arrow-up-on.png")
    choose_tile.arrow_down = FocusableImage(80,220,"assets/options/arrow-down-off.png",
        "assets/options/arrow-down-on.png")
    choose_tile.group:add(choose_tile.arrow_up.group, choose_tile.arrow_down.group)
    choose_tile.up_arrow_focus = function()
        choose_tile.arrow_up:on_focus_inst()
        choose_tile.arrow_up:off_focus()
    end
    choose_tile.down_arrow_focus = function()
        choose_tile.arrow_down:on_focus_inst()
        choose_tile.arrow_down:off_focus()
    end


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
    view.tile_group = Group{name = "selected_tile", position = {140, 220}}
    view.menu_ui = Group{name = "menu_ui"}
    view.menu_ui:add(menu_options, menu_drop_shadow)
    view.menu_ui:add(unpack(menu_bars))
    for i,item in ipairs(view.items) do
        if item.group and not item.group.parent then view.menu_ui:add(item.group)
        elseif not item.parent then view.menu_ui:add(item)
        end
    end
    view.menu_ui:add(view.tile_group)

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


---------- Extra Animations ------------------------


    add_to_key_handler(keys.o, function()
        local intervals = nil
        if menu_options.x == menu_open_x then
            intervals ={
                ["x"] = Interval(menu_options.x, menu_closed_x)
            }
        else
            intervals ={
                ["x"] = Interval(menu_options.x, menu_open_x)
            }
        end

        gameloop:add(menu_options, 400, nil, intervals)
    end)

    function view:add_tile_image(tile_image, tile_glyph)
        assert(tile_image)
        assert(tile_glyph)

        if #view.tile_group.children >= 1 then
            view.tile_group.x = view.tile_group.x - TILE_WIDTH/2
            tile_image.x = tile_image.x + TILE_WIDTH
            tile_glyph.x = tile_glyph.x + TILE_WIDTH
            view.tile_group:add(Group{children = {tile_image, tile_glyph}})
        else
            view.tile_group.position = {140, 220}
            view.tile_group:add(Group{children = {tile_image, tile_glyph}})
        end
    end

    function view:tile_bump()
        local left_tile = view.tile_group.children[1]
        local right_tile = view.tile_group.children[2]

        local left_interval = {
            ["x"] = Interval(left_tile.x, left_tile.x + 8)
        }
        local right_interval = {
            ["x"] = Interval(right_tile.x, right_tile.x - 8)
        }

        gameloop:add(left_tile, 500, nil, left_interval, 
            function()
                gameloop:add(left_tile, 400, nil, {["opacity"]=Interval(255,0)})
            end)
        gameloop:add(right_tile, 500, nil, right_interval,
            function()
                gameloop:add(right_tile, 400, nil, {["opacity"]=Interval(255,0)})
                enable_event_listeners()
            end)
    end

    function view:remove_tile_images()
        view.tile_group:clear()
        view.tile_group.position = {140, 220}
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
        if type(self.controller:get_selection().object) ~= "table" then
            error("wtf", 2)
        end
        local selected_object = self.controller:get_selection().object
        local prev_selected_object = self.controller:get_prev_selection().object
        assert(selected_object)
        if prev_selected_object.off_focus then prev_selected_object:off_focus_inst() end
        if selected_object.on_focus then selected_object:on_focus_inst() end
    end

    function view:update(event)
        assert(event)
        if not event:is_a(NotifyEvent) then return end

        local controller = self:get_controller()
        local comp = self.router:get_active_component()
        local selected_object = controller:get_selection().object

        if controller:is_options_hidden() then
            focusable_items.show_options.text.text = "Show Options"
            focusable_items.show_options.arrow_left.opacity = 0
            focusable_items.show_options.arrow_right.opacity = 255
        else
            focusable_items.show_options.text.text = "Hide Options"
            focusable_items.show_options.arrow_left.opacity = 255
            focusable_items.show_options.arrow_right.opacity = 0
        end

        -- hide focus if not the active component
        if controller:is_active_component() then
            if selected_object.on_focus then selected_object:on_focus_inst() end
        else
            if selected_object.off_focus then selected_object:off_focus_inst() end
        end
---[[
        if comp ~= Components.MENU then
            if menu_options.y ~= menu_closed_y then
                local intervals = {["x"] = Interval(menu_options.x, menu_closed_x)}
                gameloop:add(menu_options, CHANGE_VIEW_TIME, nil, intervals)
            end
        else
            if controller:is_options_hidden() and menu_options.x ~= menu_closed_x then
                local intervals = {["x"] = Interval(menu_options.x, menu_closed_x)}
                gameloop:add(menu_options, CHANGE_VIEW_TIME, nil, intervals)
            elseif not controller:is_options_hidden() and menu_options.x ~= menu_open_x then
                local intervals = {["x"] = Interval(menu_options.x, menu_open_x)}
                gameloop:add(menu_options, CHANGE_VIEW_TIME, nil, intervals)
            end
        end
        --]]
    end

end)
