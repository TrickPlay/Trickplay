FocusableImage = Class(function(focusimg, x, y, image_src, focus_src, ...)
    assert(x)
    assert(y)
    assert(image_src)
    assert(focus_src)
    focusimg.image = Image{
        src = image_src,
        position = {x, y}
    }
    focusimg.focus = Image{
        src = focus_src,
        position = {x, y},
        opacity = 0
    }
    focusimg.group = Group()
    focusimg.group:add(focusimg.image, focusimg.focus)
    
    function focusimg:on_focus()
        focusimg.focus:animate{duration = CHANGE_VIEW_TIME, opacity = 255}
        focusimg.image:animate{duration = CHAGNE_VIEW_TIME, opacity = 0}
    end

    function focusimg:out_focus()
        focusimg.focus:animate{duration = CHANGE_VIEW_TIME, opacity = 0}
        focusimg.image:animate{duration = CHAGNE_VIEW_TIME, opacity = 255}
    end

end)
