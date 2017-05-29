; https://github.com/7plus/7plus/blob/master/Clipboard.ahk
; 快捷键定义在 ahk_group ExplorerGroup 资源管理器中有效，桌面无效，
; 按下快捷键后可能要"刷新",刷新使“粘贴”菜单生效
; 有时会失败，失败后复制任意文字后重试
;#IfWinActive ahk_group ExplorerGroup
;+c::
文件追加到剪贴板之复制:
	If (InFileList() && !IsRenaming())
	{
		files := GetSelectedFiles()
		If(files)
		{
			AppendToClipboard(files)
			TrayTip, 追加复制到剪贴板,%files%`n已经追加复制到剪贴板。
			SetTimer, RemoveTrayTip, 3000
		}
}
	Else
		Send % A_ThisHotkey
Return

;+X::
文件追加到剪贴板之剪切:
	If (InFileList() && !IsRenaming())
	{
		files := GetSelectedFiles()
		If(files)
		{
			AppendToClipboard(files,1)
			TrayTip, 追加剪切到剪贴板,%files%`n已经追加剪切到剪贴板。
			SetTimer, RemoveTrayTip, 3000
		}
	}
	Else
		Send % A_ThisHotkey
Return
;#IfWinActive

;Appends files to CF_HDROP structure in clipboard
AppendToClipboard( files, cut=0) {
	DllCall("OpenClipboard", "Ptr", 0)
	If(DllCall("IsClipboardFormatAvailable", "Uint", 1))
		DllCall("EmptyClipboard")
	DllCall("CloseClipboard")
	txt:=clipboard (clipboard = "" ? "" : "`n") files
	Sort, txt , U
	CopyToClipboard(txt, true, cut)
	DllCall("CloseClipboard")
	Return
}

;Copies a list of files (separated by new line) to the clipboard so they can be pasted in explorer
/* Example clipboard data:
00000000   14 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
00000010   01 00 00 00 43 00 3A 00 5C 00 62 00 6F 00 6F 00    ....C.:.\.b.o.o.				<-- I believe the 01 byte at the start of this line could indicate unicode?
00000020   74 00 6D 00 67 00 72 00 00 00 43 00 3A 00 5C 00    t.m.g.r...C.:.\.
00000030   62 00 6C 00 61 00 2E 00 6C 00 6F 00 67 00 00 00    b.l.a...l.o.g...
00000040   00 00                                             										..     

typedef struct _DROPFILES {
  DWORD pFiles;
  POINT pt;
  BOOL  fNC;
  BOOL  fWide;
} DROPFILES, *LPDROPFILES;
_DROPFILES struct: 20 characters at the start
null-terminated filename list, and double-null termination at the end
*/

; Copies a list of files (separated by new line) to the clipboard so they can be pasted in explorer
CopyToClipboard(files, clear, cut=0){
	static CF_HDROP := 0xF
	FileCount:=0
	PathLength:=0
	; Count files and total string length
	; Rows are delimited by linefeeds (`r`n).
	Loop, Parse, files, `n,`r
	{
		FileCount++
		PathLength+=StrLen(A_LoopField)
	}
	pid:=DllCall("GetCurrentProcessId","Uint")
	hwnd:=WinExist("ahk_pid " . pid)
	DllCall("OpenClipboard", "Ptr", hwnd)
	; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
	hPath := DllCall("GlobalAlloc", "uint", 0x42, "uint", 20 + (PathLength + FileCount + 1) * 2, "Ptr")
	pPath := DllCall("GlobalLock", "Ptr", hPath)
	; Lock the moveable memory, retrieving a pointer to it.
	NumPut(20, pPath+0), pPath += 16 ; DROPFILES.pFiles = offset of file list
	NumPut(1, pPath+0), pPath += 4 ;fWide = 0 -->ANSI, fWide = 1 -->Unicode
  Offset:=0
  Loop, Parse, files, `n,`r  ; Rows are delimited by linefeeds (`r`n).
		offset += StrPut(A_LoopField, pPath+offset,StrLen(A_LoopField)+1,"UTF-16") * 2
  DllCall("GlobalUnlock", "Ptr", hPath)
	; hPath must not be freed! ->http://msdn.microsoft.com/en-us/library/ms649051(VS.85).aspx
	If clear
	{
  	DllCall("EmptyClipboard")                                                              ; Empty the clipboard, otherwise SetClipboardData may fail.
  	Clipwait, 1, 1
  }
  result:=DllCall("SetClipboardData", "uint", CF_HDROP, "Ptr", hPath) ; Place the data on the clipboard. CF_HDROP=0xF
	Clipwait, 1, 1
	; Write Preferred DropEffect structure to clipboard to switch between copy/cut operations
 	mem := DllCall("GlobalAlloc","UInt",0x42,"UInt",4, "Ptr") ; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
  str := DllCall("GlobalLock","Ptr",mem)
  If(!cut)
     DllCall("RtlFillMemory","UInt",str,"UInt",1,"UChar",0x05)
  Else
     DllCall("RtlFillMemory","UInt",str,"UInt",1,"UChar",0x02)
	DllCall("GlobalUnlock","Ptr",mem)
	cfFormat := DllCall("RegisterClipboardFormat","Str","Preferred DropEffect") 
	result:=DllCall("SetClipboardData","UInt",cfFormat,"Ptr",mem)
	Clipwait, 1, 1
	DllCall("CloseClipboard")
	; mem must not be freed! ->http://msdn.microsoft.com/en-us/library/ms649051(VS.85).aspx
	Return
}