1011:
SetTimer, notepadopen, -150
Return

notepadopen:
sleep, 50
Critical,On
Files := GetSelectedFiles()
if !Files and lastexplorerhwnd
Files := GetSelectedFiles(,lastexplorerhwnd)
If !Files
{
	CF_ToolTip("获取文件路径失败。", 3000)
Return
}

run, "%TextEditor%" "%files%",,, hpid
WinWait, ahk_pid %hpid%, , 2
WinActivate, ahk_pid %hpid%
IfWinNotActive, ahk_pid %hpid%
	WinActivate, ahk_pid %hpid%
Critical, Off
Return

7PlusMenu_记事本打开()
{
	section = 记事本打开
	defaultSet=
	( LTrim
		ID = 1011
		Name = 用记事本打开
		Description = 使用记事本打开当前选中文件
		SubMenu = 7plus
		FileTypes = *
		SingleFileOnly = 1
		Directory = 0
		DirectoryBackground = 0
		Desktop = 0
		showmenu = 1
	)
	IniWrite, % defaultSet, % 7PlusMenu_ProFile_Ini, % section
return
}