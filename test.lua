
x,y = 640, 480

stage = Stage.new(x,y)

print(stage)

t = 5000

timeline = Timeline.new(t)

print(timeline)

stage:circles(timeline)
