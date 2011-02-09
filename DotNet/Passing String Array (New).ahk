arr := ComObjArray(8,2)
arr[0] := "Hello "
arr[1] := "World"

param := COM_Parameter(0x2008, ComObjValue(arr))

asm := CLR_CompileC#(LoadC#(), "System.dll|System.Windows.Forms.dll" )
obj := CLR_CreateObject(asm, "Test")
obj.StringTest(param)

LoadC#() {
c# =
(
using System;
using System.Windows.Forms;
 
public class Test
{
  public void StringTest(string[] mystrings) 
  {
     foreach(string mystring in mystrings)
         MessageBox.Show(mystring);
  }
}
)
return c#
}