1011:
	SetTimer,notepadopen,-150
Return

notepadopen:
Critical,On
Files := GetSelectedFiles()
If !Files or (Files="ERROR")
{
	MsgBox,,,获取文件路径失败。,3
Return
}
run "%TextEditor%" "%files%"
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