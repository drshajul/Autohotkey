C# := LoadC#()
atchs := A_ScriptFullPath . "|" . A_ScriptDir . "\Hello.htm"
    ; Create array of strings (references) -> SAFEARRAY.
    StrSafeArray(arr, atchs)
    ; Create CompilerParameters object.
    atchParam := COM_Parameter(0x2008, &arr)

CLR_StartDomain( mailDomain ) 
if not ( asm := CLR_CompileC#(C#, "System.dll|System.Windows.Forms.dll", mailDomain ) )
  MsgBox Could not compile C#
mail := CLR_CreateObject(asm, "iMail")
mail.iSend(atchParam)
CLR_StopDomain( mailDomain ) 

StrSafeArray(Byref aRefs, sArray) {
  StringSplit, Refs, sArray, |, %A_Space%%A_Tab%
  VarSetCapacity(aRefs,24+4*Refs0,0), NumPut(Refs0,aRefs,16)
  NumPut(&aRefs+24,NumPut(4,NumPut(1,aRefs,0,"Ushort")+2)+4)
  Loop, %Refs0%
      NumPut(CLR_BSTR(Refs%A_Index%,Refs%A_Index%), aRefs, 20+4*A_Index)
}

LoadC#() {
c# =
(
using System;
using System.Windows.Forms;
 
public class iMail
{
  public bool iSend(string[] attachments) 
  {
   try
    {
     foreach(string Attachment in attachments)
         MessageBox.Show(Attachment);
    }
    catch (Exception ex)
    {
      MessageBox.Show(ex.ToString());
      return false;
    }
   return true;
  }
}
)
return c#
}