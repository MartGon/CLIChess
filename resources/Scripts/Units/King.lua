local n = Vector2.new(0, 1);
local s = Vector2.new(0, -1);
local e = Vector2.new(1, 0);
local w = Vector2.new(-1, 0);
local ne = {x = 1, y = 1};
local nw = {x = -1, y = 1};
local se = {x = 1, y = -1};
local sw = {x = -1, y = -1};

function CreateKing()

    local name = "King";
    local tpd = AreaDesc.New({
        directions = {
            n, s, e, w,
            ne, nw, se, sw
        },
        lockedDirs = {
            {
                dir = n,
                locksTo = {
                    n
                }
            },
            {
                dir = w,
                locksTo = {
                    w
                }
            },
            {
                dir = e,
                locksTo = {
                    e
                }
            },
            {
                dir = s,
                locksTo = {
                    s
                }
            }
            ,
            {
                dir = nw,
                locksTo = {
                    nw
                }
            },
            {
                dir = ne,
                locksTo = {
                    ne
                }
            },
            {
                dir = sw,
                locksTo = {
                    sw
                }
            },
            {
                dir = se,
                locksTo = {
                    se
                }
            }
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