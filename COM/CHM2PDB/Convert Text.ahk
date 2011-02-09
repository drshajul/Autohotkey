#SingleInstance force

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

IniRead, IsiloPath, chm2pdb.ini, iSiloX, Path
if IsiloPath=error
  IsiloPath=
if IsiloPath
  GuiControl,, IsiloPath, %IsiloPath%
else
  IsiloPath=%A_ProgramFiles%\iSilo\iSiloX\iSiloX.exe

IniRead, LastDir, chm2pdb.ini, Main, LastDir
if LastDir=error
  LastDir=
  
IniRead, LastDest, chm2pdb.ini, Main, LastDest
if LastDest=error
  LastDest=
if LastDest
  GuiControl,, DestPDB, %LastDest%
else
  LastDest=%A_MyDocuments%

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
if errorlevel=0
  {
  GuiControl,, IsiloPath, %IsiloPath%
  IniWrite, %IsiloPath%, chm2pdb.ini, iSiloX, Path
  }
return

SourceCHM:
FileSelectFile, SourceCHM, 3, %LastDir% , Please select CHM file to convert, Compiled Help Files (*.chm)
if errorlevel=0
  {
  GuiControl,, SourceCHM, %SourceCHM%
  SplitPath, SourceCHM ,, LastDir
  IniWrite, %LastDir%, chm2pdb.ini, Main, LastDir
  }
return

DestPDB:
FileSelectFolder, DestPDB, *%LastDest%,, Select folder to save iSilo PDB
if errorlevel=0
  {
  GuiControl,, DestPDB, %DestPDB%
  IniWrite, %DestPDB%, chm2pdb.ini, Main, LastDest
  }
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

SplitPath, SourceCHM,,,,tvar
StringReplace, tvar, tvar, %A_Space%,_,1
Progress,,,Converting with iSiloX..
;; Step 3
FileRead, myixl, template.ixl
StringReplace, myixl, myixl,*mysourcepath*, %SourceCHM%
StringReplace, myixl, myixl,*mytitle*,%tvar%
StringReplace, myixl, myixl,*mydestinationpath*,%DestPDB%\
FileAppend , %myixl%, D:\Temp\%tvar%\%tvar%.ixl

SplitPath, IsiloPath,,IsiloDir
Run, "%IsiloPath%" -x D:\Temp\%tvar%\%tvar%.ixl -a "%IsiloDir%"
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
MsgBox, 64, About Chm2PdbConvert, Chm 2 Pdb Converter v%A_AhkVersion%`n`nFreeware`, (c) Shajul., 6
