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
    }
});

local blackAdp = AreaDesc.New({
    directions = {
        Dirs.n, Dirs.ne, Dirs.nw
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

function CreateWhitePawn()
    return {name = name, moveType = whiteMove, weapons = {whiteWeapon}}
end

function CreateBlackPawn()
    return {name = name, moveType = blackMove, weapons = {blackWeapon}}
end

