
local function isKing(unit)
    return unit:GetGUID() == WhiteKing:GetGUID() or unit:GetGUID() == BlackKing:GetGUID();
end

function CanMove(map, origin, dest, playerId)

    local unit = map:GetUnit(origin);

    if unit then
        local owner = unit:GetOwner();
        if owner:GetId() == playerId then
            if origin ~= dest then

                local destUnit = map:GetUnit(dest);
                local canAttack = false;
                if destUnit then
                    local destOwner = destUnit:GetOwner();
                    if destOwner:GetId() ~= owner:GetId() then
                        local attack = unit:CalculateAttack(0, map, origin);
                        canAttack = attack:CanAttack(dest);
                        if canAttack then
                            map:RemoveUnit(dest)
                        end
                    else
                        return false, "Cannot capture a friendly unit";
                    end
                end
                
                local movement = unit:CalculateMovement(map, origin);
                if canAttack and destUnit then
                    map:AddUnit(dest, destUnit);
                end

                if movement:CanMove(dest) then
                    return true, "Unit moved successfully from "..tostring(origin).." to "..tostring(dest);
                else
                    return false, "Unit cannot move to that location";
                end

            else
                return false, "Origin and destination are the same position";
            end
        else
            return false, "Unit at "..tostring(origin).." doesn't belong to player "..playerId;
        end
    end

    return false, "Unit not found";
end

function ChessMove(map, origin, dest)
    local unit = map:GetUnit(origin); 

    local destUnit = map:GetUnit(dest);
    if destUnit then
        map:RemoveUnit(dest);
    end

    map:RemoveUnit(origin);
    map:AddUnit(dest, unit);

    return unit, destUnit;
end

function  UndoChessMove(map, origin, dest, destUnit)
    local unit = map:GetUnit(dest); 

    map:RemoveUnit(dest);
    map:AddUnit(origin, unit);
    
    if destUnit then
        map:AddUnit(dest, destUnit)
    end
end

function HasAlreadyMoved(guid)

    local hasMoved = false;
    for i = 1, game:GetHistoryIndex() do
        local p = game:GetHistoryProcess(i);
        if p.trigger.type == Trigger.Type.PLAYER then
            local args = p.operation:GetArgs();
            if args.type == "move" then
                local unitGUID = args.unit:GetGUID()
                if unitGUID == guid then
                    hasMoved = true;
                    break;
                end
            elseif args.type == "castle" then
                if guid == args.rook:GetGUID() or guid == args.king:GetGUID() then
                    hasMoved = true;
                    break;
                end
            end
        end
    end

    return hasMoved;
end

function IsPosOnCheckByUnit(targetPos, attackerPos)
    local map = game:GetMap(0);

    if attackerPos then
        local attacker = map:GetUnit(attackerPos);
        local attackerOwner = attacker:GetOwner();

        local canMove, res = CanMove(map, attackerPos, targetPos, attackerOwner:GetId());
        if canMove then
            return true;
        end
    end
    
    return false;
end

function IsPosOnCheckByPlayer(targetPos, attackerPlayerId)

    local map = game:GetMap(0);
    local units = GetPlayerUnits(map, attackerPlayerId);
    for pos, unit  in pairs(units) do
        local ownerId = unit:GetOwner():GetId();
        if ownerId == attackerPlayerId then
            if IsPosOnCheckByUnit(targetPos, pos) then
                return true, pos;
            end
        end

    end

    return false;
end

function OnChessCheck(event, guid)
    
    local trigger = event.process.trigger;
    local args = event.process.operation:GetArgs();
    if trigger.type == Trigger.Type.PLAYER then
        if args.type == "move" then

            local map = game:GetMap(0);
            if map:IsPosValid(args.origin) and map:IsPosValid(args.dest) then

                local unit = map:GetUnit(args.origin);
                if unit then
                    
                    local _, destUnit = ChessMove(map, args.origin, args.dest);

                    local playerId = trigger.id;
                    local king = playerId == 0 and WhiteKing or BlackKing;
                    local kingPos = game:GetUnitPos(king:GetGUID()).pos;
                    
                    -- Check
                    local isOnCheck, attackerPos = IsPosOnCheckByPlayer(kingPos, playerId)
                    if isOnCheck then
                        print("Unit at "..tostring(attackerPos).." is checking unit at pos "..tostring(kingPos));
                        print("Cannot perform a move that would leave your king on check!");
                        game:CancelProcess(event.process);
                    end

                    -- Reapply state after check
                    UndoChessMove(map, args.origin, args.dest, destUnit);
                end
            end
        end
    end
end

function GetPlayerUnits(map, playerId)

    local units = {}
    local mapSize = map:GetSize();
    for x = 0, mapSize.x -1 do
        for y = 0, mapSize.y - 1 do
            local pos = Vector2.new(x, y);
            local unit = map:GetUnit(pos);
            if unit and unit:GetOwner():GetId() == playerId then
                units[pos] = unit;
            end
        end
    end

    return units
end

function IsGameOver(playerId, opponentId)

    local enemyKing = opponentId == 0 and WhiteKing or BlackKing;
    local enemyKingPos = game:GetUnitPos(enemyKing:GetGUID()).pos;
    
    -- Current State check
    if IsPosOnCheckByPlayer(enemyKingPos, playerId) then
        print("CHECK");

        local map = game:GetMap(0);
        local mapSize = map:GetSize();

        -- Possible states check
        local units = GetPlayerUnits(map, opponentId);
        for pos, unit  in pairs(units) do
            for x = 0, mapSize.x -1 do
                for y = 0, mapSize.y - 1 do
                    local dest = Vector2.new(x, y);
                    if CanMove(map, pos, dest, opponentId) then
                        local _, destUnit = ChessMove(map, pos, dest);
                        enemyKingPos = game:GetUnitPos(enemyKing:GetGUID()).pos;
                        local isOnCheck = IsPosOnCheckByPlayer(enemyKingPos, playerId);
                        UndoChessMove(map, pos, dest, destUnit);

                        if not isOnCheck then
                            print("If unit at "..tostring(pos).." moves to "..tostring(dest).." check is avoided");
                            
                            return false
                        end
                    end
                end
            end

        end
    
    else
        return false;

    end
    
    return true;
end

local function OnGameOver(event)
    local trigger = event.process.trigger;
    local playerId = trigger.id;
    local opponentId = playerId == 0 and 1 or 0;

    if IsGameOver(playerId, opponentId) then
        game:RemovePlayer(opponentId);
    end
end

CheckEH = {opType = 9, callback = OnChessCheck, notiType = EventNotification.Type.PRE};
GameOverCheckEH = {opType = 9, callback = OnGameOver, notiType = EventNotification.Type.POST};

