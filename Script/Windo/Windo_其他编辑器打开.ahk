Windo_其他编辑器打开:
sTextDocumentPath := GetTextDocumentPath(Windy_CurWin_Pid,Windy_CurWin_id,Windy_CurWin_Title)
run,%Splitted_Windy_Cmd3% "%sTextDocumentPath%" 
return

GetTextDocumentPath(_pid,_id,_Title)
{
;窗口标题有路径的窗口直接获取窗口标题文字
IfInString,_Title,:\ 
{  
;匹配目录不能匹配文件
;FullNamell:=RegExReplace(_Title,"^.*(.:(\\)?.*)\\.*$","$1")
;编辑器文件修改后标题开头带“*”
RegExMatch(_Title, "i)^\*?\K.*\..*(?= [-*] )", FileFullPath)
If FileFullPath
  return FileFullPath
}

IfInString,_Title,记事本
{
If(_Title="无标题 - 记事本")
{
Return
}
FileFullPath := JEE_NotepadGetPath(_id)
if FileFullPath<>
 return FileFullPath
}

;;;;;;;;;;;;;;提取命令行;;;;;;;;;
;WMI_Query("\\.\root\cimv2", "Win32_Process")
CMDLine:= WMI_Query(_pid)

RegExMatch(CMDLine, "i).*exe.*?\s+(.*)", ff_)   ; 正则匹配命令行参数
;带参数的命令行不能得到路径  例如 a.exe /resart "D:\123.txt"
;命令行参数中打开的文件有些程序带  “"”，（"打开文件路径"） 有些程序不带 “"”（打开文件路径）
StringReplace,FileFullPath,ff_1,`",,All
startzimu:=RegExMatch(FileFullPath, "i)^[a-z]")

 if !startzimu
{
RegExMatch(FileFullPath, "i).*?\s+(.*)", fff_)
FileFullPath:=fff_1
}
startzimu:=ff_:=ff_1:=fff_:=fff_1:=""
if FileFullPath<>
  return FileFullPath
}
