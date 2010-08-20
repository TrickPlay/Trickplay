 -- constructor, called with Model(...)
Model = Class(function(model, ...)
    -- (private) class fields
    model.registry = {}
    model.controllers = {}
    model.active_component = nil

    --a table of all the current players
    model.players = { }
    --used so no two players can have the same position on the table
    model.positions = {}

    SCREEN_WIDTH = screen.w
    SCREEN_HEIGHT = screen.h
    model.default_player_locations = {
        [1] = {320, 950},
        [2] = {0, 99},
        [3] = {310, 20},
        [4] = {1281, 20},
        [5] = {1590, 99},
        [6] = {1331, 950},
        START = {730, 880},
        EXIT_MENU = {890, 880},
        HELP_MENU = {1050, 880},

        FOLD = {740, 780},
        EXIT = {750, 870},
        HELP = {910, 870},
        CALL = {870, 780},
        BET = {1020, 780},
        UP = {1090, 770},
        DOWN = {1090, 850}
    }
    MDPL = model.default_player_locations
    
    model.default_bet_locations = {
        [1] = {200, 600},
        [2] = {550, 350},
        [3] = {1400, 350},
        [4] = {1720, 600},
        [5] = {550, 850},
        [6] = {1400, 850},
        POT = {925, 680}
    }
    mdbl = model.default_bet_locations
    
    model.card_locations = {
        [1] = {726, 510},
        [2] = {843, 510},
        [3] = {966, 510},
        [4] = {1084, 510},
        [5] = {1205, 510},
        DECK = {785, 650},
        BURN = {1145, 650}
    }
    MCL = model.card_locations
    
    model.player_card_locations = {
        [1] = {347, 759},
        [2] = {70, 381},
        [3] = {454, 159},
        [4] = {1414, 189},
        [5] = {1726, 409},
        [6] = {1452, 760}
    }
    MPCL = model.player_card_locations
    for i=1, #MPCL do
        MPCL[i][1] = MPCL[i][1] + 45
        MPCL[i][2] = MPCL[i][2] + 60
    end
    
    model.status_chip_locations = {
        [1] = {500, 820},
        [2] = {320, 520},
        [3] = {700, 310},
        [4] = {1185, 310},
        [5] = {1550, 520},
        [6] = {1290, 820},
    }
    MSCL = model.status_chip_locations
    
    model.currentPlayer = nil
    
    model.bet = {
        SMALL_BLIND = 1,
        BIG_BLIND = 2,
        DEFAULT_BET = 2,
        --CURRENT_POT = 0,
    }

    -- class methods
    function model:attach(observer, controller_id)
        self.registry[observer] = true
        if controller_id then
            self.controllers[controller_id] = observer
        end
    end

    function model:detach(observer)
        self.registry[observer] = nil
    end

    function model:notify()
        for observer, bool in pairs(self.registry) do
            observer:update()
        end
    end

    function model:get_controller(comp)
        if self.controllers[comp] then
            return self.controllers[comp]
        else
            error("component doesn't exist.")
        end
    end

    function model:get_active_controller()
       assert(self.controllers[self.active_component])
       return self.controllers[self.active_component]
    end

    function model:get_active_component()
        return self.active_component
    end

    function model:start_app(comp)
        self.active_component = comp
        screen:show()
        self:notify()
    end
    
    function model:set_active_component(comp)
       if type(comp) ~= "number" then
          error("Component " .. tostring(comp) .. " is not a number", 2)
       elseif comp < Components.COMPONENTS_FIRST or Components.COMPONENTS_LAST < comp then
          error("Component " .. comp .. " does not exist", 2)
       end
       self.previous_component = self.active_component
       self.active_component = comp
       print("set active component to",comp)
    end

    function model:set_keys()
        function screen:on_key_down(k)
            assert(model:get_active_controller())
        end
    end

end)




Observer = Class(function(observer, ...)
    -- class fields

    -- class methods
    function observer:update()
        error("Update not defined for observer") 
    end

end)

View = Class(Observer, function(view, model, ...)
    -- COMMON VIEW LOGIC

    -- (private) class fields
    view.model = model
    view.controller = nil
    model:attach(view)

    -- class methods
    function view:initialize()
        error("Initializing empty controller", 2)
        self.controller = Controller(self)
    end

    function view:get_model()
        return view.model
    end

    function view:set_controller(cont)
        self.controller = cont
        self.set_controller = nil
    end

    function view:get_controller()
        return self.controller
    end

    function view:update()
        error("not implemented")
    end
    -- END COMMON VIEW LOGIC

end)

Controller = Class(Observer, function(controller, view, controller_id)
    assert(controller_id)

    -- class fields
    controller.model = view:get_model()
    controller.view = view
    controller.model:attach(controller, controller_id)

    function controller:update()
    end

    function controller:get_model()
        return self.model
    end

    function controller:get_view()
        return self.view
    end

    function controller:run_callback()
        error("run_callback() not defined for controller")
    end

    function controller:on_focus()
        error("self:on_focus() not defined for controller", 2)
    end
    
    function controller:out_focus()
        error("self:out_focus() not defined for controller")
    end

end)
