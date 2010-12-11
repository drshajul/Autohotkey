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
Function: Send mail natively
Requires: Autohotkey_L
URL: http://www.autohotkey.com/forum/viewtopic.php?t=65520
------------------------------------------------------------------
*/

#NoEnv
SetWorkingDir %A_ScriptDir%

pmsg          := ComObjCreate("CDO.Message")
pmsg.From       := """AHKUser"" <...@gmail.com>"
pmsg.To       := "anybody@somewhere.com"
pmsg.BCC       := ""   ; Blind Carbon Copy, Invisable for all, same syntax as CC
pmsg.CC       := "Somebody@somewhere.com, Other-somebody@somewhere.com"
pmsg.Subject    := "Message_Subject"

;You can use either Text or HTML body like
pmsg.TextBody    := "Message_Body"
;OR
;pmsg.HtmlBody := "<html><head><title>Hello</title></head><body><h2>Hello</h2><br /><p>Testing!</p></body></html>"


sAttach         := "Path_Of_Attachment" ; can add multiple attachments, the delimiter is |

fields := Object()
fields.smtpserver   := "smtp.gmail.com" ; specify your SMTP server
fields.smtpserverport     := 465 ; 25
fields.smtpusessl      := True ; False
fields.sendusing     := 2   ; cdoSendUsingPort
fields.smtpauthenticate     := 1   ; cdoBasic
fields.sendusername := "...@gmail.com"
fields.sendpassword := "your_password_here"
fields.smtpconnectiontimeout := 60
schema := "http://schemas.microsoft.com/cdo/configuration/"


pfld :=   pmsg.Configuration.Fields

For field,value in fields
   pfld.Item(schema . field) := value
pfld.Update()

Loop, Parse, sAttach, |, %A_Space%%A_Tab%
  pmsg.AddAttachment(A_LoopField)
pmsg.Send()