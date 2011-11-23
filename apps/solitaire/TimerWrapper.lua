TimerWrapper = Class(nil,function(self,...)
   local timer = Timer()

   self.enabled = false
   function self:enable(args)
      timer:stop()
      if type(args) == "function" then
         timer.on_timer = args
      elseif type(args) then
         assert(type(args.on_timer) == "function")
         timer.on_timer = function(timer)
            timer:stop()
            args.on_timer()
         end
         timer.interval = args.interval or 1000
      end

      timer:start()
      self.enabled = true
   end

   function self:disable()
      timer:stop()
      timer.on_timer = function(timer) end
      timer.interval = 0
      self.enabled = false
   end

   function self:complete()
      timer:stop()
      if timer.on_timer then timer:on_timer() end
      self.enabled = false
   end
end)
t = TimerWrapper()
