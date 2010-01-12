
function parse_rss_feed(url)

    local result={}
    local elements={}
    local item=nil
    
    local function path()
        return table.concat(elements,"/")
    end
    
    XMLParser
        {
            on_start_element =
            
                function(parser,tag,attributes)
                    table.insert(elements,tag)
                    --print(string.rep("  ",#elements),path())
                    if path()=="rss/channel/item" then
                        item={}
                    end
                end,
                
            on_end_element =
            
                function(parser,tag)
                    if path()=="rss/channel/item" then
                        table.insert(result,item)
                        item=nil
                    end
                    table.remove(elements)
                end,
                
            on_character_data =
            
                function(parser,data)
                    --print(string.rep("  ",#elements+1),"["..data.."]")
                    if item then
                        local p=path()
                        if p=="rss/channel/item/title" then
                            item.title=data
                        elseif p=="rss/channel/item/link" then
                            item.link=data
                        end
                    end
                end
                
        }:parse(URLRequest(url):perform().body)

    return result
end

local url="http://en-us.fxfeeds.mozilla.com/en-US/firefox/headlines.xml"

local items=parse_rss_feed(url)

for i,item in ipairs(items) do
    print(i)
    for k,v in pairs(item) do
        print("  ",k,"=",v)
    end
end

