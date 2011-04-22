

base = -.8
brakes = .1

function controllers.on_controller_connected( controllers , controller )

    if controller.has_accelerometer then
    
        controller:start_accelerometer( "L" , 20/1000 )
        
        function controller.on_accelerometer( controller , x , y , z )
        if paused then
            base = (base+x)/2
        end
        --[[
            if math.abs( x ) > 1 then
                my_plane.h_speed = clamp( my_plane.h_speed + ( x * 0.4 )  * ( my_plane.max_h_speed * 0.05 ) ,
                -my_plane.max_h_speed , my_plane.max_h_speed )
            end
            if math.abs( y ) > 1 then
                my_plane.v_speed = clamp( my_plane.v_speed - ( y * 0.9 )  * ( my_plane.max_v_speed * 0.25 ) ,
                -my_plane.max_v_speed , my_plane.max_v_speed )
            end
        --]]
        print("accel",x,y)
        accel = (accel+(x-base))/2-brakes
        turn_impulse = -y
        end
    
    end

end

for _,controller in pairs(controllers.connected) do
	controllers:on_controller_connected( controller )
end
