Cando_文件创建软链接:
sPara=/S
gosub Cando_文件创建软硬链接
return

Cando_文件创建硬链接:
sPara=/H
gosub Cando_文件创建软硬链接
return

Cando_文件创建软硬链接:
	SplitPath,CandySel, , , , , tempStr1
	DriveGet, tempStr, FS, %tempStr1%
	If (tempStr<>"NTFS") {
		Gui, +OwnDialogs
		MsgBox, 262192, 磁盘格式不匹配, 当前磁盘 %tempStr1% 不是 NTFS 文件系统格式，无法创建文件链接！
		Return
	}
	Gui,9:Destroy
	Gui,9:Default
	Gui,Add,Text,x10 y17, 链接名称(&N)
	Gui,Add,Edit,x90 y15 w300 vSH_Name,
	Gui,Add,Text,x10 y48, 链接目录(&P)
	Gui,Add,Edit,x90 y46 w300 vSH_Path,
	Gui,Add,Text,x10 y79, 目标文件(&T)
	Gui,Add,Edit,x90 y77 w300 vSHTG_Path,% CandySel
	Gui,Add,Button,x140 y110 w100 h25 Default gSH_OK, 确定(&S)
	Gui,Add,Button,x245 y110 w100 h25 gSH_Cancel, 取消(&X)
	SplitPath, CandySel, tempStr
If(sPara="/S")
		tempStr:="创建指向文件 [ " . tempStr . " ] 的符号(软)链接"
	Else
		tempStr:="创建指向文件 [ " . tempStr . " ] 的硬链接"
	Gui,show,,%tempStr%
Return

SH_OK:
	Gui,9:Default
	Gui,Submit,NoHide
	SH_Name:=Trim(SH_Name),SH_Path:=Trim(SH_Path,"\"),errFlag := 0
	If (SH_Name="")
		errFlag:=1, tempStr:="未设置链接名称"
	If (errFlag=0) And (SH_Path="")
		errFlag:=2, tempStr:="未设置链接所在目录" 
	If (errFlag=0) And (RegexMatch(SH_Name, "[\\/:\*\?""<>\|]")>0)
		errFlag:=3, tempStr:="链接名称不得包含以下任意字符：\ / : * \ ? "" < > |"
	If (errFlag=0) And (FileExist(SH_Path)="")
		errFlag:=4, tempStr:= "链接目录不存在"
	If (errFlag=0) And (FileExist(SHTG_Path)="") and  !InStr(FileExist(SHTG_Path), "D")
		errFlag:=5, tempStr:= "目标文件不存在"
	If ((errFlag=0) And (sPara="/S")) 
	{
		SplitPath,SH_Path, , , , , tempStr1
		DriveGet, tempStr, FS, %tempStr1%
		If (tempStr<>"NTFS")
			errFlag:=6, tempStr:= "链接所在磁盘 " tempStr1 " 不是 NTFS 文件系统格式，无法创建文件链接"
	}
		If ((errFlag=0) And (sPara="/H")) 
	{
		SplitPath,SH_Path, , , , , tempStr1
		SplitPath,CandySel, , , , , tempStr2
		If (tempStr1 <> tempStr2)
			errFlag:=7, tempStr:="硬链接与目标文件不在同一盘符，无法创建硬链接"
	}
	If (errFlag=0) 
	{
		Gui, Destroy
		If(sPara="/S")
			RunWait, %comspec% /c "mklink "%SH_Path%\%SH_Name%" "%SHTG_Path%" > "%A_Temp%\~MKLINK.TMP"",, Hide UseErrorLevel
		If(sPara="/H")
			RunWait, %comspec% /c "mklink /H "%SH_Path%\%SH_Name%" "%SHTG_Path%" > "%A_Temp%\~MKLINK.TMP"",, Hide UseErrorLevel
		If(ErrorLevel="ERROR")
			errFlag:=1
		Else 
		{
			FileReadLine, tempStr, %A_Temp%\~MKLINK.TMP, 1
			If (ErrorLevel)
				errFlag:=1
			Else
			{
				tempStr=%tempStr%
If(sPara="/S")
{
				If (tempStr<>"为 " . SH_Path . "\" . SH_Name . " <<===>> " . SHTG_Path . " 创建的符号链接")
					errFlag:=1
}
		If(sPara="/H")
{
				If (tempStr<>"为 " . SH_Path . "\" . SH_Name . " <<===>> " . SHTG_Path . " 创建了硬链接")
					errFlag:=1
}
			}
		}
		FileDelete, %A_Temp%\~MKLINK.TMP


		Gui, +OwnDialogs
		If (errFlag=0)
			MsgBox, 262208, 创建文件链接成功, % "成功创建文件链接！`n链接: " . SH_Path . "\" . SH_Name "`n指向: " SHTG_Path
		Else
			MsgBox, 262192, 错误, 创建文件链接错误，请检查后重试！
		Return
	} 
	Else 
	{
		Gui, +OwnDialogs
		MsgBox, 262192, 创建文件链接错误, %tempStr%！
		If errFlag In 1,3
			GuiControl, Focus, SH_Name
		If errFlag In 2,4,6,7
			GuiControl, Focus, SH_Path
		Else If errFlag In 5
			GuiControl, Focus, SHTG_Path
	}
	errFlag:=tempStr:=tempStr1:=tempStr2:=""
Return

SH_Cancel:
	Gui,9:Destroy
Return