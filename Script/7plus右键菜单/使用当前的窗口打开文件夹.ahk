1012:
SetTimer, 八个收藏的文件夹菜单, -200
Return

7PlusMenu_使用当前的窗口打开文件夹()
{
	section = 使用当前的窗口打开文件夹
	defaultSet=
	( LTrim
		ID = 1012
		Name = 收藏夹
		Description = 使用当前的窗口打开收藏的文件夹
		SubMenu =
		FileTypes =
		Directory =
		DirectoryBackground = 1
		Desktop = 1
		SingleFileOnly = 0
	showmenu = 0
	)
	IniWrite, % defaultSet, % 7PlusMenu_ProFile_Ini, % section
return
}