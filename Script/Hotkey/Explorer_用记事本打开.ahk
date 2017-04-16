用记事本打开:
EditSelectedFiles()
Return

EditSelectedFiles()
{
	global ImageExtensions,TextEditor,ImageEditor
	files:=GetSelectedFiles()
	SplitByExtension(files, splitfiles, ImageExtensions)
	files:=RemoveLineFeedsAndSurroundWithDoubleQuotes(files)
	splitfiles:=RemoveLineFeedsAndSurroundWithDoubleQuotes(splitfiles)
	x:=ExpandEnvVars(TextEditor)
	y:=ExpandEnvVars(ImageEditor)
	if (files && !FileExist(x) && x && splitfiles && !FileExist(y) && y)
    TrayTip,设置错误,编辑器的路径错误！,3
	else if(files && !FileExist(x) && x)
    TrayTip,设置错误,文本编辑器的路径错误！,3
	else if(splitfiles && !FileExist(y) && y)
	 TrayTip,设置错误,图片编辑器的路径错误！,3
	if ((files && FileExist(x))||(splitfiles && FileExist(y)))
	{
		if (files!="")
			run %x% %files%
		if (splitfiles!="")
			run %y% %splitfiles%
	}
	else
		SendInput {F6}
	return
}

SplitByExtension(ByRef files, ByRef SplitFiles,extensions)
{
	;Init string incase it wasn't resetted before or so
	Splitfiles:=""
	Loop, Parse, files, `n,`r  ; Rows are delimited by linefeeds ('r`n).
	{
		SplitPath, A_LoopField , , , OutExtension
	  if (InStr(extensions, OutExtension)&&OutExtension!="")
	  {
	  	Splitfiles .= A_LoopField "`n"
	  }
	  else
	  {
	  	newFiles .= A_LoopField "`n"
	  }
	}
	files:=strTrimRight(newFiles,"`n")
	SplitFiles:=strTrimRight(SplitFiles,"`n")
	return
}

RemoveLineFeedsAndSurroundWithDoubleQuotes(files)
{
	result:=""
	Loop, Parse, files, `n,`r  ; Rows are delimited by linefeeds ('r`n).
   {
      if !InStr(FileExist(A_LoopField), "D")
   			result=%result% "%A_LoopField%"
   }
   return result
}