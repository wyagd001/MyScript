1006:
	SetTimer,smartunrar,-200
Return

;智能解压
;1).压缩包内有多个文件（或文件夹）时“解压”文件到压缩包所在目录的“与压缩包同名的文件夹”内
;A.rar--------Folds/Files/Folds+Files/Fold+Files/File+Folds→Fold(name:A)
;2).压缩包内有只有1个文件（夹）时“解压”文件到压缩包所在目录的“与压缩包内的文件（夹）同名的文件（夹内）”
;A.rar--------File→File/Fold→Fold
smartunrar:
sleep,200
Critical,On
Files := GetSelectedFiles()
If !Files
{
	MsgBox,,,获取文件路径失败6。,3
Return
}

Loop Parse, Files, `n, `r ;从 Files 中逐个获取压缩包路径。换行作分隔符，忽略头尾回车。
	7z_smart_Unarchiver(A_LoopField)
Return