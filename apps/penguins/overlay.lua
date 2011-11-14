overlay = Group{name = "overlay", position = {0,-1200}}
overlay.deaths = Text{font = "Sigmar 68px", x = 160,  y = 568, color = "8bbbe0"}
overlay.level  = Text{font = "Sigmar 68px", x = 350, y = 568, width = 1400, alignment = "CENTER", color = "ffffff"}

overlay:add(penguin)

explode = dofile("explode.lua")

overlay:add(Image{src = "assets/igloo-front.png", y = 134},overlay.deaths,overlay.level)

screen:add(overlay)
overlay.clone = _Clone{source = overlay, name = "overclone"}