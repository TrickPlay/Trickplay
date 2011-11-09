local overlay = Group{name = "overlay", position = {0,-1200}}
overlay.deaths = Text{font = "Sigmar 68px", x = 24,  y = 569, color = "FFFFFF"}
overlay.level  = Text{font = "Sigmar 68px", x = 600, y = 569, color = "FFFFFF"}

overlay:add(penguin,Image{src = "assets/igloo-front.png", y = 134},overlay.deaths,overlay.level)

screen:add(overlay)
overlay.clone = _Clone{source = overlay, name = "overclone"}
    
return overlay