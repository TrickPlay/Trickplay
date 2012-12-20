screen:show()

local MAX_COUNTS=10 -- 10 second rolling window for average
local FPS = Text { font = "Comfortaa Thin 75px", text = "FPS:", position = { 50, 20 }, color = "white" }
local FPS_num = Text { font = FPS.font, text = "17.9", position = { 50 + 10 + FPS.w, 20 }, width = FPS.w * 1.2, color = "white", alignment = "RIGHT", wrap = true }
local framecount = { 0 }
local frame_ticker = Timeline
{
    duration = 1000,
    loop=true,
    on_new_frame = function() framecount[#framecount] = framecount[#framecount] + 1 end,
    on_completed = function()
        local num_counts = #framecount
        local framesum = 0
        for _,frames in ipairs(framecount) do framesum = framesum + frames end
        FPS_num.text = string.format("%2.1f", framesum/num_counts)
        if(num_counts > MAX_COUNTS) then
            table.remove(framecount, 1) -- delete the oldest entry
        end
        table.insert(framecount,0) -- start a new time period
    end,
}
screen:add(FPS,FPS_num)
frame_ticker:start()



local contents = app.contents
local menu_group = Group{}
screen:add(menu_group)

local H = 60
local COLS = 3
local top = 120
local left = 30

local tests = {}
local tests_per_column = 0

local last_run = settings.last

local focused = nil

local files = {}

for i = 1 , #contents do
    local file = contents[ i ]
    local name = string.match( file , "benchmarks/(.*)%.lua" )
    if name then
        table.insert( files , file )
    end
end

table.sort( files )

for i = 1 , #files do
    local file = files[ i ]
    local name = string.match( file , "benchmarks/(.*)%.lua" )
    if name then
        name = string.gsub( name , "_" , " " )
        local text = Text
        {
            font = "Comfortaa Thin "..tostring( H - 14 ).."px",
            color = "white",
            text = name,
            x = left,
            y = top,
            extra = { file = file }
        }

        menu_group:add( text )

        table.insert( tests , text )

        top = top + H
        if top + H > screen.h then
            tests_per_column = #tests-1
            --print("tests_per_column",tests_per_column)
            top = 10
            left = left + screen.w / COLS
        end

        if last_run == file then
            focused = # tests
        end

    end
end

if # tests > 0 then

    focused = focused or 1

    local focus = Rectangle
    {
        color = "964e20" ,
        size = { screen.w / COLS , H } ,
        position = { tests[ focused ].x - 10, tests[ focused ].y }
    }

    menu_group:add( focus )

    focus:lower_to_bottom()

    function screen.on_key_down( screen , key )

        if key == keys.Up and focused > 1 then
            focused = focused - 1
        elseif key == keys.Down and focused < # tests then
            focused = focused + 1
        elseif key == keys.Left and focused > tests_per_column then
            focused = focused - (tests_per_column+1)
        elseif key == keys.Right and focused < #tests-tests_per_column then
            focused = focused + (tests_per_column+1)
        elseif key == keys.Return then
            local file = tests[ focused ].extra.file
            settings.last = file
            menu_group:unparent()
            screen.on_key_down = function(screen, key)
                if(key == keys.BACK) then
                    reload()
                end
            end
            local test = dofile( file )
            screen:add(test)
            test:start()
        end

        focus.position = { tests[ focused ].x - 10, tests[ focused ].y }
    end

end

