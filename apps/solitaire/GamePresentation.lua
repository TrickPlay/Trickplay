GamePresentation = Class(nil,
function(pres, ctrl)
    local ctrl = ctrl

------------ Load the Assets -------------

    local backgrounds = {
        "assets/tables/Table-1.jpg",
        "assets/tables/Table-2.jpg",
        "assets/tables/Table-3.jpg",
    }
    local current_background = Image{src=backgrounds[2], name="background", scale={2.4,2.4}}
    local background = Group()
    background:add(current_background)
    background.anchor_point = {
        current_background.w*1.2,
        current_background.h*1.2
    }
    background.position = {1920/2, 1080/2, -150}
    -- the place holder where the foundation cards will go
    local foundation_holders = Group()
    local foundation_holder = Image{src="assets/tables/FoundationMarker.png",opacity=0}
    screen:add(foundation_holder)
    for i = 1,4 do
        foundation_holders:add(Clone{
            source=foundation_holder,
            position=GridPositions[3+i][1],
            anchor_point={foundation_holder.width/2, foundation_holder.height/2}
        })
    end
    -- the place holder where the stock and waste cards will go
    local waste_holder = Image{
        src = "assets/tables/WasteMarker.png",
        position = GridPositions[2][1]
    }
    waste_holder.anchor_point={waste_holder.width/2, waste_holder.height/2}
    local stock_holder = Clone{source = waste_holder, position=GridPositions[1][1]}
    stock_holder.anchor_point = {stock_holder.width/2, stock_holder.height/2}
    -- recycle stock button
    local recycle_button = Image{
        src = "assets/tables/reload-1.png",
        position = GridPositions[1][1]
    }
    recycle_button.anchor_point = {recycle_button.width/2, recycle_button.height/2}
    local ui = Group()
    ui:add(foundation_holders, waste_holder, stock_holder, recycle_button)

    screen:add(background)
    screen:add(ui)
    --ui.perspective = {40, 1, .1, 100}
    ui.x_rotation = {17, ui.height/2, 0}
    ui.y = 30
    ui.z = -120

    local stock = nil
    local backup_stock = nil
    local waste = nil
    local foundations = nil
    local tableau = nil
    local focus_pick_card = nil
    local focus_drop_card = nil
    local focus_not_valid = nil
    local focus = nil
    local collection = nil


------------- Layout Mutators -----------------

    function change_background(background_number)
        assert(background)
        assert(type(background_number) == "number")
        current_background:unparent()
        current_background = nil
        current_background = Image{
            src=backgrounds[background_number],
            name="background",
            scale = {2.4,2.4}
        }
        background:add(current_background)
        -- do this or backgrounds build up/garbage collector is being dumb
        collectgarbage("collect")
    end
   
------------- Game Flow Functions ------------------

    function pres:display_ui()
        stock = ctrl:get_stock()
        backup_stock = ctrl:get_backup_stock()
        waste = ctrl:get_waste()
        foundations = ctrl:get_foundations()
        tableau = ctrl:get_tableau()
        collection = ctrl:get_collection()

        -- add all the necessary UI elements
        ui:add(stock.group)
        ui:add(waste.group)
        ui:add(backup_stock.group)
        for _,foundation in ipairs(foundations) do
            ui:add(foundation.group)
        end
        for _,tabl in ipairs(tableau) do
            ui:add(tabl.group)
        end

        -- show focus
        focus_pick_card = Image{
            src="assets/menus/Card-Focus.png",
        }
        focus_pick_card.anchor_point = {focus_pick_card.width/2, focus_pick_card.height/2}
        focus_drop_card = Image{
            src="assets/menus/Card-Focus-3.png",
            opacity = 0
        }
        focus_drop_card.anchor_point = {focus_drop_card.width/2, focus_drop_card.height/2}
        focus_not_valid = Image{
            src="assets/menus/Card-Focus-4.png",
            opacity = 0
        }
        focus_not_valid.anchor_point = {focus_not_valid.width/2, focus_not_valid.height/2}
        focus = Group()
        focus:add(focus_pick_card, focus_drop_card, focus_not_valid)
        stock.group:add(focus)
        ui:add(collection.group)
        screen:show()
    end

    function pres:reset()
        print("pres:reset() not yet implemented")
    end

    function pres:update(event)
        if not event:is_a(NotifyEvent) then return end

        if not ctrl:is_active_component() and focus then
            focus.opacity = 0
        elseif focus then
            focus.opacity = 255
        end
    end

    function pres:move_focus(prev_selector, cb)
        local callback = nil
        if not cb then callback = function() end end

        local x = nil
        local y = nil
        local t_index = nil

        if prev_selector then
            x = prev_selector.x
            y = prev_selector.y
            t_index = prev_selector.tableau_index
        else
            local selector = ctrl:get_selector()
            x = selector.x
            y = selector.y
            t_index = selector.tableau_index
        end

        local grid = ctrl:get_grid()
        local position = Utils.deepcopy(GridPositions[x][y])
        local card = grid[x][y].stack[t_index]
        -- if moving a card back to a location then need to reference the card
        -- behind it in the stack for positioning
        if not card and prev_selector and grid[x][y].stack[t_index-1] then
            card = grid[x][y].stack[t_index-1]
        end

        focus.opacity = 0

        local focus_translation = function() end
        
        -- if moving the focus to a new location where a card exists
        if grid[x][y]:is_a(Waste) then card=grid[x][y].stack[#grid[x][y].stack] end
        if (grid[x][y]:is_a(VerticleTableau) or grid[x][y]:is_a(Waste)) and card then
            -- highlight that particular card
            position[1] = position[1] + card.position[1]
            position[2] = position[2] + card.position[2]
            position[3] = position[3] + card.position[3]
            focus_translation = function()
                focus:unparent()
                focus.position = {0,0,0}
                grid[x][y].group:add(focus)
                --[[
                intervals = {
                    ["z_rotation"] = {
                        Interval(focus.z_rotation[1], card.group.z_rotation[1]),
                        Interval(focus.z_rotation[2], card.group.z_rotation[2]),
                        Interval(focus.z_rotation[3], card.group.z_rotation[3])
                    }
                }
                gameloop:add(focus, 30, nil, intervals)
                --]]
                ---[[
                focus.z_rotation = card.group.z_rotation
                --]]
                focus.x = card.position[1]
                focus.y = card.position[2]
                focus.z = card.position[3]
            end
        else
            focus_translation = function()
                focus:unparent()
                focus.position = {0,0,0}
                grid[x][y].group:add(focus)
                --[[
                intervals = {
                    ["z_rotation"] = {
                        Interval(focus.z_rotation[1], 0),
                        Interval(focus.z_rotation[2], 0),
                        Interval(focus.z_rotation[3], 0)
                    }
                }
                gameloop:add(focus, 30, nil, intervals)
                --]]
                ---[[
                focus.z_rotation = {0,0,0}
                -- this forces the rotation
                focus.x = focus.x + 1
                focus.x = focus.x - 1
                --]]
            end
        end
        if not prev_selector then focus_translation()
        -- if moving a card back to where it was picked up originally
        else
            callback = function ()
                focus_translation()     
                if cb then cb() end
            end
        end

        if (not callback) and cb then callback = cb end

        intervals = {
            ["x"] = Interval(collection.group.x, position[1]),
            ["y"] = Interval(collection.group.y, position[2]+40),
            ["z"] = Interval(collection.group.z, position[3]+20),
        }
        gameloop:add(collection.group, 100, nil, intervals, callback)
        pres:choose_focus()
    end

    function pres:choose_focus()
        local selector = ctrl:get_selector()
        local prev_selector = ctrl:get_prev_selector()
        if not prev_selector then prev_selector = {x=0,y=0,tableau_index=0} end
        local grid = ctrl:get_grid()
        if ctrl:is_roaming() then
            focus_pick_card.opacity = 255
            focus_drop_card.opacity = 0
            focus_not_valid.opacity = 0
        -- Show green if the card can validly be placed in the given position
        -- this depends on the rules of the game (first function) or
        -- that the card was picked up from this previous position.
        -- If picked up from this previous position and checking the top row
        -- all logic is distinguished with a tableau_index of 1 and prev_selector
        -- and selector should equate.
        -- However, if the card came from the tableaus then the selector will be
        -- highlighting the card below the prev_selector and the logic must check
        -- whether or not the prev_selector tableau_index is 1 greater than the
        -- selector's tableau_index
        elseif ctrl:get_state():valid_move() 
          or ((prev_selector.x == selector.x and prev_selector.y == selector.y)
          and (prev_selector.tableau_index == selector.tableau_index
          or (GridRows.TABLEAUS == prev_selector.y
          and prev_selector.tableau_index-1 == selector.tableau_index))) then
            focus_pick_card.opacity = 0
            focus_drop_card.opacity = 255
            focus_not_valid.opacity = 0
        else
            focus_pick_card.opacity = 0
            focus_drop_card.opacity = 0
            focus_not_valid.opacity = 255
        end

        focus.opacity = 255
    end

    function pres:hint_animation(old_x, old_y, old_t_index, new_x, new_y, new_t_index)
        mediaplayer:play_sound("assets/sounds/Hint.mp3")

        local old_position = {
            x = old_x,
            y = old_y,
            tableau_index = old_t_index
        }
        local new_position = {
            x = new_x,
            y = new_y,
            tableau_index = new_t_index
        }
        game:set_selector(old_position,
            function()
                game:run_callback(
                    function()
                        game:set_selector(new_position)
                    end)
            end)
    end

    function pres:end_game_animation()
        local count = 0
        local card_count = 0
        local card
        local theta
        local card_position
        while count < 4 do
            count = 0
            for _,foundation in ipairs(game:get_foundations()) do
                if #foundation.stack == 0 then
                    count = count + 1
                else
                    card = foundation:pop()
                    card.group.position = Utils.deepcopy(card.position)
                    card_position = {0,0,card.position[3]}
                    theta = math.rad(math.random(8*180/6))
                    card_position[1] = 2500*math.cos(theta)
                    card_position[2] = 2500*math.sin(theta)
                    intervals = {
                        ["x"] = Interval(card.position[1], card_position[1]),
                        ["y"] = Interval(card.position[2], card_position[2])
                    }
                    card.position = card_position
                    gameloop:add(card.group, 500, CARD_MOVE_DURATION + 2000,
                                 intervals)
                    card_count = card_count + 1
                end
            end
        end
    end

end)
