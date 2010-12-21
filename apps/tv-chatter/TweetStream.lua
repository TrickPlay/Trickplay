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
            
            if response == nil or response.failed then
                callback(false)
                return
            end
            --print("returning response",response.body)
            callback( json:parse( response.body ).results )
        end
    }
    req:send()
--    error_message.text = "Latest tweet, waiting for more..."
end






--TweetStream Class
TweetStream = Class(function(t,parent,...)
    
    local show_obj      = parent
    local clip_side_gutter = 14
    local group       = Group{clip={0,0,0,0}}
    --local tweet_slate = Group{} --move a group, not a bunch of objects
    local tweets      = {}      --all the tweet groups
                                --format {group,username,time,channel,text,obj}
    local highlight      = Rectangle{w=0,h=0,color = "#595959",opacity = 0,x=-15}
    local results_cache  = {}
    --local animate_tweets = Timer{interval= 100} --manual Timeline
    local animate_tweets = Timeline{loop=true, duration=1000}
    local manual_scroll  = nil
    local scroll_thresh  = Timer{interval=10000} --wait-time to scrolling again
    local auto_scrolling  = true
    
    local fade_in_hl     = Timeline
        {
            duration=200,
            on_new_frame=function(tl,msecs,prog)
                highlight.opacity = 255*prog
            end,
            on_completed=function()
                highlight.opacity=255
            end
        }
    local fade_out_hl    = Timeline
        {
            duration=200,
            on_new_frame=function(tl,msecs,prog)
                highlight.opacity = 255*(1-prog)
            end,
            on_completed=function()
                highlight.opacity=0
                auto_scrolling = true
            end
        }
    local tweet_gap      = 44 
    local sel_i          = 0
    local hl_border      = 25
    --state
    local requesting      = false
    local at_bottom       = true
    local since_id        = 0
    local attempt         = 0
    local num_tweets_on_screen  = 0
    local index_of_bottom_tweet = 0
    
    local error_message = Text{text="",font="Helvetica 22px",color=Show_Time_Color,x=20}
    
    group:add(highlight,error_message)
    
    --when user moves with in the tweet stream
    --wait 10 seconds and start scrolling again
    function scroll_thresh:on_timer()
        auto_scrolling = true
        fade_out_hl:start()
        scroll_thresh:stop()
    end
    
    --resize the tweetstream
    
    function t:resize(w,h,crop_avatar)
        
        if  w == -1 then
            w = group.clip[3]
        end
        if  h == -1 then
            h = group.clip[4]
        end
        
        
        highlight.w =  w+2*clip_side_gutter
        group.y     =  group.y   +  (group.clip[4] - h)
        if crop_avatar then
            group.clip  = {0,group.clip[2],w,h}
            error_message.x = 20
        else
            group.clip  = {110,group.clip[2],w,h}
            error_message.x = 120
        end
        error_message.y = group.clip[4]-35
        if #tweets ~= 0 then
            local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
            local btm_tweet = (index_of_bottom_tweet)
            local sum = group.clip[4]
            for i = btm_tweet,top_tweet,-1 do
                tweets[i].text.w = w- tweets[i].text.x- clip_side_gutter
                tweets[i].time.x = w-clip_side_gutter
		tweets[i].username.w = (tweets[i].time.x-tweets[i].time.w)-tweets[i].username.x
                tweets[i].h = tweets[i].text.y + tweets[i].text.h + tweet_gap
                tweets[i].group.y = sum - tweets[i].h
                sum = tweets[i].group.y
            end
            
            if sum + tweets[top_tweet].h < 0 then
                print("removing tweets")
                while tweets[top_tweet].group.y + tweets[top_tweet].h < 0 do
                    print("unparent")
                    tweets[top_tweet].group:unparent()
                    
                    num_tweets_on_screen = num_tweets_on_screen - 1
                    top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
                    
                    assert(top_tweet <= btm_tweet)
                end
            else
                print("adding tweets")
                while sum > 0 do
                    if top_tweet == 1 then break end
                    print("add")
                    num_tweets_on_screen = num_tweets_on_screen + 1
                    top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
                    
                    group:add(tweets[top_tweet].group)
                    tweets[top_tweet].text.w  = w- tweets[top_tweet].text.x- clip_side_gutter
                    tweets[top_tweet].time.x  = w-clip_side_gutter
                    tweets[top_tweet].h       = tweets[top_tweet].text.y +
                            tweets[top_tweet].text.h + tweet_gap
                    tweets[top_tweet].group.y = sum - tweets[top_tweet].h
                    sum = tweets[top_tweet].group.y
                end
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
        if #tweets ~= 0 then
            animate_tweets:start()
        elseif not requesting then
            requesting = true
            req_page(show_obj.query,  t.url_callback,  since_id)
        end
        --active_stream = t
    end
    function t:out_view()
        animate_tweets:stop()
        --active_stream = nil
    end
    function t:select_tweet(i)
        highlight.y = tweets[i].group.y-hl_border
        highlight.h = tweets[i].h +(2*hl_border-tweet_gap)
    end
    
    
    function t:move_up()
        if highlight.opacity ~= 255 and not fade_in_hl.is_playing then
            fade_in_hl:start()
            auto_scrolling = false
            scroll_thresh:stop()
            scroll_thresh = Timer{interval=10000}
            
            scroll_thresh.on_timer = function(self)
                self:stop()
                fade_out_hl:start()
            end
            scroll_thresh:start()
            return
        end

        auto_scrolling = false
        scroll_thresh:stop()
        scroll_thresh = Timer{interval=10000}
        
        scroll_thresh.on_timer = function(self)
            self:stop()
            fade_out_hl:start()
            animate_tweets:start()
        end
        scroll_thresh:start()
        animate_tweets:stop()
        if manual_scroll ~= nil then
            manual_scroll:stop()
            manual_scroll:on_completed()
        end
        manual_scroll = Timeline{loop=false,duration=200}
        
        local curr_tweet_y = {}
        local targ_tweet_y = {}
        local curr_hl_h    = highlight.h
        local targ_hl_h    = highlight.h
        local curr_hl_y    = highlight.y
        local targ_hl_y    = highlight.y
        
        if sel_i - 1 < index_of_bottom_tweet+1 - num_tweets_on_screen then
            error_message.opacity=0
            at_bottom = false
            if sel_i - 1 >= 1 then
                print("up to old tweet")
                local sum = 25
                group:add(tweets[sel_i - 1].group)
                tweets[sel_i - 1].text.w = group.clip[3] - tweets[sel_i - 1].text.x- clip_side_gutter
                tweets[sel_i - 1].time.x = group.clip[3] - clip_side_gutter
                tweets[sel_i - 1].h      = tweets[sel_i - 1].text.y +
                            tweets[sel_i - 1].text.h + tweet_gap
                num_tweets_on_screen  = num_tweets_on_screen  + 1
                tweets[sel_i - 1].group.y = sum - tweets[sel_i - 1].h
                
                for j = sel_i - 1,index_of_bottom_tweet do
                    curr_tweet_y[j] = tweets[j].group.y
                    targ_tweet_y[j] = sum
                    sum = sum + tweets[j].h
                end
                targ_hl_h = tweets[sel_i - 1].h +(2*hl_border-tweet_gap)
                
            else
                manual_scroll = nil
                return
            end
        elseif sel_i - 1 == index_of_bottom_tweet+1 - num_tweets_on_screen and
            tweets[sel_i - 1].group.y < 0 then
                error_message.opacity=0
                at_bottom = false
                print("up - to half-clipped tweet")
                local sum = 25
                for j = sel_i - 1,index_of_bottom_tweet do
                    curr_tweet_y[j] = tweets[j].group.y
                    targ_tweet_y[j] = sum
                    sum = sum + tweets[j].h
                end
                targ_hl_h = tweets[sel_i - 1].h +(2*hl_border-tweet_gap)
                targ_hl_y = 0
        elseif tweets[sel_i - 1] ~= nil  then
        print("up - within the bounds",sel_i - 1,index_of_bottom_tweet+1 - num_tweets_on_screen)
            targ_hl_h = tweets[sel_i - 1].h +(2*hl_border-tweet_gap)
            targ_hl_y = tweets[sel_i - 1].group.y - hl_border
        else
            manual_scroll = nil
            auto_scrolling = true
            scroll_thresh:stop()
            return
        end
        
        function manual_scroll:on_new_frame(msecs,prog)
            highlight.h = curr_hl_h + (targ_hl_h-curr_hl_h)*prog
            highlight.y = curr_hl_y + (targ_hl_y-curr_hl_y)*prog
            for j = sel_i - 1,index_of_bottom_tweet do
                if targ_tweet_y[j] ~= nil then
                    tweets[j].group.y = curr_tweet_y[j] +
                        (targ_tweet_y[j]-curr_tweet_y[j])*prog
                end
            end
        end
        
        
        function manual_scroll:on_completed()
            print("comp")
            highlight.h = targ_hl_h
            highlight.y = targ_hl_y
            for j = sel_i - 1,index_of_bottom_tweet do
                if targ_tweet_y[j] ~= nil then
                    tweets[j].group.y = targ_tweet_y[j]
                end
            end
            
            sel_i = sel_i - 1
            
            while tweets[index_of_bottom_tweet].group.y >= group.clip[4] do
                tweets[index_of_bottom_tweet].group:unparent()
                num_tweets_on_screen  = num_tweets_on_screen - 1
                index_of_bottom_tweet = index_of_bottom_tweet - 1 
            end
            
            print((index_of_bottom_tweet+1 - num_tweets_on_screen),sel_i,index_of_bottom_tweet)
            manual_scroll = nil
        end
        manual_scroll:start()
    end
    
    function t:move_down()
        if highlight.opacity ~= 255 and not fade_in_hl.is_playing then
            fade_in_hl:start()
            auto_scrolling = false
            scroll_thresh:stop()
            scroll_thresh = Timer{interval=10000}
            
            scroll_thresh.on_timer = function(self)
                self:stop()
                fade_out_hl:start()
            end
            scroll_thresh:start()
            return
        end
        auto_scrolling = false
        scroll_thresh:stop()
        scroll_thresh = Timer{interval=10000}
        scroll_thresh.on_timer = function(self)
            self:stop()
            fade_out_hl:start()
            animate_tweets:start()
        end
        scroll_thresh:start()
        animate_tweets:stop()
        if manual_scroll ~= nil then
            manual_scroll:stop()
            manual_scroll:on_completed()
        end
        manual_scroll = Timeline{loop=false,duration=200}
        
        local curr_tweet_y = {}
        local targ_tweet_y = {}
        local curr_hl_h    = highlight.h
        local targ_hl_h    = highlight.h
        local curr_hl_y    = highlight.y
        local targ_hl_y    = highlight.y
        
        if sel_i + 1 > index_of_bottom_tweet then
            print("load in a tweet from the bottom",sel_i + 1,index_of_bottom_tweet)
            if not at_bottom then
            
                print("not the last tweet")
                if index_of_bottom_tweet < #tweets then
                    print("bringing in a previously loaded tweet")
                    group:add(tweets[sel_i + 1].group)
                    tweets[sel_i + 1].text.w = group.clip[3] - tweets[sel_i + 1].text.x- clip_side_gutter
                    tweets[sel_i + 1].time.x = group.clip[3] - clip_side_gutter
                    tweets[sel_i + 1].group.y = tweets[sel_i].group.y + tweets[sel_i].h

                elseif self:next_tweet() then
                    print("successfully next_tweeted")
                    if tweets[sel_i] ~= nil then
                        tweets[sel_i + 1].group.y = tweets[sel_i].group.y + tweets[sel_i].h
                    else
                        tweets[sel_i + 1].group.y = group.clip[4]
                    end

                else
                    print("next_tweeted unsuccessfully")
                    at_bottom = true
                    manual_scroll = nil
                    error_message.opacity=255
                    return
                end
                
                num_tweets_on_screen  = num_tweets_on_screen  + 1
                index_of_bottom_tweet = index_of_bottom_tweet + 1
                
                local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
                local sum = group.clip[4]
                for j = index_of_bottom_tweet,top_tweet,-1 do
                    curr_tweet_y[j] = tweets[j].group.y
                    targ_tweet_y[j] = sum - tweets[j].h
                    sum = sum - tweets[j].h
                end
                targ_hl_h = tweets[sel_i + 1].h +(2*hl_border-tweet_gap)
                targ_hl_y = group.clip[4]-tweets[sel_i + 1].h - hl_border
            else
            print("me")
                manual_scroll = nil
                error_message.opacity=255
                return
            end
        elseif sel_i + 1 == index_of_bottom_tweet and

            tweets[sel_i + 1].group.y + tweets[sel_i + 1].h >(group.clip[4]) then
            print("down - clipped tweet")            
            local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
            local sum = group.clip[4]
            --[[
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
            --]]
            for j = index_of_bottom_tweet,top_tweet,-1 do
                curr_tweet_y[j] = tweets[j].group.y
                targ_tweet_y[j] = sum - tweets[j].h
                sum = sum - tweets[j].h
            end
            targ_hl_h = tweets[sel_i + 1].h +2*hl_border
            targ_hl_y = group.clip[4]-tweets[sel_i + 1].h - hl_border
        else
            print("selecting within the bounds")
            --[[
            self:select_tweet(sel_i + 1)
            sel_i = sel_i + 1
            --]]
            targ_hl_h = tweets[sel_i + 1].h +(2*hl_border-tweet_gap)
            targ_hl_y = tweets[sel_i + 1].group.y - hl_border
        end
        
        function manual_scroll:on_new_frame(msecs,prog)
        local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
            highlight.h = curr_hl_h + (targ_hl_h-curr_hl_h)*prog
            highlight.y = curr_hl_y + (targ_hl_y-curr_hl_y)*prog
            
            for j = index_of_bottom_tweet,top_tweet,-1 do
                if targ_tweet_y[j] ~= nil then
                    tweets[j].group.y = curr_tweet_y[j] +
                        (targ_tweet_y[j]-curr_tweet_y[j])*prog
                end
            end
        end
        
        function manual_scroll:on_completed()
            local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
            highlight.h = targ_hl_h
            highlight.y = targ_hl_y
            for j = index_of_bottom_tweet,top_tweet,-1 do
                if targ_tweet_y[j] ~= nil then
                    print(targ_tweet_y[j])
                    tweets[j].group.y = targ_tweet_y[j]
                end
            end
            
            sel_i = sel_i + 1
            
            while tweets[top_tweet].group.y + tweets[top_tweet].h <= 0 do
                tweets[top_tweet].group:unparent()
                num_tweets_on_screen = num_tweets_on_screen - 1
                top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
            end
            
            print((index_of_bottom_tweet+1 - num_tweets_on_screen),sel_i,index_of_bottom_tweet)
            manual_scroll = nil
        end
        manual_scroll:start()
    end
    
    
    function t:receive_focus()
        
        if num_tweets_on_screen ~= 0 then        print("num_onscreen")
            local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
            local btm_tweet = (index_of_bottom_tweet)
            --highlight.opacity=255
            --auto_scrolling = false
            --scroll_thresh:start()
            
            --if the top tweet is half out of the tweetstream highlight the next one
            if tweets[top_tweet].group.y <= 0 then
                print("hangin above")
                self:select_tweet(top_tweet+1)
                sel_i = top_tweet+1
            --if the top tweet is hanging half way off the bottom of the tweet stream then
            --bring that nigga up
            elseif tweets[top_tweet].group.y + tweets[top_tweet].h >= group.clip[4] then
                print("hangin below")
                tweets[top_tweet].group.y = group.clip[4] - tweets[top_tweet].h
                self:select_tweet(top_tweet)
                sel_i = top_tweet
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
                error_message.text = "Twitter isn't sending responds, giving up"
                return
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
            error_message.text = "Twitter didn't respond. Trying again"
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
            error_message.text = "Latest tweet, waiting for more..."
            return
        end
        error_message.text = ""
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
        animate_tweets:start()
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
                            x     = 110,
                            y     = -7,
                            ellipsize = "END"
        }
        local time       = Text{
                            text  = time_diff(tweet_obj.time),
                            font  = Time_Font,
                            color = Time_Color,
                            x     = group.clip[3]-clip_side_gutter,
                            y     = -5
        }
        local text       = Text{
                            text  = tweet_obj.text,
                            font  = User_text_Font,
                            color = User_text_Color,
                            wrap  = true,
                            word_wrap = "WORD_CHAR",
                            w     = group.clip[3]- clip_side_gutter,
                            x     = 110,
                            y     = 40
        }
        
        text.w = text.w - text.x
        time.anchor_point =
        {
            time.w,
            0
        }
        username.w = (time.x-time.w)-username.x
        local next_tweet = {
            group    = Group{ y = group.clip[4] },
            username = username,
            time     = time,
            text     = text,
            icon     = Image
                        {
                            async = true,
                            src   = tweet_obj.icon,
                            size  = {73,73},
                            x     = 15
                        },
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
    end
    --animate_tweets.stop = nil
    
    --function t:on_idle(last_call)
    function animate_tweets:on_new_frame(msecs,prog)
        local last_call = msecs/1000 - last_msec
        last_msec = msecs/1000
        
        --if you start running out of tweets and didn't already request more
        if #results_cache <= 5 and not requesting then
            requesting = true
            req_page(show_obj.query,  t.url_callback,  since_id)
        end
        --if still auto scrolling and you haven't reached the bottom yet
        if auto_scrolling and not at_bottom then
            error_message.opacity = 0
            local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
            local btm_tweet = (index_of_bottom_tweet)
            --move all the tweets up
            for i = top_tweet,btm_tweet do
                tweets[i].group.y = tweets[i].group.y - scroll_speed * last_call
            end
            
            highlight.y = highlight.y - scroll_speed * last_call
            if highlight.y < 0 then
                sel_i = sel_i + 1
                if tweets[sel_i] ~= nil then
                    highlight.y = tweets[sel_i].group.y - hl_border
                    highlight.h = tweets[sel_i].h +(2*hl_border-tweet_gap)
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
                if index_of_bottom_tweet < #tweets then
                    print("bringing in a previously loaded tweet")
                    group:add(tweets[index_of_bottom_tweet + 1].group)
                    tweets[index_of_bottom_tweet + 1].text.w = group.clip[3] - tweets[index_of_bottom_tweet + 1].text.x- clip_side_gutter
                    tweets[index_of_bottom_tweet + 1].time.x = group.clip[3] - clip_side_gutter
                    tweets[index_of_bottom_tweet + 1].group.y = tweets[index_of_bottom_tweet].group.y + tweets[index_of_bottom_tweet].h
                    num_tweets_on_screen  = num_tweets_on_screen  + 1
                    index_of_bottom_tweet = index_of_bottom_tweet + 1
                elseif t:next_tweet() then
                    num_tweets_on_screen  = num_tweets_on_screen  + 1
                    index_of_bottom_tweet = index_of_bottom_tweet + 1
                else
                    at_bottom = true
                    animate_tweets:stop()
                end
            end
        elseif at_bottom then
            error_message.opacity = 255
        end
    end
    
    
end)
