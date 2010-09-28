GamePresentation = Class(nil,
function(pres, ctrl)
    local ctrl = ctrl


------------ Load the Assets -------------


    local backgrounds = {
    }
    local current_background = Image{src=backgrounds[2], name="background"}
    local background = Group()
    background:add(current_background)
    background.anchor_point = {current_background.w/2, current_background.h/2}
    background.position = {1920/2, 1080/2}

    local tiles = {
        "assets/tiles/TileWoodLg.png",
        "assets/tiles/TilePlasticLg.png"
    }

    local focus = nil
    
    ui = Group()
    ui:add(background)

    screen:add(ui)


------------- Layout Mutators -----------------


    function change_background(background_number)
        assert(background)
        assert(type(background_number) == "number")
        current_background:unparent()
        current_background = nil
        current_background = Image{
            src=backgrounds[background_number],
            name="background"
        }
        background:add(current_background)
    end

   
------------- Game Flow Functions ------------------


    function pres:display_ui()

        -- show focus
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

    function pres:move_focus()
    end

    function pres:choose_focus()
    end

    function pres:end_game_animation()
    end

end)
