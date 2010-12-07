
--all hardcoded numbers are from the spec
local gutter_sides        = 50
local top_gutter          = 26
local bottom_gutter       = 20
local title_card_h        = 180
local title_card_w        = 352
local title_card_y        = 202
local title_card_spacing  = 15
local bottom_containers_y = title_card_y + title_card_h + 33


local TV_Station_Font  = "Helvetica bold 24px"
local TV_Station_Color = "#FFFFFF"
local Show_Time_Font   = "Helvetica 24px"
local Show_Time_Color  = "#a6a6a6"



local fp_group = Group{}
screen:add(fp_group)



--Load in the stationary assets for the Front Page
--using a do-end to toss the locals once they're loaded
do
    --Upper Left
    local logo          = Image{src="assets/logo.png",    x = gutter_sides,
                                                          y = top_gutter}

    title_card_y = logo.y + logo.h+10
    --Upper Right
    local up_r_spacing = 16
    local up_r_top_gutter = 16

    local options = Image{ src="assets/options.png", y = up_r_top_gutter }
    local back    = Image{ src="assets/back.png",    y = up_r_top_gutter }
    local exit    = Image{ src="assets/exit.png",    y = up_r_top_gutter }
        
    exit.x    = screen_w - gutter_sides - exit.w
    back.x    = exit.x   - up_r_spacing - back.w
    options.x = back.x   - up_r_spacing - options.w
    
    fp_group:add(logo, recents_title, options, back, exit)
end




--Container for the Title Cards
Titlecards_Bar = Class(function(self,parent,...)
    local group   = Group{x=gutter_sides, y = title_card_y}
    local title   = Image{src="assets/recents.png"}
    local tiles   = Group{y = 21+title.h}
    group:add(title,tiles)
    fp_group:add(group)
    local max_on_screen = 5
    
    local bar_items = {}
    local imgs      = {}
    
    --need to init the bar_items here
    function self:add(show_obj)
        
        tiles:add(Image{
            src = show_obj.title_card,
            x   = #bar_items*(title_card_w+title_card_spacing)
        })
        table.insert(bar_items,show_obj)
    end
    
end)

--Container for the Listings
Listings = Class(function(self,...)
    
    local group = Group
    {
        x = gutter_sides,
        y = bottom_containers_y
    }
    local title    = Image{src="assets/listings.png"}
    local bg_unsel = Image{src="assets/listing_bg.png",       y = title.h+5}
    local bg_sel   = Image{src="assets/listing_bg_focus.png", y = title.h+5,opacity=0}
    
    local focus = Image{src="assets/listing_focus.png",opacity=0}
    
    local Show_Name_Font  = "Helvetica bold 26px"
    local Show_Name_Color = "#FFFFFF"
    local listing_h       = 69

    local listings = {}
    local listings_g = Group
    {
        y    = bg_unsel.y+23,
        clip = { 15, 0,  bg_sel.w-30, bg_sel.h-23*2}
    }
    local listing_top_rule    = Image{src="assets/object_listings_top_rule.png",y=bg_unsel.y+23}
    local listing_bottom_rule = Image{src="assets/object_listings_bottom_rule.png"}
    listing_bottom_rule.y = bg_unsel.y+bg_unsel.h -23 - listing_bottom_rule.h
    listings_g:add(focus)
    
    group:add(
        --bg_sel,
        --bg_unsel,
        title,
        --listings_g,
        listing_top_rule,
        listing_bottom_rule
    )
    listing_bottom_rule:raise_to_top()
    
    fp_group:add(group)
    ----------------------------------------------------------------------------
    
    local menu_i = 1
    
    function self:add(show_obj)
        
        local index = #listings + 1
        local show_name = Text
                {
                    text  = show_obj.show_name,
                    font  = Show_Name_Font,
                    color = Show_Name_Color,
                    x     = 15,
                    y     = listing_h*(index-.5)
                }
                show_name.anchor_point={
                    0,--show_name.w/2,
                    show_name.h/2
                }
        local show_time = Text
                {
                    text  = show_obj.show_time,
                    font  = Show_Time_Font,
                    color = Show_Time_Color,
                    x     = 378,
                    y     = listing_h*(index-.5)
                }
                show_time.anchor_point={
                    0,--show_time.w/2,
                    show_time.h/2
                }
        local tv_station = Text
                {
                    text  = show_obj.tv_station,
                    font  = TV_Station_Font,
                    color = TV_Station_Color,
                    x     = 593,
                    y     = listing_h*(index-.5)
                }
                tv_station.anchor_point={
                    0,--tv_station.w/2,
                    tv_station.h/2
                }
        
        
        table.insert(listings,
            {
                obj        = show_obj,
                show_name  = show_name,
                show_time  = show_time,
                tv_station = tv_station
            }
        )
        
        listings_g:add(show_name, show_time, tv_station)
        
    end
    
    
    function self:receive_focus()
        bg_sel.opacity   = 255
        bg_unsel.opacity = 0
        
        if #listings > 0 then
            focus.opacity=255
            --menu_i = 1
            listing[1].show_name.color  = "#000000"
            listing[1].show_time.color  = "#000000"
            listing[1].tv_station.color = "#000000"
        end
    end
    function self:receive_focus()
        bg_sel.opacity   = 0
        bg_unsel.opacity = 255
        
        if #listings > 0 then
            focus.opacity=0
            --menu_i = 1
            listing[1].show_name.color  = "#FFFFFF"
            listing[1].show_time.color  = "#FFFFFF"
            listing[1].tv_station.color = "#FFFFFF"
        end
    end
end)

--Container for the TweetStream
TweetStream = Class(function(self,...)
    
    local group = Group
    {
        x = gutter_sides + 2*title_card_w + 2*title_card_spacing,
        y = bottom_containers_y
    }
    local title   = Image{src="assets/listings.png"}
    
    local Show_Name_Font  = "Helvetica bold 40px"
    local Show_Name_Color = "#FFFFFF"
    local Sub_Title_Font  = Show_Time_Font
    local Sub_Title_Color = Show_Time_Color
    local tweets = {}
    
    
end)

fp={
    title_card_bar     = Titlecards_Bar(),
    listings_container = Listings()
}
