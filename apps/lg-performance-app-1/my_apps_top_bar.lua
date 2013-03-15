local my_apps_top = Group{
    name="my_apps_top",
    opacity=0,z=300,
    --x_rotation={90,0,-150},
    anchor_point = {screen_w/2,200},
    position = {screen_w/2,200},
}

do
    local icon = Sprite{
        sheet=assets,
        id="icon-top-my-apps.png",
        x = 30,
        y = 20,
    }
    icon.w = icon.w*3/2
    icon.h = icon.h*3/2

    local my_apps_text = Text{
        text = "MY APPS",
        color = "white",
        font = TITLE_FONT,
        x = icon.x + icon.w+10,
        y = icon.y-5
    }

    local pip = Sprite{
        sheet=assets,
        id="my-apps-mad-men.png",
        x = 100,
        y =  90,
    }
    pip.w = pip.w*3/2
    pip.h = pip.h*3/2

    local prog_bar = Sprite{
        sheet=assets,
        id="my-apps-progress-bar-whole.png",
        x = 800,
        y = 300,
    }
    prog_bar.w = prog_bar.w*3/2
    prog_bar.h = prog_bar.h*3/2

    local hdd_usb = Sprite{
        sheet=assets,
        id="button-hdd-usb-default.png",
        x = 1150,
        y = 280,
    }
    hdd_usb.w = hdd_usb.w*3/2
    hdd_usb.h = hdd_usb.h*3/2

    local lrg_btn = Sprite{
        sheet=assets,
        id="button-recently-added.png",
        x = hdd_usb.x+hdd_usb.w+20,
        y = hdd_usb.y,
    }
    lrg_btn.w = lrg_btn.w*3/2
    lrg_btn.h = lrg_btn.h*3/2

    local lrg_btn_text = Text{
        text = "Recently Added",
        font = CARD_TITLE_FONT,
        color = "black",
        x = lrg_btn.x+lrg_btn.w/2,
        y = lrg_btn.y+lrg_btn.h/2,
    }
    lrg_btn_text.anchor_point = {lrg_btn_text.w/2,lrg_btn_text.h/2}

    local lrg_btn_arrow = Sprite{
        sheet=assets,
        id="arrow-small-buttons.png",
        x = lrg_btn.x+lrg_btn.w-50,
        y = lrg_btn.y+lrg_btn.h/2,
    }
    lrg_btn_arrow.w = lrg_btn_arrow.w*3/2
    lrg_btn_arrow.h = lrg_btn_arrow.h*3/2
    lrg_btn_arrow.anchor_point = {lrg_btn_arrow.w/2,lrg_btn_arrow.h/2}

    local banner = Sprite{
        sheet=assets,
        id="ad-banner-lg-my-apps.png",
        x = 780,
        y = 120,
    }
    banner.w = banner.w*3/2
    banner.h = banner.h*3/2


    my_apps_top:add(icon,my_apps_text,pip,prog_bar,hdd_usb,lrg_btn,lrg_btn_text,lrg_btn_arrow,banner)
end

return my_apps_top
