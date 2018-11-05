IME_Switch(dwLayout)
{
    HKL := DllCall("LoadKeyboardLayout", Str, dwLayout, UInt, 1)
    ControlGetFocus, ctl, A
    SendMessage, 0x50, 0, HKL, %ctl%, A
}

IME_SwitchToEng()
{
    ; 下方代码可只保留一个
    IME_Switch(0x04090409) ; 英语(美国) 美式键盘
    IME_Switch(0x08040804) ; 中文(中国) 简体中文-美式键盘
}

; 测试时，WIN7 下切换到 搜狗拼音/智能ABC/QQ拼音 时返回值都为0，英文键盘返回值为8
IME_GetSentenceMode(WinTitle="A")   {
	ControlGet,hwnd,HWND,,,%WinTitle%
	If	(WinActive(WinTitle))	{
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
	    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
	    NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
		hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
	             ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
	}
    Return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          ,  Int, 0x003   ;wParam  : IMC_GETSENTENCEMODE
          ,  Int, 0)      ;lParam  : 0
}