; Author:  DrShajul <drshajul@gmail.com>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2
IfWinExist,Upload Manager
	myid := WinExist("Upload Manager")
SetTimer, Check, 10000
gosub Check
return

Check:
oldtitle:=mytitle
WinGetTitle, mytitle, ahk_id %myid%
IfInString,mytitle,Completed
	gosub Shutdown
return

Shutdown:
Run,"%A_AHKPath%" %A_ScriptDir%\Shutdown_timer.ahk 5 5
ExitApp

