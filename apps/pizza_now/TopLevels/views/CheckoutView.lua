EDIT_ORDER_Y = 460

CheckoutView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    --first add the background shiz
    local back = Image{
        position = {0,0},
        src = "assets/MenuBg.jpg"
    }
    local junkInDaTrunk = Clone{source = back}
    junkInDaTrunk.position = {960, 0}
    local verticalDividerLeft = Image{
        position = {150,0},
        height = 960,
        tile = {false, true},
        src = "assets/MenuLine.png"
    }
    local verticalDividerRight = Clone{source = verticalDividerLeft}
    verticalDividerRight.position = {1770, 0}
    local verticalDividerCenter = Clone{source = verticalDividerLeft}
    verticalDividerCenter.position = {960, 0}
    local horizontalDividerLeft1 = Image{
        position = {150, 740},
        height = 960-150,
        tile = {false, true},
        src = "assets/MenuLine.png",
        z_rotation = {270,0,0}
    }
    local horizontalDividerLeft2 = Image{
        position = {150, 840},
        height = 960-150,
        tile = {false, true},
        src = "assets/MenuLine.png",
        z_rotation = {270,0,0}
    }
    local horizontalDividerRight = Clone{source = horizontalDividerLeft1}
    horizontalDividerRight.position = {960, 220}
    horizontalDividerRight.z_rotation = {270, 0, 0}
    local orderText = Text{
        position = {140, 20},
        font = CUSTOMIZE_NAME_FONT,
        color = Colors.BLACK,
        z_rotation = {90,0,0},
        text = "Order",
    }
    local detailsText = Text{
        position = {1920, 20},
        font = CUSTOMIZE_NAME_FONT,
        color = Colors.BLACK,
        z_rotation = {90,0,0},
        text = "Details",
    }
    --password stuff
    local passwordText = Text{
        position = {975, 265},
        font = CUSTOMIZE_TAB_FONT,
        color = Colors.BLACK,
        text = "Trickplay Password:",
    }
    --title of enter credit payment form
    local enterPaymentText = Text{
        position = {1000, 340},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Or enter payment data:",
    }
        --the x symbol for "extention"
    local extText = Text{
        position = {1430, 475},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "x"
    }
    --the @ symbol
    local atSymbolText = Text{
        position = {1425,530},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "@"
    }
    --Name
    local nameText = Text{
        position = {1000,415},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Name",
    }
    --Phone
    local phoneText = Text{
        position = {1000,475},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Phone",
    }
    --Email
    local emailText = Text{
        position = {1000,535},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Email",
    }
    --Instructions for driver
    local driverInstructionsText = Text{
        position = {1060,85},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Instructions for driver:",
    }

    local background = {
        back, junkInDaTrunk, verticalDividerLeft, verticalDividerRight,
        verticalDividerCenter, horizontalDividerLeft1, horizontalDividerLeft2, horizontalDividerRight,
        orderText, detailsText, passwordText, enterPaymentText, atSymbolText,
        nameText, phoneText, emailText, extText, 
        --cardNumberText, expirationText, secretCodeText,
        driverInstructionsText
    }
     
    --create the components
    local creditInfoView = CreditInfoView(model, view)
    local finalOrderView = FinalOrderView(model, view)
    local finalFooterView = FinalFooterView(model, view)
    creditInfoView:initialize()
    finalOrderView:initialize()
    finalFooterView:initialize()

    view.items = {finalOrderView, creditInfoView, finalFooterView}

    --background ui
    view.background_ui = Group{name = "checkoutBackground_ui", position = {0, 0}}
    view.background_ui:add(unpack(background))

    --ui that actually moves
    view.moving_ui=Group{name="checkoutMoving_ui", position=HIDE_TOP}
    view.moving_ui:add(view.background_ui, finalOrderView.ui, creditInfoView.ui)
    --redundant bottom bar ui group, does not move
    view.footer_ui=Group{name="checkoutFooter_ui", position={0,0}}
    view.footer_ui:add(finalFooterView.ui)
    --all ui junk for this view
    view.ui=Group{name="checkout_ui", position={0,0}}
    view.ui:add(view.moving_ui, view.footer_ui)

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(CheckoutController(self))
    end
    
    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.CHECKOUT then
            self.footer_ui.opacity = 255
            self.ui:raise_to_top()
            self.moving_ui:animate{duration=CHANGE_VIEW_TIME, position=SHOW_POSITION}
            print("Showing Checkout UI")
            for i,c_view in ipairs(view.items) do
                if i == controller:get_selected_index() then
                    assert(self:get_controller().child)
                    c_view.ui:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                    self:get_controller().child = c_view:get_controller()
                else
                    c_view.ui:animate{duration=CHANGE_VIEW_TIME, opacity=BACKGROUND_FADE_OPACITY}
                end
                if controller:get_selected_index() ~= controller.CheckoutGroups.FOOTER then
                    view.background_ui.opacity = 255
                else
                    view.background_ui.opacity = BACKGROUND_FADE_OPACITY
                end
            end
        else
            print("Hiding Checkout UI")
            self.ui:complete_animation()
            view.background_ui.opacity = 255
            self.footer_ui.opacity = 0
            self.moving_ui:animate{duration=CHANGE_VIEW_TIME, position=HIDE_TOP}
        end
    end

    function view:refresh_cart()
       assert(finalOrderView)
       finalOrderView:refresh_cart()
    end
end)
