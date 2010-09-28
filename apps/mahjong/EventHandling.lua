--[[
    All key presses are encapsulated into an event and passed to the router for
    delegation.
--]]
local event_listener_en = true
function screen:on_key_down(k)
    if k == keys.g then dumptable(_G) end
    if event_listener_en then
        router:delegate(KbdEvent({key = k}), {router:get_active_component()})
    end
end

function disable_event_listeners()
    t:disable()
    event_listner_en = false
end

function enable_event_listeners()
    -- t:enable()
    event_listener_en = true
end

local old_on_key_down = nil
function enable_event_listener(event)
    if not event then error("needs an event type", 2) end
    if not event:is_a(Event) then error("event must be of Class Event", 2) end

    if event:is_a(KbdEvent) then
        screen.on_key_down, old_on_key_down = old_on_key_down, nil
    elseif event:is_a(TimerEvent) then
        local cb = event.cb or
            function()
                game:on_event(event)
            end
        t:enable{on_timer = cb, interval = event.interval}
    end
    event_listener_en = true
end

function event_listener_enabled()
    return event_listener_en
end
