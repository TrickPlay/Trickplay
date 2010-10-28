my_font = "kroeger 06_65 26px"

number_of_lives = 3
high_score = settings.high_score or 0
point_counter = 0
my_plane_sz = 128
topbar = Group{z=1}
topbar:add( 
    --[[
	Text{
		name = "LIVES",
		text = "Lives:",
		font="Highway Gothic Wide Bold 36px",
		color="FFFFFF",
		x=30,
		y=20
	},
    --]]
	Text{
		name = "SCORE",
		text = "Current Score:",
		font=my_font,--"Highway Gothic Wide Bold 36px",
		color="FFFFFF",
		y = 20
	},
	Text{
		name = "HIGHSCORE",
		text = "High Score:",
		font=my_font,--"Highway Gothic Wide Bold 36px",
		color="FFFFFF",
		y = 20
	}

)
local score_txt = Text{
		text = "",
		font=my_font,--"Highway Gothic Wide Bold 36px",
		color="FFFFFF",
		x = screen.w/2 +20,
		y = 20
}
local h_score_txt = Text{
		text = "",
		font=my_font,--"Highway Gothic Wide Bold 36px",
		color="FFFFFF",
		y = 20
}
function redo_score_text()
	score_txt.text   = string.format("%06d",point_counter)
	h_score_txt.text = string.format("%06d",high_score) 
end

redo_score_text()
h_score_txt.x = screen.w-h_score_txt.w-20

topbar:add(score_txt,h_score_txt)
topbar:find_child("SCORE").x = screen.w/2 - topbar:find_child("SCORE").w - 20
topbar:find_child("HIGHSCORE").x = h_score_txt.x - topbar:find_child("HIGHSCORE").w - 20

local life = Image{src = "assets/life.png",opacity=0,z=10}
screen:add(life)
lives =
{
	Clone{name="life1",source=life,x=20,y=15,z=10},
	Clone{name="life2",source=life,x=80,y=15,z=10},
	Clone{name="life3",source=life,x=140,y=15,z=10},
	Clone{name="life4",source=life,x=200,y=15,z=10,opacity=0},
	Clone{name="life5",source=life,x=260,y=15,z=10,opacity=0},
}

screen:add(topbar,score)
screen:add(unpack(lives))

