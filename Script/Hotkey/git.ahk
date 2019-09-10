; 复制路径后，自动打开本地文件(用于github 上帮助文件更新时自动打开本地文件同步更新)
git:
if !SelectedPath
	SelectedPath := GetSelText()
SelectedPath := StrReplace(SelectedPath, "/", "\")
SetTitleMatchMode, 2
if WinExist("N:\资料\autohotkey 帮助\v1\docs ahk_class CabinetWClass") && FileExist("N:\资料\autohotkey 帮助\v1\" SelectedPath)
{
	if WinExist("ahk_class Notepad3U")
	{
		if !WinActive("ahk_class Notepad3U")
			WinActivate, ahk_class Notepad3U
		DropFiles("N:\资料\autohotkey 帮助\v1\" SelectedPath, "ahk_class Notepad3U")
	}
	else
	{
		run "%notepad3%" "N:\资料\autohotkey 帮助\v1\%SelectedPath%"
		sleep, 200
		WinSet, AlwaysOnTop,, ahk_class Notepad3U
	}
	;return
}
sleep 1000
if WinExist("N:\资料\autohotkey 帮助\v2\docs ahk_class CabinetWClass") && FileExist("N:\资料\autohotkey 帮助\v2\" SelectedPath)
{
	if WinExist("ahk_class Notepad2U")
	{
		if !WinActive("ahk_class Notepad2U")
			WinActivate, ahk_class Notepad2U
		DropFiles("N:\资料\autohotkey 帮助\v2\" SelectedPath, "ahk_class Notepad2U")
	}
	else
	{
		run "%notepad2%" "N:\资料\autohotkey 帮助\v2\%SelectedPath%"
		sleep, 200
		WinSet, AlwaysOnTop,, ahk_class Notepad2U
	}
}
return