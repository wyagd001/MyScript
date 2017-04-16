Cando_注册表跳转:
;替换字串中第一个“， ”为"\"
StringReplace,CandySel,CandySel,`,%A_Space%,\
;替换字串中第一个“，”为"\"
StringReplace,CandySel,CandySel,`, ,\
IfInString, CandySel,HKLM
{
   StringTrimLeft, cutCandySel, CandySel, 4
   CandySel := "HKEY_LOCAL_MACHINE" . cutCandySel
}
IfInString, CandySel,HKCR
{
   StringTrimLeft, cutCandySel, CandySel, 4
   CandySel := "HKEY_CLASSES_ROOT" . cutCandySel
}
IfInString, CandySel,HKCC
{
   StringTrimLeft, cutCandySel, CandySel, 4
   CandySel := "HKEY_CURRENT_CONFIG" . cutCandySel
}
IfInString, CandySel,HKCU
{
   StringTrimLeft, cutCandySel, CandySel, 4
   CandySel := "HKEY_CURRENT_USER" . cutCandySel
}
IfInString, CandySel,HKU
{
   StringTrimLeft, cutCandySel, CandySel, 3
   CandySel := "HKEY_USERS" . cutCandySel
}
;将字串中的所有“＼”(全角)替换为“\”（半角）
StringReplace,CandySel,CandySel,＼,\,All
StringReplace,CandySel,CandySel,%A_Space%\,\,All
StringReplace,CandySel,CandySel,\%A_Space%,\,All

;将字串中的所有“\\”替换为“\”
StringReplace,CandySel,CandySel,\\,\,All

IfWinExist, 注册表编辑器 ahk_class RegEdit_RegEdit
{
IfNotInString, CandySel, 计算机\
CandySel := "计算机\" . CandySel
WinActivate, 注册表编辑器
ControlGet, hwnd, hwnd, , SysTreeView321, 注册表编辑器
TVPath_Set(hwnd, CandySel, matchPath)
}
Else
{
RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, %CandySel%
Run, regedit.exe -m
}