Slideshow = {}
local timer = Timer()
timer.interval = 4
current_pic = 1
temp_pic = 0
local started = true
local search = "space"
function Slideshow:new(args)
	local num_pics = args.num_pics
	local urls = {}
	local images = {}
	search = searches[args.index]
	print ("INDEX: "..args.index)
	print ("SEARCHING: "..search)
	local object = { 
		num_pics = num_pics,
		images = images,
	}
   setmetatable(object, self)
   self.__index = self
   return object
end

function Slideshow:loadUrls(url)
	local request = URLRequest {
		url = url,
		on_complete = function (request, response)
			local data = json:parse(response.body)
		   site = data.responseData.results[1].unescapedUrl
			self:sendImage(site)
		end
	}
	request:send()
end

-- will control when to load a URL
function Slideshow:begin()
	print ("begin")
	started = true
	timer:start()
end
function Slideshow:stop()
   	timer:stop()
  	     started = false

		  if (self.images[current_pic] ~= nil) then
   	     
	        self.images[current_pic]:complete_animation()
   	     self.images = {}
   	  end
end
-- will send and image across the screen
function Slideshow:sendImage(site)
	print(site)
	local temp = current_pic
	self.images[current_pic] = Image { src = site, z = 1000}
	self.images[current_pic].x = screen.w/2 - self.images[current_pic].w/2
	self.images[current_pic].y = screen.h/2 - self.images[current_pic].h/2 
	self.images[current_pic]:animate {
		duration = 3000,
		z = 0,
		on_completed = function()
			current_pic = current_pic+1
			if (self.images[current_pic-3] ~= nil) then
				print (current_pic-3)
				self.images[current_pic-3].opacity = 0
				table.remove(self.images,current_pic-3)
			end
		end
	}
	if self.ui ~= nil then
		print("adding to view.ui",self.ui)
		self.ui:add(self.images[temp])
	end

end

function timer.on_timer(timer)
	print("tick"..current_pic)
	if (current_pic ~= temp_pic and started) then
		model.curr_slideshow:loadUrls("http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="..search.."&rsz=1&start="..current_pic.."&imgsz=xxlarge")
		temp_pic = current_pic
	end
end


