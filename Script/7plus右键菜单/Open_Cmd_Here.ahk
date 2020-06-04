1010:
	SetTimer,命令提示符,-200
Return

7PlusMenu_Open_Cmd_Here()
{
	section = Open_Cmd_Here
	defaultSet=
	( LTrim
ID = 1010
Name = Open CMD Here
Description = CMD打开定位到该文件夹
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