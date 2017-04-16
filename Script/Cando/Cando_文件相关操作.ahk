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
FileCreateShortcut,%CandySel%,%CandySel_ParentPath%\%CandySel_FileNameNoExt% .lnk
    Return