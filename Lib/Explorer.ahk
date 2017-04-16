;#include COM.ahk
;Explorer Windows Manipulations - Sean
;http://www.autohotkey.com/forum/topic20701.html
;7plus - fragman
;http://code.google.com/p/7plus/

;测试快捷键
#F1::
	If(WinActive("ahk_group ccc"))
	{
			hWnd:=WinExist("A")
		  qqq:= ShellFolder(hwnd,3,0)
        MsgBox %qqq%
	}
return
;测试快捷键

GetCurrentFolder()
{
	global MuteClipboardList,newfolder
	newfolder=
	If (WinActive("ahk_group ExplorerGroup"))
	{
		hWnd:=WinExist("A")
		return ShellFolder(hWnd,1)
	}
	If (WinActive("ahk_group DesktopGroup"))
		return %A_Desktop%
	isdg := IsDialog()
	If (isdg=1) ;No Support for old dialogs for now
	{
	ControlGetText, text , ToolBarWindow322, A
	dgpath:=SubStr(text,InStr(text," "))
	dgpath = %dgpath%
	return dgpath
    }
	else if (isdg=2)
	{
	newfolder=types2
	return 0
	}
	return 0
}

ShellNavigate(sPath, bExplore=False, hWnd=0)
{
	SetTitleMatchMode, RegEx
	If	hWnd || (hWnd :=	WinExist("ahk_class (?:Cabinet|Explore)WClass"))
	{
		For window in ComObjCreate("Shell.Application").Windows
			If	(window.hWnd = hWnd)
				window.Navigate2[sPath]
		Until	(window.hWnd = hWnd)
	}
	Else if	bExplore
		ComObjCreate("Shell.Application").Explore[sPath]
	Else	ComObjCreate("Shell.Application").Open[sPath]
}

/*
returntype=1 当前文件夹
returntype=2 具有焦点的选中项
returntype=3 是所有选中项
returntype=4 当前文件夹下所有项目
*/
ShellFolder(hWnd=0,returntype=0,onlyname=0)
{
   if !(window := Explorer_GetWindow(hwnd))
      return ErrorLevel := "ERROR"
if (window="desktop")
{
  if (returntype=3)
       selection=1
    if (returntype=4)
       selection=0
 ;桌面文件夹区别对待
      ControlGet, hwWindow, HWND,, SysListView321, ahk_class Progman
      if !hwWindow ; #D mode
         ControlGet, hwWindow, HWND,, SysListView321, A
      ControlGet, files, List, % ( selection ? "Selected":"") "Col1",,ahk_id %hwWindow%
      base := SubStr(A_Desktop,0,1)=="" ? SubStr(A_Desktop,1,-1) : A_Desktop
      Loop, Parse, files, `n, `r
      {
         hpath := base "\" A_LoopField
         IfExist %hpath% ; ignore special icons like Computer (at least for now)
            ret .= hpath "`n"
      }
    return Trim(ret,"`n")
   }
   else
  {
  		;Find hwnd window
      doc:=window.Document
       if (returntype=1)
         {
				sFolder   := doc.Folder.Self.path
        if onlyname
				sFolder := doc.Folder.Self.name
        }
				if (returntype=2)
				{
					sFocus :=doc.FocusedItem.Path
          if onlyname
					SplitPath, sFocus , sFocus
				}
				if(returntype=3)
				{
         collection := doc.SelectedItems
         for item in collection
            {
              hpath :=  item.path
							if onlyname
								SplitPath, hpath , hpath
							sSelect .=hpath "`n"
						}
           StringReplace, sSelect, sSelect, \\ , \, 1
          }
        if(returntype=4)
         {
          collection := doc.Folder.Items
          for item in collection
           {
             hpath :=  item.path
							if onlyname
								SplitPath, hpath , hpath
              sSelect .= hpath "`n"
         }
         }
        sSelect:=Trim(sSelect,"`n")
				if (returntype=1)
					Return   sFolder
				else if (returntype=2)
					Return   sFocus
				else if (returntype=3)
					Return   sSelect
				else if (returntype=4)
					Return sSelect
}
}

SelectFiles(Select,Clear=1,Deselect=0,MakeVisible=1,focus=1, hWnd=0)
{
	If (hWnd||(hWnd:=WinActive("ahk_class CabinetWClass"))||(hWnd:=WinActive("ahk_class ExploreWClass")))
	{
		SplitPath, Select, Select ;Make sure only names are used
		for Item in ComObjCreate("Shell.Application").Windows
		{
			if (Item.hwnd = hWnd)
			{
				doc:=Item.Document
				value:=!(Deselect = 1)
				value1:=!(Deselect = 1)+(focus = 1)*16+(MakeVisible = 1)*8
				count := doc.Folder.Items.Count
				if(Clear = 1)
				{
					if(count > 0)
					{
						item := doc.Folder.Items.Item(0)
						doc.SelectItem(item,4)
						doc.SelectItem(item,0)
					}
				}
				if(!IsObject(Select))
					Select := ToArray(Select)
				items := Array()
				itemnames := Array()
				Loop % count
				{
					index := A_Index
					while(true)
					{
						item := doc.Folder.Items.Item(index - 1)
						itemname := item.Name
						if(itemname != "")
						{
							; outputdebug itemname %itemname%
							break
						}
						Sleep 10
					}
					items.append(item)
					itemnames.append(itemname)
         ;FileAppend,%itemname%`n,%A_desktop%\123.txt
				}
        ererer:=Select.len()
				Loop % Select.len()
				{
					index := A_Index
					filter := Select[A_Index]
					If(filter)
					{
						If(InStr(filter, "*"))
						{
							filter := "\Q" StringReplace(filter, "*", "\E.*\Q", 1) "\E"
							filter := strTrim(filter,"\Q\E")
							Loop % items.len()
							{
                
								if(RegexMatch(itemnames[A_Index],"i)" filter))
								{
									doc.SelectItem(items[A_Index], index=1 ? value1 : value)
									index++
								}
							}
						}
						else
						{
							Loop % items.len()
							{
								if(itemnames[A_Index]=filter)
								{
									doc.SelectItem(items[A_Index], index=1 ? value1 : value)
									index++
									break
								}
							}
						}
					}
				}
				return
			}
		}
	}
	else if(hWnd:=WinActive("ahk_group DesktopGroup") && A_PtrSize = 4)
	{
   SplitPath, Select, Select
   _SendRaw(Select)    ;ansi版直接发送中文
	}
}

/*
GetSelectedFiles(FullName=1)
{
	Critical
	global MuteClipboardSurveillance, MuteClipboardList,Vista7
	If (WinActive("ahk_group ExplorerGroup"))
	{
		RegRead,hidefileext,HKCU,Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced,HideFileExt
		if(hidefileext=1)
        {
		ControlGetFocus, focussed ,A
		MuteClipboardList := true
		clipboardbackup := clipboardall
		clipboard := ""
		ClipWait, 0.5, 1
		MuteClipboardList := true
		Send ^c
		ClipWait, 0.5, 1
		result := clipboard
		MuteClipboardList := true
		clipboard := clipboardbackup
		ControlFocus %focussed%, A
		return result
		}
		Else
		{
		hWnd:=WinExist("A")
		if(FullName)
			return ShellFolder(hwnd,3)   ;选择文件(夹)的路径
		else
			return ShellFolder(hwnd,4)  ;选择文件(夹)的文件名
		}
	}

	if((Vista7 && x:=IsDialog())||WinActive("ahk_group DesktopGroup"))
	{
		ControlGetFocus, focussed ,A
		if(x=1)
			ControlFocus DirectUIHWND2, A
		if(WinActive("ahk_group DesktopGroup"))
			ControlFocus SysListView321, A
		MuteClipboardList := true
		clipboardbackup := clipboardall
		clipboard := ""
		ClipWait, 0.05, 1
		MuteClipboardList := true
		Send ^c
		ClipWait, 1.5, 1
		result := clipboard
		TrayTip %result%
		MuteClipboardList := true
		clipboard := clipboardbackup
		ControlFocus %focussed%, A
		return result
	}

}
*/
;Returns selected files separated by `n
GetSelectedFiles(FullName=1, hwnd=0)
{
	global MuteClipboardList,Vista7
	If(WinActive("ahk_group ExplorerGroup"))
	{
		if(!hwnd)
			hWnd:=WinExist("A")
		if FullName
		{
			return ShellFolder(hwnd,3)
			}
		else
			return ShellFolder(hwnd,3,1)
	}
	else if(Vista7 && x:=IsDialog())
	{
		if(x=1)
		{
			ControlGetFocus, focussed ,A
			ControlFocus DirectUIHWND2, A
		}
		MuteClipboardList := true
		clipboardbackup := clipboardall
		outputdebug clearing clipboard
		clipboard := ""
		ClipWait, 0.05, 1
		outputdebug copying files to clipboard
		Send ^c
		ClipWait, 0.05, 1
		result := clipboard
		clipboard := clipboardbackup
		if(x=1)
			ControlFocus %focussed%, A
		OutputDebug, Selected Files: %result%
		MuteClipboardList:=false
		return result
	}
	else if(WinActive("ahk_group DesktopGroup"))
	{
		; if(A_PtrSize = 8) ;64bit doesn't support listview method below yet
		; {
			; MuteClipboardList := true
			; clipboardbackup := clipboardall
			; outputdebug clearing clipboard
			; clipboard := ""
			; ClipWait, 0.15, 1
			; outputdebug copying files to clipboard
			; Send ^c
			; ClipWait, 0.15, 1
			; result := clipboard
			; clipboard := clipboardbackup
			; OutputDebug, Selected Files: %result%
			; MuteClipboardList:=false
			; return result
		; }
		; else
		; {
			ControlGet, result, List, Selected Col1, SysListView321, A ;This line causes explorer to crash on 64 bit systems when used in a 32 bit AHK build
			if(result)
			{
				Loop, Parse, result, `n ; Rows are delimited by linefeeds (`n).
				{
					hpath := A_Desktop "\" A_LoopField
					IfExist %hpath%
					   result2 .= "`n" A_Desktop "\" A_LoopField
					IfExist  %hpath%.lnk
					   result2 .= "`n" A_Desktop "\" A_LoopField ".lnk"
					}
				return SubStr(result2,2)
			}
			else
				return ""
	}
	; }
}


IsDialog(window=0)
{
	result:=0
	if(window)
		window:="ahk_id " window
	else
		window:="A"
	WinGetClass,wc,%window%
	if(wc="#32770")
	{
		;Check for new FileOpen dialog
		ControlGet, hwnd, Hwnd , , DirectUIHWND3, %window%
		if(hwnd)
		{
			ControlGet, hwnd, Hwnd , , SysTreeView321, %window%
			if(hwnd)
			{
				ControlGet, hwnd, Hwnd , , Edit1, %window%
				if(hwnd)
				{
					ControlGet, hwnd, Hwnd , , Button2, %window%
					if(hwnd)
					{
						ControlGet, hwnd, Hwnd , , ComboBox2, %window%
						if(hwnd)
						{
						ControlGet, hwnd, Hwnd , , ToolBarWindow323, %window%
						if(hwnd)
							result:=1
						}
					}
				}
			}
		}
		;Check for old FileOpen dialog
		if(!result)
		{
			ControlGet, hwnd, Hwnd , , ToolbarWindow321, %window%          ;工具栏
			if(hwnd)
			{
				ControlGet, hwnd, Hwnd , , SysListView321, %window%        ;文件列表
				if(hwnd)
				{
					ControlGet, hwnd, Hwnd , , ComboBox3, %window%         ;文件类型下拉选择框
					if(hwnd)
					{
						ControlGet, hwnd, Hwnd , , Button3, %window%       ;取消按钮
						if(hwnd)
						{
							;ControlGet, hwnd, Hwnd , , SysHeader321 , %window%    ;详细视图的列标题
							ControlGet, hwnd, Hwnd , , ToolBarWindow322,%window%  ;左侧导航栏
							if(hwnd)
								result:=2
						}
					}
				}
			}
		}
	}
	return result
}

SetFocusToFileView()
{
	if (WinActive,ahk_group ExplorerGroup)
	{
		if(A_OSVersion="WIN_7")
			ControlFocus DirectUIHWND3, A
		else ;XP, Vista
		 	ControlFocus SysListView321, A
	}
	else if((x:=IsDialog())=1) ;New Dialogs
	{
		if(A_OSVersion="WIN_7")
			ControlFocus DirectUIHWND2, A
		else
			ControlFocus SysListView321, A
	}
    else if(x=2) ;Old Dialogs
	{
		ControlFocus SysListView321, A
	}
	return
}

TranslateMUI(resDll, resID)
{
VarSetCapacity(buf, 256)
hDll := DllCall("LoadLibrary", "str", resDll)
Result := DllCall("LoadString", "uint", hDll, "uint", resID, "str", buf, "int", 128)
return buf
}

IsRenaming()
{
	;;; 声明全局变量，否则N_OSVersion在第二次判断时值为空
	if(A_OSVersion="WIN_7")
	 ControlGetFocus focussed, A
  else
    focussed:=XPGetFocussed()
	if(WinActive("ahk_group ExplorerGroup")) ;Explorer
	{
		if(strStartsWith(focussed,"Edit"))
		{
			if(A_OSVersion="WIN_7")
				ControlGetPos , X, Y, Width, Height, DirectUIHWND3, A
			else
				ControlGetPos , X, Y, Width, Height, SysListView321, A
			ControlGetPos , X1, Y1, Width1, Height1, %focussed%, A
			if(IsInArea(X1,Y1, X, Y, Width, Height) && IsInArea(X1+Width1,Y1, X, Y, Width, Height) && IsInArea(X1,Y1+Height1, X, Y, Width, Height) && IsInArea(X1+Width1,Y1+Height1, X, Y, Width, Height))
				return true
		}
	}
	else if (WinActive("ahk_group DesktopGroup")) ;Desktop
	{
		if(focussed="Edit1")
			return true
	}
	else if((x:=IsDialog())) ;FileDialogs
	{
		if(strStartsWith(focussed,"Edit1"))
		{
			;figure out if the the edit control is inside the DirectUIHWND2 or SysListView321
			if(x=1 && A_OSVersion="WIN_7") ;New Dialogs
				ControlGetPos , X, Y, Width, Height, DirectUIHWND2, A
			else ;Old Dialogs
				ControlGetPos , X, Y, Width, Height, SysListView321, A
			ControlGetPos , X1, Y1, Width1, Height1, %focussed%, A
			if(IsInArea(X1,Y1, X, Y, Width, Height)&&IsInArea(X1+Width1,Y1, X, Y, Width, Height)&&IsInArea(X1,Y1+Height1, X, Y, Width, Height)&&IsInArea(X1+Width1,Y1+Height1, X, Y, Width, Height))
				return true
		}
	}
	return false
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
    if(hwnd=ctrlHwnd)
    {
      return A_LoopField
    }
  }
}

strStartsWith(string,start)
{
	x:=(strlen(start)<=strlen(string)&&Substr(string,1,strlen(start))=start)
	return x
}

IsInArea(px,py,x,y,w,h)
{
	return (px>x&&py>y&&px<x+w&&py<y+h)
}

GetFocusedControl()
{
   guiThreadInfoSize = 48
   VarSetCapacity(guiThreadInfo, guiThreadInfoSize, 0)
   addr := &guiThreadInfo
   DllCall("RtlFillMemory"
         , "UInt", addr
         , "UInt", 1
         , "UChar", guiThreadInfoSize)   ; Below 0xFF, one call only is needed
   If not DllCall("GetGUIThreadInfo"
         , "UInt", 0   ; Foreground thread
         , "UInt", &guiThreadInfo)
   {
      ErrorLevel := A_LastError   ; Failure
      Return 0
   }
   focusedHwnd := *(addr + 12) + (*(addr + 13) << 8) +  (*(addr + 14) << 16) + (*(addr + 15) << 24)
   Return focusedHwnd
}

WinGetClass(window=0)
{
WinGetClass, class, window
return class
}

RefreshExplorer()
{
	hwnd:=WinExist("A")
	If (WinActive("ahk_group ExplorerGroup"))
	{
		for Item in ComObjCreate("Shell.Application").Windows
		{
			if (Item.hwnd = hWnd)
			{
				Item.Refresh()
				Send {F5}
				return
			}
		}
	}
	else if(IsDialog())
		Send {F5}
}

CreateNewFolder()
{
	global newfolder
global shell32muipath
  ;This is done manually, by creating a text file with the translated name, which is then focussed
	SetFocusToFileView()
if(A_OSversion = "WIN_XP")
    TextTranslated:=TranslateMUI("shell32.dll",30320) ;"New Folder"
else
   TextTranslated:=TranslateMUI("shell32.dll",16888) ;"New Folder"
	CurrentFolder:=GetCurrentFolder()
	If newfolder=types2
	{
    PostMessage, 0x111, 40962   ; send direct command for new folder
	Return
	}
	If CurrentFolder=0
	Return
	Testpath := CurrentFolder "\" TextTranslated
	i:=1 ;Find free filename
	while FileExist(TestPath)
	{
		i++
		Testpath:=CurrentFolder "\" TextTranslated " (" i ")"
	}
	FileCreateDir, %TestPath%	;Create file and then select it and rename it
    if ErrorLevel
	TrayTip,错误,新建文件夹出错！,3
	RefreshExplorer()
  sleep,1000
		SelectFiles(Testpath)
Sleep 50
	Send {F2}
	return
}

CreateNewTextFile()
{
  global Vista7,txt
	;This is done manually, by creating a text file with the translated name, which is then focussed
	SetFocusToFileView()
	if(Vista7)
    TextTranslated:=TranslateMUI("G:\Windows\notepad.exe",470) ;"New Textfile"
  else
  {
    newstring:=TranslateMUI("shell32.dll",8587) ;"New"
    TextTranslated:=newstring  " " TranslateMUI("notepad.exe",469) ;"Textfile"
  }
	CurrentFolder :=GetCurrentFolder()
	if CurrentFolder=0
	Return
	Testpath := CurrentFolder "\" TextTranslated "." txt
	i:=1 ;Find free filename
	while FileExist(TestPath)
	{
		i++
		Testpath:=CurrentFolder "\" TextTranslated " (" i ")." txt
	}
	FileAppend , , %TestPath%	;Create file and then select it and rename it
	if ErrorLevel
	{
    TrayTip,错误,新建文本文档出错,3
	Return
	}
	RefreshExplorer()
	Sleep 1000
		SelectFiles(TestPath)
	Sleep 50
    Send     {F2}
	return
}


IsMouseOverFileList()
{
	CoordMode,Mouse,Relative
	MouseGetPos, MouseX, MouseY,Window , UnderMouse
	WinGetClass, winclass , ahk_id %Window%
	if(A_OSVersion="WIN_7" && (winclass="CabinetWClass" || winclass="ExploreWClass")) ;Win7 Explorer
	{
		ControlGetPos , cX, cY, Width, Height, DirectUIHWND3, A
		if(IsInArea(MouseX,MouseY,cX,cY,Width,Height))
			return true
	}
	else if((z:=IsDialog(window))=1) ;New dialogs
	{
		outputdebug new dialog
		ControlGetPos , cX, cY, Width, Height, DirectUIHWND2, A
		outputdebug x %MouseX% y %mousey% x%cx% y%cy% w%width% h%height%
		if(IsInArea(MouseX,MouseY,cX,cY,Width,Height)) ;Checking for area because rename might be in process and mouse might be over edit control
		{
			outputdebug over filelist
			return true
		}
	}
	else if(winclass="CabinetWClass" || winclass="ExploreWClass" || z=2) ;Old dialogs or Vista/XP
	{
		ControlGetPos , cX, cY, Width, Height, SysListView321, A
		if(IsInArea(MouseX,MouseY,cX,cY,Width,Height) && UnderMouse = "SysListView321") ;Additional check needed for XP because of header
			return true
	}
	return false
}

ToArray(SourceFiles, ByRef Separator = "`n", ByRef wasQuoted = 0)
{
	files := Array()
	pos := 1
	wasQuoted := 0
	Loop
	{
		if(pos > strlen(SourceFiles))
			break
			
		char := SubStr(SourceFiles, pos, 1)
		if(char = """" || wasQuoted) ;Quoted paths
		{
			file := SubStr(SourceFiles, InStr(SourceFiles, """", 0, pos) + 1, InStr(SourceFiles, """", 0, pos + 1) - pos - 1)
			if(!wasQuoted)
			{
				wasQuoted := 1
				Separator := SubStr(SourceFiles, InStr(SourceFiles, """", 0, pos + 1) + 1, InStr(SourceFiles, """", 0, InStr(SourceFiles, """", 0, pos + 1) + 1) - InStr(SourceFiles, """", 0, pos + 1) - 1)
			}
			if(file)
			{
				files.append(file)
				pos += strlen(file) + 3
				continue
			}
			else
				Msgbox Invalid source format %SourceFiles%
		}
		else
		{
			file := SubStr(SourceFiles, pos, max(InStr(SourceFiles, Separator, 0, pos + 1) - pos, 0)) ; separator
			if(!file)
				file := SubStr(SourceFiles, pos) ;no quotes or separators, single file
			if(file)
			{
				files.append(file)
				pos += strlen(file) + strlen(Separator)
				continue
			}
			else
				Msgbox Invalid source format
		}
		pos++ ;Shouldn't happen
	}
	return files
}

StringReplace(InputVar, SearchText, ReplaceText = "", All = "") {
	StringReplace, v, InputVar, %SearchText%, %ReplaceText%, %All%
	Return, v
}

ExpandEnvVars(ppath)
{
	VarSetCapacity(dest, 2000)
	DllCall("ExpandEnvironmentStrings", "str", ppath, "str", dest, int, 1999, "Cdecl int")
	return dest
}

strEndsWith(string,end)
{
	return strlen(end)<=strlen(string) && Substr(string,-strlen(end)+1)=end
}

strTrim(string, trim)
{
	return strTrimLeft(strTrimRight(string,trim),trim)
}

strTrimLeft(string,trim)
{
	len:=strLen(trim)
	while(strStartsWith(string,trim))
	{
		StringTrimLeft, string, string, %len%
	}
	return string
}

strTrimRight(string,trim)
{
	len:=strLen(trim)
	If(strEndsWith(string,trim))
	{
		StringTrimRight, string, string, %len%
	}
	return string
}


richObject(){
   static richObject
   If !richObject
      richObject := Object("base", Object("print", "objPrint", "copy", "objCopy"
                             , "deepCopy", "objDeepCopy", "equal", "objEqual"
             , "flatten", "objFlatten"  ))

   return  Object("base", richObject)
}

Explorer_GetPath(hwnd="")
{
   if !(window := Explorer_GetWindow(hwnd))
      return, ErrorLevel := "ERROR"
   if (window="desktop")
      return, A_Desktop
   hpath := window.LocationURL
    hpath := RegExReplace(hpath, "ftp://.*@","ftp://")
    StringReplace, hpath, hpath, file:///
    StringReplace, hpath, hpath, /, \, All

   ; thanks to polyethene
   Loop
      If RegExMatch(hpath, "i)(?<=%)[\da-f]{1,2}", hex)
         StringReplace, hpath, hpath, `%%hex%, % Chr("0x" . hex), All
      Else Break
   return hpath
}

Explorer_GetWindow(hwnd="")
{
    ; thanks to jethrow for some pointers here
    WinGet, process, processName, % "ahk_id" hwnd := hwnd? hwnd:WinExist("A")
    WinGetClass class, ahk_id %hwnd%

    if (process!="explorer.exe")
        return
    if (class ~= "(Cabinet|Explore)WClass")
    {
        for window in ComObjCreate("Shell.Application").Windows
           if (window.hwnd==hwnd)
               return window
     }
    else if (class ~= "Progman|WorkerW")
        return "desktop" ; desktop found
} 

InFileList()
{
	if(A_OSVersion="WIN_7")
		ControlGetFocus focussed, A
	else
	  focussed:=XPGetFocussed()

	if(WinActive("ahk_group ExplorerGroup"))
	{
		if((A_OSVersion="WIN_7" && focussed="DirectUIHWND3") || (A_OSVersion ="XP" && focussed="SysListView321"))
			return true
	}
	return false
}


;;;;;;;;;;;;;;;;;;;;;;;;ShellContextMenu.ahk;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
path := "C:\Windows"

ShellContextMenu(path)
sleep 1000
ShellContextMenu(0x0012)
ExitApp
*/
/*
typedef enum  { 
  ssfALTSTARTUP        = 0x1d,
  ssfAPPDATA           = 0x1a,
  ssfBITBUCKET         = 0x0a,
  ssfCOMMONALTSTARTUP  = 0x1e,
  ssfCOMMONAPPDATA     = 0x23,
  ssfCOMMONDESKTOPDIR  = 0x19,
  ssfCOMMONFAVORITES   = 0x1f,
  ssfCOMMONPROGRAMS    = 0x17,
  ssfCOMMONSTARTMENU   = 0x16,
  ssfCOMMONSTARTUP     = 0x18,
  ssfCONTROLS          = 0x03,
  ssfCOOKIES           = 0x21,
  ssfDESKTOP           = 0x00,
  ssfDESKTOPDIRECTORY  = 0x10,
  ssfDRIVES            = 0x11,
  ssfFAVORITES         = 0x06,
  ssfFONTS             = 0x14,
  ssfHISTORY           = 0x22,
  ssfINTERNETCACHE     = 0x20,
  ssfLOCALAPPDATA      = 0x1c,
  ssfMYPICTURES        = 0x27,
  ssfNETHOOD           = 0x13,
  ssfNETWORK           = 0x12,
  ssfPERSONAL          = 0x05,
  ssfPRINTERS          = 0x04,
  ssfPRINTHOOD         = 0x1b,
  ssfPROFILE           = 0x28,
  ssfPROGRAMFILES      = 0x26,
  ssfPROGRAMFILESx86   = 0x30,
  ssfPROGRAMS          = 0x02,
  ssfRECENT            = 0x08,
  ssfSENDTO            = 0x09,
  ssfSTARTMENU         = 0x0b,
  ssfSTARTUP           = 0x07,
  ssfSYSTEM            = 0x25,
  ssfSYSTEMx86         = 0x29,
  ssfTEMPLATES         = 0x15,
  ssfWINDOWS           = 0x24
} ShellSpecialFolderConstants;

*/
ShellContextMenu( sPath, win_hwnd = 0 )
{
   if ( !sPath  )
      return
   if !win_hwnd
   {
      Gui,SHELL_CONTEXT:New, +hwndwin_hwnd
      Gui,Show
   }
   
   If sPath Is Not Integer
      DllCall("shell32\SHParseDisplayName", "Wstr", sPath, "Ptr", 0, "Ptr*", pidl, "Uint", 0, "Uint*", 0)
      ;This function is the preferred method to convert a string to a pointer to an item identifier list (PIDL).
   else
      DllCall("shell32\SHGetFolderLocation", "Ptr", 0, "int", sPath, "Ptr", 0, "Uint", 0, "Ptr*", pidl)
   DllCall("shell32\SHBindToParent", "Ptr", pidl, "Ptr", GUID4String(IID_IShellFolder,"{000214E6-0000-0000-C000-000000000046}"), "Ptr*", pIShellFolder, "Ptr*", pidlChild)
   ;IShellFolder->GetUIObjectOf
   DllCall(VTable(pIShellFolder, 10), "Ptr", pIShellFolder, "Ptr", 0, "Uint", 1, "Ptr*", pidlChild, "Ptr", GUID4String(IID_IContextMenu,"{000214E4-0000-0000-C000-000000000046}"), "Ptr", 0, "Ptr*", pIContextMenu)
   ObjRelease(pIShellFolder)
   CoTaskMemFree(pidl)
   
   hMenu := DllCall("CreatePopupMenu")
   ;IContextMenu->QueryContextMenu
   ;http://msdn.microsoft.com/en-us/library/bb776097%28v=VS.85%29.aspx
   DllCall(VTable(pIContextMenu, 3), "Ptr", pIContextMenu, "Ptr", hMenu, "Uint", 0, "Uint", 3, "Uint", 0x7FFF, "Uint", 0x100)   ;CMF_EXTENDEDVERBS
   ComObjError(0)
      global pIContextMenu2 := ComObjQuery(pIContextMenu, IID_IContextMenu2:="{000214F4-0000-0000-C000-000000000046}")
      global pIContextMenu3 := ComObjQuery(pIContextMenu, IID_IContextMenu3:="{BCFCE0A0-EC17-11D0-8D10-00A0C90F2719}")
   e := A_LastError ;GetLastError()
   ComObjError(1)
   if (e != 0)
      goTo, StopContextMenu
   Global   WPOld:= DllCall("SetWindowLongPtr", "Ptr", win_hwnd, "int",-4, "Ptr",RegisterCallback("WindowProc"),"UPtr")
   DllCall("GetCursorPos", "int64*", pt)
   DllCall("InsertMenu", "Ptr", hMenu, "Uint", 0, "Uint", 0x0400|0x800, "Ptr", 2, "Ptr", 0)
   DllCall("InsertMenu", "Ptr", hMenu, "Uint", 0, "Uint", 0x0400|0x002, "Ptr", 1, "Ptr", &sPath)

   idn := DllCall("TrackPopupMenuEx", "Ptr", hMenu, "Uint", 0x0100|0x0001, "int", pt << 32 >> 32, "int", pt >> 32, "Ptr", win_hwnd, "Uint", 0)

   /*
   typedef struct _CMINVOKECOMMANDINFOEX {
   DWORD   cbSize;          0
   DWORD   fMask;           4
   HWND    hwnd;            8
   LPCSTR  lpVerb;          8+A_PtrSize
   LPCSTR  lpParameters;    8+2*A_PtrSize
   LPCSTR  lpDirectory;     8+3*A_PtrSize
   int     nShow;           8+4*A_PtrSize
   DWORD   dwHotKey;        12+4*A_PtrSize
   HANDLE  hIcon;           16+4*A_PtrSize
   LPCSTR  lpTitle;         16+5*A_PtrSize
   LPCWSTR lpVerbW;         16+6*A_PtrSize
   LPCWSTR lpParametersW;   16+7*A_PtrSize
   LPCWSTR lpDirectoryW;    16+8*A_PtrSize
   LPCWSTR lpTitleW;        16+9*A_PtrSize
   POINT   ptInvoke;        16+10*A_PtrSize
   } CMINVOKECOMMANDINFOEX, *LPCMINVOKECOMMANDINFOEX;
   http://msdn.microsoft.com/en-us/library/bb773217%28v=VS.85%29.aspx
   */
   struct_size  :=  16+11*A_PtrSize
   VarSetCapacity(pici,struct_size,0)
   NumPut(struct_size,pici,0,"Uint")         ;cbSize
   NumPut(0x4000|0x20000000|0x00100000,pici,4,"Uint")   ;fMask
   NumPut(win_hwnd,pici,8,"UPtr")       ;hwnd
   NumPut(1,pici,8+4*A_PtrSize,"Uint")       ;nShow
   NumPut(idn-3,pici,8+A_PtrSize,"UPtr")     ;lpVerb
   NumPut(idn-3,pici,16+6*A_PtrSize,"UPtr")  ;lpVerbW
   NumPut(pt,pici,16+10*A_PtrSize,"Uptr")    ;ptInvoke
   
   DllCall(VTable(pIContextMenu, 4), "Ptr", pIContextMenu, "Ptr", &pici)   ; InvokeCommand

   DllCall("GlobalFree", "Ptr", DllCall("SetWindowLongPtr", "Ptr", win_hwnd, "int", -4, "Ptr", WPOld,"UPtr"))
   DllCall("DestroyMenu", "Ptr", hMenu)
StopContextMenu:
   ObjRelease(pIContextMenu3)
   ObjRelease(pIContextMenu2)
   ObjRelease(pIContextMenu)
   pIContextMenu2:=pIContextMenu3:=WPOld:=0
   Gui,SHELL_CONTEXT:Destroy
   return idn
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
   return DllCall("ole32\CLSIDFromString", "wstr", String, "Ptr", &CLSID) >= 0 ? &CLSID : ""
}

CoTaskMemFree(pv)
{
   Return   DllCall("ole32\CoTaskMemFree", "Ptr", pv)
}

;;;;;;;;;;;;;;;;;;;;;;;;ShellContextMenu.ahk;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


/*
fileO:
FO_MOVE   := 0x1
FO_COPY   := 0x2
FO_DELETE := 0x3
FO_RENAME := 0x4

flags:
Const FOF_SILENT = 4
Const FOF_RENAMEONCOLLISION = 8
Const FOF_NOCONFIRMATION = 16
Const FOF_NOERRORUI = 1024
http://msdn.microsoft.com/en-us/library/bb759795(VS.85).aspx for more
*/
ShellFileOperation( fileO=0x0, fSource="", fTarget="", flags=0x0, ghwnd=0x0 )
{
	If ( SubStr(fSource,0) != "|" )
	    fSource := fSource . "|"

	If ( SubStr(fTarget,0) != "|" )
	    fTarget := fTarget . "|"

	fsPtr := &fSource
	Loop, % StrLen(fSource)
	If ( *(fsPtr+(A_Index-1)) = 124 )
	    DllCall( "RtlFillMemory", UInt, fsPtr+(A_Index-1), Int,1, UChar,0 )

	ftPtr := &fTarget
	Loop, % StrLen(fTarget)
	If ( *(ftPtr+(A_Index-1)) = 124 )
	    DllCall( "RtlFillMemory", UInt, ftPtr+(A_Index-1), Int,1, UChar,0 )

	VarSetCapacity( SHFILEOPSTRUCT, 30, 0 )                 ; Encoding SHFILEOPSTRUCT
	NextOffset := NumPut( ghwnd, &SHFILEOPSTRUCT )          ; hWnd of calling GUI
	NextOffset := NumPut( fileO, NextOffset+0    )          ; File operation
	NextOffset := NumPut( fsPtr, NextOffset+0    )          ; Source file / pattern
	NextOffset := NumPut( ftPtr, NextOffset+0    )          ; Target file / folder
	NextOffset := NumPut( flags, NextOffset+0, 0, "Short" ) ; options

	DllCall( "Shell32\SHFileOperationA", UInt,&SHFILEOPSTRUCT )
	Return NumGet( NextOffset+0 )
}

SetDirectory(sPath)
{
	sPath:=ExpandEnvVars(sPath)
	if(strEndsWith(sPath,":"))
		sPath .="\"s
	If (WinActive("ahk_class CabinetWClass"))
	{
		if (InStr(FileExist(sPath), "D") || SubStr(sPath,1,3)="::{" || SubStr(sPath,1,6)="ftp://" || strEndsWith(sPath,".search-ms"))
		{
			hWnd:=WinExist("A")
			ShellNavigate(sPath,0,hwnd)
		}
    }
	else if (IsDialog())
		SetDialogDirectory(sPath)
	else
		MsgBox Can't navigate: Wrong window
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

