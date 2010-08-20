AssetLoader = {}

function AssetLoader:checkPreload(calledFrom)
   print("Finished preloading: ".. calledFrom)
   local ready = 0
   for name, status in pairs(self.preloaded) do
      if not status then
         ready = 0
         break
      else
         ready = 1
      end
   end
   if ready == 1 then
      if self.on_preload_ready then self.on_preload_ready() end
   end
end

function AssetLoader:getImage(name,defaults)
   if self.assets[name] == nil then
      self.assets[name] = Image(defaults)
      self.assets[name]:hide()
      screen:add(self.assets[name])
   elseif self.assets[name].parent == nil then
      self.assets[name]:hide()
      screen:add(self.assets[name])
   end
   local the_clone = Clone{ source=self.assets[name] }
   the_clone:show()
   if defaults ~= nil then
      the_clone:set(defaults)
   end
   return the_clone
end

function AssetLoader:preloadImage( name , location )
   self.assets[name] = Image{ async=true , src=location }
   self.preloaded[name] = false;
   self.assets[name].on_loaded = function() 
      AssetLoader.preloaded[name] = true;
      AssetLoader:checkPreload(name)
   end
end

function AssetLoader:construct()
   self.preloaded = {}
   self.assets = {}
end

function AssetLoader:addAllToScreen()
   for k,image in pairs(self.assets) do
      image:hide()
      screen:add(image)
   end
end


