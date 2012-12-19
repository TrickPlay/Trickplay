screen:show()

local MAX_COUNTS=5 -- 5 second rolling window for average
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



local text_test = dofile("text_test.lua")
screen:add(text_test)
text_test:start()
