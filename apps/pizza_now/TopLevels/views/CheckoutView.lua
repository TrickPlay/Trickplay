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
    passwordForm = Form(1460, 260, 1740-1460)
    --[[
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
    --]]
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
        width = 1410-1330,
        tile = {true, false}
    }
    local phoneFormRight3 = Image{
        position = {1400-1310, 0},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    phoneGroup3:add(phoneFormLeft3, phoneFormCenter3, phoneFormRight3)
    local extText = Text{
        position = {1430, 475},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "x"
    }
    local phoneGroup4 = Clone{source = phoneGroup}
    phoneGroup4.position = {1460, 460}

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
    --card number entry forms
    local cardGroup1 = Clone{source = phoneGroup3}
    cardGroup1.position = {1140, 720}
    local cardGroup2 = Clone{source = phoneGroup3}
    cardGroup2.position = {1250, 720}
    local cardGroup3 = Clone{source = phoneGroup3}
    cardGroup3.position = {1360, 720}
    local cardGroup4 = Clone{source = phoneGroup3}
    cardGroup4.position = {1470, 720}
    local cardNumberText = Text{
        position = {1000,740},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Card #"
    }
    local expirationGroup = Group{position = {1140, 780}}
    local expirationMonthForm = Group()
    local expirationMonthFormLeft = Image{
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeft.png",
    }
    local expirationMonthFormCenter = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = 1200-1140,
        tile = {true, false}
    }
    local expirationMonthFormRight = Image{
        position = {1210-1140, 0},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    expirationMonthForm:add(expirationMonthFormLeft, expirationMonthFormCenter,
        expirationMonthFormRight)
    local expirationYearForm = Clone{source = phoneGroup3}
    expirationYearForm.position = {1210-1120, 0}
    expirationGroup:add(expirationMonthForm, expirationYearForm)
    local expirationText = Text{
        position = {1000,800},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Expires",
    }
    local secretCodeGroup = Clone{source = phoneGroup}
    secretCodeGroup.position = {1490, 780}
    local secretCodeText = Text{
        position = {1400,800},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "CVC",
    }
    --Billing Address
    local addressBillingGroup = Group{position = {1140,840}}
    local streetBillingForm = Group()
    local streetBillingFormLeft = Image{
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeft.png",
    }
    local streetBillingFormCenter = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = 1740-1150,
        tile = {true, false}
    }
    local streetBillingFormRight = Image{
        position = {1740-1140, 0},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    streetBillingForm:add(streetBillingFormLeft, streetBillingFormCenter, streetBillingFormRight)
    local cityBillingForm = Group{position = {0, 900-840}}
    local cityBillingFormLeft = Image{
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeft.png",
    }
    local cityBillingFormCenter = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = 1510-1150,
        tile = {true, false}
    }
    local cityBillingFormRight = Image{
        position = {1510-1140, 0},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    cityBillingForm:add(cityBillingFormLeft, cityBillingFormCenter, cityBillingFormRight)
    local stateBillingForm = Clone{source = expirationMonthForm}
    stateBillingForm.position = {1530-1140, 900-840}
    local zipBillingForm = Group{position = {1620-1140, 900-840}}
    local zipBillingFormLeft = Image{
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeft.png",
    }
    local zipBillingFormCenter = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = 1740-1630,
        tile = {true, false}
    }
    local zipBillingFormRight = Image{
        position = {1740-1620, 0},
        src = "assets/credit_stuff/TextBoxRight.png",
    }
    zipBillingForm:add(zipBillingFormLeft, zipBillingFormCenter, zipBillingFormRight)
    addressBillingGroup:add(streetBillingForm, cityBillingForm, stateBillingForm, zipBillingForm)
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
--[[
    local next_y = 160
    local cart_index = 1
    while model.cart[cart_index] ~= nil and
          next_y > editOrder.y do
        cart_items[#cart_items+1] = Text{
            position = {160,next_y},
            font = CUSTOMIZE_TAB_FONT,
            color = Colors.BLACK,
            text = model.cart.Name,--model.cart[cart_index].Description
        }
        next_y = next_y +60 -- + model.cart[cart_index].Desc_height
        cart_index = cart_index+1
    end
--]]
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
    local creditInstructionsText = Text{
        position = {990,990},
        font = CUSTOMIZE_TINY_FONT,
        color = Colors.BLACK,
        text = "Please have your legal photo ID and\ncredit card available for verification.",
    }
    local termsText = Text{
        position = {20, 990},
        font = CUSTOMIZE_TINY_FONT,
        color = Colors.BLACK,
        text = "By ordering, I implicitly agree to the Terms and\nConditions of Domino's Pizza and Pizza Now."
    }
    local background = {
        back, junkInDaTrunk, verticalDividerLeft, verticalDividerRight,
        verticalDividerCenter, horizontalDividerLeft, horizontalDividerRight,
        orderText, detailsText, passwordText, passwordForm.group,
        --passwordFormLeft, passwordFormCenter, passwordFormRight,
        formGroup, enterPaymentText, firstNameGroup,
        lastNameGroup, emailNameGroup, emailAtGroup, atSymbolText, nameText,
        phoneText, emailText, phoneGroup, phoneGroup2, phoneGroup3, extText, phoneGroup4,
        cash, masterCard, visaCard, americanExpressCard, discoverCard, cardGroup1,
        cardGroup2, cardGroup3, cardGroup4, cardNumberText, expirationGroup,
        expirationText, secretCodeGroup, secretCodeText, addressBillingGroup,
        driverInstructionsText, driverInstructionsForm, editOrderText, addCouponText,
        taxText, totalCostText, orderBar, creditInstructionsText, termsText, currentCart
    }
    
    --create the components
    local creditInfoView = CreditInfoView(model, view)
    local finalOrderView = FinalOrderView(model, view)
    local finalFooterView = FinalFooterView(model, view)
    creditInfoView:initialize()
    finalOrderView:initialize()
    finalFooterView:initialize()

    view.items = {finalOrderView, creditInfoView, finalFooterView}

    view.static_ui = Group{name = "checkoutStatic_ui", position = {0, 0}, opacity=255}
    view.static_ui:add(unpack(background))
    view.ui=Group{name="checkout_ui", position={0,0}}
    view.ui:add(view.static_ui)

    view.entry_ui=Group{name="checkoutEntry_ui", position={0,0}}
    for i,v in ipairs(view.items) do
        view.entry_ui:add(v.ui)
    end

    view.ui:add(view.entry_ui)
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
            self.ui.opacity = 255
            self.entry_ui.opacity = 255
            self.entry_ui:raise_to_top()
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
            self.ui.opacity = 0
        end
    end

end)
