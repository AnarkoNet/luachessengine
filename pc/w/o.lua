local u = require("util")

local wo = {}

function wo.GETMOVES(board,pos,lastmove)
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
        local found=false
        while u.gi(board,y,x)~=nil do
            local target=u.gi(board,y,x)
            if target=="0" then
                if found then
                    moves[#moves+1]={p=pos,y=y,x=x}
                end
                break
            elseif u.cc(target)==-1 then
                found=true
            else
                break
            end
            y=y+dir.y
            x=x+dir.x
        end
    end
    return moves
end

function wo.MOVE(board,pos,lastmove,mov)
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
    board[mov.y][mov.x]="O"
    for _,dir in ipairs(dirs) do
        local y=mov.y+dir.y
        local x=mov.x+dir.x
        local flips={}
        while u.gi(board,y,x) ~= nil and u.cc(u.gi(board,y,x)) == -1 do
            flips[#flips+1]={y=y,x=x}
            y=y+dir.y
            x=x+dir.x
        end
        if #flips>0 and u.gi(board,y,x)=="O" then
            for _,sq in ipairs(flips) do
                board[sq.y][sq.x]=string.upper(board[sq.y][sq.x])
            end
        end
    end
    board[pos.y][pos.x]="0"
    lastmove={pc="O",a=pos,b=mov}
    return {B=board,LM=lastmove}
end

wo.ART={"  ▄▄  "," ████ ","  ▀▀  "}

return wo