MenuView = Class(View, function(view, model, ...)
    view._base.init(view,model)

------------ Load Assets ------------

    local menu_bars = {
        Image{src="assets/menus/Menu-1.jpg", opacity=0},
        Image{src="assets/menus/Menu-2.jpg"},
        Image{src="assets/menus/Menu-3.jpg", opacity=0},
    }
    local menu_drop_shadow = Image{
        src = "assets/menus/drop-shadow.png",
        tile = {true, false},
        width = 1920,
        y = 383,
        opacity = 140
    }

    local buttons = {
        Image{src="assets/buttons/button-5-[off].png", opacity=0},
    }
    local button_on = Image{src="assets/buttons/button-6-[on].png", opacity=0}
    buttons[2] = buttons[1]
    buttons[3] = buttons[1]
    screen:add(unpack(buttons))
    screen:add(button_on)
    
    local undo_text = Text{
        text="Undo Last Move",
        font = MENU_FONT,
        color = Colors.WHITE
    }
    local next_move_text = Text{
        text="Hint",
        font = MENU_FONT,
        color = Colors.WHITE
    }
    local deal_text = Text{
        text="Deal New Hand",
        font = MENU_FONT,
        color = Colors.WHITE
    }
    local options_text = Text{
        text="Show Options",
        font = MENU_FONT,
        color = Colors.WHITE
    }

    -- focus images for the card styles and table styles in the options menu
    local table_styles_focus = Image{src="assets/table_styles/TABLE-STYLES-FOCUS.png",opacity=0}
    local card_styles_focus = Image{src="assets/card_styles/CARD-STYLES-FOCUS.png",opacity=0}
    local checkmark_focus = Image{src="assets/checkmark-focus.png",opacity = 0}
    screen:add(table_styles_focus, card_styles_focus, checkmark_focus)

    -- items the user actually interacts with
     focusable_items = {
        -- buttons
        undo_move = FocusableImage(40, 284,
            Clone{source=buttons[2]}, Clone{source=button_on}, undo_text),
        next_move = FocusableImage(380, 284, 
            Clone{source=buttons[2]}, Clone{source=button_on}, next_move_text),
        deal_hand = FocusableImage(720, 284,
            Clone{source=buttons[2]}, Clone{source=button_on}, deal_text),
        hide_options = FocusableImage(1480, 284,
            Clone{source=buttons[2]}, Clone{source=button_on}, options_text),
        help = FocusableImage(1820, 284,
            Image{src = "assets/menus/help-button-off.png"},
            Image{src = "assets/menus/help-button-on.png"}),
        
        -- card skins
        blue_card = FocusableImage(0,0,nil,
            Clone{source=card_styles_focus}),
        red_card = FocusableImage(0,0,nil,
            Clone{source=card_styles_focus}),
        forest_card = FocusableImage(0,0,nil,
            Clone{source=card_styles_focus}),
        black_card = FocusableImage(0,0,nil,
            Clone{source=card_styles_focus}),

        -- table skins
        green_table = FocusableImage(0,0,nil,
            Clone{source=table_styles_focus}),
        brown_table = FocusableImage(0,0,nil,
            Clone{source=table_styles_focus}),
        black_table = FocusableImage(0,0,nil,
            Clone{source=table_styles_focus}),

        -- check boxes
        auto_hide = FocusableImage(1477, 41, nil,
            Clone{source=checkmark_focus}),
        deal_3 = FocusableImage(1477, 123, nil,
            Clone{source=checkmark_focus}),
        auto_finish = FocusableImage(1477, 205, nil,
            Clone{source=checkmark_focus}),
    }

    -- score related stuff
     time_text = game_timer.text
     score_text = Text{
        text="Score: 0",
        position = {1215, 301},
        font = MENU_FONT_BOLD,
        color = Colors.WHITE,
    }
    score_text.extra.score = 0
    local moves_text = Text{
        text="0 Moves",
        position = {1290, 301},
        font = MENU_FONT_BOLD,
        color = Colors.WHITE
    }
    moves_text.extra.moves = 0

    -- other text
    local auto_hide_text = Text{
        text="Auto hide menu",
        position = {1540, 50},
        font = MENU_FONT,
        color = Colors.WHITE
    }
    local deal_3_text = Text{
        text="Deal three cards",
        position = {1540, 130},
        font = MENU_FONT,
        color = Colors.WHITE
    }
    local auto_finish_text = Text{
        text="Auto finish won game",
        position = {1540, 218},
        font = MENU_FONT,
        color = Colors.WHITE
    }

    view.items = {
        time_text, score_text, --moves_text,
        auto_hide_text, deal_3_text, auto_finish_text
    }

    -- card style images
    local card_styles = {
        Image{src="assets/card_styles/CARD-STYLES-1.png"},
        Image{src="assets/card_styles/CARD-STYLES-2.png"},
        Image{src="assets/card_styles/CARD-STYLES-3.png"},
        Image{src="assets/card_styles/CARD-STYLES-4.png"},
    }
    for i,image in ipairs(card_styles) do
        image.x = (i-1)*(15+card_styles[1].width)
    end
    
    local card_styles_x_offset = 86
    focusable_items.blue_card.group.y = 88
    focusable_items.blue_card.group.x = card_styles[1].x+card_styles_x_offset
    focusable_items.red_card.group.y = 88
    focusable_items.red_card.group.x = card_styles[2].x+card_styles_x_offset
    focusable_items.forest_card.group.y = 88
    focusable_items.forest_card.group.x = card_styles[3].x+card_styles_x_offset
    focusable_items.black_card.group.y = 88
    focusable_items.black_card.group.x = card_styles[4].x+card_styles_x_offset

    view.card_style_group = Group{position={card_styles_x_offset, 88}}
    view.card_style_group:add(unpack(card_styles))

    card_style_group = view.card_style_group

    -- table style images
    local table_styles = {
        Image{src="assets/table_styles/TABLE-STYLES-1.png"},
        Image{src="assets/table_styles/TABLE-STYLES-2.png"},
        Image{src="assets/table_styles/TABLE-STYLES-3.png"},
    }
    for i,image in ipairs(table_styles) do
        image.x = (i-1)*(25+table_styles[1].width)
    end

    local table_styles_x_offset = 650
    focusable_items.brown_table.group.y = 88
    focusable_items.brown_table.group.x = table_styles[1].x+table_styles_x_offset
    focusable_items.green_table.group.y = 88
    focusable_items.green_table.group.x = table_styles[2].x+table_styles_x_offset
    focusable_items.black_table.group.y = 88
    focusable_items.black_table.group.x = table_styles[3].x+table_styles_x_offset

    view.table_style_group = Group{position={table_styles_x_offset, 88}}
    view.table_style_group:add(unpack(table_styles))
    
    table_styles_group = view.table_style_group

    -- the check marks after an item is selected
    checkmarks = {}
    local checkmark = Image{src="assets/checkmark.png", opacity=0}
    screen:add(checkmark)
    for k,item in pairs(focusable_items) do
        if k ~= "undo_move" and k ~= "next_move"
          and k ~= "deal_hand" and k ~= "hide_options" then
            checkmarks[k] = Clone{
                source = checkmark,
                x = item.group.x + item.group.width/2,
                y = item.group.y + item.group.height/2+3,
                opacity = 0,
            }
            checkmarks[k].anchor_point = {
                checkmarks[k].width/2, checkmarks[k].height/2
            }
        end
    end
    local table_checkmarks = {
        checkmarks.brown_table,
        checkmarks.green_table,
        checkmarks.black_table
    }
    local card_checkmarks = {
        checkmarks.blue_card,
        checkmarks.red_card,
        checkmarks.forest_card,
        checkmarks.black_card,
    }
    checkmarks.blue_card.opacity = 255
    checkmarks.green_table.opacity = 255
    checkmarks.deal_3.opacity = 255
    checkmarks.auto_finish.opacity = 255

    -- menu ui
    local menu_open_y = 0
    local menu_closed_y = -265
    local menu_hiden_y = -385
    view.menu_ui = Group{name = "menu_ui", position = {0, menu_closed_y}}
    view.menu_ui:add(unpack(menu_bars))
    view.menu_ui:add(unpack(view.items))
    view.menu_ui:add(view.card_style_group)
    view.menu_ui:add(view.table_style_group)
    for k,v in pairs(focusable_items) do
        view.menu_ui:add(v.group)
    end
    for k,v in pairs(checkmarks) do
        view.menu_ui:add(v)
    end
    view.menu_ui:add(menu_drop_shadow)

    -- all ui junk for this view
    view.ui=Group{name="start_menu_ui", position={0,0}}
    view.ui:add(view.menu_ui)

    screen:add(view.ui)

--------- Variables ----------------------


    view.auto_hide_menu = false
    if settings.auto_hide_menu then view.auto_hide_menu = settings.auto_hide_menu end


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

        settings.moves = moves
    end
    function increase_moves()
        moves_text.extra.moves = moves_text.extra.moves + 1
        moves_text.text = moves_text.extra.moves.." Moves"

        settings.moves = moves_text.extra.moves
    end
    function set_score(score)
        score_text.extra.score = score
        score_text.text = "Score: "..score

        settings.score = score
    end
    function increase_score()
        score_text.extra.score = score_text.extra.score + 100
        score_text.text = "Score: "..score_text.extra.score

        settings.score = score_text.extra.score
    end

    --[[
        global getters
    --]]
    function get_score() return score_text.extra.score end


---------- View Mutators ----------------------------


    function change_theme(number)
        assert(number > 0 and number <= 3, "number must be between 0 and 3")
        -- menu bar
        for i,v in ipairs(menu_bars) do
            if i == number then menu_bars[i].opacity = 255
            else menu_bars[i].opacity = 0
            end
        end

        -- show the correct checkmark
        for i,checkmark in ipairs(table_checkmarks) do
            if i == number then checkmark.opacity = 255
            else checkmark.opacity = 0
            end
        end

        settings.theme = number
    end

    function view:change_card_back(number)
        if 0 >= number or 4 < number then
            error("card theme number must be between 1 and 4", 2)
        end

        for i,card in pairs(Cards) do
            card:change_theme(number)
        end

        for i,checkmark in ipairs(card_checkmarks) do
            if i == number then checkmark.opacity = 255
            else checkmark.opacity = 0
            end
        end

        settings.card_back = number
    end

    function view:change_deal_3()
        if game:get_state():get_deal_3() then checkmarks.deal_3.opacity = 255
        else checkmarks.deal_3.opacity = 0
        end
    end

    function view:change_auto_finish()
        if game:get_state():get_auto_finish() then checkmarks.auto_finish.opacity = 255
        else checkmarks.auto_finish.opacity = 0
        end
    end

    function view:change_auto_hide()
        view.auto_hide_menu = not view.auto_hide_menu
        settings.auto_hide_menu = view.auto_hide_menu

        if view.auto_hide_menu then checkmarks.auto_hide.opacity = 255
        else checkmarks.auto_hide.opacity = 0
        end
    end


---------- Main View Functionality -------------------

    -- initialize the View/Controller pair
    function view:initialize()
        self:set_controller(MenuController(self))
        if settings.theme then
            change_theme(settings.theme)
            change_background(settings.theme)
        end
        if settings.card_back then view:change_card_back(settings.card_back) end
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

        if not game:get_state():is_new_game() then
            deal_3_text.opacity = 100
        else
            deal_3_text.opacity = 255
        end
        
        ---------- restore settings visually-----
        if view.auto_hide_menu then checkmarks.auto_hide.opacity = 255
        else checkmarks.auto_hide.opacity = 0
        end

        if game:get_state():get_deal_3() then checkmarks.deal_3.opacity = 255
        else checkmarks.deal_3.opacity = 0
        end

        if game:get_state():get_auto_finish() then checkmarks.auto_finish.opacity = 255
        else checkmarks.auto_finish.opacity = 0
        end
        -----------------------------------------

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
                local intervals = {["y"] = Interval(view.menu_ui.y, menu_closed_y)}
                gameloop:add(view.menu_ui, CHANGE_VIEW_TIME, nil, intervals)
            end
        else
            if controller:is_options_hidden() and view.menu_ui.y ~= menu_closed_y then
                local intervals = {["y"] = Interval(view.menu_ui.y, menu_closed_y)}
                gameloop:add(view.menu_ui, CHANGE_VIEW_TIME, nil, intervals)
            elseif not controller:is_options_hidden() and view.menu_ui.y ~= menu_open_y then
                local intervals = {["y"] = Interval(view.menu_ui.y, menu_open_y)}
                gameloop:add(view.menu_ui, CHANGE_VIEW_TIME, nil, intervals)
            end
        end
    end

end)
