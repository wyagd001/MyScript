1001:
	f_ToggleHidden(1)
Return

7PlusMenu_显示隐藏文件()
{
	section = 显示隐藏文件
	defaultSet=
	( LTrim
ID = 1001
Name = 切换"显示/隐藏"隐藏文件
Description = 切换显示隐藏文件
SubMenu = 7plus
FileTypes =
SingleFileOnly = 0
Directory = 0
DirectoryBackground = 1
Desktop = 1
showmenu = 1
	)
IniWrite, % defaultSet, % 7PlusMenu_ProFile_Ini, % section
return
}