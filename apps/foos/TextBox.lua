-- Call this Textbox or Formfield, but not Form cause Form implies that this class encapsulates an entire Form

TextBox = Class(function(textbox, x, y, length, ...)
    print("Making textbox at",x,y,"of length",length)
    textbox.black = Group{position = {x, y}}
    textbox.red = Group{position = {x, y}, opacity = 0}
    textbox.group = Group{}
    local blackLeft = Image{
        position = {0, 0},
        src = "assets/txtbx/TextBoxLeft.png"
    }
    local blackCenter = Image{
        position = {10, 0},
        src = "assets/txtbx/TextBoxCenter.png",
        width = length - 20,
        tile = {true, false}
    }
    local blackRight = Image{
        position = {length - 10, 0},
        src = "assets/txtbx/TextBoxRight.png"
    }
    textbox.black:add(blackLeft, blackCenter, blackRight)
    local redLeft = Image{
        position = {0, 0},
        src = "assets/txtbx/TextBoxLeftFocus.png"
    }
    local redCenter = Image{
        position = {10, 0},
        src = "assets/txtbx/TextBoxCenterFocus.png",
        width = length - 20,
        tile = {true, false}
    }
    local redRight = Image{
        position = {length - 10, 0},
        src = "assets/txtbx/TextBoxRightFocus.png"
    }
    textbox.red:add(redLeft, redCenter, redRight)

    textbox.group:add(textbox.black, textbox.red)

    function textbox:on_focus()
       textbox.red:animate{duration = CHANGE_VIEW_TIME, opacity = 255}
       textbox.black:animate{duration = CHANGE_VIEW_TIME, opacity = 0}
    end
    function textbox:out_focus()
       textbox.red:animate{duration = CHANGE_VIEW_TIME, opacity = 0}
       textbox.black:animate{duration = CHANGE_VIEW_TIME, opacity = 255}
    end
end)
