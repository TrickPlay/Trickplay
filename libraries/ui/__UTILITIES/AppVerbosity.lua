
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


local usage = [[

------------------------------------------------------------
Usage for:    mesg( mesg_verbosity, stack, ...)

            mesg_verbosity:
                - non-nil value, typically a string
            stack:
                - positive number
                - {positive number,positive number} where
                  the first number is less than the second
            "...":
                - whatever you would typically pass to
                    print
------------------------------------------------------------]]
local app_verbosity = {}

local m, stack_m

local stack_trace_prefix = "\nStack Trace:\n"
local stack_trace_postfix = "\n"

local function pcall_error(mesg,stack)

    -- pcall(error,mesg,3+stack)    returns this:
    --      false [string "__UTILITIES/Misc.lua"]:133: table: 0x2097e90:notify() was called

    -- ({...})[2]       removes the first argument returning this:
    --      [string "__UTILITIES/Misc.lua"]:133: table: 0x2097e90:notify() was called

    -- (...):sub(9)     removes "[ string" and re-adds "[" returning this:
    --      ["__UTILITIES/Misc.lua"]:133: table: 0x2097e90:notify() was called

    --return "["..( (( {pcall(error,mesg,4+stack)} )[2]):sub(9) )
    --[[
    print(pcall(error,mesg,4))
    print(pcall(error,mesg,(4+stack)))
    if 4+stack == 6 then
        error(mesg,4+stack)
    end
    print(( {pcall(error,mesg,4+stack)} )[2])
    --]]
    return "["..( (( {pcall(error,mesg,4+stack)} )[2]) )

end
function mesg(mesg_verbosity,stack,...)

    if mesg_verbosity== nil then error(usage.."\nReceived 'nil' mesg_verbosity",2) end
    if not app_verbosity[mesg_verbosity] then return end

    --TODO, fold in dumptable
    m = ""
    -- used to concatenate a list a arguments to print
    for i,v in ipairs({...}) do   m = m..tostring(v).." "   end

    if type(stack) == "number" then

        m = pcall_error(m,stack)

    --if stack is a range of numbers
    elseif type(stack) == "table" then

        if type(stack[1]) ~= "number" then
            error(usage.."\nReceived '"..type(stack[1]).."' for stack[1]",2)
        end
        if type(stack[2]) ~= "number" then
            error(usage.."\nReceived '"..type(stack[2]).."' for stack[2]",2)
        end
        if stack[1] < 0 then
            error(usage.."\nReceived '"..tostring(stack[1]).."' for stack[1].\n"..
            "Must be positive ",2)
        end
        if stack[1] < 0 then
            error(usage.."\nReceived '"..tostring(stack[2]).."' for stack[2].\n"..
            "Must be positive ",2)
        end
        if stack[1] > stack[2] then
            error(usage.."\nReceived {"..tostring(stack[1])..","..tostring(stack[2]).."} for stack.\n"..
            "First number must be less than the second ",2)
            --or stack[2] = stack[1]
        end

        stack_m =  stack_trace_prefix

        for i = stack[2],stack[1]+1,-1 do

            stack_m = stack_m..pcall_error("-----This line called the line below",i).."\n"

        end

        m = stack_m..pcall_error(m,stack[1])..stack_trace_postfix

    else

        error("\nmesg() expected number or table for its 2nd parameter.\n\nReceived: "..type(stack),2)
    end



    print(m)
end
function add_verbosity(v)

    if v == nil then error("verbosity cannot be nil",2) end

    app_verbosity[v] = true
end
function add_verbosities(t)

    if type(t) ~= "table" then error("Expects a table",2) end
    if #t == 0 then error("The table contained nothing",2) end

    for i,v in pairs(t) do  add_verbosity(v)  end
end
function remove_verbosity(v)

    if v == nil then error("verbosity cannot be nil",2) end

    app_verbosity[v] = nil

end
function mute_verbosity()

    app_verbosity = {}

end

external.remove_verbosity = remove_verbosity
external.mute_verbosity   = mute_verbosity
external.add_verbosities  = add_verbosities
external.add_verbosity    = add_verbosity




