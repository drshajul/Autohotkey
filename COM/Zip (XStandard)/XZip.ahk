#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
objZip := ComObjCreate("XStandard.Zip")
objContents := objZip.Contents(A_ScriptDir . "\test.zip")._NewEnum
While objContents[objItem]
	Msgbox % objItem.Path . objItem.Name . "`n"