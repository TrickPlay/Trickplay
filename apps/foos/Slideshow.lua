Slideshow = {}
local timer = Timer()
timer.interval = 4
current_pic = 1
temp_pic = 0
local started = true
local search = "space"
local overlay_image = Image { src = "assets/overlay.png", opacity = 0 }
screen:add(overlay_image)
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
	local temp = current_pic
	self.images[current_pic] = Image { src = site, z = 1000}
	local rotation_num = math.random(30) - 15 
	local rotation = {rotation_num, self.images[current_pic].w, self.images[current_pic].h}
	
	self.images[current_pic].z_rotation = rotation
	self.images[current_pic].x = screen.w/2 - self.images[current_pic].w/2
	self.images[current_pic].y = screen.h/2 - self.images[current_pic].h/2 
	
	local overlay = Clone { source = overlay_image, z = 1000}
	rotation = {rotation_num, overlay.w, overlay.h}
	overlay.x = screen.w/2 - self.images[current_pic].w/2
	overlay.y = screen.h/2 - self.images[current_pic].h/2 
	overlay.scale = {self.images[current_pic].w/screen.w, self.images[current_pic].h/screen.h}
	overlay.z_rotation = rotation
	overlay:animate {
		duration = 2000,
		z = 1,
		on_completed = function()
			if (self.images[current_pic-3] ~= nil) then
				overlay.opacity = 0
			end
		end
	}
	self.images[current_pic]:animate {
		duration = 2000,
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
		self.ui:add(self.images[temp], overlay)
	end

end

function timer.on_timer(timer)
	print("tick"..current_pic)
	if (current_pic ~= temp_pic and started) then
		model.curr_slideshow:loadUrls("http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="..search.."&rsz=1&start="..current_pic.."&imgsz=xxlarge")
		temp_pic = current_pic
	end
end


