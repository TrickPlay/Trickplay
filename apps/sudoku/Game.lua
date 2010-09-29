local TILE_WIDTH  = 100
local TILE_GUTTER = 10
local SET_GUTTER  = 20
local TOP_GAP     = (TILE_WIDTH*9 + TILE_GUTTER*6 + SET_GUTTER*2)/2
assert(TOP_GAP >= SET_GUTTER, "flawed #defines for the board..." )



function BoardGen(number_of_givens)
    assert(number_of_givens <= 60, "in BoardGen, number_of_givens is too large")
    assert(number_of_givens >= 25, "in BoardGen, number_of_givens is too small")
    local base = 
    {
        {1,2,3,4,5,6,7,8,9},
        {4,5,6,7,8,9,1,2,3},
        {7,8,9,1,2,3,4,5,6},
        {2,3,4,5,6,7,8,9,1},
        {5,6,7,8,9,1,2,3,4},
        {8,9,1,2,3,4,5,6,6},
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
                    temp[k] = base[k][first+3*i]
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

function DevelopBoard(group,givens)
	local t
	---------------------------------
	for r = 1,9 do     for c = 1,9 do
	---------------------------------
		

		if givens[r][c] ~= 0 then
			t = Text
			{
				name = "Given "..r.." "..c,
				text = givens[r][c],
				font = "Sans 36px",
			}
			t.anchor_point={t.w/2,t.h/2}
			t.x = (c-1)*TILE_WIDTH + 
				math.floor(c/3)*SET_GUTTER +
				(c%3)*TILE_GUTTER
			t.y = (r-1)*TILE_WIDTH + 
				math.floor(r/3)*SET_GUTTER +
				(r%3)*TILE_GUTTER
			group:add(t)
		else
			
		end

	---------------------------------
	end	           end
	---------------------------------

end

Game = Class(function(g,number_of_givens, ...)
	local givens = BoardGen(number_of_givens)
	local guesses = 
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
	g.board = Group{}
	DevelopBoard(g.board,givens)
	function g:add_guess(r,c,guess)
		if givens[r][c] ~= 0 then
			table.insert(guesses[r][c],guess)
			return true
		else
			return false
		end
	end
end)


--[[
will print a board
local t = BoardGen(25)
for i = 1, #t do
    print(t[i][1],t[i][2],t[i][3],t[i][4],t[i][5],t[i][6],t[i][7],t[i][8],t[i][9])
end

--]]
