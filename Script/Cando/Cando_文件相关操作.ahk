Cando_合并文本文件:
	loop, parse, CandySel, `n,`r
	{
		SplitPath, A_LoopField, , , ext, ,
		If ext in txt,ahk,ini,js,vbs,bat
		{
			FileEncoding, % File_GetEncoding(A_LoopField)
			Fileread, text, %A_loopfield%
			all_text = %all_text%%A_loopfield%`r`n`r`n%text%`r`n`r`n
		}
	}
	FileAppend, %all_text%, %CandySel_ParentPath%\合并.txt
	all_text := text := ""
Return

Cando_生成快捷方式:
	FileCreateShortcut, %CandySel%, %CandySel_ParentPath%\%CandySel_FileNameNoExt%.lnk
Return

Cando_生成快捷方式到指定目录:
	Gui,66:Destroy
	Gui,66:Default
	Gui, Add, Text, x10 y17, 目标文件(&T)
	Gui, Add, Edit, x110 y15 h30 w350 readonly vSHLTG_Path, % CandySel
	Gui, Add, Text, x10 y50, 快捷方式目录(&P)
	Gui, Add, Edit, x110 y48 h30 w350 vSHL_Path,
	Gui, Add, CheckBox, x110 y80 w40 h30 vSHL_Desktop, 桌面
	Gui, Add, CheckBox, x168 y80 w78 h30 vSHL_QL, 快速启动栏
	Gui, Add, CheckBox, x260 y80 w78 h30 vSHL_Fav, 脚本收藏夹
	Gui, Add, Text, x10 y110, 快捷方式名称(&N)
	Gui, Add, Edit, x110 y108 w350 vSHL_Name, %CandySel_FileNameNoExt%
	Gui, Add, Button, x280 y140 w80 h25 Default gSHL_OK, 确定(&S)
	Gui, Add, Button, x370 y140 w80 h25 g66GuiClose, 取消(&X)
	Gui,show, , 为文件[%CandySel_FileNameWithExt%]创建快捷方式
Return

SHL_OK:
	Gui,66:Default
	Gui, Submit, NoHide
	SHL_Name:=Trim(SHL_Name), SHL_Path:=Trim(SHL_Path,"\"), errFlag := 0
	If (SHL_Name="")
		errFlag:=1, tempStr:="未设置快捷方式名称"
	If (errFlag=0) And (RegexMatch(SHL_Name, "[\\/:\*\?""<>\|]")>0)
		errFlag:=2, tempStr:="快捷方式名称不得包含以下任意字符：\ / : * \ ? "" < > |"
	If (errFlag=0) And (SHL_Path !="") And !InStr(FileExist(SHL_Path), "D")
		errFlag:=3, tempStr:= "快捷方式目录不存在"
	If (errFlag=0) And (FileExist(SHLTG_Path)="")
		errFlag:=4, tempStr:= "目标文件不存在"
	If (errFlag=0) And (SHL_Path="") And (SHL_Desktop=0) And (SHL_QL=0) And (SHL_Fav=0)
		errFlag:=5, tempStr:= "快捷方式目录为空并且未勾选任一目录"
	If (errFlag=0) 
	{
		Gui, Destroy
		if (SHL_Path !="")
			FileCreateShortcut, % SHLTG_Path, %SHL_Path%\%SHL_Name%.lnk
		if SHL_Desktop
			FileCreateShortcut, % SHLTG_Path, %A_desktop%\%SHL_Name%.lnk
		if SHL_QL
			FileCreateShortcut, % SHLTG_Path, %A_AppData%\Microsoft\Internet Explorer\Quick Launch\%SHL_Name%.lnk
		if SHL_Fav
			FileCreateShortcut, % SHLTG_Path, %A_ScriptDir%\favorites\%SHL_Name%.lnk
	}
	Else 
	{
		Gui, +OwnDialogs
		If errFlag In 1,2
			GuiControl, Focus, SHL_Name
		If errFlag In 3,5
			GuiControl, Focus, SHL_Path
		If errFlag In 4
			GuiControl, Focus, SHLTG_Path
		MsgBox, 262192, 创建快捷方式错误, %tempStr%！
	}
	errFlag:=tempStr:=SHLTG_Path:=SHL_Name:=SHL_Path:=""
return

cando_放入同名文件夹:
  FileCreateDir,%CandySel_ParentPath%\%CandySel_FileNamenoExt%
  FileMove,%CandySel%,%CandySel_ParentPath%\%CandySel_FileNamenoExt%
Return

cando_ListHardLinks:
msgbox % ListHardLinks(CandySel)
return

Cando_CreateLink:
	DriveGet, tempStr, FS, %CandySel_Drive%
	If (tempStr<>"NTFS") {
		Gui, +OwnDialogs
		MsgBox, 262192, 磁盘格式不匹配, 当前磁盘 %tempStr1% 不是 NTFS 文件系统格式，无法创建链接！
		Return
	}
	Gui,66:Destroy
	Gui,66:Default
	Gui, Add, Text, x10 y17, 目标文件(&T)
	Gui, Add, Edit, x90 y15 h40 w350 readonly vSHLTG_Path, % CandySel
	Gui, Add, Text, x10 y65, 链接文件(&P)
	Gui, Add, Edit, x90 y63 h40 w350 vSHL_Path gupdate_descr,
	Gui, Add, Radio, x90 y110 w120 h30 vF_Hardlink Checked gupdate_descr, 硬链接(仅文件)
	Gui, Add, Radio, x240 y110 w120 h30 vF_SymbolicLink gupdate_descr, 符号链接(软连接)
	Gui, Add, Text, x10 y150, 说明(&P)
	Gui, Add, Edit, x90 y148 h40 w350 readonly vF_descr,
	Gui, Add, Button, x280 y200 w80 h25 Default gF_OK, 确定(&S)
	Gui, Add, Button, x370 y200 w80 h25 g66GuiClose, 取消(&X)
	if (CandySel_Ext="Folder")
	{
		GuiControl, Disable, F_Hardlink
		GuiControl,, F_SymbolicLink, 1
	}
	Gui,show, , 为文件[%CandySel_FileNameWithExt%]创建链接
return

F_OK:
Gui,66:Default
gui, submit, nohide
SHL_Path :=  Trim(SHL_Path," `r`n`t")
if F_Err
	return
if F_Hardlink
{
	returnVal := CreateHardLink(SHLTG_Path, SHL_Path)
	if returnVal
		guicontrol,, F_descr, 创建文件硬链接成功！
	else
		guicontrol,, F_descr, 失败！错误代码: %A_LastError%。
}
if F_SymbolicLink && (CandySel_Ext="Folder")
{
	returnVal := CreateSymbolicLink(SHLTG_Path, SHL_Path, 0x1)
	if returnVal
		guicontrol,, F_descr, 创建文件夹符号链接成功！
	else
		guicontrol,, F_descr, 失败！错误代码: %A_LastError%。
}
if F_SymbolicLink
{
	returnVal := CreateSymbolicLink(SHLTG_Path, SHL_Path)
	if returnVal
		guicontrol,, F_descr, 创建文件符号链接成功！
	else
		guicontrol,, F_descr, 失败！错误代码: %A_LastError%。
}
return

update_descr:
Gui,66:Default
gui, submit, nohide
If (RegexMatch(SHL_Path, "^([a-zA-Z]:\\)[^\/:\*\?""\<>\|]*$") = 0)
{
	guicontrol,, F_descr,链接文件路径错误。例如包含以下非法字符：\ / : * \ ? " < > |
	F_Err := 1
	return
}
if F_Hardlink
{
	SplitPath,SHL_Path, , , , , tempStr1
	if (tempStr1<>CandySel_Drive)
	{
		guicontrol,, F_descr,硬链接文件分区错误，硬链接不能跨分区
		F_Err := 1
	}
	else
	{
		guicontrol,, F_descr,
		F_Err := 0
	}
}
if F_SymbolicLink
{
	SplitPath,SHL_Path, , , , , tempStr1
	DriveGet, tempStr, FS, %tempStr1%
	If (tempStr<>"NTFS")
	{
		guicontrol,, F_descr,链接文件分区不是 NTFS 文件系统格式！
		F_Err := 1
	}
else
	{
		guicontrol,, F_descr,
		F_Err := 0
	}
}
return

ListHardLinks(path)
{
	;static ERROR_MORE_DATA := 234
	static MAX_PATH := 260
	buflen := MAX_PATH
	VarSetCapacity(linkname, buflen)
	handle := DllCall("FindFirstFileNameW", "WStr", path, "UInt", 0, "UInt*", buflen, "WStr", linkname)
	root := SubStr(path, 1, 2)
	paths := ""
	try
	{
		Loop
		{
			paths .= root linkname "`n"
			
			buflen := MAX_PATH
			VarSetCapacity(linkname, buflen)
			more := DllCall("FindNextFileNameW", "UInt", handle, "UInt*", buflen, "WStr", linkname)
		} until (!more)
	} finally
	DllCall("FindClose", "UInt", handle)
	
	return paths
}

; https://docs.microsoft.com/zh-cn/windows/win32/api/winbase/nf-winbase-createhardlinka
; 成功返回非零值，失败返回 0.
CreateHardLink(InFile, OutFile)
{
Return (DllCall("CreateHardLink", "Str", OutFile, "Str", InFile, "Int",0))
}

; https://docs.microsoft.com/zh-cn/windows/win32/api/winbase/nf-winbase-createsymboliclinka
; 成功返回非零值，失败返回 0.
CreateSymbolicLink(InFile, OutFile, IsDirectoryLink := 0)
{
Return (DllCall("CreateSymbolicLink", "Str", OutFile, "Str", InFile, "UInt", IsDirectoryLink))
}