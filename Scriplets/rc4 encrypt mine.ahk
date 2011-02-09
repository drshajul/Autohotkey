PW := "pa$sw0rd ?J?ιδD<?aΤ±QxUξ½Ήάp"
RC4Data := "Rajat is cool, shajul's mod is cooler. AutoHotkey unleashes the full potential of your keyboard, joystick, and mouse. For example, in addition to the typical Control, Alt, and Shift modifiers, you can use the Windows key and the Capslock key as modifiers."
loop, 5
	Data .= RC4Data . "`n"

Gosub, RC4
oFile := FileOpen("pwd.dat","w","UTF-16-RAW")
oFile.Write(Result)
oFile.Close()
MsgBox, %Result%

Data := 0
iFile := FileOpen("pwd.dat","r","UTF-16-RAW")
Data := iFile.Read()
Gosub, RC4
iFile.Close()
MsgBox, %Result%


ExitApp


;___RC4_____________________________________

RC4:
	ATrim = %A_AutoTrim%
	AutoTrim, Off
	BLines = %A_BatchLines%
	SetBatchlines, -1

	StringLen, PWLen, PW
	IfNotEqual, PW, %OldPW%
	{
		Loop, 256
		{
			a := A_Index - 1
			ModVal := Mod(a,PWLen) + 1
			Key%a% := Asc(SubStr(PW, ModVal, 1))
			sBox%a% = %a%
		}
		b = 0
		Loop, 256
		{
			a := A_Index - 1
			b := Mod(b + sBox%a% + Key%a%,256)
			sBox%a% ^= sBox%b% , sBox%b% ^= sBox%a% , sBox%a% ^= sBox%b% ;swap variables
		}
		OldPW = %PW%
	}

	StringLen, DataLen, Data
	Result := "" 
	i = 0
	j = 0
	Loop, %DataLen%
	{
		i := Mod( i + 1 , 256 )
		j := Mod( sBox%i% + j , 256 )
		TmpVar2 := Mod( sBox%i% + sBox%j% , 256 )
		k := sBox%TmpVar2%
		AscVar := Asc(SubStr( Data, A_Index, 1 ))
		C := AscVar ^ k
		C := C ? C : k
		ChrVar := Chr(C)
		Result .= ChrVar
	}
	AutoTrim, %ATrim%
	SetBatchlines, %BLines%
Return

;___RC4_____________________________________
