#SingleInstance force
#NoEnv
Loop, %0%  ; For each parameter:
    params .= A_Space . %A_Index%
ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"
if not A_IsAdmin
{
  A_IsCompiled
    ? DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
    : DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
  ExitApp
}

Menu, tray, NoStandard
Menu, tray, Add, &Help, HelpMe
Menu, tray, Add, &About, AboutMe
Menu, tray, add, E&xit, GuiClose

Menu, FileMenu, Add, E&xit, GuiClose
Menu, HelpMenu, Add, &Help, HelpMe
Menu, HelpMenu, Add
Menu, HelpMenu, Add, &About, AboutMe
Menu, MyMenuBar, Add, &File, :FileMenu  ; Attach the two sub-menus that were created above.
Menu, MyMenuBar, Add, &Help, :HelpMenu

Gui, Add, GroupBox, x6 y30 w460 h50, Path of IsiloX 
Gui, Add, Edit, x16 y50 w410 h20 vIsiloPath,   
Gui, Add, Button, x426 y49 w24 h22 gIsiloPath, .. 
Gui, Add, GroupBox, x6 y90 w460 h80, Convert 
Gui, Add, Edit, x76 y110 w350 h20 vSourceCHM,   
Gui, Add, Button, x426 y109 w24 h22 gSourceCHM, ..
Gui, Add, Text, x16 y110 w40 h20, Source 
Gui, Add, Text, x16 y140 w60 h20, Destination
Gui, Add, Edit, x76 y140 w350 h20 vDestPDB, 
Gui, Add, Button, x426 y139 w24 h22 gDestPDB, ..
Gui, Add, Button, x6 y180 w80 h30 g,&Go 
Gui, Add, Button, x96 y180 w80 h30, &Cancel
Gui, Add, Button, x436 y180 w30 h30 gHelpMe,?
Gui, Menu, MyMenuBar

IniRead, IsiloPath, chm2pdb.ini, iSiloX, Path,0
if IsiloPath
  GuiControl,, IsiloPath, %IsiloPath%

IniRead, LastDir, chm2pdb.ini, Main, LastDir
IniRead, LastDest, chm2pdb.ini, Main, LastDest
if LastDest
  GuiControl,, DestPDB, %LastDest%
else
  LastDest := A_MyDocuments

SysGet, Monitor, Monitor
MonitorBottom -= 60
MonitorRight -= 320

Gui, Show, h227 w477, Shajul CHM to Isilo PDB Convertor
Return

ButtonCancel:
GuiClose:
ExitApp

IsiloPath:
FileSelectFile, IsiloPath, 3, %IsiloPath% , Please locate IsiloX.exe, iSiloX (iSiloX.exe)
if errorlevel
  return
GuiControl,, IsiloPath, %IsiloPath%
IniWrite, %IsiloPath%, chm2pdb.ini, iSiloX, Path
return

SourceCHM:
FileSelectFile, SourceCHM, 3, %LastDir% , Please select CHM file to convert, Compiled Help Files (*.chm)
if errorlevel
  return
GuiControl,, SourceCHM, %SourceCHM%
SplitPath, SourceCHM ,, LastDir
IniWrite, %LastDir%, chm2pdb.ini, Main, LastDir
return

DestPDB:
FileSelectFolder, DestPDB, *%LastDest%,, Select folder to save iSilo PDB
if errorlevel
  return
GuiControl,, DestPDB, %DestPDB%
IniWrite, %DestPDB%, chm2pdb.ini, Main, LastDest
return

ButtonGo:
GUI, submit
if (IsiloPath="" or SourceCHM="" or DestPDB="")
  {
  MsgBox, 48, Incomplete Input, Incomplete data to convert.. Please try again!, 
  return
  }
IfNotExist, %SourceCHM%
  {
  MsgBox, 48, Error, Input file does not exist! Try again.
  return
  }

Progress, m2 b x%MonitorRight% y%MonitorBottom% cwNavy ctYellow zx0 zy2 fm10 fs10 zh0,,Decompiling..

SplitPath, SourceCHM,,,,sTitle
SplitPath, A_WinDir,,,,,thisdrive
StringReplace, sTitle, sTitle, %A_Space%,_,1
Loop, %SourceCHM%
    ShortSource = %A_LoopFileShortPath%

DestFolder = %thisdrive%\chm2pdb\%sTitle%
runwait, hh -decompile %DestFolder% %ShortSource%,,hide UseErrorLevel
If ErrorLevel=ERROR
{
  MsgBox, 16, Error, Could not decompile file..`n`nQuitting!
  ExitApp 
} 

sleep 1000
Progress,,,Creating Table of Contents..

;; Step 2 - Create TOC file
TOCFile = %DestFolder%\chm2pdb_TOC.htm
Loop, %DestFolder%\*.hhc
{
  FileRead, html, %A_LoopFileLongPath%
 
  doc := ComObjCreate("HTMLfile")
  doc.write(html)

  ul := doc.getElementsByTagName("UL")
  mainNode := ul[0].childNodes
  txt =
  (
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
  <html>
  <head>
  <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">
  <title>Index</title>
  </head>
  <body>
  )
  txt .= DisplayNode(mainNode, indent=0)
  txt .= "</body>`n</html>"
  FileAppend, %txt%, %TOCFile%
}

sleep 1000
IfNotExist, %DestFolder%\chm2pdb_TOC.htm
  {
  MsgBox, 16, Error, Could not create TOC file..`n`nThe decompiled files can be found in %DestFolder% 
  ExitApp
  }
Progress,,,Converting with iSiloX..
;; Step 3
FileRead, myixl, template.ixl
StringReplace, myixl, myixl,*mysourcepath*, %TOCFile%
StringReplace, myixl, myixl,*mytitle*,%sTitle%
StringReplace, myixl, myixl,*mydestinationpath*,%DestPDB%\
FileAppend , %myixl%, %DestFolder%\%sTitle%.ixl

SplitPath, IsiloPath,,IsiloDir
Run, "%IsiloPath%" -x %DestFolder%\%sTitle%.ixl -a "%IsiloDir%"
;;               -x filename  Convert document list with filename
;;               -o filename  Option settings filename
;;               -a path      Base application file path
;;               -u           Update list status after conversion
;;               -H[pse]      Hide window
;;                              p   Progress dialog
;;                              s   Successful conversion messages
;;                              e   Conversion error messages
;;               -s           Perform a scheduled conversion


ExitApp
return

HelpMe:
Run, hh.exe Help.chm,,Max
return

AboutMe:
MsgBox, 64, About Chm2Pdb Convert, Chm 2 Pdb Converter v2.0`n`nCopyright Shajul`, 2010., 10
return



DisplayNode(node, indent=0)
{
   text .= "<ul>`n"
   Loop, % node.length
   {
   nIndex := A_Index-1
    ; MsgBox % node[nIndex].InnerHTML   ;LI inner
   if not node[nIndex].getElementsByTagName("UL").length
     {
     if (node[nIndex].childNodes[0].childNodes[0].getAttribute("name") = "Name")
       LinkText := node[nIndex].childNodes[0].childNodes[0].getAttribute("value")
     if (node[nIndex].childNodes[0].childNodes[1].getAttribute("name") = "Local")
       LinkURL := node[nIndex].childNodes[0].childNodes[1].getAttribute("value")
     text .= spaces(indent) . "<li><a href=""" . LinkURL . """>" . LinkText . "</a></li>`n"
     }
   else
     {
     if (node[nIndex].childNodes[0].childNodes[0].getAttribute("name") = "Name")
       LinkText := node[nIndex].childNodes[0].childNodes[0].getAttribute("value")
     text .= spaces(indent) . "<li><a href=""#"">" . LinkText . "</a></a></li>`n"
     text .= DisplayNode(node[nIndex].childNodes[1].childNodes, indent+2)
     }
   }
   text .= "</ul>`n"
   return text
}

spaces(n)
{
   Loop, %n%
      t .= " "
   return t
}

