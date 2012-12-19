local text_test = Group { y = screen.h - 960 }

text_test:add(Rectangle{size={screen.w,screen.h}, color="white"})

local english  = "Curabitur quis neque quis lacus mollis laoreet vitae eget dolor. Curabitur sodales, diam eget viverra volutpat, nibh ligula tincidunt magna, quis ornare nibh metus vitae dui. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse viverra felis non\n"
local russian  = "Очередь заведено создаете те про, джоэл должен написано вы всю. Получаете отказаться программистов миф мы, не пишете размере количества нее, по две заведено безостановочно? Ещё то этой вреде внешних, люсита автора принадлежите мы опа. Ну эти всегда образование\n"
local japanese = "せっかく見つけたすばらしい記事がどこにあったか忘れてしまった経験はありますか ならタイトルとアドレスだけでなく、訪問したウェブページのコンテンツからも検索することができます。せっかく見つけたすばらしい記事がどこにあったか忘れてしまった経験はありますか ならタイトルとアドレスだけでなく、訪問したウェブページのコンテンツからも検索することができます。訪問したウェブページのコンテンツからも検索することができます。せっかく見つけたすばらしい記事がどこにあったか忘れてしまった経験はありますか ならタイトルとアドレスだけでなく、訪問\n"

local textblock1, border1
local textblock2, border2
local textblock3, border3
local textblock4, border4
local textblock5, border5

local function concatStr(str, num)
    local out = str
    local i=0
    while(i < num) do
        out = out..str
        i=i+1
    end
    return out
end

local function makeBorder(text)
    local rect = Rectangle { size = text.size, position=text.position, color="white", border_color="black", border_width=1}
    text.x=text.x+1
    text.y=text.y+1
    text.w=text.w-2
    text.h=text.h-2
    return rect
end

text_test.extra.start = function()
    textblock1 = Text { wrap = true, color="black", position = {0,      0}, size = {320,  480}, text = concatStr(english, 4),  font = "Champignon 26px" }
    textblock2 = Text { wrap = true, color="black", position = {0,    480}, size = {320,  480}, text = concatStr(english, 3),  font = "Starjedi 26px"   }
    textblock3 = Text { wrap = true, color="black", position = {320,    0}, size = {1280, 960}, text = concatStr(english, 10),  font = "FreeSerif 26px"  }
    textblock4 = Text { wrap = true, color="black", position = {1600,   0}, size = {320,  480}, text = concatStr(russian, 3),  font = "FreeSerif 26px"  }
    textblock5 = Text { wrap = true, color="black", position = {1600, 480}, size = {320,  480}, text = concatStr(japanese, 3), font = "Sazanami Mincho Regular 26px"  }

    border1=makeBorder(textblock1)
    border2=makeBorder(textblock2)
    border3=makeBorder(textblock3)
    border4=makeBorder(textblock4)
    border5=makeBorder(textblock5)

    text_test:add(border1,border2,border3,border4,border5)
    text_test:add(textblock1,textblock2,textblock3,textblock4,textblock5)

    local expand = true
    local expandwidth = 320;

    local anim = AnimationState
    {
        duration = 5000,
        transitions =
        {
            {
                source = "*",
                target = "expanded",
                keys =
                {
                    { textblock1, "width", 640-2 },
                    { border1,    "width", 640   },
                    { textblock2, "width", 640-2 },
                    { border2,    "width", 640   },
                    { textblock3, "width", (1920-640*2)-2 },
                    { textblock3, "x",     640-1 },
                    { border3,    "width", (1920-640*2) },
                    { border3,    "x",     640 },
                    { textblock4, "width", 640-2 },
                    { textblock4, "x",     (1920-640)+1 },
                    { border4,    "width", 640 },
                    { border4,    "x",     1920-640 },
                    { textblock5, "width", 640-2 },
                    { textblock5, "x",     (1920-640)+1 },
                    { border5,    "width", 640 },
                    { border5,    "x",     1920-640 },
                },
            },
            {
                source = "*",
                target = "compact",
                keys =
                {
                    { textblock1, "width", 320-2 },
                    { border1,    "width", 320   },
                    { textblock2, "width", 320-2 },
                    { border2,    "width", 320   },
                    { textblock3, "width", (1920-320*2)-2 },
                    { textblock3, "x",     320-1 },
                    { border3,    "width", (1920-320*2) },
                    { border3,    "x",     320 },
                    { textblock4, "width", 320-2 },
                    { textblock4, "x",     (1920-320)+1 },
                    { border4,    "width", 320 },
                    { border4,    "x",     1920-320 },
                    { textblock5, "width", 320-2 },
                    { textblock5, "x",     (1920-320)+1 },
                    { border5,    "width", 320 },
                    { border5,    "x",     1920-320 },
                },
            },
        },
    }
    anim.on_completed = function()
        if(anim.state == "expanded") then
            anim.state = "compact"
        else
            anim.state = "expanded"
        end
    end

    anim.state = "expanded"
end

return text_test
