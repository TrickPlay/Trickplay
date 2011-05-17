--ZIP

function get_lat_lng_for_zip(zip, callback)
    
    return URLRequest{ url = "http://maps.googleapis.com/maps/api/geocode/json?sensor=true&address"..zip, on_complete = callback }:send()

end



local zip = Group{}
---------------
local zip_prompt = Group{}
do
    local zip_bg = Clone{
        source = assets.red_message
    }
    
    zip_bg.anchor_point = {zip_bg.w/2,0}
    
    local prompt = Text{
        text="Change Location:",
        font="DejaVu Sans Condensed 20px",
        color="#000000",
        y = zip_bg.h/2,
    }
    prompt.anchor_point = {
        prompt.w,
        prompt.h/2
    }
    
    local location = Text{
        name="Location",
        text="",
        font="DejaVu Sans Condensed Bold 24px",
        color="#86ad53",
        x = 20,
        y = zip_bg.h/2,
    }
    location.anchor_point = {
        0,
        location.h/2
    }
    
    
    zip.list_locations = function(t)
        location.text = ""
        for name,num in pairs(t) do
            location.text = location.text.."   "..name.." "..num
        end
    end
    
    zip_prompt:add(zip_bg,prompt,location)
end
----------------
local zip_entry = Group{}
do
    local zip_bg = Clone{
        source = assets.zip_entry
    }
    
    zip_bg.anchor_point = {zip_bg.w/2,0}
    
    local prompt = Text{
        text="Enter a zip code:",
        font="DejaVu Sans Condensed 20px",
        color="#000000",
        y = zip_bg.h/2,
    }
    
    prompt.anchor_point = {
        prompt.w,
        prompt.h/2
    }
    
    local entry = {}
    
    for i = 1,5 do
        entry[i] = Text{
            text  = "",
            font  = "DejaVu Sans Condensed Bold 20px",
            color = "#484747",
            y     = zip_bg.h/2,
            x     = 30*i
        }
    end
    
    local response = function(self,response_object)
		
		if response_object.failed then
			
            prompt.text = "Trying Again"
            
            prompt.anchor_point = {
                prompt.w,
                prompt.h/2
            }
            
			print("URLRequest failed. Trying Again")
			
			zip.cancel = self:send()
			
		elseif response_object.code ~= 200 then
			
            prompt.text = "Trying Again"
            
            prompt.anchor_point = {
                prompt.w,
                prompt.h/2
            }
            
			print(
				
				"URLRequest received a reponse code: "..
				
				response_object.code.." - "..
				
				response_object.status
				
			)
            
            zip.cancel = self:send()
			
		else
            
            zip.cancel = nil
            
            dumptable(response.body)
            
        end
    end
    
    local i = 1
    
    
    
    zip.add_number = function(self,num)
        entry[i].text = num
        i = i + 1
        if i == 6 then
            
            prompt.text = "Geocoding"
            
            prompt.anchor_point = {
                prompt.w,
                prompt.h/2
            }
            
            zip.cancel = get_lat_lng_for_zip(
                entry[1]..entry[2]..entry[3]..entry[4]..entry[5],
                response
            )
        end
    end
    
    zip_entry:add(zip_bg,prompt)
    zip_entry:add(unpack(entry))
end

----------------



zip.fade_out = function(self,msecs,p)
    zip.opacity=255*(1-p)
    if p == 1 then
        self.is_up = false
    end
end

--zip.fade_in_entry

zip.timer = Timer{
    interval = 5000,
    on_timer = function(self)
        zip.is_up = false
        self:stop()
        Idle_Loop:add_function(zip.fade_out,zip,500)
    end
}
zip.timer:stop()
zip.is_up = false
zip.anchor_point = {0,zip_bg.h}

return zip