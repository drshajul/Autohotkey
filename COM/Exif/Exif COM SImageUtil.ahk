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
Function:
Requires: 
URL: 
------------------------------------------------------------------
*/

#NoEnv
SetWorkingDir %A_ScriptDir%
Image := ComObjCreate("SImageUtil.Image")
Image.OpenImageFile(A_ScriptDir . "\test.jpg")

exif := Object() ;Object to store description of short code
exif.Make	 := "Make"
exif.Model := "Model"
exif.Software := "Software"
exif.Focal := "Focal Length"
exif.ExpProg := "Program"
exif.ISO := "ISO"
exif.Flash := "Flash"
exif.WhiteBal := "White Balance"
exif.s := "Shutter"
exif.f := "Aperture"
exif.ExpBias := "Exposure Bias"
exif.Focus := "Focus"
exif.Lens := "Lens"
exif.Meter := "Meter"
exif.Sharpness := "Sharpness"
exif.ImageAdj := "Image Adjust"
exif.Res := "Resolution"
exif.Qual := "Compression"
exif.Date := "Date"
exif.Ori := "Orientation"

Main := Object()
Main.Desc := "Image Description"
Main.Make := "Camera Make"
Main.Model := "Camera Model"
Main.Ori := "Orientation"
Main.XRes := "X Resolution"
Main.YRes := "Y Resolution"
Main.ResUnit :=     "Resolution Unit"
Main.Software := "Camera Software"
Main.ModTime := "Last Modification"
Main.WPoint := "White Point"
Main.PrimChr := "Primary Chromaticities"
Main.YCbCrCoef := "YCbCrCoefficients"
Main.YCbCrPos := "YCbCrPositioning"
Main.RefBW := "Reference Black/White point"
Main.Copy := "Copyright"
Main.ExifOffset := "Sub IFD Offset"
; XP tags
Main.Title := "Image Title"
Main.Comments := "Image Comments"
Main.Author := "Image Author"
Main.Keywords := "Image Keywords"
Main.Subject := "Image Subject"

Sub := Object()
Sub.s :=  "Exposure Time"
Sub.f := "F-Stop"
Sub.prog :=   "Program"
Sub.iso := "Equivalent ISO speed"
Sub.ExifVer := "Exif Version"
Sub.OrigTime := "Original Time"
Sub.DigTime := "Digitized Time"
Sub.CompConfig := "Components Configuration"
Sub.bpp := "Average compression ratio"
Sub.sa := "Shutter Speed APEX"
Sub.aa := "Aperture APEX"
Sub.ba := "Brightness APEX"
Sub.eba := "Exposure Bias APEX"
Sub.maa := "Maximum Aperture APEX"
Sub.dist := "Subject Distance"
Sub.meter := "Metering Mode"
Sub.ls := "Light Source"
Sub.flash := "Flash Used"
Sub.focal :=   "Focal Length"
Sub.Maker := "Maker Note"
Sub.User := "User Comment"
Sub.sTime := "Subsecond Time"
Sub.sOrigTime := "Subsecond Original Time"
Sub.sDigTime := "Subsecond Digitized Time"
Sub.flashpix := "Flash Pix Version"
Sub.ColorSpace :=  "Color Space"
Sub.Width := "Image Width"
Sub.Height := "Image Height"
Sub.SndFile := "Sound File"
Sub.ExitIntOff := "Exif Interoperability Offset"
Sub.FPXRes := "Focal Plan X Resolution"
Sub.FPYRes := "Focal Plan Y Resolution"
Sub.FPResUnit := "Focal Plan Unit"
Sub.ExpIndex := "Exposure Index"
Sub.SenseMethod := "Sensing Method"
Sub.FileSource :=  "File Source"
Sub.SceneType := "Scene Type"
Sub.CFAPat := "CFA Pattern"


Gui, Add, ListView, x0 y0 r45 w400 h500 vMyLV, Attribute|Value
GuiControl, -Redraw, MyLV

For k,v in exif
 LV_Add("",v,Image.GetExif(k))

For k,v in Main
 LV_Add("",v,Image.GetExif("Main." . k))

For k,v in Sub
 LV_Add("",v,Image.GetExif("Sub." . k))

GuiControl, +Redraw, MyLV 
LV_ModifyCol()
Gui, Show, w400 h500, Exif Details
Return

GuiClose:
ExitApp
