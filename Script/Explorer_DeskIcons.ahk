; "DeskIcons.ahk"
; Updated to be x86 and x64 compatible by Joe DF
; Revision Date : 22:13 2014/05/09
; From : Rapte_Of_Suzaku
; http://www.autohotkey.com/board/topic/60982-deskicons-getset-desktop-icon-positions/


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
	coords := DeskIcons()
    if (coords = "")
    {
    MsgBox,无法保存桌面图标，请重试！
    Return
    }
FileRead, read_coords, %SaveDeskIcons_inifile%

if(read_coords!= coords)
FileAppend, %read_coords%,*%A_ScriptDir%\settings\tmp\SaveDeskIcons_%A_Now%.ini

	FileDelete,%SaveDeskIcons_inifile%
    FileAppend, %coords%,*%SaveDeskIcons_inifile%
    read_coords:=coords:=""
    IfExist,%SaveDeskIcons_inifile%
    Menu, addf, Enable,  恢复桌面图标
    Else
    MsgBox,保存桌面图标出现错误，请重试！
Return

SaveDesktopIconsPositionsDelay:
coords := DeskIcons()
if (coords = "")
    {
    MsgBox,无法保存桌面图标，请重试！
    SetTimer,SaveDesktopIconsPositionsdelay,Off
    Return
    }
FileRead, read_coords, %SaveDeskIcons_inifile%

if(read_coords!= coords)
FileAppend, %read_coords%,*%A_ScriptDir%\settings\tmp\SaveDeskIcons_%A_Now%.ini

FileDelete,%SaveDeskIcons_inifile%
FileAppend, %coords%,*%SaveDeskIcons_inifile%
read_coords:=coords:=""
Critical,Off
IfExist,%SaveDeskIcons_inifile%
{
Menu, addf, Enable,  恢复桌面图标
SetTimer,SaveDesktopIconsPositionsdelay,Off
}
Return

RestoreDesktopIconsPositions:
FileRead, coords,%SaveDeskIcons_inifile%
if (coords != "")
DeskIcons(coords)
Else
MsgBox,没有读取到配置文件，请保存桌面图标后，再重试。
coords=
Return

DeskIcons(coords="")
{
   Critical
   static MEM_COMMIT := 0x1000, PAGE_READWRITE := 0x04, MEM_RELEASE := 0x8000
   static LVM_GETITEMPOSITION := 0x00001010, LVM_SETITEMPOSITION := 0x0000100F, WM_SETREDRAW := 0x000B

   ControlGet, hwWindow, HWND,, SysListView321, ahk_class Progman
   if !hwWindow ; #D mode
      {
      DetectHiddenWindows,Off
      ;MsgBox,,,请点击桌面空白处完成保存桌面的操作,2
      ;WinWaitActive,ahk_class WorkerW
      ControlGet, hwWindow, HWND,, SysListView321, ahk_class WorkerW
      DetectHiddenWindows,On
      }
   IfWinExist ahk_id %hwWindow% ; last-found window set
      WinGet, iProcessID, PID
   hProcess := DllCall("OpenProcess"   , "UInt",   0x438         ; PROCESS-OPERATION|READ|WRITE|QUERY_INFORMATION
                              , "Int",   FALSE         ; inherit = false
                              , "UInt",   iProcessID)
   if hwWindow and hProcess
   {
      ControlGet, list, list,Col1
      if !coords
      {
         VarSetCapacity(iCoord, 8)
         pItemCoord := DllCall("VirtualAllocEx", "UInt", hProcess, "UInt", 0, "UInt", 8, "UInt", MEM_COMMIT, "UInt", PAGE_READWRITE)
         Loop, Parse, list, `n
         {
            SendMessage, %LVM_GETITEMPOSITION%, % A_Index-1, %pItemCoord%
            DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", pItemCoord, "UInt", &iCoord, "UInt", 8, "UIntP", cbReadWritten)
            ret .= A_LoopField ":" (NumGet(iCoord) & 0xFFFF) | ((Numget(iCoord, 4) & 0xFFFF) << 16) "`n"
         }
         DllCall("VirtualFreeEx", "UInt", hProcess, "UInt", pItemCoord, "UInt", 0, "UInt", MEM_RELEASE)
      }
      else
      {
         SendMessage, %WM_SETREDRAW%,0,0
         Loop, Parse, list, `n
            If RegExMatch(coords,"\Q" A_LoopField "\E:\K.*",iCoord_new)
               SendMessage, %LVM_SETITEMPOSITION%, % A_Index-1, %iCoord_new%
         SendMessage, %WM_SETREDRAW%,1,0
         ret := true
      }
   }
   DllCall("CloseHandle", "UInt", hProcess)
   return ret
}