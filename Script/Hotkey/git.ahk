; github 上帮助文件更新时复制路径后，自动打开本地文件
git:
SelectedPath := Clipboard
if !SelectedPath
SelectedPath := GetSelText()
SelectedPath := StrReplace(SelectedPath, "/", "\")
SetTitleMatchMode, 2
;tooltip % SelectedPath
if WinExist("N:\资料\autohotkey 帮助\v2\docs")
{
	if WinExist("ahk_class Notepad2U")
	DropFiles("N:\资料\autohotkey 帮助\v2\" SelectedPath, "ahk_class Notepad2U")
	else
	{
		run "%notepad2%" "N:\资料\autohotkey 帮助\v2\%SelectedPath%"
		sleep,200
		WinSet,AlwaysOnTop,,ahk_class Notepad2U
	}
}
else if WinExist("N:\资料\autohotkey 帮助\v1\docs")
{
	if WinExist("ahk_class Notepad2U")
	DropFiles("N:\资料\autohotkey 帮助\v1\" SelectedPath, "ahk_class Notepad2U")
	else
	{
		run "%notepad2%" "N:\资料\autohotkey 帮助\v1\%SelectedPath%"
		sleep,200
		WinSet,AlwaysOnTop,,ahk_class Notepad2U
	}
}
return