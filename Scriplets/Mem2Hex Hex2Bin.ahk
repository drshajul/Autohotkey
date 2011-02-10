Data	:= "This script is just too cool $ hello !*"
sHex := Mem2Hex(&Data,StrLen(Data)*2)
Hex2Bin(varout, sHex)
MsgBox % StrGet(&varout)

Hex2Bin(ByRef BinaryOut, HexString) {
  n := StrLen(HexString)/2
  VarSetCapacity(BinaryOut,n)
  Loop, % n
    NumPut("0x" . SubStr(HexString,(A_Index*2)-1,2),BinaryOut,(A_Index-1))
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