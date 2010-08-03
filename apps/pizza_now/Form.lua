Form = Class(function(form, x, y, length, ...)
    form.black = Group{position = {x, y}}
    form.red = Group{position = {x, y}, opacity = 0}
    form.group = Group{}
    local blackLeft = Image{
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeft.png"
    }
    local blackCenter = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenter.png",
        width = length - 20,
        tile = {true, false}
    }
    local blackRight = Image{
        position = {length - 10, 0},
        src = "assets/credit_stuff/TextBoxRight.png"
    }
    form.black:add(blackLeft, blackCenter, blackRight)
    local redLeft = Image{
        position = {0, 0},
        src = "assets/credit_stuff/TextBoxLeftFocus.png"
    }
    local redCenter = Image{
        position = {10, 0},
        src = "assets/credit_stuff/TextBoxCenterFocus.png",
        width = length - 20,
        tile = {true, false}
    }
    local redRight = Image{
        position = {length - 10, 0},
        src = "assets/credit_stuff/TextBoxRightFocus.png"
    }
    form.red:add(redLeft, redCenter, redRight)

    function form:add(...)
       form.group:add(...)
    end
    form:add(form.black, form.red)

    function form:on_focus()
        form.red.opacity = 255
    end
    function form:out_focus()
        form.red.opacity = 0
    end

end)
