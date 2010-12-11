; Language:       English
; Platform:       Win9x/NT
; Author:         Dr. Shajul <mail@shajul.net>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;
#SingleInstance, force
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
BlockInput On
SendMessage, 0x112, 0xF170, 2,, Program Manager
Sleep 60000
BlockInput Off
return