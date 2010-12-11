

; Quick Launcher Toolbar for Portable Apps                        :: By Skan - 24/Aug/2007

#NoTrayIcon

;used to get the total number of .lnk files and the width of each row

Loop *.lnk
   totalLNK = %A_index%
rowHeight = 17 ;pixels
;The reason for rowheight is the following  (from help)
;Note: adding icons to a ListView's rows will increase the height of each row, which will make this option inaccurate.
listViewHeight := rowHeight * totalLNK



SetWorkingDir, %A_ScriptDir%
Gui, Margin, 3, 3
Gui, Color, 0000FF
Gui, Font, s9 Bold
Gui -Caption +ToolWindow +AlwaysOnTop +LastFound
Gui1 := WinExist() , USB := SubStr(A_ScriptFullPath,1,1) , Y := A_ScreenHeight
Col1 := "SortDesc" , Col3 := "SortDesc" , Rows := totalLNK
Menu, Tray, UseErrorLevel
Menu, Tray, Icon, %A_WinDir%\System32\Shell32.dll, 22
Menu, Tray, Icon
Menu, Tray, NoStandard

Gui, Add, Picture, x0 y0 w20 h20 Icon22, %A_WinDir%\System32\Shell32.dll
Gui, Add, Text, x0 y0 w111 h20 cFFFFFF +0x201 +BackGroundTrans, Startup
Gui, Add, Text    , x+1 y2 w16 h16 gToggleGUI cFFFFFF, »»

Gui, Add, Text, x3 y20 w130 h3 0x6
Gui, Font, s8 Normal
Gui, Add, ListView
   , x3 y23 h%listViewHeight% R%Rows% 0x2000 -Hdr -E0x200 LV0x41 LV0x800 AltSubmit gOnClick hwndLV,  1|2|3|4
ILID := IL_Create(0,1) , LV_SetImageList(ILID)

Loop *.lnk {            ; Load Links into ListView and also Check and Repairs broken Links
  LINK := A_LoopFileLongPath
  SplitPath, LINK,,,, FN
  FileGetShortcut, %LINK%, Tar, Dir, Args, T, Ico, IcoN, Run
  IL_Add( ILID,Ico,A_Index,1 ), LV_Add( "Icon" A_Index,FN,LINK,A_LoopFileTimeModified,T)
  }
LV_ModifyCol(1,"200"),  LV_ModifyCol(2,"10"),  LV_ModifyCol(3,"0"),    LV_ModifyCol(3,Col3)

Gui Show, y%Y% w130                                        ; Ascertaining the GUI Position
WinGetPos, GX,GY,GW,GH, ahk_id %Gui1%
WinGetPos, TX,TY,TW,TH, ahk_class Shell_TrayWnd
X := ( A_ScreenWidth - GW ),  Y := ( A_ScreenHeight - TH - GH )
Gui Show, x%X% y%Y% w130, [ Disabled Startup ] ; Bottom Right Corner of Screen

Menu, Tray, Add , Quick Launch, ToggleGUI
Menu, Tray, Add
Menu, Tray, Standard
Menu, Tray, Default, Quick Launch
Menu, Tray, Click, 1
Menu, Tray, Tip, Disabled Startup Items
IfExist, Drives.ICL, Menu, Tray, Icon, Drives.ICL, % Asc(USB) - 64

Return                                  ;                   // End of Auto-execute Section

#IfWinActive, [ Disabled Startup ]
  F8::LV_ModifyCol( 1, ( Col1 := (Col1="Sort") ? "SortDesc" : "Sort" ) )
  F9::LV_ModifyCol( 3, ( Col3 := (Col3="Sort") ? "SortDesc" : "Sort" ) )
#IfWinActive

ToggleGUI:
  If DllCall( "IsWindowVisible", UInt,Gui1 ) {
     DllCall( "AnimateWindow", UInt,Gui1, Int,300, Int,0x50001 )
     SendInput !{Esc}
  } Else {
     DllCall( "AnimateWindow", UInt,Gui1, Int,300, Int,0x60002 )
     Gui, Show
} Return

OnClick:
  If ( A_GuiEvent="Normal" ) {
     Row := A_EventInfo,  LV_Modify(Row,"Col3", (Now:=A_Now)), LV_GetText( Target, Row, 2)
     FileSetTime, %Now%, %Target%, M
     LV_ModifyCol(3, Col3 )
     Run, %Target%
} Return
