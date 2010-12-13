--look at the global "focus"
local months   = {
    Jan = 1,
    Feb = 2,
    Mar = 3,
    Apr = 4,
    May = 5,
    Jun = 6,
    Jul = 7,
    Aug = 8,
    Sep = 9,
    Oct = 10,
    Nov = 11,
    Dec = 12
}
local time_diff = function(tweet_time)
    local curr = os.date("!*t",os.time())
    
    local diff = {
        day   = curr.day   - tweet_time.day,
        month = curr.month - tweet_time.month,
        year  = curr.year  - tweet_time.year,
        hour  = curr.hour  - tweet_time.hour,
        min   = curr.min   - tweet_time.min,
        sec   = curr.sec   - tweet_time.sec
    }
    if diff.year ~= 0 then
        if diff.year == 1 then  return "1 year ago"
        else                    return diff.year  .." years ago"
        end
    elseif diff.month ~= 0 then 
        if diff.month == 1 then return "1 month ago"
        else                    return diff.month .." months ago"
        end
    elseif diff.day ~= 0 then   
        if diff.day == 1 then   return "1 day ago"
        else                    return diff.day  .." days ago"
        end
    elseif diff.hour ~= 0 then  
        if diff.hour == 1 then  return "1 hour ago"
        else                    return diff.hour .." hours ago"
        end
    elseif diff.min ~= 0 then   
        if diff.min == 1 then   return "1 minute ago"
        else                    return diff.min  .." minutes ago"
        end
    else                        return "1 minute ago"
    end
end
local req_page = function(keywords, callback, since_id)
    print("making request with since id: "..string.format("%d",since_id))
    local url = "http://search.twitter.com/search.json?q="..
        keywords.."&lang=en&lang=en&result_type=recent"
    if since_id ~= 0 then
        url = url.."&since_id="..string.format("%d",since_id).."&rpp="..40
    else
        url = url.."&rpp="..40
    end
        print(url)

    local req = URLRequest{
        url = url,
        on_complete = function(request,response)
            
            if response == nil or response.body == nil then
                callback(false)
            end
            print("returning response")
            callback( json:parse( response.body ).results )
        end
    }
    req:send()
end


--Container for the TweetStream
TweetStream = Class(function(t,parent,...)
    
    local show_obj      = parent
    
    local group       = Group{clip={0,0,0,0}}
    --local tweet_slate = Group{} --move a group, not a bunch of objects
    local tweets      = {}      --all the tweet groups
                                --format {group,username,time,channel,text,obj}
    local results_cache  = {}
    --local animate_tweets = Timer{interval= 100} --manual Timeline
    local animate_tweets = Timeline{loop=true,duration=5000}
    local scroll_thresh  = Timer{interval=10000} --wait-time to scrolling again
    local tweet_gap      = 44 
    local highlight = Rectangle{w=0,h=0,color = "#595959",opacity = 0}
    local sel_i     = 0
    --state
    local requesting      = false
    local auto_scrolling  = true
    local at_bottom       = true
    local since_id        = 0
    local attempt         = 0
    local num_tweets_on_screen  = 0
    local index_of_bottom_tweet = 0
    
    group:add(highlight)
    
    --when user moves with in the tweet stream
    --wait 10 seconds and start scrolling again
    function scroll_thresh:on_timer()
        auto_scrolling = true
        scroll_thresh:stop()
    end
    
    --resize the tweetstream
    function t:set_w(w)
        highlight.w = w
        group.clip = {group.clip[1],group.clip[2],w,group.clip[4]}
        if #tweets ~= 0 then
            local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
            local btm_tweet = (index_of_bottom_tweet)
            local sum = group.clip[4]--tweets[top_tweet].group.y
            for i = btm_tweet,top_tweet,-1 do
                tweets[i].text.w = w-100
                tweets[i].time.x = w-10
                tweets[i].h = tweets[i].text.y + tweets[i].text.h + tweet_gap
                tweets[i].group.y = sum - tweets[i].h
                sum = tweets[i].group.y
            end
        end
    end
    function t:set_h(h)
        --assumes y is fixed to bottom
        group.y    = group.y + (group.clip[4] - h)
        group.clip = {group.clip[1],group.clip[2],group.clip[3],h}
        if #tweets ~= 0 then
            local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
            local btm_tweet = (index_of_bottom_tweet)
            local sum = (group.clip[4] - h)
            for i = top_tweet,btm_tweet do
                tweets[i].group.y = tweets[i].group.y + sum
            end
        end
    end
    function t:set_pos(x,y)
        group.position ={x, y}
    end
    function t:get_group()
        return group
    end
    function t:in_view()
        --animate_tweets:start()
        active_stream = t
    end
    function t:out_view()
        --animate_tweets:stop()
        active_stream = nil
    end
    function t:select_tweet(i)
        highlight.y = tweets[i].group.y-25
        highlight.h = tweets[i].h -10
    end
    
    function t:move_up()
        auto_scrolling = false
        scroll_thresh:stop()
        scroll_thresh = Timer{interval=10000}
        scroll_thresh.on_timer = function(self)
            auto_scrolling = true
            self:stop()
        end
        scroll_thresh:start()
        if sel_i - 1 < index_of_bottom_tweet+1 - num_tweets_on_screen then
            if sel_i - 1 >= 1 then
                group:add(tweets[sel_i - 1].group)
                tweets[sel_i - 1].text.w = group.clip[3] - 100
                tweets[sel_i - 1].time.x = group.clip[3] - 10
                tweets[sel_i - 1].time.y = 25
                num_tweets_on_screen  = num_tweets_on_screen  + 1
                local sum = 25
                for j = sel_i - 1,index_of_bottom_tweet do
                    tweets[j].group.y = sum 
                    sum = sum + tweets[j].h
                end
                self:select_tweet(sel_i - 1)
                sel_i = sel_i - 1
                if tweets[index_of_bottom_tweet].group.y >= group.clip[4] then
                    tweets[index_of_bottom_tweet].group:unparent()
                    num_tweets_on_screen  = num_tweets_on_screen - 1
                    index_of_bottom_tweet = index_of_bottom_tweet - 1 
                end
            end
        elseif sel_i - 1 == index_of_bottom_tweet+1 - num_tweets_on_screen and
            tweets[sel_i - 1].group.y < 0 then
            
                local sum = 0
                for j = sel_i - 1,index_of_bottom_tweet do
                    tweets[j].group.y = sum 
                    sum = sum + tweets[j].h
                end
                self:select_tweet(sel_i - 1)
                sel_i = sel_i - 1
                if tweets[index_of_bottom_tweet].group.y >= group.clip[4] then
                    tweets[index_of_bottom_tweet].group:unparent()
                    num_tweets_on_screen  = num_tweets_on_screen - 1
                    index_of_bottom_tweet = index_of_bottom_tweet - 1 
                end
        else
            self:select_tweet(sel_i - 1)
            sel_i = sel_i - 1
        end
    end
    
    function t:move_down()
        auto_scrolling = false
        scroll_thresh:stop()
        scroll_thresh = Timer{interval=10000}
        scroll_thresh.on_timer = function(self)
            auto_scrolling = true
            self:stop()
        end
        scroll_thresh:start()
        if sel_i + 1 > index_of_bottom_tweet then
            print("load in a tweet from the bottom")
            if not at_bottom then
                print("not the last tweet")
                if index_of_bottom_tweet < #tweets then
                    print("bringing in a previously loaded tweet")
                    group:add(tweets[sel_i - 1].group)
                    tweets[sel_i + 1].text.w = group.clip[3] - 100
                    tweets[sel_i + 1].time.x = group.clip[3] - 10
                    num_tweets_on_screen  = num_tweets_on_screen  + 1
                    index_of_bottom_tweet = index_of_bottom_tweet + 1
                    local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
                    local sum = group.clip[4]
                    for i = index_of_bottom_tweet,top_tweet,-1 do
                        tweets[i].group.y = sum - tweets[i].h
                        sum = tweets[i].group.y
                    end
                    self:select_tweet(sel_i + 1)
                    sel_i = sel_i + 1
                    if tweets[top_tweet].group.y + tweets[top_tweet].h <= 0 then
                        tweets[top_tweet].group:unparent()
                        num_tweets_on_screen = num_tweets_on_screen - 1
                    end
                elseif self:next_tweet() then
                    print("successfully next_tweeted")
                    num_tweets_on_screen  = num_tweets_on_screen  + 1
                    index_of_bottom_tweet = index_of_bottom_tweet + 1
                    
                    local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
                    local sum = group.clip[4]
                    
                    for i = index_of_bottom_tweet,top_tweet,-1 do
                        tweets[i].group.y = sum - tweets[i].h
                        sum = tweets[i].group.y
                    end
                    self:select_tweet(index_of_bottom_tweet)
                    sel_i = sel_i + 1
                    if tweets[top_tweet].group.y + tweets[top_tweet].h <= 0 then
                        tweets[top_tweet].group:unparent()
                        num_tweets_on_screen = num_tweets_on_screen - 1
                    end
                else
                    at_bottom = true
                end
            end
        elseif sel_i + 1 == index_of_bottom_tweet and
            
            tweets[sel_i + 1].group.y + tweets[sel_i + 1].h >(group.clip[4]) then
            print("if selecting the bottom tweet (which is 99% likely"..
                " to be hanging off the clip)")
            local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
            local sum = group.clip[4]
            
            for i = index_of_bottom_tweet,top_tweet,-1 do
                tweets[i].group.y = sum - tweets[i].h
                sum = tweets[i].group.y
            end
            self:select_tweet(index_of_bottom_tweet)
            sel_i = sel_i + 1
            if tweets[top_tweet].group.y + tweets[top_tweet].h <= 0 then
                tweets[top_tweet].group:unparent()
                num_tweets_on_screen = num_tweets_on_screen - 1
            end
        else
            print("selecting within the bounds")
            self:select_tweet(sel_i + 1)
            sel_i = sel_i + 1
        end
    end
    
    
    function t:receive_focus()
        
        if num_tweets_on_screen ~= 0 then        print("num_onscreen")
            local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
            local btm_tweet = (index_of_bottom_tweet)
            highlight.opacity=255
            auto_scrolling = false
            scroll_thresh:start()
            
            --if the top tweet is half out of the tweetstream highlight the next one
            if tweets[top_tweet].group.y <= 0 then
             print("hangin above")
                self:select_tweet(top_tweet+1)
            --if the top tweet is hanging half way off the bottom of the tweet stream then
            --bring that nigga up
            elseif tweets[top_tweet].group.y + tweets[top_tweet].h >= group.clip[4] then
             print("hangin below")
                tweets[top_tweet].group.y = group.clip[4] - tweets[top_tweet].h
                self:select_tweet(top_tweet)
            --if neither than just focus on it
            else
             print("reg")
             self:select_tweet(top_tweet)
             sel_i = top_tweet
            end  
        --if there are results that haven't been loaded yet, then throw one on
        elseif #results_cache ~= 0 then
            if self:next_tweet() then
            print("res_cache")
                highlight.opacity=255
                auto_scrolling = false
                scroll_thresh:start()
                num_tweets_on_screen  = num_tweets_on_screen  + 1
                index_of_bottom_tweet = index_of_bottom_tweet + 1
                self:select_tweet(index_of_bottom_tweet)
            else
                at_bottom = true
            end
        --if nothing then wait i guess....
        else
        end
        
    end
    function t:lose_focus()
        auto_scrolling = true
        highlight.opacity=0
        scroll_thresh:stop()
    end
    function t.url_callback(data)
        if data == false then
            if attempt == 5 then
                error("Twitter isn't sending responds")
            end
            attempt = attempt + 1
            local retry = Timer{interval = 30000}
            function retry:on_timer()
                print("trying again")
                dolater(req_page,show_obj.query,t.url_callback,  since_id)
                self:stop()
                self = nil
            end
            retry:start()
            print("waiting 30 seconds, before checking twitter again")
            return
        end
        
        --Got an empty response
        if data == nil or #data == 0 then
            local retry = Timer{interval = 30000}
            function retry:on_timer()
                print("trying again")
                dolater(req_page,show_obj.query,t.url_callback,  since_id)
                self:stop()
                self = nil
            end
            retry:start()
            print("waiting 30 seconds, before checking twitter again")
            return
        end
        print("received actual data")
        local d,t,text
        for i = 0,(#data-1) do
            d = data[#data-i]
            t = { string.match( d.created_at ,
                "^(%u%a%a), (%d%d) (%u%a%a) (%d%d%d%d)"..
                " (%d%d):(%d%d):(%d%d) .*" )
            }
            text = string.gsub(d.text,"&apos;","'")
            text = string.gsub(text,"&quot;","\"")
            text = string.gsub(text,"&lt;","<")
            text = string.gsub(text,"&gt;",">")
            text = string.gsub(text,"&amp;","&")
            table.insert(results_cache,
                TweetObj(
                    d.from_user,
                    d.profile_image_url,
                    text,
                    {
                        day   = t[2] ,
                        month = months[ t[3] ] ,
                        year  = t[4] ,
                        hour  = t[5] ,
                        min   = t[6] ,
                        sec   = t[7]
                    }
                )
            )
            if d.id > since_id then
                since_id = d.id+1
                print(string.format("%d",since_id))
            else
                print("OLD??"..string.format("%d",d.id))
            end
        end
        requesting = false
        at_bottom  = false
    end
    
    --Grabs the next stored search result and adds it to the visible tweets
    function t:next_tweet()
        print("next_tweet")
        if #results_cache == 0 then
            return false
        end
        local tweet_obj  = table.remove(results_cache,1)
        local username   = Text{
                            text  = tweet_obj.name,
                            font  = Username_Font,
                            color = Username_Color,
                            x     = 95,
                            y     = 0
        }
        local time       = Text{
                            text  = time_diff(tweet_obj.time),
                            font  = Time_Font,
                            color = Time_Color,
                            x     = group.clip[3]-10,
                            y     = 0
        }
        local text       = Text{
                            text  = tweet_obj.text,
                            font  = User_text_Font,
                            color = User_text_Color,
                            wrap  = true,
                            word_wrap = "WORD_CHAR",
                            w     = group.clip[3]-100,
                            x     = 95,
                            y     = 40
        }
        time.anchor_point =
        {
            time.w,
            0
        }
        local next_tweet = {
            group    = Group{y = group.clip[4] },
            username = username,
            time     = time,
            text     = text,
            icon     = Image{   async = true,   src = tweet_obj.icon,size={73,73}   },
            h        = text.y + text.h + tweet_gap,
            obj      = tweet_obj
        }
        
        next_tweet.group:add(
            next_tweet.username,
            next_tweet.time,
            next_tweet.text,
            next_tweet.icon
        )
        
        group:add(next_tweet.group)
        table.insert(tweets,next_tweet)
        at_bottom = false
        return true
    end
    
    local px_p_sec = 30
    local last_msec = 0
    function animate_tweets:on_completed()
        last_msec = 0
        print("comp")
    end
    animate_tweets.stop = nil
    --function animate_tweets:on_new_frame(msecs,prog)
    function t:on_idle(last_call)
        --local last_call = msecs - last_msec
        --last_msec = msecs
        ---print(last_call)
        --if you start running out of tweets and didn't already request more
        if #results_cache <= 5 and not requesting then
            requesting = true
            req_page(show_obj.query,  t.url_callback,  since_id)
        end
        --if still auto scrolling and you haven't reached the bottom yet
        if auto_scrolling and not at_bottom then
            local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
            local btm_tweet = (index_of_bottom_tweet)
            --move all the tweets up
            for i = top_tweet,btm_tweet do
                tweets[i].group.y = tweets[i].group.y - px_p_sec * last_call
            end
            
            highlight.y = highlight.y - px_p_sec * last_call
            
            if highlight.y <= 0 then
                if num_tweets_on_screen ~= 0 then
                    if top_tweet == btm_tweet then
                        t:select_tweet(top_tweet)
                    else
                        t:select_tweet(top_tweet+1)
                    end
                end
            end
            
            --remove ones that are no longer visible
            if #tweets ~=0 and tweets[top_tweet].group.y + tweets[top_tweet].h <= 0 then
                tweets[top_tweet].group:unparent()
                num_tweets_on_screen = num_tweets_on_screen - 1
            end
            
            --load a new one
            if #tweets == 0 or tweets[btm_tweet].group.y + tweets[btm_tweet].h <=(group.clip[4])
                 then
                
                --if it was able to load the next tweet
                if t:next_tweet() then
                    num_tweets_on_screen  = num_tweets_on_screen  + 1
                    index_of_bottom_tweet = index_of_bottom_tweet + 1
                else
                    at_bottom = true
                end
            end
        end
    end
    
    
end)