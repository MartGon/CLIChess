
require('resources/Scripts/Units/Rook');
require('resources/Scripts/Units/King');

DB:AddUnitType(CreateRook());
DB:AddUnitType(CreateKing());

Game:CreatePlayer(0);
Game:CreatePlayer(1);
