source = {}

function showYahooImage(search,x,y,index)
	local request = URLRequest {
		url = "http://search.yahooapis.com/ImageSearchService/V1/imageSearch?appid=YahooDemo&query="..search.."&results=1&output=json",
		
		on_complete = function (request, response)
			local data = json:parse(response.body)
			local image = Image {
				src = data.ResultSet.Result[index].ClickUrl,
				x = x,
				y = y
			}
			screen:add(image)
		end
	}
	request:send()
end

return source
