Cando_更改盘符:
if FileExist(Candy_Cmd_Str3)
{
	msgbox 错误，磁盘 %Candy_Cmd_Str3% 已经存在！
return
}
VolumeName := GetVolumeNameForVolumeMountPoint(CandySel)
If VolumeName
{
	DeleteVolumeMountPoint(CandySel)
	if !SetVolumeMountPoint(Candy_Cmd_Str3, VolumeName)
		msgbox 挂载分区出现错误`nErrorLevel: %ErrorLevel%`nA_LastError: %A_LastError%`n
}
Else
	msgbox 获取分区VolumeName出现错误`nErrorLevel: %ErrorLevel%`nA_LastError: %A_LastError%`n
return

Cando_挂载分区为文件夹:
if Candy_Cmd_Str3
{
	Candy_Cmd_Str3 := RTrim(Candy_Cmd_Str3, " \")
	if !FileExist(Candy_Cmd_Str3)
	{
		msgbox 错误，文件夹不存在！
	return
	}
	if !FolderIsEmpty(Candy_Cmd_Str3)
	{
		msgbox 错误，文件夹不为空！
	return
	}
	if !FileIsNTFS(Candy_Cmd_Str3)
	{
		msgbox 文件夹所在分区不是 NTFS 文件系统格式！
	return
	}

	VolumeName := GetVolumeNameForVolumeMountPoint(CandySel)
	If VolumeName
	{
		if !SetVolumeMountPoint(Candy_Cmd_Str3, VolumeName)
			msgbox 挂载分区出现错误`nErrorLevel: %ErrorLevel%`nA_LastError: %A_LastError%`n
	}
}
else
{
	Gui,66:Destroy
	Gui,66:Default
	Gui, Add, Text, x10 y17, 目标文件夹(&T)：
	Gui, Add, Edit, x100 y15 h40 w350 vSHLTG_Path
	Gui, Add, Button, x280 y60 w80 h25 Default gPMF_OK, 确定(&S)
	Gui, Add, Button, x370 y60 w80 h25 g66GuiClose, 取消(&X)
	Gui,show, , 挂载分区[%CandySel%]到NTFS分区的空文件夹
}
return

PMF_OK:
Gui,66:Default
gui, submit, hide
if !SHLTG_Path
return
if !FileIsNTFS(SHLTG_Path)
{
	msgbox 文件夹所在分区不是 NTFS 文件系统格式！
return
}
if !FileExist(SHLTG_Path)
	FileCreateDir, % SHLTG_Path
if !FolderIsEmpty(SHLTG_Path)
{
	msgbox 错误，文件夹不为空！
return
}
VolumeName := GetVolumeNameForVolumeMountPoint(CandySel)
If VolumeName
{
	if !SetVolumeMountPoint(SHLTG_Path, VolumeName)
		msgbox 挂载分区出现错误`nErrorLevel: %ErrorLevel%`nA_LastError: %A_LastError%`n
}
return

Cando_取消分区挂载的文件夹:
VolumeName := GetVolumeNameForVolumeMountPoint(CandySel)
if ErrorLevel
	msgbox 错误`nErrorLevel: %ErrorLevel%`nA_LastError: %A_LastError%`n
if !VolumeName
{
	msgbox 该文件夹可能不是分区挂载的！
return
}
if !DeleteVolumeMountPoint(CandySel)
	msgbox 取消挂载的文件夹出现错误`nErrorLevel: %ErrorLevel%`nA_LastError: %A_LastError%`n
return

Cando_挂载文件夹为分区:
DefineDosDevice(Candy_Cmd_Str3, CandySel)
return

Cando_取消文件夹挂载的分区:
DefineDosDevice(CandySel)
return


/*
q::
;DefineDosDevice("N:")
;DefineDosDevice("N:","Z:")

;MsgBox % QueryDosDevice("N:")
;msgbox % GetVolumeNameForVolumeMountPoint("Z:\")

您可以通过使用SetVolumeMountPoint函数为本地卷分配一个驱动器号（例如，X:），前提是没有卷已经分配给该驱动器号。如果本地卷已经有一个驱动器号，那么SetVolumeMountPoint将失败。要处理这种情况，首先使用DeleteVolumeMountPoint函数删除驱动器代号。示例代码请参见编辑驱动器号分配。

系统支持每个卷最多支持一个驱动器字母。因此，您不能让C:\和F:\代表同一个卷。
*/

DefineDosDevice(sDevice, sPath = "")
{
	sDevice := RTrim(sDevice, " \")
	sPath := RTrim(sPath, " \")
	Return DllCall("DefineDosDevice", "Uint", sPath ? 0 : 1|2, "str", sDevice, "str", sPath)
}

/*
    Retrieves information about the specified MS-DOS device.
    Parameters:
        DeviceName:
            An MS-DOS device name string specifying the target of the query.
            This parameter can be a path or string like "\\?\Volume{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}\".
            If this parameter is an empty string, the function will return a list of all existing MS-DOS device names.
    Return value:
        If the function succeeds, the return value is an Array with one or more strings.
        - The first string stored into the Array is the current mapping for the device.
        - The other strings represent undeleted prior mappings for the device.
        If the function fails, the return value is zero. A_LastError contains a system error code.
*/
QueryDosDevice(sDevice = "")
{
	sDevice := RTrim(sDevice, " \")
	VarSetCapacity(sPath, 256, 0)
	Size := DllCall("QueryDosDevice", "UPtr", sDevice ? &sDevice : 0, "UPtr", &sPath, "Uint", 256)
	Name := "", List := [], Ptr := &sPath
; Size the number of bytes comprising the formatted return Value.
;   on whether PATHS/PATH contain Unicode characters. It CAN happen that
;   calling QueryDosDeviceW("E:") returns "25: \Device\Harddiskvolume3" and
;   calling QueryDosDeviceW("V:") returns "34: \??\E:\bin\apps" because the
;   \??\ prefix implies a Unicode string.

	if !Size && Errorlevel  
	return 0
	while StrLen(Name := StrGet(Ptr))
	{
		;msgbox % Ptr " - " Name " - " StrPut(Name, "UTF-16")
		List.Push(Name) , Ptr := Ptr+StrPut(Name, "UTF-16")*2
	}
Return List
} ; https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-querydosdevicew

GetVolumeNameForVolumeMountPoint(pl)
{
	pl := RTrim(pl, " \")
	pl := pl "\"
	VarSetCapacity(VolumeName, 100, 0)
	hl:=dllcall("Kernel32.dll\GetVolumeNameForVolumeMountPoint", "Str", pl, "Str", VolumeName, "Uint", 100, "Int")
	if hl && !ErrorLevel
	return VolumeName
	else
	return 0
}

DeleteVolumeMountPoint(pl)
{
	pl := RTrim(pl, " \")
	pl := pl "\"
	hl:=dllcall("Kernel32.dll\DeleteVolumeMountPoint", "Str", pl)
	if hl && !ErrorLevel
	return 1
	else
	return 0
}

SetVolumeMountPoint(pl, VolumeName)
{
	pl := RTrim(pl, " \")
	pl := pl "\"
	hl:=dllcall("Kernel32.dll\SetVolumeMountPoint", "Str", pl, "Str", VolumeName)
	if hl && !ErrorLevel
	return 1
	else
	return 0
}

FolderIsEmpty(fpath){
	Loop, Files, %fpath%\*.*, FD
		return 0
	return 1
}

FileIsNTFS(fpath){
SplitPath, fpath, , , , , OutDrive
DriveGet, FType, FS, %OutDrive%
If (FType<>"NTFS")
	return 0
return 1
}