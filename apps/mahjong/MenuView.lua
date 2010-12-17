MenuView = Class(View, function(view, model, ...)
    view._base.init(view,model)

    local controller = nil

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
    local large_button_off = Image{src="assets/menus/button-large-off.png", opacity=0}
    local large_button_on = Image{src="assets/menus/button-large-on.png", opacity=0}
    screen:add(large_button_off, large_button_on)
    view.items = {
        FocusableImage(40, 392, Clone{source=large_button_off},
            Clone{source=large_button_on}, "New Game"),
        FocusableImage(40, 392, Clone{source=large_button_off},
            Clone{source=large_button_on}, "Undo Last Move"),
        FocusableImage(40, 392, Clone{source=large_button_off},
            Clone{source=large_button_on}, "Shuffle Tiles"),
        FocusableImage(40, 392, Clone{source=large_button_off},
            Clone{source=large_button_on}, "Show a Hint"),
        FocusableImage(40, 392, Clone{source=large_button_off},
            Clone{source=large_button_on}, "Help"),
        FocusableImage(40, 392, Clone{source=large_button_off},
            Clone{source=large_button_on}, "Show Options"),
        FocusableImage(40, 392, Clone{source=large_button_off},
            Clone{source=large_button_on}, "Exit"),
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
        src="assets/options/option-arrow-right.png",
        position = {270, 17}
    }
    show_options.arrow_left = Image
    {
        src="assets/options/option-arrow-left.png",
        position = {270, 17},
        opacity = 0
    }
    show_options.group:add(
        show_options.arrow_right,
        show_options.arrow_left
    )

    local up_arrow_off = Image{src="assets/options/arrow-up-off.png",opacity=0}
    local up_arrow_on = Image{src="assets/options/arrow-up-on.png",opacity=0}
    local down_arrow_off = Image{src="assets/options/arrow-down-off.png",opacity=0}
    local down_arrow_on = Image{src="assets/options/arrow-down-on.png",opacity=0}
    screen:add(up_arrow_off, up_arrow_on, down_arrow_off, down_arrow_on)
    -- Choose map arrows
    local choose_map = focusable_items.choose_map
    choose_map.arrow_up = FocusableImage(125,35, Clone{source=up_arrow_off},
        Clone{source=up_arrow_on})
    choose_map.arrow_down = FocusableImage(125,220, Clone{source=down_arrow_off},
        Clone{source=down_arrow_on})
    choose_map.up_arrow_focus = function()
        choose_map.arrow_up:on_focus_inst()
        choose_map.arrow_up:off_focus()
    end
    choose_map.down_arrow_focus = function()
        choose_map.arrow_down:on_focus_inst()
        choose_map.arrow_down:off_focus()
    end
    -- Layouts for the player to select
    local layout_mask = Group{position={25,25},clip={0,0,232,225}}
    local layout_strip_image = Image{src="assets/options/LayoutStrip.png", opacity = 0}
    screen:add(layout_strip_image)
    local layout_strip_1 = Clone{source=layout_strip_image}
    local layout_strip_2 = Clone{source=layout_strip_image, y = -layout_strip_1.height}
    local layout_strip_3 = Clone{source=layout_strip_image, y = layout_strip_1.height}
    local layout_strip = Group{position = {0,-layout_strip_image.height*6/7}}
    layout_strip:add(layout_strip_1, layout_strip_2, layout_strip_3)
    layout_mask:add(layout_strip)
    -- text describing type of layout
    layout_text = Text{
        text = "Turtle (Classic)", font = MENU_FONT_SMALL,
        color = DEFAULT_COLOR, position={142, -5}
    }
    layout_text.anchor_point = {layout_text.width/2, layout_text.height/2}
    choose_map.group:add(
        layout_text, layout_mask,choose_map.arrow_up.group,choose_map.arrow_down.group
    )

    -- Choose tile arrows
    local choose_tile = focusable_items.choose_tile
    choose_tile.arrow_up = FocusableImage(80,35, Clone{source=up_arrow_off},
        Clone{source=up_arrow_on})
    choose_tile.arrow_down = FocusableImage(80,220, Clone{source=down_arrow_off},
        Clone{source=down_arrow_on})
    choose_tile.up_arrow_focus = function()
        choose_tile.arrow_up:on_focus_inst()
        choose_tile.arrow_up:off_focus()
    end
    choose_tile.down_arrow_focus = function()
        choose_tile.arrow_down:on_focus_inst()
        choose_tile.arrow_down:off_focus()
    end

    -- Tiles for the player to select
    local tile_mask = Group{position={45,25},clip={0,0,130,225}}
    local tiles_strip_image = Image{src="assets/options/tiles-strip3.png", opacity = 0}
    screen:add(tiles_strip_image)
    local tiles_strip_1 = Clone{source=tiles_strip_image}
    local tiles_strip_2 = Clone{source=tiles_strip_image, y = -tiles_strip_1.height-35}
    local tiles_strip_3 = Clone{source=tiles_strip_image, y = tiles_strip_1.height+35}
    local tiles_strip = Group{position = {0,-153}}
    tiles_strip:add(tiles_strip_1, tiles_strip_2, tiles_strip_3)
    tile_mask:add(tiles_strip)
    -- text describing type of tile
    local tile_text = Text{
        text = "Wood", font = MENU_FONT_SMALL,
        color = DEFAULT_COLOR, position={100, -5}
    }
    tile_text.anchor_point = {tile_text.width/2, tile_text.height/2}
    choose_tile.group:add(
        tile_text, tile_mask,choose_tile.arrow_up.group, choose_tile.arrow_down.group
    )

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
        if item.group then
            if not item.group.parent then view.menu_ui:add(item.group) end
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

        gameloop:add(left_tile, 500, nil, left_interval, nil,
            function()
                gameloop:add(left_tile, 400, nil, {["opacity"]=Interval(255,0)})
            end)
        gameloop:add(right_tile, 500, nil, right_interval, nil,
            function()
                gameloop:add(right_tile, 400, nil, {["opacity"]=Interval(255,0)})
                enable_event_listeners()
            end)
    end

    function view:remove_tile_images()
        view.tile_group:clear()
        view.tile_group.position = {140, 220}
    end

    function view:change_tiles(number, dir)
        local interval = nil
        if -1 == dir[2] then
            interval = {["y"] = Interval(tiles_strip.y, tiles_strip.y + 195)}
            gameloop:add(tiles_strip, 300, nil, interval, nil,
                function()
                    if number == 3 then tiles_strip.y = -350 end
                    game:get_state():get_tiles_class():change_images(number)
                end)
        elseif 1 == dir[2] then
            interval = {["y"] = Interval(tiles_strip.y, tiles_strip.y - 195)}
            gameloop:add(tiles_strip, 300, nil, interval, nil,
                function()
                    if number == 1 then tiles_strip.y = 40 end
                    game:get_state():get_tiles_class():change_images(number)
                end)
        else
            error("something went wrong")
        end

        tile_text.text = TILE_NAMES[number]
        tile_text.anchor_point = {tile_text.width/2, tile_text.height/2}
    end

    function view:change_layout(current_layout, dir)
        if not game:is_new_game() and not game:game_won() then
            router:set_active_component(Components.NEW_MAP_DIALOG)
            router:notify()
        else
            game:reset_game(current_layout)
        end
    end

    function view:load_layout(number)
        layout_strip.y = -layout_strip_image.height*(number-1)/7
        layout_text.text = LAYOUT_NAMES[number]
        layout_text.anchor_point = {layout_text.width/2, layout_text.height/2}
    end

    function view:move_layout(current_layout, dir)
        local change_layout = true

        if not dir then dir = controller:get_direction() end
        if not current_layout then
            current_layout = controller:get_last_layout()
            controller:restore_layout_indicator()
            change_layout = false
        end

        local interval = nil
        if -1 == dir[2] then
            interval = {["y"] = Interval(layout_strip.y, layout_strip.y + 
                layout_strip_image.height*1/7)}
            gameloop:add(layout_strip, 300, nil, interval, nil,
                function()
                    if current_layout == Layouts.LAST then
                        layout_strip.y = -layout_strip_image.height*6/7
                    end
                    if change_layout then
                        view:change_layout(current_layout, dir)
                    end
                end)
        elseif 1 == dir[2] then
            interval = {["y"] = Interval(layout_strip.y, layout_strip.y - 
                layout_strip_image.height*1/7)}
            gameloop:add(layout_strip, 300, nil, interval, nil,
                function()
                    if current_layout == 1 then
                        layout_strip.y = 0
                    end
                    if change_layout then
                        view:change_layout(current_layout, dir)
                    end
                end)
        else
            error("something went wrong")
        end

        layout_text.text = LAYOUT_NAMES[current_layout]
        layout_text.anchor_point = {layout_text.width/2, layout_text.height/2}
    end


---------- Main View Functionality -------------------


    -- initialize the View/Controller pair
    function view:initialize()
        self:set_controller(MenuController(self))
        controller = self:get_controller()
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
        -- for opening and closing the options menu
        if comp ~= Components.MENU and comp ~= Components.NEW_MAP_DIALOG then
            if menu_options.x ~= menu_closed_x then
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
    end

end)
