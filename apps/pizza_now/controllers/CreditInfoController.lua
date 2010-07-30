CreditInfoController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.CHECKOUT, parent)

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
    local DriverSub = {}
    local PasswordSub = {}
    local NameSub = {
        FIRST = 1,
        LAST = 2
    }
    local PhoneSub = {
        AREA_CODE = 1,
        FIRST = 2,
        LAST = 3,
        EXT = 4
    }
    local EmailSub = {
        ALIAS = 1,
        AT = 2
    }
    local CardTypeSub = {}
    local CardNumberSub{
        FIRST = 1,
        SECOND = 2,
        THIRD = 3,
        FORTH = 4
    }
    local CardExpirationSub{
        MONTH = 1,
        YEAR = 2
    }
    local CardCodeSub = {}
    local SubSelections = {
        DriverSub, PasswordSub, NameSub, PhoneSub, EmailSub, CardTypeSub,
        CardNumberSub, CardExpirationSub
    }

    local InfoSize = 0
    for k, v in pairs(Info) do
        InfoSize = InfoSize + 1
    end

    -- the default selected index
    local selected = 1
    local sub_selection = 1

    local CreditCallbacks = {
        [Info.DRIVER_INSTRUCTIONS] = function(self)
            print("driver instructions selected")
        end,
        [Info.PASSWORD] = function(self)
            print("password input selected")
        end,
        [Info.NAME] = function(self)
            print("name entry")
            if(NameSub.FIRST == sub_selection) then
                --first name
            elseif(NameSub.LAST == sub_selection) then
                --last name
            end
        end,
        [Info.PHONE] = function(self)
            print("phone number entry")
            if(PhoneSub.AREA_CODE == sub_selection) then
                --enter area code
            elseif(PhoneSub.FIRST == sub_selection) then
                --enter first 3 digits of phone number
            elseif(PhoneSub.LAST == sub_selection) then
                --enter last 4 digits of phone number
            elseif(PhoneSub.EXT == sub_selection) then
                --enter extension
            else
                error("error selecting phone entry")
            end
        end,
        [Info.EMAIL] = function(self)
            print("email entry")
            if(EmailSub.ALIAS == sub_selection) then
                --enter alias
            elseif(EmailSub.AT == sub_selection) then
                --enter @
            else
                error("error selecting email entry")
            end
        end,
        [Info.CARD_TYPE] = function(self)
            print("card type selected")
        end,
        [Info.CARD_NUMBER] = function(self)
            print("card number entry")
            if(CardNumberSub.FIRST == sub_selection) then
                --enter first 4 digits of phone number
            elseif(CardNumberSub.SECOND == sub_selection) then
                --enter second 4 digits of phone number
            elseif(CardNumberSub.THIRD == sub_selection) then
                --enter third 4 digits of phone number
            elseif(CardNubmerSub.FORTH == sub_selection) then
                --enter forth 4 digits of phone number
            else
                error("error selecting card entry")
            end
        end,
        [Info.CARD_EXPIRATION] = function(self)
            print("card expiration entry")
            if(CardExpirationSub.MONTH == sub_selection) then
                --enter expiration month
            elseif(CardExpirationSub.YEAR == sub_selection) then
                --enter expiration year
            else
                error("error selecting card expiration entry")
            end
        end,
        [Info.CARD_CODE] = function(self)
            print("delivery or pickup selected")
        end,
    }

    local CreditInputKeyTable = {
        [keys.Left] = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Up] = function(self) self:move_selector(Directions.UP) end,
        [keys.Down] = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Return] =
        function(self)
            -- compromise so that there's not a full-on lua panic,
            -- but the error message still displays on screen
            local success, error_msg = pcall(CreditCallbacks[selected], self)
            if not success then print(error_msg) end
        end
    }

    function self:on_key_down(k)
        if CreditInputKeyTable[k] then
            CreditInputKeyTable[k](self)
        end
    end

    function self:get_selected_index()
        return selected
    end

    function self:move_selector(dir)
        if(0 ~= dir[2]) then
            local new_selected = selected + dir[2]
            if 1 <= new_selected and new_selected <= InfoSize then
                selected = new_selected
                sub_selection = 1
            end
        elseif(0 ~= dir[1]) then
            local new_selected = sub_selection + dir[1]
            local subs = 0
            assert(SubSelections[selected])
            for k,v in pairs(SubSelections[selected]) do
                subs = subs + 1
            end
            if(1 <= new_selected and new_selected <= subs) then
                sub_selection = new_selected
            end
        else
            error("something eff'd up")
        end
        self:get_model():notify()
    end

    function self:run_callback()
        local success, error_msg = pcall(CreditCallbacks[selected], self)
        if not success then print(error_msg) end
    end

end)
