if 0>0
	param := %1%

Gui, Add, Text, x2 y4 w300 h16 , Enter password to encrypt/decrypt:
Gui, Add, Edit, x2 y20 w300 h20 +Password vsPassword, 
Gui, Add, GroupBox, x2 y45 w300 h60 , Delete
Gui, Add, CheckBox, x12 y60 w280 h20 vDel, De&lete the file after encryption/decryption
Gui, Add, CheckBox, x12 y80 w280 h20 vWipe, &Wipe Delete file after encryption/decryption
Gui, Add, GroupBox, x2 y105 w300 h60 , Other options
Gui, Add, CheckBox, x12 y120 w280 h20 vOverwrite, &Overwrite file if exists
Gui, Add, Text, x32 y143 h16 , AES 256 bit
/* Gui, Add, Radio, x62 y140 w80 h20 , 128 bit
 * Gui, Add, Radio, x142 y140 w80 h20 , 192 bit
 * Gui, Add, Radio, x222 y140 w70 h20 checked, 256 bit
 */
Gui, Add, ListView, x305 y5 w170 h160 , DRAG & DROP FILES HERE
Gui, Add, Button, x72 y170 w80 h20 , &Encrypt
Gui, Add, Button, x152 y170 w80 h20 , &Decrypt
Gui, +AlwaysOnTop +ToolWindow
if param
	Gui, Show, w305 h194, Encrypt / Decrypt
else
	Gui, Show, w479 h194, Encrypt / Decrypt
Return

GuiClose:
ExitApp

GuiDropFiles:
Loop, parse, A_GuiEvent, `n
{
    MsgBox, 4,, File number %A_Index% is:`n%A_LoopField%.`n`nContinue?
    IfMsgBox, No, Break
}
return

sFileOriginl	:= A_ScriptFullPath
sPassword	:= "AutoHotkey"

SID := 256	; 128 for 128bit, 192 for 192bit AES
sFileEncrypt := A_ScriptDir . "\encrypt" . SID . ".bin"
sFileDecrypt := A_ScriptDir . "\decrypt" . SID . ".ahk"
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
	DllCall("advapi32\CryptAcquireContext", "UintP", hProv, "Uint", 0, "Uint", 0, "Uint", 24, "Uint", 0xF0000000)
	DllCall("advapi32\CryptCreateHash", "Uint", hProv, "Uint", CALG_SHA1, "Uint", 0, "Uint", 0, "UintP", hHash)
	DllCall("advapi32\CryptHashData", "Uint", hHash, "Uint", &sPassword
	, "Uint", (A_IsUnicode ? StrLen(sPassword)*2 : StrLen(sPassword)), "Uint", 0)
	DllCall("advapi32\CryptDeriveKey", "Uint", hProv, "Uint", CALG_AES_%SID%, "Uint", hHash, "Uint", SID<<16, "UintP", hKey)
	DllCall("advapi32\CryptDestroyHash", "Uint", hHash)
	bEncrypt
	? DllCall("advapi32\CryptEncrypt", "Uint", hKey, "Uint", 0, "Uint", True, "Uint", 0, "Uint", pData, "UintP", nSize, "Uint", nSize+16)
	: DllCall("advapi32\CryptDecrypt", "Uint", hKey, "Uint", 0, "Uint", True, "Uint", 0, "Uint", pData, "UintP", nSize)
	DllCall("advapi32\CryptDestroyKey", "Uint", hKey)
	DllCall("advapi32\CryptReleaseContext", "Uint", hProv, "Uint", 0)
	Return	nSize
}