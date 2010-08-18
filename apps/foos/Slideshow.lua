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
local background2 = Image {src = "assets/background2.png" }
local caption = Text {font = "Sans 25px", text = "", x = 1530, y = 400}
screen:add(overlay_image,background,background2,caption)

function Slideshow:new(args)
	local num_pics = args.num_pics
	local urls = {}
	local images = {}
	local index = args.index
	search = searches[args.index]
	print ("INDEX: "..args.index)
	print ("SEARCHING: "..search)
	local object = { 
		num_pics = num_pics,
		images = images,
		index = index
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
	
		   site = adapters[self.index][1].site(data)
	   	caption.text = adapters[self.index][1].caption(data)
			self:sendImage(site)
		end
	}
	request:send()
end

-- will control when to load a URL
function Slideshow:begin()
	print ("begin")
	started = true
	current_pic = 1
	temp_pic = 0
	timer:start()
--	local logo = Image { src = adapters[self.index].logoUrl, x = 200, y = 200, z= 3}
--	screen:add(logo)
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
	self.images[current_pic] = Group {z = 500}
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
		--z_rotation = 740-math.random(20)-10,
		on_completed = function()
			if (self.images[temp] ~= nil) then
				self.images[temp]:animate {
					duration = 20000,
					opacity = 240,
					on_completed = function()
						self.ui:remove(self.images[temp])
						self.images[temp] = {}
					end
				}
			end
			current_pic = current_pic + 1
			
		end
	}
end

function timer.on_timer(timer)
	print("tick"..current_pic)
	if (current_pic ~= temp_pic and started) then
		model.curr_slideshow:loadUrls(adapters[1][1].photos(search,current_pic))
		temp_pic = current_pic
	end
end


