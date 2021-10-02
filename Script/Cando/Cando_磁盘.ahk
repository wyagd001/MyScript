Cando_更改盘符:
if FileExist(Candy_Cmd_Str3)
{
	msgbox 错误，磁盘 %Candy_Cmd_Str3% 已经存在！
return
}
if fileexist(CandySel "Windows\System32\winload.exe")
{
	msgbox 选中盘符[%CandySel%]为系统盘, 暂不支持更改!
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
	if !CF_FolderIsEmpty(Candy_Cmd_Str3)
	{
		msgbox 错误，文件夹不为空！
	return
	}
	if (CF_GetDriveFS(Candy_Cmd_Str3)!="NTFS")
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
	Gui, Add, Edit, x100 y15 h40 w350 vPMTF_TGPath
	Gui, Add, Button, x280 y60 w80 h25 Default gPMTF_OK, 确定(&S)
	Gui, Add, Button, x370 y60 w80 h25 g66GuiClose, 取消(&X)
	Gui,show, , 挂载分区[%CandySel%]到NTFS分区的空文件夹
}
return

PMTF_OK:
Gui,66:Default
gui, submit, hide
if !PMTF_TGPath
return
if (CF_GetDriveFS(PMTF_TGPath)!="NTFS")
{
	msgbox 文件夹所在分区不是 NTFS 文件系统格式！
return
}
if !FileExist(PMTF_TGPath)
	FileCreateDir, % PMTF_TGPath
if !CF_FolderIsEmpty(PMTF_TGPath)
{
	msgbox 错误，文件夹不为空！
return
}
VolumeName := GetVolumeNameForVolumeMountPoint(CandySel)
If VolumeName
{
	if !SetVolumeMountPoint(PMTF_TGPath, VolumeName)
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

Cando_读取硬盘扇区:
msgbox % readSector(Candy_Cmd_Str3)
return

; 格式化分区时产生的分区序列号(卷序列号, 磁盘序列号, VolumeId)
; 等同于 DriveGet, OutputVar, Serial, C:
; 获取 8 个字符长度的分区序列号
; 不同的是本函数在分区为 NTFS 格式时获取 16 个字符长度的分区序列号
Cando_GetVolumeId:
hVolume := Trim(CandySel, "\")
Tmp_Str := readSector(hVolume)
Tmp_Val := CF_GetDriveFS(CandySel)
if (Tmp_Val="NTFS")  ; NTFS格式
{
	Tmp_Str := SubStr(Tmp_Str, 145, 16)
	msgbox % Format("{:16X}", _byteswap_uint64("0x" Tmp_Str))
}
else if (Tmp_Val="FAT32")
{
  ;msgbox % Tmp_Str
	Tmp_Str := SubStr(Tmp_Str, 135, 8)
	msgbox % Format("{:08X}", _byteswap_uint32("0x" Tmp_Str))
}
else
{
	DriveGet, Tmp_Val, Serial, hVolume
	msgbox % Tmp_Val
}
return