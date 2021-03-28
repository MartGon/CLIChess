
require('Units/Rook');
require('Units/King');
require('Units/Bishop');
require('Units/Knight');
require('Units/Queen');

-- Players
local white = game:CreatePlayer(0);
local black = game:CreatePlayer(1);

-- Units
local rookType = DB:AddUnitType(CreateRook());
local kingType = DB:AddUnitType(CreateKing());
local bishopType = DB:AddUnitType(CreateBishop());
local knightType = DB:AddUnitType(CreateKnight());
local queenType = DB:AddUnitType(CreateQueen());

-- Tiles
local tileType = DB:AddTileType("ChessTile");

-- Map
local map = game:CreateMap(8, 8);
map:Fill(tileType);

map:AddUnit({x = 0, y = 0}, rookType:CreateUnit(white));
map:AddUnit({x = 1, y = 0}, knightType:CreateUnit(white));
map:AddUnit({x = 2, y = 0}, bishopType:CreateUnit(white));
map:AddUnit(Vector2.new(3, 0), queenType:CreateUnit(white));
map:AddUnit(Vector2.new(4, 0), kingType:CreateUnit(white));
map:AddUnit({x = 5, y = 0}, bishopType:CreateUnit(white));
map:AddUnit({x = 6, y = 0}, knightType:CreateUnit(white));
map:AddUnit(Vector2.new(7, 0), rookType:CreateUnit(white));

map:AddUnit(Vector2.new(0, 7), rookType:CreateUnit(black));
map:AddUnit({x = 1, y = 7}, knightType:CreateUnit(black));
map:AddUnit({x = 2, y = 7}, bishopType:CreateUnit(black));
map:AddUnit(Vector2.new(3, 7), queenType:CreateUnit(black));
map:AddUnit(Vector2.new(4, 7), kingType:CreateUnit(black));
map:AddUnit({x = 5, y = 7}, bishopType:CreateUnit(black));
map:AddUnit({x = 6, y = 7}, knightType:CreateUnit(black));
map:AddUnit(Vector2.new(7, 7), rookType:CreateUnit(black));

