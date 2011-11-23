local overlay = Group{name = "overlay", position = {0,-1200}}
overlay.deaths = Text{font = "Sigmar 68px", x = 240,  y = 568, color = "8bbbe0", text = "0"}
overlay.level  = Text{font = "Sigmar 68px", x = 350, y = 568, width = 1400, alignment = "CENTER", color = "ffffff"}

overlay:add(penguin,Image{src = "assets/igloo-front.png", y = 134},Image{src = "assets/death-bug.png", x = 150, y = 591},overlay.deaths,overlay.level)
screen:add(overlay)
overlay.clone = _Clone{source = overlay, name = "overclone"}

return overlay