local directory = ...

poster_names = dofile(directory.."list.lua")
local posters = {}

for i=1,#poster_names do
    local my_image = Widget_Image { src = directory..poster_names[i] }
    posters[i] = NineSlice{
        x = screen.w/2,
        y = screen.h/2,
        w = my_image.w + 2 + 2,
        h = my_image.h + 2 + 2,
        cells = {
            default = {
                {
                    Widget_Rectangle{ w=2,h=2,color="white", opacity=64 },
                    Widget_Rectangle{ w=2,h=2,color="white", opacity=64 },
                    Widget_Rectangle{ w=2,h=2,color="white", opacity=64 },
                },
                {
                    Widget_Rectangle{ w=2,h=2,color="white", opacity=64 },
                    my_image,
                    Widget_Rectangle{ w=2,h=2,color="white", opacity=64 },
                },
                {
                    Widget_Rectangle{ w=2,h=2,color="white", opacity=64 },
                    Widget_Rectangle{ w=2,h=2,color="white", opacity=64 },
                    Widget_Rectangle{ w=2,h=2,color="white", opacity=64 },
                },
            },
        }
    }
    posters[i].anchor_point = { posters[i].w/2, posters[i].h/2 }
end

return posters
