#include <iostream>
#include <filesystem>

#include <AWC.h>
#include <Script.h>

// App
#include <Console.h>
#include <ConsoleCommand.h>

int GetCoord(char c)
{
    if(c >= 'A' && c < 'a')
        c = c -'A';
    else if(c >= 'a')
        c = c - 'a';
    else
        c = c - '0';
    
    return c;
}

int main(int argc, const char** args)
{
    // Prepare game
    Script::Game sGame;
    auto& game = sGame.GetGame();

    std::filesystem::path scripts = std::filesystem::path{RESOURCES_DIR} / std::filesystem::path{"Scripts/"};
    sGame.GetLuaVM().AppendToPath(scripts);

    std::filesystem::path CONFIG_SCRIPT = scripts / "Config.lua";
    try
    {
        sGame.RunConfig(CONFIG_SCRIPT);
    }catch(const AWC::Exception& e)
    {
        std::cout << "Exception thrown while running file " << CONFIG_SCRIPT << ": " << e.what() << '\n';
        return -1;
    }

    std::string SCRIPTS_DIR = std::string{RESOURCES_DIR} + "Scripts/Operation/";
    std::string moveSP = SCRIPTS_DIR + "ChessMove.lua";
    std::string castleSP = SCRIPTS_DIR + "Castle.lua";

    auto moveST = -1;
    auto castleST = -1;
    try
    {
        moveST = sGame.CreateScriptType(moveSP);
        castleST = sGame.CreateScriptType(castleSP);

        std::cout << "All scripts parsed were correctly loaded\n";
    }
    catch(const AWC::Exception& e)
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
    std::shared_ptr<ConsoleCommand> printMapComm{new PrintMapCommand{game, padding, 2}};
    std::shared_ptr<ConsoleCommand> exitComm{new ExitConsoleCommand{console}};
    std::shared_ptr<ConsoleCommand> attackComm{new UnitAttackCommand(game)};
    std::shared_ptr<ConsoleCommand> reportComm{new UnitReportCommand(game)};
    std::shared_ptr<ConsoleCommand> passComm{new PassTurnCommand{game}};
    std::shared_ptr<ConsoleCommand> helpComm{new HelpConsoleCommand{console}};

    // Error listener
    auto& subject = game.GetSubject();
    auto errCb = [](const Event::Notification::Notification noti, Entity::GUID, Game&){
        //std::cout << noti.res.value().GetReason();
    };
    subject.Register(Script::SCRIPT, errCb, Event::Notification::Type::ERROR);

    // Auto pass turn
    auto cb = [](const Event::Notification::Notification noti, Entity::GUID entity, Game& game){
        game.PassTurn();

        auto nextTurn = game.GetCurrentTurn();
        std::cout << "Now it's Player " << nextTurn.playerIndex << " turn\n";
    };
    subject.Register(Script::SCRIPT, cb, Event::Notification::Type::POST);

    // Move Command
    auto parseMove = [&moveST, &sGame](std::vector<std::string> args)
    {
        std::cout << "Moving\n";

        auto& game = sGame.GetGame();
        auto mapSize = game.GetMap(0).GetSize();

        int originX = GetCoord(args[0][0]);
        int originY = mapSize.y - GetCoord(args[0][1]);
        Vector2 origin{originX, originY};
        std::cout << "origin: " << origin.ToString() << '\n';

        int destX = GetCoord(args[1][0]);
        int destY = mapSize.y - GetCoord(args[1][1]);
        Vector2 dest{destX, destY};
        std::cout << "dest: " << dest.ToString() << '\n';

        auto s = sGame.CreateScript(moveST);
        //std::cout << "script: " << s << '\n';
        auto& st = sGame.GetScriptTable(s);

        st.Set("type", "move");
        st.Set("mapIndex", 0);
        st.SetDataCopy<Script::UserData::Vector2>("origin", origin);
        st.SetDataCopy<Script::UserData::Vector2>("dest", dest);

        
        Process::Trigger::Trigger t{Process::Trigger::Type::PLAYER, game.GetCurrentTurn().playerIndex};
        sGame.PushScript(s, t);
        
        sGame.GetGame().Run();
    };
    std::shared_ptr<CommandNS::Custom> moveComm{new CommandNS::Custom{game, parseMove}};

    auto parseCastle = [&castleST, &sGame](std::vector<std::string> args)
    {
        std::string side = args.size() > 0 ? args[0] : "null";

        auto s = sGame.CreateScript(castleST);
        auto& sTable = sGame.GetScriptTable(s);
        sTable.Set("side", side);
        sTable.Set("type", "castle");

        auto& game = sGame.GetGame();
        Process::Trigger::Trigger t{Process::Trigger::Type::PLAYER, game.GetCurrentTurn().playerIndex};
        sGame.PushScript(s, t);

        sGame.GetGame().Run();
    };
    std::shared_ptr<CommandNS::Custom> castleComm{new CommandNS::Custom{game, parseCastle}};

    // Add command to console
    console.AddCommand("print", printMapComm);
    console.AddCommand("print-map", printMapComm);
    //console.AddCommand("pass", passComm);
    console.AddCommand("exit", exitComm);
    console.AddCommand("move", moveComm);
    console.AddCommand("castle", castleComm);
    //console.AddCommand("report", reportComm);
    console.AddCommand("help", helpComm);

    while(console.IsOpen())
    {
        console.Prompt();

        if(game.IsOver())
        {
            std::cout << "Game is over!!!\n";
            std::cout << "Team " << game.GetWinnerTeamId() << " wins\n";
            console.Close();
        }
    }

    return 0;
}