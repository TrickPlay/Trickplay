
-------------------------------------------------------------------------------
-- Check the launch info

local launch = app.launch

if launch.action ~= "SLIDESHOW" or launch.parameters == nil then

    return
    
end    

-------------------------------------------------------------------------------
-- A queue of images - you feed it an array of URLs and then call get_next_image
-- to get the next one.

function ImageQueue( url_list )

    local result =
        {
            url_list = url_list,
            
            next_url = 1,
            
            images = {},
            
            max_requests = 1,
            
            outstanding_requests = 0,
        }
    
    function result.get_next_image( self )
    
        local result = nil
        
        -- Pick the next image from the queue
        
        if # self.images > 0 then
        
            result = table.remove( self.images , 1 )
        
        end
        
        -- Now, start new requests if necessary
        
        if self.outstanding_requests < self.max_requests then
        
            for i = 1 , self.max_requests - self.outstanding_requests do
        
                if self.next_url > # self.url_list then
                
                    self.next_url = 1 
                    
                    if self.next_url > # self.url_list then
                    
                        break
                    
                    end
                end
            
                -- Create the image
            
                local image = Image{ src = self.url_list[ self.next_url ] , async = true }
                
                -- Callback when the image is loaded
                
                function image.on_loaded( image , failed )
                
                    if not failed then
                    
                        table.insert( self.images , image )
                        
                    end
                    
                    self.outstanding_requests = self.outstanding_requests - 1
                    
                    image.on_loaded = nil
                
                end
                
                self.outstanding_requests = self.outstanding_requests + 1
                
                self.next_url = self.next_url + 1
                
            end
        
        end
        
        return result
    
    end
    
    return result

end

-------------------------------------------------------------------------------

image_queue = ImageQueue( launch.parameters )

current_image = nil

image_time = Stopwatch()

OPACITY_PER_SECOND  = 128
SCALE_PER_SECOND    = 0.03
MOTION_PER_SECOND   = 16
SLIDE_SECONDS       = 5
OVERZOOM            = 1.05

paused = false

function idle.on_idle( idle , seconds )


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
    
        current_image = image_queue:get_next_image()
        
        if current_image then
        
            place_image( current_image )
            
            image_time:start()
            
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
