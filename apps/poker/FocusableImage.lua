FocusableImage = Class(function(focusimg, x, y, image_src, focus_src, ...)
    assert(x)
    assert(y)
    --assert(image_src)
    --assert(focus_src)
    
    if image_src then
        focusimg.image = AssetLoader:getImage(image_src,{ position = {x, y} })
    end
        
    focusimg.focus = AssetLoader:getImage(focus_src,{ position = {x, y}, opacity = 0 })

    focusimg.group = Group()
    if image_src then focusimg.group:add(focusimg.image) end
    focusimg.group:add(focusimg.focus)
    
    function focusimg:on_focus()
        focusimg.focus:animate{duration = CHANGE_VIEW_TIME, opacity = 255}
        if image_src then focusimg.image:animate{duration = CHANGE_VIEW_TIME, opacity = 0} end
    end

    function focusimg:out_focus()
        focusimg.focus:animate{duration = CHANGE_VIEW_TIME, opacity = 0}
        if image_src then focusimg.image:animate{duration = CHANGE_VIEW_TIME, opacity = 255} end
    end

end)
