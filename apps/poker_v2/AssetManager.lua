AssetManager = Class(function(assetman, ...)

    local images = {}
    local groups = {}
    local texts = {}
    local rects = {}
    -- always increasing, does not decrease on deletion
    local number_of_groups_made = 0
    local number_of_texts_made = 0
    local number_of_rects_made = 0

    function assetman:show_all()
        print("\n\nIMAGES\n")
        for k,image in pairs(images) do
            print("\tImage: name = "..image.image.name)
            print("\t\tCLONES = "..image.times_cloned.."\n")
            for _,clone in pairs(image.clones) do
                print("\t\t\tClone: name = "..clone.name.." parent = "
                    ..tostring(clone.parent))
            end
        end
    end

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
        if not image then
            error("image could not be loaded", 2)
        end

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

        function clone:dealloc()
            assetman:remove_clone(self)
        end

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
            error("group name "..args.name.." already in use", 2)
        end
        if groups[args.name] then
            self:remove_group(args.name)
        end

        local group = Group(args)
        groups[args.name] = group
        number_of_groups_made = number_of_groups_made + 1

        function group:dealloc()
            for i,child in ipairs(self.children) do
                print("deleting child with name "..child.name
                    .." from group with name "..self.name)
                child:dealloc()
            end
            print("deleting group with name "..self.name)
            assetman:remove_group(self.name)
        end

        return group
    end

    function assetman:remove_group(name)
        if type(name) ~= "string" then
            error("group name must be a string", 2)
        end

        if groups[name].children[1] then
            print("WARNING: deleting group "..group.." of name "..group.name
                .." that has children!")
        end

        if groups[name].parent then
            groups[name]:unparent()
        end
        groups[name] = nil
    end

    function assetman:create_text(args, overwrite)
        if type(args) ~= "table" then
            error("args must be a table", 2)
        end
        if not args.text then
            error("args must have a text property", 2)
        end
        if not args.name then
            args.name = args.text
        end
        if texts[args.name] and not overwrite then
            error("text name "..args.name.." already in use", 2)
        end
        if texts[args.name] then
            self:remove_text(args.name)
        end

        local text = Text(args)
        texts[args.name] = text
        number_of_texts_made = number_of_texts_made + 1

        function text:dealloc()
            assetman:remove_text(self.name)
        end

        return text
    end

    function assetman:remove_text(name)
        if type(name) ~= "string" then
            error("text name must be a string", 2)
        end

        if texts[name].parent then
            texts[name]:unparent()
        end
        texts[name] = nil
    end

    function assetman:create_rect(args, overwrite)
        if type(args) ~= "table" then
            error("args must be a table", 2)
        end
        if not args.name then
            args.name = "rect_"..number_of_rects_made
        end
        if rects[args.name] and not overwrite then
            error("rect name "..args.name.." already in use", 2)
        end
        if rects[args.name] then
            self:remove_rects(args.name)
        end

        local rect = Rectangle(args)
        rects[args.name] = rect
        number_of_rects_made = number_of_rects_made + 1

        function rect:dealloc()
            assetman:remove_rect(self.name)
        end

        return rect
    end

    function assetman:remove_rect(name)
        if type(name) ~= "string" then
            error("rect name must be a string", 2)
        end

        if rects[name].parent then
            rects[name]:unparent()
        end
        rects[name] = nil
    end

end)
