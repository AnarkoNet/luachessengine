local u = require("util")

local bk = {}

function bk.GETMOVES(board,pos,lastmove)
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

        if target ~= nil and u.cc(target) ~= -1 then
            moves[#moves+1]={p=pos,y=y,x=x}
        end
    end
    if pos.y==1 and pos.x==5 then -- Castling
        -- Kingside castling
        if u.gi(board,1,8)=="r"
        and u.gi(board,1,6)=="0"
        and u.gi(board,1,7)=="0" then
            moves[#moves+1]={p=pos,y=1,x=7}
        end
        -- Queenside castling
        if u.gi(board,1,1)=="r"
        and u.gi(board,1,2)=="0"
        and u.gi(board,1,3)=="0"
        and u.gi(board,1,4)=="0" then
            moves[#moves+1]={p=pos,y=1,x=3}
        end
    end
    return moves
end

function bk.MOVE(board,pos,lastmove,mov)
    -- Castling
    if pos.y==1 and pos.x==5 and math.abs(mov.x-pos.x)==2 then
        if mov.x==7 then
            board[1][6]="r"
            board[1][8]="0"
        elseif mov.x==3 then
            board[1][4]="r"
            board[1][1]="0"
        end
    end
    board[mov.y][mov.x]="k"
    board[pos.y][pos.x]="0"
    lastmove={pc="k",a=pos,b=mov}
    return {B=board,LM=lastmove}
end

bk.ART={" ▄▄▄▄ "," ▀██▀ ","  ▀▀  "}

return bk