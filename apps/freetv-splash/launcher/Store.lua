local function on_activate(label)
    label:animate({ duration = 250, opacity = 255 })
end

local function on_deactivate(label, new_active)
    label:animate({ duration = 250, opacity = 128, on_completed = function() if(new_active) then new_active:activate() end end } )
end

local function on_wake(label)
end

local function on_sleep(label)
end

local function on_key_down(label, key)
    if( keys.OK == key ) then
        settings.back_to_start = "Store"
        apps:launch("com.trickplay.app-shop")
    end
end

return {
            label = "Store",
            activate = on_activate,
            deactivate = on_deactivate,
            wake = on_wake,
            sleep = on_sleep,
            on_key_down = on_key_down,
        }
