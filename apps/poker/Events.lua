Event = Class(nil,function(event,...)
end)

TimerEvent = Class(Event,function(event,args,...)
   if args then
      assert(type(args) == "table", "Event constructor uses named parameters. e.g. pass in a table.")
      event.interval = args.interval or 0
      event.cb = args.cb
   end
end)

KbdEvent = Class(Event,
function(event,args,...)
   if args then
      assert(type(args) == "table", "Event constructor uses named parameters. e.g. pass in a table.")
      event.key = args.key
      event.cb = args.cb
   end
end)

BetEvent = Class(Event,function(event,args,...)
   if args then
      assert(type(args) == "table", "Event constructor uses named parameters. e.g. pass in a table.")
      event.fold = args.fold
      event.bet = args.bet
      event.cb = args.cb
   end
end)