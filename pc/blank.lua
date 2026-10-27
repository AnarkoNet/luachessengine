local blank = {}
function blank.GETMOVES(board,pos,lastmove)
    return{}
end
function blank.MOVE(board,pos,lastmove,mov)
    return{B=board,LM=lastmove}
end
return blank