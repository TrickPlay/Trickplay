dofile("nums.lua")
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

function DevelopBoard(grid_of_groups,givens,guesses,blox)
--	local grid_of_groups = {}
	local empty_spaces = 81
	local text
	local t
	local guess_g
	---------------------------------
	for r = 1,9 do  
			grid_of_groups[r] = {}   
					for c = 1,9 do
	---------------------------------

		grid_of_groups[r][c] = Group
		{
			name = r.." "..c
		}
		blox[math.floor((r-1)/3)+1][math.floor((c-1)/3)+1]:add(
			grid_of_groups[r][c])
--local backing = Rectangle{color="707070",opacity=0,w=100,h=100}
		grid_of_groups[r][c]:add(backing)
		grid_of_groups[r][c].x = ((c-1)%3)*(TILE_WIDTH+TILE_GUTTER)
				+ TILE_WIDTH/2
		grid_of_groups[r][c].y = ((r-1)%3)*(TILE_WIDTH+TILE_GUTTER)
				+ TILE_WIDTH/2
--[[
		grid_of_groups[r][c].x = screen.w/2+ (c-5)*(TILE_WIDTH+TILE_GUTTER)
if c<=3 then
grid_of_groups[r][c].x=grid_of_groups[r][c].x - SET_GUTTER
elseif c>=7 then
grid_of_groups[r][c].x=grid_of_groups[r][c].x + SET_GUTTER

end --+ math.floor((r-5)
--(c-1)*TILE_WIDTH + math.floor((c-1)/3)*
--		                         SET_GUTTER + (c-1)*TILE_GUTTER+500
		grid_of_groups[r][c].y = screen.h/2+(r-5)*(TILE_WIDTH+TILE_GUTTER)+15
if r<=3 then
grid_of_groups[r][c].y=grid_of_groups[r][c].y - SET_GUTTER
elseif r>=7 then
grid_of_groups[r][c].y=grid_of_groups[r][c].y + SET_GUTTER

end 
--]]

		if givens[r][c] ~= 0 then
			empty_spaces = empty_spaces - 1
			t = Clone{
				name = "Given "..r.." "..c,
				source = given_nums[ givens[r][c] ],
				opacity=0
			}
			t.anchor_point={t.w/2,t.h/2}
	--			t.x = TILE_WIDTH/2
	--			t.y = TILE_WIDTH/2

			grid_of_groups[r][c]:add(t)
t.opacity=255
		else
			if guesses[r][c].num > 0 then
				empty_spaces = empty_spaces - 1				
			end
			for g = 1,9 do
				t= Clone{
					name   = "Pen "..g,
					source = pen_nums[g],
					opacity = 0
				}
				t.anchor_point={t.w/2,t.h/2}
		--		t.x = TILE_WIDTH/2
		--		t.y = TILE_WIDTH/2

				grid_of_groups[r][c]:add(t)
				if guesses[r][c].pen == g then
					t.opacity=255
				end

				t= Clone{
					name   = "WR_Pen "..g,
					source = wr_pen_nums[g],
					opacity = 0
				}
				t.anchor_point={t.w/2,t.h/2}
		--		t.x = TILE_WIDTH/2
		--		t.y = TILE_WIDTH/2


				grid_of_groups[r][c]:add(t)

				t = Clone{
					name   = "Guess "..g,
					source = pencil_nums[g],
					opacity = 0
				}

				t.scale = {1/2,1/2}
				t.anchor_point={t.w/2,t.h/2}
				t.x = ((g-1)%3-1)*(TILE_WIDTH/4+5)
				t.y = (math.floor((g-1)/3)-1)*(TILE_WIDTH/4+5)

				grid_of_groups[r][c]:add(t)
				
				if guesses[r][c][g] and guesses[r][c].pen == 0 then 
					t.opacity=255
				end
				t = Clone{
					name   = "WR_Guess "..g,
					source = wr_pencil_nums[g],
					opacity = 0
				}

				t.scale = {1/2,1/2}
				t.anchor_point={t.w/2,t.h/2}
				t.x = ((g-1)%3-1)*(TILE_WIDTH/4+5)
				t.y = (math.floor((g-1)/3)-1)*(TILE_WIDTH/4+5)


				grid_of_groups[r][c]:add(t)
			end
		end
--[[
grid_of_groups[r][c]:foreach_child( function(child)
		child.anchor_point = {child.w/2,child.h/2}
end)
--]]
--backing.w = grid_of_groups[r][c].w
--backing.h = grid_of_groups[r][c].h
--print(backing.w,backing.h)
--backing.anchor_point = {backing.w/2,backing.h/2}
--backing.x = backing.w/2
--backing.y = backing.h/2
	--	grid_of_groups[r][c].anchor_point = 
	--	{
	--		grid_of_groups[r][c].w/2,
	--		grid_of_groups[r][c].h/2
	--	}
		
--(r-1)*TILE_WIDTH + math.floor((r-1)/3)*
--		                         SET_GUTTER +(r-1)*TILE_GUTTER+TOP_GAP+
--		                         TILE_WIDTH/2

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
Game = Class(function(g,the_givens, the_guesses,blox, ...)
	local error_checking = false
	local empty_spaces = 81
	local the_blox = blox
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
	--g.board = Group{}
	g.grid_of_groups = {}
	--screen:add(g.board)
	empty_spaces = DevelopBoard(g.grid_of_groups,givens, guesses,blox)
print(empty_spaces)
	--g.board.anchor_point = {g.board.w/2,g.board.h/2}
	--g.board.position = {500,0}--{screen.w/2+40,screen.h/2}
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
	function g:get_all_givens()
		return givens
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
			g.grid_of_groups[r][c]:clear()
		end                end
		g.grid_of_groups = {}
		--g.board:clear()
		--g.board = Group{}
		
		--screen:add(g.board)
		empty_spaces = DevelopBoard(g.grid_of_groups,givens, guesses,the_blox)
		print(empty_spaces)
--g.board.position = {500,0}
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
						if guesses[e[1][1]][e[1][2]].pen == e[1][3] then
							g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Pen "..e[1][3]).opacity = 0
							g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Pen "..e[1][3]).opacity = 255
						else
							g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Guess "..e[1][3]).opacity = 0
							g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Guess "..e[1][3]).opacity = 255
						end
					end
					--g.board:find_child("Guess "..e[1][1].." "
					--	..e[1][2].." "..e[1][3]).color = "FF0000"
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
						if guesses[e[2][1]][e[2][2]].pen == e[2][3] then
							g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Pen "..e[2][3]).opacity = 0
							g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Pen "..e[2][3]).opacity = 255
						else                             
							g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Guess "..e[2][3]).opacity = 0
							g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Guess"..e[2][3]).opacity = 255
						end
					end
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
					if error_checking then
						if #e[1] == 2 then
						elseif #e[1] == 3 then
							if guesses[e[1][1]][e[1][2]].pen == e[1][3] then
								g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Pen "..e[1][3]).opacity = 255
								g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Pen "..e[1][3]).opacity = 0
							else
								g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Guess "..e[1][3]).opacity = 255
								g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Guess "..e[1][3]).opacity = 0
							end
						else
							error("this should never happen,"..
								" i did something wrong")
						end
						if #e[2] == 2 then
						elseif #e[2] == 3 then
							if guesses[e[2][1]][e[2][2]].pen == e[2][3] then
								g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Pen "..e[2][3]).opacity = 255
								g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Pen "..e[2][3]).opacity = 0
							else                             
								g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Guess "..e[2][3]).opacity = 255
								g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Guess "..e[2][3]).opacity = 0
							end
						else
							error("this should never happen,"..
								" i did something wrong")
						end
					end
					table.remove(error_list,i)
				end
			end
		if error_checking then
			for i =#error_list,1,-1 do
				e = error_list[i]
					if #e[1] == 2 then
					elseif #e[1] == 3 then
						if guesses[e[1][1]][e[1][2]].pen == e[1][3] then
							g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Pen "..e[1][3]).opacity = 0
							g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Pen "..e[1][3]).opacity = 255
						else
							g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Guess "..e[1][3]).opacity = 0
							g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Guess "..e[1][3]).opacity = 255
						end
					else
						error("this should never happen,"..
							" i did something wrong")
					end
					if #e[2] == 2 then
					elseif #e[2] == 3 then
						if guesses[e[2][1]][e[2][2]].pen == e[2][3] then
							g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Pen "..e[2][3]).opacity = 0
							g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Pen "..e[2][3]).opacity = 255
						else                             
							g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Guess "..e[2][3]).opacity = 0
							g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Guess "..e[2][3]).opacity = 255
						end

					else
						error("this should never happen,"..
							" i did something wrong")
					end
			end	
		end	
		print("size of error list = "..#error_list)
	end



	function g:pen(r,c,p,status)
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
			guesses[r][c][guesses[r][c].pen] = false

print("here")
			g:rem_from_err_list(r,c,guesses[r][c].pen)
			--if toggling out a penned number
			if guesses[r][c].pen == p then
				print("removing pen")
				empty_spaces = empty_spaces + 1
				g.grid_of_groups[r][c]:find_child("Pen "..guesses[r][c].pen).opacity = 0

				guesses[r][c].pen = 0
				guesses[r][c].num = 0
--[[
				g.board:find_child("Pen "..r.." "..c).text=""
				g.board:find_child("Pen_s "..r.." "..c).text=""
--]]
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
					g.grid_of_groups[r][c]:find_child("Guess "..i).opacity = 0
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
		if guesses[r][c].pen ~= 0 then
			g:rem_from_err_list(r,c,guesses[r][c].pen)
			g.grid_of_groups[r][c]:find_child("Pen "..guesses[r][c].pen).opacity = 0
		end

		guesses[r][c].pen = p
		guesses[r][c][p] = true
local ggroup = 	g.grid_of_groups[r][c]
local cchild = ggroup:find_child("Pen "..p)
cchild.opacity = 255

--[[
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
--]]
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
			g:rem_from_err_list(r,c,guesses[r][c].pen)

			g.grid_of_groups[r][c]:find_child("Pen "..guesses[r][c].pen).opacity = 0
			g.grid_of_groups[r][c]:find_child("Guess "..guess).opacity = 255


			guesses[r][c].pen = 0
			--add the penciled guess
			guesses[r][c][guess] = true
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
			g:rem_from_err_list(r,c,guess)
			g.grid_of_groups[r][c]:find_child("Guess "..guess).opacity = 0

			if status ~= "REDO" and status ~= "UNDO" then
				table.insert(undo_list,{g.toggle_guess,r,c,guess})
				if #undo_list > 100 then
					table.remove(undo_list,1)
				end
			elseif status ~= "REDO" and status ~= "UNDO" then
				redo_list = {}
			end

		--if toggling it on
		else
				if guesses[r][c].num == 0 then
					empty_spaces = empty_spaces - 1
				end
				guesses[r][c].num = guesses[r][c].num + 1


			--guesses[r][c].sz = guesses[r][c].sz + 1
			guesses[r][c][guess] = true
			g.grid_of_groups[r][c]:find_child("Guess "..guess).opacity = 255

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
					elseif #e[1] == 3 then
						if guesses[e[1][1]][e[1][2]].pen == e[1][3] then
							g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Pen "..e[1][3]).opacity = 255
							g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Pen "..e[1][3]).opacity = 0
						else
							g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Guess "..e[1][3]).opacity = 255
							g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Guess "..e[1][3]).opacity = 0
						end

					else
						error("this should never happen,"..
							" i did something wrong")
					end
					if #e[2] == 2 then
					elseif #e[2] == 3 then
						if guesses[e[2][1]][e[2][2]].pen == e[2][3] then
							g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Pen "..e[2][3]).opacity = 255
							g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Pen "..e[2][3]).opacity = 0
						else
							g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Guess "..e[2][3]).opacity = 255
							g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Guess "..e[2][3]).opacity = 0
						end

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
					g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Pen "..e[1][3]).opacity = 0
					g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Pen "..e[1][3]).opacity = 255
				else
					g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Guess "..e[1][3]).opacity = 0
					g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Guess "..e[1][3]).opacity = 255
				end
			else
				error("this should never happen,"..
					" i did something wrong")
			end
			if #e[2] == 2 then
			elseif #e[2] == 3 then
				if guesses[e[2][1]][e[2][2]].pen == e[2][3] then
					g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Pen "..e[2][3]).opacity = 0
					g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Pen "..e[2][3]).opacity = 255
				else
					g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Guess "..e[2][3]).opacity = 0
					g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Guess "..e[2][3]).opacity = 255
				end
			else
				error("this should never happen,"..
					" i did something wrong")
			end
		end
	end
	function g:undo()
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
			g:rem_from_err_list(r,c,guesses[r][c].pen)
			g.grid_of_groups[r][c]:find_child("Pen "..guesses[r][c].pen).opacity = 0

			guesses[r][c].pen = 0
			guesses[r][c].num = 0
		else

		local params = {}
			for i = 1,9 do
				if guesses[r][c][i] then
					g:rem_from_err_list(r,c,i)
					guesses[r][c][i] = false
					g.grid_of_groups[r][c]:find_child("Guess "..i).opacity = 0
					--guess.opacity = 0
					table.insert(params,i)
				end
			end
			guesses[r][c].num = 0

			table.insert(undo_list,{g.set_pencil,r,c,params})
		end
	end
	function g:set_pencil(r,c,nums)
		if guesses[r][c].num == 0 then
			empty_spaces = empty_spaces - 1
		end

		for i = 1,9 do
			if guesses[r][c][i] then
				g:rem_from_err_list(r,c,i)
				guesses[r][c][i] = false
				g.grid_of_groups[r][c]:find_child("Guess "..i).opacity = 0
--				guess.color = "FFFFFF"
--				guess.opacity = 0
			end
		end
		for i = 1,#nums do
			guesses[r][c][nums[i]] = true
			g.grid_of_groups[r][c]:find_child("Guess "..i).opacity = 255
			g:add_to_err_list(r,c,i)
		end
		if guesses[r][c].pen ~= 0 then
			g:rem_from_err_list(r,c,guesses[r][c].pen)
			g.grid_of_groups[r][c]:find_child("Pen "..guesses[r][c].pen).opacity = 0

			guesses[r][c].pen = 0
		end
		guesses[r][c].num = #nums
	--	g.board:find_child("Pen "..r.." "..c).text=""
	--	g.board:find_child("Pen_s "..r.." "..c).text=""

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
