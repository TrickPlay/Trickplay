
local_hash = Localhash.new('data_file')


--[[
value=''

for i=1,20000 do
	value = value..i*2
	local_hash:put(i,value)
end

print(1234,local_hash:get(1234))

--]]

---[[
for j=1,10 do
	for i=1,20000 do local_hash:get(i) end
end
--]]

--[[
url_fetcher = URLFetcher.new()

x,y = 640, 540
r,g,b = 0xe0, 0xc2, 0xfc
stage = Stage.new(x,y,r,g,b)

t = 6000
timeline = Timeline.new(t)

n_circles = 3
circle_width = 128
circle_gap = 16
circle_segments = 3
stage:circles(timeline, n_circles, circle_width, circle_gap, circle_segments)

--]]
