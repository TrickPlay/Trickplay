ShowObject = Class(function(self,
                        title_card,  
                        show_name ,  
                        show_desc ,  
                        tv_station,  
                        show_time ,  
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
    self.show_time     = show_time  or "Default Show Time"
    self.query         = query or "%2230%20Rock%22+OR+30rock+OR+%22Liz%20Lemon"..
                         "%22+OR+%22Jack%20Donaghy%22+OR+nbc30rock+OR+%2330rock"
    --self.since_id      = 0
    --self.tweet_g_cache = {}
    --self.results_cache = {}
    --self.tweet_i       = 1
    --self.outstanding_req = false
    --self.pause_stream    = false
    
    self.tweetstream = TweetStream(self)
    
end)

TweetObj = Class(function(t, name,icon,text,time,...)
    t.name = name or "Default Name"
    t.icon = icon or nil
    t.text = text or "Default Message"
    t.time = time or "Sometime ago"
end)