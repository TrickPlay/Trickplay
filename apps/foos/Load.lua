--dofile ("FlickrTest.lua")
dofile("Slideshow.lua")
NUM_ROWS   = 2
NUM_VIS_COLS   = 3
PADDING_BORDER = 0
PADDING_MIDDLE = 0

PIC_DIR = "assets/thumbnails/"


--calls adapters/sources, loads default images
function Setup_Album_Covers()
    screen:add(model.default)
	 loadCovers()
   -- startAdapter(1) --TODO fix this one source shit
    model.album_group.x = screen.width  / (NUM_VIS_COLS + 1)*.5

    --fill the thing with clones of the default-loading image
    for i = 1,NUM_ROWS do 
        model.placeholders[i] = {}
        model.albums[i] = {}
        for j = 1,math.ceil(model.num_sources/NUM_ROWS) do

            model.placeholders[i][j] = Clone{ source = model.default }
            model.placeholders[i][j].position = 
            {
                screen.width  * (j-1) / (NUM_VIS_COLS + 1),
                screen.height * (i-1) / NUM_ROWS
            }
            model.placeholders[i][j].scale = 
            {
                (screen.width/(NUM_VIS_COLS+1))  / 
                 model.default.base_size[1],
                (screen.height/NUM_ROWS) / 
                 model.default.base_size[2]
            }
            model.placeholders.opacity = 255

            model.album_group:add(model.placeholders[i][j])
        end
    end
end

--Called by the adapter's on_complete function
function Load_Image(site,index)

    local i = index%NUM_ROWS + 1
    local j = math.ceil(index/NUM_ROWS)

    print("getting a pic for ",i,j,index)
    model.albums[i][j] = Image
    {
        async    = true,
        src      = site,
        position = 
        {
            screen.width  * (j-1) / (NUM_VIS_COLS + 1),
            screen.height * (i-1) / NUM_ROWS
        },
        -- toss the filler image and scale it once loaded
        on_loaded = function()
            print("loading pic at",i,j,index)
            model.placeholders[i][j]:unparent()
            model.placeholders[i][j] = nil

            model.albums[i][j].scale = 
            {
                 (screen.width/(NUM_VIS_COLS+1))  / 
                  model.albums[i][j].base_size[1],
                 (screen.height/NUM_ROWS) / 
                  model.albums[i][j].base_size[2]
            }
            model.album_group:add(model.albums[i][j])
            model.albums[i][j]:lower_to_bottom()
        end
    }
end


