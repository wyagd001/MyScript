; Explorer Windows Manipulations - Sean
; http://www.autohotkey.com/forum/topic20701.html
; 7plus - fragman
; http://code.google.com/p/7plus/
; https://github.com/7plus/7plus

新建文件夹:
IfWinActive,ahk_group ccc
{
	If(A_OSVersion="Win_XP" && !IsRenaming())
		CreateNewFolder()
	Else If !IsRenaming()
		Send ^+n
}
Return

新建文本文档:
IfWinActive,ahk_group ccc
{
	if !IsRenaming()
		CreateNewTextFile()
}
return