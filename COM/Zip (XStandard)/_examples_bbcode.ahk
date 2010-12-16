Zip/Unzip using a free COM library I found online.
I have just wrapped the functions to be compatible with AHK_L COM syntax and modified the documentation to be easier for newbies to understand.
I have tested the example codes, and work great on my machine!

Requires: Autohotkey_L and 32bit OS
[b]Reference -> [url=http://www.xstandard.com/en/documentation/xzip/]http://www.xstandard.com/en/documentation/xzip/[/url][/b]

[b][size=14]Overview[/size][/b]
Quote - "The Zip component provides industry-standard Zip archive functionality. It is designed to be easy to use. You can pack/unpack a file or folder with a single line of code. If you need to create or extract Zip files on the fly, this component is for you. This component can be used in environments that support COM.."

[b][size=14]Installation Instructions[/size][/b]
Official Download - [url=http://www.xstandard.com/en/downloads/?product=zip]Download Zip Component[/url]
Move the dll to a directory like: "C:\Program Files\XZip\"
Open a command prompt and cd to the directory where the dll is located.
Type regsvr32 XZip.dll
Note: Vista/7, the command prompt must be "Run as administrator".

[b][size=14]Uninstall Instructions[/size][/b]
Open a command prompt and cd to the directory where the dll is located.
Type regsvr32 -u XZip.dll

[b][size=14]Classes, Functions, Methods, Properties[/size][/b]
[code]obj.Pack(sFilePath, sArchive, [bStorePath As Boolean = False], [sNewPath], [CompressionLevel = -1])
; Add file or folder to an archive. 
; Compression level 1 is minimum, level 9 is maximum, all other values default to level 6.

obj.UnPack(sArchive, sFolderPath, [sPattern])
; Extract contents of an archive to a folder.

obj.Delete(sFile, sArchive)
; Remove a file from an archive.

obj.Move(sFrom, sTo, sArchive)
; Move or rename a file in the archive.

objContents := obj.Contents(sArchive)
; Get a list of files and folder in the archive.
[/code]

[b]Class: Items (Read-only)[/b]
[code]Items.Count ; Returns the number of members in a collection.
Item := Items.Item(Index) ;Returns a specific member of a collection by position.
[/code]

[b]Class: Item (Read-only)[/b]
[code]Item.Date ;Last modified date.
Item.Name ;File name.
Item.Path ;Relative path.
Item.Size ;File size in bytes.
Item.Type ;Type of object.
[/code]

[b]Enum: ItemType[/b]
[code]tFolder = 1 ;Item is a folder.
tFile = 2 ;Item is a file.[/code]

[b][size=14]Examples[/size][/b]

[b]How to archive (or zip) multiple files[/b]
[code]objZip := ComObjCreate("XStandard.Zip")
objZip.Pack("C:\Temp\golf.jpg", "C:\Temp\images.zip")
objZip.Pack("C:\Temp\racing.gif", "C:\Temp\images.zip")
[/code]

[b]How to archive (or zip) multiple files with different compression levels[/b]
[code]objZip := ComObjCreate("XStandard.Zip")
objZip.Pack("C:\Temp\reports.doc", "C:\Temp\archive.zip","" ,"" , 9)
objZip.Pack("C:\Temp\boat.jpg", "C:\Temp\archive.zip","" ,"" , 1)
[/code]

[b]How to archive (or zip) multiple files with default path[/b]
[code]objZip := ComObjCreate("XStandard.Zip")
objZip.Pack("C:\Temp\reports.doc", "C:\Temp\archive.zip", True)
objZip.Pack("C:\Temp\boat.jpg", "C:\Temp\archive.zip", True)
[/code]

[b]How to archive (or zip) multiple files with a custom path[/b]
[code]objZip := ComObjCreate("XStandard.Zip")
objZip.Pack("C:\Temp\reports.doc", "C:\Temp\archive.zip", True, "files/word")
objZip.Pack("C:\Temp\boat.jpg", "C:\Temp\archive.zip", True, "files/images")
[/code]

[b]How to archive (or zip) multiple files using wildcards[/b]
[code]objZip := ComObjCreate("XStandard.Zip")
objZip.Pack("C:\Temp\*.jpg", "C:\Temp\images.zip")
[/code]

[b]How to unzip files[/b]
[code]objZip := ComObjCreate("XStandard.Zip")
objZip.UnPack("C:\Temp\images.zip", "C:\Temp\")
[/code]

[b]How to unzip files using wildcards[/b]
[code]objZip := ComObjCreate("XStandard.Zip")
objZip.UnPack("C:\Temp\images.zip", "C:\Temp\", "*.jpg")
[/code]

[b]How to get a listing of files and folder in an archive[/b]
[code]objZip := ComObjCreate("XStandard.Zip")
objContents := objZip.Contents(A_ScriptDir . "\test.zip")._NewEnum
While objContents[objItem]
	Msgbox % objItem.Path . objItem.Name . "`n"
[/code]

[b]How to remove a file from an archive[/b]
[code]objZip := ComObjCreate("XStandard.Zip")
objZip.Delete("headshots/smith.jpg", "C:\Temp\images.zip")
[/code]

[b]How to move a file in an archive[/b]
[code]objZip := ComObjCreate("XStandard.Zip")
objZip.Move("headshots/jones.jpg", "staff/jones.jpg", "C:\Temp\images.zip")
[/code]

[b]How to rename a file in an archive[/b]
[code]objZip := ComObjCreate("XStandard.Zip")
objZip.Move("headshots/jones.jpg", "headshots/randy-jones.jpg", "C:\Temp\images.zip")
[/code]

[b][size=14]Known Issues[/size][/b]
The UnPack() method will first remove all files from the destination folder. This behavior will change in future releases.
This component was not designed to work with huge archives. Max archive size depends on the amount of available RAM.
This component is designed for 32-bit operating systems and will not work natively on 64-bit operating systems.

[b][size=14]Error codes[/size][/b]
200	Archive file is not correct.
201	Archive file is not a valid zip file[header].
202	Archive file is not a valid zip file[dir].
203	Cannot create archive file.
204	Compressed header is not correct
205	File size is not correct.
206	Cannot Alloc memory
207	Cannot open archive file
208	Archive file is empty
209	Cannot alloc memeory.
210	Cannot find source file.
211	Cannot open file
212	Cannot alloc memory.
213	Cannot alloc memory.
214	There is no file.
215	Archive file is same as the input file.
216	Cannot Alloc memory.
217	Incorrect signature of header
230	Cannot open archive file.
240	Archive file is not correct.
241	Archive file is not a valid zip file[header].
242	Archive file is not a valid zip file[dir].
250	Cannot open archive file.
251	Archive file is not correct.
252	Cannot create file for swapping.
253	Header of archive file is incorrect.
254	Unknown error when modifying archive file.
290	Cannot get information from archive file.
291	Cannot get information from archive file.
591	Cannot get information from archive file.