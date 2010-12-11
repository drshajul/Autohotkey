
Run, mspaint.exe

Sleep, 1000
; Show an error message because this isn't a picture file
PostMessage, 0x233, HDrop(A_MyDocuments), 0,, ahk_class MSPaintApp
ExitApp

/*
Return a handle to a structure describing files to be droped.
Use it with PostMessage to send WM_DROPFILES messages to windows.

fnames is a list of paths delimited by `n or `r`n
x and y are the coordinates where files are droped in the window.

Eg. :
; Open autoexec.bat in an existing Notepad window.
PostMessage, 0x233, HDrop("C:\autoexec.bat"), 0,, ahk_class Notepad
*/

HDrop(fnames,x=0,y=0) {
   fns:=RegExReplace(fnames,"\n$")
   fns:=RegExReplace(fns,"^\n")
   hDrop:=DllCall("GlobalAlloc","UInt",0x42,"UInt",20+StrLen(fns)+2)
   p:=DllCall("GlobalLock","UInt",hDrop)
   NumPut(20, p+0)  ;offset
   NumPut(x,  p+4)  ;pt.x
   NumPut(y,  p+8)  ;pt.y
   NumPut(0,  p+12) ;fNC
   NumPut(0,  p+16) ;fWide
   p2:=p+20
   Loop,Parse,fns,`n,`r
   {
      DllCall("RtlMoveMemory","UInt",p2,"Str",A_LoopField,"UInt",StrLen(A_LoopField))
      p2+=StrLen(A_LoopField)+1
   }
   DllCall("GlobalUnlock","UInt",hDrop)
   Return hDrop
}