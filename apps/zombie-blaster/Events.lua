Event = Class(nil,function(event,...)
end)

--[[
    A notify is sent to every observer attached to the router.
    The observer should check the current state and update any dependencies.
--]]
NotifyEvent = Class(Event,
function(event, args, ...)
    if args then
        assert(type(args) == "table", "Event constructor uses named parameters. e.g. pass in a table.")
        event.cb = args.cb
    end
end)

--[[
    Resets the game
--]]
ResetEvent = Class(Event,
function(event, args, ...)
    if args then
        assert(type(args) == "table", "Event constructor uses named parameters. e.g. pass in a table.")
        event.cb = args.cb
    end
end)

--[[
    Signifies a key being pressed.
--]]
KbdEvent = Class(Event,
function(event,args,...)
    if args then
        assert(type(args) == "table", "Event constructor uses named parameters. e.g. pass in a table.")
        event.key = args.key
        event.cb = args.cb
    end
end)
