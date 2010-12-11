/*
    Mount

    Revision:                   0.2
    Status:                     EXPERIMENTAL BETA
    Date:                       Wed, 28 February 2007 10:44:22 GMT
    Author:                     Tuncay <tuncay.d@gmx.net>
    License:                    GNU GPL, Version 2
    Type:                       Library
    Standalone:                 Yes
    Tested AHK Version:         1.0.48.08
    Tested WIN Version:         XP Pro SP2

    Please send any bug report to tuncay.d@gmx.net.

    Any parameter enclosed between '[' and ']' are optional.

    Mount([SourcePath], [Mountpoint], [Options])
        Returns on success mounted drive with ending backslash and on failure
        a string without content.
        
        If Mountpoint is not given, then it looks for first free drive otherwise
        existing SourcePath will be mounted to given Mountpoint. If SourcePath
        is not given, it defaults to WorkingDir.
        
        The SourcePath can contain wildcards ("*" and "?") and the relative
        directory dots ("." for current dir and ".." for one up dir).
        
        Any existing Mountpoint will be updated (first umount the old one, and
        then remounting the new one).
                
        Currently there is only one option used to unmount the drive.
        
    UnMount([Mountpoint], [Options])
        Like Mount(), but without the need of SourcePath. Also the unmount
        option is here given over to Mount() always.
    
    GetMount([Path])
        If the specified Path is a drive, the full real path is returned. If
        the Path is not given, first virtual drive will be get.
    
    SetMountArray([ArrayName])
        It creates global variables as an array holding all virtual drives and
        paths. The ArrayName is optional and will only be prefixed to all
        created global variables. The naming scheme is like that: PrefixDrive0,
        PrefixDrive1 ... and PrefixPath1, PrefixPath2 ...
        The Drive0 and the return contains the number of all virtual drives.
    
    
    Example 1
        Mount()
    -> F:
    Calling Mount() without any parameter mounts current WorkingDir to first
    found free drive letter and returns it.
        
    Example 2
        FileSelectFolder, SourcePath, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}, 3, Select folder to mount
        Mount(SourcePath, "x")
    -> X:
    Here SourcePath will be mounted to drive letter X, if it`s free. If the
    drive letter is not free and if its a virtual drive letter, then the drive
    (here "X:") will be unmounted and SourcePath will be mounted as the new one.
    
    Example 3
        UnMount()
    -> X:
    Calling UnMount() without any parameter unmounts the first founded virtual
    drive, mapped with Mount(). It returns the founded drive path (here "X:\").
    
    Example 4
        MsgBox % GetMount()
    -> X:
    Calling GetMount() without any parameter gets the drive letter of first
    virtual drive letter (without backslash). But this slow.
        
    Example 5
        MsgBox % GetMount("x")
    -> D:\files\subdirectory
    Calling GetMount() with drive letter returns the real full path of mapped
    virtual drive (without backslash). But if the given drive letter does not
    exist or isn`t a mounted drive, then a void string is returned.
    
    Example 6
        SetMountArray()
    -> 2
    Calling SetMountArray() without any parameter will create these globals with
    all founded virtual drives (in this example 2 are shown):
    Drive0 = 2
    Drive1 = E:
    Drive2 = F:
    Path1 = C:/Windows
    Path2 = D:/Emulators/zsnes
*/

#NoEnv
#NoTrayIcon
SetBatchLines, -1

/*
    Public Function Mount
    Mounts with subst.exe any path to a Windows drive.
    2007 by Tuncay
*/
Mount(SourcePath = "", Mountpoint = "", Options = "")
{
    GoSub, SetOptions@Mount
    GoSub, SetMountPath@Mount
    If NOT Option?UnMount AND FileExist(GetMount(MountPath))
    {
        Option?UnMount := True
        Option?Update := True
    }        
    If Option?UnMount
        Command = subst %MountPath% /d
    Else
    {
        If (SourcePath = "")
            SourcePath = %A_WorkingDir%
        Else
        {
            Loop, %SourcePath%, 2
            {
                SourcePath = %A_LoopFileLongPath%
                Break
            }
        }
        Command = subst %MountPath% "%SourcePath%"
    }
    
    If (NOT Option?UnMount AND NOT FileExist(MountPath . "\") AND FileExist(SourcePath))
            OR (Option?UnMount AND FileExist(MountPath))        
    {
        RunWait, "%comspec%" /c %Command%,, Hide UseErrorLevel
        If ErrorLevel = ERROR
        {
            MountPath =
            ; Failed to launch subst.exe
            ErrorLevel = 2
        }
        Else
            ErrorLevel = 0
    }
    Else
    {
        MountPath =
        ErrorLevel = 1
    }
    If Option?Update
        MountPath := Mount(SourcePath, Mountpoint)
    Return MountPath
    
    SetMountPath@Mount:        
        If (Mountpoint = "") ; Search drive.
        {
            DriveGet, ActualDrives, List
            If NOT Option?UnMount ; Get first free drive.
            {
                FreeDriveLetters = CDEFGHIJKLMNOPQRSTUVWXYZ
                Loop, Parse, ActualDrives
                    StringReplace, FreeDriveLetters,FreeDriveLetters,%A_LoopField%
                Loop, Parse, FreeDriveLetters
                {
                    MountPath = %A_LoopField%:
                    Break
                }
            }
            Else If Option?UnMount ; Get first subst.exe mounted drive.
                MountPath := GetMount()
        }
        Else If Mountpoint Is Alpha ; Add double colon on drive letter.
            MountPath = %Mountpoint%:
        Else ; Drive will be extracted from any path.
            SplitPath, MountPath,,,,, Mountpoint
    Return
    
    SetOptions@Mount:
        ; Default settings
        Option?UnMount := False        
        If NOT (Options = "")
        {
            CurrentStringCaseSense := A_StringCaseSense
            StringCaseSense, On
            If Options Contains --
            {
                StringReplace, Options, Options,--unmount,-u
            }
            StringReplace, Options, Options,/,-, All
            
            ; Overwriting default settings.
            OptionsFoundList := "" ; For performance, not to loop if already founded
                                   ; and avoid dublicates.
            Loop, Parse, Options,-,%A_SPACE%
            {
                If A_LoopField In ,%A_SPACE%
                    Continue
                ; Inner Loop for enabling the short style for grouping of options.
                Loop, Parse, A_LoopField
                {
                    If InStr(OptionsFoundList, A_LoopField, True)
                        Continue
                        
                    ; Option?UnMount
                    ; 0=creates a virtual drive from given path (default)
                    ; 1=deletes the given virtual drive mounted by subst.exe
                    If InStr(A_LoopField, "u", True)
                    {
                        Option?UnMount := True
                        OptionsFoundList .= A_LoopField
                        Continue
                    }
                }
            }
            StringCaseSense, %CurrentStringCaseSense%
        }
    Return
}

/*
    Public Function UnMount
    UnMounts a virtual drive mapped with subst.exe. 
    2006 by Tuncay
*/
UnMount(Mountpoint = "", Options = "")
{
    Return Mount("", Mountpoint, "-u " . Options)
}

/*
    Public Function SetMountArray
    Creates an array with holding all virtual drives and the real paths of them.
    2007 by Tuncay
*/
SetMountArray(pArrayName = "")
{
    Global
    %pArrayName%Drive0 = 0
    Local TempFile
    Local Command
    TempFile = %A_Temp%\{D74BA6E8-2728-4FC6-8185-623EA7DAD412}_%A_Now%.~tmp    
    Command = subst >"%TempFile%"
    RunWait, "%comspec%" /c %Command%,, Hide UseErrorLevel
    If ErrorLevel = ERROR
        ErrorLevel := 2 ; Failed to launch subst.exe
    Else
    {
        ErrorLevel = 0
        ; Process all drive letters.
        Loop, Read, %TempFile%
        {        
            StringMid, %pArrayName%Drive%A_Index%, A_LoopReadLine, 1, 2
            StringMid, %pArrayName%Path%A_Index%, A_LoopReadLine, 9
            %pArrayName%Drive0++
        }
        
    }
    FileDelete, %TempFile%
    Return %pArrayName%Drive0
}

/*
    Public Function GetMount
    Converts virtual path mapped with subst.exe to real physical full path.
    2007 by Tuncay
*/
GetMount(pPath = "")
{
    If pPath
        pPath := SubStr(pPath, 1, 1) . ":"
    Else
        SplitPath, pPath,,,,, pPath
    TempFile = %A_Temp%\{D74BA6E8-2728-4FC6-8185-623EA7DAD412}_%A_Now%.~tmp    
    Command = subst >"%TempFile%"
    RunWait, "%comspec%" /c %Command%,, Hide UseErrorLevel
    If ErrorLevel = ERROR
        ErrorLevel := 2 ; Failed to launch subst.exe
    Else
    {
        ErrorLevel = 0
        If pPath
        {
            Loop, Read, %TempFile%
            {        
                StringMid, MountDrive, A_LoopReadLine, 1, 2
                If (pPath = MountDrive)
                {
                    StringMid, MountPath, A_LoopReadLine, 9
                    Break
                }
            }    
        }
        Else
        {
            ; Get first virtual drive.
            Loop, Read, %TempFile%
            {        
                DriveGet, ActualDrives, List
                MountDrive := SubStr(A_LoopReadLine, 1, 1)
                If InStr(ActualDrives, MountDrive)
                {
                    MountPath = %MountDrive%:
                    Break
                }
                Else
                    Continue
            }
        }
    }
    FileDelete, %TempFile%
    Return MountPath
}
