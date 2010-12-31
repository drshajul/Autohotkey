;Origional by majkinetor
;modified by ahklerner for this script
Rebar_Add(hGui, hCtrl, text, break = false, x1 = 0, y1 = 0, h1 = 0, w1 = 0) {
	static  ICC_COOL_CLASSES := 0x400, REBARCLASSNAME = "ReBarWindow32"
	static  WS_EX_TOOLWINDOW := 0x80, WS_CHILD := 0x40000000, WS_VISIBLE := 0x10000000,  WS_CLIPSIBLINGS = 0x4000000, WS_CLIPCHILDREN = 0x2000000
	static  RBS_VARHEIGHT=0x200, CCS_NODIVIDER = 0x40, RBS_BANDBORDERS=0x400, RB_INSERTBAND   = 0x401
	static  RBBIM_CHILD = 0x10, RBBIM_STYLE = 0x1, RBBIM_TEXT = 0x4, RBBIM_CHILDSIZE = 0x20,RBBIM_SIZE = 0x40
	static  RBBS_BREAK=1, RBBS_FIXEDBMP=0x20, RBBS_NOVERT=0x10, RBBS_CHILDEDGE=0x4, RBBS_USECHEVRON=0x200, RBBS_FIXEDSIZE=0x2, RBBS_GRIPPERALWAYS = 0x80, RBBS_HIDETITLE = 0x400, RBBS_NOGRIPPER = 0x100, RBBS_TOPALIGN = 0x800
	static SM_CYCAPTION, SM_CYBORDER
	static init, hReBar
	DetecthiddenWindows, on
	if !init {
		init := true
		SysGet, SM_CYCAPTION, 4
		SysGet, SM_CYBORDER, 6
		VarSetCapacity(ICCE, 8)
		NumPut(8, ICCE, 0)
		NumPut(ICC_COOL_CLASSES, ICCE, 4)
		if !DllCall("comctl32.dll\InitCommonControlsEx", "uint", &ICCE) {
			return 0
			}
		hRebar := DllCall("CreateWindowEx"
			, "uint", WS_EX_TOOLWINDOW
			, "str",  REBARCLASSNAME
			, "uint", 0
			, "uint", WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS |  WS_CLIPCHILDREN | RBS_VARHEIGHT | CCS_NODIVIDER | RBS_BANDBORDERS
			, "uint", 0, "uint", 0, "uint", 0, "uint", 0
			, "uint", hGui
			, "uint", 0
			, "uint", 0
			, "uint", 0, "Uint")
		If !hRebar {
			return 0
			}
		}
	VarSetCapacity( BAND, 80, 0 )
	NumPut(80,BAND, 0)      
	fMask  := RBBIM_STYLE | RBBIM_TEXT | RBBIM_CHILD | RBBIM_CHILDSIZE | RBBIM_SIZE
	fStyle := RBBS_CHILDEDGE | RBBS_GRIPPERALWAYS ; | RBBS_FIXEDSIZE ; 
	;fStyle := RBBS_CHILDEDGE | RBBS_FIXEDSIZE  | RBBS_GRIPPERALWAYS 
	fStyle |= break ? RBBS_BREAK : 0
	NumPut(fMask,  BAND, 4)
	NumPut(fStyle, BAND, 8)
	WinGetClass, Class, ahk_id %hCtrl%
	if Child := DllCall("IsChild", "uint", hCtrl) || (Class = "ToolbarWindow32")|| (Class = "Static") 
		ControlGetPos, ,,w,h, ,ahk_id %hCtrl% 
	else {
		WinGetPos    , ,,w,h, ahk_id %hCtrl%
		}
	NumPut(&Text   ,BAND, 20)         ;lpText
	NumPut(hCtrl   ,BAND, 32)         ;hwndChild
	NumPut(w      ,BAND, 36)         ;cyMinChild
	NumPut(h      ,BAND, 40)         ;cyMinChild
	NumPut(100      ,BAND, 44)         ;cx
	SendMessage, RB_INSERTBAND, -1, &BAND,, ahk_id %hReBar%
	If !ErrorLevel {
		return 0
		}
	Return hRebar
	}
