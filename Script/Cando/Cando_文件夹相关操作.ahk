Cando_同名空白文件:
FileCreateDir, %CandySel_ParentPath%\%CandySel_FileNameWithExt%_①
Loop, Files, %CandySel%\*.*, DR
{
	StringReplace, _temp, A_LoopFileLongPath, %CandySel%\, ,All
	FileCreateDir, %CandySel_ParentPath%\%CandySel_FileNameWithExt%_①\%_temp%
}
Loop, Files, %CandySel%\*.*, FR
{
	StringReplace, _temp, A_LoopFileLongPath, %CandySel%\, ,All
	FileAppend, , %CandySel_ParentPath%\%CandySel_FileNameWithExt%_①\%_temp%
}
return

Cando_复制目录结构:
Files:= CandySel . "\"
CopyDirStructure(Files, CandySel_ParentPath "\" CandySel_FileNameWithExt "_①", 0)
Return