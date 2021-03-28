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
    std::string moveSP = SCRIPTS_DIR + "/ChessMove.lua";

    auto moveST = -1;
    try
    {
        moveST = sGame.CreateScriptType(moveSP);

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
        std::cout << "An error ocurred: " << noti.res.value().GetReason() << '\n';
    };
    subject.Register(Script::SCRIPT, errCb, Event::Notification::Type::ERROR);

    // Move Command
    auto parseMove = [&moveST, &sGame](std::vector<std::string> args)
    {
        std::cout << "Moving\n";

        int originX = GetCoord(args[0][0]);
        int originY = GetCoord(args[0][1]);
        Vector2 origin{originX, originY};
        std::cout << "origin: " << origin.ToString() << '\n';

        int destX = GetCoord(args[1][0]);
        int destY = GetCoord(args[1][1]);
        Vector2 dest{destX, destY};
        std::cout << "dest: " << dest.ToString() << '\n';

        auto s = sGame.CreateScript(moveST);
        std::cout << "script: " << s << '\n';
        auto& st = sGame.GetScriptTable(s);

        st.Set("mapIndex", 0);
        st.SetDataCopy<Script::UserData::Vector2>("origin", origin);
        st.SetDataCopy<Script::UserData::Vector2>("dest", dest);

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