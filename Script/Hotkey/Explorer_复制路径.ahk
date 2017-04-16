;~ 在 Explorer 中模仿 TC 获取文件和文件夹路径的功能。
复制路径:
IfWinActive,ahk_Group ccc
{
Gui,3:Destroy
;Hotkey, IfWinActive,ahk_Group ccc
;hotkey,^+c,复制路径
;^+c 会触发切换输入法,  热键类型为  k-hook   c键释放  卡住就像按下了Ctrl+Shift  然后松开
;^+c改为全局热键，热键类型为 reg，加入下面一行脚本，则不一定会触发
keywait LShift

    Clipboard =
    Send, ^c    ;这里的 c 不能写成大写 C  大写C 为发送^+c
    ClipWait, 1

Loop, Parse, Clipboard, `n, `r
FileFullPath=%A_LoopField%
Splitpath,FileFullPath,Filename,Filepath

Gui,3:Add, Button, gexit3 x0 y0  w490 h28 +Left,复制路径到剪贴板                                                            退出
Gui,3:Add, Button, gCopyPath x0 y28 w490 h28 +Left,文件名称: %Filename%
Gui,3:Add, Button, gCopyPath x0 y56 w490 h28 +Left,文件目录: %Filepath%\
Gui,3:Add, Button, gCopyPath x0 y84 w490 h34 +Left,完整路径: %FileFullPath%

Gui,3:Show, w485 h92
Gui,3:+AlwaysOnTop -Caption -Border +AlwaysOnTop
Gui,3:Show
Gui,3:Flash
}
Return

;代码来源于7plus
;对于lnk文件只能获得文件名，不能获得lnk扩展名
;CTRL+ALT+C:复制文件路径到剪贴板
;Shift+ALT+C:追加文件名到剪贴板，原剪贴板内容不清空
复制文件名:
if !IsRenaming()
CopyFilenames()
Return

CopyFilenames()
{
	global PasteFileClipboardBackup
	files := GetSelectedFiles()
	if(files)
	{
		clip:=ReadClipboardText()
		if(!GetKeyState("Shift")) ;Shift=append to clipboard
			clip := ""
		if (GetKeyState("Control")) ; use control to save paths too
		{
				Loop, Parse, files, `n,`r  ; Rows are delimited by linefeeds (`r`n).
					clip .= (clip = "" ? "" : "`r`n") A_LoopField
				PasteFileClipboardBackup:="" ;Clear clipboard backup so it won't be restored when another program gets activated, since clipboard gets changed now
				clipboard:=clip
		}
		else
		{
				Loop, Parse, files, `n,`r  ; Rows are delimited by linefeeds (`r`n).
				{
					SplitPath, A_LoopField, file
					clip .= (clip = "" ? "" : "`r`n") file
				}
				PasteFileClipboardBackup:="" ;Clear clipboard backup so it won't be restored when another program gets activated, since clipboard gets changed now
				clipboard:=clip
		}
	}
	else
		SendInput !{c}
	return
}

CopyPath:
GuiControlGet,whichbutton, Focus
GuiControlGet,copypath,,%whichbutton%
StringLeft,copypath2,copypath,9
StringTrimLeft, copypath, copypath, 9
Clipboard = %copypath%
TrayTip, 剪贴板,%copypath2%" %copypath% "已经复制到剪贴板。
Gui,3:Destroy
SetTimer, RemoveTrayTip, 2500
return

exit3:
3GuiEscape:
Gui,3:Destroy
return

;Read real text (=not filenames, when CF_HDROP is in clipboard) from clipboard
ReadClipboardText()
{
	if(DllCall("IsClipboardFormatAvailable", "Uint", 1))
	{
		DllCall("OpenClipboard", "Uint", 0)
		htext:=DllCall("GetClipboardData", "Uint", 1)
		ptext := DllCall("GlobalLock", "uint", htext)
		text:=PointerToString(pText)
		text:=ExtractData(ptext)
		DllCall("GlobalUnlock", "uint", htext)
		DllCall("CloseClipboard")
	}
	return text
}

PointerToString(string)
{
	return DllCall("MulDiv", int, &sTest, int, 1, int, 1, str)
}

;get data starting from pointer up to 0 char
ExtractData(pointer) {
Loop {
       errorLevel := ( pointer+(A_Index-1) )
       Asc := *( errorLevel )
       IfEqual, Asc, 0, Break ; Break if NULL Character
       String := String . Chr(Asc)
     }
Return String
}