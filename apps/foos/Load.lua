NUM_OF_3X3 = 1
NUM_OF_2X2 = 2

NUM_ROWS   = 4
NUM_COLS   = 7

PIC_DIR = "assets/thumbnails/"


math.randomseed(os.time())

--IMAGE_WIDTH  240
--IMAGE_HEIGHT 270

--SCREEN WIDTH  1920
--SCREEN HEIGHT 1080

function GenerateGrid(ui)
--[[
    local grid = {}
    for i = 1,NUM_ROWS do 
        grid[i] = {}
        for j = 1,NUM_COLS do
            grid[i][j] = {0,0}
        end
    end
--]]
    local grid = RandomGrid()
--[[
    {
        { {1,1}, {1,1}, {1,1}, {1,4}, {1,5}, {1,6}, {1,6} },
        { {1,1}, {1,1}, {1,1}, {2,4}, {2,4}, {1,6}, {1,6} },
        { {1,1}, {1,1}, {1,1}, {2,4}, {2,4}, {3,6}, {3,7} },
        { {4,1}, {4,2}, {4,3}, {4,4}, {4,5}, {4,6}, {4,7} }
    }
--]]
    local pictures
    local pic_group
    pic_group, pictures = Place_Pictures(grid,ui)

    return grid, pictures, pic_group
end

function Place_Pictures(grid,pic_group)

    --local pic_group = Group{name="FrontPage Picture Group"}
    local pictures = {}
    local index = 1

    for i = 1,NUM_ROWS do 
        pictures[i] = {}
        for j = 1,NUM_COLS do

            --if the current index isn't a place-holder for
            --a big image (i.e 2x2 or 3x3)
            if grid[i][j][1] == i and
               grid[i][j][2] == j then

                pictures[i][j] = Image{
                    position = {screen.width  * (j-1) / NUM_COLS,
                                screen.height * (i-1) / NUM_ROWS},
                    src = PIC_DIR.."Album"..index..".jpg"
                }
                index = index + 1

                --scale size for a 1 x 1
                pictures[i][j].scale = {
                    (screen.width/NUM_COLS)  / pictures[i][j].base_size[1],
                    (screen.height/NUM_ROWS) / pictures[i][j].base_size[2]
                }

                --rescale if its the 2x2 or 3x3

                -- 3 x 3

                if     grid[i][j+1]    ~= nil           and
                       grid[i][j+1][1] == grid[i][j][1] and
                       grid[i][j+1][2] == grid[i][j][2] and
                       grid[i][j+2]    ~= nil           and
                       grid[i][j+2][1] == grid[i][j][1] and
                       grid[i][j+2][2] == grid[i][j][2] then
print("3x3")
                    pictures[i][j].scale = {
                        pictures[i][j].scale[1] * 3,
                        pictures[i][j].scale[2] * 3
                    }

                    
                -- 2 x 2
                elseif grid[i][j+1]    ~= nil           and
                       grid[i][j+1][1] == grid[i][j][1] and
                       grid[i][j+1][2] == grid[i][j][2]  then
print("2x2")
                    pictures[i][j].scale = {
                        pictures[i][j].scale[1] * 2,
                        pictures[i][j].scale[2] * 2
                    }
                end

                pic_group:add(pictures[i][j])
            end
        end
    end

    return pic_group, pictures
end


function RandomGrid()
--[[
    --perform check to see if config parameters can work
    assert( (NUM_ROWS * NUM_COLS)  >=  (9*NUM_OF_3X3 + 4*NUM_OF_2X2),
           "the number of rows and columns cannot support the "..
           "desired number of 3X3 and 2X2 album covers")
    if NUM_OF_3X3 >= 1 then
        assert( ((NUM_COLS  >=  3*NUM_OF_3X3)  and  (NUM_ROWS  >=  3)) or
                ((NUM_ROWS  >=  3*NUM_OF_3X3)  and  (NUM_COLS  >=  3)),
              "window is too skinny for the number of 3x3 pictures")
        assert( (NUM_OF_3X3*3 + NUM_OF_2X2*2 <= NUM_ROWS) or
                (NUM_OF_3X3*3 + NUM_OF_2X2*2 <= NUM_COLS),
              "window can't support the number of 3x3 and 2x2 pictures")

        --place the windows
        
    elseif NUM_OF_2X2 >= 1 then
        assert( ((NUM_COLS  >=  2*NUM_OF_2X2)  and  (NUM_ROWS  >=  2)) or
                ((NUM_ROWS  >=  2*NUM_OF_2X2)  and  (NUM_COLS  >=  2)),
              "window is too skinny for the number of 2x2 pictures")

    else --just 1X1
    end
--]]
    local grid = {}
    for i = 1,NUM_ROWS do 
        grid[i] = {}
        for j = 1,NUM_COLS do
            grid[i][j] = {i,j}
        end
    end

    --these numbers are best suited for a 4,7 window
    local num_of_3x3 = 1--math.random(0,2)
    local num_of_2x2 = 2--math.random(2,4) - num_of_3x3

    local available_upper = {NUM_ROWS-2,NUM_COLS-2}
    local available_lower = {1,1}
    local picks = {}
    while num_of_3x3 > 0 do
        picks[#picks+1] = {math.random(available_lower[1],
                                       available_upper[1]),
                           math.random(available_lower[2],
                                       available_upper[2])}
        num_of_3x3 = num_of_3x3 -1
    end
--[[
    print(picks[1][1],picks[1][2], math.random(available_lower[2],
                                       available_upper[2]),available_lower[2],
                                       available_upper[2])
--]]
    for i = 0,2 do
        for j = 0,2 do
            grid[picks[1][1]+i][picks[1][2]+j] = {picks[1][1],picks[1][2]}
        end
    end

    local r1
    local r2
    local c1
    local c2

    --if the 2x2s can be separated
    if picks[1][2] == 3 then
        r1 = math.random(1,3)
        r2 = math.random(1,3)
        --if they can be stacked
        if ((r1-r2) == 2) or ((r2-r1) == 2) then
            c1 = math.random(0,1)*5+1 --yields either 6 or 1
            c2 = math.random(0,1)*5+1
        else --cant be stacked
            c1 = 1
            c2 = 6
        end
    --if the 2x2s can't be separated
    --put on the right side
    elseif  picks[1][2] == 1 or picks[1][2] == 2 then
        lower = {picks[1][2]+3, 1}
        upper = {6,3}

        c1 = math.random(lower[1],upper[1]) 
        c2 = math.random(lower[1],upper[1])

        --col has complete freedom
        if ((c1-c2) == 2) or ((c2-c1) == 2) then
            r1 = math.random(1,NUM_ROWS-1)
            r2 = math.random(1,NUM_ROWS-1)
        else 
            r1 = 1
            r2 = 3
        end
    --put on the left side
    elseif picks[1][2] == 4 or picks[1][2] == 5 then
        lower = {1, 1}
        upper = {picks[1][2]-2,3}

        c1 = math.random(lower[1],upper[1]) 
        c2 = math.random(lower[1],upper[1])

        --col has complete freedom
        if ((c1-c2) == 2) or ((c2-c1) == 2) then
            r1 = math.random(1,NUM_ROWS-1)
            r2 = math.random(1,NUM_ROWS-1)
        else 
            r1 = 1
            r2 = 3
        end
    end
    print(picks[1][1],picks[1][2],"   ",r1,c1,"   ",r2,c2)
    for i = 0,1 do
        for j = 0,1 do
            grid[r1+i][c1+j] = {r1,c1}
            grid[r2+i][c2+j] = {r2,c2}
        end
    end

    for i = 1,NUM_ROWS do 
        str = ""
        for j = 1,NUM_COLS do
            assert(grid,"0")
            assert(grid[i],"1")
            assert(grid[i][j],"2")
            assert(grid[i][j][1],"3")
            str = str.."{"..grid[i][j][1]..","..grid[i][j][2].."} "
            --print("{"..g[i][j][1]..","..g[i][j][2].."} ")
        end
        print(str)
    end

    return grid
end
--[[
local g = RandomGrid()
    for i = 1,NUM_ROWS do 
        str = ""
        for j = 1,NUM_COLS do
            assert(g,"0")
            assert(g[i],"1")
            assert(g[i][j],"2")
            assert(g[i][j][1],"3")
            str = str.."{"..g[i][j][1]..","..g[i][j][2].."} "
            --print("{"..g[i][j][1]..","..g[i][j][2].."} ")
        end
        print(str)
    end
--]]
