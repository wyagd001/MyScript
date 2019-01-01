;LAlt & MButton::  ; 一键打开当前激活窗口的所在目录
窗口程序所在目录:
Sleep,100
WinGet,ProcessPath,ProcessPath,A
Run,% "explorer.exe /select," ProcessPath 
sleep,500
Send,{Alt Down}
sleep,500
Send,{Alt Up}
Return

;RAlt & MButton::
打开文档所在目录:
WinGet pid, PID, A 
WinGetActiveTitle _Title
WinGet,ProcessPath,ProcessPath,A 

;窗口标题有路径的窗口直接获取窗口标题文字
IfInString,_Title,:\ 
{  
; 匹配目录不能匹配文件
;FullNamell:=RegExReplace(_Title,"^.*(.:(\\)?.*)\\.*$","$1")
; 编辑器文件修改后标题开头带“*”
RegExMatch(_Title, "i)^\*?\K.*\..*(?= [-*] )", FileFullPath)
If FileFullPath
  goto OpenFileFullPath
}

/*
; 方式一
; 路径带引号可识别  不带引号不行
RegExMatch(CMDLine, "Ui) ""([^""]+)""", ff_)
*/

/*
; 方式二
RegExMatch(CMDLine, "i).*exe.*?\s+(.*)", ff_)   ; 正则匹配命令行参数
; 带参数的命令行不能得到路径  例如 a.exe /resart "D:\123.txt"
startzimu:=RegExMatch(ff_1, "i)^[a-z]")

 if !startzimu
{
RegExMatch(ff_1, "i).*?\s+(.*)", fff_)
StringReplace,FullName,fff_1,`",,All
}
else
StringReplace,FullName,ff_1,`",,All

if FullName<>
run % "explorer.exe /select,"  FullName 
*/

/*
;方式三
;FullName:=RegExReplace(CMDLine,"^.*(.:(\\)?.*)\\.*$","$1",6)      ;直接得到不包含文件名的路径
;Run,%FullName%
*/

;tooltip % FullName

;tooltip % Ff_1 "-" CMDLine
;if ff_1<>
;Run, % "explorer.exe /select,"  ff_1

;;;;;;;;;;;;;;提取命令行;;;;;;;;;
;WMI_Query("\\.\root\cimv2", "Win32_Process")
CMDLine:= WMI_Query(pid)

RegExMatch(CMDLine, "i).*exe.*?\s+(.*)", ff_)   ; 正则匹配命令行参数
; 带参数的命令行不能得到路径  例如 a.exe /resart "D:\123.txt"
; 命令行参数中打开的文件有些程序带  “"”，（"打开文件路径"） 有些程序不带 “"”（打开文件路径）
StringReplace,FileFullPath,ff_1,`",,All
startzimu:=RegExMatch(FileFullPath, "i)^[a-z]")

 if !startzimu
{
RegExMatch(FileFullPath, "i)([a-z]:\\.*\.\S*)", fff_)
FileFullPath:=fff_1
}

if FileFullPath<>
 goto OpenFileFullPath

; RealPlayer
IfInString,_Title,RealPlayer
{
DetectHiddenText, On
SetTitleMatchMode, Slow
WinGetText, _Title, %_Title%
IfInString,_Title,:/
{
;RealPlayer式例：file://N:/电影/小视频/【藤缠楼】必看！正确的电线绕圈收集方法 标清.flv
StringReplace,_Title,_Title,/,\,1
Loop, parse, _Title, `n, `r
 {
	StringTrimLeft,FileFullPath,A_LoopField,7
  If FileFullPath
  gosub OpenFileFullPath
 }
}
DetectHiddenText,Off
SetTitleMatchMode,fast
Return
}

; Word、WPS、Excel、et程序
FileFullPath:=getDocumentPath(ProcessPath)  
if FileFullPath<>
  goto OpenFileFullPath

; 直接打开记事本程序，然后打开文本文件，命令行没有文件路径，使用读取内存的方法得到路径
IfInString,_Title,记事本
{
If(_Title="无标题 - 记事本")
{
FileFullPath:=_Title:=pid:=ProcessPath:=startzimu:=ff_:=ff_1:=fff_:=fff_1=""
Return
}
WinGet, hWnd, ID, A
FileFullPath := JEE_NotepadGetPath(hWnd)
if FileFullPath<>
 gosub OpenFileFullPath
}

; 结束清理
FileFullPath:=_Title:=pid:=ProcessPath:=startzimu:=ff_:=ff_1:=fff_:=fff_1=""
Return

OpenFileFullPath:
	;QQ 影音  文件路径末尾带“*”号
	FileFullPath:=Trim(FileFullPath,"`*")
	If Fileexist(FileFullPath)
	{
		Run,% "explorer.exe /select," FileFullPath
		FileFullPath:=_Title:=pid:=ProcessPath:=""
		Return
	}
	else
	{
		RegExMatch(FileFullPath, "i)^\*?\K.*\..*(?= [-*] )", FileFullPath)
		If Fileexist(FileFullPath)
		{
			Run,% "explorer.exe /select," FileFullPath
			FileFullPath:=_Title:=pid:=ProcessPath:=""
			Return
		}
		Splitpath,FileFullPath,,Filepath
		If Fileexist(Filepath)
		{
			Msgbox,% "目标文件不存在 " FileFullPath "，`r`n" "打开文件所在目录 " Filepath "。"
			Run,% Filepath
			FileFullPath:=_Title:=pid:=ProcessPath:=""
			Return
		}
	}
Return

getDocumentPath(_ProcessPath)  
  {  
SplitPath,_ProcessPath,,,,Process_NameNoExt  
    value:=Process_NameNoExt  
      
    If IsLabel( "Case_" . value)  
        Goto Case_%value%  

Case_WINWORD:  ;Word OpusApp
  Application:= ComObjActive("Word.Application") ;word
  ActiveDocument:= Application.ActiveDocument ;ActiveDocument
Return  % ActiveDocument.FullName
Case_EXCEL:  ;Excel XLMAIN
  Application := ComObjActive("Excel.Application") ;excel
  ActiveWorkbook := Application.ActiveWorkbook ;ActiveWorkbook
Return % ActiveWorkbook.FullName
Case_POWERPNT:  ;Powerpoint PPTFrameClass
  Application:= ComObjActive("PowerPoint.Application") ;Powerpoint
  ActivePresentation := Application.ActivePresentation ;ActivePresentation
Return % ActivePresentation.FullName
Case_WPS:
Application := ComObjActive("kWPS.Application")
if !Application
Application := ComObjActive("WPS.Application")
ActiveDocument:= Application.ActiveDocument
Return  % ActiveDocument.FullName
Case_ET:
Application := ComObjActive("ket.Application")
if !Application
Application := ComObjActive("et.Application")
  ActiveWorkbook := Application.ActiveWorkbook ;ActiveWorkbook
Return % ActiveWorkbook.FullName
Case_WPP:
Application := ComObjActive("kWPP.Application")
if !Application
Application := ComObjActive("wpp.Application")
  ActivePresentation := Application.ActivePresentation ;ActivePresentation
Return % ActivePresentation.FullName
}