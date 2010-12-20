sFileOriginl	:= A_ScriptFullPath
Password	:= "AutoHotkey"
SID := 256	; 128 for 128bit, 192 for 192bit AES
sFileEncrypt := A_ScriptDir . "\encrypt" . SID . ".bin"
sFileDecrypt := A_ScriptDir . "\decrypt" . SID . ".ahk"

StrPutVar(Password, sPassword, "UTF-8")


File_AES(sFileOriginl, sFileEncrypt, sPassword, SID, True)	; Encryption
File_AES(sFileEncrypt, sFileDecrypt, sPassword, SID, False)	; Decryption

File_AES(sFileFr, sFileTo, sPassword, SID = 256, bEncrypt = True)
{
	hFileFr := FileOpen(sFileFr,"r -r")
	if not hFileFr
		Return	"File not found!"
	nSize := hFileFr.Length
	VarSetCapacity(sData, nSize + (bEncrypt ? 16 : 0))
	hFileFr.Seek(0)
	hFileFr.RawRead(sData, nSize)
	hFileFr.Close()
	hFileTo := FileOpen(sFileTo,"w -r")
	if not hFileTo
		Return	"File not created/opened!"
	nSize := Crypt_AES(&sData, nSize, sPassword, SID, bEncrypt)
	hFileTo.RawWrite(sData, nSize)
	hFileTo.Close()
		Return	nSize
}

Crypt_AES(pData, nSize, sPassword, SID = 256, bEncrypt = True)
{
	CALG_AES_256 := 1 + CALG_AES_192 := 1 + CALG_AES_128 := 0x660E
	CALG_SHA1 := 1 + CALG_MD5 := 0x8003
	DllCall("advapi32\CryptAcquireContext", "Ptr*", hProv, "Ptr", 0, "Ptr", 0, "Ptr", 24, "Ptr", 0xF0000000)
	DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "Ptr", CALG_SHA1, "Ptr", 0, "Ptr", 0, "Ptr*", hHash)
	DllCall("advapi32\CryptHashData", "Ptr", hHash
	, "Ptr", &sPassword
	, "Ptr", (A_IsUnicode ? StrLen(sPassword)*2 : StrLen(sPassword)), "Ptr", 0)
	DllCall("advapi32\CryptDeriveKey", "Ptr", hProv, "Ptr", CALG_AES_%SID%, "Ptr", hHash, "Ptr", SID<<16, "Ptr*", hKey)
	DllCall("advapi32\CryptDestroyHash", "Ptr", hHash)
	If	bEncrypt
		DllCall("advapi32\CryptEncrypt", "Ptr", hKey, "Ptr", 0, "Ptr", True, "Ptr", 0, "Ptr", pData, "Ptr*", nSize, "Ptr", nSize+16)
	Else	DllCall("advapi32\CryptDecrypt", "Ptr", hKey, "Ptr", 0, "Ptr", True, "Ptr", 0, "Ptr", pData, "Ptr*", nSize)
	DllCall("advapi32\CryptDestroyKey", "Ptr", hKey)
	DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "Ptr", 0)
	Return	nSize
}

StrPutVar(string, ByRef var, encoding)
{
    VarSetCapacity( var, StrPut(string, encoding) * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    return StrPut(string, &var, encoding)
}