url_fetcher = URLFetcher.new()


for i=1,250 do
	print(url_fetcher:fetch('http://www.google.com/'))
end
