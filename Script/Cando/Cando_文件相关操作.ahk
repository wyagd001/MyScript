Cando_合并文本文件:
	loop, parse, CandySel, `n,`r
	{
		SplitPath, A_LoopField, , , File_Ext, ,
		If File_Ext in txt,ahk,ini,js,vbs,bat
		{
			FileEncoding, % File_GetEncoding(A_LoopField)
			Fileread, FileR_TFC, %A_loopfield%
			Tmp_Str = %Tmp_Str%%A_loopfield%`r`n`r`n%FileR_TFC%`r`n`r`n
		}
	}
	FileAppend, %Tmp_Str%, %CandySel_ParentPath%\合并.txt
	Tmp_Str := FileR_TFC := ""
Return

Cando_复制内容:
FileEncoding, % File_GetEncoding(CandySel)
fileread, FileR_TFC, %CandySel%
FileEncoding
try Clipboard := FileR_TFC
FileR_TFC := ""
return

Cando_生成快捷方式:
	FileCreateShortcut, %CandySel%, %CandySel_ParentPath%\%CandySel_FileNameNoExt%.lnk
Return

Cando_生成快捷方式到指定目录:
	Gui,66:Destroy
	Gui,66:Default
	Gui, Add, Text, x10 y17, 目标文件(&T)
	Gui, Add, Edit, x110 y15 h30 w350 readonly vSHL_TGPath, % CandySel
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
		errFlag:=1, Tmp_Str :="未设置快捷方式名称。"
	If (errFlag=0) And (RegexMatch(SHL_Name, "[\\/:\*\?""<>\|]")>0)
		errFlag:=2, Tmp_Str :="快捷方式名称不得包含以下任意字符：\ / : * \ ? "" < > |"
	If (errFlag=0) And (SHL_Path !="") And !InStr(FileExist(SHL_Path), "D")
		errFlag:=3, Tmp_Str := "快捷方式目录不存在。"
	If (errFlag=0) And (FileExist(SHL_TGPath)="")
		errFlag:=4, Tmp_Str := "目标文件不存在。"
	If (errFlag=0) And (SHL_Path="") And (SHL_Desktop=0) And (SHL_QL=0) And (SHL_Fav=0)
		errFlag:=5, Tmp_Str := "快捷方式目录为空并且未勾选任一目录。"
	If (errFlag=0) 
	{
		Gui, Destroy
		if (SHL_Path !="")
			FileCreateShortcut, % SHL_TGPath, %SHL_Path%\%SHL_Name%.lnk
		if SHL_Desktop
			FileCreateShortcut, % SHL_TGPath, %A_desktop%\%SHL_Name%.lnk
		if SHL_QL
			FileCreateShortcut, % SHL_TGPath, %A_AppData%\Microsoft\Internet Explorer\Quick Launch\%SHL_Name%.lnk
		if SHL_Fav
			FileCreateShortcut, % SHL_TGPath, %A_ScriptDir%\favorites\%SHL_Name%.lnk
	}
	Else 
	{
		Gui, +OwnDialogs
		If errFlag In 1,2
			GuiControl, Focus, SHL_Name
		If errFlag In 3,5
			GuiControl, Focus, SHL_Path
		If errFlag In 4
			GuiControl, Focus, SHL_TGPath
		MsgBox, 262192, 创建快捷方式错误, %Tmp_Str%！
	}
	errFlag:=Tmp_Str:=SHL_TGPath:=SHL_Name:=SHL_Path:=""
return

cando_放入同名文件夹:
  FileCreateDir,%CandySel_ParentPath%\%CandySel_FileNamenoExt%
  FileMove,%CandySel%,%CandySel_ParentPath%\%CandySel_FileNamenoExt%
Return

cando_ListHardLinks:
msgbox % ListHardLinks(CandySel)
return

Cando_CreateLink:
	If (CF_GetDriveFS(CandySel_Drive)!="NTFS")
	{
		Gui, +OwnDialogs
		MsgBox, 262192, 磁盘格式不匹配, 当前磁盘 %CandySel_Drive% 不是 NTFS 文件系统格式，无法创建硬软链接！
		Return
	}
	Gui,66:Destroy
	Gui,66:Default
	Gui, Add, Text, x10 y17, 目标文件(&T)
	Gui, Add, Edit, x90 y15 h40 w350 readonly vSHHL_TGPath, % CandySel
	Gui, Add, Text, x10 y65, 链接文件(&P)
	Gui, Add, Edit, x90 y63 h40 w350 vSHHL_Path gupdate_descr,
	Gui, Add, Radio, x90 y110 w120 h30 vSHHL_Type_Hardlink Checked gupdate_descr, 硬链接(仅文件)
	Gui, Add, Radio, x240 y110 w120 h30 vSHHL_Type_SymbolicLink gupdate_descr, 符号链接(软连接)
	Gui, Add, Text, x10 y150, 说明(&P)
	Gui, Add, Edit, x90 y148 h40 w350 readonly vSHHL_descr,
	Gui, Add, Button, x280 y200 w80 h25 Default gSHHL_OK, 确定(&S)
	Gui, Add, Button, x370 y200 w80 h25 g66GuiClose, 取消(&X)
	if (CandySel_Ext="Folder")
	{
		GuiControl, Disable, SHHL_Type_Hardlink
		GuiControl,, SHHL_Type_SymbolicLink, 1
	}
	Gui,show, , 为文件[%CandySel_FileNameWithExt%]创建链接
return

SHHL_OK:
Gui,66:Default
gui, submit, nohide
if !SHHL_Path
{
	guicontrol,, SHHL_descr, 链接文件路径为空！
	SHHL_Err := 1
}
if SHHL_Err
	return
SHHL_Path :=  Trim(SHHL_Path," `r`n`t")
if SHHL_Type_Hardlink
{
	returnVal := CreateHardLink(SHHL_TGPath, SHHL_Path)
	if returnVal
		guicontrol,, SHHL_descr, 创建文件硬链接成功！
	else
		guicontrol,, SHHL_descr, 失败！错误代码: %A_LastError%。
}
else if SHHL_Type_SymbolicLink && (CandySel_Ext="Folder")
{
	returnVal := CreateSymbolicLink(SHHL_TGPath, SHHL_Path, 0x1)
	if returnVal
		guicontrol,, SHHL_descr, 创建文件夹符号链接成功！
	else
		guicontrol,, SHHL_descr, 失败！错误代码: %A_LastError%。
}
else
{
	returnVal := CreateSymbolicLink(SHHL_TGPath, SHHL_Path)
	if returnVal
		guicontrol,, SHHL_descr, 创建文件符号链接成功！
	else
		guicontrol,, SHHL_descr, 失败！错误代码: %A_LastError%。
}
return

update_descr:
Gui,66:Default
gui, submit, nohide
If (RegexMatch(SHHL_Path, "^([a-zA-Z]:\\)[^\/:\*\?""\<>\|]*$") = 0)
{
	guicontrol,, SHHLF_descr, 链接文件路径错误。例如包含以下非法字符：\ / : * \ ? " < > |
	SHHL_Err := 1
	return
}
if SHHL_Type_Hardlink
{
	SplitPath, SHHL_Path, , , , , Tmp_Drive
	if (Tmp_Drive<>CandySel_Drive)
	{
		guicontrol,, SHHL_descr,硬链接文件分区错误，硬链接不能跨分区!
		SHHL_Err := 1
	}
	else
	{
		guicontrol,, SHHL_descr,
		SHHL_Err := 0
	}
}
if SHHL_Type_SymbolicLink
{
	If (CF_GetDriveFS(SHHL_Path)!="NTFS")
	{
		guicontrol,, SHHL_descr, 链接文件所在分区不是 NTFS 文件系统格式！
		SHHL_Err := 1
	}
else
	{
		guicontrol,, SHHL_descr,
		SHHL_Err := 0
	}
}
return