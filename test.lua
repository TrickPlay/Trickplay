
local_hash = Localhash.new()

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

