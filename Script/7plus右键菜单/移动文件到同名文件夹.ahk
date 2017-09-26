;桌面lnk文件无效(所有lnk文件都无效)
1003:
	;MsgBox
	SetTimer,移动文件到同名文件夹,-200
Return

;文件移动到同名文件夹内
;桌面lnk文件无效  无法获得lnk 后缀
;按快捷键为结果为 G:\Users\lyh\Desktop\QQ  实际为QQ.lnk
;#G::
移动文件到同名文件夹:
sleep,2000
Critical,On
Files := GetSelectedFiles()
If !Files
{
	MsgBox,,,获取文件路径失败4。,3
	Return
}
Critical,Off

Loop, Parse, files, `n,`r
{
	FileFullPath := A_LoopField
	SplitPath,FileFullPath,FileName,FilePath,FileExtension,FileNameNoExt
	creatfolder = %FilePath%\%FileNameNoExt%
	IfNotExist %creatfolder%
	{
		FileCreateDir,%creatfolder%
		FileMove,%FileFullPath%,%creatfolder%
	}
	else
	{
		TargetFile = %creatfolder%\%FileName%
		ifExist, %TargetFile%
		{
			ind = 1
			Loop, 100
			{
				TargetFile = %creatfolder%\%FileNameNoExt%_(%ind%).%FileExtension%
				ifExist, %TargetFile%
				{
					ind += 1
					continue
				}
				else
				{
					Run, %comspec% /c move "%FileFullPath%" "%TargetFile%"
					break
				}
			}
		}
		; 无同名文件时，复制文件
		else
		{
			Run, %comspec% /c move "%FileFullPath%" "%TargetFile%"
		}
	}
}
Return