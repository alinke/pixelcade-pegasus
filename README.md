# Pixelcade Marquee Integration with Pegasus
Source code and scripts for the Pixelcade Arcade Marquee integration with the Pegasus Arcade Front End. Pixelcade is a line of LED and LCD based active marquees for arcade machines http://pixelcade.org. Pegasus is a cross platform based arcade front end https://pegasus-frontend.org/

## Installation Instructions

Install the Pixelcade Software for Windows on your Windows arcade machine https://pixelcade.org/download-pc/

For Windows: copy the scripts to and note that you'll need to manually create the scripts folder

* C:\Users\[username]\AppData\Local\pegasus-frontend\scripts\game-start\pixelcade-pegasus-game-start.exe
* C:\Users\[username]\AppData\Local\pegasus-frontend\scripts\quit\pixelcade-quit.exe

Other Platforms (Pi, etc.): can add if demand

Pixelcade will update when you launch a game.

IMPORTANT: For this to work, you must have your roms organized in folders by platform name (ex. put all Atari 2600 roms in atari2600, all Nintendo Entertain System in nes, all arcade in mame, etc.). And be sure and match these platform / console names specifically https://github.com/alinke/pixelcade

Ensure that the Pixelcade Listener is running before launching Pegasus and note that if the Pixelcade Listener is not running, EmulationStation will be slower as the Pixelcade Scripts will be making API calls to the Pixelcade Listener which will time out and slow down performance.

## Customizing

After the first game launch, a configuration file called pixelcade-settings.ini will be created in c:\users\<your windows username>\pixelcade\pixelcade-settings.ini. You can change the settings as noted below to customize Pixelcade's behavior.

You can further customize by modifying the source code of the scripts which are written in Auto Hot Key (Pegasus on Windows) and then using the Pixelcade API http://pixelcade.org/api to add additional functionality

; Pixelcade Config File

[PIXELCADE SETTINGS]

; if set to 1, pixelcade-log.log will be written to c:\users\your username\pixelcade\pixelcade-log.log. Note that only Game Start events will write to this log file. Game and console scrolling (game-selected and system-selected) will not write to this log file.
; this log file will be over-written on each game start call and will not append

LOGGING=0

; if set to 1, "Now Playing < Game Title >" will scroll before the game marquee is displayed upon a game launch. If set to 0, just the game marquee will be displayed with no scrolling text

GAME_START_TEXT=1

;cycle mode means continually cycle between the game marquee and now playing text. If set to no, then the now playing text will only display on game launch and then display the game marquee. Cycle mode is not applicable if GAME_START_TEXT=0

CYCLEMODE=0

; If GAME_START_TEXT=1, you can change the "Now Playing" default scrolling text to something else

NOW_PLAYING_TEXT=Now Playing

;if in cycle mode, the number of times an animated marquee will loop before cycling back to scrolling text. This has no effect if it's a still image / non-animated game marquee

NUMBER_MARQUEE_LOOPS=1

;Scroll this text when EmulationStation quits, you can customize to whatever you'd like to say here

EXIT_MESSAGE=Thanks for Playing
