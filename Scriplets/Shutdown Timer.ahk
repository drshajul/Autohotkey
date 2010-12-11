/*           ,---,                                          ,--,    
           ,--.' |                                        ,--.'|    
           |  |  :                      .--.         ,--, |  | :    
  .--.--.  :  :  :                    .--,`|       ,'_ /| :  : '    
 /  /    ' :  |  |,--.  ,--.--.       |  |.   .--. |  | : |  ' |    
|  :  /`./ |  :  '   | /       \      '--`_ ,'_ /| :  . | '  | |    
|  :  ;_   |  |   /' :.--.  .-. |     ,--,'||  ' | |  . . |  | :    
 \  \    `.'  :  | | | \__\/: . .     |  | '|  | ' |  | | '  : |__  
  `----.   \  |  ' | : ," .--.; |     :  | |:  | : ;  ; | |  | '.'| 
 /  /`--'  /  :  :_:,'/  /  ,.  |   __|  : ''  :  `--'   \;  :    ; 
'--'.     /|  | ,'   ;  :   .'   \.'__/\_: |:  ,      .-./|  ,   /  
  `--'---' `--''     |  ,     .-./|   :    : `--`----'     ---`-'   
                      `--`---'     \   \  /                         
                                    `--`-'  
------------------------------------------------------------------
Shutdown Timer v1.1
Function: Shutdown after a specified interval!
  Command line parameters are also accepted, in minutes..
  eg Shutdown_timer.exe 10 5
  .. will force shutdown (code 5) in 10 minutes
URL: http://www.autohotkey.com/forum/viewtopic.php?t=48609
------------------------------------------------------------------
*/


/*  
              by Dr. Shajul


*/


;;********** Settings, Variable Declarations **********
#SingleInstance Force
#NoEnv
OnExit, quit

programName = Shutdown Timer
programVersion = 1.2
programFullName = %programName% v%programVersion%
programAuthor = Shajul


;;********** Auto-Execute Section **********
GoSub, trayMenu    ; construct tray menu : OPTIONAL
scode=5
if 0>0
   {
   tvar = %1%
   scode = %2%
   if not scode
      scode=5
   }
else
   {
   InputBox, tvar, Shutdown computer in.. (minutes),Format`:`"<Time in minutes> <[shutdown code]>`"`nEg. `"10 5`",,400,150,,,,60,10 5
   ; if cancel was pressed, return
   if errorlevel=1
     ExitApp
   IfInString, tvar, %A_Space%
      {
      StringSplit,tvar,tvar,%A_Space%
      tvar:=tvar1
      scode:=tvar2
      } 
   }

if tvar is number
  {
   shuttime := tvar
   Settimer,Shuttime,60000
   Gui, +AlwaysOnTop -Disabled -SysMenu +Owner -Caption -ToolWindow ; stay on top to prevent access whilst in pre shutdown mode.
   Gui, Font, s24 cFFFFFF
   my_x := (A_ScreenWidth/2)-100
   my_y := (A_ScreenHeight/2)-100
   Gui, Add, Button, x%my_x% y%my_y% h60 w200 gQuit Section, Cancel
   Gui, Add, Button, xs-250  y%my_y% h60 w200 gHibernate, Hibernate
   Gui, Add, Button, xs+250  y%my_y% h60 w200 gShutdown, Shutdown
   my2_y := my_y + 90
   Gui, Add, Button,  x%my_x% y%my2_y% h60 w200 gLogOff, Logoff
   Gui, Add, Button, xs-250  y%my2_y% h60 w200 gSuspend, Suspend
   Gui, Add, Button, xs+250  y%my2_y% h60 w200 gRestart, Reboot
   my3_y := my_y + 180
   Gui, Add, Checkbox,  x%my_x% y%my3_y% h60 w200 vforce center, Force?
   Gui, Font, s40 cFFFFFF
   my4_y := my_y - 100
   Gui, Add, Text, xs-200 y%my4_y% w600 vMyText, %A_Space%Shutdown in %Shuttime% minutes!
   Gui, Color, 000000                                   
   Gui, Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%, ScreenMask
   WinSet, Transparent, 200, ScreenMask
   Gosub, Shuttime
  }
else
   MsgBox, 48, Invalid Data, Please enter a valid 3-digit number!, 
return



;;********** Subroutines **********
Shuttime:
shuttime--
GuiControl,, MyText, %A_Space%Shutdown in %shuttime% minutes!
if shuttime <= 0
  {
   Shutdown,%scode%
   Settimer,Shuttime,off
  }
Return

Shutdown:
Gui, Submit, NoHide
if force
   Shutdown,5
else
   Shutdown,1
return

Hibernate:
Gui, Submit, NoHide
if force
  DllCall("PowrProf\SetSuspendState", "int", 1, "int", 1, "int", 0)
else
  DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
Return

Suspend:
Gui, Submit, NoHide
if force
  DllCall("PowrProf\SetSuspendState", "int", 0, "int", 1, "int", 0)
else
  DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
Return

Restart:
Gui, Submit, NoHide
if force
   Shutdown,6
else
   Shutdown,2
return

Logoff:
Gui, Submit, NoHide
if force
   Shutdown,4
else
   Shutdown,0
return

trayMenu:
   Menu, Tray, Tip, %programFullName%
   Menu, Tray, NoStandard
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

Quit:
ExitApp
Return