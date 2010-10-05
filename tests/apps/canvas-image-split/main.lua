
image = Image{ src = "globe.png" }
image.anchor_point = image.center
image.position = screen.center

screen:add( image )

screen:add( Text{ text = "Press enter to animate the image" , color = "FFFFFF" , font = "50px" } )

local function split_image( image )

    assert( image )
    assert( image.src )

    local w = image.w / 2
    local h = image.h / 2
    
    local canvas = nil
    
    local pieces = {}

    for x = 0 , 1 do
        for y = 0 , 1 do
    
            canvas = Canvas
            {
                size = {  w , h } ,
                position = { image.x - image.anchor_point[ 1 ] + w * x  , image.y - image.anchor_point[ 2 ] + h * y }
            }
            
            canvas:begin_painting()
            canvas:set_source_image( image.src , - w * x  , - h * y )
            canvas:paint()
            
            canvas:finish_painting()
            
            screen:add( canvas )
            
            canvas:raise( image )
            
            canvas:move_anchor_point( w / 2 , h / 2 )
            
            table.insert( pieces , canvas )
            
        end
    end
    
    
    image:unparent()

    return pieces
end    
    
screen:show()

pieces = split_image( image )

local F = 300

local destination =
{
    { x = F , y = F },
    { x = F , y = screen.h - F  },
    { x = screen.w - F , y = F },
    { x = screen.w - F , y = screen.h - F }
}

function screen:on_key_down( k )

    if k == keys.Return then
        
        for i , piece in ipairs( pieces ) do
            
            if piece.is_animating then
                break
            end
        
            local x = piece.x
            local y = piece.y
        
            piece:animate
            {
                duration = 500 ,
                x = destination[ i ].x,
                y = destination[ i ].y,
                on_completed = function()
                    piece:animate
                    {
                        duration = 500,
                        x = x,
                        y = y,
                    }
                end
            }
            
        end
        
    end

end


