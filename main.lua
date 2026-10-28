local u = require("util")

-- local BLANK = require("pc.blank")

local PC = {
    P = require("pc.w.p"),
    p = require("pc.b.p"),
    R = require("pc.w.r"),
    r = require("pc.b.r"),
    N = require("pc.w.n"),
    n = require("pc.b.n"),
    B = require("pc.w.b"),
    b = require("pc.b.b"),
    Q = require("pc.w.q"),
    q = require("pc.b.q"),
    K = require("pc.w.k"),
    k = require("pc.b.k"),
    O = require("pc.w.o"),
    o = require("pc.b.o")
}

-- uppercase = White, lowercase = Black, 0 = Blank
local START = {
    {"r","n","b","q","k","b","n","r"},
    {"p","p","p","p","p","p","p","p"},
    {"0","0","0","0","0","0","0","0"},
    {"0","0","0","o","O","0","0","0"},
    {"0","0","0","O","o","0","0","0"},
    {"0","0","0","0","0","0","0","0"},
    {"P","P","P","P","P","P","P","P"},
    {"R","N","B","Q","K","B","N","R"}
}

local function render(board,selpos,hovpos,lastmove,moves)
    local bgb = "42" -- Black square background
    local bgw = "43" -- White square background
    local pcb = "30" -- Black piece foreground
    local pcw = "1"  -- White piece foreground
    local sel = "104"-- Selection highlight
    local hov = "46" -- Hover highlight
    local mvb = "45" -- Possible move black highlight
    local mvw = "105"-- Possible move white highlight

    local out = {}
    local dbg = ""
    dbg=u.ct(moves)
    for Y = 1, 8 do
        local row = {}
        for y = 1, 3 do
            local line = ""
            for X = 1, 8 do
                local piece = board[Y][X]
                local bg = ((X + Y) % 2 == 0) and bgw or bgb
                if selpos then
                    if selpos.x==X and selpos.y==Y then
                        bg = sel
                    elseif u.pi({y=Y,x=X},moves) then
                        if bg==bgw then
                            bg=mvw
                        else
                            bg=mvb
                        end
                    end
                end
                if hovpos.x==X and hovpos.y==Y then
                    bg = hov
                end
                line = line .. "\27[" .. bg .. "m"
                if u.cc(piece)==1 then -- uppercase = white
                    line = line .. "\27[" .. pcw .. "m"
                elseif u.cc(piece)==-1 then
                    line = line .. "\27[" .. pcb .. "m"
                end

                -- Draw piece or empty square
                if piece ~= "0" then
                    line = line .. PC[piece].ART[y] .. "\27[0m"
                else
                    line = line .. "      "
                end
            end
            line = line .. "\27[0m"
            row[#row+1]=line
        end
        out[#out + 1] = table.concat(row, "\n")
    end
    return table.concat(out, "\n").."\n"..dbg
end

local board = START
local hover = {y=8,x=1}
local selpos = nil
local lastmove = {pc=""}
local moves = {}
local turn = 1
local k=""
while k~="Q" do
    print(render(board,selpos,hover,lastmove,moves))
    k=u.getch()
    if k=="w" and hover.y>1 then
        hover.y=hover.y-1
    elseif k=="s" and hover.y<8 then
        hover.y=hover.y+1
    elseif k=="a" and hover.x>1 then
        hover.x=hover.x-1
    elseif k=="d" and hover.x<8 then
        hover.x=hover.x+1
    elseif k==" " then
        if selpos and u.pi(hover,moves) then
            local runit=PC[board[selpos.y][selpos.x]].MOVE(board,selpos,lastmove,hover)
            board=runit.B
            lastmove=runit.LM
            selpos = nil
            moves={}
            if turn == 1 then
                turn = -1
            else
                turn = 1
            end
        elseif u.cc(u.gi(board,hover.y,hover.x))==turn then
            if selpos then
                selpos = nil
                moves={}
            else
                selpos={y=hover.y,x=hover.x}
                moves=PC[board[selpos.y][selpos.x]].GETMOVES(board,selpos,lastmove)
            end
        end
    end
end