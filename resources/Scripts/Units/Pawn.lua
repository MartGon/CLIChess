require('Dirs')

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

--[[
    This way, the only handlers we need are:
    1. Invalid diagonal movement. The movement is canceled if there are no enemy pieces at the dest or
        there wasn't a previous enemy pawn double move on that column.
    2. Cancel every move with a range of 2 if it isn't the first move that pawn makes in the game.
]]--


local whiteWeapon = WeaponType.New({
    tpd = whiteAdp,
    range = pawnRange,
    attackTable = chessAttackTable,
    dmgTable = chessDmgTable
});

local blackWeapon = WeaponType.New({
    tpd = blackAdp,
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

local function onDiagonalMove(event, guid) 
    
    local p = event.process;
    local op = p.operation;
    local args = op:GetArgs();
    
    local map = game:GetMap(0);
    local unit = map:GetUnit(args.origin);
    if unit then
        local unitGUID = unit:GetGUID();
        if unitGUID == guid then
            local move = args.dest - args.origin;

            local isBlackDiagonal = move == Dirs.se or move == Dirs.sw;
            local isWhiteDiagnoal = move == Dirs.ne or move == Dirs.nw;
            if(isBlackDiagonal or isWhiteDiagnoal) then
                local destUnit = map:GetUnit(args.dest);
                if destUnit == nil then
                    print("Pawns can only move diagonally if capturing");
                    game:CancelProcess(p);
                end
            end
        end
    end
end

local function HasAlreadyMoved(guid)

    local hasMoved = false;
    for i = 1, game:GetHistoryCount() do
        local p = game:GetHistoryProcess(i);
        local args = p.operation:GetArgs();
        
        local unitGUID = args.unit:GetGUID()
        print("On process "..i.." unit with guid "..tostring(unitGUID).." moved");
        if unitGUID == guid then
            hasMoved = true;
            break;
        end
    end

    return hasMoved;
end

local function IsDoubleMove(move)
    return move == Dirs.n2 or move == Dirs.s2;
end

local function onMove(event, guid)
    local p = event.process;
    local op = p.operation;
    local args = op:GetArgs();
    
    local map = game:GetMap(0);
    local unit = map:GetUnit(args.origin);
    if unit then
        local unitGUID = unit:GetGUID();
        if unitGUID == guid then
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

local diagonalEH = {opType = 9, callback = onDiagonalMove, notiType = EventNotification.Type.PRE};
local doubleMoveEH = {opType = Operation.Type.SCRIPT, callback = onMove, notiType = EventNotification.Type.PRE};

function CreateWhitePawn()
    return {name = name, moveType = whiteMove, weapons = {whiteWeapon}, eventHandlers = {diagonalEH, doubleMoveEH}}
end

function CreateBlackPawn()
    return {name = name, moveType = blackMove, weapons = {blackWeapon}, eventHandlers = {diagonalEH, doubleMoveEH}}
end

