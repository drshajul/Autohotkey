; Script Function:
;   Along with Autoruns program, this little script will give a quick list of programs 
;   that have been disabled with Autoruns (in a tray menu), so that they can be selected

; Author:         Dr. Shajul <mail@shajul.net>

;; ----- Disable Services List
;DisableServices=VMware DHCP Service|VMware NAT Service|VMware Authorization Service


#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
params := ""
if 0>0
{
	Loop, %0%  ; For each parameter:
	{
		param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
		params .= A_Space . param
	}
}
If A_IsCompiled
{
	if not A_IsAdmin
	{
	   DllCall("shell32\ShellExecuteA", uint, 0, str, "RunAs", str, A_ScriptFullPath
		  , str, params , str, A_WorkingDir, int, 1)
	   ExitApp
	}
}
Else
{
	if not A_IsAdmin
	{
	   DllCall("shell32\ShellExecuteA", uint, 0, str, "RunAs", str, A_AhkPath
		  , str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
	   ExitApp
	}
}

;Move Common disabled items to users disabled items..
Loop, %A_StartMenuCommon%\Programs\Startup\AutorunsDisabled\*.*
	FileMove,%A_LoopFileLongPath%,%A_StartMenu%\Programs\Startup\AutorunsDisabled\%A_LoopfileName%,1
	
;Move HKCU Run disabled items to users disabled items..
Loop, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled
{
	RegRead, OutputVar
	If OutputVar
	{
	SplitPath,OutputVar,,OutDir
	FileCreateShortcut,%OutputVar%,%A_StartMenu%\Programs\Startup\AutorunsDisabled\%A_LoopRegName%.lnk,%OutDir%
	RegDelete
	OutputVar=
	}
}	

;Move HKLM Run disabled items to users disabled items..
Loop, HKEY_LOCAL_MACHINE, Software\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled
{
	RegRead, OutputVar
	If OutputVar
	{
	SplitPath,OutputVar,,OutDir
	FileCreateShortcut,%OutputVar%,%A_StartMenu%\Programs\Startup\AutorunsDisabled\%A_LoopRegName%.lnk,%OutDir%
	RegDelete
	OutputVar=
	}
}	

;Display those items as a tray menu..
Run,%A_StartMenu%\Programs\Startup\AutorunsDisabled\_links.ahk,%A_StartMenu%\Programs\Startup\AutorunsDisabled

;Disable Services that are not required.. (another script to start them must be used when neccesary)
/*  
; Not working at present 
Loop, Parse, DisableServices,|
{
myvar := A_LoopField
if Service_State(myvar)=4 ;if service is running	
	Service_Stop(myvar) ;stop	
}

ExitApp
Return

#Include Service.ahk
*/