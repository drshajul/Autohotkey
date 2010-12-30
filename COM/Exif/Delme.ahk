MCode(BSwap16,"8AE18AC5C3")
ret := dllcall(&BSwap16, "Short", 0x1234, "cdecl ushort")
MsgBox % "ret is " . ret . " and hex is" . Mem2Hex(&ret,2)

MCode(ByRef code, hex) { ; allocate memory and write Machine Code there
   VarSetCapacity(code,StrLen(hex)//2)
   Loop % StrLen(hex)//2
  {
    number1 := "0x" . SubStr(hex,2*A_Index-1,2)
    NumPut(number1, code, A_Index-1, "Char")
  }
}


Mem2Hex(pointer,len)  ;http://www.autohotkey.com/forum/viewtopic.php?p=220160
{ 
 A_FI := A_FormatInteger 
 SetFormat, Integer, Hex 
 Loop, %len%  
 { 
  Hex := *Pointer+0 
  StringReplace, Hex, Hex, 0x, 0x0 
  StringRight Hex, Hex, 2            
  hexDump .= hex 
  Pointer ++ 
 } 
 SetFormat, Integer, %A_FI% 
 StringUpper, hexDump, hexDump 
 Return hexDump 
}