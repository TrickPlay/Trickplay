-------------------------------------------------------------------------------

function parse_rss_feed(rss,parts)

    local result={}
    local elements={}
    local item=nil
    
    local text_to_find={}
    local attributes_to_find={}
    for k,v in pairs(parts) do
        if string.find(k,".",1,true) then
            attributes_to_find["rss/channel/item/"..k]=v
        else
            text_to_find["rss/channel/item/"..k]=v
        end
    end
    
    local function path()
        return table.concat(elements,"/")
    end
    
    XMLParser
        {
            on_start_element =
            
                function(parser,tag,attributes)
                    table.insert(elements,tag)
                    
                    local p=path()
                    --print(string.rep("  ",#elements),p)
                    if p=="rss/channel/item" then
                        item={}
                    elseif item then
                        for k,v in pairs(attributes) do
                            local s=attributes_to_find[p.."."..k]
                            if s then
                                item[s]=v
                                break
                            end
                        end
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
                        local s=text_to_find[path()]
                        if s then
                            item[s]=data
                        end
                    end
                end
                
        }:parse(rss)

    return result
end

-------------------------------------------------------------------------------

function get_rss_feed(url,parts,callback)

    URLRequest
        {
            url=url,
            on_complete=
            
                function(request,response)
                    request.on_complete=nil
                    if response.failed then
                        print("REQUEST FOR",url,"FAILED")
                    else
                        callback(parse_rss_feed(response.body,parts))
                    end
                end
        }:send()
end

-------------------------------------------------------------------------------

function process_items(items)
    for i,item in pairs(items) do
        print(i)
        table.foreach(item,print)
    end
end

local discovery_parts={["title"]="title",["description"]="desc",["media:thumbnail.url"]="image"}

get_rss_feed("http://animal.discovery.com/news/news.rss",discovery_parts,process_items)
