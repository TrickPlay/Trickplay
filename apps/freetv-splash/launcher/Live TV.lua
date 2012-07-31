local channel_data = {
    [2] = {
                channel = "Fox",
                show = "The Big Bang Theory",
                hd = true,
            },
    [3] = {
                channel = "NBC",
                show = "Access Hollywood",
                hd = true,
            },
    [4] = {
                channel = "myTV",
                show = "The Insider",
                hd = false,
            },
    [5] = {
                channel = "CBS",
                show = "Eye on the Bay",
                hd = false,
            },
    [6] = {
                channel = "KICU",
                show = "Bay Area News",
                hd = false,
            },
    [7] = {
                channel = "ABC",
                show = "Jeopardy!",
                hd = false,
            },
    [9] = {
                channel = "PBS",
                show = "Nightly Business Report",
                hd = false,
            },
    [12] = {
                channel = "CW",
                show = "Two and a Half Men",
                hd = true,
            },
    [34] = {
                channel = "Food",
                show = "Cupcake Wars",
                hd = true,
            },
    [35] = {
                channel = "TBS",
                show = "Seinfeld",
                hd = false,
            },
    [36] = {
                channel = "FX",
                show = "Two and a Half Men",
                hd = true,
            },
    [37] = {
                channel = "TNT",
                show = "Rizzoli & Isles",
                hd = true,
            },
    [38] = {
                channel = "ESPN",
                show = "Baseball Tonight",
                hd = true,
            },
    [42] = {
                channel = "USA",
                show = "Law & Order: Special Victims Unit",
                hd = true,
            },
    [47] = {
                channel = "A&E",
                show = "Mad Men",
                hd = true,
            },
}


local function on_activate(label)
    label:animate({ duration = 250, opacity = 255 })
    print("Live TV on")
end

local function on_deactivate(label, new_active)
    label:animate({ duration = 250, opacity = 128, on_completed = function() if(new_active) then new_active:activate() end end } )
    print("Live TV off")
end

local function on_wake(label)
end

local function on_sleep(label)
end

local function on_key_down(label, key)
end

return {
            label = "Live TV",
            activate = on_activate,
            deactivate = on_deactivate,
            wake = on_wake,
            sleep = on_sleep,
            on_key_down = on_key_down,
        }
