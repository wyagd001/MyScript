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

Cando_解开文件夹:
ErrorCount := MoveFilesAndFolders(CandySel "\*.*", CandySel_ParentPath)
if (ErrorCount != 0)
    MsgBox %ErrorCount% 个文件/文件夹移动失败.
else
    FileRecycle, % CandySel
return

MoveFilesAndFolders(SourcePattern, DestinationFolder, DoOverwrite = false)
; 移动匹配 SourcePattern 的所有文件和文件夹到 DestinationFolder 文件夹中且
; 返回无法移动的文件/文件夹的数目. 此函数需要 [v1.0.38+]
; 因为它使用了 FileMoveDir 的模式 2.
{
    if (DoOverwrite = 1)
        DoOverwrite := 2  ; 请参阅 FileMoveDir 了解模式 2 与模式 1 的区别.
    ; 首先移动所有文件(不是文件夹):
    FileMove, %SourcePattern%, %DestinationFolder%, %DoOverwrite%
    ErrorCount := ErrorLevel
    ; 现在移动所有文件夹:
    Loop, %SourcePattern%, 2  ; 2 表示 "只获取文件夹".
    {
        FileMoveDir, %A_LoopFileFullPath%, %DestinationFolder%\%A_LoopFileName%, %DoOverwrite%
        ErrorCount += ErrorLevel
        if ErrorLevel  ; 报告每个出现问题的文件夹名称.
            MsgBox Could not move %A_LoopFileFullPath% into %DestinationFolder%.
    }
    return ErrorCount
}
