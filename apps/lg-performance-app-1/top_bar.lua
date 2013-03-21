
local top_bar = Group()

--the icons at the top
local top_items = {
    Sprite{
        sheet = assets,
        id = "top-icon-connection-on.png",
    },
    Sprite{
        sheet = assets,
        id = "top-icon-edit.png",
    },
    Sprite{
        sheet = assets,
        id = "top-bar-line-separator.png",
    },
    Sprite{
        sheet = assets,
        id = "top-icon-search.png",
    },
    Sprite{
        sheet = assets,
        id = "top-icon-notice.png",
    },
    Sprite{
        sheet = assets,
        id = "top-icon-logout.png",
    },
    Sprite{
        sheet = assets,
        id = "top-bar-line-separator.png",
    },
    Sprite{
        sheet = assets,
        id = "top-icon-exit.png",
    },
}

top_bar:add(unpack(top_items))

--space out the icons evenly
for i=1,#top_items do
    local v =top_items[i]

    v.anchor_point = {0,v.h/2}
    --separators need to be scaled up a bit
    if v.id == "top-bar-line-separator.png" then
        v.w = v.w*3/2
        v.h = v.h*3/2
    end
    v.x = i == 1 and 0 or (top_items[i-1].x+top_items[i-1].w+20)
end

top_bar.x = screen.w - top_items[#top_items].x - 100
top_bar.y = 60


return top_bar
