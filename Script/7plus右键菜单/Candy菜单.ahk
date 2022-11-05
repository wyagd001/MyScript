1017:
SetTimer, Candy, -150
Return

7PlusMenu_Candy菜单()
{
	section = Candy菜单
	defaultSet=
	( LTrim
		ID = 1017
		Name = Candy
		Description = Candy菜单
		SubMenu = 7plus
		FileTypes = *
		SingleFileOnly = 0
		Directory = 1
		DirectoryBackground = 0
		Desktop = 0
		showmenu = 0
	)
	IniWrite, % defaultSet, % 7PlusMenu_ProFile_Ini, % section
return
}