EDIT_ORDER_Y = 460

CheckoutView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    view.cart_items = {}
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
        position = {1590, 600}
    }
    --credit card text stuff
    local cardNumberText = Text{
        position = {1000,740},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Card #"
    }
    local expirationText = Text{
        position = {1000,800},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Expires",
    }
    local secretCodeText = Text{
        position = {1400,800},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "CVC",
    }
    --Instructions for driver
    local driverInstructionsText = Text{
        position = {1060,80},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Instructions for driver:",
    }
    --stuff describing the persons order
    local editOrderText = Text{
        position = {410,EDIT_ORDER_Y},
        font = CUSTOMIZE_TAB_FONT,
        color = Colors.BLACK,
        text = "Edit Order",
    }
    --placing the cart items in between the top of the screen and edit order
    local currentCart = Text{
        position = {160,0},
        font = CUSTOMIZE_TAB_FONT,
        color = Colors.BLACK,
        text = "Current Cart:",
    }
    --more text
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
    
    --driverInstructionsTextbox
    local driverInstructionsTextbox = Textbox(1020, 120, 1760-1040)
    --password Textbox
    local passwordTextbox = Textbox(1460, 260, 1740-1460)
    --credit card forms
    local firstNameTextbox = Textbox(1140, 400, 1420-1140)
    local lastNameTextbox = Textbox(1440, 400, 1440-1140)
    local emailNameTextbox = Textbox(1140, 520, 1420-1140)
    local emailAtTextbox = Textbox(1460, 520, 1420-1140)
    --more credit form stuff for entering phone number
    local phoneTextbox1 = Textbox(1140, 460, THREE_CHARACTERS)
    local phoneTextbox2 = Textbox(1230, 460, THREE_CHARACTERS)
    local phoneTextbox3 = Textbox(1320, 460, FOUR_CHARACTERS)
    local phoneTextbox4 = Textbox(1460, 460, THREE_CHARACTERS)
    --card number entry forms
    local cardTextbox1 = Textbox(1140, 720, FOUR_CHARACTERS)
    local cardTextbox2 = Textbox(1250, 720, FOUR_CHARACTERS)
    local cardTextbox3 = Textbox(1360, 720, FOUR_CHARACTERS)
    local cardTextbox4 = Textbox(1470, 720, FOUR_CHARACTERS)
    --card expiration forms
    local expirationMonthTextbox = Textbox(1140, 780, TWO_CHARACTERS)
    local expirationYearTextbox = Textbox(1220, 780, FOUR_CHARACTERS)
    --CVC
    local secretCodeTextbox = Textbox(1490, 780, THREE_CHARACTERS)
    --Billing Address
    local streetBillingTextbox = Textbox(1140, 840, 1750-1140)
    local cityBillingTextbox = Textbox(1140, 900, 1540-1150)
    local stateBillingTextbox = Textbox(1540, 900, TWO_CHARACTERS)
    local zipBillingTextbox = Textbox(1620, 900, 1760-1630)

    local background = {
        back, junkInDaTrunk, verticalDividerLeft, verticalDividerRight,
        verticalDividerCenter, horizontalDividerLeft, horizontalDividerRight,
        orderText, detailsText, passwordText, driverInstructionsTextbox.group, passwordTextbox.group, formGroup,
        enterPaymentText, firstNameTextbox.group, lastNameTextbox.group, emailNameTextbox.group,
        emailAtTextbox.group, atSymbolText, nameText, phoneText, emailText, phoneTextbox1.group,
        phoneTextbox2.group, phoneTextbox3.group, phoneTextbox4.group, extText, cash, masterCard,
        visaCard, americanExpressCard, discoverCard, cardTextbox1.group, cardTextbox2.group,
        cardTextbox3.group, cardTextbox4.group, cardNumberText, expirationMonthTextbox.group, expirationYearTextbox.group, expirationText,
        secretCodeTextbox.group, secretCodeText, streetBillingTextbox.group, cityBillingTextbox.group, stateBillingTextbox.group, zipBillingTextbox.group, driverInstructionsText,
        editOrderText, addCouponText, taxText, totalCostText,
        currentCart
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
    view.moving_ui=Group{name="checkoutMoving_ui", position={0,0}}
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
    function view:refresh_cart()
        print("refreshing cart on checkout screen, cart has "
               ..#model.cart.." item(s)")
        --if nil ~= #view.cart_items then
            for i=1,#view.cart_items do
                view.cart_items[i]:unparent()
            end
        --end
        view.cart_items = {}
        local next_y = 60
        local cart_index = 1
        while cart_index <= #model.cart and
              next_y <= EDIT_ORDER_Y do
            print("adding "..model.cart[cart_index].Name.." from cart to screen")
            view.cart_items[#view.cart_items+1] = Text{
                position = {200,next_y},
                font = CUSTOMIZE_SUB_FONT,
                color = Colors.BLACK,
                text = model.cart[cart_index].CheckOutDesc()
            }
            next_y = next_y +120 -- + model.cart[cart_index].Desc_height
            cart_index = cart_index+1
        end
        view.ui:add(unpack(view.cart_items))
    end
    
    local prev_selection = {}
    for i = 1, #view.items do
        prev_selection[i] = 1
    end

    function view:update()
        local controller = self:get_controller()
        local comp = self.model:get_active_component()
        if comp == Components.CHECKOUT then
            self.footer_ui.opacity = 255
            self.moving_ui:animate{duration=CHANGE_VIEW_TIME, position=SHOW_POSITION}
            print("Showing Checkout UI")
            for i,c_view in ipairs(view.items) do
                if i == controller:get_selected_index() then
                    c_view.ui:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                    self:get_controller().child = c_view:get_controller()
                    assert(self:get_controller().child)
                else
                    c_view.ui:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                    prev_selection[i] = c_view:get_controller():get_selected_index()
                end
            end
        else
            print("Hiding Checkout UI")
            self.ui:complete_animation()
            self.footer_ui.opacity = 0
            self.moving_ui:animate{duration=CHANGE_VIEW_TIME, position=HIDE_POSITION}
            --self.ui.opacity = 0
        end
    end

end)
