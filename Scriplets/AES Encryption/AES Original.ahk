sFileOriginl	:= A_ScriptFullPath
sPassword	:= "AutoHotkey"

SID := 256	; 128 for 128bit, 192 for 192bit AES
sFileEncrypt := A_ScriptDir . "\encrypt" . SID . ".bin"
sFileDecrypt := A_ScriptDir . "\decrypt" . SID . ".exe"
MsgBox % File_AES(sFileOriginl, sFileEncrypt, sPassword, SID, True)	; Encryption
MsgBox % File_AES(sFileEncrypt, sFileDecrypt, sPassword, SID, False)	; Decryption

File_AES(sFileFr, sFileTo, sPassword, SID = 256, bEncrypt = True)
{
	If	!(1 + hFileFr := File_CreateFile(sFileFr, 3, 0x80000000, 1))
		Return	"File not found!"
	DllCall("GetFileSizeEx", "Uint", hFileFr, "int64P", nSize)
	VarSetCapacity(sData, nSize + (bEncrypt ? 16 : 0))
	DllCall("ReadFile", "Uint", hFileFr, "Uint", &sData, "Uint", nSize, "UintP", nSize, "Uint", 0)
	DllCall("CloseHandle", "Uint", hFileFr)
	If	!(1 + hFileTo := File_CreateFile(sFileTo, 2, 0x40000000, 1))
		Return	"File not created/opened!"
	nSize := Crypt_AES(&sData, nSize, sPassword, SID, bEncrypt)
	DllCall("WriteFile", "Uint", hFileTo, "Uint", &sData, "Uint", nSize, "UintP", nSize, "Uint", 0)
	DllCall("CloseHandle", "Uint", hFileTo)
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
	bEncrypt 
	? DllCall("advapi32\CryptEncrypt", "Uint", hKey, "Uint", 0, "Uint", True, "Uint", 0, "Uint", pData, "UintP", nSize, "Uint", nSize+16)
	: DllCall("advapi32\CryptDecrypt", "Uint", hKey, "Uint", 0, "Uint", True, "Uint", 0, "Uint", pData, "UintP", nSize)
	DllCall("advapi32\CryptDestroyKey", "Uint", hKey)
	DllCall("advapi32\CryptReleaseContext", "Uint", hProv, "Uint", 0)
	Return	nSize
}

File_CreateFile(sFile, nCreate = 3, nAccess = 0x1F01FF, nShare = 3, bFolder = False)
{
	; CREATE_NEW = 1 | CREATE_ALWAYS = 2 | OPEN_EXISTING = 3 | OPEN_ALWAYS = 4 
	; GENERIC_READ = 0x80000000 | GENERIC_WRITE = 0x40000000 | GENERIC_EXECUTE = 0x20000000 | GENERIC_ALL  = 0x10000000
	; FILE_SHARE_READ = 1 | FILE_SHARE_WRITE = 2 | FILE_SHARE_DELETE = 4
	Return	DllCall("CreateFile", "Uint", &sFile, "Uint", nAccess, "Uint", nShare, "Uint", 0, "Uint", nCreate, "Uint", bFolder ? 0x02000000 : 0, "Uint", 0)
}