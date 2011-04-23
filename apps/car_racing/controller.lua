


--flat is 0,0

--tilting the top downward -> 0,1
    -- contineuing to face down is -> 0,0
        --contineuing to bottom down is -> 0,-1
--tilting the bottom downward -> 0,-1
    -- contineuing to face down is -> 0,0
        --contineuing to bottom down is -> 0,-1
        
--right down is 1,0
--left down is -1,0

function controllers.on_controller_connected( controllers , controller )
    
    if controller.ui_size[1] == 435 then
        controller:declare_resource("bg","assets/hand_held_controller/ipod.png")
        controller:set_ui_background("bg","STRETCH")
        print("Connected IPOD")
    elseif controller.ui_size[1] == 640 then
        controller:declare_resource("bg","assets/hand_held_controller/iphone.png")
        controller:set_ui_background("bg","STRETCH")
        print("Connected IPHONE")
    else
        controller:declare_resource("bg","assets/hand_held_controller/ipad.png")
        controller:set_ui_background("bg","STRETCH")
        print("Connected IPAD")
    end
    if controller.has_accelerometer then
    
        controller:start_accelerometer( "L" , 20/1000 )
        
        function controller.on_accelerometer( controller , x , y , z )
        --[[
        x = 1 - math.abs(x)
        if paused then
            base = (base+x)/2
        end
        
        if x > base then
            throttle_position = 2*(x-base)/(1-base)
        else
            throttle_position = -10*(base-x)/base
        end--]]
        --print("accel",string.format("%.3f\t%.3f",x,y))
        turn_impulse = -y
        end
    
    end
    
    if controller.has_touches then
        print("has touch")
        function controller.on_touch_down( controller, finger, x, y )
            throttle_position = -10
        end
        function controller.on_touch_move( controller, finger, x, y )
            throttle_position = -10
        end
        controller:start_touches()
    end

end

for _,controller in pairs(controllers.connected) do
	controllers:on_controller_connected( controller )
end
