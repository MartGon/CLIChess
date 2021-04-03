
function IsPosOnCheckBy(targetPos, attackerGUID)
    local map = game:GetMap(0);

    local targetUnit = map:GetUnit(targetPos);
    local attackerPos = game:GetUnitPos(attackerGUID);
    if attackerPos then
        attackerPos = attackerPos.pos;
        local attacker = map:GetUnit(attackerPos);
        if targetUnit and attacker then
            local targetOwner = targetUnit:GetOwner();
            local attackerOwner = attacker:GetOwner();

            if targetOwner:GetId() ~= attackerOwner:GetId() then
                local attack = attacker:CalculateAttack(0, map, attackerPos);
                if attack:CanAttack(targetPos) then
                    map:RemoveUnit(targetPos);

                    local move = attacker:CalculateMovement(map, attackerPos);
                    local canMove = move:CanMove(targetPos);
                    
                    if canMove then
                        print("Unit at "..tostring(attackerPos).." is checking unit at pos "..tostring(targetPos));
                    end
                    
                    map:AddUnit(targetPos, targetUnit);
                    return canMove;
                end
            end
        end
    end
    
    return false;
end

function GetPlayerKingPos(playerId)
    local map = game:GetMap(0);
    local mapSize = map:GetSize();

    for x = 0, mapSize.x - 1 do
        for y = 0, mapSize.y - 1 do
            local pos = Vector2.new(x, y);

            local unit = map:GetUnit(pos);
            if unit then
                if unit:GetGUID().subType == KING_TYPE and unit:GetOwner():GetId() == playerId then
                    return pos;
                end
            end
        end
    end

    error("Couldn't find king for player "..playerId);

    return Vector2.new(-1, -1);
end

function OnChessCheck(event, guid)
    
    
    local trigger = event.process.trigger;
    local args = event.process.operation:GetArgs();

    local map = game:GetMap(0);
    if map:IsPosValid(args.origin) and map:IsPosValid(args.dest) then

        -- Apply movement, then check state
        local unit = map:GetUnit(args.origin);
        if unit then
            local destUnit = map:GetUnit(args.dest);
            map:RemoveUnit(args.dest);
            map:RemoveUnit(args.origin);
            map:AddUnit(args.dest, unit);

            if trigger.type == Trigger.Type.PLAYER then
                local playerId = trigger.id;
                local kingPos = GetPlayerKingPos(playerId);
                
                if IsPosOnCheckBy(kingPos, guid) then
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

CheckEH = {opType = 9, callback = OnChessCheck, notiType = EventNotification.Type.PRE};