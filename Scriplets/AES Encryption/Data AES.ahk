Data	:= "This script is just too cool $ hello !*"
sPassword	:= "what the f pass$wo&d"

SID := 192	; 128 for 128bit, 192 for 192bit AES, 256
MsgBox % Data_AES(Data, sPassword, SID, True)	; Encryption
Sleep 100
MsgBox % Data_AES(Data, sPassword, SID, False)	; Decryption

Data_AES(Data, sPassword, SID = 256, bEncrypt = True)
{
	;nSize := A_IsUnicode ? StrLen(Data)*2 : StrLen(Data)
	nSize := StrLen(Data)*2
	VarSetCapacity(sData, nSize + (bEncrypt ? 16 : 0))
	StrPut(Data,&sData,nSize)
	nSize := Crypt_AES(&sData, nSize, sPassword, SID, bEncrypt)
	Return sData
}

Crypt_AES(pData, nSize, sPassword, SID = 256, bEncrypt = True)
{
	CALG_AES_256 := 1 + CALG_AES_192 := 1 + CALG_AES_128 := 0x660E
	CALG_SHA1 := 1 + CALG_MD5 := 0x8003
	DllCall("advapi32\CryptAcquireContext", "UintP", hProv, "Uint", 0, "Uint", 0, "Uint", 24, "Uint", 0xF0000000)
	DllCall("advapi32\CryptCreateHash", "Uint", hProv, "Uint", CALG_SHA1, "Uint", 0, "Uint", 0, "UintP", hHash)
	DllCall("advapi32\CryptHashData", "Uint", hHash, "Uint", &sPassword, "Uint", StrLen(sPassword)*2, "Uint", 0)
	DllCall("advapi32\CryptDeriveKey", "Uint", hProv, "Uint", CALG_AES_%SID%, "Uint", hHash, "Uint", SID<<16, "UintP", hKey)
	DllCall("advapi32\CryptDestroyHash", "Uint", hHash)
	bEncrypt 
	? DllCall("advapi32\CryptEncrypt", "Uint", hKey, "Uint", 0, "Uint", True, "Uint", 0, "Uint", pData, "UintP", nSize, "Uint", nSize+16)
	: DllCall("advapi32\CryptDecrypt", "Uint", hKey, "Uint", 0, "Uint", True, "Uint", 0, "Uint", pData, "UintP", nSize)
	DllCall("advapi32\CryptDestroyKey", "Uint", hKey)
	DllCall("advapi32\CryptReleaseContext", "Uint", hProv, "Uint", 0)
	Return	nSize
}
