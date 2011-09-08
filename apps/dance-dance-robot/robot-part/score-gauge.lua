local score_gauge = Group { name = "Score Gauge" }

local frame = Image { src = "/assets/robot-part/gauge/GaugeFront.png" }
local bground = Image { src = "/assets/robot-part/gauge/GaugeBack.png" }
local heart = Image { src = "/assets/robot-part/gauge/Heart.png" }
local gauge = Image { src = "/assets/robot-part/gauge/Gauge.png" }

bground.x = (frame.w-bground.w)/2
bground.y = (frame.h-bground.h)/2

gauge.y = bground.y
gauge.x = bground.x

score_gauge.extras = { score = 0 }

gauge.w = bground.w * score_gauge.extras.score/100 + 1

heart.anchor_point = { heart.w/2, 0 }
heart.y = (frame.h-heart.h)/2
heart.x = gauge.x + gauge.w

score_gauge:add(bground,gauge,frame,heart)

score_gauge.x = (screen.w - score_gauge.w)/2
score_gauge.y = 100


score_gauge.extras.set_score = function(new_score)
    assert(new_score >= 0 and new_score <= 100)
    score_gauge.extras.score = new_score
    gauge.w = bground.w * score_gauge.extras.score/100 + 1
    heart.x = gauge.x + gauge.w
end


return score_gauge
