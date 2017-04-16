;http://www.autohotkey.com/forum/topic68446.html

;在资源管理器中与左键点击关闭按钮冲突

#ifwinexist, ahk_class #32768   ;右键菜单
~lbutton::
ContextMenCnt := DllCall("GetMenuItemCount", "Uint", hMenu)

  ;TooltipText =
  ;Read info for each menu item
loop, %ContextMenCnt%
{
   idx := A_Index - 1

   IsEnabled := GetContextMenuState(hMenu, idx)

   idn := DllCall("GetMenuItemID", "Uint", hMenu, "int", idx)
   nSize++ := DllCall("GetMenuString", "Uint", hMenu, "int", idx, "Uint", 0, "int", 0, "Uint", 0x400)
   nSize := (nSize * (A_IsUnicode ? 2 : 1))
   VarSetCapacity(sString, nSize)
   DllCall("GetMenuString", "Uint", hMenu, "int", idx, "str", sString, "int", nSize, "Uint", 0x400)   ;MF_BYPOSITION
;~        CurrentText =
;~        if IsEnabled = 0
;~         CurrentText = %CurrentText% Enabled
;~        if (IsEnabled & MFS_CHECKED)
;~           CurrentText = %CurrentText% Checked
;~        if (IsEnabled & MFS_DEFAULT)
;~           CurrentText = %CurrentText% Default
;~        if (IsEnabled & MFS_DISABLED)
;~           CurrentText = %CurrentText% Disabled
;~        if (IsEnabled & MFS_GRAYED)
;~           CurrentText = %CurrentText% Grayed
   if (IsEnabled & MFS_HILITE) {
      If (sString="粘贴并打开") {
        ; tooltip,%sString%
         ;controlfocus,Edit1
         ;controlfocus,Edit1,A
         sleep,200
         sendevent,{del}{ctrldown}v{ctrlup}{enter}
         sleep,200
         ;tooltip
         sString =
        Return 
      }
   }

}
return
#ifwinexist
;#IfWinActive

addmenuitem:
      ;settimer, reactivate, -300
clsn:=WinGetClass2(hWndnow)
WinGet, active_id, ID, A
wingetclass, act_class,ahk_id %active_id%
;in 不能用于表达式中
if act_class in CabinetWClass,IEframe
{
 if(clsn="edit"){
   ;tooltip % act_class
   STR_TEST := "粘贴并打开"
   Position=1 ; top position
   uFlags:=0x40 ;pop menu
   uIDNewItem=0x1001
   WinWait, ahk_class #32768
   SendMessage, 0x1E1, 0, 0      ; MN_GETHMENU
   hMenu := ErrorLevel
         ;Result := DllCall("AppendMenu", Int,hMenu, Int,uFlags, Int,uIDNewItem, Str,STR_TEST)
   hMenuItem := DllCall("GetMenuItemID", "uint", hMenu, "int", MenuItemIndex - 1)
   DllCall("InsertMenu", "int", hMenu, "int", Position - 1 , "int", 0x400, "int", uIDNewItem, "int", &STR_TEST)
 }
}
return


HookProcMenu( hWinEventHook, Event, hWnd, idObject, idChild, dwEventThread, dwmsEventTime )
{
   global namcls, hwndNow
   wingetclass, namcls, ahk_id %hwnd%
   if (Event=0x4 )     {
      hwndNow:=hwnd
      gosub,addmenuitem
   }

}

HookProc(hWinEventHook2, Event, hWnd)
{
   global ShutdownBlock
   static hShutdownDialog
   Event += 0
   if Event = 8 ; EVENT_SYSTEM_CAPTURESTART
   {
      WinGetClass, Class, ahk_id %hWnd%
      WinGetTitle, Title, ahk_id %hWnd%
      if (Class = "Button" and Title = "确定")
      {
         ControlGet, Choice, Choice, , ComboBox1, ahk_id %hShutdownDialog%
         if Choice in 注销,重新启动,关机,Install updates and shut down
            ShutdownBlock := false
      }
   }
   else if Event = 16 ; EVENT_SYSTEM_DIALOGSTART
   {
      WinGetClass, Class, ahk_id %hWnd%
      WinGetTitle, Title, ahk_id %hWnd%
      if (Class = "#32770" and Title = "关闭 Windows")
         hShutdownDialog := hWnd
   }
   else if Event = 17 ; EVENT_SYSTEM_DIALOGEND
      hShutdownDialog =
}

WinGetClass2( hwnd )
{
   WinGetClass, wclass, ahk_id %hwnd%
   Return wclass
}


SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags)
{
   ;DllCall("CoInitialize", Uint, 0)  ;以单线程的方式创建com对象,COM库初始化,L 版默认开启
   return DllCall("SetWinEventHook"
   , Uint,eventMin
   , Uint,eventMax
   , Uint,hmodWinEventProc
   , Uint,lpfnWinEventProc
   , Uint,idProcess
   , Uint,idThread
   , Uint,dwFlags)
}

UnhookWinEvent()
{
   Global
   QQ:=DllCall( "UnhookWinEvent", Uint,hWinEventHook )
   qw:=DllCall( "GlobalFree", UInt,HookProcAdr ) ; free up allocated memory for RegisterCallback
;tooltip % "成功为0：" qw
   ;DllCall( "UnhookWinEvent", Uint,hWinEventHook2 )
   ;DllCall( "GlobalFree", UInt,&HookProcAdr2 )  
;&HookProcAdr 引发程序异常退出  改为 HookProcAdr不知道是否有同样效用
}



/***************************************************************
* returns the state of a menu entry
***************************************************************
*/
GetContextMenuState(hMenu, Position)
{
  ;We need to allocate a struct
   VarSetCapacity(MenuItemInfo, 60, 0)
  ;Set Size of Struct to the first member
   InsertInteger(48, MenuItemInfo, 0, 4)
  ;Get only Flags from dllcall GetMenuItemInfo MIIM_TYPE = 1
   InsertInteger(1, MenuItemInfo, 4, 4)

  ;GetMenuItemInfo: Handle to Menu, Index of Position, 0=Menu identifier / 1=Index
   InfoRes := DllCall("user32.dll\GetMenuItemInfo",UInt,hMenu, Uint, Position, uint, 1, "int", &MenuItemInfo)

   InfoResError := errorlevel
   LastErrorRes := DllCall("GetLastError")
   if InfoResError <> 0
   return -1
   if LastErrorRes != 0
   return -1

  ;Get Flag from struct
   GetMenuItemInfoRes := ExtractInteger(MenuItemInfo, 12, false, 4)
   /*
   IsEnabled = 1
   if GetMenuItemInfoRes > 0
   IsEnabled = 0
   return IsEnabled
   */
   return GetMenuItemInfoRes
}
ExtractInteger(ByRef pSource, pOffset = 0, pIsSigned = false, pSize = 4)
; pSource is a string (buffer) whose memory area contains a raw/binary integer at pOffset.
; The caller should pass true for pSigned to interpret the result as signed vs. unsigned.
; pSize is the size of PSource's integer in bytes (e.g. 4 bytes for a DWORD or Int).
; pSource must be ByRef to avoid corruption during the formal-to-actual copying process
; (since pSource might contain valid data beyond its first binary zero).
{
   SourceAddress := &pSource + pOffset  ; Get address and apply the caller's offset.
   result := 0  ; Init prior to accumulation in the loop.
   Loop %pSize%  ; For each byte in the integer:
   {
      result := result | (*SourceAddress << 8 * (A_Index - 1))  ; Build the integer from its bytes.
      SourceAddress += 1  ; Move on to the next byte.
   }
   if (!pIsSigned OR pSize > 4 OR result < 0x80000000)
   return result  ; Signed vs. unsigned doesn't matter in these cases.
   ; Otherwise, convert the value (now known to be 32-bit) to its signed counterpart:
   return -(0xFFFFFFFF - result + 1)
}
InsertInteger(pInteger, ByRef pDest, pOffset = 0, pSize = 4)
; To preserve any existing contents in pDest, only pSize number of bytes starting at pOffset
; are altered in it. The caller must ensure that pDest has sufficient capacity.
{
   mask := 0xFF  ; This serves to isolate each byte, one by one.
   Loop %pSize%  ; Copy each byte in the integer into the structure as raw binary data.
   {
      DllCall("RtlFillMemory", UInt, &pDest + pOffset + A_Index - 1, UInt, 1  ; Write one byte.
      , UChar, (pInteger & mask) >> 8 * (A_Index - 1))  ; This line is auto-merged with above at load-time.
      mask := mask << 8  ; Set it up for isolation of the next byte.
   }
}
; *********************************
; *********************************