local function on_activate(label)
    label:animate({ duration = 250, opacity = 255 })
    print("Store on")
end

local function on_deactivate(label, new_active)
    label:animate({ duration = 250, opacity = 128, on_completed = function() if(new_active) then new_active:activate() end end } )
    print("Store off")
end

local function on_wake(label)
end

local function on_sleep(label)
end

return {
            label = "Store",
            activate = on_activate,
            deactivate = on_deactivate,
            wake = on_wake,
            sleep = on_sleep,
        }
