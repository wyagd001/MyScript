1015:
SetTimer, CopyPathToClip, -150
Return

CopyPathToClip:
Critical, On
Files := GetSelectedFiles()
msgbox % Files
if !Files
	FileRead, Files, %A_Temp%\7plus\files.txt
If !Files
{
	CF_ToolTip("获取文件路径失败。", 3000)
return
}
Clipboard := Trim(Files)
if !Auto_Clip
	CF_ToolTip("已复制文件路径到截剪贴板。", 3000)
Return

7PlusMenu_复制文件路径()
{
	section = 复制文件路径
	defaultSet=
	( LTrim
		ID = 1015
		Name = 复制文件路径
		Description = 复制文件路径命令(支持多文件)
		SubMenu =
		FileTypes = *
		SingleFileOnly = 0
		Directory = 1
		DirectoryBackground = 0
		Desktop = 0
		showmenu = 1
	)
	IniWrite, % defaultSet, % 7PlusMenu_ProFile_Ini, % section
return
}