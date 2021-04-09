
function Execute(game, process)

    local map = game:GetMap(mapIndex);
    local playerId = process.trigger.id;

    local canMove, res = CanMove(map, origin, dest, playerId);
    if canMove then
        unit, destUnit = ChessMove(map, origin, dest);

        print(res);
    else
        error(res);
    end

end

function Undo(game)

    print("Undoing");
    local map = game:GetMap(mapIndex);

    UndoChessMove(map, origin, dest, destUnit);

end