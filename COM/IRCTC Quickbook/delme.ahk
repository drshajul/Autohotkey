#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
tvar := "https://www.irctc.co.in/cgi-bin/bv60.dll/irctc/booking/planner.do?screen=fromlogin&BV_SessionID=@@@@0541065106.1293815701@@@@&BV_EngineID=ccddademgkjghjecefecehidfgmdfhm.0"

RegExMatch(tvar,"BV_SessionID.+$",sID)
StringReplace,sID,sID,&,&amp`;
MsgBox % sID

