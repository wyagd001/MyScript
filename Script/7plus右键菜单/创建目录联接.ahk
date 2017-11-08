1008:
	sPara=/SRC
	SetTimer,创建目录联接,-200
Return

1009:
	sPara=/DES
	SetTimer,创建目录联接,-200
Return

创建目录联接:
	Critical,On
	If(sPara="/SRC")
		Files := GetSelectedFiles()
	If(sPara="/DES") 
		Files:=GetCurrentFolder()
	If !Files
	{
		MsgBox,,,获取文件路径失败。,3
		Return
	}
	Critical,Off
	SplitPath,Files, , , , , tempStr1
	DriveGet, tempStr, FS, %tempStr1%
	If (tempStr<>"NTFS") {
		Gui, +OwnDialogs
		MsgBox, 262192, 磁盘格式不匹配, 当前磁盘 %tempStr1% 不是 NTFS 文件系统格式，无法创建目录联接！
		Return
	}
	
	Gui,9:Destroy
	Gui,9:Default
	Gui,Add,Text,x10 y17, 联接名称(&N)
	Gui,Add,Edit,x90 y15 w250 vVL_Name,
	Gui,Add,Text,x10 y48, 联接目录(&P)
	Gui,Add,Edit,x90 y46 w250 vVL_Path,% temp:=((sPara="/DES")?Files:"")
	Gui,Add,Text,x10 y79, 目标目录(&T)
	Gui,Add,Edit,x90 y77 w250 vTG_Path,% temp:=((sPara="/SRC")?Files:"")
	Gui,Add,Button,x140 y110 w100 h25 Default gVL_OK, 确定(&S)
	Gui,Add,Button,x245 y110 w100 h25 gVL_Cancel, 取消(&X)
	If(sPara="/SRC")
	{
		GuiControl,disable,TG_Path
		If (StrLen(Files)=3) And (SubStr(Files, -1)=":\")
			tempStr:=Files
		Else
			SplitPath, Files, tempStr
		tempStr:="创建指向目录 [" . tempStr . "] 的联接"
	}
	Else
	{
		GuiControl,disable,VL_Path
		tempStr:="在当前位置创建目录联接"
	}
	Gui,show,,%tempStr%
Return

VL_OK:
	Gui,9:Default
	Gui,Submit,NoHide
	VL_Name:=Trim(VL_Name),VL_Path:=Trim(VL_Path,"\"),TG_Path:=Trim(TG_Path,"\"),errFlag := 0
	If (VL_Name="")
		errFlag:=1, tempStr:="未设置联接名称"
	If (errFlag=0) And (VL_Path="")
		errFlag:=2, tempStr:="未设置联接所在目录" 
	If (errFlag=0) And (TG_Path="")
		errFlag:=3, tempStr:="未设置目标目录" 
	If (errFlag=0) And (RegexMatch(VL_Name, "[\\/:\*\?""<>\|]")>0)
		errFlag:=4, tempStr:="联接名称不得包含以下任意字符：\ / : * \ ? "" < > |"
	If (errFlag=0) And (FileExist(VL_Path)="")
		errFlag:=5, tempStr:= "联接目录不存在"
	If (errFlag=0) And (FileExist(TG_Path)="")
		errFlag:=6, tempStr:= "目标目录不存在"
	If ((errFlag=0) And (sPara="/SRC")) 
	{
		SplitPath,VL_Path, , , , , tempStr1
		DriveGet, tempStr, FS, %tempStr1%
		If (tempStr<>"NTFS")
			errFlag:=7, tempStr:= "联接所在磁盘 " tempStr1 " 不是 NTFS 文件系统格式，无法创建目录联接"
	}
		If ((errFlag=0) And (sPara="/DES")) 
	{
		SplitPath,TG_Path, , , , , tempStr1
		DriveGet, tempStr, FS, %tempStr1%
		If (tempStr<>"NTFS")
			errFlag:=8, tempStr:="联接目录所在磁盘 " tempStr1 " 不是 NTFS 文件系统格式，无法创建目录联接"
	}
	If (errFlag=0)
	{
		Gui, Destroy
		RunWait, %comspec% /c "mklink /j "%VL_Path%\%VL_Name%" "%TG_Path%" > "%A_Temp%\~MKLINK_DIR_SRC.TMP"",, Hide UseErrorLevel
		If(ErrorLevel="ERROR")
			errFlag:=1
		Else 
		{
			FileReadLine, tempStr, %A_Temp%\~MKLINK_DIR_SRC.TMP, 1
			If (ErrorLevel)
				errFlag:=1
			Else
			{
				tempStr=%tempStr%
				If (tempStr<>"为 " . VL_Path . "\" . VL_Name . " <<===>> " . TG_Path . " 创建的联接")
					errFlag:=1
			}
		}
		FileDelete, %A_Temp%\~MKLINK_DIR_SRC.TMP


		Gui, +OwnDialogs
		If (errFlag=0)
			MsgBox, 262208, 创建目录联接成功, % "成功创建目录联接！`n联接: " . VL_Path . "\" . VL_Name "`n指向: " TG_Path
		Else
			MsgBox, 262192, 错误, 创建目录联接错误，请检查后重试！
		Return
	} 
	Else 
	{
		Gui, +OwnDialogs
		MsgBox, 262192, 创建目录联接错误, %tempStr%！
		If errFlag In 1,4
			GuiControl, Focus, VL_Name
		If errFlag In 2,5,7
			GuiControl, Focus, VL_Path
		Else If errFlag In 3,6,8
			GuiControl, Focus, TG_Path
	}
	errFlag:=tempStr:=""
Return

VL_Cancel:
9GuiClose:
9GuiEscape:
	Gui,9:Destroy
Return