

-- Common
local name = "Pawn";
local pawnRange = {
    min = 0,
    max = 2
}

local tileCT = {
    entries = {
        {id = 0, cost = 1}
    },
    default = 1;
}

local unitCT = {
    entries = {
        {id = 0, cost = -1}
    },
    default = -1;
}

-- Diff

local whiteAdp = AreaDesc.New({
    directions = {
        Dirs.s, Dirs.se, Dirs.sw
    },
    lockedDirs = {
        {
            dir = Dirs.s,
            locksTo = {
                Dirs.s
            }
        },
        {
            dir = Dirs.se,
            locksTo = {
            }
        },
        {
            dir = Dirs.sw,
            locksTo = {
            }
        },
    }
});

local whiteAttackAdp = AreaDesc.New({
    directions = {
        Dirs.se, Dirs.sw
    }
})

local blackAdp = AreaDesc.New({
    directions = {
        Dirs.n, Dirs.ne, Dirs.nw
    },
    lockedDirs = {
        {
            dir = Dirs.n,
            locksTo = {
                Dirs.n
            }
        },
        {
            dir = Dirs.ne,
            locksTo = {
            }
        },
        {
            dir = Dirs.nw,
            locksTo = {
            }
        },
    }
});

local blackAttackAdp = AreaDesc.New({
    directions = {
        Dirs.ne, Dirs.nw
    }
})

--[[
    This way, the only handlers we need are:
    1. Invalid diagonal movement. The movement is canceled if there are no enemy pieces at the dest or
        there wasn't a previous enemy pawn double move on that column.
    2. Cancel every move with a range of 2 if it isn't the first move that pawn makes in the game.
]]--


local whiteWeapon = WeaponType.New({
    tpd = whiteAttackAdp,
    range = pawnRange,
    attackTable = chessAttackTable,
    dmgTable = chessDmgTable
});

local blackWeapon = WeaponType.New({
    tpd = blackAttackAdp,
    range = pawnRange,
    attackTable = chessAttackTable,
    dmgTable = chessDmgTable
});

local whiteMove = MovementDescType.New({
    tpd = whiteAdp,
    range = pawnRange,
    tileCT = tileCT,
    unitCT = unitCT,
    maxGas = -1,
});

local blackMove = MovementDescType.New({
    tpd = blackAdp,
    range = pawnRange,
    tileCT = tileCT,
    unitCT = unitCT,
    maxGas = -1
});

local function GetLastPlayerOp()
    local hCount = game:GetHistoryCount();

    local op = nil;
    for i = hCount, 1, -1 do
        local process = game:GetHistoryProcess(i);
        if process.trigger.type == Trigger.Type.PLAYER then
            op = process.operation;
            break;
        end
    end

    return op;
end

local function IsPawn(unitGUID) 
    return unitGUID.subType == UNIT_TYPES.whitePawn:GetId() or unitGUID.subType == UNIT_TYPES.blackPawn:GetId();
end

local function IsDoubleMove(move)
    return move == Dirs.n2 or move == Dirs.s2;
end

local function CheckEnPassant(dest)

    local op = GetLastPlayerOp();
    if op then
        local args = op:GetArgs();
        if args.type == "move" then
            local otherUnit = args.unit;
            if IsPawn(otherUnit:GetGUID()) then
                local move = args.origin - args.dest;
                if IsDoubleMove(move) then
                    if args.dest.x == dest.x then -- Is on the same column
                        return true, args.dest;
                    end
                end
            end
        end
    end

    return false, nil;
end

local function onDiagonalMove(event, guid) 
    
    local p = event.process;
    local op = p.operation;
    local args = op:GetArgs();
    
    if args.type == "move" then
        local map = game:GetMap(0);
        local pawn = map:GetUnit(args.origin);
        if pawn then
            local pawnGUID = pawn:GetGUID();
            if pawnGUID == guid then
                local move = args.dest - args.origin;

                local isBlackDiagonal = move == Dirs.se or move == Dirs.sw;
                local isWhiteDiagnoal = move == Dirs.ne or move == Dirs.nw;
                if(isBlackDiagonal or isWhiteDiagnoal) then
                    local isEnPassant, capturedPawnPos = CheckEnPassant(args.dest);
                    if isEnPassant then
                        args.destUnit = map:GetUnit(capturedPawnPos);
                        map:RemoveUnit(capturedPawnPos);
                        print("Capturing pawn at "..tostring(capturedPawnPos).." by En Passant");
                    elseif map:IsPosFree(args.dest) then
                        print("Pawns can only move diagonally if capturing");
                        game:CancelProcess(p);
                    end
                end
            end
        end
    end
end

local function GetPromotionUnitType()
    
    local type = nil
    while type == nil do
        print("Promotion. Please choose a unit type to promote this pawn. Valid types are: rook, queen, bishop, knight");
        local typeStr = string.lower(io.stdin:read());
        type = UNIT_TYPES[typeStr];

        if type == nil then
            print("Type "..typeStr.." is not a valid type.");
        end
    end

    return type;
end

local function onMove(event, guid)
    local p = event.process;
    local op = p.operation;
    local args = op:GetArgs();
    
    if args.type == "move" then

        local map = game:GetMap(0);
        local pawn = map:GetUnit(args.origin);
        if pawn then
            local pawnGUID = pawn:GetGUID();
            if pawnGUID == guid then

                -- Cancel double move outside of first move
                local move = args.dest - args.origin;
                if IsDoubleMove(move) then
                    if HasAlreadyMoved(guid) then
                        print("Pawns can only move two tiles on their first move");
                        game:CancelProcess(p);
                    end
                end
            end
        end

    end
end

local function afterMove(event, guid)
    local p = event.process;
    local op = p.operation;
    local args = op:GetArgs();
    
    if args.type == "move" then

        local map = game:GetMap(0);
        local pawn = args.unit;
        if pawn then
            local pawnGUID = pawn:GetGUID();
            if pawnGUID == guid then
                -- Check for promotion
                if args.dest.y == 0 or args.dest.y == 7 then
                    local type = GetPromotionUnitType();
                    if type then
                        map:RemoveUnit(args.dest);
                        local owner = pawn:GetOwner();
                        map:AddUnit(args.dest, type:CreateUnit(owner));
                    else
                        game:CancelProcess(p);
                    end
                end
            end
        end
    end
end

local diagonalEH = {opType = 9, callback = onDiagonalMove, notiType = EventNotification.Type.PRE};
local doubleMoveEH = {opType = Operation.Type.SCRIPT, callback = onMove, notiType = EventNotification.Type.PRE};
local promoteEH = {opType = Operation.Type.SCRIPT, callback = afterMove, notiType = EventNotification.Type.POST}

function CreateWhitePawn()
    return {name = name, moveType = whiteMove, weapons = {whiteWeapon}, eventHandlers = {diagonalEH, doubleMoveEH, promoteEH, CheckEH}}
end

function CreateBlackPawn()
    return {name = name, moveType = blackMove, weapons = {blackWeapon}, eventHandlers = {diagonalEH, doubleMoveEH, promoteEH, CheckEH}}
end

