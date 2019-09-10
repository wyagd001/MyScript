1005:
	SetTimer,copyfolderStructure,-200
Return

;复制文件夹结构而不复制文件夹中的文件
copyfolderStructure:
sleep,2000
Critical,On
Files := GetSelectedFiles()
If !Files
{
	MsgBox,,,获取文件路径失败3。,3
Return
}
Critical,Off

Files:=Files . "\"
CopyDirStructure(Files,A_Desktop,1)
Return

; https://autohotkey.com/board/topic/63944-function-copydirstructure/
/*
CopyDirStructure()

复制目录结构
(复制一个文件夹及其所有子文件夹——但不复制文件)

参数:
	_inpath - 要复制的文件夹的绝对路径
	_outpath - 目标文件夹的绝对路径
	_i - 是否包括顶层文件夹(true/false)

返回值: 
	如果有问题返回 1，否则为空

gahks - 2011 - GNU GPL v3
*/


CopyDirStructure(_inpath,_outpath,_i=true) {
   If (_i) {
      SplitPath, _inpath,,_indir
      _indir := SubStr(_indir, Instr(_indir,"\",false,0)+1,(StrLen(_indir)-Instr(_indir,"\",false,0)))
      _outpath := _outpath (SubStr(_outpath,0,1)="\" ? "" : "\") . _indir
      FileCreateDir, %_outpath%
      If errorlevel
         Return errorlevel
   }
   Loop, %_inpath%\*.*, 2, 1
   {
      StringReplace, _temp, A_LoopFileLongPath, %_inpath%,,All
      FileCreateDir, %_outpath%\%_temp%
      If errorlevel
         _problem = 1
   }
   Return _problem
}