; Keyboard Hook - Crude Script to retrieve info on "Mystery keys" - By Skan
; Created : 15-Jul-2008  // Last Modifed : 15-Jul-2008 
;
; Note: Yet to be bug-fixed and optimised!!!

#SingleInstance, Force
#Persistent
#InstallKeybdHook
#KeyHistory 20
SetWorkingDir, %A_ScriptDir%

if FileExist("Scancode-Keys.csv")
  FileDelete, Scancode-Keys.csv
FileAppend , VK-Name`,VKey`,ScanCode`,C`,^`,Elapsed`,Hotkey Name`n, Scancode-Keys.csv
VKeys=
( join
VK_LBUTTON,VK_RBUTTON,VK_CANCEL,VK_MBUTTON,VK_XBUTTON1,VK_XBUTTON2,,VK_BACK,VK_TAB,Reserve
d,Reserved,VK_CLEAR,VK_RETURN,,,VK_SHIFT,VK_CONTROL,VK_MENU,VK_PAUSE,VK_CAPITAL,VK_HANGUL,
,VK_JUNJA,VK_FINAL,VK_HANJA,,VK_ESCAPE,VK_CONVERT,VK_NONCONVERT,VK_ACCEPT,VK_MODECHANGE,VK
_SPACE,VK_PRIOR,VK_NEXT,VK_END,VK_HOME,VK_LEFT,VK_UP,VK_RIGHT,VK_DOWN,VK_SELECT,VK_PRINT,V
K_EXECUTE,VK_SNAPSHOT,VK_INSERT,VK_DELETE,VK_HELP,VK_0,VK_1,VK_2,VK_3,VK_4,VK_5,VK_6,VK_7,
VK_8,VK_9,,,,,,,,VK_A,VK_B,VK_C,VK_D,VK_E,VK_F,VK_G,VK_H,VK_I,VK_J,VK_K,VK_L,VK_M,VK_N,VK_
O,VK_P,VK_Q,VK_R,VK_S,VK_T,VK_U,VK_V,VK_W,VK_X,VK_Y,VK_Z,VK_LWIN,VK_RWIN,VK_APPS,Reserved,
VK_SLEEP,VK_NUMPAD0,VK_NUMPAD1,VK_NUMPAD2,VK_NUMPAD3,VK_NUMPAD4,VK_NUMPAD5,VK_NUMPAD6,VK_N
UMPAD7,VK_NUMPAD8,VK_NUMPAD9,VK_MULTIPLY,VK_ADD,VK_SEPARATOR,VK_SUBTRACT,VK_DECIMAL,VK_DIV
IDE,VK_F1,VK_F2,VK_F3,VK_F4,VK_F5,VK_F6,VK_F7,VK_F8,VK_F9,VK_F10,VK_F11,VK_F12,VK_F13,VK_F
14,VK_F15,VK_F16,VK_F17,VK_F18,VK_F19,VK_F20,VK_F21,VK_F22,VK_F23,VK_F24,,,,,,,,,VK_NUMLOC
K,VK_SCROLL,OEM,OEM,OEM,OEM,OEM,,,,,,,,,,VK_LSHIFT,VK_RSHIFT,VK_LCONTROL,VK_RCONTROL,VK_LM
ENU,VK_RMENU,VK_BROWSER_BACK,VK_BROWSER_FORWARD,VK_BROWSER_REFRESH,VK_BROWSER_STOP,VK_BROW
SER_SEARCH,VK_BROWSER_FAVORITES,VK_BROWSER_HOME,VK_VOLUME_MUTE,VK_VOLUME_DOWN,VK_VOLUME_UP
,VK_MEDIA_NEXT_TRACK,VK_MEDIA_PREV_TRACK,VK_MEDIA_STOP,VK_MEDIA_PLAY_PAUSE,VK_LAUNCH_MAIL,
VK_LAUNCH_MEDIA_SELECT,VK_LAUNCH_APP1,VK_LAUNCH_APP2,Reserved,Reserved,VK_OEM_1,VK_OEM_PLU
S,VK_OEM_COMMA,VK_OEM_MINUS,VK_OEM_PERIOD,VK_OEM_2,VK_OEM_3,Reserved,Reserved,Reserved,Res
erved,Reserved,Reserved,Reserved,Reserved,Reserved,Reserved,Reserved,Reserved,Reserved,Res
erved,Reserved,Reserved,Reserved,Reserved,Reserved,Reserved,Reserved,Reserved,Reserved,,,,
VK_OEM_4,VK_OEM_5,VK_OEM_6,VK_OEM_7,VK_OEM_8,Reserved,OEM,VK_OEM_102,OEM,OEM,VK_PROCESSKEY
,OEM,VK_PACKET,,OEM,OEM,OEM,OEM,OEM,OEM,OEM,OEM,OEM,OEM,OEM,OEM,OEM,VK_ATTN,VK_CRSEL,VK_EX
SEL,VK_EREOF,VK_PLAY,VK_ZOOM,VK_NONAME,VK_PA1,VK_OEM_CLEAR,0xFF
)
StringSplit, VK, VKeys, `,

DetectHiddenWindows, On
Gui0 := WinExist( A_ScriptFullPath " ahk_class AutoHotkey" )
Gui, Margin,0,0
Gui 1:+LastFound -Sysmenu +AlwaysOnTop +ToolWindow
Gui1 := WinExist()
WinSet, style, -0xC00000, ahk_id %Gui0%
WinMove, ahk_id %Gui0%,,0,-30,640,25
ControlSend,,^{k}, ahk_id %Gui0%
DllCall("SetParent", uint, Gui0, uint,Gui1 )
Gui, Font, S10, Courier New
Gui, Add, ListView, Grid w605 r20 -E0x200, VK-Name|VKey|Scan|C|^|Elap|Hotkey Name
LV_ModifyCol(1, "190"), LV_ModifyCol( 2,"60 Center"), LV_ModifyCol(3,"60 Center")
LV_ModifyCol(4, "40 Center"), LV_ModifyCol(5,"40 Center"), LV_ModifyCol( 6,"60 Integer")
LV_ModifyCol(7, "150")
Gui, Show, , % " |<< Keyboard Hook >>|"
OnExit, QuitScript
SetTimer, UpdateListView, 10
Return

UpdateListView:
  If ! ( WinActive( "ahk_id" Gui1 ) OR WinActive( "ahk_id" Gui0 ) )
       Return 
  ControlSend,,{F5}, ahk_id %Gui0%
  ControlGetText, text, Edit1, ahk_id %Gui0%
  VarSetCapacity( hyphens, 109, Asc("-") )
  nText := SubStr( Text,(sPos:=InStr( Text,hyphens )+111), StrLen(Text)-Spos )
  StringReplace,nText,nText,Press [F5] to refresh,,
  StringReplace,nText,nText,%A_Tab%,|,all
  StringTrimRight,nText,nText,2
  If ( nText = pText )
     Return
  Gui, 1:Default
  LV_Delete()
  Loop, Parse, nText, `n, `r
   {
     Line := A_LoopField
     Loop,Parse,Line,|
      F%A_Index% := A_LoopField
     VKey := "VK" SubStr(F1,1,2), VK := "0x" SubStr(F1,1,2),
     VK += 0
     VK := "VK" VK, SC := "SC" SubStr(F1,-2), VKN := %VK%
     LV_Add( "", VKN, VKey, SC,F2, F3, F4, F5 ) 
;     FileAppend , %VKN%`,%VKey%`,%SC%`,%F2%`,%F3%`,%F4%`,%F5%`n, Scancode-Keys.csv
   }
  pText := nText
Return

QuitScript:
 ExitApp
Return
