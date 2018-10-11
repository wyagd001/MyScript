cando_智能解压:
	SmartUnZip_首层多个文件标志:=0
	SmartUnZip_首层有文件夹标志:=0
	SmartUnZip_首层文件夹名:=
	SmartUnZip_文件夹名A:=
	SmartUnZip_文件夹名B:=

	包列表=%A_Temp%\wannianshuyaozhinengjieya_%A_Now%.txt

	SplitPath ,CandySel,,包目录,,包文件名,IntUnZip_FileDrive
	DriveSpaceFree , IntUnZip_FreeSpace, %IntUnZip_FileDrive%
FileGetSize, IntUnZip_FileSize, %CandySel%, M
	If ( IntUnZip_FileSize > IntUnZip_FreeSpace )
	{
		MsgBox 磁盘空间不足,请检查后再解压。`n------------`n压缩包大小为%IntUnZip_FileSize%M`n剩余空间为%IntUnZip_FreeSpace%M
		Return
	}
	RunWait, %comspec% /c ""%7Z%" l "%CandySel%" `>"%包列表%"",,hide

;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	loop,read,%包列表%
	{
		If(RegExMatch(A_LoopReadLine,"^(\d\d\d\d-\d\d-\d\d)"))
		{
			If( InStr(A_loopreadline,"D")=21 Or InStr(A_loopreadline,"\"))  ;本行如果包含\或者有D标志，则判定为文件夹
			{
				SmartUnZip_首层有文件夹标志=1
			}

			If InStr(A_loopreadline,"\")
				StringMid,SmartUnZip_文件夹名A,A_LoopReadLine,54,InStr(A_loopreadline,"\")-54
			Else
				StringTrimLeft,SmartUnZip_文件夹名A,A_LoopReadLine,53

			If((SmartUnZip_文件夹名B != SmartUnZip_文件夹名A ) And ( SmartUnZip_文件夹名B!="" ))
			{
				SmartUnZip_首层多个文件标志=1
				Break
			}
			SmartUnZip_文件夹名B:=SmartUnZip_文件夹名A
		}
	}
	FileDelete,%包列表%
; 	MsgBox SmartUnZip_首层多个文件标志%SmartUnZip_首层多个文件标志%
; 	MsgBox SmartUnZip_首层有文件夹标志%SmartUnZip_首层有文件夹标志%
; 	MsgBox SmartUnZip_文件夹名A%SmartUnZip_文件夹名A%
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

	If(SmartUnZip_首层多个文件标志=0 && SmartUnZip_首层有文件夹标志=0 )   ;压缩文件内，首层有且仅有一个文件
	{
		Run, %7ZG% x "%CandySel%" -o"%包目录%"    ;覆盖还是改名，交给7z
	}

	Else If(SmartUnZip_首层多个文件标志=0 && SmartUnZip_首层有文件夹标志=1 )   ;压缩文件内，首层有且仅有一个文件夹
	{
		IfExist,%包目录%\%SmartUnZip_文件夹名A%   ;已经存在了以“首层文件夹命名”的文件夹，怎么办？
		{
			Loop
			{
				SmartUnZip_NewFolderName=%包目录%\%SmartUnZip_文件夹名A%( %A_Index% )
				If !FileExist( SmartUnZip_NewFolderName )
				{
; 					MsgBox %SmartUnZip_NewFolderName%
					Run, %7ZG% x "%CandySel%"   -o"%SmartUnZip_NewFolderName%"
					break
				}
			}
			; Run, %7ZG% x "%CandySel%"   -o"%包目录%\%SmartUnZip_文件夹名A%_%A_now%"
		}
		Else  ;没有“首层文件夹命名”的文件夹，那就太好了
		{
			Run, %7ZG% x "%CandySel%" -o"%包目录%"
		}
	}
	Else  ;压缩文件内，首层有多个文件夹
	{
		IfExist %包目录%\%包文件名%  ;已经存在了以“包文件名”的文件夹，怎么办？
		{
			Loop
			{
				SmartUnZip_NewFolderName=%包目录%\%包文件名%( %A_Index% )
				If !FileExist( SmartUnZip_NewFolderName )
				{
; 					MsgBox %SmartUnZip_NewFolderName%
					Run, %7ZG% x "%CandySel%"   -o"%SmartUnZip_NewFolderName%"
					break
				}
			}
; 			Run, %7ZG% x  "%CandySel%" -o"%包目录%\%包文件名%_%A_now%"
		}
		Else ;没有，那就太好了
		{
			Run, %7ZG% x  "%CandySel%" -o"%包目录%\%包文件名%"
		}
	}
	Return