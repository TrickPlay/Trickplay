--print = function() end

Slideshow = {}
SLIDESHOW_WIDTH = 1200
SLIDESHOW_HEIGHT = 800
local timer = Timer()
timer.interval = 4
current_pic = 1
temp_pic = 0
local started = true
local search = "space"
local caption = Text {font = "Sans 15px", text = "", x = 1530, y = 400}
local overlay_image = Image { src = "assets/overlay.png", opacity = 0 }
local background = Image {src = "assets/background.jpg" }
local background2 = Image {src = "assets/background2.png" }

function Slideshow:new(args)
	local num_pics = args.num_pics
	local urls = {}
	local images = {}
	local index = args.index
	local style = dofile("slideshows/Photo/slideshow.lua")
	search = adapters[args.index][1].required_inputs.query
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
	self.ui:add(overlay_image,background,background2,caption)
	local queryText = Text { text = string.gsub(adapters[self.index][1].required_inputs.query,"%%20"," "), font = "Sans 30px", x = 105, y = 300}
	self.ui:add(queryText)
	local logo = Image { src = adapters[self.index].logoUrl, x = 20, y = 130, z= 1, size = {300,225}}
	self.ui:add(logo)
end
function Slideshow:stop()
   	timer:stop()
  	     started = false
		collectgarbage()

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
	local i_height = SLIDESHOW_HEIGHT
	print ("original: "..image.w.." WIDTH:"..i_width)
	if (image.w/image.h > 1.5) then
		self.images[current_pic].scale = {SLIDESHOW_WIDTH/image.w, SLIDESHOW_WIDTH/image.w}
		i_height = i_height * SLIDESHOW_WIDTH/i_width
	end
	self.images[current_pic].x = (math.random(2)-1)*1920
	self.images[current_pic].y = (math.random(2)-1)*1080
	self.images[current_pic].z_rotation = {math.floor(math.random(20)-10), i_width/2, i_height/2}
	self.images[current_pic]:add(image,overlay)
	self.ui:add(self.images[temp])
	self.images[current_pic]:animate {
		duration = 1000,
		mode = EASE_IN_EXPO,
		x = screen.w/2 - i_width/2,
		y = screen.h/2 - i_height/2,
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
		model.curr_slideshow:loadUrls(adapters[model.curr_slideshow.index][1].photos(search,current_pic,model.curr_slideshow.index))
		temp_pic = current_pic
	end
end


