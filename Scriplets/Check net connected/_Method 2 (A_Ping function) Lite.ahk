
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

res := A_Ping("www.google.com")
msgbox returned`: %res%
#Include A_Ping_Lite.ahk