; init section
#SingleInstance force
#InstallMouseHook

CustomColor = EEAA99  ; Can be any RGB color (it will be made transparent below).
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
Gui, Color, %CustomColor%
Gui, Font, s48  ; Set a large font size (48-point).
Gui, Add, Text, vMyText cLime, Media Mouse Mode  ; XX & YY serve to auto-size the window.
; Make all pixels of this color transparent and make the text itself translucent (150):
WinSet, TransColor, %CustomColor%  ; 150

; initial state : all hooks off, mouse mode
remoteMode := false
Hotkey, LButton, Off
Hotkey, WheelDown, Off
Hotkey, WheelUp, Off
Hotkey, MButton, Off

return


RButton::
   ErrorLevel := 0 ;dont know what was there before me
   pressTime := 0
   keyDownTime := A_TickCount
   KeyWait, RButton, T3
   ; we only care about the duration if there's no errorlevel (else its over 3 seconds)
   if (ErrorLevel != 1) {
      keyUpTime := A_TickCount
      pressTime := keyUpTime - keyDownTime
      if (pressTime < 3000) {
         if (!remoteMode) {
            Suspend, On ;we suspend so we dont get called again and stuck in a loop
            Send, {Click Right}
            Suspend, Off
            return
         }
         ; send a "next" key
         Send {Media_Next}
         return
      }
   }
   remoteMode := !remoteMode
   if (!remoteMode) {
      Gui, Hide
      Hotkey, LButton, Off
      Hotkey, WheelDown, Off
      Hotkey, WheelUp, Off
      Hotkey, MButton, Off
   } else {
      Gui, Show, center NoActivate
      Hotkey, LButton, On
      Hotkey, WheelDown, On
      Hotkey, WheelUp, On
      Hotkey, MButton, On
   }
   return

LButton::
   if (remoteMode) {
      Send {Media_Prev}
      return
   }
   MsgBox, this should never happen!
   return
   
WheelDown::
   if (remoteMode) {
      Send {Volume_Down}
      return
   }
   MsgBox, this should never happen!
   return
   
WheelUp::
   if (remoteMode) {
      Send {Volume_Up}
      return
   }
   MsgBox, this should never happen!
   return

MButton::
   if (remoteMode) {
      Send {Media_Play_Pause}
      return
   }
   MsgBox, this should never happen!
   return