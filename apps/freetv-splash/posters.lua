local directory,load_async = ...
if nil == load_async then load_async = true end

local poster_names = dofile(directory.."list.lua")
local posters = {}

for i=1,#poster_names do
    local my_image = Widget_Image { src = directory..poster_names[i], async=load_async }
    posters[i] = NineSlice{
        x = screen.w/2,
        y = screen.h/2,
        w = my_image.w + 1 + 1,
        h = my_image.h + 1 + 1,
        cells = {
            default = {
                {
                    Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                    Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                    Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                },
                {
                    Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                    my_image,
                    Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                },
                {
                    Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                    Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                    Widget_Rectangle{ w=1,h=1,color="white", opacity=64 },
                },
            },
        }
    }
    posters[i].anchor_point = { posters[i].w/2, posters[i].h/2 }
    if load_async then my_image.on_loaded = function(img,fail)
            posters[i].w = img.base_size[1]+1+1
            posters[i].h = img.base_size[2]+1+1
            posters[i].anchor_point = { posters[i].w/2, posters[i].h/2 }
        end
    end
end

poster_names = nil

return posters
