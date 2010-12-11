stime := A_Now
msgbox % "Return code`: " . CheckStatus() . "`nTime taken`: " . A_Now-sTime . " seconds`n`nReturn codes`:`n -2 - Disconnected`n -1 - Not reachable`n  0 - Connected and reachable"



CheckStatus(URL="www.google.com")
{
if (!DllCall("Wininet.dll\InternetGetConnectedState", "Str", 0x40,"Int",0))
  return -2   ; Not connected
RunWait, ping.exe %URL% -n 1,,hide UseErrorlevel
if !ErrorLevel
  return 0    ; Connected and reachable
Else
  return -1   ; Not reachable
}