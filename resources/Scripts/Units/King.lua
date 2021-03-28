require('Dirs');

function CreateKing()

    local name = "King";
    local tpd = AreaDesc.New({
        directions = {
            Dirs.ne, Dirs.nw, Dirs.se, Dirs.sw
        }
    });
    
    local moveType = MovementDescType.New({
        tpd = tpd,
        range = {
            min = 0,
            max = 1
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