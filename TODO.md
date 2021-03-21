# TODO

## Current problems

1. Defining new Units is a chore, they have to be defined in the C++ code
1. In chess, Units cannot move through friendly units. So a MoveType should have Flags for these cases, such as FRIENDLY_OBSTACLES, IGNORE_ENEMIES, etc.
1. There's no easy way to identify when a command done by a player is handled correctly, so the turn is passed automatically - HALF DONE
    - Process could have a triggered raw pointer to the process that triggered them
1. There's no way to handle proccess (events) from Lua
1. TilePattern is a bit misleading (Design Patterns), should rename to TileArea. - DONE

## Solutions

1. Define a DB interface and a set of methods to Add Entities and Get Entities by id. After this functionality is provided, it can be decided where it should be placed. For now is going to be placed on the Script library. Considering whether to move it to DB or keep it in Script.
2. Add a flag member var to UnitMoveType. Then TilePatternConstraints should have a flag member as well. Take into account in Dijkstra Pathfinding
3. Process could have member var with a pointer to the Operation that triggered that Process. If it is null, then that means that was triggered by a user.
4. Provide a function to add new handlers. Something like. Event.Register(operationType, notificationType, callback)
