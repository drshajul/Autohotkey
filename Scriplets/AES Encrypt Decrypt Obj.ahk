sFileOriginl	:= A_ScriptFullPath
sPassword	:= "AutoHotkey"

SID := 256	; 128 for 128bit, 192 for 192bit AES
sFileEncrypt := A_ScriptDir . "\encrypt" . SID . ".bin"
sFileDecrypt := A_ScriptDir . "\decrypt" . SID . ".ahk"
File_AES(sFileOriginl, sFileEncrypt, sPassword, SID, True)	; Encryption
File_AES(sFileEncrypt, sFileDecrypt, sPassword, SID, False)	; Decryption

File_AES(sFileFr, sFileTo, sPassword, SID = 256, bEncrypt = True)
{
	hFileFr := FileOpen(sFileFr,"r")
	if not hFileFr
		Return	"File not found!"
	nSize := hFileFr.Length
	VarSetCapacity(sData, nSize + (bEncrypt ? 16 : 0))
	hFileFr.RawRead(&sData, nSize)
	hFileFr.Close()
	hFileTo := FileOpen(sFileTo,"w")
	if not hFileTo
		Return	"File not created/opened!"
	nSize := Crypt_AES(&sData, nSize, sPassword, SID, bEncrypt)
	hFileTo.RawWrite(&sData, nSize)
	hFileTo.Close()
		Return	nSize
}

Crypt_AES(pData, nSize, sPassword, SID = 256, bEncrypt = True)
{
	CALG_AES_256 := 1 + CALG_AES_192 := 1 + CALG_AES_128 := 0x660E
	CALG_SHA1 := 1 + CALG_MD5 := 0x8003
	DllCall("advapi32\CryptAcquireContext", "UintP", hProv, "Uint", 0, "Uint", 0, "Uint", 24, "Uint", 0xF0000000)
	DllCall("advapi32\CryptCreateHash", "Uint", hProv, "Uint", CALG_SHA1, "Uint", 0, "Uint", 0, "UintP", hHash)
	DllCall("advapi32\CryptHashData", "Uint", hHash, "Uint", &sPassword, "Uint", StrLen(sPassword), "Uint", 0)
	DllCall("advapi32\CryptDeriveKey", "Uint", hProv, "Uint", CALG_AES_%SID%, "Uint", hHash, "Uint", SID<<16, "UintP", hKey)
	DllCall("advapi32\CryptDestroyHash", "Uint", hHash)
	If	bEncrypt
		DllCall("advapi32\CryptEncrypt", "Uint", hKey, "Uint", 0, "Uint", True, "Uint", 0, "Uint", pData, "UintP", nSize, "Uint", nSize+16)
	Else	DllCall("advapi32\CryptDecrypt", "Uint", hKey, "Uint", 0, "Uint", True, "Uint", 0, "Uint", pData, "UintP", nSize)
	DllCall("advapi32\CryptDestroyKey", "Uint", hKey)
	DllCall("advapi32\CryptReleaseContext", "Uint", hProv, "Uint", 0)
	Return	nSize
}