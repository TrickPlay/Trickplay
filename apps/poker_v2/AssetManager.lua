AssetManager = Class(function(assetman, ...)

    local images = {}
    local groups = {}
    -- always increasing, does not decrease on deletion
    local number_of_groups_made = 0

    function assetman:load_image(path, name, overwrite)
        assert(type(name) == "string")
        assert(path)

        if images[name] and not overwrite then
            error("Image with name \""..name.."\" already exists!"
            .." Must set overwrite to \'true\' to overwrite data.", 2)
        end

        local image = Image{
            src = path,
            name = name,
            opacity = 0
        }

        if images[name] then
            assetman:remove_image(name)
        end

        images[name] = {
            image = image,
            clones = {},
            times_cloned = 0
        }
    end

    function assetman:has_image_of_name(name)
        return images[name]
    end

    function assetman:get_clone(image_name, args)
        if not type(image_name) == "string" then
            error("image_name must be a string", 2)
        end
        if not images[image_name] then
            error("images must be loaded before cloned", 2)
        end
        if not images[image_name].image.parent then
            screen:add(images[image_name].image)
        end
        if not args then args = {} end
        args.source = images[image_name].image
        args.name = image_name.."_"..tostring(images[image_name].times_cloned)

        local clone = Clone(args)
        clone.image_name = name
        images[image_name].times_cloned = images[image_name].times_cloned + 1

        images[image_name].clones[clone] = clone

        return clone
    end

    function assetman:remove_clone(clone)
        local image_name = clone.image_name
        if clone.parent then
            clone:unparent()
        end
        images[image_name].clones[clone] = nil
    end

    function assetman:remove_image(name)
        assert(type(name) == "string")
        for k,clone in pairs(images[name].clones) do
            assetman:remove_clone(clone)
        end

        if images[name].image.parent then
            images[name].image:unparent()
        end
        images[name] = nil
    end

    function assetman:create_group(args, overwrite)
        if type(args) ~= "table" then
            error("args must be a table", 2)
        end
        if not args.name then
            args.name = "group "..tostring(number_of_groups_made)
        end
        if groups[args.name] and not overwrite then
            error("all groups must have different names", 2)
        end
        if groups[args.name] then
            self:remove_group(args.name)
        end

        local group = Group(args)
        groups[args.name] = group
        number_of_groups_made = number_of_groups_made + 1

        return group
    end

    function assetman:remove_group(name)
        if type(name) ~= "string" then
            error("group name must be a string", 2)
        end

        if groups[name].parent then
            groups[name]:unparent()
        end
        groups[name] = nil
    end

end)
