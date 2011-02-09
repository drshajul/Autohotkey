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
Gui, Show, h227 w477, Shajul CHM to Isilo PDB Convertor
Return

ButtonCancel:
GuiClose:
ExitApp

IsiloPath:
FileSelectFile, IsiloPath, Options, RootDir[\DefaultFilename], Prompt, Filter]
return

SourceCHM:
return

DestPDB:
return

ButtonGo:
return

HelpMe:
return
