require('Dirs')

-- Common
local name = "Pawn";
local pawnRange = {
    min = 0,
    max = 1
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
        Dirs.n
    }
});

local blackAdp = AreaDesc.New({
    directions = {
        Dirs.s;
    }
});

local whiteAttackAdp = AreaDesc.New({
    directions = {
        Dirs.ne,
        Dirs.nw
    }
})

local blackAttackAdp = AreaDesc.New({
    directions = {
        Dirs.se,
        Dirs.sw
    }
})

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

function CreateWhitePawn()
    return {name = name, moveType = whiteMove, weapons = {whiteWeapon}}
end

function CreateBlackPawn()
    return {name = name, moveType = blackMove, weapons = {blackWeapon}}
end

