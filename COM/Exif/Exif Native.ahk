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
------------------------------------------------------------------
Function: Find Exif Info of image
Requires: OS >= Win XP
          Autohotkey_L
URL: http://www.autohotkey.com/forum/viewtopic.php?t=66634
------------------------------------------------------------------
*/


inFileName := A_ScriptDir . "\test.jpg"

SplitPath,inFileName,sFileName,sFileDir
objShell := ComObjCreate("Shell.Application") 
objFolder := objShell.Namespace(sFileDir . "\") 
objFilename := objFolder.Parsename(sFileName)

Gui, Add, ListView, x0 y0 r45 w400 h500 vMyLV, Attribute|Value

GuiControl, -Redraw, MyLV 
Loop
{
	iAttribute := objFolder.GetDetailsOf(objFolder.Items, A_Index)
	if (iValue := objFolder.GetDetailsOf(objFilename, A_Index)) ;only add attribs with values
		LV_Add("",iAttribute,iValue)
} until iAttribute = ""
GuiControl, +Redraw, MyLV 

LV_ModifyCol()
Gui, Show, w400 h500, File Details
return

ShowExifOnly:
exiflist := 1
MsgBox, Now showing only Exif details..
LV_Delete()
exif = 
( LTrim Join    ;Exif Attributes
Size,Perceived type,Kind,Date taken,Rating,Authors,Title,Subject,Categories,
 Comments,Copyright,Camera model,Dimensions,Camera maker,Filename,Bit depth,
   Horizontal resolution,Width,Vertical resolution,Height,Type,EXIF version,
Exposure bias,Exposure program,Exposure time,F-stop,Flash mode,Focal length,
35mm focal length,ISO speed,Lens maker,Lens model,Light source,Max aperture,
Metering mode,Orientation,Program mode,Saturation,Subject distance,White balance
)

GuiControl, -Redraw, MyLV 
Loop
{
	iAttribute := objFolder.GetDetailsOf(objFolder.Items, A_Index)
	If iAttribute in %exif%
		if (iValue := objFolder.GetDetailsOf(objFilename, A_Index)) ;only add attribs with values
			LV_Add("",iAttribute,iValue)
} until iAttribute = ""

GuiControl, +Redraw, MyLV 
Return

GuiClose:
if not exiflist
	gosub ShowExifOnly
else
	ExitApp
return