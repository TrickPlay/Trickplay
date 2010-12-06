local gutter_sides  = 50
local top_gutter    = 26
local bottom_gutter = 20



Listings = Class(function(self,...)
    
    local group = Group{}
    
    
    do
        --Upper Left
        local logo          = Image{src="assets/logo.png",    x = gutter_sides, y = top_gutter}
        local recents_title = Image{src="assets/recents.png", x = gutter_sides, y = top_gutter+logo.h+10}
        
        --Upper Right
        local options = Image{src="assets/options.png"}
        local back    = Image{src="assets/back.png"}
        local exit    = Image{src=}
        group:add(logo,recents_title)
    end
    --Upper Right
    group:add(
        --Upper Left
        Image{src="assets/logo.png",    x = gutter_sides, y = top_gutter},
        Image{src="assets/recents.png", x = gutter_sides, y = top_gutter+114+10}
        
        
        
    )
    
    Titlecards_Bar = Class(function(self,...)
        local group = Group{x=gutter_sides,y=202}
        local spacing = 15
        
    end)
end)