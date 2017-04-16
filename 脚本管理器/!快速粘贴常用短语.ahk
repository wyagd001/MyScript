;====================================
; 蓝蓝小雪 作品
; http://wwww.snow518.cn/
;====================================

#Persistent
#SingleInstance force
#Include %A_ScriptDir%\includes\LibINI.ahk

SetKeyDelay, -1
app := SubStr(A_ScriptName, 1, StrLen(A_ScriptName) - 4)
iniFile = %app%.ini
ini_Load(src,iniFile)
sec:=ini_GetSections(src)
Menu,Tray,NoIcon
Loop,Parse,sec,`n
{
    _Menu:=A_LoopField
	key:=ini_GetKeys(src,A_LoopField)
	Loop,Parse,key,`n
		Menu,%_Menu%,Add,%A_LoopField%,MenuHandler
	Menu,Tray,Add,%_Menu%,:%_Menu%
}
Menu,Tray,NoStandard
Menu,Tray,Add
Menu,Tray,Add, 编辑(&E), Menu_Edit
Menu,Tray,Add, 刷新(&R), Menu_Refresh
Menu,Tray,Add, 退出(&X), Menu_Exit
return

#C::
WinGet, old_win, ID, A
Menu,Tray, Show
Return

MenuHandler:
WinActivate ahk_id %old_win%
links:=ini_Read(src,A_ThisMenu,A_ThisMenuItem)
StringReplace, links, links, \n, `r`n, All
_SendRaw(links)
return

Menu_Exit:
ExitApp
Return

Menu_Edit:
Run, notepad %A_ScriptDir%\%app%.ini
Return

Menu_Refresh:
Reload
Return

_SendRaw(Keys)
{
    Len := StrLen(Keys) ; 得到字符串的长度，注意一个中文字符的长度是2
    KeysInUnicode := "" ; 将要发送的字符序列
    Char1 := "" ; 暂存字符1
    Code1 := 0 ; 字符1的ASCII码，值介于 0x0-0xFF (即1~255)
    Char2 := "" ; 暂存字符2
    Index := 1 ; 用于循环
    Loop
    {
		Code2 := 0 ; 字符2的ASCII码
		Char1 := SubStr(Keys, Index, 1) ; 第一个字符
		Code1 := Asc(Char1) ; 得到其ASCII值
		if(Code1 >= 129 And Code1 <= 254 And Index < Len) ; 判断是否中文字符的第一个字符
		{
			Char2 := SubStr(Keys, Index+1, 1) ; 第二个字符
			Code2 := Asc(Char2) ; 得到其ASCII值
			if(Code2 >= 64 And Code2 <= 254) ; 若条件成立则说明是中文字符
			{
				Code1 <<= 8 ; 第一个字符应放到高8位上
				Code1 += Code2 ; 第二个字符放在低8位上
			}
			Index++
		}
		if(Code1 <= 255) ; 如果此值仍<=255则说明是非中文字符，否则经过上面的处理必然大于255
			Code1 := "0" . Code1
		KeysInUnicode .= "{ASC " . Code1 . "}"
		if(Code2 > 0 And Code2 < 64)
		{
			Code2 := "0" . Code2
			KeysInUnicode .= "{ASC " . Code2 . "}"
		}
		Index++
		if(Index > Len)
			Break
    }
Send % KeysInUnicode
}
