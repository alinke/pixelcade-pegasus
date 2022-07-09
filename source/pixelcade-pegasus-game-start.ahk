#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; game-start gets 3 parameters
; param #1: full path with game name (but note this can have spaces and turn into multiple params)
; param #2: rom name
; param #3: game title

; logic if params is 3, then we're good
; parse the first param to get platform and use the 2nd to last param to get the rom name

Global PixelcadeLogPath ; if this is not here, the function won't work
Global console
Global game
Global gameTitle
Global oWhr
Global LoggingINI

;*************************************************
 ;change these in c:\users\username\pixelcade\pixelcade-settings.ini 
 ; 0 = off and 1 = on
LoggingINI := 0 
Game_Start_TextINI := 1
CycleModeINI := 0
NowPlayingTextINI := Now Playing
NumberMarqueeLoopsINI := 1
; Note high scores are implemeneted at this time
;HighScoresINI := 0
;HI2TXT_JAR=${INSTALLPATH}pixelcade/hi2txt/hi2txt.jar ;hi2txt.jar AND hi2txt.zip must be in this folder, the Pixelcade installer puts them here by default
;HI2TXT_DATA=${INSTALLPATH}pixelcade/hi2txt/hi2txt.zip
;*************************************************

EnvGet, hdrive, Homedrive
EnvGet, hpath, Homepath
PixelcadeRetroBatFolder := hdrive hpath "\pixelcade"
FileCreateDir, %PixelcadeRetroBatFolder% ;only creates if it doesn't already exist in c:\users\username\RetroBatPixelcade
PixelcadeLogPath := PixelcadeRetroBatFolder . "\pixelcade-log.log"
PixelcadeSettingsPath := PixelcadeRetroBatFolder . "\pixelcade-settings.ini"
if FileExist(PixelcadeSettingsPath) {
	IniRead, LoggingINI, %PixelcadeSettingsPath%, PIXELCADE SETTINGS, LOGGING
	IniRead, Game_Start_TextINI, %PixelcadeSettingsPath%, PIXELCADE SETTINGS, GAME_START_TEXT
	IniRead, CycleModeINI, %PixelcadeSettingsPath%, PIXELCADE SETTINGS, CYCLEMODE
	IniRead, NowPlayingTextINI, %PixelcadeSettingsPath%, PIXELCADE SETTINGS, NOW_PLAYING_TEXT
	IniRead, NumberMarqueeLoopsINI, %PixelcadeSettingsPath%, PIXELCADE SETTINGS, NUMBER_MARQUEE_LOOPS
}
else { ;let's create it
	FileAppend,
	(
; Pixelcade for RetroBat Config File
[PIXELCADE SETTINGS]

; if set to 1, pixelcade-log.log will be written to c:\users\your username\RetroBatPixelcade\pixelcade-log.log. Note that only Game Start events will write to this log file. Game and console scrolling (game-selected and system-selected) will not write to this log file.
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
	), %PixelcadeSettingsPath%
}	


;Get Arguments as an array
if 0 > 0
{
	argc=%0%
	args:=[]
	Loop, %argc% {
		args.Insert(%A_Index%)
		;MsgBox, % args[A_Index] ; print the command line params
		}
}
else
{
	; if got no arguments
	if LoggingINI
			WriteLog("No Command Line Args, exiting...")
	ExitApp
}

length:=args.length()

; c:\retrobat\roms\arcade\1942.zip
; c:\retroat\roms\atari2600\3D
; so get the string before the last backslash

;C:/roms/atari2600/Acid Drop (Europe).a26

if (length > 0) {  ; do we have enough args, need at least 2
	ConsoleFullString:=args[1]
	StringReplace, ConsoleFullStringMod, ConsoleFullString, /, \, All ; had to add this because we're getting c:/retrobat/roms/ vs. c:\retrobat\roms
	StringSplit, pathArray, ConsoleFullStringMod, \
	i2 := pathArray0 - 1
	console := pathArray%i2% ;second to last in the path

	game := args[length] ; rom name is the second to last in the args array but we need to strip out event code from here
	
	gameTitle := args[length] ; game title is the last item in the args array
	; let's remove the (USA), (EUROPE) ,etc. from the title string if it's there
	StringGetPos, pos, gameTitle, (
	if (pos >= 0) {
		gameTitle := SubStr(gameTitle, 1, pos)
	}
	
	; TO DO add high scores 
	
	if Game_Start_TextINI {
		 if  CycleModeINI {
			url := "http://127.0.0.1:8080/text?t=" . NowPlayingTextINI . " " . gameTitle . "&loop=" . NumberMarqueeLoopsINI . "&game=" . game . "&system=" console . "&cycle" . "&event=GameStart"
		 }
		 else {
			 url := "http://127.0.0.1:8080/text?t=" . NowPlayingTextINI . " " . gameTitle . "&loop=" . NumberMarqueeLoopsINI . "&game=" . game . "&system=" console . "&event=GameStart"
		 }
		 sendRESTCall(url)
		 url := "http://127.0.0.1:8080/arcade/stream/" . console . "/" . game . "?loop=99999&event=GameStart"
		 sendRESTCall(url)
	}
	else {
		url := "http://127.0.0.1:8080/arcade/stream/" . console . "/" . game . "?event=GameStart"
		sendRESTCall(url)
	}
}
else 
{
	if LoggingINI
			WriteLog("Command Line Args is less than 3, exiting...")
	ExitApp
}

WriteLog(msg) {
	FileDelete, %PixelcadeLogPath%
	FileAppend, % A_NowUTC ": " msg "`n", %PixelcadeLogPath%
}

sendRESTCall(url) {
	try {
			oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			oWhr.Open("GET", url, false)
			oWhr.Send()
			if LoggingINI
				WriteLog("Successful API Call: " url)
		} catch e {
			if LoggingINI
				WriteLog("Failed API Call: " url)
		}
}



