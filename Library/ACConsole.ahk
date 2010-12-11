; AutoHotkey Command Console - by Titan

SetBatchLines, -1
#SingleInstance ignore
title = AutoHotkey Command Console
instr = `; Enter commands here and press F5 to execute. For context based help press F1.
file = %temp%\~acc.tmp
RegRead, help, HKLM, SOFTWARE\AutoHotkey, InstallDir
help = %help%\AutoHotkey.chm
helpt = AutoHotkey Help
SetKeyDelay, -1
Menu, Tray, NoStandard
Menu, Tray, Add, &AutoHotkey Command Console, Show
Menu, Tray, Default, &AutoHotkey Command Console
Menu, Tray, Add, &Command Reference, Help
Menu, Tray, Add, &Forum, Forum
Menu, Tray, Add
Menu, Tray, Add, E&xit, Exit
Menu, Tray, Click, 1
Menu, Tray, Tip, %title%
Gui, +Resize
Gui, Color, black, black
Gui, Font, cWhite s9, Courier New
Gui, Add, Edit, vConsole x-1 y-1 w652 h352, %instr%`n`n
Gui, Show, w650 h350, %title%
Gui, +LastFound
ControlSend, Edit1, ^{End}
Return

GuiSize:
If A_EventInfo = 1
	Goto, Hide
GuiControl, Move, Console, % "w" A_GuiWidth+2 "h" A_GuiHeight+2
Return

~*F5::
Gui, +LastFound
If !WinActive()
	Return
Gui, Submit, NoHide
FileDelete, %file%
FileAppend, %Console%, %file%
GuiControl, , Console, %instr%`n`; Last execution: %A_Now%`n`n
Gui, +LastFound
ControlSend, Edit1, ^{End}
If !FileExist(A_AhkPath)
	die("AutoHotkey.exe was not found")
Run, %A_AhkPath% %file%, %A_MyDocuments%
Return

~*F1::
Gui, +LastFound
If !WinActive()
	Return
clipx := clipboard
Gui, +LastFound
ControlSend, Edit1, ^{Right}^+{Left}^c{Right}
word = %clipboard%
clipboard := clipx
StringReplace, word, word, `r, , 1
StringReplace, word, word, `n, , 1
If !word
	Return
Gosub, Help
WinWait, %helpt%
WinActivate, %helpt%
WinWaitActive, %helpt%
ControlSend, , !n, %helpt%
ControlSetText, Edit1, %word%, %helpt%
SetKeyDelay, 100, 100
ControlSend, Edit1, {Home}{Enter}{Enter}{Enter}, %helpt%
SetKeyDelay, -1
Return

die(txt) {
	MsgBox, 16, Error, Error response: %txt%`nProgram will terminate.
	ExitApp
}

Help:
If !FileExist(help)
	die("AutoHotkey.chm was not found")
Run, %help%
Return
Forum:
Run, http://www.autohotkey.com/forum/
Return
Show:
Gui, Show
Return
Hide:
Gui, Hide
Return
GuiClose:
Exit:
ExitApp
