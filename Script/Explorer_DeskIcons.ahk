; "DeskIcons.ahk"
; Updated to be x86 and x64 compatible by Joe DF
; Revision Date : 22:13 2014/05/09
; From : Rapte_Of_Suzaku
; http://www.autohotkey.com/board/topic/60982-deskicons-getset-desktop-icon-positions/
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=3529

/*
   Save and Load desktop icon positions
   based on save/load desktop icon positions by temp01 (http://www.autohotkey.com/forum/viewtopic.php?t=49714)

   Example:
      ; save positions
      coords := DeskIcons()
      MsgBox now move the icons around yourself
      ; load positions
      DeskIcons(coords)

   Plans:
      handle more settings (icon sizes, sort order, etc)
         - http://msdn.microsoft.com/en-us/library/ff485961%28v=VS.85%29.aspx

*/

/*
删除图标无影响
快捷方式改名/新建  有影响
*/

SaveDesktopIconsPositions:
	if Timer_SDIP
	{
		SetTimer, SaveDesktopIconsPositions, Off
		Timer_SDIP := 0
	}
	coords := DeskIcons()
	if (coords = "")
	{
		;MsgBox, 无法保存桌面图标，请重试！
	Return
	}
	FileRead, FileR_coords, %SaveDeskIcons_inifile%
 
	if (FileR_coords != coords)
	{
		if 每隔几小时结果为真(12)
			FileAppend, %FileR_coords%, *%A_ScriptDir%\settings\tmp\SaveDeskIcons_%A_Now%.ini, UTF-16
		FileDelete, %SaveDeskIcons_inifile%
		FileAppend, %coords%, *%SaveDeskIcons_inifile%, UTF-16
	}

	FileR_coords := coords := ""
	IfExist, %SaveDeskIcons_inifile%
	{
		Menu, addf, Enable, 恢复桌面图标
	}
	Else
		MsgBox, 保存桌面图标出现错误，请重试！
Return

RestoreDesktopIconsPositions:
	FileRead, FileR_coords, %SaveDeskIcons_inifile%
	if (FileR_coords != "")
	{
		DeskIcons(FileR_coords)
		FileR_coords := ""
	}
	Else
		MsgBox, 没有读取到配置文件，请保存桌面图标后，再重试。
Return

DeskIcons(coords := "")
{
	Critical
	static MEM_COMMIT := 0x1000, PAGE_READWRITE := 0x04, MEM_RELEASE := 0x8000
	static LVM_GETITEMPOSITION := 0x00001010, LVM_SETITEMPOSITION := 0x0000100F, WM_SETREDRAW := 0x000B

	BackUp_DetectHiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows, Off
	ControlGet, hwWindow, HWND,, SysListView321, ahk_class Progman
	if !hwWindow ; #D mode
	{
		;MsgBox,,,请点击桌面空白处完成保存桌面的操作,2
		;WinWaitActive,ahk_class WorkerW
		ControlGet, hwWindow, HWND,, SysListView321, ahk_class WorkerW
	}
	IfWinExist ahk_id %hwWindow% ; last-found window set
		WinGet, iProcessID, PID
	hProcess := DllCall("OpenProcess"   , "UInt",   0x438         ; PROCESS-OPERATION|READ|WRITE|QUERY_INFORMATION
                              , "Int",   FALSE         ; inherit = false
                              , "Ptr",   iProcessID)
	if hwWindow and hProcess
	{
		ControlGet, list, list, Col1  ; 第1列 名称
		ControlGet, list2, list, Col3 ; 第2列 大小 第3列 项目类型
		Loop, Parse, list2, `n
		{
			filetype_%A_Index% := SubStr(A_LoopField, 1)
			filetype_%A_Index% := StrReplace(filetype_%A_Index%, " ")
		}

		if !coords
		{
			VarSetCapacity(iCoord, A_PtrSize * 2)
			pItemCoord := DllCall("VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "UInt", 8, "UInt", MEM_COMMIT, "UInt", PAGE_READWRITE)
			Loop, Parse, list, `n
			{
				SendMessage, %LVM_GETITEMPOSITION%, % A_Index-1, %pItemCoord%
				DllCall("ReadProcessMemory", "Ptr", hProcess, "Ptr", pItemCoord, "UInt" . (A_PtrSize == 8 ? "64" : ""), &iCoord, "UInt", A_PtrSize * 2, "UIntP", cbReadWritten)
				iconid := A_LoopField . "(" . filetype_%A_Index% . ")"
				ret .= iconid ":" (NumGet(iCoord,"Int") & 0xFFFF) | ((Numget(iCoord, 4,"Int") & 0xFFFF) << 16) "`n"
			}
			DllCall("VirtualFreeEx", "Ptr", hProcess, "Ptr", pItemCoord, "Ptr", 0, "UInt", MEM_RELEASE)
		}
		else
		{
			SendMessage, %WM_SETREDRAW%, 0, 0
			Loop, Parse, list, `n
			{
				iconid := A_LoopField . "(" . filetype_%A_Index% . ")"
				If RegExMatch(coords, "\Q" iconid "\E:\K.*", iCoord_new)
					SendMessage, %LVM_SETITEMPOSITION%, % A_Index-1, %iCoord_new%
			}
			SendMessage, %WM_SETREDRAW%, 1, 0
			ret := true
		}
	}
	DllCall("CloseHandle", "Ptr", hProcess)
	DetectHiddenWindows, % BackUp_DetectHiddenWindows
	Critical, Off
return ret
}