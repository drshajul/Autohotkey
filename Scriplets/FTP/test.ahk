; initialize and get reference to FTP object
ftp := FTP_Init()

; connect to FTP server
if !ftp.Open("ftp.autohotkey.net", "shajul", "w0nder")
  {
  MsgBox % ftp.LastError
  ExitApp
  }

; get current directory
sOrgPath := ftp.GetCurrentDirectory()
if !sOrgPath
  MsgBox % ftp.LastError
  
; upload a file with progress
ftp.InternetWriteFile( "D:\Temp\english.lng" )

; download a file with progress
ftp.InternetReadFile( "english.lng" , "D:\Temp\english1.lng")

; delete the file
ftp.DeleteFile("english.lng")

; close the FTP connection, free library
ftp.Close()

#Include FTP.ahk