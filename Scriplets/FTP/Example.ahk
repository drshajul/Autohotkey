; initialize and get reference to FTP object
ftp := FTP_Init()

; connect to FTP server
if !ftp.Open("ftp.autohotkey.net", "myUserName", "myPassword")
  {
  MsgBox % ftp.LastError
  ExitApp
  }

; get current directory
sOrgPath := ftp.GetCurrentDirectory()
if !sOrgPath
  MsgBox % ftp.LastError

;; Error handling omitted from here on for brevity

; upload a file with progress
ftp.InternetWriteFile( A_ScriptDir . "\FTP.zip" )

; download a file with progress
ftp.InternetReadFile( "FTP.zip" , "delete_me.zip")

; delete the file
ftp.DeleteFile("FTP.zip")

; create a new directory 'testing'
if !ftp.CreateDirectory("testing")
  MsgBox % ftp.LastError

; set the current directory to 'root/testing'
ftp.SetCurrentDirectory("testing")

; upload this script file
ftp.PutFile(A_ScriptFullPath, A_ScriptName)

; rename script to 'mytestscript.ahk'
ftp.RenameFile(A_ScriptName, "MyTestScript.ahk")

; enumerate the file list from the current directory ('root/testing')
item := ftp.FindFirstFile("/testing/*")
MsgBox % "Name : " . item.Name
 . "`nCreationTime : " . item.CreationTime
 . "`nLastAccessTime : " . item.LastAccessTime
 . "`nLastWriteTime : " . item.LastWriteTime
 . "`nSize : " . item.Size
 . "`nAttribs : " . item.Attribs
Loop
{
  if !(item := FTP_FindNextFile())
    break
  MsgBox % "Name : " . item.Name
   . "`nCreationTime : " . item.CreationTime
   . "`nLastAccessTime : " . item.LastAccessTime
   . "`nLastWriteTime : " . item.LastWriteTime
   . "`nSize : " . item.Size
   . "`nAttribs : " . item.Attribs
}

; retrieve the file from the FTP server
ftp.GetFile("MyTestScript.ahk", A_ScriptDir . "\MyTestScript.ahk", 0)

; delete the file from the FTP server
ftp.DeleteFile("MyTestScript.ahk")

; set the current directory back to the root
ftp.SetCurrentDirectory(sOrgPath)

; remove the direcrtory 'testing'
ftp.RemoveDirectory("testing")

; close the FTP connection, free library
ftp.Close()

#Include FTP.ahk