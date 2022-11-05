PrewFile:
autoexit := 0
SplitPath, ATA_filepath,,, Prew_File_Ext
if(Prew_File_Ext = "")
	Prew_File_Ext := "txt"
Prew_Cmd := SkSub_Regex_IniRead(ATA_settingFile, "FilePrew", "i)(^|\|)" Prew_File_Ext "($|\|)")
;msgbox % Prew_Cmd " - " Prew_File_Ext
if Prew_Cmd && (Prew_Cmd != "error")
{
	GUI, PreWWin:Default
	If IsLabel("Cando_" . Prew_Cmd . "_prew")
		Gosub % "Cando_" .  Prew_Cmd . "_prew"
}
else
autoexit := 1
return

PreWWinGuiEscape:
PreWWinGuiClose:
if gif_prew
{
	hgif1.Pause()
	sleep, 500
	hgif1 := ""
	gif_prew:=0
exitapp
}
if Tmp_Val
	Tmp_Val := ""
Gui, PreWWin:Destroy
exitapp

PreWWinGuiSize:
GuiControl, Move, displayArea, % "x0 y0 w" A_GuiWidth " h" (A_GuiHeight-28)
GuiControl, Move, WMP,x0 y0 w%A_GuiWidth% h%A_GuiHeight%
return

Cando_text_prew:
File_Encode := File_GetEncoding(ATA_filepath)
FileGetSize, File_Size, % ATA_filepath
FileEncoding, % File_Encode
if (File_Size > 102400) && ((File_Encode = "CP936") or (File_Encode = "UTF-8-RAW"))
{
	FileReadLine, LineVar, % ATA_filepath, 1
		MsgBox, 36, 选择源文件的编码ANSI/UTF-8, 文件第一行内容: %LineVar%`n当前使用编码为: %File_Encode%`n文本正常显示点击"是"，否则点击"否"。, 2
	IfMsgBox, No
	{
		File_Encode := (File_Encode = "CP936") ? "UTF-8" : "CP936"
		FileEncoding, % File_Encode
	}
	IfMsgBox, yes
		File_Encode := (File_Encode = "CP936") ? "CP936" : "UTF-8"
}

if TF_CountLines(ATA_filepath)>100
{
	Loop, Read, % ATA_filepath
	{
		FileR_TFC .= A_LoopReadLine "`n"
		if a_index >100
		break
	}
}
else
	FileRead, FileR_TFC, %ATA_filepath%
FileEncoding
Gui, +ReSize +MinSize800x540
Gui, Add, Edit, w800 Multi ReadOnly vdisplayArea,
Gui,PreWWin:Show, w800 h540 Center, % ATA_filepath " - 文件预览"
GuiControl,, displayArea, %FileR_TFC%
;GuiControl, Move, displayArea, x0 y0 w800 h510
FileR_TFC := File_Encode := File_Size := ""
return

Cando_music_prew:
Gui, +LastFound +Resize
Gui, Add, ActiveX, x0 y0 w0 h0 vWMP, WMPLayer.OCX
WMP.Url := ATA_filepath
Gui, PreWWin:Show, w500 h300 Center,% ATA_filepath " - 文件预览"
return

Cando_pic_prew:
if !prewpToken
prewpToken := Gdip_Startup()
GUI, +AlwaysOnTop +Owner
Gui, Margin, 0, 0
pBitmap:=Gdip_CreateBitmapFromFile(ATA_filepath)
WidthO  :=Gdip_GetImageWidth(pBitmap)
HeightO := Gdip_GetImageHeight(pBitmap)
Gdip_DisposeImage(pBitmap)
Propor  := (A_ScreenHeight/HeightO < A_ScreenWidth/WidthO ? A_ScreenHeight/HeightO : A_ScreenWidth/WidthO)
Propor:=Propor > 1?1:Propor
	hW  := Floor(WidthO * Propor)
	hH := Floor(HeightO * Propor)
Gui, Add, Picture,w%hw% h%hh%, %ATA_filepath%
Gui,PreWWin: Show,  Center, % ATA_filepath " - 文件预览"
return

Cando_html_prew:
gosub, IE_Open
WB.Navigate(ATA_filepath)
return

IE_Open:
Gui, +ReSize
Gui Add, ActiveX, xm w1050 h800 vWB, Shell.Explorer
WB.silent := true
ComObjConnect(WB, WB_events)
IOleInPlaceActiveObject_Interface := "{00000117-0000-0000-C000-000000000046}"
pipa := ComObjQuery(WB, IOleInPlaceActiveObject_Interface)
TranslateAccelerator := NumGet(NumGet(pipa+0) + 5*A_PtrSize)
OnMessage(0x0100, "WM_KeyPress") ; WM_KEYDOWN 
OnMessage(0x0101, "WM_KeyPress") ; WM_KEYUP   
Gui, PreWWin:Show ,,% ATA_filepath " - 文件预览"
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

Cando_gif_prew:
if !prewpToken
	prewpToken := Gdip_Startup()
GUI, -Caption +AlwaysOnTop +Owner
Gui, Margin, 0, 0
pBitmap:=Gdip_CreateBitmapFromFile(ATA_filepath)
Gdip_GetImageDimensions(pBitmap, width, height)
Gui, Add, Picture,w%width% h%height% 0xE hwndhwndGif1
Gdip_DisposeImage(pBitmap)
hgif1 := new Gif(ATA_filepath, hwndGif1)
Gui,PreWWin: Show, AutoSize Center, % ATA_filepath " - 文件预览"
hgif1.Play()
gif_prew:=true
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

Cando_pdf_prew:
	gosub, IE_Open
	WB.Navigate("https://wyagd001.github.io/pdfjs/es5/web/viewer.html?file=blank.pdf")  ; IE浏览器
	WBStartTime := A_TickCount
	loop 
	{
		WBElapsedTime := A_TickCount - WBStartTime
		Sleep, 500
	}
	Until (wb.Document.Readystate = "Complete") or WBElapsedTime>5000
	settimer,autoopenpdf,-1500  ; 模拟选择文件
	wb.document.getElementById("openFile").click()
return

autoopenpdf:
WinWaitActive,ahk_class #32770,,1000
ControlSetText, edit1, %ATA_filepath%, ahk_class #32770
sleep,100
send {enter}
return

Cando_md_html_prew:
FileCopy, % ATA_filepath, % A_ScriptDir "\..\html\html-markdown-preview\apidoc.md", true
gosub, IE_Open
WB.Navigate(A_ScriptDir "\..\html\html-markdown-preview\index.html")
return

Cando_wps_prew:
Tmp_Str := xd2txlib.ExtractText(ATA_filepath)
Gui, +ReSize +MinSize800x540
Gui, Add, Edit, w800 h520 Multi ReadOnly vdisplayArea, %Tmp_Str%
Gui,PreWWin:Show, w800 h540 Center, % ATA_filepath " - 文件预览"
sendmessage, 0xB1, -1, -1, Edit1, 文件预览
Tmp_Str := ""
return

Cando_xls_prew:
IniRead, AutoHotkeyU32, %ATA_settingFile%, app, AutoHotkeyU32, %A_Space%
run, "%AutoHotkeyU32%" "%A_ScriptDir%\..\Plugins\输出excel数据到GUI.ahk" "%ATA_filepath%"
exitapp

Cando_rar_prew:
	IniRead, 7z, %ATA_settingFile%, app, 7z, %A_Space%
	IniRead, winrar, %ATA_settingFile%, app, winrar, %A_Space%
	if !7z
	{
		msgbox 没有找到 7z 程序，请检查设置文件中App的7z条目。 压缩包无法预览，程序退出。
		exitapp
	}
	; 提取整行
	Tmp_Str := cmdSilenceReturn("for /f ""skip=12 tokens=* delims=-"" `%a in ('^;""" 7z """ ""l"" " """" ATA_filepath """') do @echo `%a")
	if FileExist(winrar)
	{
		包_注释文件 := A_Temp "\123_" A_Now ".txt"
		RunWait, %comspec% /c ""%winrar%" cw "%ATA_filepath%" "%包_注释文件%"",,hide
		FileRead, 包_注释, %包_注释文件%
	}
	;msgbox % Tmp_Str
	StringReplace, Tmp_Str, Tmp_Str, `n, `n, UseErrorLevel
	Tmp_Lines :=  ErrorLevel
	Tmp_Val := ""
	Loop, parse, Tmp_Str, `n, `r
	{
		NewStr := SubStr(A_LoopField, 54)
		if instr(NewStr, "----")
			continue
		if (A_Index = 1) or (A_Index >= Tmp_Lines)
			continue
		Tmp_FileName := trim(NewStr)
		if (Tmp_FileName = "")
			continue
		if (Tmp_FileName = "Name")
			continue
		Tmp_Val .= Tmp_FileName "`n"
	}
Sort, Tmp_Val
Gui, +ReSize
ImageListID := IL_Create(5)  ; 创建初始容量为 5 个图标的图像列表.
Loop 5  ; 加载一些标准系统图标到图像列表中.
    IL_Add(ImageListID, "shell32.dll", A_Index)
Gui, Add, TreeView,r30 w800 h500 ImageList%ImageListID%
if 包_注释
	Gui, Add, Edit, r5 w800 h100 readonly, %包_注释%
Gui, Add, button, gtree2text, 显示文本
AddBranchesToTree(Tmp_Val)
Gui,PreWWin: Show, AutoSize Center, % ATA_filepath " - 文件预览"
;GuiControl,, displayArea, %Tmp_Val%
Tmp_Str := Tmp_FileName := Tmp_Lines := 包_注释 := ""
return

tree2text:
GUI,66:Destroy
Gui,66:Default 
Gui, Add, Edit, w600 h300 ReadOnly, %ATA_filepath%`n%Tmp_Val%
Gui show, AutoSize Center, % ATA_filepath " - 文件预览"
return

cmdSilenceReturn(command){
	FileR_CMDReturn := ""
	cmdFN := "RunAnyCtrlCMD.log"
	try{
		fullCommand = %ComSpec% /c "%command% >> %cmdFN%"
		RunWait, %fullCommand%, %A_Temp%, Hide

		FileRead, FileR_CMDReturn, %A_Temp%\%cmdFN%
		FileDelete, %A_Temp%\%cmdFN%
	}catch{}
return  FileR_CMDReturn
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

SkSub_Regex_IniRead(ini, sec, reg)      ; 正则方式的读取，等号左侧符合正则条件
{  ; 在ini的某个段内，查找符合某正则规则的字符串，如果找到返回value值。找不到，则返回 Error
	IniRead, keylist, %ini%, %sec%,
	Loop, Parse, keylist, `n
	{
		t := RegExReplace(A_LoopField, "=.*?$")
		If(RegExMatch(t, reg))
		{
			Return % RegExReplace(A_LoopField, "^.*?=")
			Break
		}
	}
	Return "Error"
}