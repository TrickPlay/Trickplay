--[[
    All key presses are encapsulated into an event and passed to the router for
    delegation.
--]]
local event_listener_en = true
local key_handler = {}
local key_hints = {}
local kbd_en = true
local key_consumer = Timer()
key_consumer.interval = 400
function screen:on_key_down() end
function key_consumer:on_timer()
    key_consumer:stop()
    key_consumer.on_timer = nil
    key_consumer = nil

    function screen:on_key_down(k)
        if k == keys.g then dumptable(_G) end
        if key_handler[k] then
            key_hints[k] = not key_hints[k]
            key_handler[k]()
        end
        if event_listener_en and kbd_en then
            router:delegate(KbdEvent({key = k}), {router:get_active_component()})
        end
    end
end
key_consumer:start()

function enable_kbd() kbd_en = true end
function disable_kbd() kbd_en = false end

function add_to_key_handler(key, func)
    if not key then error("must have a key for key_handler", 2) end
    if not func then error("must have a function for key_handler", 2 ) end
    if type(func) ~= "function" then error("func must be a function", 2) end

    key_handler[key] = func
    key_hints[key] = false
end

function is_key_hint_on(key)
    return key_hints[key]
end

function disable_event_listeners()
    event_listener_en = false
end

function enable_event_listeners()
    event_listener_en = true
end

local old_on_key_down = nil
function enable_event_listener(event)
    if not event then error("needs an event type", 2) end
    if not event:is_a(Event) then error("event must be of Class Event", 2) end

    if event:is_a(KbdEvent) then
        screen.on_key_down, old_on_key_down = old_on_key_down, nil
    end
    event_listener_en = true
end

function event_listener_enabled()
    return event_listener_en
end
