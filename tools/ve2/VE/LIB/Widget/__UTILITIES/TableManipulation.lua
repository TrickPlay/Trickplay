
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

function recursive_overwrite(target, source)

    if target == nil then target = {} end

	if type(target) ~= "table" then error("First  arg expected to be table. Received "..type(target),2) end
	if type(source) ~= "table" then error("Second arg expected to be table. Received "..type(source),2) end

    for k,v in pairs(source) do

        --if field is a table
        if type(v) == "table" then

            --recurse
            if type(target[k]) == "table" then

                recursive_overwrite(target[k],v)

            --... and clone
            elseif target[k] == nil then

                target[k] = recursive_overwrite( {}, v)

            end

        --else, just copy value
        elseif target[k] == nil then

            target[k] = v

        end

    end

    return target

end
