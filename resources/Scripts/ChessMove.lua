


function Execute(Game& game)

    local map = game:GetMap(mapIndex); -- mapIndex is defined int this env
    local unit = map:GetUnit(origin); -- origin is defined in this env

    if unit then
        local move = unit:CalculateMovement(map, origin);
        if move:CanMove(dest) then -- dest is also defined in this env
            
            destUnit = map:GetUnit(dest);
            if destUnit then
                map:RemoveUnit(dest);
            end
            
            map:RemoveUnit(origin);
            map:AddUnit(origin, unit);

        end
    end

end

function Undo(Game& game)

    local map = game:GetMap(mapIndex);

    map:RemoveUnit(dest);
    map:AddUnit(origin, unit);
    
    if destUnit then
        map:AddUnit(dest, destUnit)
    end

end