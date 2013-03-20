
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

local function is_color(v)

    if type(v) ~= "string" and type(v) ~= "table" then

        return false

    end

    return v

end

local all_colorschemes = setmetatable({},{__mode = 'v'})

ColorScheme = function(parameters)

    if type(parameters) == "string" then

        if all_colorschemes[parameters] then

            return all_colorschemes[parameters]

        else

            parameters = { name = parameters }

        end

    end

	parameters = is_table_or_nil("ColorScheme",parameters)

    local colors = {}

    local children_using_this_style = setmetatable( {}, { __mode = "k" } )

    local instance
    instance = {
        json = function()

            local t = {}

            collectgarbage("collect")

            for name,obj in pairs(all_colorschemes) do

                t[name] = {}

                for property, value in pairs(obj:get_table()) do
                    t[name][property] = value
                end

            end

            return json:stringify(t)

        end,
        to_json = function()
            local t = {}

            for property, value in pairs(instance:get_table()) do
                t[property] = value
            end

            return json:stringify(t)
        end,
        get_table = function()

            return colors

        end,
        update = function()

            collectgarbage("collect")

            for _,update in pairs(children_using_this_style) do

                update(real_table)

            end

        end,
        on_changed = function(self,object,update_function)

            children_using_this_style[object] = update_function

        end
    }

    local name

    local  meta_setters = {
        name = function(v)

            if name ~= nil then all_colorschemes[name] = nil end

            name = check_name( all_colorschemes, instance, v, "ColorScheme" )

        end,
    }
    local meta_getters = {
        name       = function() return name                     end,
        type       = function() return "COLORSCHEME"            end,
        attributes = function()
            return recursive_overwrite({}, colors)
        end,
    }

    setmetatable(
        instance,
        {
            __index = function(t,k)

                func_upval = meta_getters[k]

                if func_upval then

                    return func_upval()

                else

                    return colors[k]-- or "00000000"

                end

            end
        }
    )
    set_up_subscriptions( instance, getmetatable(instance),

        function(t,k,v)

            func_upval = meta_setters[k]

            if func_upval then

                func_upval(v)

            else

                colors[k] = is_color(v)

                t:update() -- this is not Widget.update

            end

        end,

        function(self,t)

            for k,v in pairs(t) do

                self[k] = v

            end

        end
    )

    if parameters.name == nil then instance.name = nil end

    for k,v in pairs(parameters) do instance[k] = v  end

    return instance

end

external.ColorScheme = ColorScheme



