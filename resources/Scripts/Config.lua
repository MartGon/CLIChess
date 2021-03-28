
require('Units/Rook');
require('Units/King');

-- Players
local black = game:CreatePlayer(0);
local white = game:CreatePlayer(1);

-- Units
local rookType = DB:AddUnitType(CreateRook());
local kingType = DB:AddUnitType(CreateKing());

-- Tiles
local tileType = DB:AddTileType("ChessTile");

-- Map
local map = game:CreateMap(8, 8);
map:Fill(tileType);

map:AddUnit({x = 0, y = 0}, rookType:CreateUnit(white));
map:AddUnit(Vector2.new(4, 0), kingType:CreateUnit(white));
map:AddUnit(Vector2.new(7, 0), rookType:CreateUnit(white));

map:AddUnit(Vector2.new(0, 7), rookType:CreateUnit(black));
map:AddUnit(Vector2.new(4, 7), kingType:CreateUnit(black));
map:AddUnit(Vector2.new(7, 7), rookType:CreateUnit(black));
