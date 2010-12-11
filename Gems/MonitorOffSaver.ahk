;MonitorOffSaver.ahk
; Screensaver that turns off the screen.
;Skrommel @2006

#SingleInstance,Force
#NoTrayIcon

applicationname=MonitorOffSaver

Gosub,READINI

StringLeft,param,1,2
If (param="" Or param="/c") 
  Goto,OPTIONS
If (param="/p")
  ExitApp

SendMessage, 0x112, 0xF170, %mode%,, Program Manager   ; 0x112 is WM_SYSCOMMAND, 0xF170 is SC_MONITORPOWER.
Sleep,1000
ExitApp

OPTIONS:
Gui,Destroy
Gui,Add,Tab,W330 H280 xm,Options|About

Gui,Tab,1
Gui,Add,GroupBox,w310 h120 xm+10 y+10,Power &mode
check=
If mode=1
  checked=Checked
Gui,Add,Radio,xm+30 yp+30 Vomode1 %checked%,Low power mode
checked=
If (mode<>1 And mode<>-1)
  checked=Checked
Gui,Add,Radio,xm+30 y+10 Vomode2 %checked%,Power &Off
checked=
If mode=-1
  checked=Checked
Gui,Add,Radio,xm+30 y+10 Vomode3 %checked%,&Power On

Gui,Tab,2
Gui,Add,Picture,xm+20 ym+30 Icon1,%applicationname%.scr
Gui,Font,Bold
Gui,Add,Text,x+10 yp+10,%applicationname% v1.0
Gui,Font
Gui,Add,Text,xm+20 yp+30,Screensaver that turns off the screen.
Gui,Add,Text,,- Low power, Power off and Power on.
Gui,Add,Text,,Made using AutoHotkey - 
Gui,Font,CBlue Underline
Gui,Add,Text,x+5 GAUTOHOTKEY,http://www.autohotkey.com
Gui,Font
Gui,Add,Text,,`t
Gui,Add,Picture,Icon5 xm+20 yp+10,%applicationname%.scr
Gui,Font,Bold
Gui,Add,Text,x+10 yp+10,1 Hour Software by Skrommel
Gui,Font
Gui,Add,Text,xm+20 yp+30,For more tools and information, please stop by at
Gui,Font,CBlue Underline
Gui,Add,Text,GWWW,http://www.donationcoders.com/skrommel
Gui,Font
Gui,Add,Text,

Gui,Tab,
Gui,Add,Button,GSETTINGSOK Default xm+20 y+30 w75,&OK
Gui,Add,Button,GSETTINGSCANCEL x+5 W75,&Cancel
Gui,Show,,%applicationname% Settings
Return


SETTINGSOK:
Gui,Submit
If omode1=1
  mode:=1
If omode2=1
  mode:=2
If omode3=1
  mode:=-1
Gosub,WRITEINI
Gosub,SETTINGSCANCEL
ExitApp


SETTINGSCANCEL:
Gui,Destroy
ExitApp


AUTOHOTKEY:
Run,http://www.autohotkey.com,,UseErrorLevel
Return


WWW:
Run,http://www.donationcoders.com/skrommel,,UseErrorLevel
Return


READINI:
IfNotExist,%applicationname%.ini
{
  mode=2
  Gosub,WRITEINI
}
Else
  IniRead,mode,%applicationname%.ini,Settings,mode
Return


WRITEINI:
Iniwrite,%mode%,%applicationname%.ini,Settings,mode
Return
