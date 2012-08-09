local function on_activate(label)
    label:animate({ duration = 250, opacity = 255 })
end

local function on_deactivate(label, new_active)
    label:animate({ duration = 250, opacity = 128, on_completed = function() if(new_active) then new_active:activate() end end } )
end

local function on_wake(label)
    -- Since search is not implemented, use this as a cheat shortcut to resetting the service
    settings.back_to_start = nil
    settings.service = nil
    exit()
end

local function on_sleep(label)
end

local function on_key_down(label, key)
end

return {
            label = "Search",
            activate = on_activate,
            deactivate = on_deactivate,
            wake = on_wake,
            sleep = on_sleep,
            on_key_down = on_key_down,
        }
