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
    --password stuff
    local passwordText = Text{
        position = {975, 265},
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
    local passwordFormRight = Image{
        position = {1730,260},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    --title of enter credit payment form
    local enterPaymentText = Text{
        position = {1000, 340},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Or enter payment data:",
    }
    --credit card forms
    local formGroup = Group{position = {1140, 400}}
    local formLeft = Image{
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeft.png",
    }
    local formCenter = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = 1420-1160,
        tile = {true, false}
    }
    local formRight = Image{
        position = {1420-1150, 0},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    formGroup:add(formLeft, formCenter, formRight)
    formGroup:hide()
    local firstNameGroup = Clone{source = formGroup}
    firstNameGroup.position = {1140, 400}
    local lastNameGroup = Clone{source = formGroup}
    lastNameGroup.position = {1440, 400}
    local emailNameGroup = Clone{source = formGroup}
    emailNameGroup.position = {1140, 520}
    local emailAtGroup = Clone{source = formGroup}
    emailAtGroup.position = {1460, 520}
    --more credit form stuff for entering phone number
    local phoneGroup = Group{position = {1140, 460}}
    local phoneFormLeft = Image{
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeft.png",
    }
    local phoneFormCenter = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = 1220-1160,
        tile = {true, false}
    }
    local phoneFormRight = Image{
        position = {1220-1150, 0},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    phoneGroup:add(phoneFormLeft, phoneFormCenter, phoneFormRight)
    local phoneGroup2 = Clone{source = phoneGroup}
    phoneGroup2.position = {1230, 460}
    local phoneGroup3 = Group{position = {1320,460}}
    local phoneFormLeft3 = Image{
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeft.png",
    }
    local phoneFormCenter3 = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = 1410-1340,
        tile = {true, false}
    }
    local phoneFormRight3 = Image{
        position = {1400-1320, 0},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    phoneGroup3:add(phoneFormLeft3, phoneFormCenter3, phoneFormRight3)
    local phoneGroup4 = Clone{source = phoneGroup}
    phoneGroup4.position = {1440, 460}

    --the @ symbol
    local atSymbolText = Text{
        position = {1425,530},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "@",
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
    --Credit Companies or Cash Images
    local cash = Image{
        src = "assets/credit_stuff/Payment_Cash.png",
        position = {990, 600}
    }
    local masterCard = Image{
        src = "assets/credit_stuff/Payment_MC.png",
        position = {1140, 600}
    }
    local visaCard = Image{
        src = "assets/credit_stuff/Payment_Visa.png",
        position = {1300, 600}
    }
    local americanExpressCard = Image{
        src = "assets/credit_stuff/Payment_AM.png",
        position = {1450, 600}
    }
    local discoverCard = Image{
        src = "assets/credit_stuff/Payment_Disc.png",
        position = {1580, 600}
    }
    --card number entry forms
    local cardGroup1 = Clone{source = phoneGroup3}
    cardGroup1.position = {1140, 760}
    local cardGroup2 = Clone{source = phoneGroup3}
    cardGroup2.position = {1250, 760}
    local cardGroup3 = Clone{source = phoneGroup3}
    cardGroup3.position = {1360, 760}
    local cardGroup4 = Clone{source = phoneGroup3}
    cardGroup4.position = {1470, 760}
    local cardNumberText = Text{
        position = {1000,780},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Card #",
    }
    local expirationGroup = Group{position = {1140, 820}}
    local expirationMonthForm = Group()
    local expirationMonthFormLeft = Image{
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeft.png",
    }
    local expirationMonthFormCenter = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = 1200-1160,
        tile = {true, false}
    }
    local expirationMonthFormRight = Image{
        position = {1210-1160, 0},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    expirationMonthForm:add(expirationMonthFormLeft, expirationMonthFormCenter,
        expirationMonthFormRight)
    local expirationYearForm = Clone{source = phoneGroup3}
    expirationYearForm.position = {1210-1140, 0}
    expirationGroup:add(expirationMonthForm, expirationYearForm)
    local expirationText = Text{
        position = {1000,840},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Expires",
    }
    local secretCodeGroup = Clone{source = phoneGroup}
    secretCodeGroup.position = {1470, 820}
    local secretCodeText = Text{
        position = {1380,840},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "CVC",
    }
    local creditInstructionsText = Text{
        position = {1320,890},
        font = CUSTOMIZE_TINY_FONT,
        color = Colors.BLACK,
        text = "Please have your legal photo ID and\ncredit card available for verification.",
    }
    --Instructions for driver
    local driverInstructionsText = Text{
        position = {1060,80},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Instructions for driver:",
    }
    local driverInstructionsForm = Group()
    driverInstructionsForm.position = {1020,120}
    local driverInstructionsFormLeft = Image{ 
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeft.png",
    }
    local driverInstructionsFormCenter = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = 1680-1040,
        tile = {true, false}
    }
    local driverInstructionsFormRight = Image{
        position = {1680-1030, 0},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    driverInstructionsForm:add(driverInstructionsFormLeft, driverInstructionsFormCenter,
        driverInstructionsFormRight)
    --stuff describing the persons order
    local editOrderText = Text{
        position = {410,460},
        font = CUSTOMIZE_TAB_FONT,
        color = Colors.BLACK,
        text = "Edit Order",
    }
    local addCouponText = Text{
        position = {390,550},
        font = CUSTOMIZE_TAB_FONT,
        color = Colors.BLACK,
        text = "Add Coupon",
    }
    local taxText = Text{
        position = {190, 800},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Tax, Processing, & Delivery",
    }
    local totalCostText = Text{
        position = {170,880},
        font = CUSTOMIZE_TAB_FONT,
        color = Colors.BLACK,
        text = "Total",
    }
    local orderBar = Image{
        src = "assets/OrderBarBase.png",
        position = {0, 960},
        tile = {true, false},
        width = 1920
    }
    local termsText = Text{
        position = {720, 990},
        font = CUSTOMIZE_TINY_FONT,
        color = Colors.BLACK,
        text = "By ordering, I implicitly agree to the Terms and\nConditions of Domino's Pizza and Pizza Now."
    }
    local background = {
        back, junkInDaTrunk, verticalDividerLeft, verticalDividerRight,
        verticalDividerCenter, horizontalDividerLeft, horizontalDividerRight,
        orderText, detailsText, passwordText, passwordFormLeft, passwordFormCenter,
        passwordFormRight, formGroup, enterPaymentText, firstNameGroup,
        lastNameGroup, emailNameGroup, emailAtGroup, atSymbolText, nameText,
        phoneText, emailText, phoneGroup, phoneGroup2, phoneGroup3, phoneGroup4,
        cash, masterCard, visaCard, americanExpressCard, discoverCard, cardGroup1,
        cardGroup2, cardGroup3, cardGroup4, cardNumberText, expirationGroup,
        expirationText, secretCodeGroup, secretCodeText, creditInstructionsText,
        driverInstructionsText, driverInstructionsForm, editOrderText,
        addCouponText, taxText, totalCostText, orderBar, termsText
    }


    --next add the form shiz
    local street = Text{
        position={50,0},
        font=DEFAULT_FONT,
        color=DEFAULT_COLOR,
        editable = true,
        text="Enter Street",
        wants_enter = false,
        max_length = 20
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

    view.entry_ui = Group{name = "checkoutEntry_ui", position  = {0, 0}}
    view.entry_ui:add(unpack(menu_items))
    view.static_ui = Group{name = "checkoutStatic_ui", position = {0, 0}}
    view.static_ui:add(unpack(background))
    view.ui=Group{name="checkout_ui", position={0,0}}
    view.ui:add(view.static_ui, view.entry_ui)
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
