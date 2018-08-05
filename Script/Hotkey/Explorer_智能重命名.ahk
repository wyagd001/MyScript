; http://ahk.5d6d.com/viewthread.php?tid=703

#IfWinActive ahk_group ccc
F2::
    WinID := WinExist("A")  ; 获取当前窗口的 ID
    ControlGetFocus, ControlName, ahk_id %WinID%    ; 获取当前窗口获得焦点的控件名

    IfNotInString, ControlName, Edit    ; 判断当前是否处于命名状态, Edit 是重命名编辑框的类名
    {
		State = 0
        Send, {F2}
        Sleep, 100
    }

    ControlID := GetFocusControlID()    ; 获取重命名编辑框的 ID
    ControlGetText, FileName,, ahk_id %ControlID%   ; 获取文件名或文件夹名

    StringGetPos, DotPostion, FileName, ., R ; 获取最右边的 "." 的位置

    If !ErrorLevel   ; 当文件名有 "." 时才进行变换选择
    {
        MoveCount := StrLen(FileName) - DotPostion
        if state=
            state=2
        Goto, RenameState%State%
    }
Return
#IfWinActive

RenameState0:
State = 1
Return

; 仅选中扩展名
RenameState1:
    ExtensionMoveCount := MoveCount - 1
    Send, ^{End}+{Left %ExtensionMoveCount%}
		State =2
Return

; 全选文件名（包括扩展名）
RenameState2:
    Send, ^{Home}+^{End}
		State = 3
Return

; 光标停在扩展名的"."前
RenameState3:
    Send, ^{End}{Left %MoveCount%}
		State = 4
Return

; 仅选中文件名（不包括扩展名）
RenameState4:
Send, ^{Home}+^{End}+{Left %MoveCount%} ; 全选，然后按住 Shift 左移，不选中扩展名
	State = 1
Return

;-------------------------------------------------------------------------------

; ~ 返回当前窗口获得焦点的控件的 ID
GetFocusControlID()
    {
        WinID := WinExist("A")
        ControlGetFocus, ControlName, ahk_id %WinID%
        ControlGet, ControlID, HWND,, %ControlName%, ahk_id %WinID%
        Return ControlID
    }

;-------------------------------------------------------------------------------