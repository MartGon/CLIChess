#include <iostream>
#include <AWC.h>
#include <Script.h>

// App
#include <Console.h>
#include <ConsoleCommand.h>

UnitType CreateSoldierType()
{
    // Name and id
    uint id = 0;
    std::string name = "Soldier";

    // TilePatternDesc
    std::vector<Vector2> manhattanMoves{{0, 1}, {1, 0}, {0, -1}, {-1, 0}};
    TilePatternDescIPtr manhattan = TilePatternDesc::Create(manhattanMoves);

    // CostTables
    std::shared_ptr<CostTable> unitCostTable{new CostTable};
    unitCostTable->SetCost(0, 0);

    CostTablePtr tileCostTable{new CostTable};
    uint grassId = 0;
    tileCostTable->SetCost(grassId, 1);

    // Movement
    MovementDecTypePtr moveType{ new MovementDescType{manhattan, {3, 0}, tileCostTable, unitCostTable, 99}};

    // Weapon
    AttackTable attackTable{ { {id, true}, {1, true} } };
    DamageTable damageTable{ { {id, 50}, {1, 25} } };
    WeaponTypePtr weaponType{ new WeaponType{manhattan, {1, 1}, attackTable, damageTable, 99}};

    UnitType soldierType{id, name, moveType, {weaponType}};

    return soldierType;
}

int main()
{
    // Prepare game
    Script::Game sGame;
    auto& game = sGame.GetGame();

    // Players
    Player playerOne{0, 0, 0};
    Player playerTwo{1, 1, 0};
    game.AddPlayer(playerOne);
    game.AddPlayer(playerTwo);

    // Tiles
    Map map{8, 8};
    TileType grassType{0, "Grass"};
    MapUtils::FillMap(map, grassType);

    // Units
    auto soldierType = CreateSoldierType();
    
        // Red units
    map.AddUnit({1, 0}, soldierType.CreateUnit(game.GetPlayer(0)));
    map.AddUnit({2, 1}, soldierType.CreateUnit(game.GetPlayer(0)));
    map.AddUnit({1, 2}, soldierType.CreateUnit(game.GetPlayer(0)));

        // Blue units
    map.AddUnit({4, 0}, soldierType.CreateUnit(game.GetPlayer(1)));
    map.AddUnit({4, 2}, soldierType.CreateUnit(game.GetPlayer(1)));

    // Set map
    game.AddMap(map);

    std::string SCRIPTS_DIR = std::string{RESOURCES_DIR} + "Scripts/Operation/";
    std::string moveSP = SCRIPTS_DIR + "/ChessMove.lua";

    auto moveST = -1;
    try
    {
        moveST = sGame.CreateScriptType(moveSP);

        std::cout << "All scripts parsed were correctly loaded\n";
    }
    catch(const AWCException& e)
    {
        std::cout << "Exception thrown: " << e.what() << '\n';
    }

    // Finish prepare game
    Console console(game);

    // Prompt message
    std::string promptMsg = "Please, type a command.\n";
    console.SetPromptMsg(promptMsg);

    // Commands
    Padding padding{2, 2, 4, 2};
    std::shared_ptr<ConsoleCommand> printMapComm{new PrintMapCommand{game, padding}};
    std::shared_ptr<ConsoleCommand> exitComm{new ExitConsoleCommand{console}};
    std::shared_ptr<ConsoleCommand> attackComm{new UnitAttackCommand(game)};
    std::shared_ptr<ConsoleCommand> reportComm{new UnitReportCommand(game)};
    std::shared_ptr<ConsoleCommand> passComm{new PassTurnCommand{game}};
    std::shared_ptr<ConsoleCommand> helpComm{new HelpConsoleCommand{console}};

    // Error listener
    auto& subject = game.GetSubject();
    auto errCb = [](const Event::Notification::Notification noti, Entity::GUID, Game&){
        std::cout << "An error ocurred: " << noti.res.value().GetReason() << '\n';
    };
    subject.Register(Script::SCRIPT, errCb, Event::Notification::Type::ERROR);

    // Move Command
    auto parseMove = [&moveST, &sGame](std::vector<std::string> args)
    {
        std::cout << "Moving\n";

        int originX = std::atoi(args[0].c_str());
        int originY = std::atoi(args[1].c_str());
        Vector2 origin{originX, originY};
        std::cout << "origin: " << origin.ToString() << '\n';

        int destX = std::atoi(args[2].c_str());
        int destY = std::atoi(args[3].c_str());
        Vector2 dest{destX, destY};
        std::cout << "dest: " << dest.ToString() << '\n';

        auto s = sGame.CreateScript(moveST);
        std::cout << "script: " << s << '\n';
        auto& st = sGame.GetScriptTable(s);

        st.SetInt("mapIndex", 0);
        st.SetGCData("origin", Script::UserData::Vector2::MT_NAME, origin);
        st.SetGCData("dest", Script::UserData::Vector2::MT_NAME, dest);

        auto pid = sGame.PushScript(s);

        auto& game = sGame.GetGame();
        auto& subject = game.GetSubject();

        auto cb = [pid](const Event::Notification::Notification noti, Entity::GUID entity, Game& game){
            if(noti.process.id == pid)
            {
                game.PassTurn();

                auto nextTurn = game.GetCurrentTurn();
                std::cout << "Now it's Player " << nextTurn.playerIndex << " turn\n";

                auto& subject = game.GetSubject();
                subject.Unregister(entity);
            }
        };
        subject.Register(Script::SCRIPT, cb, Event::Notification::Type::POST);

        sGame.GetGame().Run();
    };
    std::shared_ptr<CommandNS::Custom> moveComm{new CommandNS::Custom{game, parseMove}};

    // Add command to console
    console.AddCommand("print", printMapComm);
    console.AddCommand("print-map", printMapComm);
    console.AddCommand("pass", passComm);
    console.AddCommand("exit", exitComm);
    console.AddCommand("move", moveComm);
    console.AddCommand("report", reportComm);
    console.AddCommand("help", helpComm);

    while(console.IsOpen())
    {
        console.Prompt();

        if(game.IsOver())
        {
            std::cout << "Game is over!!!\n";
            std::cout << "Team " << game.GetPlayer(0).GetTeamId() << " wins\n";
            break;
        }
    }

    return 0;
}