; initialize and get reference to FTP object
ftp := FTP_Init()

; connect to FTP server
if !ftp.Open("ftp.autohotkey.net", "shajul", "w0nder")
  {
  MsgBox % ftp.LastError
  ExitApp
  }

; get current directory
If !ftp.SetCurrentDirectory("helloworld")
  MsgBox % ftp.LastError
  
#Include FTP.ahk