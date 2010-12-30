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
Function:
Requires: 
URL: 
------------------------------------------------------------------
*/

#NoEnv
SetWorkingDir %A_ScriptDir%

hConnect := FTP_Open("ftp.autohotkey.net", "21", "shajul", "w0nder")
hEnum := FTP_FindFirstFile(hConnect, "/COM/*", mFound)
item := FTP_GetFileInfoObj(mFound)
MsgBox % "Name : " . item.Name
 . "`nCreationTime : " . item.CreationTime
 . "`nLastAccessTime : " . item.LastAccessTime
 . "`nLastWriteTime : " . item.LastWriteTime
 . "`nSize : " . item.Size
 . "`nAttribs : " . item.Attribs
Loop
{
 FTP_FindNextFile(hEnum, mFound)
 item := FTP_GetFileInfoObj(mFound)
 MsgBox % "Name : " . item.Name
  . "`nCreationTime : " . item.CreationTime
  . "`nLastAccessTime : " . item.LastAccessTime
  . "`nLastWriteTime : " . item.LastWriteTime
  . "`nSize : " . item.Size
  . "`nAttribs : " . item.Attribs
}



#Include FTP.ahk
