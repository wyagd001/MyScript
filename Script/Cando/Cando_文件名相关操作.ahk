Cando_A-B交换:  ;   AA - BB.xxx  改名为  BB - AA.xxx
Tmp_Arr := StrSplit(CandySel_FileNameNoExt, "-")
if Tmp_Arr[2]
	FileMove, %CandySel%, % CandySel_ParentPath "\" Trim(Tmp_Arr[2]) " - " Trim(Tmp_Arr[1]) "." CandySel_Ext
Tmp_Arr := ""
return

Cando_多文件A-B交换:
Loop Parse, CandySel, `n, `r
	File_SwapAB(A_LoopField)
return

File_SwapAB(filename)
{
	SplitPath, filename, , CandySel_ParentPath, CandySel_Ext, CandySel_FileNameNoExt
	Tmp_Arr := StrSplit(CandySel_FileNameNoExt, "-")
	if Tmp_Arr[2]
	FileMove, %filename%, % CandySel_ParentPath "\" Trim(Tmp_Arr[2]) " - " Trim(Tmp_Arr[1]) "." CandySel_Ext
	Tmp_Arr := ""
}

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
	CandySel_FileNameNoExt := SafeFileName(CandySel_FileNameNoExt)
	FileMove, %CandySel%, %CandySel_ParentPath%\%CandySel_FileNameNoExt%.%CandySel_Ext%
	;msgbox % A_LastError
return

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
	Files_TwoFilesSwapName(CandySel)
Return

Files_TwoFilesSwapName(Filelist)
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
	Tmp_Val := ""
	Loop, Parse, CandySel, `n,`r 
	{
		SplitPath, A_LoopField, outfilename
		Tmp_Val .= (Tmp_Val = "" ? "" : "`r`n") outfilename
	}
	clipboard := Tmp_Val
	Tmp_Val := ""
return