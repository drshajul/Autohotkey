Process Priority,,High                 ; Run faster
SetBatchLines -1

RC4Pass := "pa$sw0rd ?J?éäD<?aÔ±QxUî½¹Üp"

RC4Data := "Rajat is cool, shajul's mod is cooler. AutoHotkey unleashes the full potential of your keyboard, joystick, and mouse. For example, in addition to the typical Control, Alt, and Shift modifiers, you can use the Windows key and the Capslock key as modifiers."

RC4Enc := RC4txt2hex(RC4Data "`n" RC4Data "`n" RC4Data "`n" RC4Data "`n" RC4Data,RC4Pass)
RC4Dec := RC4hex2txt(RC4Enc,RC4Pass)
MsgBox %RC4Data%`n`nEncrypted 5-times with pass:`n`n%RC4Pass%`n`nto`n`n%RC4Enc%`n`nDecypted to`n`n%RC4Dec%

ExitApp

RC4txt2hex(Data,Pass) {
   Format := A_FormatInteger
   SetFormat Integer, Hex
   b := 0, j := 0
   VarSetCapacity(Result,StrLen(Data)*2)
   Loop 256
      a := A_Index - 1
     ,Key%a% := Asc(SubStr(Pass, Mod(a,StrLen(Pass))+1, 1))
     ,sBox%a% := a
   Loop 256
      a := A_Index - 1
     ,b := b + sBox%a% + Key%a%  & 255
     ,sBox%a% := (sBox%b%+0, sBox%b% := sBox%a%) ; SWAP(a,b)
   Loop Parse, Data
      i := A_Index & 255
     ,j := sBox%i% + j  & 255
     ,k := sBox%i% + sBox%j%  & 255
     ,sBox%i% := (sBox%j%+0, sBox%j% := sBox%i%) ; SWAP(i,j)
     ,Result .= SubStr(Asc(A_LoopField)^sBox%k%, -1, 2)
   StringReplace Result, Result, x, 0, All
   SetFormat Integer, %Format%
   Return Result
}

RC4hex2txt(Data,Pass) {
   b := 0, j := 0, x := "0x"
   VarSetCapacity(Result,StrLen(Data)//2)
   Loop 256
      a := A_Index - 1
     ,Key%a% := Asc(SubStr(Pass, Mod(a,StrLen(Pass))+1, 1))
     ,sBox%a% := a
   Loop 256
      a := A_Index - 1
     ,b := b + sBox%a% + Key%a%  & 255
     ,sBox%a% := (sBox%b%+0, sBox%b% := sBox%a%) ; SWAP(a,b)
   Loop % StrLen(Data)//2
      i := A_Index  & 255
     ,j := sBox%i% + j  & 255
     ,k := sBox%i% + sBox%j%  & 255
     ,sBox%i% := (sBox%j%+0, sBox%j% := sBox%i%) ; SWAP(i,j)
     ,Result .= Chr((x . SubStr(Data,2*A_Index-1,2)) ^ sBox%k%)
   Return Result
}