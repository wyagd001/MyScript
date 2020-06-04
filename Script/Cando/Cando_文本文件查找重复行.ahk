Cando_文本文件查找重复行:
	Stime := A_TickCount
	FileEncoding, % File_GetEncoding(CandySel)
	Fline_array1 := {}
	Fline_array2 := {}
	Loop, read, % CandySel
	{
		if A_LoopReadLine && (StrLen(A_LoopReadLine) > 30)
		{
			if !Fline_array2[A_LoopReadLine]
			{
				Fline_array1[A_LoopReadLine] := 1
				Fline_array2[A_LoopReadLine] := A_index
			}
			else
			{
				Fline_array1[A_LoopReadLine] += 1
				FileAppend % Fline_array2[A_LoopReadLine] " - " A_index " - " Fline_array1[A_LoopReadLine] " " A_LoopReadLine "`r`n", %CandySel_ParentPath%\重复行.txt
				Fline_array2[A_LoopReadLine] := A_index
			}
		}
	}
	Fline_array1 := {}
	Fline_array2 := {}
	FileEncoding
	CF_ToolTip("查找完毕用时 " Round(A_TickCount/1000 - Stime/1000, 3) " 秒。", 3000)
return

Cando_查找文件夹中所有文本文件的重复行:
	Fline_array1 := {}
	Loop, %CandySel%\*.*, 0, 1
	{
		if A_LoopFileExt in txt,htm,html
		{
			FileEncoding, % File_GetEncoding(A_LoopFileLongPath)
			Loop, read, % A_LoopFileLongPath
			{
				if (A_index<20)
				Continue
				if strlen(A_LoopReadLine)<30
				Continue
				if InStr(A_LoopReadLine,"<p>类型:") or InStr(A_LoopReadLine,"<h2") or InStr(A_LoopReadLine,"#ExBasic")
				Continue
				if !Fline_array1[Trim(A_LoopReadLine)]
				{
					Fline_array1[Trim(A_LoopReadLine)] := 1
				}
				else
				{
					Fline_array1[Trim(A_LoopReadLine)] += 1
					FileAppend % A_LoopFileLongPath "`t" Fline_array1[Trim(A_LoopReadLine)] "`t" A_index "`t" Trim(A_LoopReadLine) "`r`n", %CandySel%\重复行.txt
				}
			}
		}
	}
	Fline_array1 := {}
	FileEncoding
return
