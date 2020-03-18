1015:
	SetTimer,CopyPathToClip,-200
Return

CopyPathToClip:
	sleep, 200
	Critical, On
	Files := GetSelectedFiles()
	If !Files
	{
		CF_ToolTip("无法获取到文件路径。", 3000)
	return
	}
	Clipboard := Files
	if !Auto_Clip
	CF_ToolTip("已复制文件路径到截剪贴板。", 3000)
Return