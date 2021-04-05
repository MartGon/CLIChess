
function HasAlreadyMoved(guid)

    local hasMoved = false;
    for i = 1, game:GetHistoryCount() do
        local p = game:GetHistoryProcess(i);
        if p.trigger.type == Trigger.Type.PLAYER then
            local args = p.operation:GetArgs();
            if args.type == "move" then
                local unitGUID = args.unit:GetGUID()
                -- print("On process "..i.." unit with guid "..tostring(unitGUID).." moved");
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

function IsPosOnCheckByUnit(targetPos, attackerGUID, targetOwnerId)
    local map = game:GetMap(0);

    -- If a targetUnit is found, we take that owner Id and ignore the one
    -- that was provided
    local targetUnit = map:GetUnit(targetPos);
    if targetUnit then
        local targetOwner = targetUnit:GetOwner();
        targetOwnerId = targetOwner:GetId();
    end

    local attackerPos = game:GetUnitPos(attackerGUID);
    if attackerPos then
        attackerPos = attackerPos.pos;
        local attacker = map:GetUnit(attackerPos);
        if targetOwnerId and attacker then
            local attackerOwner = attacker:GetOwner();
            if targetOwnerId ~= attackerOwner:GetId() then
                local attack = attacker:CalculateAttack(0, map, attackerPos);
                if attack:CanAttack(targetPos) then
                    
                    -- Remove target unit before calculating movement
                    if targetUnit then
                        map:RemoveUnit(targetPos);    
                    end
                    
                    local move = attacker:CalculateMovement(map, attackerPos);
                    local canMove = move:CanMove(targetPos);
                    
                    if canMove then
                        print("Unit at "..tostring(attackerPos).." is checking unit at pos "..tostring(targetPos));
                    end
                    
                    -- Restore prev. removed unit
                    if targetUnit then
                        map:AddUnit(targetPos, targetUnit);
                    end

                    return canMove;
                end
            end
        end
    end
    
    return false;
end

function IsPosOnCheckByPlayer(targetPos, attackerPlayerId, defenderPlayerId)

    local map = game:GetMap(0);
    local mapSize = map:GetSize();

    for x = 0, mapSize.x - 1 do
        for y = 0, mapSize.y - 1 do
            local pos = Vector2.new(x, y);
            local unit = map:GetUnit(pos);

            if unit then
                local ownerId = unit:GetOwner():GetId();
                if ownerId == attackerPlayerId then
                    if IsPosOnCheckByUnit(targetPos, unit:GetGUID(), defenderPlayerId) then
                        return true;
                    end
                end
            end
        end
    end

    return false;
end

function OnChessCheck(event, guid)
    
    local trigger = event.process.trigger;
    local args = event.process.operation:GetArgs();

    if args.type == "move" then

        local map = game:GetMap(0);
        if map:IsPosValid(args.origin) and map:IsPosValid(args.dest) then

            
            local unit = map:GetUnit(args.origin);
            if unit then
                -- Apply movement, then check state
                local destUnit = map:GetUnit(args.dest);
                map:RemoveUnit(args.dest);
                map:RemoveUnit(args.origin);
                map:AddUnit(args.dest, unit);
                
                -- Check
                if trigger.type == Trigger.Type.PLAYER then
                    local playerId = trigger.id;
                    local king = playerId == 0 and WhiteKing or BlackKing;
                    local kingPos = game:GetUnitPos(king:GetGUID()).pos;

                    if IsPosOnCheckByUnit(kingPos, guid) then
                        print("Cannot perform a move that would leave your king on check!");
                        game:CancelProcess(event.process);
                    end

                end

                -- Reapply state after check
                map:RemoveUnit(args.dest);
                map:AddUnit(args.origin, unit);
                if destUnit then
                    map:AddUnit(args.dest, destUnit);
                end
            end
        end
    end
end

CheckEH = {opType = 9, callback = OnChessCheck, notiType = EventNotification.Type.PRE};

