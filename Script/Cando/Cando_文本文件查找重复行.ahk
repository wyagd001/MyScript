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
