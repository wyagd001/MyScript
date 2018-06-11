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
 
WMI_Query(pid)
{
   wmi :=    ComObjGet("winmgmts:")
    queryEnum := wmi.ExecQuery("" . "Select * from Win32_Process where ProcessId=" . pid)._NewEnum()
    if queryEnum[process]
        sResult.=process.CommandLine
    else
        MsgBox 指定进程没有找到!  
   Return   sResult
}

;;JEE_NotepadGetFilename
JEE_NotepadGetPath(hWnd)
{
	WinGetClass, vWinClass, % "ahk_id " hWnd
	if !(vWinClass = "Notepad")
		return
	WinGet, vPID, PID, % "ahk_id " hWnd
	WinGet, vPPath, ProcessPath, % "ahk_id " hWnd
	FileGetVersion, vPVersion, % vPPath
	StringLeft, vPVersionnum, vPVersion, 2
	vPVersionnum+=0.1
	MAX_PATH := 260
	;PROCESS_QUERY_INFORMATION := 0x400 ;PROCESS_VM_READ := 0x10
	if !hProc := DllCall("kernel32\OpenProcess", UInt,0x410, Int,0, UInt,vPID, Ptr)
		return
	if !vAddress && A_Is64bitOS
	{
		DllCall("kernel32\IsWow64Process", Ptr,hProc, IntP,vIsWow64Process)
		vPIs64 := !vIsWow64Process
	}
	if (vPVersion = "5.1.2600.5512") && !vPIs64 ;Notepad (Windows XP version)
		vAddress := 0x100A900

	if !vAddress
	{
		VarSetCapacity(MEMORY_BASIC_INFORMATION, A_PtrSize=8?48:28, 0)
		vAddress := 0
		Loop
		{
			if !DllCall("kernel32\VirtualQueryEx", Ptr,hProc, Ptr,vAddress, Ptr,&MEMORY_BASIC_INFORMATION, UPtr,A_PtrSize=8?48:28, UPtr)
				break

			vMbiBaseAddress := NumGet(MEMORY_BASIC_INFORMATION, 0, "Ptr")
			vMbiRegionSize := NumGet(MEMORY_BASIC_INFORMATION, A_PtrSize=8?24:12, "UPtr")
			vMbiState := NumGet(MEMORY_BASIC_INFORMATION, A_PtrSize=8?32:16, "UInt")
			vMbiType := NumGet(MEMORY_BASIC_INFORMATION, A_PtrSize=8?40:24, "UInt")

			vName := ""
			if (vMbiState & 0x1000) ;MEM_COMMIT := 0x1000
			&& (vMbiType & 0x1000000) ;MEM_IMAGE := 0x1000000
			{
				vPath := ""
				VarSetCapacity(vPath, MAX_PATH*2)
				DllCall("psapi\GetMappedFileName", Ptr,hProc, Ptr,vMbiBaseAddress, Str,vPath, UInt,MAX_PATH*2, UInt)
				if !(vPath = "")
					SplitPath, vPath, vName
			}
			if InStr(vName, "notepad") && (vPVersionnum > 10)    ; win10
			{
				;get address where path starts
				if vPIs64
					;vAddress := vMbiBaseAddress + 0x25C0
					vAddress := vMbiBaseAddress + 0x245C0
				else
				{
					If (vPVersion = "10.0.15063.0")
						vAddress := vMbiBaseAddress + 0x1F000 ; (0x1CB30 文件菜单打开时有效 拖拽无效  0x1E000 拖拽文件打开和文件菜单打开都有效)
					If (vPVersion = "10.0.14393.0")
						vAddress := vMbiBaseAddress + 0x1E000
				;MsgBox, % Format("0x{:X}", vMbiBaseAddress) "`r`n" Format("0x{:X}", vAddress)
				}
				break
			}
			if InStr(vName, "notepad") && (vPVersionnum < 10) ; Win7
			{
				;MsgBox, % Format("0x{:X}", vMbiBaseAddress)
				;get address where path starts
				if vPIs64
					vAddress := vMbiBaseAddress + 0x10B40
				else
					vAddress := vMbiBaseAddress + 0xCAE0 ;(vMbiBaseAddress + 0xD378 also appears to work)
				break
			}
			vAddress += vMbiRegionSize
			if (vAddress > 2**32-1) ;4 gigabytes
			{
				DllCall("kernel32\CloseHandle", Ptr,hProc)
				return
			}
		}
	}

	VarSetCapacity(MEMORY_BASIC_INFORMATION, A_PtrSize=8?48:28, 0)
	if DllCall("kernel32\VirtualQueryEx", Ptr,hProc, Ptr,vAddress, Ptr,&MEMORY_BASIC_INFORMATION, UPtr,A_PtrSize=8?48:28, UPtr)
	{
		vMbiBaseAddress := NumGet(MEMORY_BASIC_INFORMATION, 0, "Ptr")
		vPath := ""
		VarSetCapacity(vPath, MAX_PATH*2)
		DllCall("psapi\GetMappedFileName", Ptr,hProc, Ptr,vMbiBaseAddress, Str,vPath, UInt,MAX_PATH*2, UInt)
; \Device\HarddiskVolume6\WINDOWS\notepad.exe XP C盘
; \Device\HarddiskVolume10\Windows\notepad.exe  win7 G盘
;msgbox %vPath%
		if InStr(vPath, "notepad")
		{
			VarSetCapacity(vPath, MAX_PATH*2, 0)
			DllCall("kernel32\ReadProcessMemory", Ptr,hProc, Ptr,vAddress, Str,vPath, UPtr,MAX_PATH*2, UPtr,0)
		}
	}

if !A_IsUnicode
{
;转换vPath为ansi版能识别的字符 U版不需要转换
	VarSetCapacity(vfilepath, MAX_PATH, 0) 
DllCall("WideCharToMultiByte", "Uint",0, "Uint",0, "str",vPath, "int",-1, "str",vfilepath, "int",MAX_PATH, "Uint",0, "Uint",0)
	DllCall("kernel32\CloseHandle", Ptr,hProc)
	return vfilepath
}
else
{
	DllCall("kernel32\CloseHandle", Ptr,hProc)
	return vPath
}
}

;==================================================