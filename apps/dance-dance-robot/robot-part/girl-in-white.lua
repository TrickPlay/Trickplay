local my_hook = function(factory)

    local images = {
                                    idle1 = "assets/robot-part/girls/idle.0001-1.png",
                                    idle2 = "assets/robot-part/girls/idle.0002-1.png",
                                    idle3 = "assets/robot-part/girls/idle.0003-1.png",

                                    knockdown1 = "assets/robot-part/girls/knockdown.0001-1.png",
                                    knockdown2 = "assets/robot-part/girls/knockdown.0002-1.png",
                                    knockdown3 = "assets/robot-part/girls/knockdown.0003-1.png",
                                    knockdown4 = "assets/robot-part/girls/knockdown.0004-1.png",

                                    knockdownToStand1 = "assets/robot-part/girls/knockdownTostand.0001-1.png",

                                    roll1 = "assets/robot-part/girls/roll.0001-1.png",

                                    rollToStand1 = "assets/robot-part/girls/rollTostand.0001-1.png",
                                    rollToStand2 = "assets/robot-part/girls/rollTostand.0002-1.png",

                                    run1 = "assets/robot-part/girls/run.0001-1.png",
                                    run2 = "assets/robot-part/girls/run.0002-1.png",
                                    run3 = "assets/robot-part/girls/run.0003-1.png",
                                    run4 = "assets/robot-part/girls/run.0004-1.png",
                                    run5 = "assets/robot-part/girls/run.0005-1.png",
                                    run6 = "assets/robot-part/girls/run.0006-1.png",

                                    runToStop1 = "assets/robot-part/girls/runTostop.0001-1.png",
                                    runToStop2 = "assets/robot-part/girls/runTostop.0002-1.png",
                                }

    local girl = factory(images)

    girl.name = "white"
    girl.extra.MAX_X = girl.MAX_X-150
    girl.position = { girl.MIN_X, screen.h * 9/10 }
    girl.target_x = girl.x

    return girl
end

return my_hook
