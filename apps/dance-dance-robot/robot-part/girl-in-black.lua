local my_hook = function(factory)

    local images = {
                                    idle1 = "/assets/robot-part/girls/idle.0001.png",
                                    idle2 = "/assets/robot-part/girls/idle.0002.png",
                                    idle3 = "/assets/robot-part/girls/idle.0003.png",

                                    knockdown1 = "/assets/robot-part/girls/knockdown.0001.png",
                                    knockdown2 = "/assets/robot-part/girls/knockdown.0002.png",
                                    knockdown3 = "/assets/robot-part/girls/knockdown.0003.png",
                                    knockdown4 = "/assets/robot-part/girls/knockdown.0004.png",

                                    knockdownToStand1 = "/assets/robot-part/girls/knockdownToStand.0001.png",

                                    roll1 = "/assets/robot-part/girls/roll.0001.png",

                                    rollToStand1 = "/assets/robot-part/girls/rollTostand.0001.png",
                                    rollToStand2 = "/assets/robot-part/girls/rollTostand.0002.png",

                                    run1 = "/assets/robot-part/girls/run.0001.png",
                                    run2 = "/assets/robot-part/girls/run.0002.png",
                                    run3 = "/assets/robot-part/girls/run.0003.png",
                                    run4 = "/assets/robot-part/girls/run.0004.png",
                                    run5 = "/assets/robot-part/girls/run.0005.png",
                                    run6 = "/assets/robot-part/girls/run.0006.png",

                                    runToStop1 = "/assets/robot-part/girls/runTostop.0001.png",
                                    runToStop2 = "/assets/robot-part/girls/runTostop.0002.png",
                                }

    local girl = factory(images)

    girl.name = "black"
    girl.position = { screen.w/3, screen.h * 9/10 }

    return girl
end

return my_hook
