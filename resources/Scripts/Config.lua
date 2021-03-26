
require('resources/Scripts/Units/Rook');
require('resources/Scripts/Units/King');

local rookTypeId = DB:AddUnitType(CreateRook());
local kingTypeId = DB:AddUnitType(CreateKing());

local black = Game:CreatePlayer(0);
local white = Game:CreatePlayer(1);

local rookType = DB:GetUnitType(rookTypeId);
local kingType = DB:GetUnitType(kingTypeId);

local map = Game:GetMap(0);
print(map);

map:AddUnit(Vector2.new(0, 0), rookType:CreateUnit(white));
map:AddUnit(Vector2.new(4, 0), kingType:CreateUnit(white));
map:AddUnit(Vector2.new(7, 0), rookType:CreateUnit(white));

map:AddUnit(Vector2.new(0, 7), rookType:CreateUnit(black));
map:AddUnit(Vector2.new(4, 7), kingType:CreateUnit(black));
map:AddUnit(Vector2.new(7, 7), rookType:CreateUnit(black));
