Loop Files, %A_ScriptDir%\*.ahk, FR
	s.=A_LoopFileFullPath "`r`n"
FileAppend, %s%,%A_ScriptDir%\all.txt, UTF-8
s:=""
Loop Files, %A_ScriptDir%\*.ahk, FR
{
FileRead, OutputVar, %A_LoopFileFullPath%
s .= "`r`n" A_LoopFileFullPath "`r`n"
s .= "`r`n" OutputVar "`r`n"
}
FileAppend, %s%,%A_ScriptDir%\all.txt, UTF-8
FileMove, %A_ScriptDir%\all.txt, %A_ScriptDir%\all.ahk