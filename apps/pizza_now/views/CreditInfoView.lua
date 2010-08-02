CreditInfoView = Class(View, function(view, model, parent_view, ...)
    view._base.init(view, model)

    view.parent_view = parent_view
    
    local Info = {
        DRIVER_INSTRUCTIONS = 1,
        PASSWORD = 2,
        NAME = 3,
        PHONE = 4,
        EMAIL = 5,
        CARD_TYPE = 6,
        CARD_NUMBER = 7,
        CARD_EXPIRATION = 8,
        CARD_CODE = 9
    }

    --entry for instructions for the driver
    local driverInstructionsEntry = Text{
        position = {1030, 135},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Anything you want to tell the driver?",
        max_length = 40,
        wants_enter = false
    }
    local driverInstructionsTable = {driverInstructionsEntry}
    --password entry place
    local passwordEntry = Text{
        position = {1475, 280},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Password?",
        max_length = 20,
        wants_enter = false
    }
    local passwordTable = {passwordEntry}
    --name entry places
    local firstName = Text{
        position = {1150, 415},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "First",
        max_length = 15,
        wants_enter = false
    }
    local lastName = Text{
        position = {1450, 415},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "Last",
        max_length = 15,
        wants_enter = false
    }
    local nameTable = {firstName, lastName}
    --phone entry places
    local areaCode = Text{
        position = {1150, 475},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "###",
        max_length = 3,
        wants_enter = false
    }
    local firstThreeDigits = Text{
        position = {1240, 475},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "###",
        max_length = 3,
        wants_enter = false
    }
    local lastFourDigits = Text{
        position = {1330, 475},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "####"
    }
    local extension = Text{
        position = {1470, 480},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "###",
        max_lengt = 3,
        wants_enter = false
    }
    local phoneTable = {areaCode, firstThreeDigits, lastFourDigits, extension}
    --email entry stuff
    local emailHandle = Text{
        position = {1150, 535},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "email",
        max_length = 20,
        wants_enter = false
    }
    local emailAt = Text{
        position = {1470, 535},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "trickplay.com",
        max_length = 20,
        wants_enter = false
    }
    local emailTable = {emailHandle, emailAt}
    --credit type
    local dottedSquare1 = Image{
        src = "assets/credit_stuff/PaymentHighlight.png",
        position = {990,600}
    }
    local dottedSquare2 = Clone{source = dottedSquare1}
    dottedSquare2.position = {1140, 600}
    local dottedSquare3 = Clone{source = dottedSquare1}
    dottedSquare3.position = {1300, 600}
    local dottedSquare4 = Clone{source = dottedSquare1}
    dottedSquare4.position = {1450, 600}
    local dottedSquare5 = Clone{source = dottedSquare1}
    dottedSquare5.position = {1590, 600}
    local dottedSquareTable = {
        dottedSquare1, dottedSquare2, dottedSquare3, dottedSquare4, dottedSquare5
    }
    --credit number
    local credit1 = Text{
        position = {1150, 775},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "####",
        max_length = 4,
        wants_enter = false
    }
    local credit2 = Text{
        position = {1260, 775},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "####",
        max_length = 4,
        wants_enter = false
    }
    local credit3 = Text{
        position = {1370, 775},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "####",
        max_length = 4,
        wants_enter = false
    }
    local credit4 = Text{
        position = {1480, 775},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "####",
        max_length = 4,
        wants_enter = false

    }
    local creditTable = {credit1, credit2, credit3, credit4}
    --expiration date
    local expMonth = Text{
        position = {1150, 835},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "MM",
        max_length = 2,
        wants_enter = false
    }
    local expYear = Text{
        position = {1240, 835},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "YYYY",
        max_length = 4,
        wants_enter = 2
    }
    local expirationTable = {expMonth, expYear}
    --card code junk
    local cardCode = Text{
        position = {1150, 895},
        font = CUSTOMIZE_SUB_FONT,
        color = Colors.BLACK,
        text = "###",
        max_length = 3,
        wants_enter = false
    }
    local cardCodeTable = {cardCode}

    view.info = {
        driverInstructionsTable, passwordTable, nameTable, phoneTable, emailTable,
        dottedSquareTable, creditTable, expirationTable, cardCodeTable
    }
    view.ui = Group{name="creditInfo_ui", position={0, 0}, opacity=255}
    for i,table in ipairs(view.info) do
        view.ui:add(unpack(table))
    end
    view.ui:raise_to_top()

    function view:initialize()
        self:set_controller(CreditInfoController(self))
    end

    function view:update()
        local controller = self:get_controller()
        local comp = model:get_active_component()
        if comp == Components.CHECKOUT then
            assert(controller:get_selected_index())
            assert(controller:get_sub_selection_index())
            print("Showing CreditInfoView UI")
            for i,table in ipairs(self.info) do
                for j,item in ipairs(view.info[i]) do
                    if(i == controller:get_selected_index()) and 
                      (j == controller:get_sub_selection_index()) then
                        item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                    elseif(Info.CARD_TYPE == i) then
                        if(model:selected_card() == j) then
                            item:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                        else
                            item:animate{duration=CHANGE_VIEW_TIME, opacity=0}
                        end
                    else
                        item:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                    end
                end
            end
        else
            print("Hiding CreditInfoView UI")
            self.ui:complete_animation()
            self.ui.opacity = 0
        end
    end

end)
