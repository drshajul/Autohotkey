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
Function: Run script with parameters (context menu)
Requires: 
URL: 
------------------------------------------------------------------
*/

#NoEnv
SetWorkingDir %A_ScriptDir%
if 0>0
 appl = %1%
else
 ExitApp
Gui, Add, Text, x2 y0 w300 h16 , Kindly enter parameters to be passed to the script..
Gui, Add, Edit, x2 y16 w430 h20 vparams,
Gui, Add, Button, x432 y16 w30 h20 gGo, &Ok
Gui, +Toolwindow +AlwaysOnTop
Gui, Show, w464 h40, Run with parameters
Return

Go:
Gui, Submit
Run, %appl% %params%

GuiClose:
ExitApp
 