
s2 = WL.Slider{x=500, y = 300, grip_w = 50, grip_h = 200, track_w = 500, track_h = 50}
--s1 = Slider{direction = "vertical", }
--s1:set{x=30,track_h = 400, track_w = 100,grip_w = 100,grip_h = 100}

--dumptable(s1.attributes)
screen:add(s1,s2)

screen.reactive = true