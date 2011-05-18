--ZIP

function get_lat_lng_for_zip(zip, callback)
    
    return URLRequest{ url = "http://maps.googleapis.com/maps/api/geocode/json?sensor=true&address="..zip, on_complete = callback }:send()

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
        prompt.w+40,
        prompt.h/2
    }
    
    local location = Text{
        name="Location",
        text="",
        font="DejaVu Sans Condensed Bold 24px",
        color="#86ad53",
        x = -30,
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
local fade_out_entry, fade_in_entry
local zip_entry = Group{opacity=0}
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
        prompt.w+40,
        prompt.h/2
    }
    
    local entered = Image{
        src = "assets/cell-dark-grey.png",
        x=14,
        y=10,
        tile={true,false},
        w=0
    }
    
    local cursor = Clone{
        source=assets.cell_green,
        x=14,y=10
    }
    
    local entry = {}
    
    for i = 1,5 do
        entry[i] = Text{
            text  = "",
            font  = "DejaVu Sans Condensed Bold 40px",
            color = "#f4fce9",
            y     = zip_bg.h/2,
            x     = 40*i-20
        }
        entry[i].anchor_point={0,entry[i].h/2}
    end
    local i = 1
    local reset = function(invalid)
        for i = 1,5 do
            entry[i].text=""
        end
        if invalid then
            prompt.text="Entered Invalid ZIP"
        else
            prompt.text="Enter a zip code:"
        end
        prompt.anchor_point = {
            prompt.w,
            prompt.h/2
        }
        entered.w = 0
        cursor.x = 14
        cursor.opacity=255
        i=1
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
            print(self.url)
            
            local zip_info = json:parse(response_object.body)
            
            if zip_info.status ~= "OK" then
                print("not ok")
                reset(true)
            elseif  zip_info.results[1].address_components[
                        #zip_info.results[1].address_components
                    ].short_name ~= "US" then
                
                print("not US")
                reset(true)
            else
                local lat = zip_info.results[1].geometry.location.lat
                local lng = zip_info.results[1].geometry.location.lng
                
                
                zip_prompt.opacity=255
                
                --zip_prompt:unparent()
                
                Groupon_Request(
                    "all_deals",
                    Rolodex_Constructor,
                    nil,
                    nil,
                    lat,
                    lng,
                    50
                )
                
                
                Loading_G.opacity=255
                
                Loading_G:raise_to_top()
                
                Loading_G.x = 450
                
                Loading_G.y = screen_h - 200
                
                Idle_Loop:add_function(Loading_G.spinning,Loading_G,2000,true)
                
                Idle_Loop:add_function(fade_out_entry,zip,500)
                
                App_State:change_state_to(STATES.LOADING)
                
            end
            
        end
    end
    
    
    fade_out_entry = function(self,msecs,p)
        zip_entry.opacity=255*(1-p)
        if p == 1 then
            self.entry_is_up = false
            reset(false)
        end
    end
    
    
    zip.add_number = function(self,num)
        if  App_State.rolodex.flipping or
            not Zip.entry_is_up or
            Idle_Loop:has_function(fade_out_entry) or
            Idle_Loop:has_function(fade_in_entry)  or
            i == 6 then
            
            return
        end
        entry[i].text = num
        i = i + 1
        
        entered.w = assets.cell_dark.w*(i-1)
        cursor.x = 14+40*(i-1)
        if i == 6 then
            cursor.opacity=0
            prompt.text = "Geocoding"
            
            prompt.anchor_point = {
                prompt.w+40,
                prompt.h/2
            }
            
            zip.cancel = get_lat_lng_for_zip(
                
                entry[1].text..
                entry[2].text..
                entry[3].text..
                entry[4].text..
                entry[5].text,
                
                response
            )
        end
    end
    
    zip_entry:add(zip_bg,prompt,entered,cursor)
    zip_entry:add(unpack(entry))
end

----------------

zip:add(zip_prompt,zip_entry)

local fade_out_prompt = function(self,msecs,p)
    zip_prompt.opacity=255*(1-p)
    if p == 1 then
        self.prompt_is_up = false
    end
end


zip.fade_out_entry = function(self,msecs,p)
    if Idle_Loop:has_function(fade_out_entry) then
        return
    elseif Idle_Loop:has_function(fade_in_entry) then
         Idle_Loop:remove_function(fade_in_entry)
    end
    Idle_Loop:add_function(fade_out_entry,zip,500)
end

fade_in_entry = function(self,msecs,p)
    zip_entry.opacity=255*(p)
    --print(App_State.rolodex.top_card)
    --dumptable(App_State.rolodex.cards)
    zip.y = -App_State.rolodex.cards[App_State.rolodex.top_card].h
    zip:lower_to_bottom()
end
zip.fade_in_entry = function(self)
    
    if Idle_Loop:has_function(fade_in_entry) then
        return
    elseif Idle_Loop:has_function(fade_out_entry) then
         Idle_Loop:remove_function(fade_out_entry)
    end
    self.entry_is_up = true
    Idle_Loop:add_function(fade_in_entry,zip,500)
end


--zip.fade_in_entry

zip.timer = Timer{
    interval = 5000,
    on_timer = function(self)
        if not Idle_Loop:has_function(fade_out_prompt) then
            self:stop()
            print("a")
            Idle_Loop:add_function(fade_out_prompt,zip,500)
        end
    end
}
zip.timer:stop()
zip.prompt_is_up = false
zip.entry_is_up = false
zip.anchor_point = {0,assets.zip_entry.h-10}

return zip