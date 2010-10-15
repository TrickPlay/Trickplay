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
	local solution = {}

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

	for r = 1,9 do
		solution[r] = {}
		for c = 1,9 do
			solution[r][c] = base[r][c]
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

    return base, solution
end

function DevelopBoard(grid_of_groups,givens,guesses,blox)
--	local grid_of_groups = {}
	local cheat_list = {}
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
			else
				table.insert(cheat_list,{r,c})
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
	return empty_spaces, cheat_list
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


Game = Class(function(g,the_givens,solution, the_guesses,blox,undo, ...)
	local error_checking = false
	local empty_spaces = 81
	local the_blox = blox
	local error_list = {}
	local undo_list  = undo or {}
	local redo_list  = {}
	local cheat_list = {}
	local givens = the_givens--BoardGen(number_of_givens)
	local guesses = {}
	local sol = solution
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
	empty_spaces, cheat_list = DevelopBoard(g.grid_of_groups,givens, guesses,blox)
print(empty_spaces)
	--g.board.anchor_point = {g.board.w/2,g.board.h/2}
	--g.board.position = {500,0}--{screen.w/2+40,screen.h/2}
	function g:save()
		if empty_spaces == 0 and #error_list == 0 then
			settings.givens  = nil
			settings.guesses = nil
			settings.sol     = nil
			settings.undo    = nil
		else
			settings.givens  = givens
			settings.guesses = guesses
			settings.sol     = sol
			settings.undo    = undo_list
		end
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
	function g:get_sol()
		return sol
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

		local m = {} --the mini list of updates

		-- for all the other tiles on that column
		for rr = 1,9 do
			if givens[rr][c] == v then
				table.insert(t,{{r,c,v},{rr,c}})
				table.insert(m,{rr,c})
			elseif guesses[rr][c].pen == v and--guesses[rr][c][v] and 
				rr ~= r then
				table.insert(t,{{r,c,v},{rr,c,v}})
				table.insert(m,{rr,c,v})
			end
		end
		--for all the other tiles on that row
		for cc = 1,9 do
			if givens[r][cc] == v then
				table.insert(t,{{r,c,v},{r,cc}})
				table.insert(m,{r,cc})
			elseif guesses[r][cc].pen == v and-- guesses[r][cc][v] and 
				cc ~= c then
				table.insert(t,{{r,c,v},{r,cc,v}})
				table.insert(m,{r,cc,v})
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
						table.insert(m,{rr,cc})
					elseif  guesses[rr][cc].pen == v and--guesses[rr][cc][v] and 
						(cc ~= c or rr ~= r) then
						table.insert(t,{{r,c,v},{rr,cc,v}})
						table.insert(m,{rr,cc,v})
					end
				end
			end
		end

		--if #m > 0 then table.insert(m,{r,c,v}) end
		return m
	end
	function g:init_error_list()
		error_list = {}
		-- check each guess sitting on every tile
		-----------------------------------------------------------
		for r = 1,9 do   for c = 1,9 do   if givens[r][c] == 0 then 
  
		                 --for v = 1,9 do    if guesses[r][c][v] then
						if guesses[r][c].pen ~= 0 then
		-----------------------------------------------------------

			g:check_guess(r,c,guesses[r][c].pen,error_list)--v,error_list)

		-----------------------------------------------------------
		end          end          end          end    --      end
		-----------------------------------------------------------
	end
	g:init_error_list()
	function g:add_to_err_list(r,c,guess)
		local updates = g:check_guess(r,c,guess,error_list)
		local old_nums = {}
		local new_nums = {}
		if error_checking then

			for i,u in ipairs(updates) do	if #u == 3 then
				table.insert(old_nums,g.grid_of_groups[u[1]][u[2]]:
					find_child("Pen "..u[3]))
				table.insert(new_nums,g.grid_of_groups[u[1]][u[2]]:
					find_child("WR_Pen "..u[3]))
			end								end
			if #updates == 0 then
				table.insert(new_nums,g.grid_of_groups[r][c]:
					find_child("Pen "..guess))
			else
				table.insert(new_nums,g.grid_of_groups[r][c]:
					find_child("WR_Pen "..guess))
			end

--[=[
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
--]=]
		else
			table.insert(new_nums,g.grid_of_groups[r][
				c]:find_child("Pen "..guess))
		end
		return old_nums, new_nums
	end
	function g:rem_from_err_list(r,c,guess)
		--if error_checking then
			--have to search backwards in order to update the
			--table at the same time
			local e
			local updates  = {}
			local old_nums = {}
			local new_nums = {}
			local found_instance = false
			for i =#error_list,1,-1 do
				e = error_list[i]
				print(e[1][1],e[1][2],e[1][3],e[2][1],e[2][2],e[2][3])
				if     (e[1][1] == r and e[1][2] == c 
				                     and e[1][3] == guess) then
					if error_checking  then--and e[2][3] ~= nil then
						table.insert(updates,{e[2][1],e[2][2],e[2][3]})
					end
					table.remove(error_list,i)

				elseif (e[2][1] == r and e[2][2] == c 
				                     and e[2][3] == guess) then
					if error_checking then--and e[1][3] ~= nil then
						table.insert(updates,{e[1][1],e[1][2],e[1][3]})
					end
					table.remove(error_list,i)
				end
			end
		if error_checking then
			for i,u in ipairs(updates) do if #u == 3 then
				found_instance = false
				for j,e in ipairs(error_list) do
					if (u[1] == e[1][1] and u[2] == e[1][2]  and 
					                        u[3] == e[1][3]) or
					   (u[1] == e[2][1] and u[2] == e[2][2]  and 
					                        u[3] == e[2][3]) then
						found_instance = true
						break
					end
				end

				if found_instance == false then
					table.insert(old_nums,g.grid_of_groups[u[1]][u[2]]:
						find_child("WR_Pen "..u[3]))
					table.insert(new_nums,g.grid_of_groups[u[1]][u[2]]:
						find_child("Pen "..u[3]))
				end
			end	end
			if #updates == 0 then
				table.insert(old_nums,g.grid_of_groups[r][c]:
					find_child("Pen "..guess))
			else
				table.insert(old_nums,g.grid_of_groups[r][c]:
					find_child("WR_Pen "..guess))
			end
		else
			table.insert(old_nums,g.grid_of_groups[r][c]:
				find_child("Pen "..guess))

--[=[
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
--]=]
		end	
	--	print("size of error list = "..#error_list)
		return old_nums, new_nums
	end

	function animate_numbers(old_nums,new_nums,next_timeline)
		local timeline = Timeline{duration=100}
		save(timeline)
		function timeline.on_new_frame(t,msecs,p)
			for i = 1, #old_nums do old_nums[i].opacity = 255*(1-p) end
			for i = 1, #new_nums do new_nums[i].opacity = 255*p     end
		end
		function timeline:on_completed()
			for i = 1, #old_nums do old_nums[i].opacity = 0   end
			for i = 1, #new_nums do new_nums[i].opacity = 255 end
			if next_timeline then dolater(next_timeline)
			else restore_keys() end
			clear(timeline)
		end
		timeline:start()
	end
	function table_concat(t1,t2)
		for i = 1,#t2 do
			table.insert(t1,t2[i])
		end
	end

	function g:pen(r,c,p,status)

		if givens[r][c] ~= 0 then 
			restore_keys()
			return
		end
		mediaplayer:play_sound("audio/pen.mp3")

		local old_nums = {}
		local new_nums = {}
		local o , n


		--if another pen number was there
		if guesses[r][c].pen ~= 0 then
			if status ~= "UNDO" then
				table.insert(undo_list,{"pen",r,c,
					guesses[r][c].pen})
				if #undo_list > 100 then
					table.remove(undo_list,1)
				end
			elseif status ~= "REDO" then
				redo_list = {}
			end
			guesses[r][c][guesses[r][c].pen] = false

			o,n = g:rem_from_err_list(r,c,guesses[r][c].pen)
			table_concat(old_nums,o)
			table_concat(new_nums,n)
			--if toggling out a penned number
			if guesses[r][c].pen == p then
				print("removing pen")
				empty_spaces = empty_spaces + 1
--				table.insert(old_nums,g.grid_of_groups[r][c]:find_child("Pen "..guesses[r][c].pen))--.opacity = 0

				guesses[r][c].pen = 0
				guesses[r][c].num = 0
				dolater(animate_numbers,old_nums,new_nums)

				return
			end
		--if pencil numbers were there
		elseif guesses[r][c].num > 0 then
			local params = {}
			empty_spaces = empty_spaces - 1

			for i = 1,9 do
				if guesses[r][c][i] then
					table.insert(params,i)
					guesses[r][c][i] = false
					table.insert(old_nums,g.grid_of_groups[r][c]:
						find_child("Guess "..i))
				end
			end
			if status ~= "UNDO" then
				table.insert(undo_list,{"set_pencil",r,c,
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
				table.insert(undo_list,{"pen",r,c,p})
				if #undo_list > 100 then
					table.remove(undo_list,1)
				end
			elseif status ~= "REDO" then
				redo_list = {}
			end
			empty_spaces = empty_spaces - 1
		end

		guesses[r][c].num = 1
		guesses[r][c].pen = p
		guesses[r][c][p] = true

		o,n=g:add_to_err_list(r,c,p)
		table_concat(old_nums,o)
		table_concat(new_nums,n)

		if empty_spaces == 0 and #error_list == 0 then
			dolater(animate_numbers,old_nums,new_nums,player_won)
		else
			dolater(animate_numbers,old_nums,new_nums)
		end
		print(empty_spaces)
	end
	function g:cheat()
		local hold_list = cheat_list
		cheat_list = {}
		local l = #hold_list
		local r,c
		for i=1,l do
			table.insert(cheat_list,
				table.remove(hold_list,
					math.random(1,#hold_list)
				)
			)
		end

		--pull the first one that fits
		for i = 1,l do
			r = cheat_list[i][1]
			c = cheat_list[i][2]

			--if guesses[r][c].pen ~= 0 or guesses[r][c].num == 0 then
				if guesses[r][c].pen ~= sol[r][c] then
					g:pen(r,c,sol[r][c])
					return
				end
		--	end
		end
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
		if givens[r][c] ~= 0 then
			restore_keys()
			return
		end
		mediaplayer:play_sound("audio/pencil.mp3")

		local old_nums = {}
		local new_nums = {}
		local o,n

		--if there was an existing pen mark on the tile
		if guesses[r][c].pen ~= 0 then
			if guesses[r][c].num == 0 then
				empty_spaces = empty_spaces + 1
			end

			-- remove the "penned" guess, add it to the undo list
			o,n = g:rem_from_err_list(r, c, guesses[r][c].pen)	
			table_concat(old_nums,o)
			table_concat(new_nums,n)
			if status ~= "REDO" and status ~= "UNDO" then
				table.insert(undo_list, {"pen",r,c,guesses[r][c].pen})
				if #undo_list > 100 then
					table.remove(undo_list,1)
				end
			elseif status ~= "REDO" and status ~= "UNDO" then
				redo_list = {}
			end

			guesses[r][c][guesses[r][c].pen] = false

--			table.insert(old_nums,g.grid_of_groups[r][c]:find_child("Pen "..guesses[r][c].pen))--.opacity = 0
			table.insert(new_nums,g.grid_of_groups[r][c]:find_child("Guess "..guess))--.opacity = 255


			guesses[r][c].pen = 0
			--add the penciled guess
			guesses[r][c][guess] = true
			--o,n = g:add_to_err_list(r,c,guess)
			--table_concat(old_nums,o)
			--table_concat(new_nums,n)
			--if empty_spaces == 0 and #error_list == 0 then
			--	player_won()
			--end

		--if toggling the guess off
		elseif guesses[r][c][guess] then
				guesses[r][c].num = guesses[r][c].num - 1
			--	if guesses[r][c].num == 0 then
			--		empty_spaces = empty_spaces + 1
			--	end


--			guesses[r][c].sz = guesses[r][c].sz - 1
			guesses[r][c][guess] = false
			--g:rem_from_err_list(r,c,guess)
			table.insert(old_nums,g.grid_of_groups[r][c]:find_child("Guess "..guess))--.opacity = 0

			if status ~= "REDO" and status ~= "UNDO" then
				table.insert(undo_list,{"toggle_guess",r,c,guess})
				if #undo_list > 100 then
					table.remove(undo_list,1)
				end
			elseif status ~= "REDO" and status ~= "UNDO" then
				redo_list = {}
			end

		--if toggling it on
		else
			--if guesses[r][c].num == 0 then
			--	empty_spaces = empty_spaces - 1
			--end
			guesses[r][c].num = guesses[r][c].num + 1


			--guesses[r][c].sz = guesses[r][c].sz + 1
			guesses[r][c][guess] = true
			table.insert(new_nums,g.grid_of_groups[r][c]:find_child("Guess "..guess))--.opacity = 255

			if status ~= "REDO" and status ~= "UNDO" then
				table.insert(undo_list,{"toggle_guess",r,c,guess})
				if #undo_list > 100 then
					table.remove(undo_list,1)
				end
			elseif status ~= "REDO" and status ~= "UNDO" then
				redo_list = {}
			end
			--g:add_to_err_list(r,c,guess)
--			if empty_spaces == 0 and #error_list == 0 then
--				player_won()
--			end
		end
		if empty_spaces == 0 and #error_list == 0 then
			dolater(animate_numbers,old_nums,new_nums,player_won())
		else
			dolater(animate_numbers,old_nums,new_nums)
		end

		print(empty_spaces)
	end
	function g:error_check()
		local old_nums = {}
		local new_nums = {}
		if error_checking then
			error_checking = false
				for i =#error_list,1,-1 do
					e = error_list[i]
						--table.remove(error_list,i)

					if #e[1] == 2 then
					elseif #e[1] == 3 then
					--	if guesses[e[1][1]][e[1][2]].pen == e[1][3] then
							table.insert(new_nums,g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Pen "..e[1][3]))--.opacity = 255
							table.insert(old_nums,g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Pen "..e[1][3]))--.opacity = 0
					--	else
					--		g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Guess "..e[1][3]).opacity = 255
					--		g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Guess "..e[1][3]).opacity = 0
					--	end

					else
						error("this should never happen,"..
							" i did something wrong")
					end
					if #e[2] == 2 then
					elseif #e[2] == 3 then
						--if guesses[e[2][1]][e[2][2]].pen == e[2][3] then
							table.insert(new_nums,g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Pen "..e[2][3]))--.opacity = 255
							table.insert(old_nums,g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Pen "..e[2][3]))--.opacity = 0
						--else
						--	g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Guess "..e[2][3]).opacity = 255
						--	g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Guess "..e[2][3]).opacity = 0
						--end

					else
						error("this should never happen,"..
							" i did something wrong")
					end
					--table.remove(error_list,i)
				end
			dolater(animate_numbers,old_nums,new_nums)

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
			--	if guesses[e[1][1]][e[1][2]].pen == e[1][3] then
					table.insert(old_nums,g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Pen "..e[1][3]))--.opacity = 0
					table.insert(new_nums,g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Pen "..e[1][3]))--.opacity = 255

			--	else
			--		g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Guess "..e[1][3]).opacity = 0
			--		g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Guess "..e[1][3]).opacity = 255
			--	end
			else
				error("this should never happen,"..
					" i did something wrong")
			end
			if #e[2] == 2 then
			elseif #e[2] == 3 then
			--	if guesses[e[2][1]][e[2][2]].pen == e[2][3] then
					table.insert(old_nums,g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Pen "..e[2][3]))--.opacity = 0
					table.insert(new_nums,g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Pen "..e[2][3]))--.opacity = 255
			--	else
			--		g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Guess "..e[2][3]).opacity = 0
			--		g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Guess "..e[2][3]).opacity = 255
			--	end
			else
				error("this should never happen,"..
					" i did something wrong")
			end
		end
		dolater(animate_numbers,old_nums,new_nums)
	end
	function g:clear_tile(r,c)
		mediaplayer:play_sound("audio/pencil.mp3")

		local old_nums = {}
		local new_nums = {}
		local o,n

		if guesses[r][c].pen ~= 0 then
			empty_spaces = empty_spaces + 1

			table.insert(undo_list,{"pen",r,c,guesses[r][c].pen})
			o,n = g:rem_from_err_list(r,c,guesses[r][c].pen)
			table_concat(old_nums,o)
			table_concat(new_nums,n)
			guesses[r][c][guesses[r][c].pen] = false

			--table.insert(old_nums,g.grid_of_groups[r][c]:find_child("Pen "..guesses[r][c].pen))--.opacity = 0

			guesses[r][c].pen = 0
			guesses[r][c].num = 0
		else

			local params = {}
			for i = 1,9 do
				if guesses[r][c][i] then
					--g:rem_from_err_list(r,c,i)
					guesses[r][c][i] = false
					table.insert(old_nums,g.grid_of_groups[r][c]:find_child("Guess "..i))--.opacity = 0
					--guess.opacity = 0
					table.insert(params,i)
				end
			end
			guesses[r][c].num = 0

			table.insert(undo_list,{"set_pencil",r,c,params})
			dolater(animate_numbers,old_nums,new_nums)

		end
	end
	function g:set_pencil(r,c,nums)
		mediaplayer:play_sound("audio/pencil.mp3")
		print("set called wit", nums[1],nums[2],nums[3],nums[4])
		local old_nums = {}
		local new_nums = {}

		if guesses[r][c].num == 0 then
			empty_spaces = empty_spaces - 1
		end

		for i = 1,9 do
			if guesses[r][c][i] then
				g:rem_from_err_list(r,c,i)
				guesses[r][c][i] = false
				table.insert(old_nums,
					g.grid_of_groups[r][c]:find_child("Guess "..i))
			end
		end
		for i = 1,#nums do
			guesses[r][c][nums[i]] = true
			table.insert(new_nums,
				g.grid_of_groups[r][c]:find_child("Guess "..nums[i]))
			g:add_to_err_list(r,c,i)
		end
		if guesses[r][c].pen ~= 0 then
			g:rem_from_err_list(r,c,guesses[r][c].pen)
			table.insert(old_nums,
				g.grid_of_groups[r][c]:find_child("Pen "..guesses[r][c].pen))
			guesses[r][c].pen = 0
		end
		guesses[r][c].num = #nums
		dolater(animate_numbers,old_nums,new_nums)

	end

local str_funcs = 
{
	["pen"] = g.pen,
	["toggle_guess"] = g.toggle_guess,
	["set_pencil"] = g.set_pencil
}

	function g:undo()

		if #undo_list > 0 then
			mediaplayer:play_sound("audio/undo.mp3")

			params = table.remove(undo_list)
			table.insert(redo_list,{params[1],params[2],params[3],params[4]})
print("undooo",params[2],params[3],params[4])
			str_funcs[params[1]](g,params[2],params[3],params[4],"UNDO")
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
		else
			restore_keys()
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
