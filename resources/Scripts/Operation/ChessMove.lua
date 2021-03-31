
function Execute(game, process)

    local map = game:GetMap(mapIndex); -- mapIndex is defined int this env
    local unit = map:GetUnit(origin); -- origin is defined in this env

    local owner = unit:GetOwner();
    local trigger = process.trigger;
    if trigger.type == Trigger.PLAYER and owner:GetId() == trigger.id then
        if unit then
            if origin ~= dest then

                destUnit = map:GetUnit(dest);
                if destUnit then
                    local destOwner = destUnit:GetOwner();
                    if destOwner:GetId() ~= owner:GetId() then
                        local attack = unit:CalculateAttack(0, map, origin);
                        if attack:CanAttack(dest) then

                            map:RemoveUnit(dest) -- Remove to calculate movement
                        end
                    else
                        error("Cannot capture a friendly unit");
                    end
                end
                
                movement = unit:CalculateMovement(map, origin);
                if movement:CanMove(dest) then -- dest is also defined in this env
                    
                    map:RemoveUnit(origin);
                    map:AddUnit(dest, unit);

                    print("Unit moved successfully from "..tostring(origin).." to "..tostring(dest));
                elseif destUnit then
                    map:AddUnit(dest, destUnit); -- restore unit if cannot move there
                    error ("Unit cannot move to that location")
                else
                    error ("Unit cannot move to that location")
                end

            else
                error("Origin and destination are the same position")
            end
        else
            error("Unit not found")

        end
    else
        error("Unit at "..tostring(origin).." doesn't belong to player "..trigger.id);
    end

end

function Undo(game)

    local map = game:GetMap(mapIndex);

    map:RemoveUnit(dest);
    map:AddUnit(origin, unit);
    
    if destUnit then
        map:AddUnit(dest, destUnit)
    end

end