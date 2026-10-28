local u = require("util")

local wk = {}

function wk.GETMOVES(board,pos,lastmove)
    local moves={}
    local dirs={
        {y=-1,x=-1},
        {y=-1,x= 0},
        {y=-1,x= 1},
        {y= 0,x=-1},
        {y= 0,x= 1},
        {y= 1,x=-1},
        {y= 1,x= 0},
        {y= 1,x= 1}
    }
    for _,dir in ipairs(dirs) do
        local y=pos.y+dir.y
        local x=pos.x+dir.x
        local target=u.gi(board,y,x)

        if target ~= nil and u.cc(target) ~= 1 then
            moves[#moves+1]={p=pos,y=y,x=x}
        end
    end
    if pos.y==8 and pos.x==5 then -- Castling
        -- Kingside castling
        if u.gi(board,8,8)=="R"
        and u.gi(board,8,6)=="0"
        and u.gi(board,8,7)=="0" then
            moves[#moves+1]={p=pos,y=8,x=7}
        end
        -- Queenside castling
        if u.gi(board,8,1)=="R"
        and u.gi(board,8,2)=="0"
        and u.gi(board,8,3)=="0"
        and u.gi(board,8,4)=="0" then
            moves[#moves+1]={p=pos,y=8,x=3}
        end
    end
    return moves
end

function wk.MOVE(board,pos,lastmove,mov)
    -- Castling
    if pos.y==8 and pos.x==5 and math.abs(mov.x-pos.x)==2 then
        if mov.x==7 then
            board[8][6]="R"
            board[8][8]="0"
        elseif mov.x==3 then
            board[8][4]="R"
            board[8][1]="0"
        end
    end
    board[mov.y][mov.x]="K"
    board[pos.y][pos.x]="0"
    lastmove={pc="K",a=pos,b=mov}
    return {B=board,LM=lastmove}
end

wk.ART={" ▄▄▄▄ "," ▀██▀ ","  ▀▀  "}

return wk