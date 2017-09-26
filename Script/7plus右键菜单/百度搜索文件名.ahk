;桌面lnk文件无效(所有lnk文件都无效)
1004:
	SetTimer,searchthefile,-200
Return

;桌面lnk文件无效  Why
;百度搜索文件名
searchthefile:
sleep,2000
Critical,On
Files := GetSelectedFiles()
If !Files
{
	MsgBox,,,获取文件路径失败1。,3
Return
}
Critical,Off

Loop, Parse, files, `n,`r
fullpath := A_LoopField

splitpath,fullpath,filename,dir,,filenameNoExt
run,http://www.baidu.com/s?wd=%filenameNoExt%
Return