Components = {
    COMPONENTS_FIRST = 1,
    GAME = 1,
    MENU = 2,
    NO_MOVES_DIALOG = 3,
    AUTO_COMPLETE_DIALOG = 4,
    HELP = 5,
    COMPONENTS_LAST = 5
}

Events = {
    KEYBOARD = 1,
    TIMER = 2,
    NOTIFY = 3
}

dofile("DoFiles.lua")

-- Router initialization
local router = Router()

-- View/Controller initialization

--[[
    All key presses are encapsulated into an event an passed to the router for
    delegation.
--]]
local event_listener_en = true
master_event_listener_en = true

function event_listener_enabled()
    return event_listener_en and master_event_listener_en
end

function screen:on_key_down(k)
    if k == keys.g then dumptable(_G) end
    if k == keys.c and Cards then 
        for i,card in ipairs(Cards) do
            print("card rank", card.rank.num)
            print("card suit", card.suit.name)
            dumptable(card.group.position)
        end
    end
    if event_listener_enabled() then
        router:delegate( KbdEvent({key = k}), {router:get_active_component()} )
    end
end

local old_on_key_down
-- private (helper) functions
function disable_event_listeners()
    -- if screen.on_key_down then
    --    old_on_key_down, screen.on_key_down = screen.on_key_down, nil
    -- end
    t:disable()
    event_listener_en = false
end

function enable_event_listeners()
--    t:enable()
    event_listener_en = true
end

function enable_event_listener(event)
    assert(event:is_a(Event))
    if event:is_a(KbdEvent) then
        --print("enable_event_listener(KbdEvent())")
        if old_on_key_down then
            screen.on_key_down, old_on_key_down = old_on_key_down, nil
        end
    elseif event:is_a(TimerEvent) then
        --print("enable_event_listener(TimerEvent{interval=" .. event.interval .. "})")
        local cb = event.cb or
        function()
            game:on_event(event)
        end
        t:enable{
            on_timer=cb,
            interval=event.interval
        }
    end
    event_listener_en = true
end


GridPositions = {}
for i = 1,7 do
    GridPositions[i] = {}
    GridPositions[i][1] = {1920/8*i, 200, 0}
    GridPositions[i][2] = {1920/8*i, 505, 0}
end

gameloop = GameLoop()

splash_screen = Image{
    src = "assets/splash-solitaire.jpg"
}
screen:add(splash_screen)
screen:show()
local splash_timer = Timer()
splash_timer.interval = 1000
function splash_timer:on_timer()
    splash_timer:stop()

    game = GameControl(router, Components.GAME)
    menu_view = MenuView(router)
    menu_view:initialize()
    no_moves_dialog = DialogBox("Sorry, no more available moves.",
        Components.NO_MOVES_DIALOG, router)
    auto_complete_dialog = DialogBox("You've Won!", Components.AUTO_COMPLETE_DIALOG,
        router, "Auto complete remaining cards?") 
    splash_screen:raise_to_top()
    --[[
    local help = HelpScreen(router)
    router:start_app(Components.HELP)
    --]]
    router:start_app(Components.GAME)
end
splash_timer:start()
