# TODO

## Current problems

- Defining new Units is a chore, they have to be defined in the C++ code
- In chess, Units cannot move through friendly units. So a MoveType should have Flags for these cases, such as FRIENDLY_OBSTACLES, IGNORE_ENEMIES, etc.
- There's no easy way to identify when a command done by a player is handled correctly, so the turn is passed automatically - HALF DONE
    - Process could have a triggered raw pointer to the process that triggered them
- There's no way to handle proccess (events) from Lua