;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	Written by Tank
;;	Based on Seans most excelent work COM.ahk
;;	http://www.autohotkey.com/forum/viewtopic.php?t=22923
;;	some credit due to Lexikos for ideas arrived at from ScrollMomentum
;;	http://www.autohotkey.com/forum/viewtopic.php?t=24264
;;	1-17-2009
;;	Please use and distribute freely
;;	Please do not claim it as your own
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

{	;~ CONSTANTS/PARAMETERS
	GuiWinTitle = iWebBrowser2 Learner
	WM_LBUTTONDOWN = 0x201
}

{	;~ DIRECTIVES
	DetectHiddenWindows,on
	SetTitleMatchMode,slow	
	SetTitleMatchMode,2
}

{	;~ AUTOEXEC
	COM_Error(0)
	
	FileInstall, Cross.bmp, %A_ScriptDir%\iWebBrowser2_Learner_Cross.bmp
	FileInstall, NoCross.bmp, %A_ScriptDir%\iWebBrowser2_Learner_NoCross.bmp
	FileSetAttrib, +H, %A_ScriptDir%\iWebBrowser2_Learner_Cross.bmp
	FileSetAttrib, +H, %A_ScriptDir%\iWebBrowser2_Learner_NoCross.bmp
	OnExit, DeleteFiles
	
	Gui, Add, Edit, x56 y5 w260 h20 vTitle, 
	Gui, Add, Edit, x56 y30 w260 h20 vURLL, 
	Gui, Add, Edit, x120 y55 w90 h20 vEleName, 
	Gui, Add, Edit, x226 y55 w90 h20 vEleIDs, 
	Gui, Add, Edit, x36 y55 w50 h20 vEleIndex, 
	Gui, Add, ListView, x6 y82 w310 h60 -LV0x10 AltSubmit vVarListView gSubListView NoSortHdr, % "frame.#|s Index|name|id|"
	LV_ModifyCol(1, 65), LV_ModifyCol(2,49), LV_ModifyCol(3,87), LV_ModifyCol(4,87), LV_ModifyCol(2,"Center")
	Gui, Add, Edit, x11 y160 w302 h40 vhtml_text, 
	Gui, Add, Edit, x10 y217 w302 h40 vhtml_value, 
	Gui, Add, Text, x30 y7 w25 h20 +Center, Title
	Gui, Add, Text, x32 y33 w23 h20 +Center, Url
	Gui, Add, Text, x1 y56 w34 h20 +Center, Index
	Gui, Add, Text, x89 y57 w30 h21 +Center, Name
	Gui, Add, Text, x212 y58 w13 h20 +Center, ID
	Gui, Add, GroupBox, x6 y145 w310 h119 , Value/InnerText
	Gui, Add, GroupBox, x6 y201 w310 h63 , OuterHTML

	; Cross-Hair Image
	Gui, Font, S6 CGray, Verdana
	Gui, Add, Picture, x2 y2 w26 h26 gCrossHairPic, %A_ScriptDir%\iWebBrowser2_Learner_Cross.bmp
	Gui, Add, Text, x2 y30 w26 h26 +Center Font8, Drag Cursor
	Gui, Font, , 

	OnMessage(WM_LBUTTONDOWN:="0x0201", "HandleMessage")

	Gui, +AlwaysOnTop
	Gui, +Delimiter`n
	Gui, Show, Center  h270 w322, %GuiWinTitle%
	
	outline := Outline() ; create "Outline" object
	Hotkey, ~LButton Up, Off ; "~LButton Up" Hotkey only active when LButton is pressed
	Return
}

~Lbutton Up:: ; Reset Cross-Hair & freeze program
{
	Hotkey, ~LButton Up, Off
	Lbutton_Pressed := False
	If ( !CH ) {
		GuiControl, , Static6, %A_ScriptDir%\iWebBrowser2_Learner_Cross.bmp
		CrossHair( CH:=True )
	}
	Return
}
CrossHairPic: ; allow dragable Cross-Hair when clicked
{
	If ( A_GuiEvent = "Normal" ) {
		SetBatchLines, -1
		Hotkey, ~LButton Up, On
		GuiControl, , Static6, %A_ScriptDir%\iWebBrowser2_Learner_NoCross.bmp
		CrossHair( CH:=False )			
		Lbutton_Pressed := True
		while, Lbutton_Pressed
			IE_HtmlElement()
		outline.hide()
		SetBatchLines, 10ms
	}
	Return
}

#s:: COM_CreateObject("SAPI.SpVoice").Speak( textOfObj )

GuiClose:
{
	ExitApp
	DeleteFiles:
	FileDelete, %A_ScriptDir%\iWebBrowser2_Learner_Cross.bmp
	FileDelete, %A_ScriptDir%\iWebBrowser2_Learner_NoCross.bmp
	ExitApp
}


IE_HtmlElement() {
	CoordMode, Mouse
	MouseGetPos, xpos, ypos,, hCtl, 3
	WinGetClass, sClass, ahk_id %hCtl%
	If Not   sClass == "Internet Explorer_Server"
		|| Not   pdoc := IE_GetDocument(hCtl)
			Return
	global Frame, outline ; store frames & hold "Frame" Coords
		Frame := object()
	static Stored ; hold stored values
		Stored := ( Stored ? Stored : object() )
	pwin :=   COM_QueryService(pdoc ,"{332C4427-26CB-11D0-B483-00C04FD90119}")
	, IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
	, iWebBrowser2 := COM_QueryService(pwin,IID_IWebBrowserApp,IID_IWebBrowserApp)
	
	If   pelt := pwin.document.elementFromPoint( xpos-xorg:=pwin.screenLeft, ypos-yorg:=pwin.screenTop ) {
		; framepath:=
		global LV := object() ; hold frame info for ListView
		While   ( type:=pelt.tagName )="IFRAME" || type="FRAME"
			selt .=   A_Index ") **[sourceIndex]=" pelt.sourceindex " **[Name]= " pelt.name " **[ID]= " pelt.id "`n"
			, LV[ A_Index, "C1" ] := type "." A_Index
			, LV[ A_Index, "C2" ] := pelt.sourceindex
			, LV[ A_Index, "C3" ] := pelt.name
			, LV[ A_Index, "C4" ] := pelt.id
			; , framepath .= (pelt.id ? pelt.id :  pelt.sourceindex) ","
			, Frame[ A_Index ] := pelt ; store frames
			, pwin :=	COM_QueryService(pbrt:=pelt.contentWindow, "{332C4427-26CB-11D0-B483-00C04FD90119}")
			, pdoc :=	pwin.document
			, LV[ A_Index, "URL" ] := pdoc.url
			, pbrt :=	pdoc.elementFromPoint( xpos-xorg+=pelt.getBoundingClientRect().left, ypos-yorg+=pelt.getBoundingClientRect().top )
			, pelt :=		pbrt
		pbrt :=   pelt.getBoundingClientRect()
		, l  :=   pbrt.left
		, t  :=   pbrt.top
		, r  :=   pbrt.right
		, b  :=   pbrt.bottom
		
		If Not outline.visible ; if the element has changed
			|| (Stored["x1"] <> l+xorg || Stored["y1"] <> t+yorg || Stored["x2"] <> r+xorg || Stored["y2"] <> b+yorg) {
			If selt { ; if the element is in a frame, get frame dimensions
				; Loop, Parse, framepath, `, ; loop framepath from above & insert code
					; If A_LoopField ; prevent error if extra comma at the end
						; frame_path .= "document.all[" A_LoopField "].contentWindow."
				; StringTrimRight, frame_path, frame_path, 14
				Frect := Frame[ Frame._maxIndex() ].getBoundingClientRect() ; get the Frame Rectangle
				, Frame["x1"] := xorg ; set the frame Coordinates
				, Frame["y1"] := yorg
				, Frame["x2"] := FRect.right+xorg
				, Frame["y2"] := FRect.bottom+yorg
			} Else, 
				Frame["x1"]:=Frame["y1"]:=Frame["x2"]:=Frame["y2"]:= "NA" ; if there isn't any frames, assign frame coords "NA"
			
			; Change outline display
			outline.transparent( true )
			, outline.hide()			
			, coord := GetCoord(	Stored["x1"] := l+xorg
										, 	Stored["y1"] := t+yorg
										,	Stored["x2"] := r+xorg
										,	Stored["y2"] := b+yorg
										,	iWebBrowser2.HWND	)
			, outline.show( coord["x1"], coord["y1"], coord["x2"], coord["y2"], coord["sides"] )
			, outline.setAbove( iWebBrowser2.HWND )
			, outline.transparent( false )	
		} 
	
		global textOfObj, GuiWinTitle
		Sleep, 1 ; make sure Controls Update
		textOfObj:=inpt(pelt)
		WinSetTitle, % GuiWinTitle "ahk_class AutoHotkeyGUI",, % GuiWinTitle (pelt.tagName ? " - [" pelt.tagName "]":"")
		GuiControl,Text,Title,%	iWebBrowser2.LocationName
		GuiControl,Text,URLL,% iWebBrowser2.LocationURL	
		GuiControl,Text,EleIndex,%	sI:= pelt.sourceindex
		GuiControl,Text,EleName,%	sName:= pelt.name
		GuiControl,Text,EleIDs,%	sID:= pelt.id
		If ( Stored["textOfObj"] <> textOfObj ) 
			GuiControl,Text,html_text,%	Stored["textOfObj"]:=textOfObj
		If ( Stored["outerHTML"] <> pelt.outerHTML ) 
			GuiControl,Text,html_value,% Stored["outerHTML"]:=pelt.outerHTML
		If ( Stored["selt"] <> selt ) {
			LV_Delete()
			Loop, % LV._maxIndex()
				LV_Add(	""
							,	LV[ A_Index, "C1" ]
							,	LV[ A_Index, "C2" ]
							,	LV[ A_Index, "C3" ]
							,	LV[ A_Index, "C4" ]	)
			Stored["selt"] := selt
		}
		StringReplace, textOfObj, textOfObj,]=,?
		StringSplit,textOfObjs,textOfObj,?
		StringReplace,textOfObj,textOfObjs2,`,,&#44;,all
		; optFrames:=framepath ? ", """ framepath """" : ""
		; global element,optFrames
		; element:=sID ? sID : sNames ? sName : sI
		; optFrames:=framepath ? ", """ framepath """" : ""
	}
	
}

inpt(i) {
	typ	:=	i.tagName
	inpt	:=	"BUTTON,INPUT,OPTION,SELECT,TEXTAREA"
	Loop,Parse,inpt,`,
		if (typ	=	A_LoopField	?	1	:	"")
			Return "[value]=" i.value
	Return "[innertext]=" i.innertext
}

IE_GetDocument( hWnd ) {
	Return,	COM_QueryService( COM_AccessibleObjectFromWindow( hWnd )
				,	"{332C4427-26CB-11D0-B483-00C04FD90119}" ).document
}

GetCoord( x1,y1,x2,y2, WinHWND ) { ; get the coordinates for the outline
	global Frame, outline
	WinGetPos, Wx, Wy, , , ahk_id %WinHWND%
	ControlGetPos, Cx1, Cy1, Cw, Ch, Internet Explorer_Server1, ahk_id %WinHWND%
	Cx1+=Wx  ; set "Internet Explorer_Server1" dimensions
	, Cy1+=Wy
	, Cx2:=Cx1+Cw
	, Cy2:=Cy1+Ch
	
	; Example return: object( "x1", 150, "y1", 200, "x2", 250, "y2", 300, "sides", "TRBL" )
	Return, object(	"x1",		Val( x1,Cx1,Frame["x1"], ">" )
						,	"y1",		Val( y1,Cy1,Frame["y1"], ">" )
						,	"x2",		Val( x2,Cx2,Frame["x2"], "<" )
						,	"y2",		Val( y2,Cy2,Frame["y2"], "<" )
						,	"sides",	( ElemCoord( y1,Cy1,Frame["y1"], ">" ) ? "T" : "" )
									.	( ElemCoord( x2,Cx2,Frame["x2"], "<" ) ? "R" : "" )
									.	( ElemCoord( y2,Cy2,Frame["y2"], "<" ) ? "B" : "" )
									.	( ElemCoord( x1,Cx1,Frame["x1"], ">" ) ? "L" : "" )	)
}

Val( E,C,F, option=">" ) { ; returns the value of the Greatest (or smallest) value
	If F is digit
		Return, option=">" ? (E>=C ? (E>=F ? E:F) : (C>=F ? C:F)) : (E<=C ? (E<=F ? E:F) : (C<=F ? C:F))
	Else Return, option=">" ? (E>=C ? E:C) : (E<=C ? E:C)
}

ElemCoord( E,C,F, option=">" ) { ; returns true if the Element value is the Greatest (or smallest)
	If F is digit
		Return, option=">" ? (E>=C && E>=F ? 1:0):(E<=C && E<=F ? 1:0)
	Else Return, option=">" ? (E>=C ? 1:0):(E<=C ? 1:0)
}

HandleMessage( p_w, p_l, p_m, p_hw ) { ; for "WM_LBUTTONDOWN" 
	Gui, Submit, NoHide
	If ( A_GuiControl = "VarListView" ) { ; Get Column Number - if clicked on ListView
		global column_num ; http://www.autohotkey.com/forum/viewtopic.php?t=6414
		VarSetCapacity( htinfo, 20 )
		, DllCall( "RtlFillMemory", "uint", &htinfo, "uint", 1, "uchar", p_l & 0xFF )
		, DllCall( "RtlFillMemory", "uint", &htinfo+1, "uint", 1, "uchar", ( p_l >> 8 ) & 0xFF )
		, DllCall( "RtlFillMemory", "uint", &htinfo+4, "uint", 1, "uchar", ( p_l >> 16 ) & 0xFF )
		, DllCall( "RtlFillMemory", "uint", &htinfo+5, "uint", 1, "uchar", ( p_l >> 24 ) & 0xFF )
		SendMessage, 0x1000+57, 0, &htinfo,, ahk_id %p_hw%
		If ( ErrorLevel = -1 )
			Return
		column_num := ( *( &htinfo+8 ) & 1 ) ? False : 1+*( &htinfo+16 )
	} 
	Else, If !InStr( A_GuiControl, "\" ) ; if clicked Cross-Hair ( "\" will cause RexEx Error in next line )
		&& temp := RegExReplace(%A_GuiControl%,"(\[value\]\=|\[innertext\]\=)") { ; if control contains data
			clipboard := temp
			ToolTip, % "clipboard= " (StrLen(temp) > 40 ? SubStr(temp,1,40) "..." : temp)
			SetTimer, RemoveToolTip, 1000
	}
}
SubListView:
{
	If ( A_GuiEvent="Normal" ) { ; if Right Clicked
		if ( column_num = 1 )
			LVselection := LV[ A_EventInfo ].url
		Else,
			LV_GetText( LVselection, A_EventInfo, column_num )
		if LVselection { ; if listview item contains data
			clipboard := LVSelection
			ToolTip, % "clipboard= " (StrLen(LVSelection) > 40 ? SubStr(LVSelection,1,40) "..." : LVSelection)
			SetTimer, RemoveToolTip, 1000
		}
	}
	Return
}
RemoveToolTip:
{
	SetTimer, RemoveToolTip, off
	ToolTip
	Return
}

CrossHair(OnOff=1) {   ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
    static AndMask, XorMask, $, h_cursor
        ,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; system cursors
        , b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13   ; blank cursors
        , h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13   ; handles of default cursors
    if (OnOff = "Init" or OnOff = "I" or $ = "") {      ; init when requested or at first call
        $ := "h"                                          ; active default cursors
        , VarSetCapacity( h_cursor,4444, 1 )
        , VarSetCapacity( AndMask, 32*4, 0xFF )
        , VarSetCapacity( XorMask, 32*4, 0 )
        , system_cursors := "32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650"
        StringSplit c, system_cursors, `,
        Loop, %c0%
            h_cursor   := DllCall( "LoadCursor", "uint",0, "uint",c%A_Index% )
            , h%A_Index% := DllCall( "CopyImage",  "uint",h_cursor, "uint",2, "int",0, "int",0, "uint",0 )
            , b%A_Index% := DllCall("LoadCursor", "Uint", "", "Int", IDC_CROSS := 32515, "Uint")
    }
    $ := (OnOff = 0 || OnOff = "Off" || $ = "h" && (OnOff < 0 || OnOff = "Toggle" || OnOff = "T")) ? "b" : "h"

    Loop, %c0%
        h_cursor := DllCall( "CopyImage", "uint",%$%%A_Index%, "uint",2, "int",0, "int",0, "uint",0 )
        , DllCall( "SetSystemCursor", "uint",h_cursor, "uint",c%A_Index% )
}
; http://www.autohotkey.com/docs/commands/DllCall.htm
; http://www.autohotkey.com/forum/topic4570.html#75609

{ ; OUTLINE OBJECT DEFINITION
Outline(color="red") { ; uses GUI 95-99
	static objAddress
	if ( *objAddress = 108 ) { ; valid Dereferenced object address equals "108"
		MsgBox, 262160, Outline Object Error, Only one "Outline Object" can exist at a time.
		Return
	}
	self := object(	"base"
						,	object(	"show",				"Outline_Show"
									,	"hide",				"Outline_Hide" 
									,	"setAbove",		"Outline_SetAbove"	
									,	"transparent",	"Outline_Transparent"
									,	"color",				"Outline_Color"
									,	"destroy",			"Outline_Destroy"
									,	"__delete",		"Object_Delete"	)	)
	Loop, 4 {
		Gui, % A_Index+95 ": -Caption +ToolWindow"
		Gui, % A_Index+95 ": Color" , %color%
		Gui, % A_Index+95 ": Show", NA h0 w0, outline%A_Index%
		self[ A_Index ] := WinExist( "outline" A_Index " ahk_class AutoHotkeyGUI" )
	}
	self.visible := false
	, self.color := color
	, self.top := self[1]
	, self.right := self[2]
	, self.bottom := self[3]
	, self.left := self[4]
	objAddress := &self ; store object address - for testing to ensure only one "Outline object" exists
	Return, self
}
	Outline_Show( self, x1, y1, x2, y2, sides="TRBL" ) { ; show outline at coords
		if InStr( sides, "T" )
			Gui, 96:Show, % "NA X" x1-2 " Y" y1-2 " W" x2-x1+4 " H" 2,outline1
		Else, Gui, 96: Hide
		if InStr( sides, "R" )
			Gui, 97:Show, % "NA X" x2 " Y" y1 " W" 2 " H" y2-y1,outline2
		Else, Gui, 97: Hide
		if InStr( sides, "B" )
			Gui, 98:Show, % "NA X" x1-2 " Y" y2 " W" x2-x1+4 " H" 2,outline3
		Else, Gui, 98: Hide
		if InStr( sides, "L" )
			Gui, 99:Show, % "NA X" x1-2 " Y" y1 " W" 2 " H" y2-y1,outline4
		Else, Gui, 99: Hide
		self.visible := true		
	}
	Outline_Hide( self ) { ; hide outline
		Loop, 4
			Gui, % A_Index+95 ": Hide"
		self.visible := false
	}
	Outline_SetAbove( self, hwnd ) { ; set Z-Order one above "hwnd"
		ABOVE := DllCall("GetWindow", "uint", hwnd, "uint", 0x3) ; get window directly above "hwnd"
		Loop, 4  ; set 4 "outline" GUI's directly below "hwnd_above"
			DllCall(	"SetWindowPos", "uint", self[ A_Index ], "uint", ABOVE
						,	"int", 0, "int", 0, "int", 0, "int", 0
						,	"uint", 0x1|0x2|0x10	) ; NOSIZE | NOMOVE | NOACTIVATE
	}
	Outline_Transparent( self, param ) { ; set Transparent ( different from hiding )
		Loop, 4
			WinSet, Transparent, % param=1 ? 0 : 255, % "ahk_id" self[ A_Index ]
		self.visible := !param
	}
	Outline_Color( self, color ) { ; set Color of Outline GUIs
		Loop, 4
			Gui, % A_Index+95 ": Color" , %color%
		self.color := color
	}
	Outline_Destroy( ByRef self ) { ; Destroy Outline
		VarSetCapacity( self, 0 )
	}
	Object_Delete() { ; Destroy "outline GUIs" when object is deleted
		Loop, 4
			Gui, % A_Index+95 ": Destroy"
	}
}
