local text_test = Group {}

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
    out = str
    i=0
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
    textblock1 = Text { wrap = true, color="black", position = {0,      0}, size = {200, 300}, text = concatStr(english, 4),  font = "Champignon 16px" }
    textblock2 = Text { wrap = true, color="black", position = {0,    300}, size = {200, 300}, text = concatStr(english, 3),  font = "Starjedi 16px"   }
    textblock3 = Text { wrap = true, color="black", position = {200,    0}, size = {800, 600}, text = concatStr(english, 10),  font = "FreeSerif 16px"  }
    textblock4 = Text { wrap = true, color="black", position = {1000,   0}, size = {200, 300}, text = concatStr(russian, 3),  font = "FreeSerif 16px"  }
    textblock5 = Text { wrap = true, color="black", position = {1000, 300}, size = {200, 300}, text = concatStr(japanese, 3), font = "Sazanami Mincho Regular 16px"  }

    border1=makeBorder(textblock1)
    border2=makeBorder(textblock2)
    border3=makeBorder(textblock3)
    border4=makeBorder(textblock4)
    border5=makeBorder(textblock5)

    text_test:add(border1,border2,border3,border4,border5)
    text_test:add(textblock1,textblock2,textblock3,textblock4,textblock5)

    local expand = true
    local expandwidth = 200;

    idle:add_onidle_listener(function()
        if(expand) then
            expandwidth = expandwidth + 1
            if(expandwidth == 400) then
                expand = false
            end
        else
            expandwidth = expandwidth - 1
            if(expandwidth == 200) then
                expand = true
            end
        end

        border1.width = expandwidth                         textblock1.width = expandwidth-2
        border2.width = expandwidth                         textblock2.width = expandwidth-2

        border3.width = (1200-(expandwidth*2))              textblock3.width = (1200-(expandwidth*2))-2
        border3.x = expandwidth                             textblock3.x = expandwidth+1

        border4.width = expandwidth                         textblock4.width = expandwidth-2
        border4.x = (1200-expandwidth)                      textblock4.x = (1200-expandwidth)+1
        border5.width = expandwidth                         textblock5.width = expandwidth-2
        border5.x = (1200-expandwidth)                      textblock5.x = (1200-expandwidth)+1
    end)
end

return text_test
