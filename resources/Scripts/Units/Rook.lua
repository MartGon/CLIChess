require("Dirs")
require("Units/ChessTables")

function CreateRook()

    local name = "Rook";
    local tpd = AreaDesc.New({
        directions = {
            Dirs.n, Dirs.w, Dirs.e, Dirs.s
        },
        lockedDirs = {
            {
                dir = Dirs.n,
                locksTo = {
                    Dirs.n
                }
            },
            {
                dir = Dirs.w,
                locksTo = {
                    Dirs.w
                }
            },
            {
                dir = Dirs.e,
                locksTo = {
                    Dirs.e
                }
            },
            {
                dir = Dirs.s,
                locksTo = {
                    Dirs.s
                }
            }
        }
    });
    
    local range = {
        min = 0,
        max = -1
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
    })

    return {name = name, moveType = moveType, weapons = {weapon}, eventHandlers = {CheckEH}};

end