; 程序使用方法, 没有选项时默认记事本打开
; "Any2ahk.exe" *选项 "文件路径"
; "Any2ahk.exe" *选项 "文件路径1" "文件路径2"
; "Any2ahk.exe" "文件路径"       
; "Any2ahk.exe" "文件路径1" "文件路径2"

ATA_params := A_Args.Length()

if ATA_params = 0
{
	MsgBox % "脚本需要至少 1 个参数, 但实际没有接收到参数, 程序退出."
	ExitApp
}

SplitPath, A_ScriptFullPath, , , , NameNoExt
7plusfolder := SubStr(A_Desktop , 1, InStr(SubStr(A_Desktop,1,-1), "\", 0, 0)-1) "\AppData\Local\Temp\7plus"
ATA_settingFile := A_ScriptDir "\" NameNoExt ".ini"
FileRead, RunAhk, %7plusfolder%\hwnd.txt
RunAhk := trim(RunAhk, "`n`r `t")
global ATA_filepath
autoexit := 1

if (ATA_params = 1)
	ATA_filepath := A_Args[1]
else
{
	if 1 is integer ;  传入参数1 为数字
	{
		;msgbox % A_Args[1]
		ATA_parameter := A_Args[1]
	}
	else if Instr(A_Args[1], "*") ; 传入参数1 带有字符 "*"
	{
		ATA_parameter := StrReplace(A_Args[1], "*")
	}
	else
	{
		MsgBox % "脚本接收到 " ATA_params " 个参数, 但第 1 个参数不是数字或没有 “*” 符号, 程序退出."
		ExitApp
	}
	loop, % ATA_params - 1
	{
		ATA_filepath%A_index% := Trim(A_Args[(A_index + 1)], " `n`t")
	}
	ATA_filepath := ATA_filepath1, ATA_fileNum := ATA_params - 1
	if !ATA_filepath
	{
		MsgBox 脚本无法获得文件路径，请检查传入的参数， 程序退出.
		ExitApp
	}
}
SplitPath, ATA_filepath, ATA_FileNameWithExt, ATA_ParentPath, ATA_Ext, ATA_FileNameNoExt, ATA_Drive

;msgbox % ATA_filepath  " - " A_Args[1] " - " A_Args[2] " - " A_Args[3] " - " A_Args[4] " - " A_Args[5]

; 只有 1 个参数时, 使用浏览器打开
; 选项为"*openurl"时, 使用浏览器打开
; ATA_filepath 含有"/"字符时, 使用浏览器打开
If (ATA_params = 1) or (ATA_parameter = "openurl") or instr(ATA_filepath, "/") or RegExMatch(ATA_filepath, "i)^(https://|http://)?(\w+(-\w+)*\.)+[a-z]{2,}?") or RegExMatch(ATA_filepath, "((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)")
{
	IniRead, Default_Browser, %ATA_settingFile%, Browser, Default_Browser, %A_Space%
	If !Default_Browser
	{
		Default_Browser := "iexplore.exe"
	}

	IniRead, url, %ATA_settingFile%, Browser, Default_Url
	IniRead, InUse_Browser, %ATA_settingFile%, Browser, InUse_Browser

	Loop, parse, url, |
	{
		IfInString, ATA_filepath, %A_LoopField%
		{
			run %Default_Browser% "%ATA_filepath%",, UseErrorLevel
			if (ErrorLevel = "error")
				msgbox A_LastError
		return
		}
	}
	StringSplit, BApp, InUse_Browser, `,
	LoopN := 1
	br := 0
	Loop, %BApp0%
	{
		BCtrApp := BApp%LoopN%
		LoopN++
		Process, Exist, %BCtrApp%
		If (errorlevel<>0)
		{
			NewPID = %ErrorLevel%
			If(BCtrApp = "chrome.exe" or BCtrApp = "firefox.exe")
			{
				pid := GetCommandLine2(NewPID)
				;pid := GetCommandLine(NewPID)
				;FileAppend , %pid%`n, %A_desktop%\123.txt
				run, %pid% "%ATA_filepath%"
				br :=1
				break
			}
			else
			{
				pid := GetModuleFileNameEx(NewPID)
				;FileAppend , %pid%`n, %A_desktop%\123.txt
				run, %pid% "%ATA_filepath%"
				br := 1
				break
			}
		}
	}
	if br = 0
	{
		run %Default_Browser% "%ATA_filepath%",, UseErrorLevel
		if (ErrorLevel = "error")
		{
			if (A_LastError = 2)
				msgbox % "找不到默认的浏览器, 请检查设置文件的 Default_Browser 条目, 指定默认的浏览器位置或名称."
		}
	}
	if autoexit
		exitapp
}

if RunAhk   ; 运行-ahk 打开时, 发送消息给 运行-ahk
{
	;msgbox % ATA_parameter " - " ATA_filepath
	FileDelete, %7plusfolder%\files.txt
	FileAppend, %ATA_filepath%, %7plusfolder%\files.txt, UTF-16
	err := ExecSend("", RunAhk, ATA_parameter)
}
if !RunAhk or !err or (err = "FAIL")   ; 运行-ahk 没有运行时, 脚本自己处理
{
	if ATA_parameter is integer
	{
		IniRead, Candy_Cmd, %ATA_settingFile%, Pro, % ATA_parameter
		If !Candy_Cmd or (Candy_Cmd = "ERROR")
			return
		if !Instr(Candy_Cmd, "|")
			Candy_Cmd := "openwith|" Candy_Cmd
		arrCandy_Cmd_Str := StrSplit(Candy_Cmd, "|", " `t")
		Candy_Cmd_Str1 := arrCandy_Cmd_Str[1]
		Candy_Cmd_Str2 := arrCandy_Cmd_Str[2]
		Candy_Cmd_Str3 := arrCandy_Cmd_Str[3]
		If (Candy_Cmd_Str1 = "openwith")
			run "%Candy_Cmd_Str2%" "%ATA_filepath%"
		Else If (Candy_Cmd_Str1 = "cando")
			gosub % Candy_Cmd_Str2
	}
	else if IsLabel(ATA_parameter)
	{
		gosub % ATA_parameter
	}
}
if autoexit
	exitapp
return

sendtoFile:
if Candy_Cmd_Str3
{
	loop % ATA_fileNum
	{
		SplitPath, ATA_filepath%A_index%, FileName
		TargetFile := PathU(Candy_Cmd_Str3 "\" FileName)
		if GetKeyState("shift")
			FileMove % ATA_filepath%A_index%, %TargetFile%
		else
			FileCopy % ATA_filepath%A_index%, %TargetFile%
	}
}
else
{
	AllOpenFolder := GetAllWindowOpenFolder()
	Menu SendToOpenedFolder, Add, 发送到打开的文件夹, nul
	Menu SendToOpenedFolder, Add
	for k, v in AllOpenFolder
	{
		Menu SendToOpenedFolder, add, %v%, SendToFolder
	}
	Menu SendToOpenedFolder, Show
	Menu SendToOpenedFolder, DeleteAll
}
return

SendToFolder:
loop % ATA_fileNum
{
	SplitPath, ATA_filepath%A_index%, FileName
	TargetFile := PathU(A_ThisMenuItem "\" FileName)
	if GetKeyState("shift")
		FileMove % ATA_filepath%A_index%, %TargetFile%
	else
		FileCopy % ATA_filepath%A_index%, %TargetFile%
}
Return

nul:
return

File2Folder:
File2Folder(ATA_filepath)
return

FileMd5:
msgbox,, % ATA_filepath, % MD5_File(ATA_filepath)
return

FileLnkToDesk:
FileCreateShortcut, % ATA_filepath, %A_desktop%\%ATA_FileNameNoExt%.lnk
return

#include %A_ScriptDir%\预览文件.ahk
#include %A_ScriptDir%\..\lib\File_GetEncoding.ahk
#include %A_ScriptDir%\..\lib\tf.ahk
#include %A_ScriptDir%\lib\QtTabBar.ahk
#include %A_ScriptDir%\lib\Explorer.ahk
#include %A_ScriptDir%\lib\Process.ahk
#include %A_ScriptDir%\lib\File.ahk
#include %A_ScriptDir%\lib\Class_xd2txlib.ahk
#include %A_ScriptDir%\..\lib\gdip.ahk
#include %A_ScriptDir%\..\lib\CF.ahk