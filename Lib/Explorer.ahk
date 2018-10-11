; Explorer Windows Manipulations - Sean
; http://www.autohotkey.com/forum/topic20701.html
; 7plus - fragman
; http://code.google.com/p/7plus/
; https://github.com/7plus/7plus

;测试快捷键
#F1::
If(WinActive("ahk_group ccc"))
{
	hWnd:=WinExist("A")
	qqq:= ShellFolder(hwnd,2)
	MsgBox %qqq%
}
Return
;测试快捷键

GetCurrentFolder()
{
	global MuteClipboardList,newfolder
	newfolder=
	If (WinActive("ahk_group ExplorerGroup"))
	{
		hWnd:=WinExist("A")
		Return ShellFolder(hWnd,1)
	}
	If (WinActive("ahk_group DesktopGroup"))
		Return %A_Desktop%
	isdg := IsDialog()
	If (isdg=1) ;No Support for old dialogs for now
	{
		ControlGetText, text , ToolBarWindow322, A
		dgpath:=SubStr(text,InStr(text," "))
		dgpath = %dgpath%
		Return dgpath
	}
	Else If (isdg=2)
	{
		newfolder=types2
		Return 0
	}
Return 0
}

ShellNavigate(sPath, bExplore=False, hWnd=0)
{
	tmm := A_TitleMatchMode
	SetTitleMatchMode, RegEx
	If hWnd || (hWnd :=	WinExist("ahk_class (?:Cabinet|Explore)WClass"))
	{
		SetTitleMatchMode, %tmm%
		For window in ComObjCreate("Shell.Application").Windows
			If (window.hWnd = hWnd)
				window.Navigate2[sPath]
		Until (window.hWnd = hWnd)
	}
	Else If bExplore
		ComObjCreate("Shell.Application").Explore[sPath]
	Else ComObjCreate("Shell.Application").Open[sPath]
}

/*
Returntype=1 当前文件夹
Returntype=2 具有焦点的选中项
Returntype=3 所有选中项
Returntype=4 当前文件夹下所有项目
*/
ShellFolder(hWnd=0,returntype=0,onlyname=0)
{
	If !(window := Explorer_GetWindow(hwnd))
		Return ErrorLevel := "ERROR"
	If (window="desktop")
	{
		If (returntype=2) or (returntype=3)
			selection=1
		If (returntype=4)
			selection=0

		ControlGet, hwWindow, HWND,, SysListView321, ahk_class Progman  ; 桌面文件夹区别对待
		If !hwWindow ; #D mode
			ControlGet, hwWindow, HWND,, SysListView321, A
		ControlGet, files, List, % ( selection ? "Selected":"") "Col1",,ahk_id %hwWindow%
		base := SubStr(A_Desktop,0,1)=="" ? SubStr(A_Desktop,1,-1) : A_Desktop
		Loop, Parse, files, `n, `r
		{
			hpath := base "\" A_LoopField
			IfExist %hpath% ; ignore special icons like Computer (at least for now)
				ret .= hpath "`n"
		}
	Return Trim(ret,"`n")
	}
	Else
	{
		; Find hwnd window
		doc:=window.Document
		If (returntype=1)
		{
			sFolder   := doc.Folder.Self.path
			If onlyname
				sFolder := doc.Folder.Self.name
		}
		If (returntype=2)
		{
			sFocus :=doc.FocusedItem.Path
			If onlyname
				SplitPath, sFocus , sFocus
		}
		If(returntype=3)
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
		If(returntype=4)
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
		sSelect:=Trim(sSelect,"`n")
		If (returntype=1)
			Return   sFolder
		Else If (returntype=2)
			Return   sFocus
		Else If (returntype=3)
			Return   sSelect
		Else If (returntype=4)
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
			If (Item.hwnd = hWnd)
			{
				doc:=Item.Document
				value:=!(Deselect = 1)
				value1:=!(Deselect = 1)+(focus = 1)*16+(MakeVisible = 1)*8
				count := doc.Folder.Items.Count
				If(Clear = 1)
				{
					If(count > 0)
					{
						item := doc.Folder.Items.Item(0)
						doc.SelectItem(item,4)
						doc.SelectItem(item,0)
					}
				}
				If(!IsObject(Select))
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
						If(itemname != "")
						{
							; outputdebug itemname %itemname%
							break
						}
						Sleep 10
					}
					items.Push(item)
					itemnames.Push(itemname)
         ;FileAppend,%itemname%`n,%A_desktop%\123.txt
				}
        ererer:=Select.Length()
				Loop % Select.Length()
				{
					index := A_Index
					filter := Select[A_Index]
					If(filter)
					{
						If(InStr(filter, "*"))
						{
							filter := "\Q" StringReplace(filter, "*", "\E.*\Q", 1) "\E"
							filter := strTrim(filter,"\Q\E")
							Loop % items.Length()
							{
                
								If(RegexMatch(itemnames[A_Index],"i)" filter))
								{
									doc.SelectItem(items[A_Index], index=1 ? value1 : value)
									index++
								}
							}
						}
						Else
						{
							Loop % items.Length()
							{
								If(itemnames[A_Index]=filter)
								{
									doc.SelectItem(items[A_Index], index=1 ? value1 : value)
									index++
									break
								}
							}
						}
					}
				}
				Return
			}
		}
	}
	Else If(hWnd:=WinActive("ahk_group DesktopGroup") && A_PtrSize = 4)
	{
		SplitPath, Select,,,, Select
		SendStr(Select)  ;A版，U版兼容
		; _SendRaw(Select)  ; A版
	}
}

;Returns selected files separated by `n
GetSelectedFiles(FullName=1, hwnd=0)
{
	global MuteClipboardList,Vista7
	If(WinActive("ahk_group ExplorerGroup"))
	{
		If(!hwnd)
			hWnd:=WinExist("A")
		If FullName
		{
			Return ShellFolder(hwnd,3)
			}
		Else
			Return ShellFolder(hwnd,3,1)
	}
	Else If(Vista7 && x:=IsDialog())
	{
		If(x=1)
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
		If(x=1)
			ControlFocus %focussed%, A
		OutputDebug, Selected Files: %result%
		MuteClipboardList:=false
		Return result
	}
	Else If(WinActive("ahk_group DesktopGroup"))
	{
		; If(A_PtrSize = 8) ;64bit doesn't support listview method below yet
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
			; Return result
		; }
		; Else
		; {
			ControlGet, result, List, Selected Col1, SysListView321, A ;This line causes explorer to crash on 64 bit systems when used in a 32 bit AHK build
			If(result)
			{
				Loop, Parse, result, `n ; Rows are delimited by linefeeds (`n).
				{
					hpath := A_Desktop "\" A_LoopField
					IfExist %hpath%
					   result2 .= "`n" A_Desktop "\" A_LoopField
					IfExist  %hpath%.lnk
					   result2 .= "`n" A_Desktop "\" A_LoopField ".lnk"
					}
				Return SubStr(result2,2)
			}
			Else
				Return ""
	}
	; }
}


IsDialog(window=0)
{
	result:=0
	If(window)
		window:="ahk_id " window
	Else
		window:="A"
	WinGetClass,wc,%window%
	If(wc="#32770")
	{
		;Check for new FileOpen dialog
		ControlGet, hwnd, Hwnd , , DirectUIHWND3, %window%
		If(hwnd)
		{
			ControlGet, hwnd, Hwnd , , SysTreeView321, %window%
			If(hwnd)
			{
				ControlGet, hwnd, Hwnd , , Edit1, %window%
				If(hwnd)
				{
					ControlGet, hwnd, Hwnd , , Button2, %window%
					If(hwnd)
					{
						ControlGet, hwnd, Hwnd , , ComboBox2, %window%
						If(hwnd)
						{
						ControlGet, hwnd, Hwnd , , ToolBarWindow323, %window%
						If(hwnd)
							result:=1
						}
					}
				}
			}
		}
		;Check for old FileOpen dialog
		If(!result)
		{
			ControlGet, hwnd, Hwnd , , ToolbarWindow321, %window%          ;工具栏
			If(hwnd)
			{
				ControlGet, hwnd, Hwnd , , SysListView321, %window%        ;文件列表
				If(hwnd)
				{
					ControlGet, hwnd, Hwnd , , ComboBox3, %window%         ;文件类型下拉选择框
					If(hwnd)
					{
						ControlGet, hwnd, Hwnd , , Button3, %window%       ;取消按钮
						If(hwnd)
						{
							;ControlGet, hwnd, Hwnd , , SysHeader321 , %window%    ;详细视图的列标题
							ControlGet, hwnd, Hwnd , , ToolBarWindow322,%window%  ;左侧导航栏
							If(hwnd)
								result:=2
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
			ControlFocus DirectUIHWND3, A
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
hDll := DllCall("LoadLibrary", "str", resDll)
Result := DllCall("LoadString", "uint", hDll, "uint", resID, "str", buf, "int", 128)
Return buf
}

IsRenaming()
{
	If(Vista7)
	 ControlGetFocus focussed, A
  Else
    focussed:=XPGetFocussed()
	If(WinActive("ahk_group ExplorerGroup")) ;Explorer
	{
		If(strStartsWith(focussed,"Edit"))
		{
			If(Vista7)
				ControlGetPos , X, Y, Width, Height, DirectUIHWND3, A
			Else
				ControlGetPos , X, Y, Width, Height, SysListView321, A
			ControlGetPos , X1, Y1, Width1, Height1, %focussed%, A
			If(IsInArea(X1,Y1, X, Y, Width, Height) && IsInArea(X1+Width1,Y1, X, Y, Width, Height) && IsInArea(X1,Y1+Height1, X, Y, Width, Height) && IsInArea(X1+Width1,Y1+Height1, X, Y, Width, Height))
				Return true
		}
	}
	Else If (WinActive("ahk_group DesktopGroup")) ;Desktop
	{
		If(focussed="Edit1")
			Return true
	}
	Else If((x:=IsDialog())) ;FileDialogs
	{
		If(strStartsWith(focussed,"Edit1"))
		{
			;figure out If the the edit control is inside the DirectUIHWND2 or SysListView321
			If(x=1 && Vista7) ;New Dialogs
				ControlGetPos , X, Y, Width, Height, DirectUIHWND2, A
			Else ;Old Dialogs
				ControlGetPos , X, Y, Width, Height, SysListView321, A
			ControlGetPos , X1, Y1, Width1, Height1, %focussed%, A
			If(IsInArea(X1,Y1, X, Y, Width, Height)&&IsInArea(X1+Width1,Y1, X, Y, Width, Height)&&IsInArea(X1,Y1+Height1, X, Y, Width, Height)&&IsInArea(X1+Width1,Y1+Height1, X, Y, Width, Height))
				Return true
		}
	}
	Return false
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

strStartsWith(string,start)
{
	x:=(strlen(start)<=strlen(string)&&Substr(string,1,strlen(start))=start)
	Return x
}

IsInArea(px,py,x,y,w,h)
{
	Return (px>x&&py>y&&px<x+w&&py<y+h)
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

;WinGetClass(window=0)
;{
;WinGetClass, class, window
;Return class
;}

RefreshExplorer()
{
	hwnd:=WinExist("A")
	If (WinActive("ahk_group ExplorerGroup"))
	{
		for Item in ComObjCreate("Shell.Application").Windows
		{
			If (Item.hwnd = hWnd)
			{
				Item.Refresh()
				Send {F5}
				Return
			}
		}
	}
	Else If(IsDialog())
		Send {F5}
	Else
		Send {F5}
}

CreateNewFolder()
{
	global newfolder
global shell32muipath
  ;This is done manually, by creating a text file with the translated name, which is then focussed
	SetFocusToFileView()
If(A_OSversion = "WIN_XP")
    TextTranslated:=TranslateMUI("shell32.dll",30320) ;"New Folder"
Else
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
    If ErrorLevel
	TrayTip,错误,新建文件夹出错！,3
	RefreshExplorer()
  sleep,1000
		SelectFiles(Testpath)
Sleep 50
	Send {F2}
	Return
}

CreateNewTextFile()
{
  global Vista7,txt
	;This is done manually, by creating a text file with the translated name, which is then focussed
	SetFocusToFileView()
	If(Vista7)
    TextTranslated:=TranslateMUI("G:\Windows\notepad.exe",470) ;"New Textfile"
  Else
  {
    newstring:=TranslateMUI("shell32.dll",8587) ;"New"
    TextTranslated:=newstring  " " TranslateMUI("notepad.exe",469) ;"Textfile"
  }
	CurrentFolder :=GetCurrentFolder()
	If CurrentFolder=0
	Return
	Testpath := CurrentFolder "\" TextTranslated "." txt
	i:=1 ;Find free filename
	while FileExist(TestPath)
	{
		i++
		Testpath:=CurrentFolder "\" TextTranslated " (" i ")." txt
	}
	FileAppend , , %TestPath%	;Create file and then select it and rename it
	If ErrorLevel
	{
    TrayTip,错误,新建文本文档出错,3
	Return
	}
	RefreshExplorer()
	Sleep 1000
		SelectFiles(TestPath)
	Sleep 50
    Send     {F2}
	Return
}


IsMouseOverFileList()
{
	CoordMode,Mouse,Relative
	MouseGetPos, MouseX, MouseY,Window , UnderMouse
	WinGetClass, winclass , ahk_id %Window%
	If(Vista7 && (winclass="CabinetWClass" || winclass="ExploreWClass")) ;Win7 Explorer
	{
		ControlGetPos , cX, cY, Width, Height, DirectUIHWND3, A
		If(IsInArea(MouseX,MouseY,cX,cY,Width,Height))
			Return true
	}
	Else If((z:=IsDialog(window))=1) ;New dialogs
	{
		outputdebug new dialog
		ControlGetPos , cX, cY, Width, Height, DirectUIHWND2, A
		outputdebug x %MouseX% y %mousey% x%cx% y%cy% w%width% h%height%
		If(IsInArea(MouseX,MouseY,cX,cY,Width,Height)) ;Checking for area because rename might be in process and mouse might be over edit control
		{
			outputdebug over filelist
			Return true
		}
	}
	Else If(winclass="CabinetWClass" || winclass="ExploreWClass" || z=2) ;Old dialogs or Vista/XP
	{
		ControlGetPos , cX, cY, Width, Height, SysListView321, A
		If(IsInArea(MouseX,MouseY,cX,cY,Width,Height) && UnderMouse = "SysListView321") ;Additional check needed for XP because of header
			Return true
	}
	Return false
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

StringReplace(InputVar, SearchText, ReplaceText = "", All = "") {
	StringReplace, v, InputVar, %SearchText%, %ReplaceText%, %All%
	Return, v
}

ExpandEnvVars(ppath)
{
	VarSetCapacity(dest, 2000)
	DllCall("ExpandEnvironmentStrings", "str", ppath, "str", dest, int, 1999, "Cdecl int")
	Return dest
}

strEndsWith(string,end)
{
	Return strlen(end)<=strlen(string) && Substr(string,-strlen(end)+1)=end
}

strTrim(string, trim)
{
	Return strTrimLeft(strTrimRight(string,trim),trim)
}

strTrimLeft(string,trim)
{
	len:=strLen(trim)
	while(strStartsWith(string,trim))
	{
		StringTrimLeft, string, string, %len%
	}
	Return string
}

strTrimRight(string,trim)
{
	len:=strLen(trim)
	If(strEndsWith(string,trim))
	{
		StringTrimRight, string, string, %len%
	}
	Return string
}


richObject(){
   static richObject
   If !richObject
      richObject := Object("base", Object("print", "objPrint", "copy", "objCopy"
                             , "deepCopy", "objDeepCopy", "equal", "objEqual"
             , "flatten", "objFlatten"  ))

   Return  Object("base", richObject)
}

Explorer_GetPath(hwnd="")
{
   If !(window := Explorer_GetWindow(hwnd))
      Return, ErrorLevel := "ERROR"
   If (window="desktop")
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

Explorer_GetWindow(hwnd="")
{
    ; thanks to jethrow for some pointers here
    WinGet, process, processName, % "ahk_id" hwnd := hwnd? hwnd:WinExist("A")
    WinGetClass class, ahk_id %hwnd%

    If (process!="explorer.exe")
        Return
    If (class ~= "(Cabinet|Explore)WClass")
    {
        for window in ComObjCreate("Shell.Application").Windows
           If (window.hwnd==hwnd)
               Return window
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
		If((Vista7 && focussed="DirectUIHWND3") || (A_OSVersion ="XP" && focussed="SysListView321"))
			Return true
	}
		If(WinActive("ahk_group DesktopGroup"))
	{
		If((Vista7 && focussed="SysListView321") || (A_OSVersion ="XP" && focussed="SysListView321"))
			Return true
	}
	Return false
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
   If ( !sPath  )
      Return
   If !win_hwnd
   {
      Gui,SHELL_CONTEXT:New, +hwndwin_hwnd
      Gui,Show
   }
   
   If sPath Is Not Integer
      DllCall("shell32\SHParseDisplayName", "Wstr", sPath, "Ptr", 0, "Ptr*", pidl, "Uint", 0, "Uint*", 0)
      ;This function is the preferred method to convert a string to a pointer to an item identifier list (PIDL).
   Else
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
   If (e != 0)
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
   Return idn
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
	If(strEndsWith(sPath,":"))
		sPath .="\"s
	If (WinActive("ahk_class CabinetWClass"))
	{
		If (InStr(FileExist(sPath), "D") || SubStr(sPath,1,3)="::{" || SubStr(sPath,1,6)="ftp://" || strEndsWith(sPath,".search-ms"))
		{
			hWnd:=WinExist("A")
			ShellNavigate(sPath,0,hwnd)
		}
    }
	Else If (IsDialog())
		SetDialogDirectory(sPath)
	Else
		MsgBox 不能导航: 当前窗口不是资源管理器窗口。
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

