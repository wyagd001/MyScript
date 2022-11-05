; Explorer Windows Manipulations - Sean
; http://www.autohotkey.com/forum/topic20701.html
; 7plus - fragman
; http://code.google.com/p/7plus/
; https://github.com/7plus/7plus

GetCurrentFolder()
{
	global MuteClipboardList, newfolder
	newfolder =
	If WinActive("ahk_group ccc")
	{
		isdg := IsDialog()
		If (isdg = 0)
			Return ShellFolder(, 1)
		Else If (isdg = 1) ; No Support for old dialogs for now
		{
			ControlGetText, text, ToolBarWindow322, A
			dgpath := SubStr(text, InStr(text, " "))
			dgpath = %dgpath%
			Return dgpath
		}
		Else If (isdg = 2)
		{
			newfolder = types2
			Return 0
		}
	}
	Return 0
}

ShellNavigate(sPath, bExplore=False, hWnd=0)
{
	If (window := Explorer_GetWindow(hwnd))
	{
		if !InStr(sPath, "#")  ; 排除特殊文件名
		{
			window.Navigate2(sPath) ; 当前资源管理器窗口切换到指定目录
		}
		else ; https://www.autohotkey.com/boards/viewtopic.php?f=5&t=526&p=153676#p153676
		{
			DllCall("shell32\SHParseDisplayName", WStr, sPath, Ptr,0, PtrP, vPIDL, UInt, 0, Ptr, 0)
			VarSetCapacity(SAFEARRAY, A_PtrSize=8?32:24, 0)
			NumPut(1, SAFEARRAY, 0, "UShort") ;cDims
			NumPut(1, SAFEARRAY, 4, "UInt") ;cbElements
			NumPut(vPIDL, SAFEARRAY, A_PtrSize=8?16:12, "Ptr") ;pvData
			NumPut(DllCall("shell32\ILGetSize", Ptr, vPIDL, UInt), SAFEARRAY, A_PtrSize=8?24:16, "Int") ;rgsabound[1]
			window.Navigate2(ComObject(0x2011, &SAFEARRAY))
			DllCall("shell32\ILFree", Ptr, vPIDL)
		}
	}
	Else If bExplore
		ComObjCreate("Shell.Application").Explore[sPath]  ; 新窗口打开目录(带左侧导航SysTreeView321控件)
	Else ComObjCreate("Shell.Application").Open[sPath]  ; 新窗口打开目录
}

/*
Returntype=1 当前文件夹
Returntype=2 具有焦点的选中项
Returntype=3 所有选中项
Returntype=4 当前文件夹下所有项目
*/
ShellFolder(hWnd=0, returntype=1, onlyname=0)
{
	If !(window := Explorer_GetWindow(hwnd))
		Return 0
	If (window = "desktop")
	{
		If (returntype = 1)
		return A_Desktop
		If (returntype = 2) or (returntype=3)
			selection=1
		If (returntype = 4)
			selection=0

		ControlGet, hwWindow, HWND,, SysListView321, ahk_class Progman  ; 桌面文件夹区别对待
		If !hwWindow ; #D mode
			ControlGet, hwWindow, HWND, , SysListView321, A
		ControlGet, files, List, % (selection ? "Selected":"") "Col1", , ahk_id %hwWindow%
		;base := SubStr(A_Desktop, 0, 1)=="\" ? SubStr(A_Desktop, 1, -1) : A_Desktop
		Loop, Parse, files, `n, `r
		{
			hpath := A_Desktop "\" A_LoopField
			hpath2 := A_DesktopCommon "\" A_LoopField
			IfExist %hpath% ; ignore special icons like Computer (at least for now)
				ret .= !onlyname?hpath:A_LoopField "`n"
			else IfExist %hpath%.lnk
				ret .= !onlyname?hpath:A_LoopField ".lnk`n"
			else IfExist %hpath2%
				ret .= !onlyname?hpath2:A_LoopField "`n"
			else IfExist %hpath2%.lnk
				ret .= !onlyname?hpath2:A_LoopField ".lnk`n"
		}
	Return Trim(ret,"`n")
	}
	Else
	{
		; Find hwnd window
		doc := window.Document
		If (returntype = 1)
		{
			sFolder := doc.Folder.Self.path
			If onlyname
				sFolder := doc.Folder.Self.name
		}
		If (returntype = 2)
		{
			sFocus :=doc.FocusedItem.Path
			If onlyname
				SplitPath, sFocus , sFocus
		}
		If(returntype = 3)
		{
			collection := doc.SelectedItems
			for item in collection
			{
				hpath :=  item.path
				If onlyname
					SplitPath, hpath , hpath
				sSelect .=hpath "`n"
			}
			StringReplace, sSelect, sSelect, \\ , \, 1
		}
		If(returntype = 4)
		{
			collection := doc.Folder.Items
			for item in collection
			{
				hpath :=  item.path
				If onlyname
					SplitPath, hpath , hpath
				sSelect .= hpath "`n"
			}
		}
		sSelect:=Trim(sSelect, "`n")
		If (returntype = 1)
			Return   sFolder
		Else If (returntype = 2)
			Return   sFocus
		Else If (returntype = 3)
			Return   sSelect
		Else If (returntype = 4)
			Return sSelect
	}
}

File_OpenAndSelect(sFullPath)
{
	SplitPath sFullPath, , sPath
	FolderPidl := DllCall("shell32\ILCreateFromPath", "Str", sPath)
	; QtTabBar 使用 explorer /select, %sFullPath%, explorer %sFullPath% 会打开新窗口
	run %sPath%  ; 用标签页打开目录后, 选择才能快速结束,否则下面的SHOpenFolderAndSelectItems可能会卡住(安装QtTabBar)
	sleep 200
	DllCall("shell32\SHParseDisplayName", "str", sFullPath, "Ptr", 0, "Ptr*", ItemPidl, "Uint", 0, "Uint*", 0)
	DllCall("shell32\SHOpenFolderAndSelectItems", "Ptr", FolderPidl, "UInt", 1, "Ptr*", ItemPidl, "Int", 0)
	CoTaskMemFree(FolderPidl)
	CoTaskMemFree(ItemPidl)
return
}

OpenAndSelect(sPath, Files*)
{
	; Make sure path has a trailing \
	if (SubStr(sPath, 0, 1) <> "\")
		sPath .= "\"
	;FolderPidl := DllCall("shell32\ILCreateFromPath", "Str", SPath)
	;tooltip, % FolderPidl
	; Get a pointer to ID list (pidl) for the path
	DllCall("shell32\SHParseDisplayName", "str", sPath, "Ptr", 0, "Ptr*", FolderPidl, "Uint", 0, "Uint*", 0)
	
	; create a C type array and store each file name pidl
	VarSetCapacity(PidlArray, Files.MaxIndex() * A_PtrSize, 0)
	for i in Files {
		DllCall("shell32\SHParseDisplayName", "str", sPath . Files[i], "Ptr", 0, "Ptr*", ItemPidl, "Uint", 0, "Uint*", 0)
		NumPut(ItemPidl, PidlArray, (i - 1) * A_PtrSize)
	}

	DllCall("shell32\SHOpenFolderAndSelectItems", "Ptr", FolderPidl, "UInt", Files.MaxIndex(), "Ptr", &PidlArray, "Int", 0)
	;tooltip % ErrorLevel  " - " A_LastError " - " Files[1]
	; Free all of the pidl memory
	for i in Files 
	{
		CoTaskMemFree(NumGet(PidlArray, (i - 1) * A_PtrSize))
		;tooltip % 2
	}
	CoTaskMemFree(FolderPidl)
return
}

IsDialog(window=0)
{
	result:=0
	If(window)
		window := "ahk_id " window
	Else
		window:="A"
	WinGetClass, wc, %window%
	If(wc = "#32770")
	{
		;Check for new FileOpen dialog
		ControlGet, hwnd, Hwnd, , DirectUIHWND3, %window%
		If(hwnd)
		{
			ControlGet, hwnd, Hwnd, , SysTreeView321, %window%
			If(hwnd)
			{
				ControlGet, hwnd, Hwnd, , Edit1, %window%
				If(hwnd)
				{
					ControlGet, hwnd, Hwnd, , Button2, %window%
					If(hwnd)
					{
						ControlGet, hwnd, Hwnd, , ComboBox2, %window%
						If(hwnd)
						{
						ControlGet, hwnd, Hwnd, , ToolBarWindow323, %window%
						If(hwnd)
							result := 1
						}
					}
				}
			}
		}
		;Check for old FileOpen dialog
		If(!result)
		{
			ControlGet, hwnd, Hwnd, , ToolbarWindow321, %window%          ;工具栏
			If(hwnd)
			{
				ControlGet, hwnd, Hwnd, , SysListView321, %window%        ;文件列表
				If(hwnd)
				{
					ControlGet, hwnd, Hwnd, , ComboBox3, %window%         ;文件类型下拉选择框
					If(hwnd)
					{
						ControlGet, hwnd, Hwnd, , Button3, %window%       ;取消按钮
						If(hwnd)
						{
							;ControlGet, hwnd, Hwnd , , SysHeader321 , %window%    ;详细视图的列标题
							ControlGet, hwnd, Hwnd, , ToolBarWindow322, %window%  ;左侧导航栏
							If(hwnd)
								result := 2
						}
					}
				}
			}
		}
	}
	Return result
}

SetFocusToFileView()
{
	If (WinActive,ahk_group ExplorerGroup)
	{
		If(Vista7)
		{
			ControlGetFocus focussed, A
			if (focussed="DirectUIHWND2")
				ControlFocus DirectUIHWND2, A
			else
				ControlFocus DirectUIHWND3, A
		}
		Else ;XP, Vista
		 	ControlFocus SysListView321, A
	}
	Else If((x:=IsDialog())=1) ;New Dialogs
	{
		If(Vista7)
			ControlFocus DirectUIHWND2, A
		Else
			ControlFocus SysListView321, A
	}
    Else If(x=2) ;Old Dialogs
	{
		ControlFocus SysListView321, A
	}
	Return
}

TranslateMUI(resDll, resID)
{
VarSetCapacity(buf, 256)
hDll := DllCall("LoadLibrary", "str", resDll, "Ptr")
Result := DllCall("LoadString", "uint", hDll, "uint", resID, "uint", &buf, "int", 128)
VarSetCapacity(buf, -1)
Return buf
}



XPGetFocussed()
{
  WinGet ctrlList, ControlList, A
  ctrlHwnd:=GetFocusedControl()
  ; Built an array indexing the control names by their hwnd
  Loop Parse, ctrlList, `n
  {
    ControlGet hwnd, Hwnd, , %A_LoopField%, A
    hwnd += 0   ; Convert from hexa to decimal
    If(hwnd=ctrlHwnd)
    {
      Return A_LoopField
    }
  }
}

IsInArea(px,py,x,y,w,h)
{
	Return (px>x&&py>y&&px<x+w&&py<y+h)
}

GetFocusedControl()
{
   guiThreadInfoSize := 4+4+A_PtrSize*6+16
   VarSetCapacity(guiThreadInfo, guiThreadInfoSize, 0)
   ;addr := &guiThreadInfo
   ;DllCall("RtlFillMemory", "ptr", addr, "UInt", 1, "UChar", guiThreadInfoSize)   ; Below 0xFF, one call only is needed
   If not DllCall("GetGUIThreadInfo"
         , "UInt", 0   ; Foreground thread
         , "ptr", &guiThreadInfo)
   {
      ErrorLevel := A_LastError   ; Failure
      Return 0
   }
   focusedHwnd := NumGet(guiThreadInfo,8+A_PtrSize, "Ptr") ;focusedHwnd := *(addr + 12) + (*(addr + 13) << 8) +  (*(addr + 14) << 16) + (*(addr + 15) << 24)
   Return focusedHwnd
}

RefreshExplorer()
{ ; by teadrinker on D437 @ tiny.cc/refreshexplorer
	local Windows := ComObjCreate("Shell.Application").Windows
	Windows.Item(ComObject(0x13, 8)).Refresh()
	for Window in Windows
		if (Window.Name != "Internet Explorer")
			Window.Refresh()
	Else If(IsDialog())
	{
		WinGet, w_WinIDs, List, ahk_class #32770
		Loop, %w_WinIDs%
		{
			w_WinID := w_WinIDs%A_Index%
			ControlGet, w_CtrID, Hwnd,, SHELLDLL_DefView1, ahk_id %w_WinID%
			ControlGet, w_CtrID, Hwnd,, SHELLDLL_DefView1, ahk_id %w_WinID%
			ControlClick, DirectUIHWND2, ahk_id %w_WinID%,,,, NA x1 y30
			SendMessage, 0x111, 0x7103,,, ahk_id %w_CtrID%
		}
	}
	Else
		Send {F5}
}



f_RefreshExplorer()
{
	wParam := Vista7 ? 0x1A220 : 0x7103
	WinGet, w_WinID, ID, ahk_class Progman
	SendMessage, 0x111, % wParam,,, ahk_id %w_WinID%
	WinGet, w_WinID, ID, ahk_class WorkerW
	SendMessage, 0x111, % wParam,,, ahk_id %w_WinID%
	WinGet, w_WinIDs, List, ahk_class CabinetWClass
	Loop, %w_WinIDs%
	{
		w_WinID := w_WinIDs%A_Index%
		SendMessage, 0x111, % wParam,,, ahk_id %w_WinID%
	}
	WinGet, w_WinIDs, List, ahk_class ExploreWClass
	Loop, %w_WinIDs%
	{
		w_WinID := w_WinIDs%A_Index%
		SendMessage, 0x111, % wParam,,, ahk_id %w_WinID%
	}
	WinGet, w_WinIDs, List, ahk_class #32770
	Loop, %w_WinIDs%
	{
		w_WinID := w_WinIDs%A_Index%
		ControlGet, w_CtrID, Hwnd,, SHELLDLL_DefView1, ahk_id %w_WinID%
		if w_CtrID !=
			SendMessage, 0x111, 0x7103,,, ahk_id %w_CtrID%
	}
	; 刷新桌面
	DllCall("Shell32\SHChangeNotify", "uint", 0x8000000, "uint", 0x1000, "uint", 0, "uint", 0)
return
}

ToArray(SourceFiles, ByRef Separator = "`n", ByRef wasQuoted = 0)
{
	files := Array()
	pos := 1
	wasQuoted := 0
	Loop
	{
		If(pos > strlen(SourceFiles))
			break
			
		char := SubStr(SourceFiles, pos, 1)
		If(char = """" || wasQuoted) ;Quoted paths
		{
			file := SubStr(SourceFiles, InStr(SourceFiles, """", 0, pos) + 1, InStr(SourceFiles, """", 0, pos + 1) - pos - 1)
			If(!wasQuoted)
			{
				wasQuoted := 1
				Separator := SubStr(SourceFiles, InStr(SourceFiles, """", 0, pos + 1) + 1, InStr(SourceFiles, """", 0, InStr(SourceFiles, """", 0, pos + 1) + 1) - InStr(SourceFiles, """", 0, pos + 1) - 1)
			}
			If(file)
			{
				files.Push(file)
				pos += strlen(file) + 3
				continue
			}
			Else
				Msgbox Invalid source format %SourceFiles%
		}
		Else
		{
			file := SubStr(SourceFiles, pos, max(InStr(SourceFiles, Separator, 0, pos + 1) - pos, 0)) ; separator
			If(!file)
				file := SubStr(SourceFiles, pos) ;no quotes or separators, single file
			If(file)
			{
				files.Push(file)
				pos += strlen(file) + strlen(Separator)
				continue
			}
			Else
				Msgbox Invalid source format
		}
		pos++ ;Shouldn't happen
	}
	Return files
}

Explorer_GetPath(hwnd="")
{
	If !(window := Explorer_GetWindow(hwnd))
		Return, ErrorLevel := "ERROR"
	If (window = "desktop")
		Return, A_Desktop
	hpath := window.LocationURL
	hpath := RegExReplace(hpath, "ftp://.*@","ftp://")
	StringReplace, hpath, hpath, file:///
	StringReplace, hpath, hpath, /, \, All

	; thanks to polyethene
	Loop
		If RegExMatch(hpath, "i)(?<=%)[\da-f]{1,2}", hex)
			StringReplace, hpath, hpath, `%%hex%, % Chr("0x" . hex), All
		Else Break
	Return hpath
}

GetAllWindowOpenFolder()
{
	if WinActive("ahk_class TTOTAL_CMD")
	return TC_getTwoPath()

	QtTabBarObj := QtTabBar()
	if QtTabBarObj
	{
		OPenedFolder := QtTabBar_GetAllTabs()
	}
	else
	{
		OPenedFolder := []
		ShellWindows := ComObjCreate("Shell.Application").Windows
		for w in ShellWindows
		{
			Tmp_Fp := w.Document.Folder.Self.path
			if (Tmp_Fp)
				if FileExist(Tmp_Fp)
				{
					OPenedFolder.push(Tmp_Fp)
				}
		}
	}
return OPenedFolder
}

Explorer_GetWindow(hwnd="")
{
	static shell := ComObjCreate("Shell.Application")
	; thanks to jethrow for some pointers here
	WinGet, process, processName, % "ahk_id" hwnd := (hwnd ? hwnd : WinExist("A"))
	WinGetClass class, ahk_id %hwnd%
    
	If (process!="explorer.exe")
		Return
	If (class ~= "(Cabinet|Explore)WClass")
	{
		for window in shell.Windows
		{
			;tooltip % window.hwnd " - " hwnd
			If (window.hwnd==hwnd)
			Return window
		}
	}
	Else If (class ~= "Progman|WorkerW")
		Return "desktop" ; desktop found
}

InFileList()
{
	If(Vista7)
		ControlGetFocus focussed, A
	Else
		focussed:=XPGetFocussed()

	If(WinActive("ahk_group ExplorerGroup"))
	{
		If((Vista7 && (focussed="DirectUIHWND2" || focussed="DirectUIHWND3" )) || (A_OSVersion ="XP" && focussed="SysListView321"))
			Return true
	}
		If(WinActive("ahk_group DesktopGroup"))
	{
		If((Vista7 && focussed="SysListView321") || (A_OSVersion ="XP" && focussed="SysListView321"))
			Return true
	}
	Return false
}

WindowProc(hWnd, nMsg, wParam, lParam)
{
   Global   pIContextMenu2, pIContextMenu3, WPOld
   If   pIContextMenu3
   {    ;IContextMenu3->HandleMenuMsg2
      If   !DllCall(VTable(pIContextMenu3, 7), "Ptr", pIContextMenu3, "Uint", nMsg, "Ptr", wParam, "Ptr", lParam, "Ptr*", lResult)
         Return   lResult
   }
   Else If   pIContextMenu2
   {    ;IContextMenu2->HandleMenuMsg
      If   !DllCall(VTable(pIContextMenu2, 6), "Ptr", pIContextMenu2, "Uint", nMsg, "Ptr", wParam, "Ptr", lParam)
         Return   0
   }
   Return   DllCall("user32.dll\CallWindowProcW", "Ptr", WPOld, "Ptr", hWnd, "Uint", nMsg, "Ptr", wParam, "Ptr", lParam)
}

VTable(ppv, idx)
{
   Return   NumGet(NumGet(1*ppv)+A_PtrSize*idx)
}

GUID4String(ByRef CLSID, String)
{
   VarSetCapacity(CLSID, 16,0)
   Return DllCall("ole32\CLSIDFromString", "wstr", String, "Ptr", &CLSID) >= 0 ? &CLSID : ""
}

CoTaskMemFree(pv)
{
   Return   DllCall("ole32\CoTaskMemFree", "Ptr", pv)
}

SetDialogDirectory(Path)
{
	ControlGetFocus, focussed, A
	ControlGetText, w_Edit1Text, Edit1, A
	ControlClick, Edit1, A
	ControlSetText, Edit1, %Path%, A
	hwnd:=WinExist("A")
	ControlSend, Edit1, {Enter}, A
	Sleep, 100	; It needs extra time on some dialogs or in some cases.
	while hwnd!=WinExist("A") ;If there is an error dialog, wait until user closes it before continueing
		Sleep, 100
	ControlSetText, Edit1, %w_Edit1Text%, A
	ControlFocus %focussed%,A
}

f_GetExplorerList() ; Thanks to F1reW1re
{
	WinGet, IDList, list, , , Program Manager
	Loop, %IDList%
	{
		ThisID := IDList%A_Index%
		WinGetClass, ThisClass, ahk_id %ThisID%
		if ThisClass in ExploreWClass,CabinetWClass
		{
			if Vista7
				ControlGetText, ThisPath, ToolbarWindow322, ahk_id %ThisID%
			else
				ControlGetText, ThisPath, ComboBoxEx321, ahk_id %ThisID%
			if ThisPath = ; if cannot get path, use title instead
				WinGetTitle, ThisPath, ahk_id %ThisID%
			PathList = %PathList%%ThisID%=%ThisPath%`n
		}
	}
	return PathList
}

f_GetPathEdit(ThisID) ; get the classnn of the addressbar, thanks to F1reW1re
{
	WinGetClass, ThisClass, ahk_id %ThisID%
	if ThisClass not in ExploreWClass,CabinetWClass
		return
	ControlGetText, ComboBoxEx321_Content, ComboBoxEx321, ahk_id %ThisID%
	WinGet, ActiveControlList, ControlList, ahk_id %ThisID%
	Loop, Parse, ActiveControlList, `n
	{
		StringLeft, WhichControl, A_LoopField, 4
		if WhichControl = Edit
		{
			ControlGetText, Edit_Content, %A_LoopField%, ahk_id %ThisID%
			if ComboBoxEx321_Content = %Edit_Content%
			{
				return % A_LoopField
			}
		}
	}
	return
}

TC_getTwoPath()
{
	DetectHiddenText, On
	WinGetText, TCWindowText, Ahk_class TTOTAL_CMD
	m := RegExMatchAll(TCWindowText, "m)(.*)\\\*\.\*", 1)
	return m
}

RegExMatchAll(ByRef Haystack, NeedleRegEx, SubPat="")
{
	arr := [], startPos := 1
	while ( pos := RegExMatch(Haystack, NeedleRegEx, match, startPos) )
	{
		arr.push(match%SubPat%)
		startPos := pos + StrLen(match)
	}
	return arr.MaxIndex() ? arr : ""
}