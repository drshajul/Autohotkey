;==================================================================================================================================
;			There are no settings to Modify In This script
;			All user defined settings are located in MiniFTP_Settings.ini 
;==================================================================================================================================
;#NoTrayIcon
#NoEnv
SetBatchLines -1
SetWinDelay, 0
OnExit, GuiClose
;==================================================================================================================================
MiniFTP_DefaultServer 		:= GetDefault("DefaultServer", "Servers")
MiniFTP_DefaultPort 		:= GetDefault("DefaultPort", "Servers")
MiniFTP_DefaultUserName 	:= GetDefault("DefaultUserName", "Servers")
MiniFTP_DefaultPassword 	:= GetDefault("DefaultPassword", "Servers")
MiniFTP_AppTitle 			:= GetDefault("AppTitle")
MiniFTP_TOOLBAR_ICONSIZE 	:= GetDefault("ToolBarIconSize")
MiniFTP_ToolTipDelay 		:= GetDefault("ToolTipDelay")
MiniFTP_ToolTip_ShowProps 	:= GetDefault("ToolTip_FileShowProps")
MiniFTP_AutoConnect 		:= GetDefault("AutoConnect")
MiniFTP_ToolTip_AllProps 	= Name|Size|Attrib|CreationTime|LastAccessTime|LastWriteTime|Path
MiniFTP_ToolTipShowing		= 0
;==================================================================================================================================

;Install Toolbar Icons
IfNotExist %A_Temp%\add.ico
	FileInstall, Add.ico, %A_Temp%\add.ico
IfNotExist %A_Temp%\file.ico
	FileInstall, file.ico, %A_Temp%\file.ico
IfNotExist %A_Temp%\refresh.ico
	FileInstall, refresh.ico, %A_Temp%\refresh.ico
IfNotExist %A_Temp%\tools.ico
	FileInstall, tools.ico, %A_Temp%\tools.ico
IfNotExist %A_Temp%\check.ico
	FileInstall, check.ico, %A_Temp%\check.ico
IfNotExist %A_Temp%\Connect.ico
	FileInstall, Connect.ico, %A_Temp%\Connect.ico

Menu, Tray, Icon, Connect.ico
;==================================================================================================================================
Menu, MiniFTP_FileOptions, Add, Delete File, MiniFTP_DeleteFile
Menu, MiniFTP_FileOptions, Add, Rename File, MiniFTP_RenameFile

Gui, 1:+LastFound +Resize +0x2000000 +MinSize660x292 ; WS_CLIPCHILDREN

;Add The Toolbar
MiniFTP_hToolBar := TB_Init(MiniFTP_hGui := WinExist(),0,0,(MiniFTP_TOOLBAR_ICONSIZE + 10),800)
GroupAdd, Self, ahk_id %MiniFTP_hGui%
;Upload
TB_AddButton(MiniFTP_hToolBar,A_Temp . "\Add.ico","Upload","MiniFTP_UploadFile",MiniFTP_TOOLBAR_ICONSIZE,MiniFTP_TOOLBAR_ICONSIZE)
;Download
TB_AddButton(MiniFTP_hToolBar,A_Temp . "\File.ico","Download","MiniFTP_DownloadFile",MiniFTP_TOOLBAR_ICONSIZE,MiniFTP_TOOLBAR_ICONSIZE)
;Refresh
TB_AddButton(MiniFTP_hToolBar,A_Temp . "\Refresh.ico","Refresh","MiniFTP_UpdateFiles",MiniFTP_TOOLBAR_ICONSIZE,MiniFTP_TOOLBAR_ICONSIZE)
;File Options
TB_AddButton(MiniFTP_hToolBar,A_Temp . "\Tools.ico","File Options","MiniFTP_FileOptions",MiniFTP_TOOLBAR_ICONSIZE,MiniFTP_TOOLBAR_ICONSIZE)
;Settings
TB_AddButton(MiniFTP_hToolBar,A_Temp . "\Check.ico","Settings","",MiniFTP_TOOLBAR_ICONSIZE,MiniFTP_TOOLBAR_ICONSIZE)
;Create Image List for the Treeview
MiniFTP_ImageListID := IL_Create()

;Only add the "Folder" Icon
IL_Add(MiniFTP_ImageListID,"shell32.dll", 4)

; Gui 2 is inside the rebar (Connect to Gui)
Gui, 2:+ToolWindow -Caption +LastFound
Gui, 2:Add, ComboBox, 	w160 h20 r5 vMiniFTP_Server hwndMiniFTP_hEdit_Server, %MiniFTP_DefaultServer%||
Gui, 2:Add, Text, 		ym w30 h20 , Port:
Gui, 2:Add, Edit, 		ym w30 h20 vMiniFTP_Port hwndMiniFTP_hEdit_Port, %MiniFTP_DefaultPort%
Gui, 2:Add, Text, 		ym w40 h20 , UserID:
Gui, 2:Add, Edit, 		ym w80 h20 vMiniFTP_UserID hwndMiniFTP_hEdit_UserID, %MiniFTP_DefaultUserName%
Gui, 2:Add, Text, 		ym w30 h20 , Pass:
Gui, 2:Add, Edit, 		ym w80 h20 vMiniFTP_Password +Password hwndMiniFTP_hEdit_Password, %MiniFTP_DefaultPassword%
Gui, 2:Add, Button, 	ym w40 h20 gMiniFTP_Connect +Default, Go
Gui, 2:-0x80000000 ; WS_POPUP := 0x80000000
Gui, 2:+0x40000000 ; WS_CHILD := 0x40000000
Gui, 2:Show
MiniFTP_hGui2 := WinExist()
MiniFTP_hRebar := Rebar_Add(MiniFTP_hGui, MiniFTP_hGui2, "Connection", 0, 40, 990, 100)
Rebar_Add(MiniFTP_hGui, MiniFTP_hToolBar, "Tools", 1)
WinGetPos,,,,Rebarh,ahk_id %MiniFTP_hRebar%
yOffset += Rebarh + 5
Gui, 1:Add, TreeView, x10 y%yOffset% h200 w150 vMiniFTP_ServerDir hwndMiniFTP_hFileDir ImageList%MiniFTP_ImageListID% gMiniFTP_ChangeServerDir -TabStop +AltSubmit
Gui, 1:Add, ListView, x170 y%yOffset% w480 h200 gFileSelect AltSubmit vMiniFTP_ServerList hwndMiniFTP_hFileList -TabStop, File Name | Size | -
Gui, 1:Add, StatusBar,, Not Connected
Gui, 1:Show, y35, %MiniFTP_AppTitle%
; For MiniFTP_AutoConnect
If (MiniFTP_AutoConnect) && (MiniFTP_Server := MiniFTP_DefaultServer ) && (MiniFTP_Password := MiniFTP_DefaultPassword) && (MiniFTP_UserID := MiniFTP_DefaultUserName) && (MiniFTP_Port := MiniFTP_DefaultPort)
	SetTimer, MiniFTP_Connect, -10
Return
;==================================================================================================================================
KillTT:
ToolTip
MiniFTP_ToolTipShowing		= 0
Return
;==================================================================================================================================
GetDefault(pKey,pSection="Settings"){
	Return IniRead("MiniFTP_Settings.ini",pSection,pKey)
	}
;==================================================================================================================================
IniRead(pFile,pSection,pKey,pDefault=""){
	IniRead, Ret, %pFile%, %pSection%, %pKey%, %pDefault%
	Return Ret
	}
;==================================================================================================================================
MiniFTP_Null:
Return
;==================================================================================================================================
MiniFTP_RenameFile:
Return
;==================================================================================================================================
MiniFTP_PreloadDirs(RootDir=0){
	Global
	Critical
	Local ThisItem, FullPath, ItemCount = 0
	If !pFiles {
		CoInitialize()
		pFiles := Dictionary()
		setitem(pFiles, "Root", RootDir := TV_Add("/"))
		setitem(pFiles, RootDir . "_Path", "/")
		;%RootDir%_HasBeenAdded = 1
		}
	If !RootDir {
		If RootDir := getitem(pFiles, "Root") {
		}Else{
			setitem(pFiles, "Root", RootDir := TV_Add("/"))
			setitem(pFiles, RootDir . "_Path", "/")
			}
		}
	If (%RootDir%_HasBeenAdded = 1)
		Return
	If hEnum := FTP_FindFirstFile(MiniFTP_hFTPConnection, GetItem(pFiles,RootDir . "_Path") . "/*", MiniFTP_FTPData) { 
		Loop { ;Get the info from all files and directories
			If FTP_GetFileInfo(MiniFTP_FTPData, "IsDirectory") { ; If it is a directory
				If (%RootDir%_HasBeenAdded!=3){
					Size := FTP_GetFileInfo(MiniFTP_FTPData, "Size") / 1024
					If (Size > 1024) 
						Size := Size / 1024, SizeType := "MB" 
					Else
						SizeType := "KB"
					; add directory to treeview
					Name := FTP_GetFileInfo(MiniFTP_FTPData, "Name")
					ThisItem := TV_Add(Name,RootDir)
					Add(pFiles, ThisItem . "_Name", Name)
					Add(pFiles, ThisItem . "_Size", Size)
					Add(pFiles, ThisItem . "_SizeType", SizeType)
					Add(pFiles, ThisItem . "_Attrib", FTP_GetFileInfo(MiniFTP_FTPData, "Attrib"))
					GetItem(pFiles,RootDir . "_Path") = "/" ? FullPath := "" : FullPath := GetItem(pFiles,RootDir . "_Path")
					Add(pFiles, ThisItem . "_Path", FullPath . "/" . Name)
					Add(pFiles, ThisItem . "_CreationTime", FTP_GetFileInfo(MiniFTP_FTPData, "CreationTime"))
					Add(pFiles, ThisItem . "_LastAccessTime", FTP_GetFileInfo(MiniFTP_FTPData, "LastAccessTime"))
					Add(pFiles, ThisItem . "_LastWriteTime", FTP_GetFileInfo(MiniFTP_FTPData, "LastWriteTime"))
					Add(pFiles, ThisItem . "_Count", 0)
					}
				}Else{
					Size := FTP_GetFileInfo(MiniFTP_FTPData, "Size")
					Path := MiniFTP_SelectedDir ; 
					Size = %Size%
					Size := Size / 1024
					If (Size > 1024) 
						Size := Size / 1024, SizeType := "MB" 
					Else
						SizeType := "KB"
					ThisItem := RootDir
					ItemCount++
					SetItem(pFiles, ThisItem . "_Count", ItemCount)
					SetItem(pFiles, ThisItem . "_" . ItemCount, Path = "/" ? "/" . Name := FTP_GetFileInfo(MiniFTP_FTPData, "Name") : Path . "/" . Name := FTP_GetFileInfo(MiniFTP_FTPData, "Name"))
					SetItem(pFiles, ThisItem . "_" . ItemCount . "_Name", Name)
					SetItem(pFiles, ThisItem . "_" . ItemCount . "_Size", Size)
					SetItem(pFiles, ThisItem . "_" . ItemCount . "_SizeType", SizeType)
					SetItem(pFiles, ThisItem . "_" . ItemCount . "_Attrib", FTP_GetFileInfo(MiniFTP_FTPData, "Attrib"))
					SetItem(pFiles, ThisItem . "_" . ItemCount . "_Path", GetItem(pFiles, RootDir . "_Path"))
					SetItem(pFiles, ThisItem . "_" . ItemCount . "_CreationTime", FTP_GetFileInfo(MiniFTP_FTPData, "CreationTime"))
					SetItem(pFiles, ThisItem . "_" . ItemCount . "_LastAccessTime", FTP_GetFileInfo(MiniFTP_FTPData, "LastAccessTime"))
					SetItem(pFiles, ThisItem . "_" . ItemCount . "_LastWriteTime", FTP_GetFileInfo(MiniFTP_FTPData, "LastWriteTime"))
					}
			If(!FTP_FindNextFile(hEnum, MiniFTP_FTPData))
				break ; there are no more files
			}
		}
	%RootDir%_HasBeenAdded = 1
	}
;==================================================================================================================================
FileSelect:
If (A_GuiEvent = "RightClick")
	{
	Gosub, KillTT
	Gosub, MiniFTP_FileOptions
	Return
	}
If (A_GuiEvent != "Normal")
	Return
CreateToolTip(A_EventInfo)	
return
;==================================================================================================================================
MiniFTP_FileOptions:
;Critical
Menu, MiniFTP_FileOptions, Show
Return
;==================================================================================================================================
MiniFTP_DeleteFile:

;Critical
MiniFTP_SelectedDir := GetItem(pFiles, TV_GetSelection() . "_Path")
If MiniFTP_SelectedDir = /
	MiniFTP_Dir = 
Else
	MiniFTP_Dir := MiniFTP_SelectedDir 
	

If !MiniFTP_SelectedRow := LV_GetNext() { ; If a file was not selected
	MsgBox, No File selected.`nPlease select a file to delete.
	Return
	}
LV_GetText(MiniFTP_FileToDelete,MiniFTP_SelectedRow) ; ;Get the selected file name

If !MiniFTP_FileToDelete { ; If the selection is blank
	SB_SetText("Error Deleting File.")
	Return
	}
MsgBox, 3, Delete File?, Are you sure you want to delete the file:`n%MiniFTP_Dir%/%MiniFTP_FileToDelete%
IfMsgBox Yes 
	{
	
	;FTP_DeleteFile(MiniFTP_hFTPConnection,MiniFTP_Dir . MiniFTP_FileToDelete)
	If FTP_DeleteFile(MiniFTP_hFTPConnection,MiniFTP_Dir . "/" . MiniFTP_FileToDelete) {
		SB_SetText("File Deleted.")
		GoSub, MiniFTP_UpdateFiles
		} Else {
		SB_SetText("Error Deleting File.")
		Return
		}
	}
Return
;==================================================================================================================================
GuiSize:
If !MiniFTP_Count123 {
	MiniFTP_Count123++
	WinMove, ahk_id %MiniFTP_hRebar%,,,,%A_GuiWidth%
	}
Anchor(MiniFTP_hFileDir,"h")
Anchor(MiniFTP_hRebar,"w")
Anchor(MiniFTP_hFileList,"hw")
return
;==================================================================================================================================
;Called when treeview item is selected
MiniFTP_ChangeServerDir:
Critical
If (A_GuiEvent = "RightClick") {
	ToolTip, % GetItem(pFiles, A_EventInfo . "_Path")
	SetTimer, KillTT, -%MiniFTP_ToolTipDelay%
	MiniFTP_ToolTipShowing = 1
	}

If (MiniFTP_LastSelectedTVItem = MiniFTP_SelectedTVItem := TV_GetSelection()) and (A_GuiEvent = "Normal") or (A_GuiEvent != "S") or Refresh {
	Refresh=
	Return
	}


If !MiniFTP_LastSelectedTVItem := MiniFTP_SelectedTVItem := TV_GetSelection()  { ;Get the current Selected item in the treeview
	Return ; If no selection (should not happen)
	}
If MiniFTP_ToolTipShowing
	GoSub, KillTT
GoSub, MiniFTP_Refresh ;Refresh the file list
return
;==================================================================================================================================
MiniFTP_UploadFile: ;When user chooses to upload a file
If !MiniFTP_hFTPConnection { ;If no Connection
	MsgBox, No current FTP connection.`nOperation Cancelled.
	Return
	}
Gui, 1:+OwnDialogs ;Choose the file to upload
FileSelectFile, MiniFTP_SelectedFile,,,Select File To Upload
If !MiniFTP_SelectedFile {
	Return ; User Cancelled without selecting a file
	}
Loop %MiniFTP_SelectedFile% ;Get the file name (for the default file name)
	MiniFTP_FileNameOnly := A_LoopFileName
InputBox, MiniFTP_TargetFile, Upload File, Type a Target filename.,,,,,,,, %MiniFTP_FileNameOnly% ;Choose the target name
If ErrorLevel {
	Return ; User Cancelled
	}
SB_SetText("Uploading file -" . MiniFTP_SelectedFile . "- to server") ;Update Status Bar
If !FTP_PutFile(MiniFTP_hFTPConnection,MiniFTP_SelectedFile,GetItem(pFiles,TV_GetSelection() . "_Path") . "/" . MiniFTP_TargetFile) { ;Upload File
	SB_SetText("Error Uploading file") ; There was an error
	Return
	}
Gosub, MiniFTP_UpdateFiles ;Update the file list (to show the new file)
SB_SetText("Upload Complete") ;Update the status bar
Return
;==================================================================================================================================
;After Login Window
MiniFTP_Connect:
Critical
Gui, 2:Submit, NoHide
;The following lines are for the Status bar
Gui, 1:Default
Gui, 1:+LastFound
SB_SetText("Connecting to Server " . MiniFTP_Server . ":" . MiniFTP_Port)
TV_Delete()
%MiniFTP_SelectedTVItem%_HasBeenAdded=
MiniFTP_SelectedDir=/
MiniFTP_SelectedTVItem =
0_HasBeenAdded=
%MiniFTP_Root%_HasBeenAdded=
MiniFTP_Root=
FTP_Close()
RemoveAll(pFiles)
;MiniFTP_PreloadDirs()
;_HasBeenAdded = 1
MiniFTP_hFTPConnection=
MiniFTP_NewConnect=1
	
Gosub, MiniFTP_UpdateFiles
Return
;==================================================================================================================================
MiniFTP_UpdateFiles:
ThisSelection := TV_GetSelection()
Loop, % GetItem(pFiles, ThisSelection . "_Count")
	{
	Remove(pFiles, ThisItem . "_" . A_Index)
	Remove(pFiles, ThisItem . "_" . A_Index . "_Name")
	Remove(pFiles, ThisItem . "_" . A_Index . "_Size")
	Remove(pFiles, ThisItem . "_" . A_Index . "_SizeType")
	Remove(pFiles, ThisItem . "_" . A_Index . "_Attrib")
	Remove(pFiles, ThisItem . "_" . A_Index . "_Path")
	Remove(pFiles, ThisItem . "_" . A_Index . "_CreationTime")
	Remove(pFiles, ThisItem . "_" . A_Index . "_LastAccessTime")
	Remove(pFiles, ThisItem . "_" . A_Index . "_LastWriteTime")
	}
Remove(pFiles, ThisItem . "_Count")
%ThisSelection%_HasBeenAdded = 3
Gosub, MiniFTP_Refresh
Return
;==================================================================================================================================
;Update the File Listing
MiniFTP_Refresh:
OldFormat := A_FormatFloat
SetFormat, Float, 0.2
LV_Delete() ; Clear the current file list
GuiControl, -Redraw, MiniFTP_ServerList
ThisSelection := TV_GetSelection()
If (%ThisSelection%_HasBeenAdded != 1)	{
	If MiniFTP_hFTPConnection
		FTP_CloseSocket(MiniFTP_hFTPConnection) ;Close the socket
	If !MiniFTP_hFTPConnection := FTP_Open(MiniFTP_Server, MiniFTP_Port, MiniFTP_UserID, MiniFTP_Password) { ;Open a connection
		SB_SetText("Error Connecting to server")
		Return
	} Else {
		SB_SetText("Connected to Server " . MiniFTP_Server . ":" . MiniFTP_Port)
		}
	MiniFTP_PreloadDirs(ThisSelection)
	}
Loop, % GetItem(pFiles, ThisSelection . "_Count")
	LV_Add("",GetItem(pFiles, ThisSelection . "_" . A_Index  . "_Name"), GetItem(pFiles, ThisSelection . "_" . A_Index . "_Size"), GetItem(pFiles, ThisSelection . "_" . A_Index . "_SizeType"))
LV_ModifyCol() ; Make the file names visible
Loop, % LV_GetCount("Column")
	LV_ModifyCol(A_Index, "AutoHdr")
WinSet, Redraw, , ahk_id %MiniFTP_hFileDir% ;Sometimes the Expand marks do not show without this
GuiControl, +Redraw, MiniFTP_ServerList
If MiniFTP_NewConnect {
	MiniFTP_NewConnect=
	Refresh=1
	MiniFTP_LastSelectedTVItem := MiniFTP_SelectedTVItem := MiniFTP_Root
	TV_Modify(getitem(pFiles, "Root"), "Expand Select") 
	}
SetFormat, Float, %OldFormat%
Return
;==================================================================================================================================
MiniFTP_DownloadFile:
If !MiniFTP_SelectedRow := LV_GetNext() { ; If a file was not selected

	MsgBox, No File selected.`nPlease select a file to download.
	Return
	}
LV_GetText(MiniFTP_FileToDownload,MiniFTP_SelectedRow) ; ;Get the selected file name
If !MiniFTP_FileToDownload { ; If the selection is blank
	SB_SetText("Error Downloading File.")
	Return
	}
Gui, 1:+OwnDialogs ;Show the save file dialog
FileSelectFile, MiniFTP_TargetFile,S 16,%MiniFTP_FileToDownload%,Save File
If !MiniFTP_TargetFile { ; If user cancelled or did not select a file name 
	Return
	}
If !FTP_GetFile(MiniFTP_hFTPConnection,MiniFTP_SelectedDir . "/" . MiniFTP_FileToDownload,MiniFTP_TargetFile) { ; Download the file

	SB_SetText("Error Downloading File.") ; Error
}Else{
	SB_SetText("Download Complete.") ; Successful Download
	}

Return
;==================================================================================================================================
GUI_ShowDownloads:
Return
;==================================================================================================================================
GuiClose:
Gui, 2:Destroy
Gui, 1:Destroy
Release(pFiles)
CoUninitialize()
ExitApp
;==================================================================================================================================
CreateToolTip(ItemID) {
	global MiniFTP_ToolTip_ShowProps, MiniFTP_ToolTipDelay, pFiles, MiniFTP_ToolTipShowing
	TVItem := TV_GetSelection()
	Loop, Parse, MiniFTP_ToolTip_ShowProps, |
	If (A_LoopField = "Size")
		Text .= A_LoopField . ":`t" . GetItem(pFiles, TVItem . "_" . ItemID . "_Size") . " " . GetItem(pFiles, TVItem . "_" . ItemID . "_SizeType") . "`n"
	Else
		Text .= A_LoopField . ":`t" . GetItem(pFiles, TVItem . "_" . ItemID . "_" . A_LoopField) . "`n"
	StringTrimRight, Text, Text, 1
	ToolTip, % Text
	MiniFTP_ToolTipShowing		= 1
	SetTimer, KillTT, -%MiniFTP_ToolTipDelay%
	}
;==================================================================================================================================
TB_WM_COMMAND(wParam, lParam) {
    global
    If (A_Gui = 1 && lParam = MiniFTP_hToolBar) {

	If IsLabel(Btn_%wParam%_Label)
        Gosub, % Btn_%wParam%_Label
    }

}
;==================================================================================================================================

;==================================================================================================================================
;==================================================================================================================================
#IfWinActive ahk_group Self
Enter::
;Critical
ControlGetFocus, MiniFTP_CurrentControl, ahk_id %MiniFTP_hGui%
If MiniFTP_CurrentControl in Edit4,Button1
	Gosub, MiniFTP_Connect
Return
;==================================================================================================================================
+Tab::
;Critical
ControlGetFocus, MiniFTP_CurrentControl, ahk_id %MiniFTP_hGui%
If MiniFTP_CurrentControl not in Edit1,Edit2,Edit3,Edit4,Button1
	{
	ControlFocus, Edit4, ahk_id %MiniFTP_hGui%
	ControlSend, Edit4, +{End}, ahk_id %MiniFTP_hGui%
	Return
	}
If MiniFTP_CurrentControl = Button1 
	{
	ControlFocus, Edit4, ahk_id %MiniFTP_hGui%
	ControlSend, Edit4, +{End}, ahk_id %MiniFTP_hGui%
	}
Else If MiniFTP_CurrentControl = Edit1 
	{
	ControlFocus, Button1, ahk_id %MiniFTP_hGui%
	}
Else
	{
	StringRight, Instance, MiniFTP_CurrentControl, 1
	Instance--
	ControlFocus, Edit%Instance%, ahk_id %MiniFTP_hGui%
	ControlSend, Edit%Instance%, +{End}, ahk_id %MiniFTP_hGui%
	;ControlSend, Edit%Instance%, ^a, ahk_id %MiniFTP_hGui%
	}
Return
;==================================================================================================================================
Tab::
ControlGetFocus, MiniFTP_CurrentControl, ahk_id %MiniFTP_hGui2%
If MiniFTP_CurrentControl not in Edit1,Edit2,Edit3,Edit4,Button1
	{
	ControlFocus, Edit1, ahk_id %MiniFTP_hGui2%
	Return
	}
If MiniFTP_CurrentControl = Button1 
	{
	ControlFocus, Edit1, ahk_id %MiniFTP_hGui%
	ControlSend, Edit1, +{End}, ahk_id %MiniFTP_hGui%
	}
Else If MiniFTP_CurrentControl = Edit4 
	{
	ControlFocus, Button1, ahk_id %MiniFTP_hGui%
	}
Else
	{
	StringRight, Instance, MiniFTP_CurrentControl, 1
	Instance++
	ControlFocus, Edit%Instance%, ahk_id %MiniFTP_hGui%
	If Instance != 1
		ControlSend, Edit%Instance%, +{End}, ahk_id %MiniFTP_hGui%
	}
Return
#IfWinActive
;==================================================================================================================================
#Include Dictionary.ahk
#Include Rebar.ahk
#Include Toolbar.ahk
#Include FTP.ahk
#Include Anchor.ahk
;==================================================================================================================================
