1011:
	SetTimer,notepadopen,-200
Return

notepadopen:
sleep,200
Critical,On
Files := GetSelectedFiles()
If !Files
{
	MsgBox,,,获取文件路径失败4。,3
Return
}
run "%TextEditor%" "%files%"
Return