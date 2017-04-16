;Checks if a context menu is active and has focus
IsContextMenuActive()
{
	GuiThreadInfoSize = 48
	VarSetCapacity(GuiThreadInfo, 48)
	NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
	if not DllCall("GetGUIThreadInfo", uint, 0, str, GuiThreadInfo)
	{
	  MsgBox GetGUIThreadInfo() indicated a failure.
	  return
	}
	; GuiThreadInfo contains a DWORD flags at byte 4
	; Bit 4 of this flag is set if the thread is in menu mode. GUI_INMENUMODE = 0x4
	if (NumGet(GuiThreadInfo, 4) & 0x4)
	  return true
	return false
}
