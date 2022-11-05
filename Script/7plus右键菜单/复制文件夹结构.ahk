1005:
	SetTimer, copyfolderStructure, -150
Return

;复制文件夹结构而不复制文件夹中的文件
copyfolderStructure:
FileReadLine, Files, %A_Temp%\7plus\files.txt, 1
sleep, 50
Critical,On
if !Files
	Files := GetSelectedFiles()
Critical,Off
If !Files
{
	CF_ToolTip("获取文件路径失败。", 3000)
Return
}

Files:=Files . "\"
CopyDirStructure(Files, A_Desktop, 1)
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


CopyDirStructure(_inpath,_outpath,_i=true)
{
	If (_i)
	{
		SplitPath, _inpath,, _indir
		_indir := SubStr(_indir, Instr(_indir,"\", false, 0)+1, (StrLen(_indir)-Instr(_indir, "\", false, 0)))
		_outpath := _outpath (SubStr(_outpath, 0, 1) = "\" ? "" : "\") . _indir
		FileCreateDir, %_outpath%
		If errorlevel
		Return errorlevel
	}
	Loop, %_inpath%\*.*, 2, 1
	{
		StringReplace, _temp, A_LoopFileLongPath, %_inpath%,, All
		FileCreateDir, %_outpath%\%_temp%
		If errorlevel
			_problem = 1
	}
Return _problem
}

7PlusMenu_复制文件夹结构()
{
	section = 复制文件夹结构
	defaultSet=
	( LTrim
		ID = 1005
		Name = 复制文件夹结构到桌面
		Description = 复制文件夹结构到桌面
		SubMenu = 7plus
		FileTypes =
		SingleFileOnly = 1
		Directory = 1
		DirectoryBackground = 0
		Desktop = 0
		showmenu = 1
	)
	IniWrite, % defaultSet, % 7PlusMenu_ProFile_Ini, % section
return
}