; DATA COMPRESSION
infile := FileOpen(A_ScriptFullPath, "r") 
len := infile.length
infile.RawRead(MyData,len)
if (r := zlib_Compress(CompressedData , MyData, len))
 MsgBox % "Data compressed " . round((r/len)*100) . "%"
else MsgBox Error Errorlevel %Errorlevel%
infile.Close()

; DATA DECOMPRESSION
if (t := zlib_Decompress(Inflated,CompressedData,r,len))
 MsgBox % StrGet(&Inflated,len,"")
else MsgBox Error Errorlevel %Errorlevel%
ExitApp


zlib_Compress(Byref Compressed, Byref Data, DataLen, level = -1) {
nSize := DllCall("zlib1\compressBound", "UInt", DataLen, "Cdecl")
VarSetCapacity(Compressed,nSize)
ErrorLevel := DllCall("zlib1\compress2", "ptr", &Compressed, "UIntP", nSize, "ptr", &Data, "UInt", DataLen, "Int"
               , level    ;level 0 (no compression), 1 (best speed) - 9 (best compression)
               , "Cdecl") ;0 means Z_OK
return ErrorLevel ? 0 : nSize
}

zlib_Decompress(Byref Decompressed, Byref CompressedData, DataLen, OriginalSize = -1) {
OriginalSize := (OriginalSize > 0) ? OriginalSize : DataLen*10 ;should be large enough for most cases
VarSetCapacity(Decompressed,OriginalSize)
ErrorLevel := DllCall("zlib1\uncompress", "Ptr", &Decompressed, "UIntP", OriginalSize, "Ptr", &CompressedData, "UInt", DataLen)
return ErrorLevel ? 0 : OriginalSize
}

/*
Return codes for the compression/decompression functions. Negative values are errors, positive values are used for special but normal events.
#define Z_OK            0
#define Z_STREAM_END    1
#define Z_NEED_DICT     2
#define Z_ERRNO        (-1)
#define Z_STREAM_ERROR (-2)
#define Z_DATA_ERROR   (-3)
#define Z_MEM_ERROR    (-4)
#define Z_BUF_ERROR    (-5)
#define Z_VERSION_ERROR (-6)

Compression levels.
#define Z_NO_COMPRESSION         0
#define Z_BEST_SPEED             1
#define Z_BEST_COMPRESSION       9
#define Z_DEFAULT_COMPRESSION  (-1)
*/