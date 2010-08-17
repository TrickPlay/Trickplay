Slideshow = {}
SLIDESHOW_WIDTH = 1000
SLIDESHOW_HEIGHT = 800
local timer = Timer()
timer.interval = 4
current_pic = 1
temp_pic = 0
local started = true
local search = "space"
local overlay_image = Image { src = "assets/overlay.png", opacity = 0 }
local background = Image {src = "assets/background.jpg" }

screen:add(overlay_image,background)
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
	--[[local temp = current_pic
	self.images[current_pic] = Image { src = site, z = 1000}
	local image = self.images[current_pic]
	
	local rotation_num = math.random(30) - 15 
	local rotation = {rotation_num, image.w/2, image.h/2}
	
	self.images[current_pic].z_rotation = rotation
	self.images[current_pic].x = screen.w/2 - self.images[current_pic].w/2
	self.images[current_pic].y = screen.h/2 - self.images[current_pic].h/2 
	
	local overlay = Clone { source = overlay_image, z = 1000}
	overlay.scale = {self.images[current_pic].w/(overlay.w-60), self.images[current_pic].h/(overlay.h-60)}
	rotation = {rotation_num, overlay.w/2, overlay.h/2}

	overlay.z_rotation = rotation

	overlay.x = screen.w/2 - self.images[current_pic].w/2 - 20
	overlay.y = screen.h/2 - self.images[current_pic].h/2 - 20
	overlay:animate {
		duration = 2000,
		z = 0,
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
	end]]
	local temp = current_pic
	self.images[current_pic] = Group {z = 1000}
	local image = Image { src = site }
	local overlay = Clone { source = overlay_image, scale = {image.w/(screen.w-100), image.h/(screen.h-100) }, x = (-image.w)/40, y = (-image.h)/20}
	self.images[current_pic].scale = {SLIDESHOW_HEIGHT/image.h, SLIDESHOW_HEIGHT/image.h}
	local i_width = image.w * SLIDESHOW_HEIGHT/image.h
	self.images[current_pic].x = screen.w/2 - i_width/2
	self.images[current_pic].y = screen.h/2 - SLIDESHOW_HEIGHT/2
	self.images[current_pic].z_rotation = {math.random(20)-10, i_width/2, SLIDESHOW_HEIGHT/2}
	self.images[current_pic]:add(image,overlay)
	self.ui:add(self.images[temp])
	self.images[current_pic]:animate {
		duration = 2000,
		z = 0,
		on_completed = function()
			self.images[temp]:animate {
				duration = 20000,
				opacity = 240,
				on_completed = function()
					self.ui:remove(self.images[temp])
					self.images[temp] = {}
				end
			}
			current_pic = current_pic + 1
			
		end
	}
end

function timer.on_timer(timer)
	print("tick"..current_pic)
	if (current_pic ~= temp_pic and started) then
		model.curr_slideshow:loadUrls("http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="..search.."&rsz=1&start="..current_pic.."&imgsz=xxlarge")
		temp_pic = current_pic
	end
end


