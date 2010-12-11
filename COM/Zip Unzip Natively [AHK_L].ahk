/*           ,---,                                          ,--,    
           ,--.' |                                        ,--.'|    
           |  |  :                      .--.         ,--, |  | :    
  .--.--.  :  :  :                    .--,`|       ,'_ /| :  : '    
 /  /    ' :  |  |,--.  ,--.--.       |  |.   .--. |  | : |  ' |    
|  :  /`./ |  :  '   | /       \      '--`_ ,'_ /| :  . | '  | |    
|  :  ;_   |  |   /' :.--.  .-. |     ,--,'||  ' | |  . . |  | :    
 \  \    `.'  :  | | | \__\/: . .     |  | '|  | ' |  | | '  : |__  
  `----.   \  |  ' | : ," .--.; |     :  | |:  | : ;  ; | |  | '.'| 
 /  /`--'  /  :  :_:,'/  /  ,.  |   __|  : ''  :  `--'   \;  :    ; 
'--'.     /|  | ,'   ;  :   .'   \.'__/\_: |:  ,      .-./|  ,   /  
  `--'---' `--''     |  ,     .-./|   :    : `--`----'     ---`-'   
                      `--`---'     \   \  /                         
                                    `--`-'  
Zip/Unzip file(s)/folder(s)/wildcard pattern files
Requires: Autohotkey_L, Windows > XP
URL: http://www.autohotkey.com/forum/viewtopic.php?t=65401
Credits: Sean for original idea
*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;; --------- 	EXAMPLE CODE	-------------------------------------
FilesToZip = D:\Projects\AHK\_Temp\Test\  ;Example of folder to compress
; FilesToZip = D:\Projects\AHK\_Temp\Test\*.ahk  ;Example of wildcards to compress
; FilesToZip := A_ScriptFullPath   ;Example of file to compress
sZip := A_ScriptDir . "\Test.zip"  ;Zip file to be created
sUnz := A_ScriptDir . "\ext\"      ;Directory to unzip files

Zip(FilesToZip,sZip)
Sleep, 500
Unz(sZip,sUnz)
;; --------- 	END EXAMPLE 	-------------------------------------



;; ----------- 	THE FUNCTIONS   -------------------------------------
Zip(FilesToZip,sZip)
{
If Not FileExist(sZip)
	CreateZipFile(sZip)
psh := ComObjCreate( "Shell.Application" )
pzip := psh.Namespace( sZip )
if InStr(FileExist(FilesToZip), "D")
	FilesToZip .= SubStr(FilesToZip,0)="\" ? "*.*" : "\*.*"
loop,%FilesToZip%,1
{
	ToolTip Zipping %A_LoopFileName% ..
	pzip.CopyHere( A_LoopFileLongPath, 4|16 )
	sleep 400
}
ToolTip
}

CreateZipFile(sZip)
{
	Header1 := "PK" . Chr(5) . Chr(6)
	VarSetCapacity(Header2, 18, 0)
	file := FileOpen(sZip,"w")
	file.Write(Header1)
	file.RawWrite(Header2,18)
	file.close()
}

Unz(sZip, sUnz)
{
    fso := ComObjCreate("Scripting.FileSystemObject")
    If Not fso.FolderExists(sUnz)  ;http://www.autohotkey.com/forum/viewtopic.php?p=402574
       fso.CreateFolder(sUnz)
    psh  := ComObjCreate("Shell.Application")
    zippedItems := psh.Namespace( sZip ).items().count
    psh.Namespace( sUnz ).CopyHere( psh.Namespace( sZip ).items, 4|16 )
    Loop {
        sleep 100
        unzippedItems := psh.Namespace( sUnz ).items().count
        ToolTip Unzipping in progress..
        IfEqual,zippedItems,%unzippedItems%
            break
    }
    ToolTip
}
;; ----------- 	END FUNCTIONS   -------------------------------------