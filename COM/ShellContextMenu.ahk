sPath := A_ScriptFullPath
SplitPath, sPath, sName, sDir
objShell := ComObjCreate("Shell.Application")
Loop % objShell.NameSpace[sDir].ParseName[sName].Verbs.Count
{
   verbList .= (verb := objShell.NameSpace[sDir].ParseName[sName].Verbs.Item(A_Index-1).Name) ? verb . "`n": ""
   if ( verb = "PSPad" )
      objShell.NameSpace[sDir].ParseName[sName].Verbs.Item(A_Index-1).DoIt()
}
MsgBox % verbList