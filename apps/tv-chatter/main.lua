--store globals of the screens height and width
screen_w = screen.w
screen_h = screen.h
--show the screen
screen:show()



--recreate their gradient background using Canvas



--Global Text info
TV_Station_Font  = "Helvetica bold 24px"
TV_Station_Color = "#FFFFFF"
Show_Time_Font   = "Helvetica 24px"
Show_Time_Color  = "#a6a6a6"
Username_Font    = "Helvetica bold 26px"
Username_Color   = "#b1ff0a"
User_text_Font   = "Helvetica 26px"
User_text_Color  = "#ffffff"
Time_Font   = "Helvetica 24px"
Time_Color  = "#a6a6a6"

dofile("Canvas_Elements.lua") --Contains functions for creating Canvas peices
dofile("Class.lua")     --Defines the 'Class' data structure
dofile("Objects.lua")   --Defines 'ShowObject'
dofile("Frontpage.lua") --Layout and key handler for the front page
dofile("TweetStream.lua")
dofile("Showpage.lua")
dofile("Minipage.lua")








--make Show_objects, hard coded for now
tv_show = {}
--ShowObject = Class(function(self,
--                        title_card,  
--                        show_name ,  
--                        sub_title ,  
--                        tv_station,  
--                        show_time ,  
--                        add_image ,
--                        ...
--                )
tv_show[1] = ShowObject(
        "assets/titlecards/tile_community.png",
        "Community",
        "For the people",
        "C-SPAN",
        "Friday 6pm",
        "assets/posters/banner_community.png",
        {"nbccommunity"},
        {"Jeff Winger","Britta","Abed","Troy Barnes"}
)
tv_show[2] = ShowObject(
        "assets/titlecards/tile_dexter.png",
        "Dexter",
        "Darkly Dreaming Dexter",
        "SHO 240",
        "Sunday 9pm",
        "assets/posters/banner_dexter.png",
        {"Dexter","sho_dexter"},
        {"Dexter Morgan","Debra Morgan"}
)
tv_show[3] = ShowObject(
        "assets/titlecards/tile_family_guy.png",
        "Family Guy",
        "Victory is mine!!",
        "FOX 5",
        "Thursday 9pm",
        "assets/posters/banner_family_guy.png",
        {"familyguy","fox_familyguy"},
        {"Peter Griffin","Lois Griffin", "Meg Griffin",
        "Brian Griffin", "Chris Griffin", "Stewie, Quagmire"}
)
tv_show[4] = ShowObject(
        "assets/titlecards/tile_glee.png",
        "Glee",
        "Kurt is officially a Dalton Academy Warbler.",
        "FOX 5",
        "Now Playing",
        "assets/posters/banner_glee.png",
        {"glee","gleek","fox_glee"},
        {"Quinn Fabray", "Kurt Hummel", "Terri Schuester", "Will Schuester"}
)
tv_show[5] = ShowObject(
        "assets/titlecards/tile_sons_of_anarchy.png",
        "Sons of Anarchy",
        "On the road again.",
        "FX 24",
        "Tonight 10pm",
        "assets/posters/banner_sons_of_anarchy.png",
        {"soafx"},
        {"Jax", "Clay Morrow", "Gemma Morrow"}
)
tv_show[6] = ShowObject(
        "assets/titlecards/tile_biggest_loser.png",
        "Biggest Loser",
        "Less is More.",
        "NBC 3",
        "Tonight 9pm",
        "assets/posters/banner_biggest_loser.png",
        {"BL10","BL11","nbc_loser"},
        {"Allison Sweeney", "Jillian Michaels", "Bob Harper"}
)
tv_show[7] = ShowObject(
        "assets/titlecards/tile_csi.png",
        "CSI:NY",
        "Another one bites the dust.",
        "SPK 29",
        "Wednesday 1pm",
        "assets/posters/banner_csiNY.png",
        {"csiny"},
        {"Mac Taylor", "Jo Danville"}
)
tv_show[8] = ShowObject(
        "assets/titlecards/tile_outsourced.png",
        "Outsourced",
        "Jobless",
        "NBC 3",
        "Thursday 9:30pm",
        "assets/posters/banner_outsourced.png",
        {"outsourcednbc"},
        {"Todd Dempsey", "Asha"}
)


for i=1,#tv_show do
    if tv_show[i].title_card ~= nil then
        fp.title_card_bar:add(tv_show[i])
    end
    fp.listings_container:add(tv_show[i])
end


--key handler
page = "fp"
local prev_stream = nil
active_stream = nil
fp.title_card_bar:receive_focus()

function screen:on_key_down(key)
    
    if  _G[page].keys[  _G[page].focus  ][key] then
        _G[page].keys[  _G[page].focus  ][key]()
    end
end

function idle:on_idle(elapsed)
    --ping active stream
    if active_stream ~= nil then
        if prev_stream ~= active_stream then
            active_stream:on_idle(0)
            prev_stream = active_stream
        else
            active_stream:on_idle(elapsed)
        end
    end
end