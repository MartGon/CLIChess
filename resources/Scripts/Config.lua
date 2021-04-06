

require("Dirs")
require("ChessHandler");
require("Units/ChessTables")

require('Units/Rook');
require('Units/King');
require('Units/Bishop');
require('Units/Knight');
require('Units/Queen');
require('Units/Pawn');

-- Players
local white = game:CreatePlayer(0);
local black = game:CreatePlayer(1);

-- Units
local rookType = DB:AddUnitType(CreateRook()); -- 0
local kingType = DB:AddUnitType(CreateKing()); -- 1
local bishopType = DB:AddUnitType(CreateBishop()); -- 2
local knightType = DB:AddUnitType(CreateKnight()); -- 3
local queenType = DB:AddUnitType(CreateQueen()); -- 4

local whitePawnType = DB:AddUnitType(CreateWhitePawn()); -- 5
local blackPawnType = DB:AddUnitType(CreateBlackPawn()); -- 6

UNIT_TYPES = { rook = rookType, bishop = bishopType, knight = knightType, queen = queenType,
                whitePawn = whitePawnType, blackPawn = blackPawnType}

WhiteKing = kingType:CreateUnit(white);
BlackKing = kingType:CreateUnit(black);

-- Tiles
local tileType = DB:AddTileType("ChessTile");

-- Map
local map = game:CreateMap(8, 8);
map:Fill(tileType);

map:AddUnit({x = 0, y = 0}, rookType:CreateUnit(black));
map:AddUnit({x = 1, y = 0}, knightType:CreateUnit(black));
map:AddUnit({x = 2, y = 0}, bishopType:CreateUnit(black));
map:AddUnit(Vector2.new(3, 0), queenType:CreateUnit(black));
map:AddUnit(Vector2.new(4, 0), BlackKing);
map:AddUnit({x = 5, y = 0}, bishopType:CreateUnit(black));
map:AddUnit({x = 6, y = 0}, knightType:CreateUnit(black));
map:AddUnit(Vector2.new(7, 0), rookType:CreateUnit(black));

for i = 0, 7 do
    map:AddUnit({x = i, y = 1}, blackPawnType:CreateUnit(black));
end

map:AddUnit(Vector2.new(0, 7), rookType:CreateUnit(white));
map:AddUnit({x = 1, y = 7}, knightType:CreateUnit(white));
map:AddUnit({x = 2, y = 7}, bishopType:CreateUnit(white));
map:AddUnit(Vector2.new(3, 7), queenType:CreateUnit(white));
map:AddUnit(Vector2.new(4, 7), WhiteKing);
map:AddUnit({x = 5, y = 7}, bishopType:CreateUnit(white));
map:AddUnit({x = 6, y = 7}, knightType:CreateUnit(white));
map:AddUnit(Vector2.new(7, 7), rookType:CreateUnit(white));

for i = 0, 7 do
    map:AddUnit({x = i, y = 6}, whitePawnType:CreateUnit(white));
end

game:AddEventHandler(GameOverCheckEH);

--[[
local origin, dest = Vector2.new(7, 7), Vector2.new(7, 6)
local _, nothing = ChessMove(map, origin, dest);
UndoChessMove(map, origin, dest, nothing);

local whiteQueenPos = Vector2.new(4, 0);
local whiteQueen = map:GetUnit(Vector2.new(4, 6));
assert(IsPosOnCheckByUnit(Vector2.new(4, 0), whiteQueen:GetGUID()), "IsPosOnCheckByUnit does not work correclty");
]]--
