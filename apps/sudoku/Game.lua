local TILE_WIDTH  = 100
local TILE_GUTTER = 10
local SET_GUTTER  = 20
local TOP_GAP     = 30
assert(TOP_GAP >= SET_GUTTER, "flawed #defines for the board..." )

function sel_pos(r,c)
	return
			(c-1)*TILE_WIDTH + 
				math.floor((c-1)/3)*SET_GUTTER +
				(c-1)*TILE_GUTTER-1 + 500
			,
			(r-1)*TILE_WIDTH + 
				math.floor((r-1)/3)*SET_GUTTER +
				(r-1)*TILE_GUTTER+TOP_GAP+TILE_WIDTH/2-1

end

function BoardGen(number_of_givens)
    assert(number_of_givens <= 80, "in BoardGen, number_of_givens is too large")
    assert(number_of_givens >= 25, "in BoardGen, number_of_givens is too small")
    local base = 
    {
        {1,2,3,4,5,6,7,8,9},
        {4,5,6,7,8,9,1,2,3},
        {7,8,9,1,2,3,4,5,6},
        {2,3,4,5,6,7,8,9,1},
        {5,6,7,8,9,1,2,3,4},
        {8,9,1,2,3,4,5,6,7},
        {3,4,5,6,7,8,9,1,2},
        {6,7,8,9,1,2,3,4,5},
        {9,1,2,3,4,5,6,7,8}
    }

    local temp = {}
    local num_times = 0

    --column swaps per sets of 3
    for i = 0,2 do
        --the number of times to swap in that set of 3
        num_times = math.random(0,3)
        for j = 0, num_times do
            local first  = math.random(1,3)
            local second = math.random(1,3)
            --can't swap a column with itself
            if first ~= second then
                --the ol' switcheroo
                for k = 1,9 do
                    temp[k] = base[k][first + 3*i]
                end
                for k = 1,9 do
                    base[k][first+3*i] = base[k][second + 3*i]
                end
                for k = 1,9 do
                    base[k][second+3*i] = temp[k]
                end
            end
        end
    end

    --row swaps per sets of 3
    for i = 0,2 do
        --the number of times to swap in that set of 3
        num_times = math.random(0,3)
        for j = 0, num_times do
            local first  = math.random(1,3)
            local second = math.random(1,3)
            --can't swap a column with itself
            if first ~= second then
                --the ol' switcheroo
                for k = 1,9 do
                    temp[k] = base[first+3*i][k]
                end
                for k = 1,9 do
                    base[first+3*i][k] = base[second + 3*i][k]
                end
                for k = 1,9 do
                    base[second+3*i][k] = temp[k]
                end
            end
        end
    end

    --row swaps of the 3x3 sets
    num_times = math.random(0,3)
    for i = 1, num_times do
        local first  = math.random(0,2)
        local second = math.random(0,2)
        --can't swap a column with itself
        if first ~= second then
            --the ol' switcheroo
            for j = 1,3 do
                for k = 1,9 do
                    temp[k] = base[3*first+j][k]
                end
                for k = 1,9 do
                    base[3*first+j][k] = base[3*second+j][k]
                end
                for k = 1,9 do
                    base[3*second+j][k] = temp[k]
                end
            end
        end
    end

    --column swaps of the 3x3 sets
    num_times = math.random(0,3)
    for i = 1, num_times do
        local first  = math.random(0,2)
        local second = math.random(0,2)
        --can't swap a column with itself
        if first ~= second then
            --the ol' switcheroo
            for j = 1,3 do
                for k = 1,9 do
                    temp[k] = base[k][3*first+j]
                end
                for k = 1,9 do
                    base[k][3*first+j] = base[k][3*second+j]
                end
                for k = 1,9 do
                    base[k][3*second+j] = temp[k]
                end
            end
        end
    end


    --erase the requested number of squares
    for i = 1, 81-number_of_givens do
        local i = math.random(1,9)
        local j = math.random(1,9)
        while base[i][j] == 0 do
            i = math.random(1,9)
            j = math.random(1,9)
        end
        base[i][j] = 0
    end

    return base
end

function DevelopBoard(group,givens,guesses)
	local empty_spaces = 81
	local text
	local t
	local guess_g
	---------------------------------
	for r = 1,9 do     for c = 1,9 do
	---------------------------------
		
--[[
		t = Rectangle {name = "Tile "..r.." "..c,color = "202020",w = TILE_WIDTH,h = TILE_WIDTH, anchor_point = {TILE_WIDTH/2,TILE_WIDTH/2},opacity=0}
			t.x = (c-1)*TILE_WIDTH + 
				math.floor((c-1)/3)*SET_GUTTER +
				(c-1)*TILE_GUTTER
			t.y = (r-1)*TILE_WIDTH + 
				math.floor((r-1)/3)*SET_GUTTER +
				(r-1)*TILE_GUTTER+TOP_GAP+TILE_WIDTH/2

		group:add(t)
--]]
		if givens[r][c] ~= 0 then
			empty_spaces = empty_spaces - 1
			t = Text
			{
				name = "Given_s "..r.." "..c,
				text = givens[r][c],
				font = "DejaVu Bold 82px",
					color = "000000"
			}
			t.anchor_point={t.w/2,t.h/2}
			t.x = (c-1)*TILE_WIDTH + 
				math.floor((c-1)/3)*SET_GUTTER +
				(c-1)*TILE_GUTTER-1
			t.y = (r-1)*TILE_WIDTH + 
				math.floor((r-1)/3)*SET_GUTTER +
				(r-1)*TILE_GUTTER+TOP_GAP+TILE_WIDTH/2-1
			group:add(t)

			t = Text
			{
				name = "Given "..r.." "..c,
				text = givens[r][c],
				font = "DejaVu Bold 80px",
					color = "FFFFFF"
			}
			t.anchor_point={t.w/2,t.h/2}
			t.x = (c-1)*TILE_WIDTH + 
				math.floor((c-1)/3)*SET_GUTTER +
				(c-1)*TILE_GUTTER
			t.y = (r-1)*TILE_WIDTH + 
				math.floor((r-1)/3)*SET_GUTTER +
				(r-1)*TILE_GUTTER+TOP_GAP+TILE_WIDTH/2
			group:add(t)
		else
			text = ""
			if guesses[r][c].pen ~= 0 then
				text = guesses[r][c].pen
			end
			if guesses[r][c].num > 0 then
				empty_spaces = empty_spaces - 1				
			end
			guess_g = Group{name = "Guess "..r.." "..c,opacity=0}
			group:add(guess_g)
			t = Text
			{
				name = "Pen_s "..r.." "..c,
				text = text,
				font = "DejaVu Bold 82px",
				color = "000000",
				opacity = 255,		
			}
			t.anchor_point={t.w/2,t.h/2}
			t.x = (c-1)*TILE_WIDTH + 
				math.floor((c-1)/3)*SET_GUTTER +
				(c-1)*TILE_GUTTER-1
			t.y = (r-1)*TILE_WIDTH + 
				math.floor((r-1)/3)*SET_GUTTER +
				(r-1)*TILE_GUTTER+TOP_GAP+TILE_WIDTH/2-1
			group:add(t)

			t = Text
			{
				name = "Pen "..r.." "..c,
				text = text,
				font = "DejaVu Bold 80px",
				color = "fefa00",
				opacity = 255,

			}
			t.anchor_point={t.w/2,t.h/2}
			t.x = (c-1)*TILE_WIDTH + 
				math.floor((c-1)/3)*SET_GUTTER +
				(c-1)*TILE_GUTTER
			t.y = (r-1)*TILE_WIDTH + 
				math.floor((r-1)/3)*SET_GUTTER +
				(r-1)*TILE_GUTTER+TOP_GAP+TILE_WIDTH/2
			group:add(t)

			for g = 1,9 do
				t = Text
				{
					name    = "Guess "..r.." "..c.." "..g,
					text    = g,
					font    = "Eraser 57px",
					color   = "fefa00",
					opacity = 0,
					--z=1
				}
				t.scale = {1/2,1/2}
				t.anchor_point={t.w/2,t.h/2}
				t.x = (c-1)*TILE_WIDTH + 
					math.floor((c-1)/3)*SET_GUTTER +
					(c-1)*TILE_GUTTER+ ((g-1)%3-1)*TILE_WIDTH/3
				t.y = (r-1)*TILE_WIDTH + 
					math.floor((r-1)/3)*SET_GUTTER +
					(r-1)*TILE_GUTTER+ (math.floor((g-1)/3)-1)*
					TILE_WIDTH/3+TOP_GAP+TILE_WIDTH/2

				if guesses[r][c][g] and guesses[r][c].pen == 0 then 
					t.opacity=255
				end

				group:add(t)
				t = Text
				{
					text    = g,
					font    = "DejaVu ExtraLight 55px",
					color   = "707070",
					opacity = 150
					
				}
				t.scale = {1/2,1/2}
				t.anchor_point={t.w/2,t.h/2}
				t.x = (c-1)*TILE_WIDTH + 
					math.floor((c-1)/3)*SET_GUTTER +
					(c-1)*TILE_GUTTER+ ((g-1)%3-1)*TILE_WIDTH/3
				t.y = (r-1)*TILE_WIDTH + 
					math.floor((r-1)/3)*SET_GUTTER +
					(r-1)*TILE_GUTTER+ (math.floor((g-1)/3)-1)*
					TILE_WIDTH/3+TOP_GAP+TILE_WIDTH/2

				guess_g:add(t)

			end
		end

	---------------------------------
	end	           end
	---------------------------------
	return empty_spaces
end
--[[
local sel_menu = Group{}
local m_items = {
	Text{text="PENCIL",color="FFFFFF",font="Sans 36px",x=10,y=10},
	Text{text="PEN",color="FFFFFF",font="Sans 36px",x=10,y=90},
	Text{text="CLEAR",color="FFFFFF",font="Sans 36px",x=10,y=170},
	Text{text="BACK",color="FFFFFF",font="Sans 36px",x=10,y=250}

}
sel_menu:add(
	Rectangle{w = 200,h=300,color = "101010"}
)
sel_menu:add(unpack(m_items))
sel_menu.anchor_point={TILE_WIDTH/2,TILE_WIDTH/2}
--]]
Game = Class(function(g,the_givens, the_guesses, ...)
print("SHIIIIIIT")
	local error_checking = false
	local empty_spaces = 81

	local error_list = {}
	local undo_list = {}
	local redo_list = {}
	local givens = the_givens--BoardGen(number_of_givens)
	local guesses = {}
	if the_guesses then
		guesses = the_guesses
	else
		guesses = 
		{
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}}
		}

		for r = 1,9 do     for c = 1,9 do

			for i = 1,9 do
				guesses[r][c][i] = false
			end 
			guesses[r][c].num = 0
			guesses[r][c].pen = 0

		end                end
	end
	g.board = Group{}
	screen:add(g.board)
	empty_spaces = DevelopBoard(g.board,givens, guesses)
print(empty_spaces)
	--g.board.anchor_point = {g.board.w/2,g.board.h/2}
	g.board.position = {500,0}--{screen.w/2+40,screen.h/2}
	function g:save()
		settings.givens  = givens
		settings.guesses = guesses
	end
	function g:get_guesses(r,c)
		return guesses[r][c]
	end
	function g:get_givens(r,c)
		return givens[r][c]
	end
	function g:restart()
		guesses = 
		{
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}},
			{{},{},{},{},{},{},{},{},{}}
		}

		for r = 1,9 do     for c = 1,9 do

			for i = 1,9 do
				guesses[r][c][i] = false
			end 
			guesses[r][c].num = 0
			guesses[r][c].pen = 0

		end                end
		g.board:clear()
		g.board = Group{}
		screen:add(g.board)
		empty_spaces = DevelopBoard(g.board,givens, guesses)
		print(empty_spaces)
g.board.position = {500,0}
	end
	function g:check_guess(r,c,v,t)
		--r = row
		--c = column
		--v = value of the guess
		--t = the error_list


		-- for all the other tiles on that column
		for rr = 1,9 do
			if givens[rr][c] == v then
				table.insert(t,{{r,c,v},{rr,c}})
			elseif guesses[rr][c][i] and 
				rr ~= r then
				table.insert(t,{{r,c,v},{rr,c,v}})
			end
		end
		--for all the other tiles on that row
		for cc = 1,9 do
			if givens[r][cc] == i then
				table.insert(t,{{r,c,v},{r,cc}})
			elseif guesses[r][cc][i] and 
				cc ~= c then
				table.insert(t,{{r,c,v},{r,cc,v}})
			end
		end
		--for all the other tiles in that box
		for rr = math.floor((r-1)/3)*3+1, 
		         math.ceil(r/3)*3 do
			for cc = math.floor((c-1)/3)*3+1, 
			         math.ceil(c/3)*3 do
				--don't repeat the row-col checking
				if r ~=rr and c ~= cc then
					if givens[rr][cc] == v then
						table.insert(t,{{r,c,v},{rr,cc}})
					elseif guesses[rr][cc][v] and 
						(cc ~= c or rr ~= r) then
						table.insert(t,{{r,c,v},{rr,cc,v}})
					end
				end
			end
		end

		return mini_list
	end
	function g:init_error_list()
		error_list = {}
		-- check each guess sitting on every tile
		-----------------------------------------------------------
		for r = 1,9 do   for c = 1,9 do   if givens[r][c] == 0 then 
  
		                 for v = 1,9 do    if guesses[r][c][v] then
		-----------------------------------------------------------

			g:check_guess(r,c,v,error_list)

		-----------------------------------------------------------
		end          end          end          end          end
		-----------------------------------------------------------
	end
	g:init_error_list()
	function g:add_to_err_list(r,c,guess)
		g:check_guess(r,c,guess,error_list)
		if error_checking then
			--update the error_list
			for i,e in ipairs(error_list) do
				if #e[1] == 2 then
--[[
					g.board:find_child("Given "..e[1][1].." "
						..e[1][2]).color = "FF0000"
--]]
				elseif #e[1] == 3 then
					if guesses[e[1][1]][e[1][2]].pen == e[1][3] then
						g.board:find_child("Pen "..e[1][1].." "
							..e[1][2]).color = "FF0000"
					end
					g.board:find_child("Guess "..e[1][1].." "
						..e[1][2].." "..e[1][3]).color = "FF0000"
				else
					error("this should never happen,"..
						" i did something wrong")
				end
				if #e[2] == 2 then

--[[
					g.board:find_child("Given "..e[2][1].." "
						..e[2][2]).color = "FF0000"
--]]
				elseif #e[2] == 3 then
					if guesses[e[2][1]][e[2][2]].pen == e[2][3] then
						g.board:find_child("Pen "..e[2][1].." "
							..e[2][2]).color = "FF0000"
					end
					g.board:find_child("Guess "..e[2][1].." "
						..e[2][2].." "..e[2][3]).color = "FF0000"
				else	
					error("this should never happen,"..
						" i did something wrong")
				end
			end
		end

	end
	function g:rem_from_err_list(r,c,guess)
		--if error_checking then
			--have to search backwards in order to update the
			--table at the same time
			local e
			for i =#error_list,1,-1 do
				e = error_list[i]
				print(e[1][1],e[1][2],e[1][3],e[2][1],e[2][2],e[2][3])
				if (e[1][1] == r and e[1][2] == c 
				                 and e[1][3] == guess) or
				   (e[2][1] == r and e[2][2] == c 
				                 and e[2][3] == guess) then
					--print("rm")
					if #e[1] == 2 then
						g.board:find_child("Given "..e[1][1].." "
							..e[1][2]).color = "FFFFFF"
					elseif #e[1] == 3 then
						if guesses[e[1][1]][e[1][2]].pen == e[1][3] then
							g.board:find_child("Pen "..e[1][1].." "
								..e[1][2]).color = "fefa00"
						end
						g.board:find_child("Guess "..e[1][1].." "
							..e[1][2].." "..e[1][3]).color = "fefa00"
					else
						error("this should never happen,"..
							" i did something wrong")
					end
					if #e[2] == 2 then
						g.board:find_child("Given "..e[2][1].." "
							..e[2][2]).color = "FFFFFF"
					elseif #e[2] == 3 then
						if guesses[e[2][1]][e[2][2]].pen == e[2][3] then
							g.board:find_child("Pen "..e[2][1].." "
								..e[2][2]).color = "fefa00"
						end
						g.board:find_child("Guess "..e[2][1].." "
							..e[2][2].." "..e[2][3]).color = "fefa00"
					else
						error("this should never happen,"..
							" i did something wrong")
					end

					table.remove(error_list,i)
				end
			end
		if error_checking then
			for i =#error_list,1,-1 do
				e = error_list[i]

					if #e[1] == 2 then
--[[
						g.board:find_child("Given "..e[1][1].." "
							..e[1][2]).color = "FF0000"
--]]
					elseif #e[1] == 3 then
						g.board:find_child("Guess "..e[1][1].." "
							..e[1][2].." "..e[1][3]).color = "FF0000"
					else
						error("this should never happen,"..
							" i did something wrong")
					end
					if #e[2] == 2 then
--[[
						g.board:find_child("Given "..e[2][1].." "
							..e[2][2]).color = "FF0000"
--]]
					elseif #e[2] == 3 then
						g.board:find_child("Guess "..e[2][1].." "
							..e[2][2].." "..e[2][3]).color = "FF0000"
					else
						error("this should never happen,"..
							" i did something wrong")
					end
			end	
		end	
		print("size of error list = "..#error_list)
	end



	function g:pen(r,c,p,status)
print("pen",r,c,p)
--[[
					if status ~= "REDO" and status ~= "UNDO" then
						table.insert(undo_list,{g.,r,c,p})
						if #undo_list > 100 then
							table.remove(undo_list,1)
						end
					elseif status ~= "REDO" and status ~= "UNDO" then
						redo_list = {}
					end
--]]
		if givens[r][c] ~= 0 then return end

		--if another pen number was there
		if guesses[r][c].pen ~= 0 then
			if status ~= "UNDO" then
				table.insert(undo_list,{g.pen,r,c,
					guesses[r][c].pen})
				if #undo_list > 100 then
					table.remove(undo_list,1)
				end
			elseif status ~= "REDO" then
				redo_list = {}
			end
print("here")
			g:rem_from_err_list(r,c,guesses[r][c].pen)
			--if toggling out a penned number
			if guesses[r][c].pen == p then
				print("removing pen")
				empty_spaces = empty_spaces + 1
				guesses[r][c][p] = false
				guesses[r][c].pen = 0
				guesses[r][c].num = 0
				g.board:find_child("Pen "..r.." "..c).text=""
				g.board:find_child("Pen_s "..r.." "..c).text=""
				return
			end
		--if pencil numbers were there
		elseif guesses[r][c].num > 0 then
			local params = {}
			for i = 1,9 do
				if guesses[r][c][i] then
					table.insert(params,i)
					g:rem_from_err_list(r,c,i)
					guesses[r][c][i] = false
					g.board:find_child("Guess "..
						r.." "..c.." "..i).opacity = 0
				end
			end
			if status ~= "UNDO" then
				table.insert(undo_list,{g.set_pencil,r,c,
					params})
				if #undo_list > 100 then
					table.remove(undo_list,1)
				end
			elseif status ~= "REDO" then
				redo_list = {}
			end

		--if nothing was there
		else
			if status ~= "UNDO" then
				table.insert(undo_list,{g.pen,r,c,p})
				if #undo_list > 100 then
					table.remove(undo_list,1)
				end
			elseif status ~= "REDO" then
				redo_list = {}
			end
			empty_spaces = empty_spaces - 1
		end



--[[
		for i = 1,9 do
			guesses[r][c][i] = false
		end
--]]
		guesses[r][c].num = 1
		
		guesses[r][c].pen = p
		guesses[r][c][p] = true
		local pen = g.board:find_child("Pen "..r.." "..c)
		pen.text=p
		pen.anchor_point={pen.w/2,pen.h/2}
		pen.x = (c-1)*TILE_WIDTH + 
				math.floor((c-1)/3)*SET_GUTTER +
				(c-1)*TILE_GUTTER
		pen.y = (r-1)*TILE_WIDTH + 
				math.floor((r-1)/3)*SET_GUTTER +
				(r-1)*TILE_GUTTER+TOP_GAP+TILE_WIDTH/2

		local pen_s = g.board:find_child("Pen_s "..r.." "..c)
		pen_s.text=p
		pen_s.anchor_point={pen.w/2,pen.h/2}
		pen_s.x = (c-1)*TILE_WIDTH + 
				math.floor((c-1)/3)*SET_GUTTER +
				(c-1)*TILE_GUTTER-1
		pen_s.y = (r-1)*TILE_WIDTH + 
				math.floor((r-1)/3)*SET_GUTTER +
				(r-1)*TILE_GUTTER+TOP_GAP+TILE_WIDTH/2-1
		g:add_to_err_list(r,c,p)
		if empty_spaces == 0 and #error_list == 0 then
			player_won()
		end
print(empty_spaces)
	end


	function g:toggle_guess(r,c,guess,status)
		if type(guess) == "table" then
			error("this shouldt happen anymore")
			for i = 1,#guess do
			g:toggle_guess(r,c,guess[i],status)
			end
			return
		end
		--can't toggle a guess for a given
		if givens[r][c] ~= 0 then return end

		--if there was an existing pen mark on the tile
		if guesses[r][c].pen ~= 0 then

			-- remove the "penned" guess, add it to the undo list
			g:rem_from_err_list(r,c,guesses[r][c].pen)	
			if status ~= "REDO" and status ~= "UNDO" then
				table.insert(undo_list,{g.pen,r,c,guesses[r][c].pen})
				if #undo_list > 100 then
					table.remove(undo_list,1)
				end
			elseif status ~= "REDO" and status ~= "UNDO" then
				redo_list = {}
			end

			guesses[r][c][guesses[r][c].pen] = false
			guesses[r][c].pen = 0
			g.board:find_child("Pen "..r.." "..c).text=""
			g.board:find_child("Pen_s "..r.." "..c).text=""

			--add the penciled guess
			guesses[r][c][guess] = true
			g.board:find_child("Guess "..r.." "..c..
				" "..guess).opacity = 255
			g:add_to_err_list(r,c,guess)
			if empty_spaces == 0 and #error_list == 0 then
				player_won()
			end

		--if toggling the guess off
		elseif guesses[r][c][guess] then
				guesses[r][c].num = guesses[r][c].num - 1
				if guesses[r][c].num == 0 then
					empty_spaces = empty_spaces + 1
				end


--			guesses[r][c].sz = guesses[r][c].sz - 1
			guesses[r][c][guess] = false
			g.board:find_child("Guess "..r.." "..c..
				" "..guess).opacity = 0
			if status ~= "REDO" and status ~= "UNDO" then
				table.insert(undo_list,{g.toggle_guess,r,c,guess})
				if #undo_list > 100 then
					table.remove(undo_list,1)
				end
			elseif status ~= "REDO" and status ~= "UNDO" then
				redo_list = {}
			end
			g:rem_from_err_list(r,c,guess)

		--if toggling it on
		else
				if guesses[r][c].num == 0 then
					empty_spaces = empty_spaces - 1
				end
				guesses[r][c].num = guesses[r][c].num + 1


			--guesses[r][c].sz = guesses[r][c].sz + 1
			guesses[r][c][guess] = true
			g.board:find_child("Guess "..r.." "..c..
				" "..guess).opacity = 255
			if status ~= "REDO" and status ~= "UNDO" then
				table.insert(undo_list,{g.toggle_guess,r,c,guess})
				if #undo_list > 100 then
					table.remove(undo_list,1)
				end
			elseif status ~= "REDO" and status ~= "UNDO" then
				redo_list = {}
			end
			g:add_to_err_list(r,c,guess)
			if empty_spaces == 0 and #error_list == 0 then
				player_won()
			end
		end
print(empty_spaces)
end
	function g:error_check()
		if error_checking then
			error_checking = false
				for i =#error_list,1,-1 do
					e = error_list[i]
						--table.remove(error_list,i)

					if #e[1] == 2 then
						g.board:find_child("Given "..e[1][1].." "
							..e[1][2]).color = "FFFFFF"
					elseif #e[1] == 3 then
						if guesses[e[1][1]][e[1][2]].pen == e[1][3] then
							g.board:find_child("Pen "..e[1][1].." "
								..e[1][2]).color = "fefa00"
						end
						g.board:find_child("Guess "..e[1][1].." "
							..e[1][2].." "..e[1][3]).color = "fefa00"
					else
						error("this should never happen,"..
							" i did something wrong")
					end
					if #e[2] == 2 then
						g.board:find_child("Given "..e[2][1].." "
							..e[2][2]).color = "FFFFFF"
					elseif #e[2] == 3 then
						if guesses[e[2][1]][e[2][2]].pen == e[2][3] then
							g.board:find_child("Pen "..e[2][1].." "
								..e[2][2]).color = "fefa00"
						end
						g.board:find_child("Guess "..e[2][1].." "
							..e[2][2].." "..e[2][3]).color = "fefa00"
					else
						error("this should never happen,"..
							" i did something wrong")
					end
					--table.remove(error_list,i)
				end
			return
		end
		error_checking = true
--[[
		error_list = {}
		for r = 1,9 do
			for c = 1,9 do
				if givens[r][c] == 0 then
					for guess = 1,9 do
						if guesses[r][c][guess] then
							for rr = 1,9 do
								if givens[rr][c] == guess then
									table.insert(error_list,
										{{r,c,guess},{rr,c}})
								elseif guesses[rr][c][guess] and 
									rr ~= r then
									table.insert(error_list,
										{{r,c,guess},{rr,c,guess}})
								end
							end
							for cc = 1,9 do
								if givens[r][cc] == guess then
									table.insert(error_list,
										{{r,c,guess},{r,cc}})
								elseif guesses[r][cc][guess] and 
									cc ~= c then
									table.insert(error_list,
										{{r,c,guess},{r,cc,guess}})
								end
							end
							for rr = math.floor((r-1)/3)*3+1, 
							         math.ceil(r/3)*3 do
								for cc = math.floor((c-1)/3)*3+1, 
								         math.ceil(c/3)*3 do
									if givens[rr][cc] == guess then
										table.insert(error_list,
											{{r,c,guess},{rr,cc}})
									elseif guesses[rr][cc][guess] and 
										(cc ~= c or rr ~= r) then
										table.insert(error_list,
											{{r,c,guess},{rr,cc,guess}})
									end
								end
							end
						end
					end
---[ uncomment to see if the givens produced by the board generator are messed up
				else
					for rr = 1,9 do
						if givens[rr][c] == givens[r][c] and rr ~= r then
							table.insert(error_list,
								{{r,c},{rr,c}})
						elseif guesses[rr][c][ givens[r][c] ] then
							table.insert(error_list,
								{{r,c},{rr,c,givens[r][c]}})
						end
					end
					for cc = 1,9 do
						if givens[r][cc] == givens[r][c] and cc ~= c then
							table.insert(error_list,
								{{r,c},{r,cc}})
						elseif guesses[r][cc][ givens[r][c] ] then
							table.insert(error_list,
								{{r,c},{r,cc,givens[r][c]}})
						end
					end
					for rr = math.floor((r-1)/3)*3+1, 
					         math.ceil(r/3)*3 do
						for cc = math.floor((c-1)/3)*3+1, 
						         math.ceil(c/3)*3 do
							if givens[rr][cc] == givens[r][c] and 
								(cc ~= c or rr ~= r) then
								table.insert(error_list,
									{{r,c},{rr,cc}})
							elseif guesses[rr][cc][ givens[r][c] ] then
								table.insert(error_list,
									{{r,c},{rr,cc,givens[r][c]}})
							end
						end
					end
--]
				end
			end
		end

--]]
		for i,e in ipairs(error_list) do
			if #e[1] == 2 then
--[[
				g.board:find_child("Given "..e[1][1].." "
					..e[1][2]).color = "FF0000"
--]]
			elseif #e[1] == 3 then
				if guesses[e[1][1]][e[1][2]].pen == e[1][3] then
					g.board:find_child("Pen "..e[1][1].." "
						..e[1][2]).color = "FF0000"
				else
					g.board:find_child("Guess "..e[1][1].." "
						..e[1][2].." "..e[1][3]).color = "FF0000"
				end
			else
				error("this should never happen,"..
					" i did something wrong")
			end
			if #e[2] == 2 then

				if givens[e[2][1]][e[2][2]] == 0 then
					print(e[1][1],e[1][2],"   ",e[2][1],e[2][2])

					debug()
				end
--[[
				g.board:find_child("Given "..e[2][1].." "
					..e[2][2]).color = "FF0000"
--]]
			elseif #e[2] == 3 then
				if guesses[e[2][1]][e[2][2]].pen == e[2][3] then
					g.board:find_child("Pen "..e[2][1].." "
						..e[2][2]).color = "FF0000"
				else

				g.board:find_child("Guess "..e[2][1].." "
					..e[2][2].." "..e[2][3]).color = "FF0000"
				end
			else
				error("this should never happen,"..
					" i did something wrong")
			end
		end
	end
	function g:undo(r,c)
		if #undo_list > 0 then
			params = table.remove(undo_list)
			table.insert(redo_list,{params[1],params[2],params[3],params[4]})
print("undooo",params[2],params[3],params[4])
			params[1](g,params[2],params[3],params[4],"UNDO")
--[[
			if r ~= params[1] or c ~= params[2] then
				r = params[1]
				c = params[2]
				if guesses[r][c].sz == 1 then
					local i = 1
					for k = 1,9 do
						if guesses[r][c][k] then
							i=k	
							print(i)			
						end
					end
					local guess = g.board:find_child("Guess "..
						r.." "..c.." "..i)
					guess.scale = {1,1}
					guess.x = (c-1)*TILE_WIDTH + 
						math.floor((c-1)/3)*SET_GUTTER +
						(c-1)*TILE_GUTTER
					guess.y = (r-1)*TILE_WIDTH + 
						math.floor((r-1)/3)*SET_GUTTER +
						(r-1)*TILE_GUTTER+TOP_GAP+
						TILE_WIDTH/2
				end
			end
--]]
		end
	end
	function g:redo(r,c)
		if #redo_list > 0 then
			params = table.remove(redo_list)
			table.insert(undo_list,{params[1],params[2],params[3],params[4]})
			params[1](params[2],params[3],params[4],"REDO")
--[[
			if r ~= params[1] or c ~= params[2] then
				r = params[1]
				c = params[2]
				if guesses[r][c].sz == 1 then
					local i = 1
					for k = 1,9 do
						if guesses[r][c][k] then
							i=k	
							print(i)			
						end
					end
					local guess = g.board:find_child("Guess "..
						r.." "..c.." "..i)
					guess.scale = {1,1}
					guess.x = (c-1)*TILE_WIDTH + 
						math.floor((c-1)/3)*SET_GUTTER +
						(c-1)*TILE_GUTTER
					guess.y = (r-1)*TILE_WIDTH + 
						math.floor((r-1)/3)*SET_GUTTER +
						(r-1)*TILE_GUTTER+TOP_GAP+
						TILE_WIDTH/2
				
				elseif guesses[r][c].sz > 1 then
					for i = 1,9 do
						if guesses[r][c][i] then
							local guess = g.board:find_child("Guess "..
								r.." "..c.." "..i)
							guess.scale = {1/2,1/2}
							guess.x = (c-1)*TILE_WIDTH + 
								math.floor((c-1)/3)*SET_GUTTER +
								(c-1)*TILE_GUTTER+ ((i-1)%3-1)*
								TILE_WIDTH/3
							guess.y = (r-1)*TILE_WIDTH + 
								math.floor((r-1)/3)*SET_GUTTER +
								(r-1)*TILE_GUTTER+ (math.floor(
								(i-1)/3)-1)*TILE_WIDTH/3+TOP_GAP+
								TILE_WIDTH/2
						end
					end
				end
			end
--]]
		end
	end


	function g:clear_tile(r,c)
		empty_spaces = empty_spaces + 1
		if guesses[r][c].pen ~= 0 then
			table.insert(undo_list,{g.pen,r,c,guesses[r][c].pen})

			guesses[r][c].pen = 0
			guesses[r][c].num = 0
			g.board:find_child("Pen "..r.." "..c).text=""
			g.board:find_child("Pen_s "..r.." "..c).text=""

		else

		local params = {}
			for i = 1,9 do
				if guesses[r][c][i] then
					g:rem_from_err_list(r,c,i)
					guesses[r][c][i] = false
					local guess = g.board:find_child("Guess "..
							r.." "..c.." "..i)
					guess.opacity = 0
					table.insert(params,i)
				end
			end
			guesses[r][c].pen = 0
			guesses[r][c].num = 0
			g.board:find_child("Pen "..r.." "..c).text=""
			g.board:find_child("Pen_s "..r.." "..c).text=""


			table.insert(undo_list,{g.set_pencil,r,c,params})
		end
	end
	function g:set_pencil(r,c,nums)
print("hi??")
		if guesses[r][c].num == 0 then
			empty_spaces = empty_spaces - 1
		end

		for i = 1,9 do
			if guesses[r][c][i] then
				g:rem_from_err_list(r,c,i)
				guesses[r][c][i] = false
				g.board:find_child("Guess "..
					r.." "..c.." "..i).opacity = 0
--				guess.color = "FFFFFF"
--				guess.opacity = 0
			end
		end
		for i = 1,#nums do
			guesses[r][c][nums[i]] = true
			g.board:find_child("Guess "..
				r.." "..c.." "..nums[i]).opacity = 255
		end
		guesses[r][c].pen = 0
		guesses[r][c].num = #nums
		g.board:find_child("Pen "..r.." "..c).text=""
		g.board:find_child("Pen_s "..r.." "..c).text=""

	end
--[[
	function g:enter_menu(r,c)
		sel_menu.x = (c)*TILE_WIDTH + 
			math.floor((c-1)/3)*SET_GUTTER +
			(c-1)*TILE_GUTTER
		sel_menu.y = (r-1)*TILE_WIDTH + 
			math.floor((r-1)/3)*SET_GUTTER +
			(r-1)*TILE_GUTTER+TOP_GAP+TILE_WIDTH/2
	end
--]]
end)


--[[
will print a board
local t = BoardGen(25)
for i = 1, #t do
    print(t[i][1],t[i][2],t[i][3],t[i][4],t[i][5],t[i][6],t[i][7],t[i][8],t[i][9])
end

--]]
