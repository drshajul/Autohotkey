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
 This sample schedules a task to start notepad.exe 30 seconds
 after windows boot with highest privileges!.
 Requires AutoHotkey_L
------------------------------------------------------------------
*/

#NoEnv
SetWorkingDir %A_ScriptDir%

Gosub RunAsAdministrator

TriggerType = 8   ; trigger on boot.
ActionTypeExec = 0  ; specifies an executable action.
TaskCreateOrUpdate = 6 
Task_Runlevel_Highest = 1 

strUser := "Domain\Username" 
strPassword := "yourpassword" 

objService := ComObjCreate("Schedule.Service") 
objService.Connect() 

objFolder := objService.GetFolder("\") 
objTaskDefinition := objService.NewTask(0) 

principal := objTaskDefinition.Principal 
principal.LogonType := 1    ; Set the logon type to TASK_LOGON_PASSWORD 
principal.RunLevel := Task_Runlevel_Highest  ; Tasks will be run with the highest privileges. 

colTasks := objTaskDefinition.Triggers 
objTrigger := colTasks.Create(TriggerType) 
objTrigger.StartBoundary := "2011-05-27T08:00:00-00:00" 
objTrigger.ExecutionTimeLimit := "PT5M"    ;Five minutes 
colActions := objTaskDefinition.Actions 
objAction := colActions.Create(ActionTypeExec) 
objAction.ID := "Boot Task Test" 
objAction.Path := "C:\Windows\System32\notepad.exe" 
objAction.WorkingDirectory := "C:\Windows\System32" 
objAction.Arguments := "" 
objInfo := objTaskDefinition.RegistrationInfo 
objInfo.Author := "shajul" 
objInfo.Description := "Test task on every boot." 
objSettings := objTaskDefinition.Settings 
objSettings.Enabled := True 
objSettings.Hidden := False 
objSettings.StartWhenAvailable := True 
objFolder.RegisterTaskDefinition("Test Boot Trigger", objTaskDefinition, TaskCreateOrUpdate , strUser, strPassword, 1 )
MsgBox Task Created
ExitApp

RunAsAdministrator:
ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"
if not A_IsAdmin
{
    If A_IsCompiled
       DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
    Else
       DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
    ExitApp
}
return