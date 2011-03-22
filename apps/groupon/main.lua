GROUPON = dofile("groupon.lua")

local deals = GROUPON:get_deals()

local make_tile = function (image, title)
    local i = Image { src = image }
    local t = Text { text = title, color = 'ffffff', font = 'Diavlo 36px' }
    local r = Rectangle { size = { t.w, t.h }, color = "000000", opacity = 150 }
    local g = Group { }
    g:add(i)
    g:add(r)
    g:add(t)
    t.y = i.h + 6
    t.x = (i.w - t.w) / 2
    r.x, r.y = t.x, t.y

    g.x = math.random(10,screen.w-g.w-10)
    g.y = math.random(10 + 100 ,screen.h-g.h-10)

    screen:add(g)
    g.x_rotation = { -90, 0, 0 }
    g:animate({
                duration = 500,
                x_rotation = 0,
                mode = "EASE_OUT_BOUNCE",
                on_completed = function ()
                                    g:animate({
                                                    duration = 10000,
                                                    opacity = 0,
                                                    mode = "EASE_IN_EXPO",
                                                    on_completed = function ()
                                                                        g:unparent()
                                                                    end,
                                                })
                                end,
            })
end


print("We got ",#(deals.deals)," deals")

local title = Text { text = 'Groupon deals!', color = 'ffffff', font = 'Diavlo 96px' }
title.x = (screen.w-title.w)/2
screen:add(title)
screen:show()

local deal
function main()
    repeat
        deal = next(deals.deals, deal)

        if(deal) then
            local v = deals.deals[deal]

            local image = v.largeImageUrl or v.mediumImageUrl or v.smallImageUrl

            local title = v.announcementTitle

            make_tile(image, title)
        end
    until deal
end

local t = Timer(2200)
t.on_timer = main
t:start()
dolater(main)
