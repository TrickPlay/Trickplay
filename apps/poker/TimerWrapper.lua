TimerWrapper = Class(nil,function(self,...)
   local timer = Timer()

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
         timer.interval = args.interval or 1
      end

      timer:start()
   end

   function self:disable()
      timer:stop()
      timer.on_timer = function(timer) end
      timer.interval = 0
   end
end)
t = TimerWrapper()