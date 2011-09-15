local score_gauge = Group { name = "Score Gauge" }

local frame = Image { name = "frame", src = "assets/robot-part/gauge/GaugeFront.png" }
local bground = Image { name = "bground", src = "assets/robot-part/gauge/GaugeBack.png" }
local heart = Image { name = "heart", src = "assets/robot-part/gauge/Heart.png" }
local gauge = Image { name = "gauge", src = "assets/robot-part/gauge/Gauge.png" }

bground.x = (frame.w-bground.w)/2
bground.y = (frame.h-bground.h)/2

gauge.y = bground.y
gauge.x = bground.x

score_gauge.extra = { score = 0 }

gauge.w = bground.w * score_gauge.extra.score/100 + 1

heart.anchor_point = { heart.w/2, 0 }
heart.y = (frame.h-heart.h)/2
heart.x = gauge.x + gauge.w

score_gauge:add(bground,gauge,frame,heart)

score_gauge.x = (screen.w - score_gauge.w)/2
score_gauge.y = 60


score_gauge.extra.set_score = function(self,new_score)
    assert(new_score >= 0 and new_score <= 100)
    local old_score = score_gauge.extra.score
    local gauge, bground, heart = self:find_child('gauge'),self:find_child('bground'),self:find_child('heart')
    self.extra.score = new_score

    local animator = Animator {
                                duration = 250,
                                properties = {
                                    {
                                        source = gauge,
                                        name = "width",
                                        keys = {
                                            { 0.0,  "LINEAR",   bground.w * old_score/100 + 1 },
                                            { 1.0,  "EASE_IN_OUT_SINE", bground.w * self.extra.score/100 + 1 },
                                        }
                                    },
                                    {
                                        source = heart,
                                        name = "x",
                                        keys = {
                                            { 0.0,  "LINEAR",   gauge.x + bground.w * old_score/100 + 1 },
                                            { 1.0,  "EASE_IN_OUT_SINE", gauge.x + bground.w * self.extra.score/100 + 1 },
                                        }
                                    },
                                },
                    }

    animator:start()
end

score_gauge:move_anchor_point( score_gauge.w/2, score_gauge.h/2 )
score_gauge.scale = { 2, 2 }

return score_gauge
