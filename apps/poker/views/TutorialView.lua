TutorialView = Class(View, function(self, model, ...)
   
   -- Register view
    self._base.init(self, model)
    
    -- Construct the slides
    local tutorial = {}
    self.tutorial = tutorial

    local tutorialGroup = Group{}
    self.tutorialGroup = tutorialGroup
    screen:add(tutorialGroup)

    local TUTORIAL_LENGTH = 2

    -- some Buttons
    -- create the awesome Done and Next buttons
     done_button = FocusableImage(112, 920,
        Image{src = "assets/help/button-done.png"},
        Image{src = "assets/help/button-done-on.png", opacity = 0})
    local next_button = FocusableImage(1665, 920,
        Image{src = "assets/help/button-next.png"},
        Image{src = "assets/help/button-next-on.png", opacity = 0})
    -- 2nd buttons
    local back_button = FocusableImage(done_button.x, done_button.y,
        Image{src = "assets/help/button-back.png"},
        Image{src = "assets/help/button-back-on.png", opacity = 0})
    local done_button_2 = FocusableImage(next_button.x, next_button.y,
        Clone{source = done_button.image},
        Clone{source = done_button.focus, opacity = 0})

    done_button.focus.x = done_button.focus.x - 10
    done_button.focus.y = done_button.focus.y - 10
    done_button_2.focus.x = done_button_2.focus.x - 10
    done_button_2.focus.y = done_button_2.focus.y - 10
    back_button.focus.x = back_button.focus.x - 10
    back_button.focus.y = back_button.focus.y - 10
    next_button.focus.x = next_button.focus.x - 10
    next_button.focus.y = next_button.focus.y - 10

    
    function self:getBounds()
        return 1, TUTORIAL_LENGTH
    end
    
    -- Initialize
    function self:initialize()
       self:set_controller(TutorialController(self))
    end
    
    -- Update
    function self:move_focus(selector)
        if selector == 1 then
            done_button:on_focus_inst()
            back_button:on_focus_inst()
            next_button:out_focus_inst()
            done_button_2:out_focus_inst()
        else
            done_button:out_focus_inst()
            back_button:out_focus_inst()
            next_button:on_focus_inst()
            done_button_2:on_focus_inst()
        end
    end

    function self:update(p, c, n)
    
        if model:get_active_component() == Components.TUTORIAL then
            tutorialGroup:raise_to_top()
            if not tutorial[1] then
                -- begin by making an awesome red mask
                local mask = Canvas{
                    size = {1804, 964},
                    position = {55, 60}
                }
                mask:begin_painting()
                mask:set_source_color("9A363A")
                mask:round_rectangle(0, 0, 1804, 964, 15)
                mask:set_source_radial_pattern(
                    mask.x+mask.w/2, mask.y+mask.h/2, 50,
                    mask.x+mask.w/2, mask.y+mask.h/2, 900
                )
                mask:add_source_pattern_color_stop(0, "9A363A")
                mask:add_source_pattern_color_stop(1, "421A12")
                mask:fill()
                mask:finish_painting()
                local border_mask = Canvas{
                    size = {1816, 976},
                    position = {49, 54}
                }
                border_mask:begin_painting()
                border_mask:set_source_color("FFFFFF")
                border_mask:round_rectangle(0, 0, 1816, 976, 15)
                border_mask:fill()
                border_mask:finish_painting()
                border_mask.opacity = 128
                -- Page 1
                -- next add some awesome descriptions of how to play
                local text_left_1 = Text{
                    text = "Each player is initially dealt two cards visible\nonly "..
                           "to themselves. Over four betting\nrounds an additional "..
                           "five cards are dealt face\nup on the table for all to see."..
                           "\n\nThe goal is to create the best five-card hand\npossible"..
                           " from your two cards and the five\nshared cards on the "..
                           "table. To win the game\nyou must win all the chips, "..
                           "eliminating your\nopponents.\n\nIn No Limit Hold \'Em you "..
                           "can bet as much as\nyou like, even going all in by betting "..
                           "all your\nchips.",
                    size = {685, 600},
                    position = {198, 228},
                    font = "Deja Vu Sans Condensed 32px",
                    color = Colors.WHITE
                }
                local text_right_1 = Text{
                    text = "On the table there are three marker chips:\n\tD = Dealer\n"..
                           "\tSB = Small Blind\n\tBB = Big Blind\nAfter each hand the "..
                           "chips rotate clockwise\none position.\n\nThe cards are "..
                           "dealt starting with the player\none position from the "..
                           "dealer.\n\nThe first round of betting begins with the\n"..
                           "player one position clockwise from the Big\nBlind. Every "..
                           "round after begins with the\nplayer one position "..
                           "clockwise from the Deal.",
                    size = {685,600},
                    position = {1038, 228},
                    font = "Deja Vu Sans Condensed 32px",
                    color = Colors.WHITE
                }
                -- page number 1
                local page_number_1 = Text{
                   text = "1/2",
                   position = {screen.w/2, 950},
                    font = "Deja Vu Sans Condensed Bold 32px",
                    color = Colors.WHITE
                }
                page_number_1.anchor_point = {page_number_1.w/2, page_number_1.h/2}
                -- awesome logo at the top
                local logo = Image{
                    src = "assets/help/logo-small.png",
                    position = {screen.w/2, 110}
                }
                logo.anchor_point = {logo.w/2, logo.h/2}
                -- bb/sb/d chips
                local marker_chips = Image{
                    src = "assets/help/marker-chips.png",
                    position = {1040, 270}
                }
                local tutorial_1 = Group()
                tutorial_1:add(
                    border_mask, mask, text_left_1, text_right_1, marker_chips,
                    done_button.group, next_button.group, page_number_1, logo
                )
                done_button.group:raise_to_top()

                -- Page 2
                -- mask
                local mask_2 = Clone{
                    source = mask,
                    position = mask.position
                }
                local border_mask_2 = Clone{
                    source = border_mask,
                    position = border_mask.position,
                    opacity = 128
                }
                -- logo
                local logo_2 = Clone{
                    source = logo,
                    position = logo.position,
                    anchor_point = logo.anchor_point
                }
                -- text
                local text_2_top = Text{
                    text = "At the end of the game each player makes a five-card "..
                           "hand using both their cards and the five shared\ncards. "..
                           "Hands are ranked according to their rarity with "..
                           "highest-ranking hand winning.",
                    position = {180, 225},
                    font = "Deja Vu Sans Condensed 32px",
                    color = Colors.WHITE
                }
                local numbers_left = Text{
                    text = "1\n\n\n2\n\n\n3\n\n\n4\n\n\n5",
                    position = {180, 360},
                    font = "Deja Vu Sans Condensed Bold 32px",
                    color = "F3E18F"
                }
                local hands_left = Text{
                    text = "Royal Flush\n\n\nStraight Flush\n\n\nFour of a Kind\n\n\n"..
                           "Full House\n\n\nFlush",
                    position = {220, 360},
                    font = "Deja Vu Sans Condensed Bold 32px",
                    color = Colors.WHITE
                }
                local numbers_right = Text{
                    text = "  6\n\n\n  7\n\n\n  8\n\n\n  9\n\n\n10",
                    position = {1015, 360},
                    font = "Deja Vu Sans Condensed Bold 32px",
                    color = "F3E18F"
                }
                local hands_right = Text{
                    text = "Straight\n\n\nThree of a Kind\n\n\nTwo Pair\n\n\n"..
                           "One Pair\n\n\nHigh card",
                    position = {1075, 360},
                    font = "Deja Vu Sans Condensed Bold 32px",
                    color = Colors.WHITE
                }
                -- page number 2
                local page_number_2 = Text{
                   text = "2/2",
                   position = {screen.w/2, 950},
                    font = "Deja Vu Sans Condensed Bold 32px",
                    color = Colors.WHITE
                }
                -- hand images
                local hands = {}
                for i = 1,10 do
                    hands[i] = Image{src = "assets/help/P4hand"..i..".png"}
                end
                page_number_2.anchor_point = {page_number_2.w/2, page_number_2.h/2}
                local tutorial_2 = Group()
                tutorial_2:add(
                    border_mask_2, mask_2, logo_2, back_button.group,
                    done_button_2.group, text_2_top, numbers_left,
                    hands_left, numbers_right, hands_right, page_number_2
                )
                for i = 1,5 do
                    hands[i].position = {524, 339+(i-1)*(hands[1].h+28)}
                    tutorial_2:add(hands[i])
                end
                for i = 6,10 do
                    hands[i].position = {1365, 339+(i-6)*(hands[1].h+28)}
                    tutorial_2:add(hands[i])
                end
                tutorial[1] = Popup:new{
                    group = tutorial_1,
                    norender = true
                }
                tutorial[2] = Popup:new{
                    group = tutorial_2,
                    norender = true
                }
                for i, slide in ipairs(tutorial) do
                    self.tutorialGroup:add(slide.group)
                    slide.group.opacity = 140
                    ---[[
                    -- Anchored in the center
                    slide.group.anchor_point = { slide.group.w/2, slide.group.h/2 }
                    -- They start off screen to the right
                    slide.group.position = { screen.w * (3/2), screen.h/2 }
                    -- This animates them back to the start
                    slide.animate_start = {
                        opacity = 140,
                        x = screen.w * (3/2),
                        duration = 700,
                        mode = "EASE_OUT_QUAD"
                    }
                    -- This animates them into the center screen
                    slide.animate_in = {
                        opacity = 255,
                        x = screen.w/2-29,
                        duration = 700,
                        mode = "EASE_OUT_QUAD"
                    }
                    -- This animates them off to the left
                    slide.animate_out = {
                        opacity = 140,
                        x = -screen.w/2,
                        duration = 700,
                        mode = "EASE_OUT_QUAD"
                    }
                    slide.on_fade_in = function() end
                    slide.on_fade_out = function() end
                end
            end
            --]]
            --[[
            tutorialGroup:raise_to_top()
            tutorialGroup.opacity = 255
            --]]
            ---[[
            -- Active slide moves to center
            if tutorial[c] then
                local current = tutorial[c]
                current.fade = "in"
                current:render()
                current.group:raise_to_top()
            end
            
            -- Previous should move to the left
            if tutorial[p] then
                local current = tutorial[p]
                current.fade = "out"
                current:render()
                current.group:raise_to_top()
            end
            
            -- Next slide should be waiting on the right
            if tutorial[n] then
                local current = tutorial[n]
                current.group:animate( current.animate_start )
            end
            --]]end end
        else
            for i, slide in ipairs(tutorial) do
                done_button.group:unparent()
                done_button_2.group:unparent()
                next_button.group:unparent()
                back_button.group:unparent()
                slide.group:unparent()
                tutorial[i] = nil
            end
            collectgarbage("collect")
        end
        
    end
    
end)
