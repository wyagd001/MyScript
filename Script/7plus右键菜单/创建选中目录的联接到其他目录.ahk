1008:
sPara=/SRC
SetTimer, 创建目录联接, -200
Return

创建目录联接:
Critical,On
If(sPara="/SRC")
	Files := GetSelectedFiles()
If(sPara="/DES") 
	Files := GetCurrentFolder()
If !Files
{
	MsgBox,,, 获取文件路径失败。, 3
Return
}
Critical, Off
SplitPath, Files, , , , , Tmp_Drive
If !(FileInNTFS(Files))
{
	Gui, +OwnDialogs
	MsgBox, 262192, 磁盘格式不匹配, 当前磁盘 %Tmp_Drive% 不是 NTFS 文件系统格式，无法创建目录联接！
Return
}

Gui,9:Destroy
Gui,9:Default
Gui, Add,Text, x10 y17, 联接名称(&N)
Gui, Add, Edit, x90 y15 w400 vSHSL_Name,
Gui, Add, Text, x10 y48, 联接目录(&P)
Gui, Add, Edit, x90 y46 w400 h40 vSHSL_Path, % ((sPara="/DES")?Files:"")
Gui, Add, Text, x10 y95, 目标目录(&T)
Gui, Add, Edit, x90 y93 w400 h40 vSHSL_TGPath, % ((sPara="/SRC")?Files:"")
Gui, Add, Button, x270 y140 w100 h25 Default gSHSL_OK, 确定(&S)
Gui, Add, Button, x380 y140 w100 h25 gSHSL_Cancel, 取消(&X)
If(sPara="/SRC")
{
	GuiControl, disable, SHSL_TGPath
	If (StrLen(Files) = 3) And (SubStr(Files, -1) = ":\")
		Tmp_Str := Files
	Else
		SplitPath, Files, Tmp_Str
	Tmp_Str := "创建指向目录 [" . Tmp_Str . "] 的联接"
}
Else
{
	GuiControl,disable,SHSL_Path
	Tmp_Str := "在当前位置创建目录联接"
}
Gui, show,, %Tmp_Str%
Return

VL_OK:
Gui,9:Default
Gui, Submit, NoHide
SHSL_Name := Trim(SHSL_Name), SHSL_Path := Trim(SHSL_Path,"\"), SHSL_TGPath := Trim(SHSL_TGPath, "\"), errFlag := 0
If (SHSL_Name="")
	errFlag := 1, Tmp_Str := "未设置联接名称"
If (errFlag=0) And (SHSL_Path="")
	errFlag := 2, Tmp_Str := "未设置联接所在目录" 
If (errFlag = 0) And (SHSL_TGPath = "")
	errFlag := 3, Tmp_Str := "未设置目标目录" 
If (errFlag = 0) And (RegexMatch(SHSL_Name, "[\\/:\*\?""<>\|]")>0)
	errFlag := 4, Tmp_Str := "联接名称不得包含以下任意字符：\ / : * \ ? "" < > |"
If (errFlag=0) And (FileExist(SHSL_Path) = "")
	errFlag := 5, Tmp_Str := "联接目录不存在"
If (errFlag = 0) And (FileExist(SHSL_TGPath) = "")
	errFlag := 6, Tmp_Str:= "目标目录不存在"
If ((errFlag = 0) And (sPara = "/SRC")) 
{
	SplitPath, SHSL_Path, , , , , Tmp_Drive
	If !(FileInNTFS(SHSL_Path))
		errFlag := 7, Tmp_Str := "联接所在磁盘 " Tmp_Drive " 不是 NTFS 文件系统格式，无法创建目录联接"
}
If ((errFlag = 0) And (sPara = "/DES")) 
{
	SplitPath, SHSL_TGPath, , , , , Tmp_Drive
	If !(FileInNTFS(SHSL_TGPath))
		errFlag := 8, Tmp_Str := "联接目录所在磁盘 " Tmp_Drive " 不是 NTFS 文件系统格式，无法创建目录联接"
}
If (errFlag=0)
{
	Gui, Destroy
	RunWait, %comspec% /c "mklink /j "%SHSL_Path%\%SHSL_Name%" "%SHSL_TGPath%" > "%A_Temp%\~MKLINK_DIR_SRC.TMP"",, Hide UseErrorLevel
	If(ErrorLevel = "ERROR")
		errFlag := 1
	Else 
	{
		FileReadLine, FileR_Tmp_Str, %A_Temp%\~MKLINK_DIR_SRC.TMP, 1
		If (ErrorLevel)
			errFlag := 1
		Else
		{
			Tmp_Str = %FileR_Tmp_Str%
			If (Tmp_Str<>"为 " . SHSL_Path . "\" . SHSL_Name . " <<===>> " . SHSL_TGPath . " 创建的联接")
				errFlag := 1
		}
	}
	FileDelete, %A_Temp%\~MKLINK_DIR_SRC.TMP

	Gui, +OwnDialogs
	If (errFlag = 0)
		MsgBox, 262208, 创建目录联接成功, % "成功创建目录联接！`n联接: " . SHSL_Path . "\" . SHSL_Name "`n指向: " SHSL_TGPath
	Else
		MsgBox, 262192, 错误, 创建目录联接错误，请检查后重试！
	Return
}
Else 
{
	Gui, +OwnDialogs
	MsgBox, 262192, 创建目录联接错误, %Tmp_Str%！
	If errFlag In 1,4
		GuiControl, Focus, SHSL_Name
	If errFlag In 2,5,7
		GuiControl, Focus, SHSL_Path
	Else If errFlag In 3,6,8
		GuiControl, Focus, SHSL_TGPath
}
errFlag := Tmp_Str := ""
Return

VL_Cancel:
9GuiClose:
9GuiEscape:
	Gui,9:Destroy
Return

7PlusMenu_创建选中目录的联接到其他目录()
{
	section = 创建选中目录的联接到其他目录
	defaultSet=
	( LTrim
		ID = 1008
		Name = 创建文件夹的目录联接(镜像)
		Description = 在指定文件夹中创建选中文件夹的目录联接(镜像)
		SubMenu = 7plus
		FileTypes =
		SingleFileOnly = 0
		Directory = 1
		DirectoryBackground = 0
		Desktop = 0
		showmenu = 1
	)
	IniWrite, % defaultSet, % 7PlusMenu_ProFile_Ini, % section
return
}