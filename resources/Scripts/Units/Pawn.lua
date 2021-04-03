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
    local subType = guid.subType;
    
    if subType == WHITE_PAWN_TYPE or subType == BLACK_PAWN_TYPE then
        
        local p = event.process;
        local op = p.operation;
        local args = op:GetArgs();
        
        local map = game:GetMap(0);
        local unit = map:GetUnit(args.origin);
        if unit then
            local unitGUID = unit:GetGUID();
            print("Listener GUID is "..tostring(guid));
            print("UnitGUID is "..tostring(unitGUID));
            
            if unitGUID == guid then
                print("That pawn is me!");
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
            else
                print("Pawn "..unitGUID.id.." ain't me, I'm "..guid.id);
            end
        end
    end
end

local eh = {opType = 9, callback = onDiagonalMove, notiType = 1};

function CreateWhitePawn()
    return {name = name, moveType = whiteMove, weapons = {whiteWeapon}, eventHandlers = {eh}}
end

function CreateBlackPawn()
    return {name = name, moveType = blackMove, weapons = {blackWeapon}, eventHandlers = {eh}}
end

