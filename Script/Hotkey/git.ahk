; 复制路径后，自动打开本地文件(用于github 上帮助文件更新时自动打开本地文件同步更新)
git:
	if !SelectedPath
		SelectedPath := GetSelText()
	SelectedPath := StrReplace(SelectedPath, "/", "\")

	Switch  ; 需要主程序版本 1.1.31.00
	{
		case InStr(SelectedPath,"zh-cn"), InStr(SelectedPath,"v1"):
		{
			SelectedPath:=SubStr(SelectedPath, InStr(SelectedPath,"docs")+5)
			if FileExist("N:\资料\autohotkey 帮助\v1\docs\" SelectedPath)
			{
				if WinExist("ahk_class Notepad3U")
				{
					WinActivate, ahk_class Notepad3U
					DropFiles("N:\资料\autohotkey 帮助\v1\docs\" SelectedPath, "ahk_class Notepad3U")
				return
				}
				else
					run "%notepad3%" "N:\资料\autohotkey 帮助\v1\docs\%SelectedPath%"
				return
			}
		}

		case InStr(SelectedPath,"v2"):
		{
			SelectedPath:=SubStr(SelectedPath, InStr(SelectedPath,"docs")+5)
			if FileExist("N:\资料\autohotkey 帮助\v2\docs\" SelectedPath)
			{
				if WinExist("ahk_class Notepad2U")
				{
					WinActivate, ahk_class Notepad2U
					DropFiles("N:\资料\autohotkey 帮助\v2\docs\" SelectedPath, "ahk_class Notepad2U")
				return
				}
			else
				run "%notepad2%" "N:\资料\autohotkey 帮助\v2\docs\%SelectedPath%"
			return
			}
		}

		Default:
		{
			SelectedPath := LTrim(SelectedPath,"\")
			if FileExist("N:\资料\autohotkey 帮助\v2\" SelectedPath)
			{
				if WinExist("ahk_class Notepad2U")
				{
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
			sleep 1000
			if FileExist("N:\资料\autohotkey 帮助\v1\" SelectedPath) && GetKeyState("Capslock" , "T")
			{
				if WinExist("ahk_class Notepad3U")
				{
					WinActivate, ahk_class Notepad3U
					DropFiles("N:\资料\autohotkey 帮助\v1\" SelectedPath, "ahk_class Notepad3U")
				}
				else
				{
					run "%notepad3%" "N:\资料\autohotkey 帮助\v1\%SelectedPath%"
					sleep, 200
					WinSet, AlwaysOnTop,, ahk_class Notepad3U
				}
			}
		return
		}
	}
return