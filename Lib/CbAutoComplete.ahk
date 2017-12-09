;=======================================================================================
;
; Function:      CbAutoComplete
; Description:   Auto-completes typed values in a ComboBox.
;
; Author:        Pulover [Rodolfo U. Batista]
; Usage:         Call the function from the Combobox's gLabel.
; https://github.com/Pulover/CbAutoComplete
;=======================================================================================
CbAutoComplete()
{	; CB_GETEDITSEL = 0x0140, CB_SETEDITSEL = 0x0142
	If ((GetKeyState("Delete", "P")) || (GetKeyState("Backspace", "P"))|| (GetKeyState("shift", "P")))  ; shift 配合热键 @
		return
	GuiControlGet, lHwnd, Hwnd, %A_GuiControl%
	SendMessage, 0x0140, 0, 0,, ahk_id %lHwnd%
	MakeShort(ErrorLevel, Start, End)
	GuiControlGet, CurContent,, %lHwnd%
	GuiControl, ChooseString, %A_GuiControl%, %CurContent%
	If (ErrorLevel)
	{
		ControlSetText,, %CurContent%, ahk_id %lHwnd%
		;PostMessage, 0x0142, 0, MakeLong(Start, End),, ahk_id %lHwnd%
		PostMessage, 0x0142, 0, MakeLong(Start, StrLen(CurContent)),, ahk_id %lHwnd%
		return
	}
	GuiControlGet, CurContent,, %lHwnd%
	PostMessage, 0x0142, 0, MakeLong(Start, StrLen(CurContent)),, ahk_id %lHwnd%
}

MakeLong(LoWord, HiWord)
{
	return (HiWord << 16) | (LoWord & 0xffff)
}

MakeShort(Long, ByRef LoWord, ByRef HiWord)
{
	LoWord := Long & 0xffff
,   HiWord := Long >> 16
}
