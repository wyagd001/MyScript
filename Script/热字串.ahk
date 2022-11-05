:*:@zhushi::
zhushi_fun()
{
	WinGetTitle, h_hzcWin,A
	if InStr(h_hzcWin, ".js") or InStr(h_hzcWin, ".cpp") or InStr(h_hzcWin, ".css")
	{
		send //
		return
	}
	else if InStr(h_hzcWin, ".vbs")
	{
		send '
		return
	}
	else if InStr(h_hzcWin, ".bat")
	{
		send ::
		return
	}
	else if InStr(h_hzcWin, ".reg") or InStr(h_hzcWin, ".ini") or InStr(h_hzcWin, ".inf") or InStr(h_hzcWin, ".ahk") or InStr(h_hzcWin, ".au3")
	{
		Send `;
		return
	}
	else if InStr(h_hzcWin, ".lst") or InStr(h_hzcWin, ".py") or InStr(h_hzcWin, ".sh") or InStr(h_hzcWin, "hosts")
	{
		send {#}
		return
	}
	else if InStr(h_hzcWin, ".html") or InStr(h_hzcWin, "htm")
	{
		send <{!}--  -->
		return
	}
}

;* 任意==号时自动触发，不需要终止符触发，B0 触发不删除==
:?B0*:==::
If !IME_IsENG()
; 检测 IME 状态，中文输入时不执行任何命令，
{
	sleep, 400
	Return
}
Else
{
	SetFormat, FLOAT, 0.6
	BackUp_ClipBoard := ClipboardAll
	Clipboard :=
	; 复制
	Send, +{Home}^c
 ; 剪贴
	;Send, +{Home}^x
	ClipWait, 1
	StringReplace, Clipboard, Clipboard, ==,, all
	Tmp_Val := ZTrim(Eval(Clipboard))
	;tooltip % Eval(Clipboard) "`n" Tmp_Val
	; 是否保留公式
	;Send, {end}=
	;SendInput, %Tmp_Val%
	Send, %Tmp_Val%
	Clipboard := BackUp_ClipBoard
	Tmp_Val := BackUp_ClipBoard := ""
}
Return