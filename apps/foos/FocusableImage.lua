FocusableImage = Class(function(focusimg, x, y, image_clone, focus_clone, ...)
    assert(x)
    assert(y)
    assert(image_clone)
    assert(focus_clone)
    focusimg.image = Clone{ source = image_clone }
    focusimg.image.position = {x, y}

    focusimg.focus = Clone{ source = focus_clone }
    focusimg.focus.position = {x, y}
    focusimg.group = Group()
    focusimg.group:add(focusimg.image, focusimg.focus)
    
    function focusimg:on_focus()
        focusimg.focus:animate{duration = CHANGE_VIEW_TIME, opacity = 255}
        focusimg.image:animate{duration = CHANGE_VIEW_TIME, opacity = 0}
    end

    function focusimg:out_focus()
        focusimg.focus:animate{duration = CHANGE_VIEW_TIME, opacity = 0}
        focusimg.image:animate{duration = CHANGE_VIEW_TIME, opacity = 255}
    end

end)
