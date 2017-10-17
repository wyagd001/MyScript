Cando_小说改名:
FileReadLine,x,%CandySel%,1
FileMove,%CandySel%,%CandySel_ParentPath%\%x%.txt
Return

Cando_合并文本文件:
	loop, parse, CandySel, `n,`r
	{
		SplitPath, A_LoopField, , , ext, ,
		If(ext="txt"||ext="ahk"||ext="ini")
		{
			Fileread, text, %A_loopfield%
			all_text=%all_text%%A_loopfield%`r`n`r`n%text%`r`n`r`n
		}
	}
	FileAppend, %all_text%, %A_Desktop%\合并.txt
Return

Cando_文件列表:
   ; dateCut := A_Now
   ; EnvAdd, dateCut, -1, days       ; sets a date -24 hours from now
   列表产生的文件=%A_Temp%\万年书妖文件列表临时文件_%A_now%.txt
;    MsgBox %CandySel%
   loop, %CandySel%\*.*, 1, 1   ; change the folder name
   {
   ;    if (A_LoopFileTimeModified >= dateCut)
         str .= A_LoopFileFullPath "`n"
   }
   FileAppend,%str%,%列表产生的文件%
;    Sleep,50
   Run,notepad.exe %列表产生的文件%
   Return

Cando_交换文件名:
SwapName(CandySel)
Return

Swapname(Filelist)
{
	StringSplit,File_,Filelist,`n
	SplitPath,File_1,FN1,Dir
	SplitPath,File_2,FN2
	RunWait,%ComSpec% /c ren `"%File_1%`" `"temp`",,Hide
	RunWait,%ComSpec% /c ren `"%File_2%`" `"%FN1%`",,Hide
	RunWait,%ComSpec% /c ren `"%Dir%\temp`" `"%FN2%`",,Hide
	return,0
	}

cando_多文件复制文件名:
clip := ""
Loop, Parse, CandySel, `n,`r 
{
SplitPath, A_LoopField,outfilename
clip .= (clip = "" ? "" : "`r`n") outfilename
}
clipboard:=clip
	return

cando_多文件复制路径:
clip := ""
Loop, Parse, CandySel, `n,`r 
{
SplitPath, A_LoopField,outfilename
clip .= (clip = "" ? "" : "`r`n") outfilename
}
clipboard:=clip
	return

Cando_生成快捷方式:
FileCreateShortcut,%CandySel%,%CandySel_ParentPath%\%CandySel_FileNameNoExt%.lnk
    Return

Cando_生成快捷方式到指定目录:
	Gui,66:Destroy
	Gui,66:Default
	Gui,Add,Text,x10 y17, 目标文件(&T)
	Gui,Add,Edit,x110 y15 w300 readonly vSHLTG_Path,% CandySel
	Gui,Add,Text,x10 y48, 快捷方式目录(&P)
	Gui,Add,Edit,x110 y46 w300 vSHL_Path,
	Gui,Add,CheckBox,x20 y70 w50 h30 vSHL_Desktop,桌面
	Gui,Add,CheckBox,x90 y70 w80 h30 vSHL_QL,快速启动栏
	Gui,Add,CheckBox,x180 y70 w80 h30 vSHL_Fav,脚本收藏夹
	Gui,Add,Text,x10 y110, 快捷方式名称(&N)
	Gui,Add,Edit,x110 y108 w300 vSHL_Name,%CandySel_FileNameNoExt%
	Gui,Add,Button,x220 y140 w80 h25 Default gSHL_OK, 确定(&S)
	Gui,Add,Button,x320 y140 w80 h25 g66GuiClose, 取消(&X)
	Gui,show,,为文件[%CandySel_FileNameWithExt%]创建快捷方式
Return

SHL_OK:
	Gui,66:Default
	Gui,Submit,NoHide
	SHL_Name:=Trim(SHL_Name),SHL_Path:=Trim(SHL_Path,"\"),errFlag := 0
	If (SHL_Name="")
		errFlag:=1, tempStr:="未设置快捷方式名称"
	If (errFlag=0) And (RegexMatch(SHL_Name, "[\\/:\*\?""<>\|]")>0)
		errFlag:=2, tempStr:="快捷方式名称不得包含以下任意字符：\ / : * \ ? "" < > |"
	If (errFlag=0) And (SHL_Path !="") And !InStr(FileExist(SHL_Path), "D")
		errFlag:=3, tempStr:= "快捷方式目录不存在"
	If (errFlag=0) And (FileExist(SHLTG_Path)="")
		errFlag:=4, tempStr:= "目标文件不存在"
	If (errFlag=0) 
	{
		Gui, Destroy
		if (SHL_Path !="")
			FileCreateShortcut, % SHLTG_Path,%SHL_Path%\%SHL_Name%.lnk
		if SHL_Desktop
			FileCreateShortcut, % SHLTG_Path,%A_desktop%\%SHL_Name%.lnk
		if SHL_QL
			FileCreateShortcut, % SHLTG_Path,%A_AppData%\Microsoft\Internet Explorer\Quick Launch\%SHL_Name%.lnk
		if SHL_Fav
			FileCreateShortcut, % SHLTG_Path,%A_ScriptDir%\favorites\%SHL_Name%.lnk
	}
	Else 
	{
		Gui, +OwnDialogs
		MsgBox, 262192, 创建快捷方式错误, %tempStr%！
		If errFlag In 1,2
			GuiControl, Focus, SHL_Name
		If errFlag In 3
			GuiControl, Focus, SHL_Path
		If errFlag In 4
			GuiControl, Focus, SHLTG_Path
}
	errFlag:=tempStr:=SHLTG_Path:=SHL_Name:=SHL_Path:=""
return