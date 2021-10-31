1016:
SetTimer, 文件MD5, -150
Return

7PlusMenu_MD5()
{
	section = MD5
	defaultSet=
	( LTrim
		ID = 1016
		Name = 文件MD5
		Description = 计算选中文件的MD5
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