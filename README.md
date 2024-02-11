This is a really basic game to play with your viewers on twitch / keep the chat entertained while you're gone!

--

# SETUP

Go to https://dev.twitch.tv/ and login. 
Register an Application in the Application section.
Name the application and get a Client ID.
Run the game for the first time to generate "setup.cfg" in the folder the .exe is in (this must stay in the same folder as the .exe file)
Update the setup.cfg with your client ID, channel name, and a name for the bot (anything works here)
Run again and confirm authorisation from twitch to the app!

--

# Viewer Commands (shown in game):

!join - Join the game, also starts the round if the round hasn't started yet

!leave - Leave the game

!move <direction> - Move in the specified direction, options are up/down/left/right e.g. "!move right"

!levelup <stat> - Levelups grant a level up token that you can spend on your health or damage stat e.g. "!levelup damage"

--

# Configuration

The generated setup.cfg file also contains:

The settings from step 5

A refresh speed for the rounds which only allows values 0->4. 0 = 2 second refresh, 1 = 5 sec, 2 =10 sec, 3 = 15 sec, 4 = 30 sec (default)

A bots delay which determines how many turns pass before a bot is spawned. Only allows values 0->4. 0 = 2 turn delay between spawn, 2 = 3 turns, 2 = 5 turns, 3 = 7 turns (default), 4 = 10 turns.

A chatter health - This is used as a starting max health value for the chatters.

A bot health - This is used as a starting max health value for the bots.

A chatter damage - This is used as the starting damage for the chatters. Damage is limited to 100 by levelups.

A bot damage - This is used as the starting damage for the players. Damage is limited to 100 by levelups.

Press "#" in game to open a debug menu to change these settings temporarily for testing, does NOT save the settings



*Made in godot.*
