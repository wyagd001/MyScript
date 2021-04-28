;---------------------------------------------------------------------------
; A simple auto-search utility for the WinExplorer
; created by Buddy 02/2009
;
;---------------------------------------------------------------------------

;---------------------------------------------------------------------------
; Define SPACE as Windows Explorer auto-search hotkey
;---------------------------------------------------------------------------
;#NoTrayIcon
;!Space::
定位文件:
IfWinActive,ahk_Group ccc
searchInExplorer()
Else
{
Sleep,100
Send !{Space}
    }
Return

;---------------------------------------------------------------------------
; Search function
;---------------------------------------------------------------------------
searchInExplorer() {

    ;---------------------------------------------------------------------------
    ; Control variables must be global
    ;---------------------------------------------------------------------------
    global Input
    global List

    ;---------------------------------------------------------------------------
    ; Save incoming clipboard content
    ;---------------------------------------------------------------------------
    OldClip := Clipboard

    ;---------------------------------------------------------------------------
    ; Store current directory name to clipboard
    ;---------------------------------------------------------------------------
    Send !d^c{Tab}

    ;---------------------------------------------------------------------------
    ; Define and show minimal GUI with controls
    ;---------------------------------------------------------------------------
    Gui, 5:Font, S10 CDefault Bold, Letter Gothic
    Gui, 5:Margin,0,0
    Gui, 5:+Owner +AlwaysOnTop -Caption
    Gui, 5:Add, Edit, x0 y0 h25 w600 vInput gInputEvent hwndhInput
    Gui, 5:Add, ListView, x0 y+0 h400 w600 vList gListEvent hwndhList Hide -Hdr AltSubmit,%A_Space%
    Gui, 5:Show, Center

WaitForKey:
    ;---------------------------------------------------------------------------
    ; Retrieve the control, which currently has the focus
    ; (according ControlGetFocus page in AHK manual)
    ;---------------------------------------------------------------------------
    ;VarSetCapacity(hInputDec, 65, 0)
    ; 十六进制数字转十进制   得到10进制字符串  以00结尾的字符串 例如 0xFF  得到 3235 3500
    ;DllCall("msvcrt\_i64toa", Int64, hInput, Str, hInputDec, Int, 10)
    GuiThreadInfoSize = 48
    VarSetCapacity(GuiThreadInfo, GuiThreadInfoSize)
    NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
    If DllCall("GetGUIThreadInfo", uint, 0, str, GuiThreadInfo)
        hFocused := NumGet(GuiThreadInfo, 12)
    Else
        hFocused = 0
;CF_tooltip(hFocused " || " hInput,3000)
    ;---------------------------------------------------------------------------
    ; Wait until user pressed ENTER, ESC or DOWN key
    ;---------------------------------------------------------------------------
    Input, keyf,V, {Enter}{Esc}{Down}

    ;---------------------------------------------------------------------------
    ; For DOWN the cursor jumps down into the search list
    ;---------------------------------------------------------------------------
    If (ErrorLevel = "EndKey:Down")
    {
						;CF_tooltip(hFocused,3000)
        If  (hFocused = hInput)
            SendInput {Tab}{Down}
        ;---------------------------------------------------------------------------
        ; Go wait for the next key if DOWN is pressed
        ;---------------------------------------------------------------------------
        Goto,WaitForKey
    }

    ;---------------------------------------------------------------------------
    ; ENTER & ESC closes the GUI
    ;---------------------------------------------------------------------------
    Gui, 5:Destroy

    ;---------------------------------------------------------------------------
    ; ENTER also shows the selected file in another explorer window
    ;---------------------------------------------------------------------------
    If (ErrorLevel = "EndKey:Enter") AND (SelectedFile or keyf)
    {
       ;tooltip
       ;Run, % "explorer.exe /select," . Clipboard . "\" . SelectedFile
       if SelectedFile && (SelectedFile != " ")
{
;CF_tooltip(keyf " |111| " SelectedFile,3000)
         SelectFiles(SelectedFile)
}
       else if keyf
{
         SelectFiles(keyf)
;       CF_tooltip(keyf " |222| " SelectedFile,3000)
}

    }
    ;---------------------------------------------------------------------------
    ; Restore the clipboard and return
    ;---------------------------------------------------------------------------
    Clipboard := OldClip
    Return

    ;---------------------------------------------------------------------------
    ; Routine executed for each keystroke in the input field
    ;---------------------------------------------------------------------------
InputEvent:
        ;---------------------------------------------------------------------------
        ; Retrieve actual user input
        ;---------------------------------------------------------------------------
        GuiControlGet, Input

        ;---------------------------------------------------------------------------
        ; Show list control
        ;---------------------------------------------------------------------------
        GuiControl, Show, List

        ;---------------------------------------------------------------------------
        ; Search files based on specified prefix and list them
        ;---------------------------------------------------------------------------
        LV_Delete()
        Loop, %Clipboard%\%Input%*
            LV_Add("", A_LoopFileName)

        ;---------------------------------------------------------------------------
        ; Resize list control height according to the number of found files
        ;---------------------------------------------------------------------------
        LV_ModifyCol(1,"AutoHdr")
        LV_Modify(1, "Focus")
        h1 := LV_GetCount() * 25
        if h1 < 400
				{
          h2 := h1 + 25
				}
        else
				{
          h1 := 400
          h2 := 430
				}
        GuiControl, Move, List, h%h1%
        Gui, 5:Show, h%h2% ;, Center h%h2%
    Return

    ;---------------------------------------------------------------------------
    ; Routine executed for each keystroke in the search list
    ;---------------------------------------------------------------------------
ListEvent:
        ;---------------------------------------------------------------------------
        ; Retrieve file name for selected row
        ;---------------------------------------------------------------------------
        LV_GetText(SelectedFile, LV_GetNext(0))
    Return
}