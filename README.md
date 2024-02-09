# Twitch Stick Figure Game
This is a really basic game to play with your viewers on twitch / keep the chat entertained while you're gone!

SETUP: 

Go to https://dev.twitch.tv/ and login. 
Register an Application in the Application section.
Name the application and get a Client ID.
Run the game for the first time to generate "setup.cfg" in the folder the .exe is in (this must stay in the same folder as the .exe file)
Update the setup.cfg with your client ID, channel name, and a name for the bot (anything works here)
Run again and confirm authorisation from twitch to the app!
setup.cfg contains a refreshspeed which only allows values 0->4. 0 = 2 second refresh, 1 = 5 sec, 2 =10 sec, 3 = 15 sec, 4 = 30 sec (default)

Built application available [here](https://starkandco.itch.io/twitch-stick-figure-game)

"#" in game to open a debug menu to change the settings/try adding a player (they don't move tho so..)

Viewer commands (shown in game):

!join - Join the game, also starts the round if the round hasn't started yet

!leave - Leave the game

!move <direction> - Move in the specified direction, options are up/down/left/right e.g. "!move right"

!levelup <stat> - Levelups grant a level up token that you can spend on your health or damage stat e.g. "!levelup damage"
