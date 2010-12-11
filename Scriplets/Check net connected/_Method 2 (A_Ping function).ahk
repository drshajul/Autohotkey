
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

res := A_Ping("www.google.com","AHK Ping",1000)
;res := A_Ping("100.100.1.1")   ;hypothetical ip to test..
msgbox returned`: %res%`nErrorlevel`: %errorlevel%
;#Include A_Ping.ahk
#Include A_Ping.ahk