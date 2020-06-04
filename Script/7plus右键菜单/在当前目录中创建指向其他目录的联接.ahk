1009:
	sPara=/DES
	SetTimer,创建目录联接,-200
Return

7PlusMenu_在当前目录中创建指向其他目录的联接()
{
	section = 在当前目录中创建指向其他目录的联接
	defaultSet=
	( LTrim
ID = 1009
Description = 在该文件夹中创建其他文件夹的目录联接(镜像)
Name = 在此文件夹中创建目录联接(镜像)
SubMenu = 7plus
FileTypes =
SingleFileOnly = 0
Directory = 0
DirectoryBackground = 1
Desktop = 0
showmenu = 1
	)
IniWrite, % defaultSet, % 7PlusMenu_ProFile_Ini, % section
return
}