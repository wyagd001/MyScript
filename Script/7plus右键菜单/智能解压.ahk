1006:
	SetTimer,smartunrar,-150
Return

;智能解压
;1).压缩包内有多个文件（或文件夹）时“解压”文件到压缩包所在目录的“与压缩包同名的文件夹”内
;A.rar--------Folds/Files/Folds+Files/Fold+Files/File+Folds→Fold(name:A)
;2).压缩包内有只有1个文件（夹）时“解压”文件到压缩包所在目录的“与压缩包内的文件（夹）同名的文件（夹内）”
;A.rar--------File→File/Fold→Fold
smartunrar:
SetTimer, hovering, off
hovering_off:=1
sleep, 50
Critical,On
Files := GetSelectedFiles()
If !Files or (Files="ERROR")
{
	hovering_off:=0
	CF_ToolTip("获取文件路径失败。", 3000)
Return
}
Critical,Off
Loop Parse, Files, `n, `r ;从 Files 中逐个获取压缩包路径。换行作分隔符，忽略头尾回车。
	7z_smart_Unarchiver(A_LoopField)
hovering_off:=0
Return

7PlusMenu_智能解压()
{
	section = 智能解压
	defaultSet=
	( LTrim
ID = 1006
Name = 智能解压到当前文件夹
Description = 智能解压到当前文件夹(支持多文件)
SubMenu = 7plus
FileTypes = rar,zip,7z
SingleFileOnly = 0
Directory = 0
DirectoryBackground = 0
Desktop = 0
showmenu = 1
	)
IniWrite, % defaultSet, % 7PlusMenu_ProFile_Ini, % section
return
}