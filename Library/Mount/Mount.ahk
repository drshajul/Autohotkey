#NoEnv
SendMode Input
#Include Mount.lib.ahk
FileSelectFolder, SourcePath, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}, 3, Select folder to mount
MsgBox % Mount(SourcePath, "x")
