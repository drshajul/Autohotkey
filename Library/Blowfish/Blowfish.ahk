; http://www.autohotkey.com/forum/viewtopic.php?t=4631
Data = my test data
pw = password

pw := encpass(pw)
msgbox %pw%



res := encrypt(data,pw)
msgbox %res%

res := decrypt(res,pw)
msgbox %res%




;used to encrypt a password to make it a lot more secure
EncPass(Key)
{
   ;VarSetCapacity(Output, 2048) 

   ATrim = %A_AutoTrim%
   AutoTrim, Off

   Ret := DllCall("blowfish.dll\Encpass", "str", "aircdll.dll", "str", "Encpass", "str", Key, "Cdecl")
   StringTrimLeft, Key, Key, 4

   AutoTrim, %ATrim%
   Return Key
}



Encrypt(Data,Key)
{
   ;VarSetCapacity(Output, 2048) 

   ATrim = %A_AutoTrim%
   AutoTrim, Off

   Output = %Key%%A_Space%%Data%
   Ret := DllCall("blowfish.dll\Encrypt", "str", "aircdll.dll", "str", "Encrypt", "str", Output, "Cdecl")
   StringTrimLeft, Output, Output, 4

   AutoTrim, %ATrim%
   Return Output
}



Decrypt(Data,Key)
{
   ;VarSetCapacity(Output, 2048) 

   ATrim = %A_AutoTrim%
   AutoTrim, Off

   Output = %Key%%A_Space%%Data%
   Ret := DllCall("blowfish.dll\Decrypt", "str", "aircdll.dll", "str", "Decrypt", "str", Output, "Cdecl")
   StringTrimLeft, Output, Output, 4 

   AutoTrim, %ATrim%
   Return Output
}