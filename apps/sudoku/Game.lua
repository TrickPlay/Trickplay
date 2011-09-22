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
function guess_x(g)
	return ((g-1)%3-1)*(TILE_WIDTH/4+5)
end
function guess_y(g)
	return (math.floor((g-1)/3)-1)*(TILE_WIDTH/4+5)
end

function DevelopBoard(grid_of_groups,givens,guesses,blox)
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
		grid_of_groups[r][c]:add(backing)
		grid_of_groups[r][c].x = ((c-1)%3)*(TILE_WIDTH+TILE_GUTTER)
				+ TILE_WIDTH/2
		grid_of_groups[r][c].y = ((r-1)%3)*(TILE_WIDTH+TILE_GUTTER)
				+ TILE_WIDTH/2

		if givens[r][c] ~= 0 then
			empty_spaces = empty_spaces - 1
			t = Clone{
				name = "Given "..r.." "..c,
				source = given_nums[ givens[r][c] ],
				opacity=0
			}
			t.anchor_point={a_p.big[ givens[r][c] ][1],a_p.big[ givens[r][c] ][2]} 

			grid_of_groups[r][c]:add(t)
			t.opacity=255
		else
			table.insert(cheat_list,{r,c})
			if guesses[r][c].pen ~= 0 then
				empty_spaces = empty_spaces - 1

				t= Clone{
					name   = "Pen "..guesses[r][c].pen,
					source = pen_nums[guesses[r][c].pen],
				}
				t.anchor_point={a_p.big[ guesses[r][c].pen ][1],a_p.big[ guesses[r][c].pen ][2]}
				grid_of_groups[r][c]:add(t)
			else
				for g = 1,9 do
					if guesses[r][c][g] then
						t = Clone{
							name   = "Guess "..g,
							source = pencil_nums[g],
						}
						t.scale = {1/2,1/2}
						t.anchor_point={a_p.sm[g][1],a_p.sm[g][2]}
						t.x = guess_x(g)
						t.y = guess_y(g)
						grid_of_groups[r][c]:add(t)

					end
				end
			end
		end

	---------------------------------
	end	           end
	---------------------------------
	return empty_spaces, cheat_list
end


Game = Class(function(g,the_givens,solution, the_guesses,blox,undo, ...)
	--set up all the Game Board variables
	local error_checking = false
	local empty_spaces   = 81
	local the_blox       = blox
	local error_list     = {}
	local undo_list      = undo or {}
	local redo_list      = {}
	local cheat_list     = {}
	local givens         = the_givens
	local guesses        = {}
	local sol            = solution
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

	g.grid_of_groups = {}
	empty_spaces, cheat_list = DevelopBoard(g.grid_of_groups,givens, guesses,blox)




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
	function g:get_guesses(r,c) return guesses[r][c] end
	function g:get_givens(r,c)  return givens[r][c]  end
	function g:get_all_givens() return givens        end
	function g:get_sol()        return sol           end
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
		empty_spaces,cheat_list = DevelopBoard(g.grid_of_groups,givens, guesses,the_blox)
	end
	function g:check_guess(r,c,v,t)
		--  r = row
		--  c = column
		--  v = value of the guess
		--  t = the error_list

		local m = {} --the mini list of updates

		-- for all the other tiles on that column
		for rr = 1,9 do
			if givens[rr][c] == v then
				table.insert(t,{{r,c,v},{rr,c}})
				table.insert(m,{rr,c})
			elseif guesses[rr][c].pen == v and rr ~= r then
				table.insert(t,{{r,c,v},{rr,c,v}})
				table.insert(m,{rr,c,v})
			end
		end
		--for all the other tiles on that row
		for cc = 1,9 do
			if givens[r][cc] == v then
				table.insert(t,{{r,c,v},{r,cc}})
				table.insert(m,{r,cc})
			elseif guesses[r][cc].pen == v and cc ~= c then
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
					elseif  guesses[rr][cc].pen == v and 
						(cc ~= c or rr ~= r) then
						table.insert(t,{{r,c,v},{rr,cc,v}})
						table.insert(m,{rr,cc,v})
					end
				end
			end
		end

		return m
	end
	function g:init_error_list()
		error_list = {}
		-- check each guess sitting on every tile
		-----------------------------------------------------------
		for r = 1,9 do   for c = 1,9 do   if givens[r][c] == 0 then 
  
						if guesses[r][c].pen ~= 0 then
		-----------------------------------------------------------

			g:check_guess(r,c,guesses[r][c].pen,error_list)

		-----------------------------------------------------------
		end          end          end          end   
		-----------------------------------------------------------
	end
	g:init_error_list()
	function g:add_to_err_list(r,c,guess)
		local clone
		local updates = g:check_guess(r,c,guess,error_list)
		local old_nums = {}
		local new_nums = {}


		if error_checking then

			for i,u in ipairs(updates) do	if #u == 3 then
				table.insert(old_nums,g.grid_of_groups[u[1]][u[2]]:
					find_child("Pen "..u[3]))
				clone = Clone{
					name    = "WR_Pen "..u[3],
					source  = wr_pen_nums[ u[3] ],
					opacity = 0,
					anchor_point = {a_p.big[ u[3] ][1],a_p.big[ u[3] ][2]}
				}
				table.insert(new_nums,{clone,u[1],u[2]})
			end								end
			if #updates == 0 then
				clone = Clone{
					name    = "Pen "..guess,
					source  = pen_nums[guess],
					opacity = 0,
					anchor_point = {a_p.big[guess][1],a_p.big[guess][2]}
				}
	
				table.insert(new_nums,{clone,r,c})
			else

				clone = Clone{
					name    = "WR_Pen "..guess,
					source  = wr_pen_nums[guess],
					opacity = 0,
					anchor_point = {a_p.big[guess][1],a_p.big[guess][2]}
				}
				table.insert(new_nums,{clone,r,c})

			end
		else
				clone = Clone{
					name    = "Pen "..guess,
					source  = pen_nums[guess],
					opacity = 0,
					anchor_point = {a_p.big[guess][1],a_p.big[guess][2]}
				}
				table.insert(new_nums,{clone,r,c})
		end
		return old_nums, new_nums
	end
	function g:rem_from_err_list(r,c,guess)
		local clone
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
			if e[1][1] == r and e[1][2] == c and e[1][3] == guess then
				if error_checking  then
					table.insert(updates,{e[2][1],e[2][2],e[2][3]})
				end
				table.remove(error_list,i)

			elseif e[2][1] == r and e[2][2] == c and e[2][3] == guess then
				if error_checking then
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
					clone = Clone{
						name    = "Pen "..u[3],
						source  = pen_nums[ u[3] ],
						opacity = 0,
						anchor_point = {a_p.big[u[3]][1],a_p.big[u[3]][2]}
					}
					table.insert(new_nums,{clone,u[1],u[2]})
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
		end	
		return old_nums, new_nums
	end
	local anim_nums = nil
	function animate_numbers(old_nums,new_nums,next_timeline)
		if next_timeline == nil then restore_keys() end
		if anim_nums ~= nil then
			anim_nums:stop()
			anim_nums:on_completed()
			clear(anim_nums)
			anim_nums = nil
		end
		anim_nums = Timeline{duration=60}
		for i = 1, #new_nums do
			g.grid_of_groups[new_nums[i][2]][new_nums[i][3]]:add(new_nums[i][1])
		end
		save(anim_nums)
		function anim_nums.on_new_frame(t,_,p)
			local msecs = t.elapsed
			for i = 1, #old_nums do old_nums[i].opacity    = 255*(1-p) end
			for i = 1, #new_nums do new_nums[i][1].opacity = 255*p     end
		end
		function anim_nums:on_completed()
			for i = 1, #old_nums do old_nums[i]:unparent()    end
			for i = 1, #new_nums do new_nums[i][1].opacity = 255 end
			if next_timeline then dolater(next_timeline) end
			--else restore_keys() end
			clear(anim_nums)
		end
		anim_nums:start()
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
				empty_spaces = empty_spaces + 1
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
			animate_numbers(old_nums,new_nums,player_won)
		else
			animate_numbers(old_nums,new_nums)
		end
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
		local clone
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
				empty_spaces = empty_spaces + 1
        
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
				clone = Clone{
					name    = "Guess "..guess,
					source  = pencil_nums[ guess ],
					x       = guess_x(guess),
					y       = guess_y(guess),
					scale   = {.5,.5},
					opacity = 0,
					anchor_point = {a_p.sm[guess][1],a_p.sm[guess][2]}
				}
				table.insert(new_nums,{clone,r,c})
				guesses[r][c].pen = 0
				--add the penciled guess
				guesses[r][c][guess] = true
		--if toggling the guess off
		elseif guesses[r][c][guess] then
				guesses[r][c].num    = guesses[r][c].num - 1
				guesses[r][c][guess] = false
				table.insert(old_nums,g.grid_of_groups[r][c]:find_child("Guess "..guess))
        
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
				guesses[r][c].num = guesses[r][c].num + 1
				guesses[r][c][guess] = true
				clone = Clone{
					name    = "Guess "..guess,
					source  = pencil_nums[ guess ],
					x       = guess_x(guess),
					y       = guess_y(guess),
					scale   = {.5,.5},
					opacity = 0,
					anchor_point = {a_p.sm[guess][1],a_p.sm[guess][2]}
				}
				table.insert(new_nums,{clone,r,c})
				if status ~= "REDO" and status ~= "UNDO" then
					table.insert(undo_list,{"toggle_guess",r,c,guess})
					if #undo_list > 100 then
						table.remove(undo_list,1)
					end
				elseif status ~= "REDO" and status ~= "UNDO" then
					redo_list = {}
				end
		end
		if empty_spaces == 0 and #error_list == 0 then
			animate_numbers(old_nums,new_nums,player_won)
		else
			animate_numbers(old_nums,new_nums)
		end

	end
	function g:error_check()
		local clone
		local old_nums = {}
		local new_nums = {}
		if error_checking then
			error_checking = false
				for i =#error_list,1,-1 do
					e = error_list[i]
					if #e[1] == 2 then
					elseif #e[1] == 3 then
							clone = Clone{
								name    = "Pen "..e[1][3],
								source  = pen_nums[ e[1][3] ],
								opacity = 0,
								anchor_point = {a_p.big[e[1][3]][1],a_p.big[e[1][3]][2]}
							}

							table.insert(new_nums,{clone,e[1][1],e[1][2]})
							table.insert(old_nums,g.grid_of_groups[e[1][1]][e[1][2]]:find_child("WR_Pen "..e[1][3]))
					else
						error("this should never happen,"..
							" i did something wrong")
					end
					if #e[2] == 2 then
					elseif #e[2] == 3 then
							clone = Clone{
								name    = "Pen "..e[2][3],
								source  = pen_nums[ e[2][3] ],
								opacity = 0,
								anchor_point = {a_p.big[e[2][3]][1],a_p.big[e[2][3]][2]}
							}
							table.insert(new_nums,{clone,e[2][1],e[2][2]})

							table.insert(old_nums,g.grid_of_groups[e[2][1]][e[2][2]]:find_child("WR_Pen "..e[2][3]))
					else
						error("this should never happen,"..
							" i did something wrong")
					end
				end
			dolater(animate_numbers,old_nums,new_nums)

			return
		end
		error_checking = true
		local going_red = {} -- this prevents adding multiples of the same number to the tile

		for i,e in ipairs(error_list) do
			if #e[1] == 2 then
			elseif #e[1] == 3 and going_red[ e[1][1].." "..e[1][2] ] == nil then
					table.insert(old_nums,g.grid_of_groups[e[1][1]][e[1][2]]:find_child("Pen "..e[1][3]))
					clone = Clone{
								name    = "WR_Pen "..e[1][3],
								source  = wr_pen_nums[ e[1][3] ],
								opacity = 0,
								anchor_point = {a_p.big[e[1][3]][1],a_p.big[e[1][3]][2]}
					}
					table.insert(new_nums,{clone,e[1][1],e[1][2]})
					going_red[ e[1][1].." "..e[1][2] ] = true
			end
			if #e[2] == 2 then
			elseif #e[2] == 3 and going_red[ e[2][1].." "..e[2][2] ] == nil then
					table.insert(old_nums,g.grid_of_groups[e[2][1]][e[2][2]]:find_child("Pen "..e[2][3]))
					clone = Clone{
						name    = "WR_Pen "..e[2][3],
						source  = wr_pen_nums[ e[2][3] ],
						opacity = 0,
						anchor_point = {a_p.big[e[2][3]][1],a_p.big[e[2][3]][2]}
					}

					table.insert(new_nums,{clone,e[2][1],e[2][2]})
					going_red[ e[2][1].." "..e[2][2] ] = true

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
			guesses[r][c].pen = 0
			guesses[r][c].num = 0
		else

			local params = {}
			for i = 1,9 do   if guesses[r][c][i] then
				
					guesses[r][c][i] = false
					table.insert(old_nums,g.grid_of_groups[r][c]:
						find_child("Guess "..i))
					table.insert(params,i)

			end              end
			guesses[r][c].num = 0

			table.insert(undo_list,{"set_pencil",r,c,params})

		end
		dolater(animate_numbers,old_nums,new_nums)

	end
	function g:set_pencil(r,c,nums)
		local clone
		mediaplayer:play_sound("audio/pencil.mp3")
		local old_nums = {}
		local new_nums = {}

		if guesses[r][c].num == 0 then
			empty_spaces = empty_spaces - 1
		end

		for i = 1,9 do    if guesses[r][c][i] then
		
				g:rem_from_err_list(r,c,i)
				guesses[r][c][i] = false
				table.insert(old_nums,
					g.grid_of_groups[r][c]:find_child("Guess "..i))

		end               end
		for i = 1,#nums do
			guesses[r][c][nums[i]] = true
			clone = Clone{
				name    = "Guess "..nums[i]  ,
				source  = pen_nums[ nums[i] ],
				x       = guess_x(  nums[i] ),
				y       = guess_y(  nums[i] ),
				scale   = {.5,.5},
				opacity = 0,
				anchor_point = { a_p.sm[nums[i]][1] ,
				                 a_p.sm[nums[i]][2] }
			}
			
			table.insert(new_nums,{clone,r,c})
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

	--this allows us to save the undo functions in settings
	local str_funcs = 
	{
		["pen"]          = g.pen,
		["toggle_guess"] = g.toggle_guess,
		["set_pencil"]   = g.set_pencil
	}

	function g:undo()
		local params = {}

		if #undo_list > 0 then
			mediaplayer:play_sound("audio/undo.mp3")

			params = table.remove(undo_list)
			table.insert(redo_list,{params[1],params[2],params[3],params[4]})
			str_funcs[params[1]](g,params[2],params[3],params[4],"UNDO")
		else
			restore_keys()
		end
		return params[2],params[3]
	end


end)

