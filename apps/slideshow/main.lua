
-------------------------------------------------------------------------------
-- Check the launch info

local launch = app.launch

if launch.action ~= "SLIDESHOW" or launch.parameters == nil then

    return
    
end    

url_list = launch.parameters

--[[
url_list =
{
    "http://farm1.static.flickr.com/29/60950480_a297fd04d3_o.jpg",
    "http://farm4.static.flickr.com/3636/3517315415_354a090962_o.jpg"
}
]]

next_url = 1

image_queue = {}

image_request_max = 1

image_requests = 0

-------------------------------------------------------------------------------
-- When an image is loaded, we add it to the queue and decrement the number
-- of outstanding requests

function image_loaded( image , failed )

    if not failed then
    
        table.insert( image_queue , image )
        
    end
    
    image_requests = image_requests - 1
    
    image.on_loaded = nil

end

-------------------------------------------------------------------------------
-- Returns the next image in the queue (or nil) and starts up requests for more
-- images until it reaches image_request_max.

function get_next_image()

    local result = nil
    
    if #image_queue > 0 then
    
        result = image_queue[ 1 ]
        
        table.remove( image_queue, 1 )
    
    end

    if not result and image_requests < image_request_max then
    
        for i = 1 , image_request_max - image_requests do
    
            if next_url > # url_list then
            
                break
                
            end
        
            Image{ src = url_list[ next_url ] , on_loaded = image_loaded }
            
            image_requests = image_requests + 1
            
            next_url = next_url + 1
            
        end
    
    end

    return result
    
end


current_image = nil

image_time = Stopwatch()

OPACITY_PER_SECOND  = 128
SCALE_PER_SECOND    = 0.03
MOTION_PER_SECOND   = 16
SLIDE_SECONDS       = 5
OVERZOOM            = 1.05

old_image_time = 0

paused = false

function idle.on_idle( idle , seconds )

	if(math.random(1000) == 5) then print(image_time.elapsed_seconds - old_image_time, seconds) end
	old_image_time=image_time.elapsed_seconds

	if paused then return end

    local function place_image( image )
    
        local scale = math.max( screen.w / image.w , screen.h / image.h ) * OVERZOOM
        
        image.anchor_point = { image.w / 2 , image.h / 2 }
        
        image.scale = { scale , scale }
        
        image.position = screen.center
        
        image.opacity = 0
        
        screen:add( image )
        
    end


    if not current_image then
    
        current_image = get_next_image()
        
        if current_image then
        
            place_image( current_image )
            
            image_time:start()
            
            print( "GOT IMAGE" )
        
        end
        
    else

        -- We have a current image

        local t = image_time.elapsed_seconds
        
        if t < SLIDE_SECONDS then
   
            if current_image.opacity < 255 then
            
                current_image.opacity = math.min( current_image.opacity + ( OPACITY_PER_SECOND * seconds ) , 255 )
            
            end
            
        elseif t >= SLIDE_SECONDS then
        
            if current_image.opacity > 0 then
            
                current_image.opacity = math.max( current_image.opacity - ( OPACITY_PER_SECOND * seconds ) , 0 )
            
            else
            
                current_image:unparent()
                
                current_image = nil
                
                collectgarbage()
                
                return
            
            end
        
        end
        
        local scale = current_image.scale[ 1 ] + ( SCALE_PER_SECOND * seconds )
        
        current_image.scale = { scale , scale }
        
        local xd = current_image.extra.xd
        
        local yd = current_image.extra.yd
        
        if xd == nil then
        
            xd = math.random( -1 , 1 )
            
            current_image.extra.xd = xd
        
        end

        if yd == nil then
        
            yd = math.random( -1 , 1 )
            
            current_image.extra.yd = yd
        
        end
        
        current_image.x = current_image.x + ( xd * ( MOTION_PER_SECOND * seconds ) )
        current_image.y = current_image.y + ( yd * ( MOTION_PER_SECOND * seconds ) )
    
    end

end

screen:show()

function screen.on_key_down(screen, key)
	if key == keys.space then
		paused = not paused
	end
end
