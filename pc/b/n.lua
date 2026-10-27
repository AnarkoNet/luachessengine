local u = require("util")

local bn = {}

function bn.GETMOVES(board,pos,lastmove)
    local moves={}
    local offsets={
        {y=-2,x=-1},
        {y=-2,x= 1},
        {y=-1,x=-2},
        {y=-1,x= 2},
        {y= 1,x=-2},
        {y= 1,x= 2},
        {y= 2,x=-1},
        {y= 2,x= 1}
    }
    for _, offset in ipairs(offsets) do
        local y=pos.y+offset.y
        local x=pos.x+offset.x
        local target=u.gi(board,y,x)
        if target ~= nil then
            if u.cc(target) ~= -1 then
                moves[#moves+1]={p=pos,y=y,x=x}
            end
        end
    end
    return moves
end

function bn.MOVE(board,pos,lastmove,mov)
    board[mov.y][mov.x]="n"
    board[pos.y][pos.x]="0"
    lastmove={pc="n",a=pos,b=mov}
    return {B=board,LM=lastmove}
end

bn.ART = {"  ▄▄▄ "," ▀▀██ ","  ▀▀▀ "}

return bn