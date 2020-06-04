Cando_小说改名:
	FileEncoding, % File_GetEncoding(CandySel)
	Result := ""
	Loop, read, % CandySel
	{
		Result :=  Trim(A_LoopReadLine)
		if Result
		break
	}
	FileMove, %CandySel%, %CandySel_ParentPath%\%Result%.txt
	Result := ""
Return

Cando_文件名首字母大写:
	Loop, Parse, CandySel_FileNameNoExt, %A_Space%_`,|;-！`.  
	{  
		; 计算分隔符的位置.  
		Position += StrLen(A_LoopField) + 1
		; 获取解析循环中找到的分隔符.  
		Delimiter := SubStr(CandySel_FileNameNoExt, Position, 1)
		str1 := Format("{:T}", A_LoopField)
		out := out . str1 . Delimiter 
	}  
	FileMove, %CandySel%, %CandySel_ParentPath%\%out%.%CandySel_Ext%
	out := Position := ""
Return

Cando_文件名乱码转码:
	CandySel_FileNameNoExt := UrlDecode(CandySel_FileNameNoExt)
	FileMove, %CandySel%, %CandySel_ParentPath%\%CandySel_FileNameNoExt%.%CandySel_Ext%
return

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

Cando_文件列表:
	; dateCut := A_Now
	; EnvAdd, dateCut, -1, days       ; sets a date -24 hours from now
	列表产生的文件=%A_Temp%\万年书妖文件列表临时文件_%A_now%.txt

	loop, %CandySel%\*.*, 1, 1   ; change the folder name
	{
		;    if (A_LoopFileTimeModified >= dateCut)
		str .= A_LoopFileFullPath "`n"
	}
	FileAppend, %str%, %列表产生的文件%
	str := ""
	Run, notepad.exe %列表产生的文件%
Return

Cando_交换文件名:
	SwapName(CandySel)
Return

SwapName(Filelist)
{
	; 传递的字符串中的换行是回车+换行
	StringReplace, Filelist, Filelist, `r`n, `n
	StringSplit, File_, Filelist, `n
	SplitPath, File_1, , FileDir, , FileNameNoExt
	;msgbox % fileexist(File_1) " - " fileexist(File_2)
	FileMove, %File_1%, %FileDir%\%FileNameNoExt%.tempExt
	FileMove, %File_2%, %File_1%
	FileMove, %FileDir%\%FileNameNoExt%.tempExt, %File_2%
return
}

cando_多文件复制文件名:
	clip := ""
	Loop, Parse, CandySel, `n,`r 
	{
		SplitPath, A_LoopField, outfilename
		clip .= (clip = "" ? "" : "`r`n") outfilename
	}
	clipboard := clip
return

cando_多文件复制路径:
	clip := ""
	Loop, Parse, CandySel, `n,`r 
	{
		SplitPath, A_LoopField, outfilename
		clip .= (clip = "" ? "" : "`r`n") outfilename
	}
	clipboard:=clip
return

Cando_生成快捷方式:
	FileCreateShortcut, %CandySel%, %CandySel_ParentPath%\%CandySel_FileNameNoExt%.lnk
Return

Cando_生成快捷方式到指定目录:
	Gui,66:Destroy
	Gui,66:Default
	Gui, Add, Text, x10 y17, 目标文件(&T)
	Gui, Add, Edit, x110 y15 w300 readonly vSHLTG_Path, % CandySel
	Gui, Add, Text, x10 y48, 快捷方式目录(&P)
	Gui, Add, Edit, x110 y46 w300 vSHL_Path,
	Gui, Add, CheckBox, x110 y70 w40 h30 vSHL_Desktop, 桌面
	Gui, Add, CheckBox, x168 y70 w78 h30 vSHL_QL, 快速启动栏
	Gui, Add, CheckBox, x260 y70 w78 h30 vSHL_Fav, 脚本收藏夹
	Gui, Add, Text, x10 y110, 快捷方式名称(&N)
	Gui, Add, Edit, x110 y108 w300 vSHL_Name, %CandySel_FileNameNoExt%
	Gui, Add, Button, x220 y140 w80 h25 Default gSHL_OK, 确定(&S)
	Gui, Add, Button, x320 y140 w80 h25 g66GuiClose, 取消(&X)
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