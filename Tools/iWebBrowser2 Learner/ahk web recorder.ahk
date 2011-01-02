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

;~ CONSTANTS/PARAMETERS
{
	GuiWinTitle = iWebBrowser2 Learner Build ID: 2.5 ; added by jethrow
}
;~ DIRECTIVES
{
	DetectHiddenWindows,on
	SetTitleMatchMode,slow	
	SetTitleMatchMode,2
	link=linked,traversed
	iwf=iWeb Examples (press Ctrl+e when mouse is over desired element)
	WM_LBUTTONDOWN = 0x201
	Copyable=Title,URLL,MouseX,MouseY,EleIndex,EleIDs,EleName
	,theFrame,html_value,html_text,iWeb,CodeWindow,Source,Form,SampleScript
	funcs=
	(LTrim Join
	iWeb_Init()|iWeb_Term()|iWeb_getWin()|iWeb_DomWin()
	|iWeb_Nav()|iWeb_Complete()|iWeb_getDomObj()
	|iWeb_setDomObj()|iWeb_TableParse()|iWeb_clickDomObj()
	|iWeb_clickText()|iWeb_clickHref()|iWeb_clickValue()
	|iWeb_execScript()|iWeb_SelectOption()
	)
}

; <COMPILER: v1.0.48.3>
;~ AUTOEXEC
{
	COM_CoInitialize()
	COM_Error(0)
	fu=bar
	;;;;;;;;;;;;;;;;;;;;;;ExitMenu;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	{
		Menu,ViewMenu,add,Always On Top, ontop
		Menu,MenuGoup,Add,View, :ViewMenu
		Menu,ViewMenu,ToggleCheck,Always On Top
	}
	;;;;;;;;;;;;;;;;;;;;;;ExitMenu;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	{
		Menu,MenuGoup,Add,Exit, GuiClose
	}
	;;;;;;;;;;;;;;;;;;;;;;Show the Menu;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	{
		Gui, Menu, MenuGoup
	}
	Gui, Add, Tab2, x0 y0 w390 h572 0x40 gIsRolled vCurrentTab AltSubmit, Viewer|Script Writer|Source|Forms|Templates|About
	Gui, Tab, Viewer
	;	~~~ Main GroupBox layout~~~
	Gui, Add, GroupBox, x10 y30 w365 h110 , Browser	
	Gui, Add, GroupBox, xp yp+120 wp hp-70 , Mouse Coordinates		;	x15 y150 w365 h40
	Gui, Add, GroupBox, xp yp+50 wp hp , Element Under Mouse	;	x15 y200 w365 h40
	Gui, Add, GroupBox, xp yp+50 wp hp+25 , Frames			;	x25 y295 w385 h65
	Gui, Add, GroupBox, xp yp+70 wp hp+60 , Element Info	;	x25 y365 w385 h125	
	Gui, Add, GroupBox, xp yp+130 wp hp-35 , %iwf%					;	x15 y510 w405 h70
	;	~~~ Browser sub-Groupbox layout ~~~
	Gui, Add, GroupBox, x25 y45 w345 h40, Page Title	;	x25 y45 w385 h40
	Gui, Add, GroupBox, xp yp+45 wp hp, URL/Address		;	x25	y90 w385 h40
	;	~~~Title/URL layout~~~
	Gui, Add, Edit, x33 y60 w330 h20 vTitle ReadOnly,
	Gui, Add, Edit, xp yp+45 wp hp vURLL ReadOnly,
	;	~~~Mouse Coordinates layout~~~
	Gui, Add, Text, x40 y167 w65 h17 , Mouse X				;	x235 y185 w65 h17
	Gui, Add, Edit, xp+70 yp-2 wp-5 hp ReadOnly vMouseX,	;	x310 y185 w60 h17
	Gui, Add, Text, xp+100 yp+2 wp+5 hp , Mouse Y			;	x235 y205 w65 h17
	Gui, Add, Edit, xp+70 yp-2 wp-5 hp ReadOnly vMouseY,	;	x310 y205 w60 h17
	;	~~~Element Under Mouse layout~~~
	Gui, Add, Text, x25 y218 w65 h17 , Index
	Gui, Add, Text, xp+100 yp wp hp , Name						;	x140 y277 w65 h17
	Gui, Add, Text, xp+135 yp wp hp , ID						;	x290 y277 w65 h17
	Gui, Add, Edit, x60 yp-2 wp-10 hp vEleIndex ReadOnly,				;	x60 y275 w55 h17
	Gui, Add, Edit, xp+105 yp wp+25 hp vEleName ReadOnly,				;	x175 y275 w100 h17
	Gui, Add, Edit, xp+115 yp wp hp vEleIDs ReadOnly,					;	x310 y275 w100 h17
	;	~~~ 2nd layer layout ~~~
	Gui, Add, Edit, x20 y265 w345 h40 Border vtheFrame ReadOnly,		;	x35 y310 w365 h40
	Gui, Add, GroupBox, xp yp+70 wp hp, Value/InnerText		;	x35 y380 w365 h40
	Gui, Add, GroupBox, xp yp+40 wp hp+23, OuterHTML		;	x35 y420 w365 h60
	Gui, Add, ListBox, xp yp+95 wp r3 gCopyToWriter viWeb			;	x25 y525 w365
	Gui, Add, CheckBox, xp+270 yp+50 viClip, To Clipboard
	;	~~~ 3rd layer layout ~~~
	Gui, Add, Edit, x30 y350 w325 h17 vhtml_value ReadOnly,			;	x45 y395 w350 h17
	Gui, Add, Edit, xp yp+40 wp hp+23 Border vhtml_text ReadOnly,	;	x45 y435 w350 h40
	Gui, Add, Edit, x150 y255 w70 h10 Hidden vHTMLTag ReadOnly
	;	###### SCRIPT WRITER TAB ######
	Gui, Tab, Script Writer
	Gui, Add, GroupBox, x10 y30 w370 h205 , Code Testing Sandbox
	Gui, Add, DropDownList, xp+10 yp+15 w200 r8 vFunc, List of functions||%funcs%
	Gui, Add, Button, xp+205 yp-1 gAddToScript, Add
	Gui, Add, Edit, xp-205 yp+30 w348 h130 vCodeWindow,
	Gui, Add, Button, x264 y207 w50 h20 gRunScript, Test
	Gui, Add, Button, xp+55 yp wp hp gSaveScript, Save
	Gui, Add, CheckBox, x20 y211 vsClip, To Clipboard	;	gIsBottom 
;	Gui, Add, CheckBox, xp+80 yp gIsClip vBottom, To End of Script
	;	###### SOURCE TAB ######
	Gui, Tab, Source
	Gui, Add, Edit, x10 y35 w370 h470 vSource ReadOnly,
	;	###### FORMS TAB ######
	Gui, Tab, Forms
	Gui, Add, Button, x10 y35 h22 gGetForms, Get Forms
	Gui, Add, DropDownList, xp+70 yp+1 w200 gLoadForm vSelForm AltSubmit,
	Gui, Add, Edit, xp-70 yp+50 w370 h215 Border vForm,
	Gui, Add, Text, xp yp+220 w150 h40 , Sample Script
	Gui, Add, Edit, xp yp+25 w370 h160 Border vSampleScript,
	Gui, Add, Button, xp+275 yp+185 hh22 gFormToClip, Copy to Clipboard
	;	###### ABOUT TAB ######
	Gui, Tab, About
	Gui, Add, GroupBox, x10 y30 w370 h70 , Main contributors to this project
	Gui, Add, Text, xp+10 yp+20 w50 h40 , Tank`nJethrow`nSinkfaze
;	Gui, Add, GroupBox, xp-10 yp+55 w370 h70 , Special thanks
;	Gui, Add, Text, xp+10 yp+20 w300, % "Chris Mallett - Creator of AutoHotkey`n"
;		. "Sean - Creator of COM Standard Library for AutoHotkey`n"
;		. "Lexikos - Creator of AutoHotkey_L (and much more)"
	Gui, Add, Picture, x80 y108 , ahklogo.png
;~ 	Gui, +AlwaysOnTop +LastFound
	Gui, +Delimiter`n
	Gui, Show, Center w390 h572, %GuiWinTitle% ; modified by jethrow
	OnMessage(WM_LBUTTONDOWN, "WM_LBUTTONDOWN")
	SetTimer, IsPaused, 1000
	;WinGet, GuiHWND, ID, % GuiWinTitle "ahk_class AutoHotkeyGUI" ; added by jethrow
	Gosub,ontop
    GetWin:
;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	While, GetKeyState("LButton","P") {
		WinGetPos, Wx, Wy, , , ahk_id %WinHWND%
		If(Wx <> Stored_Wx || Wy <> Stored_Wy)
			Outline("Hide")
		Sleep, 10
	}
	WinGetTitle, WinTitle, ahk_id %WinHWND%
	WinGetPos, Wx, Wy, Ww, Wh, ahk_id %WinHWND%
	If(Ww <> Stored_Ww || Wh <> Stored_Wh || WinTitle <> Stored_WinTitle) && (WinHWND = Stored_WinHWND)
		Outline("Hide"), Resized:=True ; Hide outline if the window either changes size or WinTitle (set variable "Resized" as true)
	Else If(Wx <> Stored_Wx || Wy <> Stored_Wy) && !Resized && (WinHWND = Stored_WinHWND) ; move outline if Window moves (not if window has been resized)
		Outline( x1+=Wx-Stored_Wx, y1+=Wy-Stored_Wy, x2+=Wx-Stored_Wx, y2+=Wy-Stored_Wy )
	Stored_Wx := Wx, Stored_Wy := Wy, Stored_Ww := Ww, Stored_Wh := Wh, Stored_WinTitle := WinTitle, Stored_WinHWND := WinHWND
	GoSub, SetOulineLevel	
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	
	if paused
		GoTo, GetWin
	GetKeyState("LButton","P") ? "" : IE_HtmlElement()
	Goto,GetWin



	ontop:
	{
		ontop:=ontop ? 0 : 1
		WinSet,AlwaysOnTop,% (ontop ? "on" : "off" ),%GuiWinTitle%
		Return
	}
	#s::
		psv:=COM_CreateObject("SAPI.SpVoice")
		COM_Invoke(psv, "Speak", textOfObj)
		COM_Release(psv)
	Return

	Pause::
	^/::
	paused:= paused ? "" : 1
	WinSetTitle, % GuiWinTitle "ahk_class AutoHotkeyGUI",, % GuiWinTitle (paused ? " (PAUSED)":"")
	SetTimer,GetWin,-10
	Return

	^e::
	MouseGetPos, , , wID
	Gui, Submit, NoHide
	if (CurrentTab<>1 || WinGetClass(wID)<>"IEFrame")
		return
	if theFrame {
		Pos=1
		While Pos:=RegExMatch(theFrame,"is)sourceIndex]=(.*?) \*\*\[name]= (.*?) \*\*\[id]= (\V*)",f,Pos+StrLen(f))
			fpath.=((f1) ? (f1) : ((f3) ? (f3) : (f2))) . (A_Index=1 ? "" : ",")
	}
	oFrm:=fpath ? ",""" fpath """" : ""
	dObj:=((EleName) ? (EleName) : ((EleIDs) ? (EleIDs) : (EleIndex)))
	pacc := iWebacc_AccessibleObjectFromPoint()
	oRole:=((paccChild:=iWebacc_Child(pacc, _idChild_)) ? iWebacc_Role(paccChild) : iWebacc_Role(pacc,_idChild_))
	oValue:=((paccChild:=iWebacc_Child(pacc, _idChild_)) ? iWebacc_Value(paccChild) : iWebacc_Value(pacc,_idChild_))
	if InStr(HTMLTag,"INPUT") {
		if RegExMatch(oRole,"(?:push|radio) button")
			res:="iWeb_clickDomObj(pwb,""" dObj """" oFrm ")"
			. "`niWeb_clickValue(pwb,""" html_value """" oFrm ")"
		else if (oRole="check box")
			res:="iWeb_clickDomObj(pwb,""" dObj """" oFrm ")"
			. "`niWeb_Checked(pwb,""" dObj """" oFrm ")"
		else
			res:="iWeb_setDomObj(pwb,""" dObj 
			. ((html_value) ? """,""" html_value """" oFrm ")" : """,""<< enter value >>""" oFrm ")")
	}
	else if (oRole="combo box")
		res:="iWeb_setDomObj(pwb,""" dObj
		 . ((html_value) ? """,""" html_value """" oFrm ")" : """,""<< enter value >>""" oFrm ")")
	else if InStr(link,RegExReplace(oRole,"\W"))
		res:="iWeb_clickDomObj(pwb,""" dObj """" oFrm ")"
		 . ((html_value) ? "`niWeb_clickText(pwb,""" html_value """" oFrm ")" : "")
		. ((RegExMatch(oValue,"^javascript")) ? "`niWeb_execScript(pwb,""" oValue """" oFrm ")" : "")
		. ((oValue) ? "`niWeb_clickHref(pwb,""" oValue """" oFrm ")" : "")
	else
		res:="iWeb_getDomObj(pwb,""" dObj """" oFrm ")"
	GuiControl, , iWeb, `n%res%
	TabActivate(0)
	WinGet, st, MinMax, %GuiWinTitle%
	if st=-1
		WinRestore, %GuiWinTitle%
	WinGetPos, x, y, , , %GuiWinTitle%
	WinMove, %GuiWinTitle%, , % x > A_ScreenWidth - 396 ? A_ScreenWidth - 396 : 
	 , % y > A_ScreenHeight - 572 ? 0 : , , % CurrentTab=1 ? 572 :  ; 278
	VarSetCapacity(res,0), VarSetCapacity(fpath,0)
	return
	
	F1::
	Gui, Submit, NoHide
	WinMove, %GuiWinTitle%, , , , , % CurrentTab=1 ? (GuiHeight()=582 ? 298 : 582) :  ; 278
	return
	F10::Reload
}
GuiClose:
COM_CoUninitialize()
ExitApp



IE_HtmlElement()
{
	CoordMode, Mouse
	MouseGetPos, xpos, ypos,, hCtl, 3
	WinGetClass, sClass, ahk_id %hCtl%
	If Not   sClass == "Internet Explorer_Server"
		|| Not   pdoc := IE_GetDocument(hCtl)
			Return


	GuiControl,Text,MouseX,%	xpos
	GuiControl,Text,MouseY,%	ypos
	pwin :=   COM_QueryService(pdoc ,"{332C4427-26CB-11D0-B483-00C04FD90119}")
	IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
	iWebBrowser2 := COM_QueryService(pwin,IID_IWebBrowserApp,IID_IWebBrowserApp)
	GuiControl,Text,WindowTitle,%	COM_Invoke(iWebBrowser2,"LocationName")
	GuiControl,Text,Title,%	COM_Invoke(iWebBrowser2,"LocationName")
	GuiControl,Text,URLL,% COM_Invoke(iWebBrowser2,"LocationURL")
	GuiControl,Text,browserHeight,%	 COM_Invoke(iWebBrowser2,"height")
	GuiControl,Text,browserWidth,%	 COM_Invoke(iWebBrowser2,"width")
	
	If   pelt := COM_Invoke(pwin , "document.elementFromPoint", xpos-xorg:=COM_Invoke(pwin ,"screenLeft"), ypos-yorg:=COM_Invoke(pwin ,"screenTop"))
	{
		framepath:=
		COM_Release(pwin)
		While   (type:=COM_Invoke(pelt,"tagName"))="IFRAME" || type="FRAME"
		{
			selt .=   "[" type "]." A_Index " **[sourceIndex]=" COM_Invoke(pelt,"sourceindex") " **[name]= " COM_Invoke(pelt,"name") " **[id]= " COM_Invoke(pelt,"id") "`n"
			framepath.=(COM_Invoke(pelt,"id") ? COM_Invoke(pelt,"id") :  COM_Invoke(pelt,"sourceindex")) ","
			pwin :=   COM_QueryService(pbrt:=COM_Invoke(pelt,"contentWindow"), "{332C4427-26CB-11D0-B483-00C04FD90119}"), COM_Release(pbrt), COM_Release(pdoc)
			pdoc :=   COM_Invoke(pwin, "document"), COM_Release(pwin)
			pbrt :=   COM_Invoke(pdoc, "elementFromPoint", xpos-xorg+=COM_Invoke(pelt,"getBoundingClientRect.left"), ypos-yorg+=COM_Invoke(pelt,"getBoundingClientRect.top")), COM_Release(pelt), pelt:=pbrt
		}

		pbrt :=   COM_Invoke(pelt, "getBoundingClientRect")
		l  :=   COM_Invoke(pbrt, "left")
		t  :=   COM_Invoke(pbrt, "top")
		r  :=   COM_Invoke(pbrt, "right")
		b  :=   COM_Invoke(pbrt, "bottom")
;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		global WinHWND, x1, y1, x2, y2
		WinHWND := COM_Invoke(iWebBrowser2, "HWND"), COM_Release(iWebBrowser2)
		If(x1 <> l+xorg || y1 <> t+yorg || x2 <> r+xorg || y2 <> b+yorg)
			Outline( x1:=l+xorg, y1:=t+yorg, x2:=r+xorg, y2:=b+yorg )
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	
		StringTrimRight,framepath,framepath,1
		GuiControl,Text,theFrame,%	selt
		GuiControl,Text,EleIndex,%	sI:=COM_Invoke(pelt,"sourceindex")
		GuiControl,Text,EleName,%	sName:=COM_Invoke(pelt,"name")
		GuiControl,Text,EleIDs,%	sID:=COM_Invoke(pelt,"id")
		GuiControl,Text,clientHeight,%	COM_Invoke(pdoc,"body.clientHeight")
		GuiControl,Text,clientWidth,%	COM_Invoke(pdoc,"body.clientWidth")
		GuiControl,Text,Source,%	COM_Invoke(pdoc,"documentelement.outerhtml")
		global textOfObj
;		GuiControl,Text,html_text
;		,%	(textOfObj:=inpt(pelt)) " `n" COM_Invoke(pelt, "outerhtml")
		textOfObj:=inpt(pelt)
		GuiControl, Text, html_value, % RegExReplace(textOfObj,"\[.*\]=")
		GuiControl, Text, html_text, % RegExReplace(COM_Invoke(pelt, "outerhtml"),"\[.*\]=")
		GuiControl,Text,HTMLTag,%	COM_Invoke(pelt,"tagName")
		innert:=COM_Invoke(pelt, "innerHTML")
		StringReplace, textOfObj, textOfObj,]=,?
		StringSplit,textOfObjs,textOfObj,?

		StringReplace,textOfObj,textOfObjs2,`,,&#44;,all
		optFrames:=framepath ? ", """ framepath """" : ""
		global element,optFrames
		element:=sID ? sID : sNames ? sName : sI
		optFrames:=framepath ? ", """ framepath """" : ""




		COM_Release(pbrt)
		COM_Release(pelt)

	}
	COM_Release(pdoc)
	Return
}

inpt(i)
{

	typ		:=	COM_Invoke(i,	"tagName")
	inpt	:=	"BUTTON,INPUT,OPTION,SELECT,TEXTAREA"
	Loop,Parse,inpt,`,
		if (typ	=	A_LoopField	?	1	:	"")
			Return "[value]=" COM_Invoke(i,	"value")
	Return "[innertext]=" COM_Invoke(i,	"innertext")
}

IE_GetDocument(hWnd)
{
   Static
   If Not   pfn
      pfn := DllCall("GetProcAddress", "Uint", DllCall("LoadLibrary", "str", "oleacc.dll"), "str", "ObjectFromLresult")
   ,   msg := DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
   ,   COM_GUID4String(iid, "{00020400-0000-0000-C000-000000000046}")
   If   DllCall("SendMessageTimeout", "Uint", hWnd, "Uint", msg, "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 1000, "UintP", lr:=0) && DllCall(pfn, "Uint", lr, "Uint", &iid, "Uint", 0, "UintP", pdoc:=0)=0
   Return   pdoc
}

;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
Outline(x1,y1="",x2="",y2="") {
	global WinHWND, Resized
	If x1 = Hide
	{
		Loop, 4
			Gui, % A_Index+1 ": Hide"
		Return
	}
	GoSub, SetOutlineTransparent
	Loop, 4 {
		Gui, % A_Index+1 ": Hide"
		Gui, % A_Index+1 ": -Caption +ToolWindow"
		Gui, % A_Index+1 ": Color" , Red
	}
	WinGetPos, Wx, Wy, , , ahk_id %WinHWND%
	ControlGetPos, Cx1, Cy1, Cw, Ch, Internet Explorer_Server1, ahk_id %WinHWND%
	Cx1 += Wx, Cy1 += Wy, Cx2 := Cx1+Cw, Cy2 := Cy1+Ch, Resized := False ; set "Internet Explorer_Server1" dimensions (set variable "Resized" as true)
	If(y1>Cy1)
		Gui, 2:Show, % "NA X" (x1<Cx1 ? Cx1 : x1)-2 " Y" (y1<Cy1 ? Cy1 : y1)-2 " W" (x2>Cx2 ? Cx2 : x2)-(x1<Cx1 ? Cx1 : x1)+4 " H" 2,outline1
	If(x2<Cx2)
		Gui, 3:Show, % "NA X" (x2>Cx2 ? Cx2 : x2) " Y" (y1<Cy1 ? Cy1 : y1) " W" 2 " H" (y2>Cy2 ? Cy2 : y2)-(y1<Cy1 ? Cy1 : y1),outline2
	If(y2<Cy2)
		Gui, 4:Show, % "NA X" (x1<Cx1 ? Cx1 : x1)-2 " Y" (y2>Cy2 ? Cy2 : y2) " W" (x2>Cx2 ? Cx2 : x2)-(x1<Cx1 ? Cx1 : x1)+4 " H" 2,outline3
	If(x1>Cx1)
		Gui, 5:Show, % "NA X" (x1<Cx1 ? Cx1 : x1)-2 " Y" (y1<Cy1 ? Cy1 : y1) " W" 2 " H" (y2>Cy2 ? Cy2 : y2)-(y1<Cy1 ? Cy1 : y1),outline4
	GoSub, SetOulineLevel
	Return
}
SetOutlineTransparent:
	Loop, 4
		WinSet, Transparent, 0, % outline%A_Index%
Return
SetOulineLevel:
	If Not outline1
		Loop, 4
			WinGet, outline%A_Index%, ID, % "outline" A_Index " ahk_class AutoHotkeyGUI"
	; thanks Chris! - http://www.autohotkey.com/forum/topic5672.html&highlight=getnextwindow
	hwnd_above := DllCall("GetWindow", "uint", WinHWND, "uint", 0x3) ; get window directly above "WinHWND"
	While(hwnd_above=outline1 || hwnd_above=outline2 || hwnd_above=outline3 || hwnd_above=outline4 || hwnd_above=GuiHWND) ; don't use 5 AHK GUIs
		hwnd_above := DllCall("GetWindow", "uint", hwnd_above, "uint", 0x3)
	; thanks Lexikos! - http://www.autohotkey.com/forum/topic22763.html&highlight=setwindowpos
	Loop, 4 { ; set 4 "outline" GUI's directly below "hwnd_above"
		DllCall("SetWindowPos", "uint", outline%A_Index%, "uint", hwnd_above
			, "int", 0, "int", 0, "int", 0, "int", 0
			, "uint", 0x13) ; NOSIZE | NOMOVE | NOACTIVATE ( 0x1 | 0x2 | 0x10 )
		WinSet, Transparent, 255, % outline%A_Index%
	}
Return
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^	



NewWindow:
{
	Gui,Submit,NoHide

	initString=
(
iWeb_Init()
pwb:=iWeb_newIe()
iWeb_nav("%URLL%")
)
	writeScript(initString)
	Return
}
InitWindow:
{
	Gui,Submit,NoHide
	initString=
(
iWeb_Init()
pwb:=iWeb_getwin("%Title%")
)
	writeScript(initString)


	Return
}

writeScript(code)
{
	global
	Gui,Submit,NoHide
	GuiControl,text,CodeWindow,% CodeWindow "`n" code
	Return



}

getURL(t)
{
	If	psh	:=	COM_CreateObject("Shell.Application") {
		If	psw	:=	COM_Invoke(psh,	"Windows") {
			Loop, %	COM_Invoke(psw,	"Count")
				If	url	:=	(InStr(COM_Invoke(psw,"Item[" A_Index-1 "].LocationName"),t) && InStr(COM_Invoke(psw,"Item[" A_Index-1 "].FullName"), "iexplore.exe")) ? COM_Invoke(psw,"Item[" A_Index-1 "].LocationURL") :
					Break
			COM_Release(psw)
		}
		COM_Release(psh)
	}
	Return	url
}



AddToScript:
{

	Gui, Submit, NoHide
	if InStr(Func,"List of functions")
		return
	StringReplace, Func, Func, `(`)
	 , % (RegExMatch(Func,"(?:Init|Term|newIe)") ? "()"
	 : (RegExMatch(Func,"(?:Release|Complete)") ? "(pwb)"
	 : (InStr(Func,"DomWin") ? "(pwb,"""")"
	 : (InStr(Func,"getWin") ? "(""" Title """)"
	 : (InStr(Func,"setDomObj") ? "(pwb,"""","""")"
	 : "(pwb,"""")")))))
	if sClip
		Clipboard:=InStr(Func,"getWin") ? "pwb:=" Func : Func
	else
		GuiControl, Text, CodeWindow, % (!CodeWindow || RegExMatch(CodeWindow,"\v+$"))
		 ? CodeWindow (InStr(Func,"getWin") ? "pwb:=" Func : Func)
		 : CodeWindow "`n" (InStr(Func,"getWin") ? "pwb:=" Func : Func)
	return
}

AddJscript:
{

	Gui,Submit,NoHide
	js=
	(
js=`n(`n%Javascript%`n)
iWeb_execScript(pwb,js %optFrames%)
	)
	writeScript(js)
	GuiControl,text,Javascript,
	Return
}

TestJscript:
{

	Gui,Submit,NoHide
	pwb:=iWeb_getwin(Title)
	iWeb_execScript(pwb,Javascript %optFrames%)
	COM_Release(pwb)
	Return
}

RunScript:

Gui,Submit,NoHide
if !ErrCheckInitTerm() || !ErrCheckPwb() || !ErrCheckBounds()
	return
pipe_name := "iWebBrowser2 Script Writer"
pipe_ga := CreateNamedPipe(pipe_name, 2)
pipe    := CreateNamedPipe(pipe_name, 2)
if (pipe=-1 or pipe_ga=-1) {
    MsgBox CreateNamedPipe failed.
    return
}
Run, %A_AhkPath% "\\.\pipe\%pipe_name%"
DllCall("ConnectNamedPipe","uint",pipe_ga,"uint",0)
DllCall("CloseHandle","uint",pipe_ga)
DllCall("ConnectNamedPipe","uint",pipe,"uint",0)
Script := chr(239) chr(187) chr(191) CodeWindow
if !DllCall("WriteFile","uint",pipe,"str",Script,"uint",StrLen(Script)+1,"uint*",0,"uint",0)
    MsgBox WriteFile failed: %ErrorLevel%/%A_LastError%
DllCall("CloseHandle","uint",pipe)
Return


SaveScript:
{


	Gui,Submit,NoHide
	FileSelectFile,script
	FileDelete,%script%
	FileAppend,%CodeWindow%,%script%
	Return
}

CopyToWriter:
Gui, Submit, NoHide
if (A_GuiEvent<>"DoubleClick")
	return
if iClip
	Clipboard:=iWeb
else
	GuiControl, Text, CodeWindow
	 , % ((!CodeWindow || RegExMatch(CodeWindow,"\v$")) ? CodeWindow iWeb : CodeWindow "`n" iWeb)
WinActivate, %GuiWinTitle%
TabActivate(1)
return

IsPaused:
ControlGet, a, Tab, , SysTabControl321, %GuiWinTitle%
if a=1
	prevSt:=paused
return

IsRolled:
Gui, Submit, NoHide
paused:=((CurrentTab=1) ? prevSt : ((CurrentTab=4) ? 0 : 1))
WinSetTitle, %GuiWinTitle%,, % GuiWinTitle ((CurrentTab=1 && !prevSt) || CurrentTab=4 ? "" : " (PAUSED)")
WinMove, %GuiWinTitle%, , , , , % (CurrentTab=2 || CurrentTab=6) ? 298 : 617
return

GetForms:
Pos:=1
Gui, Submit, NoHide
While Pos:=RegExMatch(Source,"is)(?P<t><FORM.*?>).*?</FORM>",o,Pos+StrLen(o)) 
{ 
   RegExMatch(ot," (?:name|id)=\s?(?P<ni>\w+)",m) 
   flist.=(A_Index=1 ? mni "`n" : "`n" mni), f%A_Index%:=o 
}
GuiControl, , SelForm, `n%flist%
GuiControl, , Form, % (flist ? f1 : "")
VarSetCapacity(flist,0)
LoadForm:
Gui, Submit, NoHide
GuiControl, , Form, % f%SelForm%
forminfo:=Get_forms(f%SelForm%)
FormID:="Form ID " (formname ? formname : SelForm-1)
GuiControl, , SampleScript, % forminfo
return
Get_forms(fSelForm)
{
	global formname,optFrames,SelForm,Title
	pdoc:=iWeb_Txt2Doc(fSelForm)
	formname:=COM_Invoke(pdoc,"forms[0].elements.name") ? COM_Invoke(pdoc,"forms[0].elements.name") : SelForm-1
	iwebstring=
	(
	/*
****Disclaimer:
This code is experimental and should not be relied upon without thorough testing


*/
iWeb_Init()
pwb:=iWeb_getwin("%Title%")
	)
	
	Loop % COM_Invoke(pdoc,"forms[0].elements.length")
	{
		ordinal:=A_Index-1
		tagname:=COM_Invoke(pdoc,"forms[0].elements[" ordinal "].tagname")
		selectedindex:=
		Checked	:=
		If	tagname=select
			selectedindex:=COM_Invoke(pdoc,"forms[0].elements[" ordinal "].selectedindex")
		Else	type:=COM_Invoke(pdoc,"forms[0].elements[" ordinal "].type")
		If	(type="radio" || type="checkbox")
			Checked	:=COM_Invoke(pdoc,"forms[0].elements[" ordinal "].checked") ? 1 : 0
		ID:=COM_Invoke(pdoc,"forms[0].elements[" ordinal "].id")
		name:=COM_Invoke(pdoc,"forms[0].elements[" ordinal "].name")
		value:=COM_Invoke(pdoc,"forms[0].elements[" ordinal "].value")
		elementRef:=ID ? ID : name ? name : ordinal
		element.=elementRef "=" value "`n"  ;; might one day use this to create a simple postdata string
		StringReplace,value,value,`,,&#44;,all	;	escape all commas in text extracted always
		StringReplace,elementRef,elementRef,`,,&#44;,all	;	escape all commas in text extracted always
		If	(StrLen(selectedindex) || StrLen(Checked))
			iwebstring.= StrLen(selectedindex) ? "iWeb_SelectOption(pwb,""" elementRef """," selectedindex optFrames ")" : StrLen(Checked) ? "iWeb_Checked(pwb,""" elementRef """," Checked optFrames ")" : ""
		Else	If	(type <> "button" &&  type <> "submit" && type <> "reset")
		{
			values.=value ","
			elementRefs.=elementRef ","
		}
		iwebstring.= "`n"
	}
	If	elementRefs
		iwebstring.="iWeb_setDomObj(pwb,""" elementRefs """,""" values """" optFrames ")`n"
	footer=
	(
COM_Invoke(pWin:=iWeb_DomWin(pwb%optFrames%),"document.forms[%formname%].submit")
iWeb_Release(pWin)
iWeb_Release(pwb)
iWeb_Term()	
	)
	iwebstring.=footer
	Loop,Parse,iwebstring,`n
		If	A_LoopField
			iwebstrings.=A_LoopField "`n"
;~ 	MsgBox	% iwebstrings
	COM_Release(pdoc)
	Return	iwebstrings
}

FormToClip:
Gui, Submit, NoHide
Clipboard:=Form
return

iWebacc_Query(pacc, bunk = "")
{
	If	DllCall(NumGet(NumGet(1*pacc)+0), "Uint", pacc, "Uint", COM_GUID4String(IID_IAccessible,bunk ? "{00020404-0000-0000-C000-000000000046}" : "{618736E0-3C3D-11CF-810C-00AA00389B71}"), "UintP", pobj)=0
		DllCall(NumGet(NumGet(1*pacc)+8), "Uint", pacc), pacc:=pobj
	Return	pacc
}

iWebacc_AccessibleObjectFromPoint(x = "", y = "", ByRef _idChild_ = "")
{
	VarSetCapacity(varChild,16,0)
	x<>""&&y<>"" ? pt:=x&0xFFFFFFFF|y<<32 : DllCall("GetCursorPos", "int64P", pt)
	DllCall("oleacc\AccessibleObjectFromPoint", "int64", pt, "UintP", pacc, "Uint", &varChild)
	_idChild_ := NumGet(varChild,8)
	Return	pacc
}

iWebacc_Child(pacc, idChild)
{
	If	DllCall(NumGet(NumGet(1*pacc)+36), "Uint", pacc, "int64", 3, "int64", idChild, "UintP", paccChild)=0 && paccChild
	Return	iWebacc_Query(paccChild)
}

iWebacc_Name(pacc, idChild = 0)
{
	If	DllCall(NumGet(NumGet(1*pacc)+40), "Uint", pacc, "int64", 3, "int64", idChild, "UintP", pName)=0 && pName
	Return	COM_Ansi4Unicode(pName) . SubStr(COM_SysFreeString(pName),1,0)
}

iWebacc_Value(pacc, idChild = 0)
{
	If	DllCall(NumGet(NumGet(1*pacc)+44), "Uint", pacc, "int64", 3, "int64", idChild, "UintP", pValue)=0 && pValue
	Return	COM_Ansi4Unicode(pValue) . SubStr(COM_SysFreeString(pValue),1,0)
}

iWebacc_Role(pacc, idChild = 0)
{
	VarSetCapacity(var,16,0)
	If	DllCall(NumGet(NumGet(1*pacc)+52), "Uint", pacc, "int64", 3, "int64", idChild, "Uint", &var)=0
	Return	iWebacc_GetRoleText(NumGet(var,8))
}

iWebacc_State(pacc, idChild = 0)
{
	VarSetCapacity(var,16,0)
	If	DllCall(NumGet(NumGet(1*pacc)+56), "Uint", pacc, "int64", 3, "int64", idChild, "Uint", &var)=0
	Return	iWebacc_GetStateText(nState:=NumGet(var,8)) . "`t(" . iWebacc_Hex(nState) . ")"
}

iWebacc_GetRoleText(nRole)
{
	nSize := DllCall("oleacc\GetRoleTextA", "Uint", nRole, "Uint", 0, "Uint", 0)
	VarSetCapacity(sRole, nSize)
	DllCall("oleacc\GetRoleTextA", "Uint", nRole, "str", sRole, "Uint", nSize+1)
	Return	sRole
}

iWebacc_GetStateText(nState)
{
	nSize := DllCall("oleacc\GetStateTextA", "Uint", nState, "Uint", 0, "Uint", 0)
	VarSetCapacity(sState, nSize)
	DllCall("oleacc\GetStateTextA", "Uint", nState, "str", sState, "Uint", nSize+1)
	Return	sState
}

iWebacc_Hex(num)
{
	old := A_FormatInteger
	SetFormat, Integer, H
	num += 0
	SetFormat, Integer, %old%
	Return	num
}

CreateNamedPipe(Name, OpenMode=3, PipeMode=0, MaxInstances=255) {
    return DllCall("CreateNamedPipe","str","\\.\pipe\" Name,"uint",OpenMode
        ,"uint",PipeMode,"uint",MaxInstances,"uint",0,"uint",0,"uint",0,"uint",0)
}

GuiHeight() {
	global GuiWinTitle
	WinGetPos, , , , h, %GuiWinTitle%
	return h
}

TabActivate(no) {
	global GuiWinTitle
	SendMessage, 0x1330, %no%,, SysTabControl321, %GuiWinTitle%
	Sleep 50
	SendMessage, 0x130C, %no%,, SysTabControl321, %GuiWinTitle%
	return
}

WinGetClass(ID) {
	WinGetClass, res, ahk_id %ID%
	return res
}

ErrCheckInitTerm() {
	global CodeWindow
	i:=j:=errlvl:=0
	Loop, Parse, CodeWindow, `n
	{
		if InStr(A_LoopField,"iWeb_Init()") {
			++i
			init%i%:=A_Index
		}
		if InStr(A_LoopField,"iWeb_Term()") {	
			++j
			term%j%:=A_Index
		}
	}
	if (i <> j) {
		MsgBox, 48, iWebBrowser2 Script Writer Warning, % "Script Writer has detected that you do not have an equal number of:`n`n"
			. "`tiWeb_Init() and iWeb_Term() statements`n`n"
			. "Please double check your code and try again."
		return 0
	}
	Loop % i {
		if (init%A_Index% > term%A_Index%) {
			errlvl=1
			Break
		}
	}
	if errlvl {
		MsgBox, 48, iWebBrowser2 Script Writer Warning, % "Script Writer has detected that the following sequences are not in order:`n`n"
			. "`tiWeb_Init() and iWeb_Term() statements`n`n"
			. "Please double check your code and try again."
		return 0
	}
	return 1
}

ErrCheckPwb() {
	global CodeWindow
	i:=j:=errlvl:=0
	Loop, Parse, CodeWindow, `n
	{
		if RegExMatch(A_LoopField,"pwb:=iWeb_getWin\(.*?\)") {
			++i
			gwin%i%:=A_Index
		}
		if InStr(A_LoopField,"COM_Release(pwb)") {
			++j
			crls%j%:=A_Index
		}
	}
	if (i <> j) {
		MsgBox, 48, iWebBrowser2 Script Writer Warning, % "Script Writer has detected that you do not have an equal number of:`n`n"
			. "`tiWeb_getWin() and COM_Release() statements`n`n"
			. "Please double check your code and try again."
		return 0
	}
	Loop % i {
		if (gwin%A_Index% > crls%A_Index%) {
			errlvl=1
			Break
		}
	}
	if errlvl {
		MsgBox, 48, iWebBrowser2 Script Writer Warning, % "Script Writer has detected that the following sequences are not in order:`n`n"
			. "`tiWeb_getWin() and COM_Release() statements`n`n"
			. "Please double check your code and try again."
		return 0
	}
	return 1
}

ErrCheckBounds() {
	global CodeWindow
	ipos:=InStr(CodeWindow,"iWeb_Init"), tpos:=InStr(CodeWindow,"iWeb_Term")
	Pos:=1,errlvl=0
	While Pos:=RegExMatch(CodeWindow,"(?:iWeb_getWin\(.*?\)|COM_Release\(pwb\))",p,Pos+StrLen(p))
	{
		chk:=Pos+StrLen(p)
		if chk not between %ipos% and %tpos%
		{
				errlvl=1
				break
		}
	}
	if errlvl {
		MsgBox, 48, iWebBrowser2 Script Writer Warning, % "Script Writer has detected that your iWeb_getWin() and COM_Release() statements`n"
		. "         are not properly bound between iWeb_Init() and iWeb_Term() statements.`n`n"
		. "Please double check your code and try again."
		return 0
	}
	return 1
}

;	credit below to toralf
;	http://www.autohotkey.com/forum/topic8976.html
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd){       ;Copy-On-Click for controls
    global 

	Gui, Submit, NoHide
    If A_GuiControl is space                     ;Control is not known
        Return
	If InStr(Copyable,A_GuiControl) {
		Clipboard:=%A_GuiControl%
		if !Clipboard
			return
        ToolTip("Contents copied to Clipboard.`n" (StrLen(Clipboard) > 25 ? SubStr(Clipboard,1,25) "..." : Clipboard))
		return
	}
	return
}

ToolTip(Text, TimeOut=1000){
    ToolTip, %Text%
    SetTimer, RemoveToolTip, %TimeOut%
    Return
}
RemoveToolTip:
   ToolTip
Return