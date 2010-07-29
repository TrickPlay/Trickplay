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
    local horizontalDividerLeft = Image{
        position = {150, 840},
        height = 960-150,
        tile = {false, true},
        src = "assets/MenuLine.png",
        z_rotation = {270,0,0}
    }
    local horizontalDividerRight = Clone{source = horizontalDividerLeft}
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
    local passwordText = Text{
        position = {970, 260},
        font = CUSTOMIZE_TAB_FONT,
        color = Colors.BLACK,
        text = "Trickplay Password:",
    }
    local passwordFormLeft = Image{
        position = {1460, 260},
        src = "assets/credit_stuff/TextBoxLeft.png",
    }
    local passwordFormCenter = Image{
        position = {1470,260},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = 1730-1470,
        tile = {true, false}
    }
    passwordFormRight = Image{
        position = {1730,260},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    local background = {
        back, junkInDaTrunk, verticalDividerLeft, verticalDividerRight,
        verticalDividerCenter, horizontalDividerLeft, horizontalDividerRight,
        orderText, detailsText, passwordText, passwordFormLeft, passwordFormCenter,
        passwordFormRight
    }

    --next add the form shiz
    local street = Text{
        position={50,0},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        editable = true,
        text="Enter Street",
        wants_enter = false
    }
    local apartment = Text{
        position = {400, 0},
        font=DEFAULT_FONT,
        color = DEFAULT_COLOR,
        editable = true,
        text = "Apt."
    }
    local city = Text{
        position={50,60},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        editable = true,
        text="City"
    }
    local zip_code = Text{
        position={50,120},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        editable = true,
        text="Zip Code"
    }
    local card_type = Text{
        position = {50, 180},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        editable = true,
        text="Card Type"
    }
    local card_number = Text{
        position = {50, 240},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        editable = true,
        text="Card Number"
    }
    local card_secret_code = Text{
        position = {50, 300},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        editable = true,
        text="Secret Code"
    }
    local card_expiration = Text{
        position = {50, 360},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        editable = true,
        text="Expiration"
    }
    local confirm = Text{
        position={50, 420},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        text = "Confirm Information?"
    }
    local exit = Text{
        position={50, 480},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        text = "Go Back"
    }

    local menu_items = {street, apartment, city, zip_code, card_type, card_number, card_secret_code, card_expiration, confirm, exit}

    view.ui=Group{name="checkout_ui", position={0,0}}
    view.ui:add(unpack(background))
    view.ui:add(unpack(menu_items))
    assert(view.ui.children[1])
    screen:add(view.ui)

    function view:initialize()
        self:set_controller(CheckoutController(self))
    end

    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.CHECKOUT then
            self.ui.opacity = 255
            print("Showing Checkout UI")
            for i,item in ipairs(menu_items) do
                if i == controller:get_selected_index() then
                    item:animate{duration = CHANGE_VIEW_TIME, opacity=255}
                else
                    item:animate{duration = CHANGE_VIEW_TIME, opacity=100}
                end
            end
        else
            print("Hiding Checkout UI")
            self.ui:complete_animation()
            self.ui.opacity = 0
        end
    end

end)
