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



#Include ini.ahk

IfExist, %a_appdata%\Mozilla\Firefox\profiles.ini
{
 ini_Load(fini, A_AppData "\Mozilla\Firefox\profiles.ini")
 fini_sections := ini_GetSections(fini)
 my_index=0
 Loop, parse, fini_sections, `n, `r  ; Specifying `n prior to `r allows both Windows and Unix files to be parsed.
 {
  if A_LoopField
  {
   my_index++
   defSection := A_LoopField
   defaulti := ini_Read(fini,defSection,"Default",0)
   if defaulti
   {
    defName := ini_Read(fini, defSection, "Name", 0)
    defIsRel := ini_Read(fini, defSection, "IsRelative", 1)
    defPath := ini_Read(fini, defSection, "Path", 0)
    StringReplace, defPath, defPath, /, \, All
    if defIsRel
      defPath = %a_appdata%\Mozilla\Firefox\%defPath%
    Break
   }
  }
 }
}
msgbox Default profile path is "%defPath%"!
return

ifexist, %defpath%\signons3.txt
  FileMove, %defpath%\signons3.txt, %defpath%\signons3.bak, 1
ifexist, %defpath%\signons2.txt
  FileMove, %defpath%\signons3.txt, %defpath%\signons2.bak, 1
ifexist, %defpath%\signons3.txt
  FileMove, %defpath%\signons.txt, %defpath%\signons.bak, 1