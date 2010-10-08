MenuView = Class(View, function(view, model, ...)
    view._base.init(view,model)

------------ Load Assets ------------

    local menu_bars = {
        Image{src = "assets/menus/menu+btns.jpg"}
    }
    local menu_options = Image{src = "assets/menus/options-menu.png", x = 0}
    menu_options.y = 1070 - menu_options.height
    local menu_drop_shadow = Image{
        src="assets/menus/menu-drop-shadow.png",
        x = 395
    }

    --
    view.items = {}

    local focusable_items = {}

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
    local menu_open_x = 395
    local menu_closed_x = 0
--    local menu_hiden_x = -408
    view.tile_group = Group{name = "selected_tile", position = {140, 220}}
    view.menu_ui = Group{name = "menu_ui"}
    view.menu_ui:add(menu_options, menu_drop_shadow)
    view.menu_ui:add(unpack(menu_bars))
    view.menu_ui:add(unpack(view.items))
    view.menu_ui:add(view.tile_group)

    -- all ui junk for this view
    view.ui=Group{name="start_menu_ui", position={0,0}}
    view.ui:add(view.menu_ui)

    screen:add(view.ui)

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

        gameloop:add(left_tile, 400, nil, left_interval)
        gameloop:add(right_tile, 400, nil, right_interval)
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
            --options_text.text = "Show Options"
        else
            --options_text.text = "Hide Options"
        end

        -- hide focus if not the active component
        if controller:is_active_component() then
            --if selected_object.on_focus then selected_object:on_focus() end
        else
            --if selected_object.off_focus then selected_object:off_focus() end
        end
--[[
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
        --]]
    end

end)
