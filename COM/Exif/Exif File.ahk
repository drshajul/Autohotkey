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
Function: Exif Data extraction from images with File Object
Requires: Autohotkey_L
URL: http://www.autohotkey.com/forum/viewtopic.php?t=66634
Credits: Inspired from autohotkey.com/forum/topic59079.html
         by SKAN
------------------------------------------------------------------
*/
ImageFile := "test.jpg"
oFile := FileOpen(ImageFile,"r")

;======================== SEARCH FOR APP1 ========================
Loop 4096
{
oFile.RawRead(rData,2)
hex := Mem2Hex( &rData, 2 )
If (APP1 := (hex = "FFE1") ? True : False) ;APP1 Exist - hence Exif Data exists
  break
}
If not APP1
 Quit("Exif Data not found!")
;=================================================================


;======================== SEARCH FOR EXIF ======================== 
oFile.RawRead(sData,2) ;Size of exif data
oFile.RawRead(rData,6) ;String EXIF
EXIF := (Mem2Hex( &rData, 6 ) = "457869660000") ? True : False
If not EXIF
 Quit("Exif Data not found!")
;=================================================================


;======================== TIFF HEADER INFO =======================
TiffHPos := oFile.Position ;Position to mark start of TIFF Header
oFile.RawRead(rData,2)
LE := ( Mem2Hex(&rData,2) = "4949" ) ? True : False ;Endian-ness
If not LE
 Quit("Big-endian Exif not supported yet!")
oFile.Seek(2,1)
oFile.RawRead(rData,4) ;Offset of first IFD (Image File Directory)
if (NumGet(rData) != 8)
 {
  oFile.Seek(-8,1)
  oFile.Seek(NumGet(rData),1)
 }
;=================================================================

Gui, Add, ListView, x0 y0 r45 w500 h500 vMyLV, IFD|Tag|Description|Data|Type|Size|DataLength
GuiControl, -Redraw, MyLV 

gosub LoadTags ;Load tags as object
gosub LoadTypes ;Load types as object
NextIFD := oFile.Position  ;First IFD position

Loop,3  ;Loop through IFD's, usually only two
{
  nIFD := A_Index-1
  If nextIFD  ;If next IFD exists
    {
    rData := 1   ;Reset
    IFD := "Main" . nIFD  ;MsgBox % "Going to IFD" . A_Index-1 . " at : " . nextIFD
    oFile.Seek(nextIFD)
    nextIFD := NextIFDRetrieved := ""
    gosub IFDStart ;Load IFD Data
    }
  else
    break
  If subIFDOffset
    {
    rData := 1
    IFD := "Sub" . nIFD   ;MsgBox % "Going to subIFD at : " . subIFDOffset
    oFile.Seek(subIFDOffset)
    subIFDOffset := "" ;Note - NextIFDRetrieved is not reset
    gosub IFDStart
    }
  If InterOpOffset
    {
    rData := 1
    IFD := "InterOP" . nIFD   ;MsgBox % "Going to InterOp at : " . InterOpOffset
    oFile.Seek(InterOpOffset)
    InterOpOffset := "" ;Note - NextIFDRetrieved is not reset
    gosub IFDStart
    }
}
GuiControl, +Redraw, MyLV 
LV_ModifyCol()
Gui, Show, w500 h500, %ImageFile% `: Exif Data
Return
;======================= END OF AUTOEXECUTE SECTION =======================


GuiClose:
ExitApp


;======================== IFD DATA RETRIEVAL ==============================
IFDStart:
;---- Number of directory entries in this IFD ----
oFile.RawRead(rData,2)
thisIFDnEntries := NumGet(rData)
;MsgBox % "Number of entries in this IFD : " . thisIFDnEntries
;-------------------------------------------------

Loop, % thisIFDnEntries
{
  SetFormat, Integer, Hex
  oFile.RawRead(rData,2) ;Tag
  thisTag := TrimHex(NumGet(rData),2)

  SetFormat, Integer, D
  rData := 1 ;otherwise some error occurs, probably due to var capacity/type
  oFile.RawRead(rData,2) ;Type of data
  thisType := NumGet(rData)

  thisSize := oType[thisType].len


  rData := 1
  oFile.RawRead(rData,4) ;Number of components
  thisComponents := NumGet(rData)

  thisDataLen := thisComponents * thisSize


  rData := 1
  oFile.RawRead(rData,4)
  if (thisTag = "8769") ;This is offset to SubIFD
  {
     thisData := NumGet(rData)
     rData := 1
     subIFDOffset := thisData + TiffHPos
     thisTag := thisType := thisSize := thisComponents := thisDataLen := thisData := thisOffset := corrOffset := ""
     rData := 1
     continue
  }
  else if (thisTag = "A005") ;This is offset to InterOpIFD
  {
     thisData := NumGet(rData)
     rData := 1
     InterOpOffset := thisData + TiffHPos
     thisTag := thisType := thisSize := thisComponents := thisDataLen := thisData := thisOffset := corrOffset := ""
     rData := 1
     continue
  }
  else if (thisDataLen > 4) ;The value is an offset
  {
     thisData := NumGet(rData)
     rData := 1
     corrOffset := thisData + TiffHPos
     lastpos := oFile.position
     oFile.Seek(corrOffset)
     oFile.RawRead(rData,thisDataLen)
     if (thisType=2 || thisType=7) ;It is an ascii string or undefined
        thisData := StrGet(&rData,thisDataLen,"CP0") ;read System ANSI codepage string
     else if (thisType=5 || thisType=10) ;It is an rational
        {
        nNum := NumGet(rData,0,"UInt")
        nDen := NumGet(rData,4,"UInt")
        thisData := nNum . "/" . nDen
        }
     else
        thisData := NumGet(rData,0,oType[thisType].type)
     oFile.Seek(lastpos)  ;Seek to position before jump to offset
  }
  else  ;value is stored in the 4 bytes itself
  {
     if (thisType=2 || thisType=7) ;It is an ascii string or undefined
        thisData := StrGet(&rData,thisDataLen,"CP0") ;read System ANSI codepage string
     else
     {
        thisData := NumGet(rData,0,oType[thisType].type)
     }
  }
  LV_Add("",IFD,thisTag,oTag[thisTag],thisData,thisType,thisSize,thisDataLen)
  thisTag := thisType := thisSize := thisComponents := thisDataLen := thisData := thisOffset := s := corrOffset := ""
  rData := 1
}

if not NextIFDRetrieved
{
NextIFDRetrieved := 1
oFile.RawRead(rData,4)
If NumGet(rData) ;It will be zero if it is the last IFD directory, usually two only.
  nextIFD := NumGet(rData) + TiffHPos ;Next IFD
}
return


LoadTypes:
types=
( ltrim join ; Value-Bytes-Description        Source: http://www.media.mit.edu/pia/Research/deepview/exif.html
               1-1-UChar|
               2-1-Ascii|
               3-2-UShort|
               4-4-UInt|
               5-8-Double|
               6-1-Char|
               7-1-|
               8-2-Short|
               9-4-UInt|
               10-8-Double|
               11-4-Float|
               12-8-Float
)
oType := Object()
Loop,Parse,types,|
{
 StringSplit,tData,A_LoopField,-
 oType[tData1,"len"] := tData2
 oType[tData1,"type"] := tData3
}
types := tData := tData1 := tData2 := tData3 := ""
return




LoadTags:
tags=
 ( ltrim join ;                                             source www.exiv2.org/tags.html
   0001-InteropIndex|0002-InteropVersion|000B-ProcessingSoftware|00FE-SubfileType|00FF-Old
  SubfileType|0100-ImageWidth|0101-ImageHeight|0102-BitsPerSample|0103-Compression|0106-Ph
  otometricInterpretation|0107-Thresholding|0108-CellWidth|0109-CellLength|010A-FillOrder|
  010D-DocumentName|010E-ImageDescription|010F-Make|0110-Model|0111-PreviewImageStart|0112
  -Orientation|0115-SamplesPerPixel|0116-RowsPerStrip|0117-PreviewImageLength|0118-MinSamp
  leValue|0119-MaxSampleValue|011A-XResolution|011B-YResolution|011C-PlanarConfiguration|0
  11D-PageName|011E-XPosition|011F-YPosition|0120-FreeOffsets|0121-FreeByteCounts|0122-Gra
  yResponseUnit|0123-GrayResponseCurve|0124-T4Options|0125-T6Options|0128-ResolutionUnit|0
  129-PageNumber|012C-ColorResponseUnit|012D-TransferFunction|0131-Software|0132-DateTime|
  013B-Artist|013C-HostComputer|013D-Predictor|013E-WhitePoint|013F-PrimaryChromaticities|
  0140-ColorMap|0141-HalftoneHints|0142-TileWidth|0143-TileLength|0144-TileOffsets|0145-Ti
  leByteCounts|0146-BadFaxLines|0147-CleanFaxData|0148-ConsecutiveBadFaxLines|014A-SubIFD|
  DataOffset|014C-InkSet|014D-InkNames|014E-NumberofInks|0150-DotRange|0151-TargetPrinter|
  0152-ExtraSamples|0153-SampleFormat|0154-SMinSampleValue|0155-SMaxSampleValue|0156-Trans
  ferRange|0157-ClipPath|0158-XClipPathUnits|0159-YClipPathUnits|015A-Indexed|015B-JPEGTab
  les|015F-OPIProxy|0190-GlobalParametersIFD|0191-ProfileType|0192-FaxProfile|0193-CodingM
  ethods|0194-VersionYear|0195-ModeNumber|01B1-Decode|01B2-DefaultImageColor|0200-JPEGProc
  |0201-ThumbnailImageStart|0201-JpgFromRawStart|0201-JpgFromRawStart|0201-OtherImageStart
  |0202-ThumbnailImageLength|0203-JPEGRestartInterval|0205-JPEGLosslessPredictors|0206-JPE
  GPointTransforms|0207-JPEGQTables|0208-JPEGDCTables|0209-JPEGACTables|0211-YCbCrCoeffici
  ents|0212-YCbCrSubSampling|0213-YCbCrPositioning|0214-ReferenceBlackWhite|022F-StripRowC
  ounts|02BC-ApplicationNotes|1000-RelatedImageFileFormat|1001-RelatedImageWidth|1002-Rela
  tedImageHeight|4746-Rating|4749-RatingPercent|800D-ImageID|80A4-WangAnnotation|80E3-Matt
  eing|80E4-DataType|80E5-ImageDepth|80E6-TileDepth|827D-Model2|828D-CFARepeatPatternDim|8
  28E-CFAPattern2|828F-BatteryLevel|8290-KodakIFD|8298-Copyright|829A-ExposureTime|829D-FN
  umber|82A5-MDFileTag|82A6-MDScalePixel|82A7-MDColorTable|82A8-MDLabName|82A9-MDSampleInf
  o|82AA-MDPrepDate|82AB-MDPrepTime|82AC-MDFileUnits|830E-PixelScale|83BB-IPTC-NAA|847E-In
  tergraphPacketData|847F-IntergraphFlagRegisters|8480-IntergraphMatrix|8482-ModelTiePoint
  |84E0-Site|84E1-ColorSequence|84E2-IT8Header|84E3-RasterPadding|84E4-BitsPerRunLength|84
  E5-BitsPerExtendedRunLength|84E6-ColorTable|84E7-ImageColorIndicator|84E8-BackgroundColo
  rIndicator|84E9-ImageColorValue|84EA-BackgroundColorValue|84EB-PixelIntensityRange|84EC-
  TransparencyIndicator|84ED-ColorCharacterization|84EE-HCUsage|84EF-TrapIndicator|84F0-CM
  YKEquivalent|8546-SEMInfo|8568-AFCP_IPTC|85D8-ModelTransform|8602-WB_GRGBLevels|8606-Lea
  fData|8649-PhotoshopSettings|8769-ExifOffset|8773-ICC_Profile|87AC-ImageLayer|87AF-GeoTi
  ffDirectory|87B0-GeoTiffDoubleParams|87B1-GeoTiffAsciiParams|8822-ExposureProgram|8824-S
  pectralSensitivity|8825-GPSInfo|8827-ISO|8828-Opto-ElectricConvFactor|8829-Interlace|882
  A-TimeZoneOffset|882B-SelfTimerMode|885C-FaxRecvParams|885D-FaxSubAddress|885E-FaxRecvTi
  me|888A-LeafSubIFD|9000-ExifVersion|9003-DateTimeOriginal|9004-CreateDate|9101-Component
  sConfiguration|9102-CompressedBitsPerPixel|9201-ShutterSpeedValue|9202-ApertureValue|920
  3-BrightnessValue|9204-ExposureCompensation|9205-MaxApertureValue|9206-SubjectDistance|9
  207-MeteringMode|9208-LightSource|9209-Flash|920A-FocalLength|920B-FlashEnergy|920C-Spat
  ialFrequencyResponse|920D-Noise|920E-FocalPlaneXResolution|920F-FocalPlaneYResolution|92
  10-FocalPlaneResolutionUnit|9211-ImageNumber|9212-SecurityClassification|9213-ImageHisto
  ry|9214-SubjectLocation|9215-ExposureIndex|9216-TIFF-EPStandardID|9217-SensingMethod|923
  F-StoNits|927C-MakerNote|9286-UserComment|9290-SubSecTime|9291-SubSecTimeOriginal|9292-S
  ubSecTimeDigitized|935C-ImageSourceData|9C9B-XPTitle|9C9C-XPComment|9C9D-XPAuthor|9C9E-X
  PKeywords|9C9F-XPSubject|A000-FlashpixVersion|A001-ColorSpace|A002-ExifImageWidth|A003-E
  xifImageHeight|A004-RelatedSoundFile|A005-InteropOffset|A20B-FlashEnergy|A20C-SpatialFre
  quencyResponse|A20D-Noise|A20E-FocalPlaneXResolution|A20F-FocalPlaneYResolution|A210-Foc
  alPlaneResolutionUnit|A211-ImageNumber|A212-SecurityClassification|A213-ImageHistory|A21
  4-SubjectLocation|A215-ExposureIndex|A216-TIFF-EPStandardID|A217-SensingMethod|A300-File
  Source|A301-SceneType|A302-CFAPattern|A401-CustomRendered|A402-ExposureMode|A403-WhiteBa
  lance|A404-DigitalZoomRatio|A405-FocalLengthIn35mmFormat|A406-SceneCaptureType|A407-Gain
  Control|A408-Contrast|A409-Saturation|A40A-Sharpness|A40B-DeviceSettingDescription|A40C-
  SubjectDistanceRange|A420-ImageUniqueID|A480-GDALMetadata|A481-GDALNoData|A500-Gamma|BC0
  1-PixelFormat|BC02-Transformation|BC03-Uncompressed|BC04-ImageType|BC80-ImageWidth|BC81-
  ImageHeight|BC82-WidthResolution|BC83-HeightResolution|BCC0-ImageOffset|BCC1-ImageByteCo
  unt|BCC2-AlphaOffset|BCC3-AlphaByteCount|BCC4-ImageDataDiscard|BCC5-AlphaDataDiscard|C42
  7-OceScanjobDesc|C428-OceApplicationSelector|C429-OceIDNumber|C42A-OceImageLogic|C44F-An
  notations|C4A5-PrintIM|C612-DNGVersion|C613-DNGBackwardVersion|C614-UniqueCameraModel|C6
  15-LocalizedCameraModel|C616-CFAPlaneColor|C617-CFALayout|C618-LinearizationTable|C619-B
  lackLevelRepeatDim|C61A-BlackLevel|C61B-BlackLevelDeltaH|C61C-BlackLevelDeltaV|C61D-Whit
  eLevel|C61E-DefaultScale|C61F-DefaultCropOrigin|C620-DefaultCropSize|C621-ColorMatrix1|C
  622-ColorMatrix2|C623-CameraCalibration1|C624-CameraCalibration2|C625-ReductionMatrix1|C
  626-ReductionMatrix2|C627-AnalogBalance|C628-AsShotNeutral|C629-AsShotWhiteXY|C62A-Basel
  ineExposure|C62B-BaselineNoise|C62C-BaselineSharpness|C62D-BayerGreenSplit|C62E-LinearRe
  sponseLimit|C62F-CameraSerialNumber|C630-DNGLensInfo|C631-ChromaBlurRadius|C632-AntiAlia
  sStrength|C633-ShadowScale|C634-SR2Private|C635-MakerNoteSafety|C640-RawImageSegmentatio
  n|C65A-CalibrationIlluminant1|C65B-CalibrationIlluminant2|C65C-BestQualityScale|C65D-Raw
  DataUniqueID|C660-AliasLayerMetadata|C68B-OriginalRawFileName|C68C-OriginalRawFileData|C
  68D-ActiveArea|C68E-MaskedAreas|C68F-AsShotICCProfile|C690-AsShotPreProfileMatrix|C691-C
  urrentICCProfile|C692-CurrentPreProfileMatrix|EA1C-Padding|EA1D-OffsetSchema|FDE8-OwnerN
  ame|FDE9-SerialNumber|FDEA-Lens|FE4C-RawFile|FE4D-Converter|FE4E-WhiteBalance|FE51-Expos
  ure|FE52-Shadows|FE53-Brightness|FE54-Contrast|FE55-Saturation|FE56-Sharpness|FE57-Smoot
  hness|FE58-MoireFilter
 )
 
oTag := Object()
Loop,Parse,tags,|
{
 StringSplit,tData,A_LoopField,-
 oTag[tData1] := tData2
}
tags := tData := tData1 := tData2 := ""
return






;; -------------- FUNCTIONS -------------------------
Mem2Hex(pointer,len)  ;http://www.autohotkey.com/forum/viewtopic.php?p=220160
{ 
 A_FI := A_FormatInteger 
 SetFormat, Integer, Hex 
 Loop, %len%  
 { 
  Hex := *Pointer+0 
  StringReplace, Hex, Hex, 0x, 0x0 
  StringRight Hex, Hex, 2            
  hexDump .= hex 
  Pointer ++ 
 } 
 SetFormat, Integer, %A_FI% 
 StringUpper, hexDump, hexDump 
 Return hexDump 
}

TrimHex(Hex,len)
{
Loop, % len
 pad .= "00"
StringReplace,Hex,Hex,0x,%pad%
StringRight Hex, Hex, 2*len
return Hex
}

Quit(desc)
{
 MsgBox, 0, Exif Reader, %desc%
 ExitApp
}