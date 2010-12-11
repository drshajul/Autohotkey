; Language:       English
; Platform:       Win9x/NT
; Author:         Dr. Shajul <mail@shajul.net>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/* 
Hibernate:
Hibernate=1
gosub WakeUp
Return

Standby:
MsgBox, 4,DataOne Manager Standby, Standby and wake at 2`:01 AM`n`nDo you really want to continue? (Press YES or NO)
IfMsgBox No
  Return
Hibernate=2
gosub WakeUp
Return
 */
WakeUp:
Hibernate=1
if A_Hour > 8    ; After 8 o'clock in the morning..
 {
  var1=
  var1 += 1, Days  ; next day
 }
Else
  var1 := A_Now
FormatTime, hYear, %var1%, yyyy
FormatTime, hMth, %var1%, M
FormatTime, hDay, %var1%, d
hHour = 2
hMin = 1
WakeUp(hYear, hMth, hDay, hHour, hMin, Hibernate, 1, A_Now)
return


;///////////////////////////
;BOSKNOP's CODE
;http://www.autohotkey.com/forum/topic11620.html
WakeUp(Year, Month, Day, Hour, Minute, Hibernate, Resume, Name)
;Awaits duetime, then returns to the caller (like some sort of "sleep until duetime").
;If the computer is in hibernate or suspend mode
;at duetime, it will be reactivated (hardware support provided)
;Parameters: Year, Month, Day, Hour, Minute together produce duetime
;Hibernate: If Hibernate=1, the function hibernates the computer. If Hibernate=2 the computer is set to
;         suspend-mode
;Resume: If Resume=1, the system is restored from power save mode at due time
;Name: Arbitrary name for the timer
{
    duetime:=GetUTCFileTime(Year, Month, Day, Hour, Minute)

    Handle:=DLLCall("CreateWaitableTimer"
            ,"char *", 0
            ,"Int",0
            ,"Str",name, "UInt")

    DLLCall("CancelWaitableTimer","UInt",handle)

    DLLCall("SetWaitableTimer"
          ,"Uint", handle
          ,"Int64*", duetime        ;duetime must be in UTC-file-time format!
          ,"Int", 1000
          ,"uint",0
          ,"uint",0
          ,"int",resume)
   

    ;Hibernates the computer, depending on variable "Hibernate":
    If Hibernate=1       ;Hibernate
        {
        DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
        }
       
    If Hibernate=2      ;Suspend
       {
       DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
       }
    Signal:=DLLCall("WaitForSingleObject"
            ,"Uint", handle
            ,"Uint",-1)
           
    DllCall("CloseHandle", uint, Handle)   ;Closes the handle
   
}   


GetUTCFiletime(Year, Month, Day, Hour, Min)
;Converts "System Time" (readable time format) to "UTC File Time" (number of 100-nanosecond intervals since January 1, 1601 in  Coordinated Universal Time UTC)
{
    DayOfWeek=0

    Second=00
    Millisecond=00
   

    ;Converts System Time to Local File Time:
    VarSetCapacity(MyFiletime  , 64, 0)
    VarSetCapacity(MySystemtime, 32, 0)
   
    InsertInteger(Year,       MySystemtime,0)
    InsertInteger(Month,      MySystemtime,2)
    InsertInteger(DayOfWeek,  MySystemtime,4)
    InsertInteger(Day,        MySystemtime,6)
    InsertInteger(Hour,       MySystemtime,8)
    InsertInteger(Min,        MySystemtime,10)
    InsertInteger(Second,     MySystemtime,12)
    InsertInteger(Millisecond,MySystemtime,14)

    DllCall("SystemTimeToFileTime", Str, MySystemtime, UInt, &MyFiletime)
    LocalFiletime := ExtractInteger(MyFiletime, 0, false, 8)

    ;Converts local file time to a file time based on the Coordinated Universal Time (UTC):
    VarSetCapacity(MyUTCFiletime  , 64, 0)
    DllCall("LocalFileTimeToFileTime", Str, MyFiletime, UInt, &MyUTCFiletime)
    UTCFiletime := ExtractInteger(MyUTCFiletime, 0, false, 8)
   
    Return UTCFileTime
}


ExtractInteger(ByRef pSource, pOffset = 0, pIsSigned = false, pSize = 32)
; Documented in Autohotkey Help
{
    Loop %pSize%
        result += *(&pSource + pOffset + A_Index-1) << 8*(A_Index-1)
    if (!pIsSigned OR pSize > 4 OR result < 0x80000000)
        return result
    return -(0xFFFFFFFF - result + 1)
}



InsertInteger(pInteger, ByRef pDest, pOffset = 0, pSize = 4)
; Documentated in Autohotkey Help
{
  Loop %pSize%
          DllCall("RtlFillMemory", UInt, &pDest + pOffset + A_Index-1
                  , UInt, 1, UChar, pInteger >> 8*(A_Index-1) & 0xFF)
}

Return
