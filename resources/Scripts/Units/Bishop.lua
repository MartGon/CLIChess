require ("Dirs")

function CreateBishop()

    local name = "Bishop";
    local tpd = AreaDesc.New({
        directions = {
            Dirs.ne, Dirs.nw, Dirs.se, Dirs.sw
        },
        lockedDirs = {
            {
                dir = Dirs.nw,
                locksTo = {
                    Dirs.nw
                }
            },
            {
                dir = Dirs.ne,
                locksTo = {
                    Dirs.ne
                }
            },
            {
                dir = Dirs.sw,
                locksTo = {
                    Dirs.sw
                }
            },
            {
                dir = Dirs.se,
                locksTo = {
                    Dirs.se
                }
            }
        }
    });
    
    local moveType = MovementDescType.New({
        tpd = tpd,
        range = {
            min = 0,
            max = -1
        },
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

    return {name = name, moveType = moveType};

end