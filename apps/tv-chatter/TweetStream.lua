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
        url = url.."&since_id="..string.format("%d",since_id).."&rpp="..20
    else
        url = url.."&rpp="..20
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
    local animate_tweets = Timer{interval= 100} --manual Timeline
    local scroll_thresh  = Timer{interval=1000} --wait-time to scrolling again
    local tweet_gap      = 44 
    
    --state
    local requesting      = false
    local auto_scrolling  = true
    local at_bottom       = true
    local since_id        = 0
    local attempt         = 0
    local num_tweets_on_screen  = 0
    local index_of_bottom_tweet = 0
    
    --when user moves with in the tweet stream
    --wait 10 seconds and start scrolling again
    function scroll_thresh:on_timer()
        auto_scrolling = true
        scroll_thresh:stop()
    end
    
    --resize the tweetstream
    function t:set_w(w)
        group.clip = {group.clip[1],group.clip[2],w,group.clip[4]}
        if #tweets ~= 0 then
            local top_tweet = (index_of_bottom_tweet+1 - num_tweets_on_screen)
            local btm_tweet = (index_of_bottom_tweet)
            local sum = group.clip[4]--tweets[top_tweet].group.y
            for i = btm_tweet,top_tweet,-1 do
                tweets[i].text.w = w
                tweets[i].h = tweets[i].text.y + tweets[i].text.h + tweet_gap
                tweets[i].group.y = sum - tweets[i].h
                sum = tweets[i].group.y
            end
        else
            for _,tweet in ipairs(tweets) do
                tweet.text.w = w
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
        animate_tweets:start()
    end
    function t:out_view()
        animate_tweets:stop()
    end
    function t:receive_focus()
        highlight.opacity=255
    end
    function t:lose_focus()
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
        local d,t
        for i = 0,(#data-1) do
            d = data[#data-i]
            t = { string.match( d.created_at ,
                "^(%u%a%a), (%d%d) (%u%a%a) (%d%d%d%d)"..
                " (%d%d):(%d%d):(%d%d) .*" )
            }
            table.insert(results_cache,
                TweetObj(
                    d.from_user,
                    d.profile_image_url,
                    d.text,
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
    
    function animate_tweets:on_timer()
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
                tweets[i].group.y = tweets[i].group.y - 3
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