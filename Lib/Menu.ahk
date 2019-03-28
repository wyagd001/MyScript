;Checks if a context menu is active and has focus
IsContextMenuActive()
{
	GuiThreadInfoSize := A_PtrSize ? 4+4+A_PtrSize*6+16 : 48
	VarSetCapacity(GuiThreadInfo, GuiThreadInfoSize)
	NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
	if not DllCall("GetGUIThreadInfo", uint, 0, "ptr", &GuiThreadInfo)
	{
	  MsgBox GetGUIThreadInfo() µ÷ÓÃÊ§°Ü.
	  return
	}
	; GuiThreadInfo contains a DWORD flags at byte 4
	; Bit 4 of this flag is set if the thread is in menu mode. GUI_INMENUMODE = 0x4
	if (NumGet(GuiThreadInfo, 4) & 0x4)
	  return true
	return false
}

/*
typedef struct TAGGUITHREADINFO {
  DWORD cbSize;
  DWORD flags;
  HWND  hwndActive;
  HWND  hwndFocus;
  HWND  hwndCapture;
  HWND  hwndMenuOwner;
  HWND  hwndMoveSize;
  HWND  hwndCaret;
  RECT  rcCaret;
} GUITHREADINFO, *PGUITHREADINFO, *LPGUITHREADINFO;
*/
