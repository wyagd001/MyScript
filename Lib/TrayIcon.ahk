; 来源网址：https://autohotkey.com/boards/viewtopic.php?p=9186#p9186
; 作用是操控右下角 系统托盘区 的图标，可右键点击调出菜单等

; ----------------------------------------------------------------------------------------------------------------------
; Name ..........: TrayIcon library
; Description ...: Provide some useful functions to deal with Tray icons.
; AHK Version ...: AHK_L 1.1.22.02 x32/64 Unicode
; Original Author: Sean (http://goo.gl/dh0xIX) (http://www.autohotkey.com/forum/viewtopic.php?t=17314)
; Update Author .: Cyruz (http://ciroprincipe.info) (http://ahkscript.org/boards/viewtopic.php?f=6&t=1229)
; Mod Author ....: Fanatic Guru
; License .......: WTFPL - http://www.wtfpl.net/txt/copying/
; Version Date...: 2020 - 03 - 22
; Note ..........: Many people have updated Sean's original work including me but Cyruz's version seemed the most straight
; ...............: forward update for 64 bit so I adapted it with some of the features from my Fanatic Guru version.
; Update 20160120: Went through all the data types in the DLL and NumGet and matched them up to MSDN which fixed IDcmd.
; Update 20160308: Fix for Windows 10 NotifyIconOverflowWindow
; Update 20180313: Fix problem with "VirtualFreeEx" pointed out by nnnik
; Update 20180313: Additional fix for previous Windows 10 NotifyIconOverflowWindow fix breaking non-hidden icons
; Update 20190404: Added TrayIcon_Set by Cyruz
; Update 20200322: Added TrayIcon_Add from majkinetor by wyagd0001
; ----------------------------------------------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------------------------------------------
; Function ......: TrayIcon_GetInfo
; Description ...: Get a series of useful information about tray icons.
; Parameters ....: sExeName  - The exe for which we are searching the tray icon data. Leave it empty to receive data for 
; ...............:             all tray icons.
; Return ........: oTrayIcon_GetInfo - An array of objects containing tray icons data. Any entry is structured like this:
; ...............:             oTrayIcon_GetInfo[A_Index].idx     - 0 based tray icon index.
; ...............:             oTrayIcon_GetInfo[A_Index].IDcmd   - Command identifier associated with the button.
; ...............:             oTrayIcon_GetInfo[A_Index].pID     - Process ID.
; ...............:             oTrayIcon_GetInfo[A_Index].uID     - Application defined identifier for the icon.
; ...............:             oTrayIcon_GetInfo[A_Index].msgID   - Application defined callback message.
; ...............:             oTrayIcon_GetInfo[A_Index].hIcon   - Handle to the tray icon.
; ...............:             oTrayIcon_GetInfo[A_Index].hWnd    - Window handle.
; ...............:             oTrayIcon_GetInfo[A_Index].Class   - Window class.
; ...............:             oTrayIcon_GetInfo[A_Index].Process - Process executable.
; ...............:             oTrayIcon_GetInfo[A_Index].Tray    - Tray Type (Shell_TrayWnd or NotifyIconOverflowWindow).
; ...............:             oTrayIcon_GetInfo[A_Index].tooltip - Tray icon tooltip.
; Info ..........: TB_BUTTONCOUNT message - http://goo.gl/DVxpsg
; ...............: TB_GETBUTTON message   - http://goo.gl/2oiOsl
; ...............: TBBUTTON structure     - http://goo.gl/EIE21Z
; ----------------------------------------------------------------------------------------------------------------------

TrayIcon_GetInfo(sExeName := "")
{
	DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
	oTrayIcon_GetInfo := {}
	For key, sTray in ["NotifyIconOverflowWindow", "Shell_TrayWnd"]
	{
		idxTB := TrayIcon_GetTrayBar(sTray)
		WinGet, pidTaskbar, PID, ahk_class %sTray%
		
		hProc := DllCall("OpenProcess", UInt, 0x38, Int, 0, UInt, pidTaskbar)
		pRB   := DllCall("VirtualAllocEx", Ptr, hProc, Ptr, 0, UPtr, 20, UInt, 0x1000, UInt, 0x4)

			SendMessage, 0x418, 0, 0, ToolbarWindow32%idxTB%, ahk_class %sTray%   ; TB_BUTTONCOUNT = 0x418
		
		szBtn := VarSetCapacity(btn, (A_Is64bitOS ? 32 : 20), 0)
		szNfo := VarSetCapacity(nfo, (A_Is64bitOS ? 32 : 24), 0)
		szTip := VarSetCapacity(tip, 128 * 2, 0)
		
		Loop, %ErrorLevel%
		{
				SendMessage, 0x417, A_Index - 1, pRB, ToolbarWindow32%idxTB%, ahk_class %sTray%   ; TB_GETBUTTON
			DllCall("ReadProcessMemory", Ptr, hProc, Ptr, pRB, Ptr, &btn, UPtr, szBtn, UPtr, 0)

			iBitmap := NumGet(btn, 0, "Int")
			IDcmd   := NumGet(btn, 4, "Int")
			statyle := NumGet(btn, 8)
			dwData  := NumGet(btn, (A_Is64bitOS ? 16 : 12))
			iString := NumGet(btn, (A_Is64bitOS ? 24 : 16), "Ptr")

			DllCall("ReadProcessMemory", Ptr, hProc, Ptr, dwData, Ptr, &nfo, UPtr, szNfo, UPtr, 0)

			hWnd  := NumGet(nfo, 0, "Ptr")
			uID   := NumGet(nfo, (A_Is64bitOS ? 8 : 4), "UInt")
			msgID := NumGet(nfo, (A_Is64bitOS ? 12 : 8))
			hIcon := NumGet(nfo, (A_Is64bitOS ? 24 : 20), "Ptr")

			WinGet, pID, PID, ahk_id %hWnd%
			WinGet, sProcess, ProcessName, ahk_id %hWnd%
			WinGetClass, sClass, ahk_id %hWnd%

			If !sExeName || (sExeName = sProcess) || (sExeName = pID) || (sExeName = hWnd)
			{
				DllCall("ReadProcessMemory", Ptr, hProc, Ptr, iString, Ptr, &tip, UPtr, szTip, UPtr, 0)
				Index := (oTrayIcon_GetInfo.MaxIndex()>0 ? oTrayIcon_GetInfo.MaxIndex()+1 : 1)
				oTrayIcon_GetInfo[Index,"idx"]     := A_Index - 1
				oTrayIcon_GetInfo[Index,"IDcmd"]   := IDcmd
				oTrayIcon_GetInfo[Index,"pID"]     := pID
				oTrayIcon_GetInfo[Index,"uID"]     := uID
				oTrayIcon_GetInfo[Index,"msgID"]   := msgID
				oTrayIcon_GetInfo[Index,"hIcon"]   := hIcon
				oTrayIcon_GetInfo[Index,"hWnd"]    := hWnd
				oTrayIcon_GetInfo[Index,"Class"]   := sClass
				oTrayIcon_GetInfo[Index,"Process"] := sProcess
				oTrayIcon_GetInfo[Index,"Tooltip"] := StrGet(&tip, "UTF-16")
				oTrayIcon_GetInfo[Index,"Tray"]    := sTray
			}
		}
		DllCall("VirtualFreeEx", Ptr, hProc, Ptr, pRB, UPtr, 0, Uint, 0x8000)
		DllCall("CloseHandle", Ptr, hProc)
	}
	DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
	Return oTrayIcon_GetInfo
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_Hide
; Description ..: Hide or unhide a tray icon.
; Parameters ...: IDcmd - Command identifier associated with the button.
; ..............: bHide - True for hide, False for unhide.
; ..............: sTray - 1 or Shell_TrayWnd || 0 or NotifyIconOverflowWindow.
; Info .........: TB_HIDEBUTTON message - http://goo.gl/oelsAa
; ----------------------------------------------------------------------------------------------------------------------
^q::
TrayIcon_Hide(1,0,1)
return

TrayIcon_Hide(IDcmd, sTray := "Shell_TrayWnd", bHide:=True)
{
	sTray := sTray = 0 ?  "NotifyIconOverflowWindow" : "Shell_TrayWnd"
	DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
	idxTB := TrayIcon_GetTrayBar()
	; win 10 隐藏托盘时 idxTB 返回 3, NotifyIconOverflowWindow  中的图标所在区域为 ToolbarWindow321，未隐藏的为ToolbarWindow323
	; 未隐藏时为 ToolbarWindow323，系统版本不同可能有出入
	; Win7 隐藏图标与否都是 ToolbarWindow321
	idxTB := sTray = "NotifyIconOverflowWindow" ? 1 : idxTB
	SendMessage, 0x404, IDcmd, bHide, ToolbarWindow32%idxTB%, ahk_class %sTray% ; TB_HIDEBUTTON
	SendMessage, 0x1A, 0, 0, , ahk_class %sTray%
	DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_Delete
; Description ..: Delete a tray icon.
; Parameters ...: idx - 0 based tray icon index.
; ..............: sTray - 1 or Shell_TrayWnd || 0 or NotifyIconOverflowWindow.
; Info .........: TB_DELETEBUTTON message - http://goo.gl/L0pY4R
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_Delete(idx, sTray := "Shell_TrayWnd")
{
	sTray := sTray = 0 ?  "NotifyIconOverflowWindow" : "Shell_TrayWnd"
	DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
	idxTB := TrayIcon_GetTrayBar()
	SendMessage, 0x416, idx, 0, ToolbarWindow32%idxTB%, ahk_class %sTray% ; TB_DELETEBUTTON
	SendMessage, 0x1A, 0, 0, , ahk_class %sTray%
	DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_Remove
; Description ..: Remove a tray icon.
; Parameters ...: hWnd, uID.
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_Remove(hWnd, uID)
{
		NumPut(VarSetCapacity(NID,(A_IsUnicode ? 2 : 1) * 384 + A_PtrSize * 5 + 40,0), NID)
		NumPut(hWnd , NID, A_PtrSize   )
		NumPut(uID  , NID, 2*A_PtrSize )
		Return DllCall("shell32\Shell_NotifyIcon", "Uint", 0x2, "Uint", &NID)
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_Move
; Description ..: Move a tray icon.
; Parameters ...: idxOld - 0 based index of the tray icon to move.
; ..............: idxNew - 0 based index where to move the tray icon.
; ..............: sTray - 1 or Shell_TrayWnd || 0 or NotifyIconOverflowWindow.
; Info .........: TB_MOVEBUTTON message - http://goo.gl/1F6wPw
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_Move(idxOld, idxNew, sTray := "Shell_TrayWnd")
{
	sTray := sTray = 0 ?  "NotifyIconOverflowWindow" : "Shell_TrayWnd"
	DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
	idxTB := TrayIcon_GetTrayBar()
	SendMessage, 0x452, idxOld, idxNew, ToolbarWindow32%idxTB%, ahk_class %sTray% ; TB_MOVEBUTTON
	DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_Set
; Description ..: Modify icon with the given index for the given window.
; Parameters ...: hWnd       - Window handle.
; ..............: uId        - Application defined identifier for the icon.
; ..............: hIcon      - Handle to the tray icon.
; ..............: hIconSmall - Handle to the small icon, for window menubar. Optional.
; ..............: hIconBig   - Handle to the big icon, for taskbar. Optional.
; Return .......: True on success, false on failure.
; Info .........: NOTIFYICONDATA structure  - https://goo.gl/1Xuw5r
; ..............: Shell_NotifyIcon function - https://goo.gl/tTSSBM
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_Set(hWnd, uId, hIcon, hIconSmall:=0, hIconBig:=0,hTooltip:="")
{
    d := A_DetectHiddenWindows
    DetectHiddenWindows, On
    ; WM_SETICON = 0x0080
    If ( hIconSmall ) 
        SendMessage, 0x0080, 0, hIconSmall,, ahk_id %hWnd%
    If ( hIconBig )
        SendMessage, 0x0080, 1, hIconBig,, ahk_id %hWnd%
    DetectHiddenWindows, %d%

    VarSetCapacity(NID, szNID := ((A_IsUnicode ? 2 : 1) * 384 + A_PtrSize*5 + 40),0)
    NumPut( szNID, NID, 0             )
    NumPut( hWnd,  NID, A_PtrSize     )
    NumPut( uId,   NID, 2*A_PtrSize   )
    NumPut( 2,     NID, 2*A_PtrSize+4 )
    NumPut( hIcon, NID, 3*A_PtrSize+8 )
    StrPut(hTooltip, &NID+4*A_PtrSize+8, 128,0)

    ; NIM_MODIFY := 0x1
    Return DllCall("Shell32.dll\Shell_NotifyIcon", UInt,0x1, Ptr,&NID)
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_GetTrayBar
; Description ..: Get the tray icon handle.
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_GetTrayBar(Tray:="Shell_TrayWnd")
{
	DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
	WinGet, ControlList, ControlList, ahk_class %Tray%
	RegExMatch(ControlList, "(?<=ToolbarWindow32)\d+(?!.*ToolbarWindow32)", nTB)
	Loop, %nTB%
	{
		ControlGet, hWnd, hWnd,, ToolbarWindow32%A_Index%, ahk_class %Tray%
		hParent := DllCall( "GetParent", Ptr, hWnd )
		WinGetClass, sClass, ahk_id %hParent%
		If !(sClass = "SysPager" or sClass = "NotifyIconOverflowWindow" )
			Continue
		idxTB := A_Index
		Break
	}
	DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
	Return  idxTB
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_GetHotItem
; Description ..: Get the index of tray's hot item.
; Info .........: TB_GETHOTITEM message - http://goo.gl/g70qO2
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_GetHotItem()
{
	idxTB := TrayIcon_GetTrayBar()
	SendMessage, 0x447, 0, 0, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd ; TB_GETHOTITEM
	Return ErrorLevel << 32 >> 32
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_Button
; Description ..: Simulate mouse button click on a tray icon.
; Parameters ...: sExeName - Executable Process Name of tray icon.
; ..............: sButton  - Mouse button to simulate (L, M, R).
; ..............: bDouble  - True to double click, false to single click.
; ..............: index    - Index of tray icon to click if more than one match.
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_Button(sExeName, sButton := "L", bDouble := false, index := 1)
{
	DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
	WM_MOUSEMOVE	  = 0x0200
	WM_LBUTTONDOWN	  = 0x0201   ; 513
	WM_LBUTTONUP	  = 0x0202     ; 514
	WM_LBUTTONDBLCLK = 0x0203    ; 515
	WM_RBUTTONDOWN	  = 0x0204   ; 516
	WM_RBUTTONUP	  = 0x0205
	WM_RBUTTONDBLCLK = 0x0206    ; 520
	WM_MBUTTONDOWN	  = 0x0207
	WM_MBUTTONUP	  = 0x0208     ;
	WM_MBUTTONDBLCLK = 0x0209
	sButton := "WM_" sButton "BUTTON"
	oIcons := {}
	oIcons := TrayIcon_GetInfo(sExeName)
	msgID  := oIcons[index].msgID
	uID    := oIcons[index].uID
	hWnd   := oIcons[index].hWnd
	if bDouble
		PostMessage, msgID, uID, %sButton%DBLCLK, , ahk_id %hWnd%
	else
	{
		PostMessage, msgID, uID, %sButton%DOWN, , ahk_id %hWnd%
		PostMessage, msgID, uID, %sButton%UP, , ahk_id %hWnd%
	}
	DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
	return
}

;___________________________________________________________________
;;;; Tray.ahk v2.1 TrayIcon_Add 例子
/*
#singleinstance, force
		OnExit, OnExit
		Gui,  +LastFound +AlwaysOnTop Toolwindow
		hGui := WinExist()

		TrayIcon_Add(hGui, "OnTrayIcon", "shell32.dll:25", "a测试d信息1")
	return
 
	OnTrayIcon(Hwnd, Event){
	  	if (Event != "R")		;return if event is not right click
			return
 
		MsgBox, ,Icon %Hwnd%, %EVENT% Button clicked.
		;Tray_Focus(hGui, Hwnd)
	}

q:: TrayIcon_Remove(hGui, 101)

OnExit:
TrayIcon_Remove(hGui, 101)
ExitApp
return
*/
;___________________________________________________________________

;___________________________________________________________________
; 新添加 来自 majkinetor - Tray.ahk v2.1 中的一些函数(代码已被修改)
; 论坛帖子: https://autohotkey.com/board/topic/23741-module-tray-21/
; 原代码  : https://github.com/majkinetor/mm-autohotkey/tree/master/Tray
; 参考消息: https://docs.microsoft.com/zh-cn/windows/win32/shell/notification-area?redirectedfrom=MSDN

/*
https://docs.microsoft.com/en-us/windows/win32/api/shellapi/ns-shellapi-notifyicondataa
typedef struct _NOTIFYICONDATAA {
  DWORD cbSize;             #4  A_PtrSize
  HWND  hWnd;               #A_PtrSize
  UINT  uID;                #4
  UINT  uFlags;             #4
  UINT  uCallbackMessage;   #4  A_PtrSize
  HICON hIcon;              #A_PtrSize
#if ...
  CHAR  szTip[64];          #64*2
#else
  CHAR  szTip[128];         
#endif
  DWORD dwState;            #4
  DWORD dwStateMask;        #4
  CHAR  szInfo[256];        #256*2
  union {                   #4
    UINT uTimeout;          
    UINT uVersion;          
  } DUMMYUNIONNAME;
  CHAR  szInfoTitle[64];    #64*2
  DWORD dwInfoFlags;        #4


  GUID  guidItem;           #16
  HICON hBalloonIcon;       #A_PtrSize
} NOTIFYICONDATAA, *PNOTIFYICONDATAA;

typedef struct _NOTIFYICONDATA {
  DWORD cbSize;
  HWND  hWnd;
  UINT  uID;
  UINT  uFlags;
  UINT  uCallbackMessage;
  HICON hIcon;
  TCHAR szTip[64];
  DWORD dwState;
  DWORD dwStateMask;
  TCHAR szInfo[256];
  union {
    UINT uTimeout;
    UINT uVersion;
  };
  TCHAR szInfoTitle[64];
  DWORD dwInfoFlags;
  GUID  guidItem;
  HICON hBalloonIcon;
} NOTIFYICONDATA, *PNOTIFYICONDATA;

4+4+4+4+4+4+64+4+4+256+4+64+4+16+4=444
4+4+4+4+4+4+64*2+4+4+256*2+4+64*2+4+16+4=828

uFlags
NIF_MESSAGE  (0x00000001)  uCallbackMessage
NIF_ICON     (0x00000002)  hIcon
NIF_TIP      (0x00000004)  szTip
NIF_STATE    (0x00000008)  dwState and dwStateMask 
NIF_INFO     (0x00000010)  szInfo, szInfoTitle, dwInfoFlags, and uTimeout
NIF_GUID     (0x00000020)  guidItem
NIF_REALTIME (0x00000040)  
NIF_SHOWTIP  (0x00000080)

dwInfoFlags
NIIF_NONE (0x00000000)
NIIF_INFO (0x00000001)
NIIF_WARNING (0x00000002)
NIIF_ERROR (0x00000003)
NIIF_USER (0x00000004)
NIIF_NOSOUND (0x00000010)
NIIF_LARGE_ICON (0x00000020)
NIIF_RESPECT_QUIET_TIME (0x00000080)
NIIF_ICON_MASK (0x0000000F)
*/

/*
https://docs.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shell_notifyicona
Shell_NotifyIcon
NIM_ADD (0x00000000)
NIM_MODIFY (0x00000001)
NIM_DELETE (0x00000002)
NIM_SETFOCUS (0x00000003)
NIM_SETVERSION (0x00000004)
*/

; ----------------------------------------------------------------------------------------------------------------------
/*Function:		Add
 				Add icon in the system tray.
 
  Parameters:
 				hGui	- Handle of the parent window.
 				Handler	- Notification handler.
 				Icon	- Icon path or handle. Icons allocated by module will be automatically destroyed when <Remove> function
 						  returns. If you pass icon handle, <Remove> will not destroy it. If path is an icon resource, you can 
						  use "path:idx" notation to get the handle of the desired icon by its resource index (0 based).
 				Tooltip	- Tooltip text.
 
  Notifications:
 >				Handler(Hwnd, Event)
 
 				Hwnd	- Handle of the tray icon.
 				Event	- L (Left click), R(Right click), M (Middle click), P (Position - mouse move).
		 				  Additionally, "u" or "d" can follow event name meaning "up" and "doubleclick".
 						  For example, you will be notified on "Lu" when user releases the left mouse button.
 				
  Returns:
 				0 on failure, handle on success.
 */
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_Add( hGui, Handler, Icon, Tooltip="") {
	static NIF_ICON=2, NIF_MESSAGE=1, NIF_TIP=4, MM_SHELLICON := 0x500
	static uid=100, hFlags

	if !hFlags
		OnMessage( MM_SHELLICON, "TrayIcon_onShellIcon" ), hFlags := NIF_ICON | NIF_TIP | NIF_MESSAGE 

	if !IsFunc(Handler)
		return A_ThisFunc "> Invalid handler: " Handler

	hIcon := Icon/Icon ? Icon : TrayIcon_loadIcon(Icon, 32)

	VarSetCapacity( NID, (A_IsUnicode ? 2 : 1) * 384 + A_PtrSize * 5 + 40, 0) 
	 ,NumPut((A_IsUnicode ? 2 : 1) * 384 + A_PtrSize * 5 + 40,	NID)
	 ,NumPut(hGui,	NID, A_PtrSize)
	 ,NumPut(++uid,	NID, 2*A_PtrSize)
	 ,NumPut(hFlags, NID, 2*A_PtrSize+4)
	 ,NumPut(MM_SHELLICON, NID, 2*A_PtrSize+8)
	 ,NumPut(hIcon, NID, 3*A_PtrSize+8)
	 ,StrPut(Tooltip, &NID+4*A_PtrSize+8, 128,0)

	if !DllCall("shell32.dll\Shell_NotifyIcon", "uint", 0, "uint", &NID)
		return 0

	TrayIcon_staticValue( uid "handler", Handler)
	;Icon/Icon ? "" : TrayIcon_staticValue( uid "hIcon", hIcon) ; save icon handle allocated by Tray module so icon can be destroyed.
	return uid
}

TrayIcon_loadIcon(pPath, pSize=32){
	j := InStr(pPath, ":", 0, 0), idx := 0
	if j > 2
		idx := Substr( pPath, j+1), pPath := SubStr( pPath, 1, j-1)

	DllCall("PrivateExtractIcons"
            ,"str",pPath,"int",idx,"int",pSize,"int", pSize
            ,"uint*",hIcon,"uint*",0,"uint",1,"uint",0,"int")

	return hIcon
}

TrayIcon_onShellIcon(Wparam, Lparam) {
	static EVENT_512="P", EVENT_513="L", EVENT_514="Lu", EVENT_515="Ld", EVENT_516="R", EVENT_517="Ru", EVENT_518="Rd", EVENT_519="M", EVENT_520="Mu", EVENT_521="Md"

	;wparam = uid, ; msg = lparam loword
	handler := TrayIcon_staticValue(Wparam "handler")  ,event := (Lparam & 0xFFFF)
	return %handler%(Wparam, EVENT_%event%)
}

TrayIcon_staticValue(var="", value="☆") { 
	static
	_ := %var%
	ifNotEqual, value,☆, SetEnv, %var%, %value%
	return _
}

TrayIcon_Focus(hGui="", huid="") {
	VarSetCapacity(NID, szNID := ((A_IsUnicode ? 2 : 1) * 384 + A_PtrSize*5 + 40),0)
	NumPut( szNID, NID, 0             )
	NumPut( hWnd,  NID, A_PtrSize     )
	NumPut( uId,   NID, 2*A_PtrSize   )
	DllCall("shell32.dll\Shell_NotifyIconA", "uint", 0x3, "uint", &NID)
}