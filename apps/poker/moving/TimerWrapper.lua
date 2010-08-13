TimerWrapper = Class(nil,function(self,...)
   local timer = Timer()

   function self:enable(args)
      timer:stop()
      timer.on_timer = function(timer)
         timer:stop()
         args.on_timer()
      end
      timer.interval = args.interval or 1
      timer:start()
   end

   function self:disable()
      timer:stop()
      timer.on_timer = function(timer) end
      timer.interval = 0
   end
end)