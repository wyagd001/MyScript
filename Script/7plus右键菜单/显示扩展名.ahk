1002:
f_ToggleFileExt(1)
Return

7PlusMenu_显示扩展名()
{
	section = 显示扩展名
	defaultSet=
	( LTrim
		ID = 1002
		Name = 切换"显示/隐藏"文件扩展名
		Description = 显示(隐藏)文件扩展名
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