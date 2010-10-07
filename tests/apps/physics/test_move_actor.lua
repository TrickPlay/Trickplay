
-------------------------------------------------------------------------------
-- Add invisible walls

physics:Body{ size = { 2 , screen.h } , position = { -1 , screen.h / 2 } }
physics:Body{ size = { 2 , screen.h } , position = { screen.w + 1 , screen.h / 2 } }
physics:Body{ size = { screen.w , 2 } , position = { screen.w / 2 , -1 } }
physics:Body{ size = { screen.w , 2 } , position = { screen.w / 2 , screen.h + 1 } }

-------------------------------------------------------------------------------

r = Rectangle
{
    size = { 100 , 100 } ,
    position = { ( screen.w / 2 ) - 50 , ( screen.h / 2 ) - 50 },
    color = "0000FF",
}

b = physics:Body{ source = r , dynamic = true , density = 1 , bounce = 0.8 }

screen:add( r )

function physics.on_begin_contact( physics , point , body_a_handle , fixture_a_handle , body_b_handle , fixture_b_handle )

    print( "BEGIN CONTACT" , point[ 1 ] , point[ 2 ] , ":" , body_a_handle , body_b_handle );

end

function physics.on_end_contact( physics , point , body_a_handle , fixture_a_handle , body_b_handle , fixture_b_handle )

    print( "  END CONTACT" , point[ 1 ] , point[ 2 ] , ":" , body_a_handle , body_b_handle );

end


function screen.on_key_down( screen , key )

    if key == keys.space then
    
        physics:step()
        
    elseif key == keys.Return then
    
        if idle.on_idle then
            
            idle.on_idle = nil
            
        else
        
            idle.on_idle = function( idle , seconds ) physics:step( seconds ) end
            
        end
        
    elseif key == keys.Up then
    
        b.y = b.y - 10
        
    elseif key == keys.Down then
    
        b.y = b.y + 10
    
    elseif key == keys.Left then
    
        b.x = b.x - 10
        
    elseif key == keys.Right then
    
        b.x = b.x + 10
        
    elseif key == keys.z then
    
        b.rotation = b.rotation + 10
        
    end
    
    --print( r.x , r.y , r.z_rotation[ 1] , b.x , b.y , b.rotation )
end

