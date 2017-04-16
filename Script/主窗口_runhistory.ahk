#ifwinactive, ahk_Group AppMainWindow
Del::
GuiControlGet, focused_control, focusV
ifEqual, focused_control, Dir
{
  Tempitems =
  GuiControlGet, EditContent, , %Focused_Control%, Text
  ;MsgBox % EditContent
  Loop, Parse, stableProgram, |
	{
		If (A_LoopField = EditContent) ; not case-sensitive
		    Return
    }
  Loop, Parse, ComboBoxShowItems, |
	{
	    If !A_LoopField Or (A_LoopField = EditContent) ; not case-sensitive
			Continue
		Else
			Tempitems .= A_LoopField . "|"
	}
	StringTrimRight, Tempitems, Tempitems, 1   ; remove last |
	;ToolTip % Tempitems
	ComboBoxShowItems := Tempitems
	GuiControl, , %Focused_Control%, |%ComboBoxShowItems%
	sLength := StrLen(stableProgram)
	StringTrimLeft, historyData, ComboBoxShowItems, %sLength%
	;MsgBox % historyData
	IniWrite,%historyData%,%run_iniFile%,固定的程序,historyData
}
Return
#ifwinactive

#ifwinactive, ahk_Group AppMainWindow
~Enter::
~Numpadenter::
    sleep 2000
WinActivate,%apptitle%
GuiControlGet, focused_control, focusV
ifEqual, focused_control, Dir
{
  GuiControlGet, EditContent, , %Focused_Control%, Text
  ;MsgBox % EditContent
  Loop, Parse, stableProgram, |
	{
		If (A_LoopField = EditContent) ; not case-sensitive
		Return
	}
  If (EditContent <> "")
    {
	historyData .= "|"
	historyData .= EditContent
	Sort, historyData, D| U
	ComboBoxShowItems :=stableProgram . historyData
	IniWrite,%historyData%,%run_iniFile%,固定的程序,historyData
    ;MsgBox %  ComboBoxShowItems
	GuiControl, , %Focused_Control%, |%ComboBoxShowItems%
	GuiControl,ChooseString,dir,%EditContent%
	GuiControl, +default,打开(&O)
	}
}
Return
#ifwinactive