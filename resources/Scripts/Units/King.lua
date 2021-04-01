require('Dirs');

function CreateKing()

    local name = "King";
    local tpd = AreaDesc.New({
        directions = {
            Dirs.n, Dirs.w, Dirs.e, Dirs.s,
            Dirs.ne, Dirs.nw, Dirs.se, Dirs.sw
        }
    });
    
    local range = {
        min = 0,
        max = 1
    }
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
    });

    local weapon = WeaponType.New({
        tpd = tpd,
        range = range,
        attackTable = chessAttackTable,
        dmgTable = chessDmgTable
    });

    local function Handler(event, guid, game)
        print("Hanlding some event");
    end

    local eh = {opType = 9, callback = Handler, notiType = 1};

    return {name = name, moveType = moveType, weapons = { weapon }, eventHandlers = {eh}};

end