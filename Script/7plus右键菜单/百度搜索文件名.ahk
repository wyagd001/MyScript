;桌面lnk文件无效(所有lnk文件都无效)
1004:
	SetTimer,searchthefile,-200
Return

; 桌面lnk文件无效  Why
; 百度搜索文件名
searchthefile:
	sleep, 200
	Critical, On
	Files := GetSelectedFiles(0)
	If !Files
	{
		MsgBox,,,获取文件路径失败1。,3
	Return
	}
	Critical, Off

	StrReplace(files, "`n", "`n", tmp_v)
	if tmp_v > 5
	{
		msgbox, 4, 搜索文件名, 将搜索5个以上的文件名，是否继续？
		IfMsgBox Yes
		{
			Loop, Parse, files, `n, `r
				run, http://www.baidu.com/s?wd=%A_LoopField%
		return
		}
		else
		return
	}
	Loop, Parse, files, `n, `r
		run, http://www.baidu.com/s?wd=%A_LoopField%
Return