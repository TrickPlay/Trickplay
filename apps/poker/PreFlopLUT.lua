--[[
    this is what should be called for result

    i.e. preFlopLUT[Position.EARLY][RaiseFactor.UR][Ranks.ACE.num][Ranks.ACE.num][SUITED]
    @return value in Moves table (Moves.CALL)

    Cards must be listed in order, hence ...[Ranks.JACK.num][Ranks.ACE.num]...
    does not guarentee a valid result!!
--]]
preFlopLUT = nil

--[[
    values below are also in Globals.lua
--]]
local Position = {
    EARLY = 1,
    EARLY2 = 2,     --Same as Early but redundancy for 6 players
    MIDDLE = 3,
    LATE = 4,
    SMALL_BLIND = 5,
    BIG_BLIND = 6
}
local RaiseFactor = {
    UR = 1,     --Un-Raised Big-Blind
    R = 2,      --Raised Big-Blind
    RR = 3      --Re-Raised Big-Blind
}
local Moves = {
    CALL = 1,
    RAISE = 2,
    FOLD = 3
}
local SUITED = 1
local UNSUITED = 2

--contains pre-flop moves for Early UR condition, used as basis
local baseMovesTable = {}
for i = Ranks.TWO.num,Ranks.ACE.num do
    baseMovesTable[i] = {}
    for j = Ranks.TWO.num,Ranks.ACE.num do
        baseMovesTable[i][j] = {}
        --initialize to folding since occurs most often
        baseMovesTable[i][j][SUITED] = Moves.FOLD
        baseMovesTable[i][j][UNSUITED] = Moves.FOLD
    end
end

--[[
    Early UR
--]]
--build AA-QQ
for i = Ranks.QUEEN.num,Ranks.ACE.num do
    baseMovesTable[i][i][SUITED] = Moves.RAISE
    baseMovesTable[i][i][UNSUITED] = Moves.RAISE
end
--JJ-22
for i = Ranks.TWO.num, Ranks.JACK.num do
    baseMovesTable[i][i][SUITED] = Moves.CALL
    baseMovesTable[i][i][UNSUITED] = Moves.CALL
end
--AKs, AK, AQs, AQ
for i = Ranks.QUEEN.num,Ranks.KING.num do
    baseMovesTable[Ranks.ACE.num][i][SUITED] = Moves.RAISE
    baseMovesTable[Ranks.ACE.num][i][UNSUITED] = Moves.RAISE
end
--AJs
baseMovesTable[Ranks.ACE.num][Ranks.JACK.num][SUITED] = Moves.RAISE
--ATs
baseMovesTable[Ranks.ACE.num][Ranks.TEN.num][SUITED] = Moves.CALL
--AJ
baseMovesTable[Ranks.ACE.num][Ranks.JACK.num][UNSUITED] = Moves.CALL
--A9s-A7s
for i = Ranks.SEVEN.num,Ranks.NINE.num do
    baseMovesTable[Ranks.ACE.num][i][SUITED] = Moves.CALL
end
--KQs
baseMovesTable[Ranks.KING.num][Ranks.QUEEN.num][SUITED] = Moves.CALL
--KJs
baseMovesTable[Ranks.KING.num][Ranks.JACK.num][SUITED] = Moves.CALL
--QJs
baseMovesTable[Ranks.QUEEN.num][Ranks.JACK.num][SUITED] = Moves.CALL

--Set up some basic pre-flop moves based on Early UR into all different
--Sections of the LUT, use deep copies
local movesTable = {}
for i = Position.EARLY,Position.BIG_BLIND do
    movesTable[i] = {}
    for j = RaiseFactor.UR, RaiseFactor.RR do
        movesTable[i][j] = {}
        for k = Ranks.TWO.num,Ranks.ACE.num do
            movesTable[i][j][k] = {}
            for l = Ranks.TWO.num,Ranks.ACE.num do
                movesTable[i][j][k][l] = {}
                movesTable[i][j][k][l][SUITED] = baseMovesTable[k][l][SUITED]
                movesTable[i][j][k][l][UNSUITED] = baseMovesTable[k][l][UNSUITED]
            end
        end
    end
end

--[[
    Early R
--]]
--66-22
for i = Ranks.TWO.num,Ranks.SIX.num do
    movesTable[Position.EARLY][RaiseFactor.R][i][i][SUITED] = Moves.FOLD
    movesTable[Position.EARLY][RaiseFactor.R][i][i][UNSUITED] = Moves.FOLD
end
--AJs
movesTable[Position.EARLY][RaiseFactor.R][Ranks.ACE.num][Ranks.JACK.num][SUITED] = Moves.CALL
--ATs
movesTable[Position.EARLY][RaiseFactor.R][Ranks.ACE.num][Ranks.TEN.num][SUITED] = Moves.FOLD
--AJ
movesTable[Position.EARLY][RaiseFactor.R][Ranks.ACE.num][Ranks.JACK.num][UNSUITED] = Moves.FOLD
--A9s-A7s
for i = Ranks.SEVEN.num,Ranks.NINE.num do
    movesTable[Position.EARLY][RaiseFactor.R][Ranks.ACE.num][i][SUITED] = Moves.FOLD
end
--KJs
movesTable[Position.EARLY][RaiseFactor.R][Ranks.KING.num][Ranks.JACK.num][SUITED] = Moves.FOLD
--QJs
movesTable[Position.EARLY][RaiseFactor.R][Ranks.QUEEN.num][Ranks.JACK.num][SUITED] = Moves.FOLD

--[[
    Early RR
--]]
--initialize to 
for i = Ranks.TWO.num,Ranks.ACE.num do
    for j = Ranks.TWO.num,Ranks.ACE.num do
        movesTable[Position.EARLY][RaiseFactor.RR][i][j][SUITED] = movesTable[Position.EARLY][RaiseFactor.R][i][j][SUITED]
        movesTable[Position.EARLY][RaiseFactor.RR][i][j][UNSUITED] = movesTable[Position.EARLY][RaiseFactor.R][i][j][UNSUITED]
    end
end
--AQs,AQ
movesTable[Position.EARLY][RaiseFactor.RR][Ranks.ACE.num][Ranks.QUEEN.num][SUITED] = Moves.CALL
movesTable[Position.EARLY][RaiseFactor.RR][Ranks.ACE.num][Ranks.QUEEN.num][UNSUITED] = Moves.CALL
--KQs
movesTable[Position.EARLY][RaiseFactor.RR][Ranks.KING.num][Ranks.QUEEN.num][SUITED] = Moves.FOLD

--[[
    copy Early to Early2
--]]
movesTable[Position.EARLY2] = movesTable[Position.EARLY]

--[[
    Middle, R and RR are exactly the same as Early position
--]]
movesTable[Position.MIDDLE][RaiseFactor.R] = movesTable[Position.EARLY][RaiseFactor.R]
movesTable[Position.MIDDLE][RaiseFactor.RR] = movesTable[Position.EARLY][RaiseFactor.RR]

--[[
    Middle UR
--]]
--AT
movesTable[Position.MIDDLE][RaiseFactor.UR][Ranks.ACE.num][Ranks.QUEEN.num][UNSUITED] = Moves.CALL
--Axs
for i = Ranks.TWO.num,Ranks.ACE.num do
    movesTable[Position.MIDDLE][RaiseFactor.UR][Ranks.ACE.num][i][SUITED] = Moves.CALL
end
--KQ
movesTable[Position.MIDDLE][RaiseFactor.UR][Ranks.KING.num][Ranks.QUEEN.num][UNSUITED] = Moves.CALL
--KTs
movesTable[Position.MIDDLE][RaiseFactor.UR][Ranks.KING.num][Ranks.TEN.num][SUITED] = Moves.CALL
--QTs
movesTable[Position.MIDDLE][RaiseFactor.UR][Ranks.QUEEN.num][Ranks.TEN.num][SUITED] = Moves.CALL
--JTs
movesTable[Position.MIDDLE][RaiseFactor.UR][Ranks.JACK.num][Ranks.TEN.num][SUITED] = Moves.CALL
--J9s
movesTable[Position.MIDDLE][RaiseFactor.UR][Ranks.JACK.num][Ranks.NINE.num][SUITED] = Moves.CALL
--T9s
movesTable[Position.MIDDLE][RaiseFactor.UR][Ranks.TEN.num][Ranks.NINE.num][SUITED] = Moves.CALL
--98s
movesTable[Position.MIDDLE][RaiseFactor.UR][Ranks.NINE.num][Ranks.EIGHT.num][SUITED] = Moves.CALL

--[[
    Late UR
--]]
--initialize to Middle UR, very close
for i = Ranks.TWO.num,Ranks.ACE.num do
    for j = Ranks.TWO.num,Ranks.ACE.num do
        movesTable[Position.LATE][RaiseFactor.UR][i][j][SUITED] = movesTable[Position.MIDDLE][RaiseFactor.UR][i][j][SUITED]
        movesTable[Position.LATE][RaiseFactor.UR][i][j][UNSUITED] = movesTable[Position.MIDDLE][RaiseFactor.UR][i][j][UNSUITED]
    end
end
--JJ
movesTable[Position.LATE][RaiseFactor.UR][Ranks.JACK.num][Ranks.JACK.num][SUITED] = Moves.RAISE
movesTable[Position.LATE][RaiseFactor.UR][Ranks.JACK.num][Ranks.JACK.num][UNSUITED] = Moves.RAISE
--TT
movesTable[Position.LATE][RaiseFactor.UR][Ranks.TEN.num][Ranks.TEN.num][SUITED] = Moves.RAISE
movesTable[Position.LATE][RaiseFactor.UR][Ranks.TEN.num][Ranks.TEN.num][UNSUITED] = Moves.RAISE
--KQ-KT suited and unsuited
for i = Ranks.TEN.num,Ranks.QUEEN.num do
    movesTable[Position.LATE][RaiseFactor.UR][Ranks.KING.num][i][SUITED] = Moves.CALL
    movesTable[Position.LATE][RaiseFactor.UR][Ranks.KING.num][i][UNSUITED] = Moves.CALL
end
--all other Kxs
for i = Ranks.TWO.num,Ranks.NINE.num do
    movesTable[Position.LATE][RaiseFactor.UR][Ranks.KING.num][i][SUITED] = Moves.CALL
end
--QJ-QT suited and unsuited
for i = Ranks.TEN.num,Ranks.JACK.num do
    movesTable[Position.LATE][RaiseFactor.UR][Ranks.QUEEN.num][i][SUITED] = Moves.CALL
    movesTable[Position.LATE][RaiseFactor.UR][Ranks.QUEEN.num][i][UNSUITED] = Moves.CALL
end
--Q9s
movesTable[Position.LATE][RaiseFactor.UR][Ranks.QUEEN.num][Ranks.NINE.num][SUITED] = Moves.CALL
--JTs
movesTable[Position.LATE][RaiseFactor.UR][Ranks.JACK.num][Ranks.TEN.num][SUITED] = Moves.CALL
--T8s
movesTable[Position.LATE][RaiseFactor.UR][Ranks.TEN.num][Ranks.EIGHT.num][SUITED] = Moves.CALL

--[[
    Late R
--]]
--initialize to Middle R
for i = Ranks.TWO.num,Ranks.ACE.num do
    for j = Ranks.TWO.num,Ranks.ACE.num do
        movesTable[Position.LATE][RaiseFactor.R][i][j][SUITED] = movesTable[Position.MIDDLE][RaiseFactor.R][i][j][SUITED]
        movesTable[Position.LATE][RaiseFactor.R][i][j][UNSUITED] = movesTable[Position.MIDDLE][RaiseFactor.R][i][j][UNSUITED]
    end
end
--AJs
movesTable[Position.LATE][RaiseFactor.R][Ranks.ACE.num][Ranks.JACK.num][SUITED] = Moves.RAISE
--QJs
movesTable[Position.LATE][RaiseFactor.R][Ranks.QUEEN.num][Ranks.JACK.num][SUITED] = Moves.CALL

--[[
    Late RR
--]]
--initialize to Middle RR
for i = Ranks.TWO.num,Ranks.ACE.num do
    for j = Ranks.TWO.num,Ranks.ACE.num do
        movesTable[Position.LATE][RaiseFactor.RR][i][j][SUITED] = movesTable[Position.MIDDLE][RaiseFactor.RR][i][j][SUITED]
        movesTable[Position.LATE][RaiseFactor.RR][i][j][UNSUITED] = movesTable[Position.MIDDLE][RaiseFactor.RR][i][j][UNSUITED]
    end
end
--TT
movesTable[Position.LATE][RaiseFactor.RR][Ranks.TEN.num][Ranks.TEN.num][SUITED] = Moves.CALL
movesTable[Position.LATE][RaiseFactor.RR][Ranks.TEN.num][Ranks.TEN.num][UNSUITED] = Moves.CALL
--KQs
movesTable[Position.LATE][RaiseFactor.RR][Ranks.KING.num][Ranks.QUEEN.num][SUITED] = Moves.CALL

--[[
    Small Blind UR
--]]
--initialize to Late UR
for i = Ranks.TWO.num,Ranks.ACE.num do
    for j = Ranks.TWO.num,Ranks.ACE.num do
        movesTable[Position.SMALL_BLIND][RaiseFactor.UR][i][j][SUITED] = movesTable[Position.LATE][RaiseFactor.UR][i][j][SUITED]
        movesTable[Position.SMALL_BLIND][RaiseFactor.UR][i][j][UNSUITED] = movesTable[Position.LATE][RaiseFactor.UR][i][j][UNSUITED]
    end
end
--some redundancy here, but saves from explicit insertion
--Ax and Axs
for i = Ranks.TWO.num,Ranks.ACE.num do
    movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.ACE.num][i][SUITED] = Moves.CALL
    movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.ACE.num][i][UNSUITED] = Moves.CALL
end
--Qxs
for i = Ranks.TWO.num,Ranks.ACE.num do
    movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.QUEEN.num][i][SUITED] = Moves.CALL
end
--J8s
movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.JACK.num][Ranks.EIGHT.num][SUITED] = Moves.CALL
--J7s
movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.JACK.num][Ranks.SEVEN.num][SUITED] = Moves.CALL
--T7s
movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.TEN.num][Ranks.SEVEN.num][SUITED] = Moves.CALL
--98
movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.NINE.num][Ranks.EIGHT.num][UNSUITED] = Moves.CALL
--97s
movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.NINE.num][Ranks.SEVEN.num][SUITED] = Moves.CALL
--87s, 87
movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.EIGHT.num][Ranks.SEVEN.num][SUITED] = Moves.CALL
movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.EIGHT.num][Ranks.SEVEN.num][UNSUITED] = Moves.CALL
--76s, 76, 75s, 75
for i = Ranks.FIVE.num, Ranks.SIX.num do
    movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.SEVEN.num][i][SUITED] = Moves.CALL
    movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.SEVEN.num][i][UNSUITED] = Moves.CALL
end
--65s, 65
movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.SIX.num][Ranks.FIVE.num][SUITED] = Moves.CALL
movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.SIX.num][Ranks.FIVE.num][UNSUITED] = Moves.CALL
--64s
movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.SIX.num][Ranks.FOUR.num][SUITED] = Moves.CALL
--54s
movesTable[Position.SMALL_BLIND][RaiseFactor.UR][Ranks.FIVE.num][Ranks.FOUR.num][SUITED] = Moves.CALL

--[[
    Small Blind R
--]]
--initialize to Late R
for i = Ranks.TWO.num,Ranks.ACE.num do
    for j = Ranks.TWO.num,Ranks.ACE.num do
        movesTable[Position.SMALL_BLIND][RaiseFactor.R][i][j][SUITED] = movesTable[Position.LATE][RaiseFactor.R][i][j][SUITED]
        movesTable[Position.SMALL_BLIND][RaiseFactor.R][i][j][UNSUITED] = movesTable[Position.LATE][RaiseFactor.R][i][j][UNSUITED]
    end
end
--66-22
for i = Ranks.TWO.num,Ranks.SIX.num do
    movesTable[Position.SMALL_BLIND][RaiseFactor.R][i][i][SUITED] = Moves.CALL
    movesTable[Position.SMALL_BLIND][RaiseFactor.R][i][i][UNSUITED] = Moves.CALL
end
--ATs
movesTable[Position.SMALL_BLIND][RaiseFactor.R][Ranks.ACE.num][Ranks.TEN.num][SUITED] = Moves.CALL
--KJs
movesTable[Position.SMALL_BLIND][RaiseFactor.R][Ranks.KING.num][Ranks.JACK.num][SUITED] = Moves.CALL

--[[
    Small Blind RR
--]]
--initialize to Late RR
for i = Ranks.TWO.num,Ranks.ACE.num do
    for j = Ranks.TWO.num,Ranks.ACE.num do
        movesTable[Position.SMALL_BLIND][RaiseFactor.RR][i][j][SUITED] = movesTable[Position.LATE][RaiseFactor.RR][i][j][SUITED]
        movesTable[Position.SMALL_BLIND][RaiseFactor.RR][i][j][UNSUITED] = movesTable[Position.LATE][RaiseFactor.RR][i][j][UNSUITED]
    end
end
--ATs
movesTable[Position.SMALL_BLIND][RaiseFactor.RR][Ranks.ACE.num][Ranks.TEN.num][SUITED] = Moves.CALL

--[[
    Big Blind UR
--]]
--instantiate to Small Blind UR
for i = Ranks.TWO.num,Ranks.ACE.num do
    for j = Ranks.TWO.num,Ranks.ACE.num do
        movesTable[Position.BIG_BLIND][RaiseFactor.UR][i][j][SUITED] = movesTable[Position.SMALL_BLIND][RaiseFactor.UR][i][j][SUITED]
        movesTable[Position.BIG_BLIND][RaiseFactor.UR][i][j][UNSUITED] = movesTable[Position.SMALL_BLIND][RaiseFactor.UR][i][j][UNSUITED]
    end
end
--call/check on all low hands as well (up to KAs so less redundancy in assignment)
for i = Ranks.TWO.num,Ranks.KING.num do
    for j = Ranks.TWO.num,Ranks.ACE.num do
        movesTable[Position.BIG_BLIND][RaiseFactor.UR][i][j][SUITED] = Moves.CALL
        movesTable[Position.BIG_BLIND][RaiseFactor.UR][i][j][UNSUITED] = Moves.CALL
    end
end

--[[
    Big Blind R
--]]
--instantiate to Late UR
for i = Ranks.TWO.num,Ranks.ACE.num do
    for j = Ranks.TWO.num,Ranks.ACE.num do
        movesTable[Position.BIG_BLIND][RaiseFactor.R][i][j][SUITED] = movesTable[Position.LATE][RaiseFactor.UR][i][j][SUITED]
        movesTable[Position.BIG_BLIND][RaiseFactor.R][i][j][UNSUITED] = movesTable[Position.LATE][RaiseFactor.UR][i][j][UNSUITED]
    end
end

--Qxs
for i = Ranks.TWO.num,Ranks.JACK.num do
    movesTable[Position.BIG_BLIND][RaiseFactor.R][Ranks.QUEEN.num][i][SUITED] = Moves.CALL
end
--J8s
movesTable[Position.BIG_BLIND][RaiseFactor.R][Ranks.JACK.num][Ranks.EIGHT.num][SUITED] = Moves.CALL
--J7s
movesTable[Position.BIG_BLIND][RaiseFactor.R][Ranks.JACK.num][Ranks.SEVEN.num][SUITED] = Moves.CALL
--98
movesTable[Position.BIG_BLIND][RaiseFactor.R][Ranks.NINE.num][Ranks.EIGHT.num][UNSUITED] = Moves.CALL

--[[
    Big Blind RR
--]]
--Same as Small Blind RR, shallow copy since this wont change
movesTable[Position.BIG_BLIND][RaiseFactor.RR] = movesTable[Position.SMALL_BLIND][RaiseFactor.RR]

preFlopLUT = movesTable
