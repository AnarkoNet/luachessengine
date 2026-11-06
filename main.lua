local gamemode = "procedy" -- 2p randy procedy stockfish(notworking)

local u = require("util")

local BLANK = require("pc.blank")

local engine = require("engine")

local utf8 = require("lua-utf8")
local socket = require("socket")

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

math.randomseed()

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
        --socket.sleep(1)
        local move=moves[math.random(#moves)]
        return PC[board[move.p.y][move.p.x]].MOVE(board,move.p,lastmove,{y=move.y,x=move.x})
    else
        return BLANK.MOVE(board,nil,lastmove,nil)
    end
end

local function procedy(board,lastmove,history) -- written by ChatGPT
    local moves={}
    local values={
        P=100,p=100,
        N=320,n=320,
        B=330,b=330,
        R=500,r=500,
        Q=900,q=900,
        K=20000,k=20000,
        O=350,o=350
    }

    -- Gather Black's available moves
    for Y=1,8 do
        for X=1,8 do
            if u.cc(u.gi(board,Y,X))==-1 then
                moves=u.jt(moves,PC[board[Y][X]].GETMOVES(board,{y=Y,x=X},lastmove))
            end
        end
    end

    if #moves==0 then
        return BLANK.MOVE(board,nil,lastmove,nil)
    end

    -- Gather squares controlled by White
    local threats={}
    for Y=1,8 do
        for X=1,8 do
            if u.cc(u.gi(board,Y,X))==1 then
                local wm=PC[board[Y][X]].GETMOVES(board,{y=Y,x=X},lastmove)
                for _,m in ipairs(wm) do
                    threats[m.y..","..m.x]=true
                end
            end
        end
    end

    local scored={}
    local highest=-math.huge

    for _,m in ipairs(moves) do
        local from=m.p
        local to={y=m.y,x=m.x}
        local piece=board[from.y][from.x]
        local target=board[to.y][to.x]
        local score=math.random()*8

        -- Captures
        if target~="0" then
            score=score+(values[target] or 0)*1.2
        end

        -- Avoid landing on controlled squares
        if threats[to.y..","..to.x] then
            score=score-(values[piece] or 100)*0.8
        end

        -- Center control
        local center=math.abs(4.5-to.x)+math.abs(4.5-to.y)
        score=score+(8-center)*5

        -- Pawn advancement
        if piece=="p" then
            score=score+(to.y-from.y)*8
        end

        -- Develop knights and bishops
        if piece=="n" or piece=="b" then
            if from.y==1 and to.y~=1 then
                score=score+35
            end
        end

        -- Promotion
        if piece=="p" and to.y==8 then
            score=score+900
        end

        -- Discourage repeating the same move
        local notation=u.coord(from)..u.coord(to)
        for i=math.max(1,#history-5),#history do
            if history[i]==notation then
                score=score-40
            end
        end

        scored[#scored+1]={move=m,score=score}

        if score>highest then
            highest=score
        end
    end

    -- Randomly choose between the best-scoring moves
    local best={}
    for _,s in ipairs(scored) do
        if s.score>=highest-12 then
            best[#best+1]=s.move
        end
    end

    socket.sleep(1)
    local move=best[math.random(#best)]

    return PC[board[move.p.y][move.p.x]].MOVE(
        board,move.p,lastmove,{y=move.y,x=move.x}
    )
end

local function fishy(board,lastmove,history)
    local position = "position startpos moves "..table.concat(history," ")
    local bestmove = engine.BESTMOVE(position,8)
    return PC[board[bestmove.pos.y][bestmove.pos.x]].MOVE(board,bestmove.pos,lastmove,bestmove.mov)
end

local function render(board,selpos,hovpos,moves,hist)
    local bgb="42" -- Black square background
    local bgw="43" -- White square background
    local pcb="30" -- Black piece foreground
    local pcw="97"  -- White piece foreground
    local sel="104"-- Selection highlight
    local hov="46" -- Hover highlight
    local mvb="45" -- Possible move black highlight
    local mvw="105"-- Possible move white highlight
    local xyw="30" -- Coordinate color on white
    local xyb="97" -- Coordinate color on black

    local out={}
    for Y=1,8 do
        local row={}
        for y=1,3 do
            local line=""
            for X=1,8 do
                local piece=board[Y][X]
                local bg=((X+Y)%2==0) and bgw or bgb
                local xy=((X+Y)%2==0) and xyw or xyb
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
                local lineart="      "
                if piece~="0" then
                    lineart=PC[piece].ART[y]
                end
                if Y==1 and y==1 then
                    lineart="\27["..xy.."m"..utf8.sub("abcdefgh",X,X).."\27["..(u.cc(piece)==1 and pcw or pcb).."m"..utf8.sub(lineart,2,6)
                elseif X==8 and y==3 then
                    lineart=utf8.sub(lineart,1,5).."\27["..xy.."m"..tostring(9-Y)
                end
                line=line..lineart
            end
            line=line.."\27[0m"
            row[#row+1]=line.." "..(hist[#hist-(((Y-1)*3)+(y-1))] or "")
        end
        out[#out+1]=table.concat(row,"\n")
    end
    return table.concat(out,"\n")
end

local board=START
local hover={y=8,x=1}
local selpos=nil
local lastmove={pc=""}
local moves={}
local turn=1

local white_king_exists = true
local black_king_exists = true

gamemode = arg[1] or gamemode

if gamemode=="stockfish" then
engine.START("./stockfish")
end

local history={}
local k=""
while k~="Q" do
    print("\n\n"..render(board,selpos,hover,moves,history))
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
            local pp=runit.pp or ""
            history[#history+1]=(u.coord(selpos)..u.coord(hover)..pp)
            board=runit.B
            lastmove=runit.LM
            selpos=nil
            moves={}
            print("\n\n"..render(board,selpos,hover,moves,history))
            if turn==1 then
                if gamemode~="2p" then
                    if gamemode=="randy" then
                        runit=randy(board,lastmove)
                    elseif gamemode=="stockfish" then
                        runit=fishy(board,lastmove,history)
                    elseif gamemode=="procedy" then
                        runit=procedy(board,lastmove,history)
                    end
                    board=runit.B
                    lastmove=runit.LM
                    pp=runit.pp or ""
                    history[#history+1]=(u.coord(lastmove.a)..u.coord(lastmove.b)..pp)
                    print("\n\n"..render(board,selpos,hover,moves,history))
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
    white_king_exists, black_king_exists = false, false
    for Y=1,8 do
        for X=1,8 do
            if board[Y][X]=="k" then
                black_king_exists = true
            elseif board[Y][X]=="K" then
                white_king_exists = true
            end
        end
    end
    if (not white_king_exists) or (not black_king_exists) then
        if black_king_exists then
            print("\n\27[31mYOU LOST\27[0m\n")
        else
            print("\n\27[32mYOU WON\27[0m\n")
        end
        k="Q"
    end
end
if gamemode=="stockfish" then
engine.STOP()
end
