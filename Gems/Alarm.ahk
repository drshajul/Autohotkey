#Persistent
#SingleInstance ignore
#NoEnv


Gui, Add, DateTime, x6 y32 w110 h20 vMyDateTime, Time
Gui, Add, Button, x116 y32 w40 h20 gSetAlarm, &Ok
Gui, Add, Button, x156 y32 w50 h20 gResetAlarm, &Reset
Gui, Add, Text, x6 y12 w200 h20 , Alarm Time:
Gui, Show, Center h64 w215, Alarm
Return

GuiClose:
ExitApp

SetAlarm:
Gui, Submit
AlarmTime:=SubStr(MyDateTime, 9, 4 )
Settimer, Maintimer, 15000
return

ResetAlarm:
Settimer, Maintimer, Off
return

Maintimer:
FormatTime,thistime,,HHmm
If thistime=%AlarmTime%
  Run alarm.mp3
Return
