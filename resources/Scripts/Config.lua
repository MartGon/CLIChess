
local function CreateChessTile()



end

local up = Vector2.new(0, 1);
local down = Vector2.new(0, -1);
local right = Vector2.new(1, 0);
local left = Vector2.new(-1, 0);

local function CreateRook()


    local name = "Rook";
    local tpd = AreaDesc.New({
        directions = {
            up, down, right, left
        },
        lockedDirs = {
            {
                dir = up,
                locksTo = {
                    up
                }
            },
            {
                dir = left,
                locksTo = {
                    left
                }
            },
            {
                dir = right,
                locksTo = {
                    right
                }
            },
            {
                dir = down,
                locksTo = {
                    down
                }
            }
        }
    });
    
    local moveType = MovementDescType.New({
        tpd = tpd,
        range = {
            min = 0,
            max = -10
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

local rook = CreateRook();
DB:AddUnitType(rook);
