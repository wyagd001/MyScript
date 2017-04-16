;#IfWinActive ahk_group ExplorerGroup
;+c::
return
文件追加到剪贴板复制:
if (InFileList() && !IsRenaming())
{
files := GetSelectedFiles()
if(files)
	AppendToClipboard(files)
}
else
	Send +{c}
return

;+X::
文件追加到剪贴板剪切:
if (InFileList() && !IsRenaming())
{
files := GetSelectedFiles()
if(files)
	AppendToClipboard(files,1)
}
else
	Send +{x}
return
;#IfWinActive

;Appends files to CF_HDROP structure in clipboard
AppendToClipboard( files, cut=0) {
	DllCall("OpenClipboard", "Uint", 0)
	if(DllCall("IsClipboardFormatAvailable", "Uint", 1))
		DllCall("EmptyClipboard")
	DllCall("CloseClipboard")
	txt:=clipboard (clipboard = "" ? "" : "`r`n") files
	Sort, txt , U
	DllCall("OpenClipboard", "Uint", 0)
	CopyToClipboard(txt, true, cut)
	DllCall("CloseClipboard")
	return
}

;Copies a list of files (separated by new line) to the clipboard so they can be pasted in explorer
CopyToClipboard(files, clear, cut=0){
	CF_HDROP = 0xF
	FileCount:=0
	PathLength:=0
	; Rows are delimited by linefeeds (`r`n).
	Loop, Parse, files, `n,`r
	{
		FileCount++
		PathLength+=StrLen(A_LoopField)
	}
	; Copy image file - CF_HDROP
	pid:=DllCall("GetCurrentProcessId","Uint")
	hwnd:=WinExist("ahk_pid " . pid)
	DllCall("OpenClipboard", "Uint", hwnd)
	; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
	hPath := DllCall("GlobalAlloc", "uint", 0x42, "uint", PathLength+FileCount+22)
	pPath := DllCall("GlobalLock", "uint", hPath)
	; Lock the moveable memory, retrieving a pointer to it.
	NumPut(20, pPath+0), pPath += 20
	; DROPFILES.pFiles = offset of file list
  Offset:=0
  Offset:=0
  Loop, Parse, files, `n,`r  ; Rows are delimited by linefeeds (`r`n).
		DllCall("lstrcpy", "uint", pPath+offset, "str", A_LoopField)    ; Copy the file into moveable memory.
			, offset+=StrLen(A_LoopField)+1
  DllCall("GlobalUnlock", "uint", hPath)
	if clear
	{
  	DllCall("EmptyClipboard")                                                              ; Empty the clipboard, otherwise SetClipboardData may fail.
  	Clipwait, 1, 1
  }
  result:=DllCall("SetClipboardData", "uint", CF_HDROP, "uint", hPath) ; Place the data on the clipboard. CF_HDROP=0xF
	Clipwait, 1, 1
 	mem := DllCall("GlobalAlloc","UInt",2,"UInt",4)
  str := DllCall("GlobalLock","UInt",mem)
  if(!cut)
     DllCall("RtlFillMemory","UInt",str,"UInt",1,"UChar",0x05)
  else
     DllCall("RtlFillMemory","UInt",str,"UInt",1,"UChar",0x02)
  DllCall("RtlZeroMemory","UInt",str + 1,"UInt",1)
  DllCall("RtlZeroMemory","UInt",str + 2,"UInt",1)
  DllCall("RtlZeroMemory","UInt",str + 3,"UInt",1)
  DllCall("GlobalUnlock","UInt",mem)

  cfFormat := DllCall("RegisterClipboardFormat","Str","Preferred DropEffect")
  result:=DllCall("SetClipboardData","UInt",cfFormat,"UInt",mem)
  Clipwait, 1, 1
	DllCall("CloseClipboard")
	return
}