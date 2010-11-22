



function controllers.on_controller_connected( controllers , controller )

    if controller.has_accelerometer then
    
        controller:start_accelerometer( "L" , 0.01 )
        
        function controller.on_accelerometer( controller , x , y , z )
        
            if math.abs( x ) > 0.10 then
                my_plane.h_speed = clamp( my_plane.h_speed + ( x * 0.4 )  * ( my_plane.max_h_speed * 0.10 ) , -my_plane.max_h_speed , my_plane.max_h_speed )
            end
            if math.abs( y ) > 0.07 then
                my_plane.v_speed = clamp( my_plane.v_speed - ( y * 0.9 )  * ( my_plane.max_v_speed * 0.55 ) , -my_plane.max_v_speed , my_plane.max_v_speed )
            end
        
        end
    
    end

end

for _,controller in pairs(controllers.connected) do
	controllers:on_controller_connected( controller )
end
