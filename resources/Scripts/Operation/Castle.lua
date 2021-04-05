
--[[

    Castling is permissible provided all of the following conditions hold:[4]

    1. The castling must be kingside or queenside.[5]
    2. Neither the king nor the chosen rook has previously moved.
    3. There are no pieces between the king and the chosen rook.
    4. The king is not currently in check.
    5. The king does not pass through a square that is attacked by an enemy piece.
    6. The king does not end up in check. (True of any legal move.)

]]--

local kingPos = {[0] = Vector2.new(4, 7), Vector2.new(4, 0)};

local kingSideKingCastlePos = {[0] = Vector2.new(6, 7), Vector2.new(6, 0)};
local queenSideKingCastlePos = {[0] = Vector2.new(2, 7), Vector2.new(2, 0)};
local kingCastlePos = {king = kingSideKingCastlePos, queen = queenSideKingCastlePos};

local kingRookPos = {[0] = Vector2.new(7,7), Vector2.new(7, 0)};
local queenRookPos = {[0] = Vector2.new(0, 7), Vector2.new(0, 0)};
local rookPos = {king = kingRookPos, queen = queenRookPos};

function Execute(game, process)

    playerId = process.trigger.id;

    king = playerId == 0 and WhiteKing or BlackKing;
    if not HasAlreadyMoved(king:GetGUID()) then -- Rule 2.1
        local map = game:GetMap(0);

        side = string.lower(side);
        if side == "king" or side == "queen" then -- Rule 1
            rook = map:GetUnit(rookPos[side][playerId]);
            if rook and not HasAlreadyMoved(rook:GetGUID()) then -- Rule 2.2
                local origin = kingPos[playerId];
                local enemyId = playerId == 0 and 1 or 0;

                if IsPosOnCheckByPlayer(origin, enemyId, playerId) then -- Rule 4
                    error("King is on check");
                end
                
                local dest = kingCastlePos[side][playerId];
                local inc = origin.x < dest.x and 1 or -1;
                rookCastlePos = Vector2.new(origin.x + inc, origin.y);
                for x = rookCastlePos.x, dest.x, inc do -- Rule 3, 5 and 6
                    local pos = Vector2.new(x, origin.y);
                    -- print("Checking if pos "..tostring(pos).." is threatened");
                    if map:IsPosFree(pos) then -- Rule 3
                        if IsPosOnCheckByPlayer(pos, enemyId, playerId) then -- Rule 5 and 6
                            error("Pos "..tostring(pos).." is on check");
                        end
                    else
                        error("Pos "..tostring(pos).." is not free");
                    end
                end

                -- Castle
                map:RemoveUnit(rookPos[side][playerId]);
                map:RemoveUnit(origin);

                map:AddUnit(dest, king);
                map:AddUnit(rookCastlePos, rook);
                print("Castled successfully on "..side.."side");

            else
                error("King rook of player "..playerId.." has already moved");
            end
        else
            print("Side '"..side.."' is not a valid castling side");
            print("Valid castling sides are: 'king' and 'queen'");
        end
    else
        error("King of player "..playerId.." has already moved");
    end
end

function Undo()
    local map = game:GetMap(0);
    map:RemoveUnit(kingCastlePos[side][playerId]);
    map:RemoveUnit(rookCastlePos);

    map:AddUnit(rookPos[side][playerId], rook);
    map:AddUnit(kingPos[playerId], king);
end