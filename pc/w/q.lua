local u = require("util")

local wq = {}

function wq.GETMOVES(board,pos,lastmove)
    local moves={}
    local dirs={
        {y=-1,x= 0},
        {y= 1,x= 0},
        {y= 0,x=-1},
        {y= 0,x= 1},
        {y=-1,x=-1},
        {y=-1,x= 1},
        {y= 1,x=-1},
        {y= 1,x= 1}
    }
    for _,dir in ipairs(dirs) do
        local y=pos.y+dir.y
        local x=pos.x+dir.x
        while true do
            local target=u.gi(board,y,x)
            if target==nil then
                break
            end
            if target=="0" then
                moves[#moves+1]={p=pos,y=y,x=x}
            else
                if u.cc(target) ~= 1 then
                    moves[#moves+1]={p=pos,y=y,x=x}
                end
                break
            end
            y=y+dir.y
            x=x+dir.x
        end
    end
    return moves
end

function wq.MOVE(board,pos,lastmove,mov)
    board[mov.y][mov.x]="Q"
    board[pos.y][pos.x]="0"
    lastmove={pc="Q",a=pos,b=mov}
    return {B=board,LM=lastmove}
end

wq.ART={" ▄  ▄ "," ▀██▀ "," ▀▀▀▀ "}

return wq