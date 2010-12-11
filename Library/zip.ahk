/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       _   _          ______
      | | | |        |___  /         N A T I V E   D A T A   C O M P R E S S I O N.
      | | | | __ _ _ __ / /          www.autohotkey.com/forum/viewtopic.php?t=45559
      | | | |/ _` | '__/ /           by SURESH KUMAR A N [ arian.suresh@gmail.com ]
      \ \_/ / (_| | |./ /___         Created: 19-Jun-2009  | Last Edit: 21-Jun-2009
       \___/ \__,_|_|\_____/         Note:   Required OS  -  Windows 2000 and later
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*/

VarZ_Compress( byref V, Max=1 ) {
 If ( NumGet(V)=0x5F5A4C && ( (M:=NumGet(V,12,"UShort"))=0x102||M=0x2) )
   Return -2                                                    ;    already LZ compressed
 DllCall( "ntdll\RtlGetCompressionWorkSpaceSize", UInt,M:=(!!Max<<8)+2,UIntP,WZ,UIntP,CZ )
 VarSetCapacity(WS,WZ), VZ := VarSetCapacity(V),  TZ := VarSetCapacity(TV,VZ)
 If NTSTATUS := DllCall( "ntdll\RtlCompressBuffer", UInt,M, Str,V, UInt,VZ, Str,TV, UInt
                                                  ,TZ, UInt,CZ,UIntP,F ,UInt,&WS, UInt )
   Return -1 + ( (errorLevel:=NTSTATUS)<<64 )                   ;       unable to compress
 VarsetCapacity(V,0), VarSetCapacity(V,F+18,0), pV:=&V+18, NumPut(0x5F5A4C,V)
 Numput(M,V,12,"UShort"),NumPut(VZ,V,14), DllCall( "RtlMoveMemory",UInt,pV,Str,TV,UInt,F )
 DllCall( "shlwapi\HashData", UInt,&V+12,UInt,F+6,Int64P,H,UInt,8 ), NumPut(H,V,4,"Int64")
Return VarSetCapacity(V)
}

VarZ_Decompress( byref V ) {
 If ! ( NumGet(V)=0x5F5A4C && ( (M:=NumGet(V,12,"UShort"))=0x102||M=0x2) )
   Return -2                                                    ;        not LZ compressed
 VZ := VarSetCapacity(V)-18, TZ := NumGet(V,14), VarSetCapacity(TV,TZ,0), pV:=&V+18
 DllCall( "shlwapi\HashData", UInt,&V+12, UInt,VZ+6, Int64P,H, UInt,8 )
 If ( H <> NumGet(V,4,"Int64") )
   Return -3                                                    ; Hash fail = data corrupt
 If NTSTATUS := DllCall( "ntdll\RtlDecompressBuffer", UInt,M, Str,TV, UInt,TZ, UInt,pV
                                                   , UInt,VZ, UIntP,F, UInt )
   Return -1 + ( (errorLevel:=NTSTATUS)<<64 )                   ;     unable to decompress
 V:="", VarSetCapacity(V,F,0), DllCall( "RtlMoveMemory", Str,V, Str,TV, UInt,F )
 Return VarSetCapacity(V)
}

VarZ_Load( byRef V, File="" ) {
 FileGetSize, Sz, %File%
 FileRead, V, %File%
 Return ErrorLevel ? 0 : Sz
}

VarZ_Save( byRef V, File="" ) { ;   www.autohotkey.net/~Skan/wrapper/FileIO16/FileIO16.ahk
Return ( ( hFile :=  DllCall( "_lcreat", Str,File, UInt,0 ) ) > 0 )
                 ?   DllCall( "_lwrite", UInt,hFile, Str,V, UInt,VarSetCapacity(V) )
                 + ( DllCall( "_lclose", UInt,hFile ) << 64 ) : 0
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - End of wrapper

; The following code is for testing and is not part of the wrapper and maybe omitted

StringReplace, File, A_AhkPath, autohotkey.exe, license.txt
oSize := VarZ_Load( Data, File )
oHash := MD5( Data )

cSize := VarZ_Compress( Data )
cHash := MD5( Data )

dSize := VarZ_Decompress( Data )
dHash := MD5( Data )

MsgBox, 0, %File%, % "Original:`nSize: " oSize "`t`tMD5: " oHash "`n`nCompressed:`nSize: "
     . cSize "`t`tMD5: " cHash "`n`nDecompressed:`nSize: " dSize "`t`tMD5: " dHash
     . "`n`n==> Compressed data was "  Round(cSize/oSize*100) "% of the original size."
Return

MD5( ByRef V, L=0 ) { ;             www.autohotkey.com/forum/viewtopic.php?p=275910#275910
 VarSetCapacity( MD5_CTX,104,0 ), DllCall( "advapi32\MD5Init", Str,MD5_CTX )
 DllCall( "advapi32\MD5Update", Str,MD5_CTX, Str,V, UInt,L ? L : VarSetCapacity(V) )
 DllCall( "advapi32\MD5Final", Str,MD5_CTX )
 Loop % StrLen( Hex:="123456789ABCDEF0" )
  N := NumGet( MD5_CTX,87+A_Index,"Char"), MD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)
Return MD5
}