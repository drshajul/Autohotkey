/*  Shutdown Timer v1.1
              by Dr. Shajul

Shutdown after a specified interval of stopping TV!
*/


;;********** Settings, Variable Declarations **********
#SingleInstance Force
#NoEnv
OnExit, quit

programName = TVShutdown
programVersion = 1.1
programFullName = %programName% v%programVersion%
programAuthor = Shajul


;;********** Auto-Execute Section **********
SetTitleMatchMode, 2
GoSub, trayMenu    ; construct tray menu : OPTIONAL
ifexist, %A_ProgramFiles%\TVR\honestechTV.exe
  RunWait, %A_ProgramFiles%\TVR\honestechTV.exe
else
  Exitapp
;WinWaitClose, TVR Screen

Shutdown:
shuttime = 59
Settimer,Shuttime,1000
Gui, +AlwaysOnTop +LastFound +Owner  ; +Owner prevents a taskbar button from appearing.
Gui, Color, white
Gui, Font, s16 Bold
Gui, Add, Text, x0 y0 w290 h25 vMyText cRed, %A_Space%Shutdown in %Shuttime% seconds!
Gui, Font, s12
Gui, Add, Text, x+2 y1 w50 h23 border gquit, %A_Space%ESC
;   WinSet, TransColor, white 200
WinSet, Transparent, 200
Gui, -Caption  ; Remove the title bar and window borders.
Gui, Show, x200 y0 w345 h25
return



;;********** Subroutines **********
Shuttime:
IfWinExist, TVR Screen
{
  Settimer,Shuttime,off
  Gui, destroy
  WinWaitClose, TVR Screen
  Goto Shutdown
  Return
  Exit
}   

shuttime--
GuiControl,, MyText, %A_Space%Shutdown in %shuttime% seconds!
if shuttime <= 0
 {
 Shutdown,1
 Settimer,Shuttime,off
 }
return

trayMenu:
   Menu, Tray, Tip, %programFullName%
   Menu, Tray, NoStandard
   Menu, Tray, Icon, %A_WinDir%/system32/shell32.dll,28
   Menu, Tray, Add, &About, about
   Menu, Tray, Add
   Menu, Tray, Add, &Quit, quit
Return

about:
   MsgBox, 64, %programFullName%,
   ( LTrim
      %programFullName%
      %A_Space%by %programAuthor%

      Shutdown after a specified interval!
   )
Return

quit:
ExitApp
Return
