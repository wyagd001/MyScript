#ifWinActive, ahk_group MyPreWWinGroup
$Space::
gosub PreWWinGuiClose
return

#ifWinActive ahk_Group ccc
$Space::
;tooltip % A_Cursor " - " IsRenaming()
;重命名时，直接发送空格
if(A_Cursor="IBeam") or IsRenaming()
{
 send {space}
 return
}
Files := ""
Files := ShellFolder(0,2)
if !Files or f_IsFolder(Files)
{
 send {space}
 return
}
SplitPath,Files,,,Files_Ext
if(Files_Ext="")
{
 send {space}
 return
}
Candy_Cmd:=SkSub_Regex_IniRead(Candy_ProFile_Ini, "FilePrew", "i)(^|\|)" Files_Ext "($|\|)")
if Candy_Cmd
{
GUI, PreWWin:Destroy
GUI, PreWWin:Default
GUI, PreWWin:+hwndmyguihwnd
GroupAdd, MyPreWWinGroup, ahk_id %myguihwnd%
If IsLabel("Cando_" . Candy_Cmd . "_prew")
	Gosub % "Cando_" .  Candy_Cmd . "_prew"
} 
return
#ifWinActive

PreWWinGuiEscape:
PreWWinGuiClose:
if gif_prew
{
hgif1.Pause()
sleep,500
hgif1 := ""
gif_prew:=0
return
}
if Tmp_value
Tmp_value:=""
Gui,PreWWin:Destroy
;if prewpToken
;{
;Gdip_ShutDown(prewpToken)
;sleep,200
;}
return

PreWWinGuiSize:
GuiControl, Move, displayArea, x0 y0 w%A_GuiWidth% h%A_GuiHeight%
GuiControl, Move, WMP,x0 y0 w%A_GuiWidth% h%A_GuiHeight%
return

; 详情  https://github.com/mozilla/pdf.js
Cando_pdf_prew:
	gosub,IE_Open
	WB.Navigate("https://mozilla.github.io/pdf.js/es5/web/viewer.html?file=blank.pdf")  ; 老版浏览器
	WBStartTime := A_TickCount
	loop 
	{
		WBElapsedTime := A_TickCount - WBStartTime
		Sleep, 500
	}
	Until (wb.Document.Readystate = "Complete") or WBElapsedTime>5000
	settimer,autoopenpdf,-1500
	wb.document.getElementById("openFile").click()
return

Cando_html_prew:
gosub,IE_Open
WB.Navigate(Files)
return

IE_Open:
if tipGui_Init
	TipsState(0)
Gui, +ReSize
Gui Add, ActiveX,xm w1050 h800 vWB, Shell.Explorer
WB.silent := true
ComObjConnect(WB, WB_events)
IOleInPlaceActiveObject_Interface := "{00000117-0000-0000-C000-000000000046}"
pipa := ComObjQuery( WB, IOleInPlaceActiveObject_Interface )
TranslateAccelerator := NumGet( NumGet( pipa+0 ) + 5*A_PtrSize )
OnMessage( 0x0100, "WM_KeyPress" ) ; WM_KEYDOWN 
OnMessage( 0x0101, "WM_KeyPress" ) ; WM_KEYUP   

Gui, PreWWin:Show ,,% Files " - 文件预览"
return

autoopenpdf:
WinWaitActive,ahk_class #32770,,1000
ControlSetText, edit1, %Files%, ahk_class #32770
sleep,100
send {enter}
return

class WB_events
{
	;for more events and other, see http://msdn.microsoft.com/en-us/library/aa752085

	NavigateComplete2(wb) {
		;~ wb.Stop() ;blocked all navigation, we want our own stuff happening
	}
	DownloadComplete(wb, NewURL) {
		;~ wb.Stop() ;blocked all navigation, we want our own stuff happening
	}
	DocumentComplete(wb, NewURL) {
		;~ wb.Stop() ;blocked all navigation, we want our own stuff happening
	}
}

WM_KeyPress( wParam, lParam, nMsg, hWnd ) {

Global WB, pipa, TranslateAccelerator
Static Vars := "hWnd | nMsg | wParam | lParam | A_EventInfo | A_GuiX | A_GuiY" 

  WinGetClass, ClassName, ahk_id %hWnd%

  If ( ClassName = "Shell DocObject View" && wParam = 0x09 ) {
    WinGet, hIES, ControlListHwnd, ahk_id %hWnd% ; Find child of 'Shell DocObject View'
    ControlFocus,, ahk_id %hIES%
    Return 0
  }

  If ( ClassName = "Internet Explorer_Server" ) {

    VarSetCapacity( MSG, 28, 0 )                   ; MSG STructure    http://goo.gl/4bHD9Z
    Loop, Parse, Vars, |, %A_Space%
      NumPut( %A_LoopField%, MSG, ( A_Index-1 ) * A_PtrSize )

    Loop 2  ; IOleInPlaceActiveObject::TranslateAccelerator method    http://goo.gl/XkGZYt
      r := DllCall( TranslateAccelerator, UInt,pipa, UInt,&MSG )
    Until wParam != 9 || WB.document.activeElement != ""

    IfEqual, R, 0, Return, 0         ; S_OK: the message was translated to an accelerator.

  }
}

Cando_music_prew:
Gui, +LastFound +Resize
Gui, Add, ActiveX, x0 y0 w0 h0 vWMP, WMPLayer.OCX
WMP.Url := files
Gui, PreWWin:Show, w500 h300 Center,% Files " - 文件预览"
return

Cando_pic_prew:
if !prewpToken
prewpToken := Gdip_Startup()        
GUI, +AlwaysOnTop +Owner
Gui, Margin, 0, 0
pBitmap:=Gdip_CreateBitmapFromFile(files)
WidthO  :=Gdip_GetImageWidth(pBitmap)
HeightO := Gdip_GetImageHeight(pBitmap)
Gdip_DisposeImage(pBitmap)
Propor  := (A_ScreenHeight/HeightO < A_ScreenWidth/WidthO ? A_ScreenHeight/HeightO : A_ScreenWidth/WidthO)
Propor:=Propor > 1?1:Propor
	hW  := Floor(WidthO * Propor)
	hH := Floor(HeightO * Propor)
Gui, Add, Picture,w%hw% h%hh%, %files%
Gui,PreWWin: Show,  Center, % Files " - 文件预览"
return

/*
Cando_rar_prew:
textvalue:= cmdSilenceReturn("for /f ""eol=- skip=8 tokens=5*"" `%a in ('D:\Progra~1\Tool\WinRAR\unRAR.exe l -c- " """" files """') do @echo `%a `%b")
Gui, +ReSize
Gui, Add, Edit, w800 h600 ReadOnly vdisplayArea,
Gui,PreWWin: Show, AutoSize Center, % Files " - 文件预览"
GuiControl,, displayArea,%textvalue%
textvalue=
return
*/

Cando_rar_prew:
	if !7z
	{
		msgbox 7z 变量未设置，请在选项→运行→自定义短语中添加。`n例如: 7z=G:\Program Files\7z\7z.exe
	return
	}
	textvalue:= cmdSilenceReturn("for /f ""skip=12 tokens=5,* eol=-"" `%a in ('^;""" 7z """ ""l"" " """" files """') do @echo `%a `%b")
	;msgbox % textvalue
	Loop, parse, textvalue, `n, `r
	{
		Tmp_val:=trim(A_LoopField)
		if (tmp_pos:=instr(Tmp_val, " "))
		{
			StringTrimLeft, Tmp_val2, Tmp_val, % tmp_pos
			if (Tmp_val2 = "Name") or (Tmp_val2 = "folders")
				continue
			if RegExMatch(Tmp_val,"^[0-9]+\s")  ; 不能正确得到7z压缩包中以数字空格开头的文件名
				Tmp_value .= Tmp_val2 "`n"
			else
				Tmp_value .= Tmp_val "`n"
		}
		else
			if Tmp_val
				Tmp_value .= A_LoopField "`n"
	}
Sort, Tmp_value
Gui, +ReSize
ImageListID := IL_Create(5)  ; 创建初始容量为 5 个图标的图像列表.
Loop 5  ; 加载一些标准系统图标到图像列表中.
    IL_Add(ImageListID, "shell32.dll", A_Index)
Gui, Add, TreeView,r30 w800 h580 ImageList%ImageListID%
Gui, Add, button,gtree2text,显示文本
AddBranchesToTree(Tmp_value)

Gui,PreWWin: Show, AutoSize Center, % Files " - 文件预览"
;GuiControl,, displayArea, %Tmp_value%
textvalue:=Tmp_val:=""
return

tree2text:
Gui,66:Default 
Gui, Add, Edit, w600 h300 ReadOnly,%Files%`n%Tmp_value%
Gui show, AutoSize Center, % Files " - 文件预览"
return

cmdSilenceReturn(command){
	CMDReturn:=""
	cmdFN:="RunAnyCtrlCMD.log"
	try{
    fullCommand = %ComSpec% /c "%command% >> %cmdFN%"
		RunWait, %fullCommand%, %A_Temp%, Hide

		FileRead, CMDReturn, %A_Temp%\%cmdFN%
		FileDelete,%A_Temp%\%cmdFN%
	}catch{}
return  CMDReturn
}

; 来源网址: https://autohotkey.com/board/topic/39809-script-to-open-list-of-filesfolders-in-treeview/
AddBranchesToTree(filelist)
{
	level = 0
	parent0 = 0
	Loop, parse, filelist, `n, `r
	{
		if A_LoopField =
			continue
		stringsplit, parts, A_LoopField, \	; drive + folders ( + file)
		if level = 0				; first record, insert all parts
		{
			gosub build_tree
			continue
		}
		ifinstring, A_LoopField, %hprev_file%	; sub folders or files
		{
			gosub build_tree
			continue
		}
							; other drive or folder
		line := A_LoopField              
		if (parts0 > level)			; ignore parts > level
			loop, % parts0 - level - 1
				StringLeft, line, line, % InStr(line,"\",false,0)
		else
			level := parts0			; set level to no of parts
		loop, % level
		{
			StringLeft, line, line, % InStr(line,"\",false,0)-1  
			level--
			if level = 0			; other drive
			{
				hprev_file =
				bs =
			}
		else					; find corresponding level
			{
				hprev_file := file%level%
				ifnotinstring, line, %hprev_file%
					continue
				if level = 0
					level++
			}
			gosub build_tree
			break
		}
	}
	return

build_tree:
	loop, % parts0 - level
	{
        
		prev_parent = parent%level%
		level++
;msgbox % parts0 "-" level "-" A_LoopField
		ifnotinstring parts%level%,.
		parent%level% := tv_add(parts%level%, %prev_parent%, "expand Icon4")
		else
 parent%level% := tv_add(parts%level%, %prev_parent%, "expand")
		if level <> 1
			bs = \
		file%level% := hprev_file bs parts%level%
		hprev_file := file%level%
    ;msgbox % hprev_file
	}
	return
}

Cando_gif_prew:
if !prewpToken
prewpToken := Gdip_Startup()
GUI, -Caption +AlwaysOnTop +Owner
Gui, Margin, 0, 0
pBitmap:=Gdip_CreateBitmapFromFile(files)
Gdip_GetImageDimensions(pBitmap, width, height)
Gui, Add, Picture,w%width% h%height% 0xE hwndhwndGif1
Gdip_DisposeImage(pBitmap)
hgif1 := new Gif(Files, hwndGif1)
Gui,PreWWin: Show, AutoSize Center, % Files " - 文件预览"
hgif1.Play()
gif_prew:=true
return

Cando_text_prew:
File_Encode := File_GetEncoding(files)
FileGetSize, File_Size, % files
FileEncoding, % File_Encode
	if (File_Size > 102400) && ((File_Encode = "CP936") or (File_Encode = "UTF-8-RAW"))
	{
		FileReadLine, LineVar, % files, 1
		MsgBox, 36, 选择源文件的编码ANSI/UTF-8, 文件第一行内容: %LineVar%`n当前使用编码为: %File_Encode%`n文本正常显示点击"是"，否则点击"否"。, 2
		IfMsgBox, No
		{
			File_Encode := (File_Encode = "CP936") ? "UTF-8" : "CP936"
			FileEncoding, % File_Encode
		}
		IfMsgBox, yes
			File_Encode := (File_Encode = "CP936") ? "CP936" : "UTF-8"
	}

if TF_CountLines(files)>100
{
Loop, Read,% files
{
textvalue .= A_LoopReadLine "`n"
if a_index >100
break
}
}
else
FileRead,textvalue,%files%
FileEncoding
Gui, +ReSize
Gui, Add, Edit, w800 h600 ReadOnly vdisplayArea,
Gui,PreWWin: Show, AutoSize Center, % Files " - 文件预览"
GuiControl,, displayArea,%textvalue%
textvalue := File_Encode := File_Size := ""
return

; https://www.autohotkey.com/boards/viewtopic.php?p=112572
class Gif
{	
	__New(file, hwnd)
	{
		this.file := file
		this.hwnd := hwnd
		this.pBitmap := Gdip_CreateBitmapFromFile(this.file)
		Gdip_GetImageDimensions(this.pBitmap, width, height)
		this.width := width, this.height := height
		this.isPlaying := false
		
		DllCall("Gdiplus\GdipImageGetFrameDimensionsCount", "ptr", this.pBitmap, "uptr*", frameDimensions)
		this.SetCapacity("dimensionIDs", 32)
		DllCall("Gdiplus\GdipImageGetFrameDimensionsList", "ptr", this.pBitmap, "uptr", this.GetAddress("dimensionIDs"), "int", frameDimensions)
		DllCall("Gdiplus\GdipImageGetFrameCount", "ptr", this.pBitmap, "uptr", this.GetAddress("dimensionIDs"), "int*", count)
		this.frameCount := count
		this.frameCurrent := -1
		this.frameDelay := this.GetFrameDelay(this.pBitmap)
	}

	; Return a zero-based array, containing the frames delay (in milliseconds)
	GetFrameDelay(pImage) {
		static PropertyTagFrameDelay := 0x5100

		DllCall("Gdiplus\GdipGetPropertyItemSize", "Ptr", pImage, "UInt", PropertyTagFrameDelay, "UInt*", ItemSize)
		VarSetCapacity(Item, ItemSize, 0)
		DllCall("Gdiplus\GdipGetPropertyItem"    , "Ptr", pImage, "UInt", PropertyTagFrameDelay, "UInt", ItemSize, "Ptr", &Item)

		PropLen := NumGet(Item, 4, "UInt")
		PropVal := NumGet(Item, 8 + A_PtrSize, "UPtr")

		outArray := []
		Loop, % PropLen//4 {
			if !n := NumGet(PropVal+0, (A_Index-1)*4, "UInt")
				n := 10
			outArray[A_Index-1] := n * 10
		}
		return outArray
	}
	
	Play()
	{
		this.isPlaying := true
		fn := this._Play.Bind(this)
		this._fn := fn
		SetTimer, % fn, -1
	}
	
	Pause()
	{
		this.isPlaying := false
		fn := this._fn
		SetTimer, % fn, Delete
		sleep,200
		fn:=this._fn:=""
	}
	
	_Play()
	{
		this.frameCurrent := (this.frameCurrent = this.frameCount-1) ? 0 : this.frameCurrent + 1
		DllCall("Gdiplus\GdipImageSelectActiveFrame", "ptr", this.pBitmap, "uptr", this.GetAddress("dimensionIDs"), "int", this.frameCurrent)
		hBitmap := Gdip_CreateHBITMAPFromBitmap(this.pBitmap)
		SetImage(this.hwnd, hBitmap)
		DeleteObject(hBitmap)

		fn := this._fn
		if fn
		SetTimer, % fn, % -1 * this.frameDelay[this.frameCurrent]
	}
	
	__Delete()
	{
		Gdip_DisposeImage(this.pBitmap)
		Object.Delete("dimensionIDs")
		CF_ToolTip("成功释放对象!",3000)
	}
}