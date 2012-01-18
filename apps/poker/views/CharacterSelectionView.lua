CharacterSelectionView = Class(nil, 
function(view, ctrl, ...)

    local choose_char_text = assetman:create_text({
        text = "Choose Your Dog",
        font = DEFAULT_FONT,
        color = DEFAULT_COLOR,
        opacity = 0
    })
    choose_char_text.anchor_point = {0, choose_char_text.h/2}
    local select_ai_text = assetman:create_text({
        text = "Choose Your Opponents\n      Then Press Start",
        font = DEFAULT_FONT,
        color = DEFAULT_COLOR,
        opacity = 0
    })
    select_ai_text.anchor_point = {0, select_ai_text.h/2}

    choose_char_text.position = {
        1920/2-choose_char_text.width/2,
        1080/2-choose_char_text.height/2 + 50
    }
    select_ai_text.position = {
        1920/2-select_ai_text.width/2,
        1080/2-select_ai_text.height/2 + 100
    }

    local background = {
        choose_char_text,
        select_ai_text
    }

    view.ui = assetman:create_group({name = "character_selection_ui"})
    view.ui:add(unpack(background))
    screen:add(view.ui)

    function view:update()
        local comp = router:get_active_component()
        
        if comp == Components.CHARACTER_SELECTION then
            view:show()

            -- include some directions for the user
            if ctrl.number_of_players == 0 then
                if choose_char_text.opacity ~= 255 then
                    choose_char_text:animate{
                        duration = CHANGE_VIEW_TIME+100,
                        opacity = 255
                    }
                end
                select_ai_text.opacity = 0
            else
                choose_char_text:complete_animation()
                choose_char_text.opacity = 0
                select_ai_text:animate{duration = CHANGE_VIEW_TIME+100, opacity = 170}
            end
        else
            view:hide()
        end
    end

    function view:add(aView)
        view.ui:add(aView)
    end

    function view:hide()
        view.ui:hide()
    end

    function view:show()
        view.ui:show()
    end

end)
