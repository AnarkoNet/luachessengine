local u = require("util")

local BLANK = require("pc.blank")

local PC = {
    P=require("pc.w.p"),
    p=require("pc.b.p"),
    R=require("pc.w.r"),
    r=require("pc.b.r"),
    N=require("pc.w.n"),
    n=require("pc.b.n"),
    B=require("pc.w.b"),
    b=require("pc.b.b"),
    Q=require("pc.w.q"),
    q=require("pc.b.q"),
    K=require("pc.w.k"),
    k=require("pc.b.k"),
    O=require("pc.w.o"),
    o=require("pc.b.o")
}

-- uppercase = White, lowercase = Black, 0 = Blank
local START = {
    {"r","n","b","q","k","b","n","r"},
    {"p","p","p","p","p","p","p","p"},
    {"0","0","0","0","0","0","0","0"},
    {"0","0","0","0","0","0","0","0"},
    {"0","0","0","0","0","0","0","0"},
    {"0","0","0","0","0","0","0","0"},
    {"P","P","P","P","P","P","P","P"},
    {"R","N","B","Q","K","B","N","R"}
}

local function randy(board,lastmove)
    local moves={}
    for Y=1,8 do
        for X=1,8 do
            if u.cc(u.gi(board,Y,X))==-1 then
                moves=u.jt(moves,PC[board[Y][X]].GETMOVES(board,{y=Y,x=X},lastmove))
            end
        end
    end
    if #moves>0 then
        local move=moves[math.random(#moves)]
        return PC[board[move.p.y][move.p.x]].MOVE(board,move.p,lastmove,{y=move.y,x=move.x})
    else
        return BLANK.MOVE(board,nil,lastmove,nil)
    end
end

local function render(board,selpos,hovpos,moves)
    local bgb="42" -- Black square background
    local bgw="43" -- White square background
    local pcb="30" -- Black piece foreground
    local pcw="1"  -- White piece foreground
    local sel="104"-- Selection highlight
    local hov="46" -- Hover highlight
    local mvb="45" -- Possible move black highlight
    local mvw="105"-- Possible move white highlight

    local out={}
    local dbg=""
    for Y=1,8 do
        local row={}
        for y=1,3 do
            local line=""
            for X=1,8 do
                local piece=board[Y][X]
                local bg=((X+Y)%2==0) and bgw or bgb
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
                    bg=hov
                end
                line=line.."\27["..bg.."m"
                if u.cc(piece)==1 then -- uppercase = white
                    line=line.."\27["..pcw.."m"
                elseif u.cc(piece)==-1 then
                    line=line.."\27["..pcb.."m"
                end

                -- Draw piece or empty square
                if piece~="0" then
                    line=line..PC[piece].ART[y].."\27[0m"
                else
                    line=line.."      "
                end
            end
            line=line.."\27[0m"
            row[#row+1]=line
        end
        out[#out+1]=table.concat(row,"\n")
    end
    return table.concat(out,"\n").."\n"..dbg
end

local board=START
local hover={y=8,x=1}
local selpos=nil
local lastmove={pc=""}
local moves={}
local turn=1
local gamemode="randy"
local k=""
while k~="Q" do
    print(render(board,selpos,hover,moves))
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
                if gamemode~="2p" then
                    if gamemode=="randy" then
                        local runit=randy(board,lastmove)
                        board=runit.B
                        lastmove=runit.LM
                    end
                else
                    turn = -1
                end
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