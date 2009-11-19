
x,y = 640, 480

stage = Stage.new(x,y)

print(stage)

t = 5000

timeline = Timeline.new(t)

print(timeline)

n_circles = 5
circle_width = 64
circle_gap = 16
circle_segments = 3

stage:circles(timeline, n_circles, circle_width, circle_gap, circle_segments)
