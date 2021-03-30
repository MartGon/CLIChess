require("Dirs")

local KnigthDirs = {
    {x = 2, y = 1},
    {x = -2, y = 1},
    {x = 2, y = -1},
    {x = -2, y = -1},
    {x = 1, y = 2},
    {x = -1, y = 2},
    {x = 1, y = -2},
    {x = -1, y = -2}
}

function CreateKnight()

    local name = "Knight";
    local tpd = AreaDesc.New({
        directions = KnigthDirs;
    });
    
    local range = {
        min = 0,
        max = 1
    };
    local moveType = MovementDescType.New({
        tpd = tpd,
        range = range,
        tileCT = {
            entries = {
                {id = 0, cost = 1}
            },
            default = 1
        },
        unitCT = {
            entries = {
                {id = 0, cost = -1}
            },
            default = -1
        },
        maxGas = -1
    })

    local weapon = WeaponType.New({
        tpd = tpd,
        range = range,
        attackTable = chessAttackTable,
        dmgTable = chessDmgTable
    });

    return {name = name, moveType = moveType, weapons = {weapon}};

end
