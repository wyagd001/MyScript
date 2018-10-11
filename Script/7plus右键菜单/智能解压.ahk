1006:
	SetTimer,smartunrar,-200
Return

;智能解压
;1).压缩包内有多个文件（或文件夹）时“解压”文件到压缩包所在目录的“与压缩包同名的文件夹”内
;A.rar--------Folds/Files/Folds+Files/Fold+Files/File+Folds→Fold(name:A)
;2).压缩包内有只有1个文件（夹）时“解压”文件到压缩包所在目录的“与压缩包内的文件（夹）同名的文件（夹内）”
;A.rar--------File→File/Fold→Fold
smartunrar:
sleep,2000
Critical,On
Files := GetSelectedFiles()
If !Files
{
	MsgBox,,,获取文件路径失败5。,3
Return
}

Loop Parse, Files, `n, `r ;从 Files 中逐个获取压缩包路径。换行作分隔符，忽略头尾回车。
{
SplitPath A_LoopField, , 包目录, , 包名 ;将压缩包路径分割为它的所在目录和不含扩展名的文件名
解压目录 = %包目录%\%包名%
IfExist %解压目录%
	{
	Msgbox 解压时，发现已存在文件夹“%包名%”。`n`n压缩包不会解压到文件夹“%包名%”，解压跳过。
	Continue ;继续解压下一个压缩包
	}
RunWait D:\Program Files\Directory Opus\VFSPlugins\7zG.exe x "%A_LoopField%" -o"%解压目录%" ;调用 7-Zip 的GUI 模块的命令行语法来解压！

;在解压目录中只寻文件
Loop %解压目录%\* ;如果没找到文件，循环会被跳过！
	{
	文件数 = %A_Index%
	If 文件数 = 1 ;有一个文件，保存它的名称，以便移动时所需。然后继续。
		{
		文件名 = %A_LoopFileName%
		Continue
		}
	Else Goto 结束 ;有两个文件。
	}
;在解压目录中只寻文件夹
Loop %解压目录%\*, 2 ;如果没找到文件夹，循环会被跳过！
	{
	文件夹数 = %A_Index%
	If 文件夹数 = 1 ;有一个文件夹，保存它的名称，以便移动时所需。然后继续。
		{
		文件夹名 = %A_LoopFileName%
		Continue
		}
	Else Goto 结束 ;有两个文件夹。
	}

;完成只寻文件和只寻文件夹这两个循环。下面开始判断解压目录内的 4 种情况！
If 文件夹数 = 1
	{
	If 文件数 = 1
		Goto 结束 ;有一个文件夹和一个文件。
	Else ;只有一个文件夹，下面移出。
		{
		If 文件夹名 = %包名%
			FileMoveDir %解压目录%\%包名%, %解压目录%, 2 ;特殊情况：如果源目录中存在同名空文件夹，将被删除。
		Else
			{
			IfExist %包目录%\%文件夹名% ;如果外面存在同名文件夹，移出时重命名。
				{
				Msgbox 移出单个文件夹时，发现已存在同名文件夹！`n`n故追加“重命名”字样后，再移出。
				FileMoveDir %解压目录%\%文件夹名%, %包目录%\%文件夹名%（重命名）, R ;重命名模式
				}
			Else FileMoveDir %解压目录%\%文件夹名%, %包目录%\%文件夹名%, R
			FileRemoveDir %解压目录%
			}
		Goto 结束
		}
	}
Else ;没找到文件夹
	{
	If 文件数 = 1 ;只有一个文件，下面移出。
		{
		IfExist %包目录%\%文件名% ;如果外面存在同名文件，移出时重命名。
			{
			Msgbox 移出单个文件时，发现已存在同名文件！`n`n故追加“重命名”字样后，再移出。
			SplitPath 文件名, , , 扩展, 名去扩展 ;将文件名分割为扩展名和纯名称两部分，存入变量。
			FileMove %解压目录%\%文件名%, %包目录%\%名去扩展%（重命名）.%扩展%
			}
		Else FileMove %解压目录%\%文件名%, %包目录% ;外面无同名文件，直接移出。
		FileRemoveDir %解压目录%
		Goto 结束
		}
	Else
		{
		MsgBox 这是一个空压缩包。
		Continue
		}
	}

结束:
;SoundPlay C:\Program Files\Messenger\type.wav, 1
CF_ToolTip("文件解压完成！", 2000)
;将这个和下面的变量都清空，以便在下一个压缩包的4种情况判断中重新使用。
文件夹数 := 文件数 := ""
}
Return