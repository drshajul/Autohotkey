
#^!h::
WinGet, id, list,,, Program Manager
Loop, %id%
{
    this_id := id%A_Index%
    WinGetTitle, this_title, ahk_id %this_id%
    WinHide, %this_title%
    FileAppend, %this_title%`n, temp.txt
}
Return,

#^!s::
Loop, 20
{
FileReadLine, title, temp.txt, %A_Index%
WinShow, %title%
}
FileDelete, temp.txt

Return
