;Origional code by Lexikos
;See this post:
; http://www.autohotkey.com/forum/viewtopic.php?t=25700
;Modified by ahklerner
;
ExitApp
/* 
Flags:
ILC_COLOR := 0x0
ILC_COLOR4 := 0x4
ILC_COLOR8 := 0x8
ILC_COLOR16 := 0x10
ILC_COLOR24 := 0x18
ILC_COLOR32 := 0x20
ILC_COLORDDB := 0xFE
ILC_MASK := 0x1
ILC_PALETTE := 0x800
 */

; Returns an ImageList handle which may be used with the built-in IL_* functions.
IL_CreateEx(ImageWidth=32, ImageHeight=32, Flags=0x0, InitialCount=2, GrowCount=5) {
   ; Default Flags: ILC_COLOR32=0x20
    Return DllCall("ImageList_Create","int",ImageWidth,"int",ImageHeight
        ,"uint",Flags,"int",InitialCount,"int",GrowCount)
	}

;Lexikos
;Modified by ahklerner
TB_Init(hGui,xPos,yPos,Height,Width) {
	hTb := DllCall("CreateWindowExA","uint",0x8,"str","ToolbarWindow32","uint",0
	   ,"uint",0x50000000 | 0x4|0x800|TBSTYLE_LIST := 0x1000|WS_EX_STATICEDGE := 0x20000 ; WS_CHILD|WS_VISIBLE | CCS_NORESIZE|TBSTYLE_FLAT 
	   ,"int",xPos,"int",yPos,"int",Width,"int",Height ; x, y, w, h
	   ,"uint",hGui,"uint",0,"uint",0,"uint",0)
	SendMessage, 0x41E, 20, 0,, ahk_id %hTb%    ; TB_SETBUTTONSTRUCTSIZE (sizeof(TBBUTTON))
	OnMessage(0x111, "TB_WM_COMMAND")
	Return hTb
	}

;Lexikos
;Modified by ahklerner
TB_AddButton(hTb,sFile,sText,sLabel,Height,Width) {
	Static Number_of_Buttons, hIL_normal
	If !hIL_normal {
		hIL_normal  := IL_CreateEx(Width,Height,0x21)
		SendMessage, 0x430, 0, hIL_normal   ,, ahk_id %hTb% ; TB_SETIMAGELIST
		}
	Number_of_Buttons++
	If sLabel
		MakeGlobal("Btn_" . Number_of_Buttons . "_Label",sLabel)
	IL_Add(hIL_normal,sFile,0x000000,0)
	text%Number_of_Buttons% := sText
	VarSetCapacity(btn,20*Number_of_Buttons,0)
	NumPut(Number_of_Buttons-1,btn,0)  ; iBitmap (zero-based index of button image)
	NumPut(Number_of_Buttons, btn,4) ; idCommand
	NumPut(0x4,     btn,8,"char") ; fsState = TBSTATE_ENABLED
	NumPut(0x10,    btn,9,"char") ; fsStyle = TBSTYLE_AUTOSIZE
	NumPut(&text%Number_of_Buttons%,btn,16) ; iString (index or pointer to string)
	SendMessage, 0x414, 1, &btn,, ahk_id %hTb%    ; TB_ADDBUTTONSA
	
	}

MakeGlobal(VarName,Value) {
	Global
	%VarName% := Value
	}


