
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

function expects(type_wanted, received)
    return type(received) == type_wanted or error(
        "Expected "..type_wanted..". Received "..type(received)..
        " with value '"..received.."'",3
    )
end

function is_ui_element(obj)
    return type(obj) == "userdata" and obj.__types__ and obj.__types__.actor
end

function is_table_or_nil(name,input)

    return input == nil and {} or

        type(input) == "table" and input or

        error(name.." requires a table or nil as input",3)

end

--This function needs a better name
function matches_nil_table_or_type(constructor,req_type,input)

    return input == nil and constructor() or
        type(input) == "string" and constructor(input) or
        type(input) == "table"  and (input.type == req_type and input or constructor(input)) or
        error("input did not match nil, table, or "..req_type,2)

end



check_name = function(curr_names,instance,name,generic)
    --print(generic)
    if name == nil then name = generic end

    if curr_names[name] == nil then

        curr_names[name] = instance

    else

        local i = 1

        while curr_names[name.." ("..i..")"] ~= nil do    i = i + 1    end

        curr_names[name.." ("..i..")"] = instance

        name = name.." ("..i..")"
    end

    return name

end
