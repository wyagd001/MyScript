Cando_文件创建软链接:
sPara=/S
gosub Cando_文件创建软硬链接
return

Cando_文件创建硬链接:
sPara=/H
gosub Cando_文件创建软硬链接
return

Cando_文件创建软硬链接:
	If (CF_GetDriveFS(CandySel_Drive)!="NTFS") {
		Gui, +OwnDialogs
		MsgBox, 262192, 磁盘格式不匹配, 当前磁盘 %CandySel_Drive% 不是 NTFS 文件系统格式，无法创建文件链接！
		Return
	}
	Gui,9:Destroy
	Gui,9:Default
	Gui,Add,Text,x10 y17, 链接名称(&N)
	Gui,Add,Edit,x90 y15 w300 vSHHL_Name,
	Gui,Add,Text,x10 y48, 链接目录(&P)
	Gui,Add,Edit,x90 y46 w300 vSHHL_Path,
	Gui,Add,Text,x10 y79, 目标文件(&T)
	Gui,Add,Edit,x90 y77 w300 vSHHL_TGPath,% CandySel
	Gui,Add,Button,x140 y110 w100 h25 Default gSHHL_OK2, 确定(&S)
	Gui,Add,Button,x245 y110 w100 h25 gSHHL_Cancel, 取消(&X)
	If(sPara="/S")
		Tmp_Str:="创建指向文件 [ " . CandySel_FileNameWithExt . " ] 的符号(软)链接"
	Else
		Tmp_Str:="创建指向文件 [ " . CandySel_FileNameWithExt . " ] 的硬链接"
	Gui,show,,%Tmp_Str%
Return

SHHL_OK2:
	Gui,9:Default
	Gui,Submit,NoHide
	SHHL_Name:=Trim(SHHL_Name),SHHL_Path:=Trim(SHHL_Path,"\"),errFlag := 0
	If (SHHL_Name="")
		errFlag:=1, Tmp_Str:="未设置链接名称。"
	If (errFlag=0) And (SHHL_Path="")
		errFlag:=2, Tmp_Str:="未设置链接所在目录。" 
	If (errFlag=0) And (RegexMatch(SHHL_Name, "[\\/:\*\?""<>\|]")>0)
		errFlag:=3, Tmp_Str:="链接名称不得包含以下任意字符：\ / : * \ ? "" < > |"
	If (errFlag=0) And (FileExist(SHHL_Path)="")
		errFlag:=4, Tmp_Str:= "链接目录不存在。"
	If (errFlag=0) And (FileExist(SHHL_TGPath)="") and  !CF_IsFolder(SHHL_TGPath)
		errFlag:=5, Tmp_Str:= "目标文件不存在。"
	If ((errFlag=0) And (sPara="/S")) 
	{
		SplitPath,SHHL_Path, , , , , Tmp_Drive
		If (CF_GetDriveFS(SHHL_Path)!="NTFS")
			errFlag:=6, Tmp_Str:= "链接所在磁盘 " Tmp_Drive " 不是 NTFS 文件系统格式，无法创建文件链接!"
	}
	If ((errFlag=0) And (sPara="/H")) 
	{
		SplitPath,SHHL_Path, , , , , Tmp_Drive
		If (Tmp_Drive <> CandySel_Drive)
			errFlag:=7, Tmp_Str:="硬链接与目标文件不在同一盘符，无法创建硬链接！"
	}
	If (errFlag=0) 
	{
		Gui, Destroy
		If(sPara="/S")
			RunWait, %comspec% /c "mklink "%SHHL_Path%\%SHHL_Name%" "%SHHL_TGPath%" > "%A_Temp%\~MKLINK.TMP"",, Hide UseErrorLevel
		If(sPara="/H")
			RunWait, %comspec% /c "mklink /H "%SHHL_Path%\%SHHL_Name%" "%SHHL_TGPath%" > "%A_Temp%\~MKLINK.TMP"",, Hide UseErrorLevel
		If(ErrorLevel="ERROR")
			errFlag:=1
		Else 
		{
			FileReadLine, FileR_Tmp_Str, %A_Temp%\~MKLINK.TMP, 1
			If (ErrorLevel)
				errFlag:=1
			Else
			{
				Tmp_Str=%FileR_Tmp_Str%
				If(sPara="/S")
				{
					If (Tmp_Str<>"为 " . SHHL_Path . "\" . SHHL_Name . " <<===>> " . SHHL_TGPath . " 创建的符号链接")
						errFlag:=1
				}
				If(sPara="/H")
				{
					If (Tmp_Str<>"为 " . SHHL_Path . "\" . SHHL_Name . " <<===>> " . SHHL_TGPath . " 创建了硬链接")
						errFlag:=1
				}
			}
		}
		FileDelete, %A_Temp%\~MKLINK.TMP

		Gui, +OwnDialogs
		If (errFlag=0)
			MsgBox, 262208, 创建文件链接成功, % "成功创建文件链接！`n链接: " . SHHL_Path . "\" . SHHL_Name "`n指向: " SHHL_TGPath
		Else
			MsgBox, 262192, 错误, 创建文件链接错误，请检查后重试！
		Return
	}
	Else 
	{
		Gui, +OwnDialogs
		MsgBox, 262192, 创建文件链接错误, %Tmp_Str%！
		If errFlag In 1,3
			GuiControl, Focus, SHHL_Name
		If errFlag In 2,4,6,7
			GuiControl, Focus, SHHL_Path
		Else If errFlag In 5
			GuiControl, Focus, SHHL_TGPath
	}
	errFlag := Tmp_Str := Tmp_Drive := FileR_Tmp_Str := ""
Return

SHHL_Cancel:
	Gui,9:Destroy
Return