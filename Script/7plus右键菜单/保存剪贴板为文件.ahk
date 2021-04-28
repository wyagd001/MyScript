1014:
SetTimer, 保存剪贴板为文件, -150
return

保存剪贴板为文件:
sleep, 50
Critical, On
CurrentFolder := GetCurrentFolder()
if CurrentFolder
	PasteToPath(CurrentFolder)
return

7PlusMenu_保存剪贴板为文件()
{
	section = 保存剪贴板为文件
	defaultSet=
	( LTrim
		ID = 1014
		Name = 保存剪贴板为文件
		Description = 保存剪贴板为文件
		SubMenu =
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