FocusableImage = Class(function(focusimg, x, y, image_src, focus_src, ...)
    assert(x)
    assert(y)
    --assert(image_src)
    --assert(focus_src)

    focusimg.x = x
    focusimg.y = y
    focusimg.extra = {}
    
    if image_src and type(image_src) == "string" then
        focusimg.image = assetman:get_clone(image_src,{position = {0, 0}})
    elseif image_src then
        focusimg.image = image_src
    end
    
    if focus_src and type(focus_src) == "string" then
       focusimg.focus =
            AssetLoader:getImage(focus_src,{position={0, 0},opacity = 0})
    elseif focus_src then
        focusimg.focus = focus_src
    end

    focusimg.group = Group{position = {x, y}}
    if image_src then focusimg.group:add(focusimg.image) end
    focusimg.group:add(focusimg.focus)
    
    function focusimg:on_focus()
        focusimg.focus:animate{duration = CHANGE_VIEW_TIME, opacity = 255}
        if focusimg.image then focusimg.image:animate{duration = CHANGE_VIEW_TIME, opacity = 0} end
    end

    function focusimg:out_focus()
        focusimg.focus:animate{duration = CHANGE_VIEW_TIME, opacity = 0}
        if focusimg.image then focusimg.image:animate{duration = CHANGE_VIEW_TIME, opacity = 255} end
    end

    function focusimg:on_focus_inst()
        if focusimg.focus then focusimg.focus.opacity = 255 end
        if focusimg.image then focusimg.image.opacity = 0 end
    end

    function focusimg:out_focus_inst()
        if focusimg.focus then focusimg.focus.opacity = 0 end
        if focusimg.image then focusimg.image.opacity = 255 end
    end

end)
