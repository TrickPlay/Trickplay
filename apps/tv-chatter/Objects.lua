

ShowObject = Class(function(self,
                        title_card,  
                        show_name ,  
                        show_desc ,  
                        tv_station,
                        show_day,
                        show_time ,
                        show_ampm,
                        add_image ,
                        hash_tags,
                        char_names,
                        ...
                )
    
    local query = ""
    if type(hash_tags) == "table" and type(char_names) == "table" then
        for i=1,#hash_tags do
            query = query.."%23"..hash_tags[i]
            if i ~= #hash_tags then
                query = query.."+OR+"
            end
        end
        
        for i=1,#char_names do
            if query ~= "" then
                query = query.."+OR+"
            end
            --print(char_names[i])
            query = query.."%22"..string.gsub(char_names[i]," ","%%20").."%22"
            
        end
    end
    
    --Default values for all the class fields
    self.title_card   = title_card or nil
    if add_image ~= nil then
        self.add_image    = Image{src=add_image}
    else
        self.add_image = nil
    end
    self.show_name     = show_name  or "Default Show Name"
    self.show_desc     = show_desc  or "Default Sub-Title"
    self.tv_station    = tv_station or "Default TV Station"
    self.show_day      = show_day   or "Sunday"
    self.show_time     = show_time  or 6
    self.show_ampm     = show_ampm  or "pm"
    self.query         = query or "%2230%20Rock%22+OR+30rock+OR+%22Liz%20Lemon"..
                         "%22+OR+%22Jack%20Donaghy%22+OR+nbc30rock+OR+%2330rock"

    self.tweetstream = TweetStream(self)
    local days_r = {
        "Sunday"    ,
        "Monday"    ,
        "Tuesday"   ,
        "Wednesday" ,
        "Thursday"  ,
        "Friday"    ,
        "Saturday"  
    }
    local curr_date = os.date("*t",os.time())
    local time = show_time-math.floor(show_time)
        if time == 0 then
            time = show_time
        else
            time = math.floor(show_time)..":"..(time*60)
        end
        if show_day==days_r[curr_date.wday] then
            if show_ampm == curr_ampm and
                show_time ==  curr_time then
                
                self.show_time_text = "Now Playing"
            else
                self.show_time_text = "Tonight at "..time..show_ampm
            end
        else
            self.show_time_text = show_day.." "..time..show_ampm
        end
end)

TweetObj = Class(function(t, name,icon,text,time,...)
    t.name = name or "Default Name"
    t.icon = icon or nil
    t.text = text or "Default Message"
    t.time = time or "Sometime ago"
end)