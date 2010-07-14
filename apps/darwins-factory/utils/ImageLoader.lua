ImageLoader = class(function(self)
    self._image = {}
end)

function ImageLoader:load(src, properties)

    assert(src, "trying to get image without a source!")

    properties = properties or {}

    if not self._image then self._image = {} end

    if not self._image[src] then
        local new_image = Image{src=src}
        new_image:hide()
        screen:add(new_image)
        self._image[src] = new_image
    end

    local clone = Clone{source=self._image[src]}

    for k,v in pairs(properties) do
        clone[k] = v
    end

    return clone
end
