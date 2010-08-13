TimerWrapper = Class(nil,function(self,...)
   local timer = Timer()

   function self:enable(args)
      timer:stop()
      function timer.on_timer(timer)
         timer:stop()
         args.on_timer()
      end
      timer.interval = args.interval
      timer:start()
   end

   function self:disable()
      timer:stop()
      function timer.on_timer(timer) end
      timer.interval = 0
   end
end)