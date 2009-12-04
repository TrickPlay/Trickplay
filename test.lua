
local_db = LocalDB.new('circles_demo.tch')

--[[
local_db:nuke('REALLY_NUKE')

local_db:put('x', 1392)
local_db:put('y', 783)

local_db:put('r', 0xe0)
local_db:put('g', 0xc2)
local_db:put('b', 0xfc)

local_db:put('time', 6000)

local_db:put('n_circles', 3)
local_db:put('circle_width', 128)
local_db:put('circle_gap', 16)
local_db:put('circle_segments', 3)
--]]

---[[
print(local_db)
--]]

---[[

x,y = local_db:get('x'), local_db:get('y')
r,g,b = local_db:get('r'), local_db:get('g'), local_db:get('b')

stage = Stage.new(x,y,r,g,b)

time = local_db:get('time')
timeline = Timeline.new(time)

n_circles = local_db:get('n_circles')
circle_width = local_db:get('circle_width')
circle_gap = local_db:get('circle_gap')
circle_segments = local_db:get('circle_segments')
stage:circles(timeline, n_circles, circle_width, circle_gap, circle_segments)

--]]
