local u = require("util")

local wp = {}

function wp.GETMOVES(board,pos,lastmove)
    local moves = {}
    if u.gi(board,pos.y-1,pos.x)=="0" then -- move up
        moves[#moves+1]={p=pos,y=pos.y-1,x=pos.x}
        if pos.y==7 and u.gi(board,pos.y-2,pos.x)=="0" then -- move far up
            moves[#moves+1]={p=pos,y=pos.y-2,x=pos.x}
        end
    end
    if u.cc(u.gi(board,pos.y-1,pos.x-1))==-1 then -- capture left
        moves[#moves+1]={p=pos,y=pos.y-1,x=pos.x-1}
    end
    if u.cc(u.gi(board,pos.y-1,pos.x+1))==-1 then -- capture right
        moves[#moves+1]={p=pos,y=pos.y-1,x=pos.x+1}
    end
    if lastmove.pc=="p" then -- en passant
        if (lastmove.b.y-lastmove.a.y)==2 then
            if lastmove.b.y==pos.y then
                if math.abs(lastmove.b.x-pos.x)==1 then
                    moves[#moves+1]={p=pos,y=lastmove.b.y-1,x=lastmove.b.x}
                end
            end
        end
    end
    return moves
end

function wp.MOVE(board, pos, lastmove, mov)
    if mov.x ~= pos.x and u.gi(board,mov.y,mov.x)=="0" then
        board[pos.y][mov.x]="0" -- en passant
    end
    if mov.y==1 then
        board[mov.y][mov.x]=string.upper(u.promo())
    else
        board[mov.y][mov.x]="P"
    end
    board[pos.y][pos.x]="0"
    lastmove={pc="P",a=pos,b={y=mov.y,x=mov.x}}
    return {B=board,LM=lastmove}
end

wp.ART = {"      ", "  ██  ", " ▀▀▀▀ "}

return wp