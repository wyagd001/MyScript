#ifWinActive, ahk_group MyPreWWinGroup
$Space::
gosub PreWWinGuiClose
return

F2::
ControlGet, Tmp_V, Selected,, Edit1
if !Tmp_V
{
	try {
		GUI, PreWWin:Default
		Tmp_id := TV_GetSelection()
		TV_GetText(Tmp_V, Tmp_id)
		SplitPath, Tmp_V, , , , Tmp_V
	}
}
if !Tmp_V
return
SplitPath, Prew_File,, Prew_File_ParentPath, Prew_File_Ext
FileMove, % Prew_File, % Prew_File_ParentPath "\" Tmp_V "." Prew_File_Ext  ; 存在同名文件不覆盖
return

del::
MsgBox,4,删除提示,确定要把文件放入回收站吗？`n`n%Prew_File%
IfMsgBox Yes
	FileRecycle,%Prew_File%
return

F5::
run, %Prew_File%
return

F6::
run, % notepad2 " " Prew_File
return

#ifWinActive ahk_Group Prew_Group
$Space::
;tooltip % A_Cursor " - " IsRenaming()
;重命名时，直接发送空格
if(A_Cursor="IBeam") or IsRenaming()
{
	send {space}
	return
}
Prew_File := ""
if WinActive("ahk_class EVERYTHING") or WinActive("ahk_class TTOTAL_CMD") or WinActive("ahk_class #32770")
	Prew_File := GetSelText()
else
	Prew_File := ShellFolder(0,2)
if !Prew_File or CF_IsFolder(Prew_File)
{
	send {space}
	return
}
SplitPath, Prew_File,,, Prew_File_Ext
if(Prew_File_Ext = "")
{
	send {space}
	return
}
Candy_Cmd:=SkSub_Regex_IniRead(Candy_ProFile_Ini, "FilePrew", "i)(^|\|)" Prew_File_Ext "($|\|)")
if Candy_Cmd
{
	GUI, PreWWin:Destroy
	GUI, PreWWin:Default
	GUI, PreWWin:+hwndh_PrewGui
	GroupAdd, MyPreWWinGroup, ahk_id %h_PrewGui%
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
	sleep, 500
	hgif1 := ""
	gif_prew:=0
return
}
if Tmp_Val
	Tmp_Val := ""
Gui, PreWWin:Destroy
;if prewpToken
;{
;Gdip_ShutDown(prewpToken)
;sleep,200
;}
return

PreWWinGuiSize:
GuiControl, Move, displayArea, % "x0 y0 w" A_GuiWidth " h" (A_GuiHeight-28)
GuiControl, Move, WMP,x0 y0 w%A_GuiWidth% h%A_GuiHeight%
return

; 详情  https://github.com/mozilla/pdf.js
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

Cando_html_prew:
gosub, IE_Open
WB.Navigate(Prew_File)
return

Cando_wps_prew:
Tmp_Str := xd2txlib.ExtractText(Prew_File)
Gui, +ReSize +MinSize800x540
Gui, Add, Edit, w800 h520 Multi ReadOnly vdisplayArea, %Tmp_Str%
Gui,PreWWin:Show, w800 h540 Center, % Prew_File " - 文件预览"
sendmessage, 0xB1, -1, -1, Edit1, 文件预览
Tmp_Str := ""
return

/*
; https://open.wps.cn/docs/office
Cando_wps_prew:
if !(oWord := ComObjCreate("kWPS.Application"))
return
oWord.Visible := false 
oWord.Documents.Open(Prew_File)
Tmp_Str := oWord.ActiveDocument.range(0,1000).text
oWord.Quit()
Tmp_Str := StrReplace(Tmp_Str, "`r", "`r`n")
Gui, +ReSize +MinSize800x540
Gui, Add, Edit, w800 h520 Multi ReadOnly vdisplayArea,%Tmp_Str%
Gui,PreWWin:Show, w800 h540 Center, % Prew_File " - 文件预览"
Tmp_Str := ""
return
*/

Cando_xls_prew:
输出excel数据到GUI:
run, "%A_AhkPath%" "%A_ScriptDir%\Plugins\输出excel数据到GUI.ahk" "%Prew_File%"
return

IE_Open:
if tipGui_Init
	TipsState(0)
Gui, +ReSize
Gui Add, ActiveX, xm w1050 h800 vWB, Shell.Explorer
WB.silent := true
ComObjConnect(WB, WB_events)
IOleInPlaceActiveObject_Interface := "{00000117-0000-0000-C000-000000000046}"
pipa := ComObjQuery(WB, IOleInPlaceActiveObject_Interface)
TranslateAccelerator := NumGet(NumGet(pipa+0) + 5*A_PtrSize)
OnMessage(0x0100, "WM_KeyPress") ; WM_KEYDOWN 
OnMessage(0x0101, "WM_KeyPress") ; WM_KEYUP   

Gui, PreWWin:Show ,,% Prew_File " - 文件预览"
return

autoopenpdf:
WinWaitActive,ahk_class #32770,,1000
ControlSetText, edit1, %Prew_File%, ahk_class #32770
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
WMP.Url := Prew_File
Gui, PreWWin:Show, w500 h300 Center,% Prew_File " - 文件预览"
return

Cando_pic_prew:
if !prewpToken
prewpToken := Gdip_Startup()        
GUI, +AlwaysOnTop +Owner
Gui, Margin, 0, 0
pBitmap:=Gdip_CreateBitmapFromFile(Prew_File)
WidthO  :=Gdip_GetImageWidth(pBitmap)
HeightO := Gdip_GetImageHeight(pBitmap)
Gdip_DisposeImage(pBitmap)
Propor  := (A_ScreenHeight/HeightO < A_ScreenWidth/WidthO ? A_ScreenHeight/HeightO : A_ScreenWidth/WidthO)
Propor:=Propor > 1?1:Propor
	hW  := Floor(WidthO * Propor)
	hH := Floor(HeightO * Propor)
Gui, Add, Picture,w%hw% h%hh%, %Prew_File%
Gui,PreWWin: Show,  Center, % Prew_File " - 文件预览"
return

/*
Cando_rar_prew:
textvalue:= cmdSilenceReturn("for /f ""eol=- skip=8 tokens=5*"" `%a in ('D:\Progra~1\Tool\WinRAR\unRAR.exe l -c- " """" Prew_File """') do @echo `%a `%b")
Gui, +ReSize
Gui, Add, Edit, w800 h600 ReadOnly vdisplayArea,
Gui,PreWWin: Show, AutoSize Center, % Prew_File " - 文件预览"
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
	; 提取整行
	Tmp_Str := cmdSilenceReturn("for /f ""skip=12 tokens=* delims=-"" `%a in ('^;""" 7z """ ""l"" " """" Prew_File """') do @echo `%a")
	if FileExist(winrar)
	{
		包_注释文件 := A_Temp "\123_" A_Now ".txt"
		RunWait, %comspec% /c ""%winrar%" cw "%Prew_File%" "%包_注释文件%"",,hide
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
Gui, Add, TreeView,r30 w800 h580 ImageList%ImageListID%
if 包_注释
	Gui, Add, Edit, r3 w800 readonly, %包_注释%
Gui, Add, button, gtree2text, 显示文本
Gui, Add, button, xp+70 yp+0 gPf2Unarchiver, 智能解压
Gui, Add, StatusBar,, 快捷键: 1. 选中项目后按 F2 以选中项目重命名文件. 2. Del 删除文件. 3. F5 运行. 4. F6 编辑.
AddBranchesToTree(Tmp_Val)
Gui,PreWWin: Show, AutoSize Center, % Prew_File " - 文件预览"
;GuiControl,, displayArea, %Tmp_Val%
Tmp_Str := Tmp_FileName := Tmp_Lines := 包_注释 := ""
return

tree2text:
GUI,66:Destroy
Gui,66:Default 
Gui, Add, Edit, w600 h300 ReadOnly,%Prew_File%`n%Tmp_Val%
Gui show, AutoSize Center, % Prew_File " - 文件预览"
return

Pf2Unarchiver:
7z_smart_Unarchiver(Prew_File)
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

Cando_gif_prew:
if !prewpToken
	prewpToken := Gdip_Startup()
GUI, -Caption +AlwaysOnTop +Owner
Gui, Margin, 0, 0
pBitmap:=Gdip_CreateBitmapFromFile(Prew_File)
Gdip_GetImageDimensions(pBitmap, width, height)
Gui, Add, Picture,w%width% h%height% 0xE hwndhwndGif1
Gdip_DisposeImage(pBitmap)
hgif1 := new Gif(Prew_File, hwndGif1)
Gui,PreWWin: Show, AutoSize Center, % Prew_File " - 文件预览"
hgif1.Play()
gif_prew:=true
return

Cando_text_prew:
File_Encode := File_GetEncoding(Prew_File)
FileGetSize, File_Size, % Prew_File
FileEncoding, % File_Encode
if (File_Size > 102400) && ((File_Encode = "CP936") or (File_Encode = "UTF-8-RAW"))
{
	FileReadLine, LineVar, % Prew_File, 1
		MsgBox, 36, 选择源文件的编码ANSI/UTF-8, 文件第一行内容: %LineVar%`n当前使用编码为: %File_Encode%`n文本正常显示点击"是"，否则点击"否"。, 2
	IfMsgBox, No
	{
		File_Encode := (File_Encode = "CP936") ? "UTF-8" : "CP936"
		FileEncoding, % File_Encode
	}
	IfMsgBox, yes
		File_Encode := (File_Encode = "CP936") ? "CP936" : "UTF-8"
}

if TF_CountLines(Prew_File)>100
{
	Loop, Read, % Prew_File
	{
		FileR_TFC .= A_LoopReadLine "`n"
		if a_index >100
		break
	}
}
else
	FileRead, FileR_TFC, %Prew_File%
FileEncoding
Gui, +ReSize +MinSize800x540
Gui, Add, Edit, w800 Multi ReadOnly vdisplayArea,
Gui, Add, StatusBar,, 快捷键: 1. 选中文字后按 F2 以选中文字重命名文件. 2. Del 删除文件. 3. F5 运行. 4. F6 编辑.
Gui,PreWWin:Show, w800 h540 Center, % Prew_File " - 文件预览"
GuiControl,, displayArea, %FileR_TFC%
;GuiControl, Move, displayArea, x0 y0 w800 h510
FileR_TFC := File_Encode := File_Size := ""
return

Cando_md_html_prew:
FileCopy, % Prew_File, % A_ScriptDir "\html\html-markdown-preview\apidoc.md", true
gosub, IE_Open
WB.Navigate(A_ScriptDir "\html\html-markdown-preview\index.html")
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