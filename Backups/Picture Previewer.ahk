#include Gdip.ahk
#include Control_AniGif.ahk

CropLineColor := "FF0000"
CropLineThickness := 1
CropLineTrans := "FF"
#NoTrayIcon
#SingleInstance Force
SetBatchLines, -1
Param = %1%
CurrImage := Param
Ext := SubStr(Param,InStr(Param, ".","",0)+1)
CropExtList = bmp,dib,rle,jpg,jpeg,jpe,jfif,gif,tif,tiff,png
If Ext not in ico,%CropExtList%,cur,ani,wmf,emf
{
  MsgBox, % "Sorry, that file type is not supported.`n"
	. "Fully supported file types are bmp, dib, rle, jpg, jpeg, jpe, jfif, gif, tif, tiff, and png`n"
	. "ico can be displayed, and converted/cropped into one of the image types, but images cannot be saved as .ico`n"
	. "cur, ani, wmf, and emf file types can also be displayed, but not cropped or converted."
  ExitApp
}
gdipToken := Gdip_Startup()
OnExit, OnExit
FileList := 0
Loop, % (Directory := SubStr(Param,1, InStr(Param,"\","",0))) "*.*" {
	If A_LoopFileExt in %CropExtList%,ico,cur,ani,wmf,emf
		FileList++, FileList%FileList% := A_LoopFileLongPath
  If (A_LoopFileShortPath = Param || A_LoopFileLongPath = Param)
    FileListCur := FileList
}
Menu, ZoomMenu, Add, Add Custom Zoom `%, CustomZoom
ImgPropor := GetPropor(Param)
Menu, ZoomMenu, Add, % "Default: " 100*ImgPropor "%", ZoomPercent
OldPropor := 100*ImgPropor
Loop, 20
	Menu, ZoomMenu, Add, % 10*(21-A_Index) "%", ZoomPercent
Menu, AutoSSMenu , Add, Turn Off  , AutoSlideshowOff
Menu, AutoSSMenu , Add, 1 Second  , AutoSlideshow
Menu, AutoSSMenu , Add, 3 Seconds , AutoSlideshow
Menu, AutoSSMenu , Add, 5 Seconds , AutoSlideshow
Menu, AutoSSMenu , Add, 10 Seconds, AutoSlideshow
Menu, AutoSSMenu , Add, 20 Seconds, AutoSlideshow
Menu, AutoSSMenu , Add, 30 Seconds, AutoSlideshow
Menu, AutoSSMenu , Add, 45 Seconds, AutoSlideShow
Menu, ResizeMenu , Add, Not Ready Yet..., Left
Menu, ConfigMenu , Add, Crop Line Thickness, SetThickness
Menu, ConfigMenu , Add, Crop Line Color, SetColor
Menu, ConfigMenu , Add, Crop Line Trans, SetTrans
Menu, ContextMenu, Add, Random Slideshow, RandomSlideshow
Menu, ContextMenu, Add, Automatic Slideshow, :AutoSSMenu
Menu, ContextMenu, Add, Zoom Image, :ZoomMenu
Menu, ContextMenu, Add, Resize, :ResizeMenu
Menu, ContextMenu, Add, Config, :ConfigMenu
Menu, ContextMenu, Disable, Resize
EraserBrush := Gdip_BrushCreateSolid(0x00000000)
ImageToGUI(Param,ImgPropor)
Return

AutoSlideshowOff:
If !SlideshowRunning
	Return
SlideshowRunning := False, SlideshowPaused := False
Hotkey, Space, Off
SetTimer, Right, Off
Return

AutoSlideshow:
Hotkey, Space, PauseSlideshow
SetTimer, Right, % RegExReplace(A_ThisMenuItem,"[^\d]") * 1000
SlideshowRunning := True, SlideshowPaused := False
Return

PauseSlideshow:
SlideshowPaused := !SlideshowPaused
SetTimer, Right, % SlideshowPaused ? "Off" : "On"
Return


RandomSlideshow:
%A_ThisLabel% := !%A_ThisLabel%
Menu, ContextMenu, ToggleCheck, %A_ThisMenuItem%
Return

SetThickness:
InputBox, CropLineThickness, Picture Previewer, How thick`, in pixels`, the cropping line should be:
If (ErrorLevel || !IfIs(CropLineThickness,"number"))
	CropLineThickness := 1
pPen := Gdip_CreatePen("0x" CropLineTrans CropLineColor, CropLineThickness)
Return

SetTrans:
InputBox, CropLineTrans, Picture Previewer, How transparent the cropping line should be`,`n from 00 (fully transparent) to FF (fully opaque)
If (ErrorLevel || !IfIs(CropLineTrans,"xdigit") || StrLen(CropLineTrans) != 2)
	CropLineTrans := "FF"
pPen := Gdip_CreatePen("0x" CropLineTrans CropLineColor, CropLineThickness)
Return

SetColor:
InputBox, CropLineColor, Picture Previewer, What color the cropping line should be`, RRGGBB
If (ErrorLevel || !IfIs(CropLineColor,"xdigit") || StrLen(CropLineColor) != 6)
	CropLineColor := "FF0000"
pPen := Gdip_CreatePen("0x" CropLineTrans CropLineColor, CropLineThickness)
Return

ZoomPercent:
ImageToGUI(CurrImage,(ImgPropor:=RegExReplace(A_ThisMenuItem,"[^\d\.]")/100))
Return

CustomZoom:
InputBox, CustomZoomLevel, Picture Previewer, Please input a percent level to zoom to.
If ErrorLevel
	Return
If CustomZoomLevel is not number
	Return
Menu, ZoomMenu, Add, Custom: %CustomZoomLevel%`%, ZoomPercent
ImageToGUI(CurrImage,(ImgPropor:=CustomZoomLevel/100))
Return

GuiContextMenu:
If !NoMenu
	Menu, ContextMenu, Show, %A_GuiX%, %A_GuiY%
Return

#IfWinActive PicturePreviewerImageWindow ahk_class AutoHotkeyGUI
Left::
Right::
Increment := (A_ThisLabel = "Left" ? -1 : 1)
If (RandomSlideshow = True)
	Random, FileListCur, 1, FileList
Else {
	FileListCur += Increment
	If (FileListCur = 0 || FileListCur > FileList) {
		FileListCur -= Increment
		Return
	}
}
ImageToGUI(CurrImage:=FileList%FileListCur%, ImgPropor:=GetPropor(CurrImage))
hPropor:=OldPropor - ImgPropor*100
If (hPropor!=0)
{
	Menu, ZoomMenu, Rename, Default: %OldPropor%`%, % "Default: " ImgPropor*100 "%"
OldPropor := ImgPropor*100
}
Return
#IfWinActive

GetPropor(ImgFile, Type=0) {
	pBitmap := Gdip_CreateBitmapFromFile(ImgFile)
	WidthO  := Gdip_GetImageWidth( pBitmap)
	HeightO := Gdip_GetImageHeight(pBitmap)
	Gdip_DisposeImage(pBitmap)
  Propor  := (A_ScreenHeight/HeightO < A_ScreenWidth/WidthO ? A_ScreenHeight/HeightO : A_ScreenWidth/WidthO)
	Return ((Propor > 1 && Type = 0) ? 1 : Propor)
}

ImageToGUI(Image, Propor) {
	Global
	If (AniGif)
	  AniGif_DestroyControl(AniGifHwnd)
  WinGetPos, WinCurX, WinCurY, WinCurW, WinCurH, PicturePreviewerImageWindow ahk_class AutoHotkeyGUI
	Gui, Destroy
	If (hbm)
		DeleteObject(hbm)
	If (hdc)
	  DeleteDC(hdc)
	If (pBitmapFile)
		Gdip_DisposeImage(pBitmapFile)
	If (G)
		Gdip_DeleteGraphics(G)
	Gui, +LastFound -Caption +ToolWindow
	Gui, Margin, 0, 0
	Hotkey, ~LButton, Cropping, Off
	Hotkey, Enter, CropIt, Off
	NoMenu := False
	StartX := "", StartY := "", EndX := "", EndY := ""
	Ext := SubStr(Image,InStr(Image, ".","",0)+1)
	AniGif := False
	If Ext in cur,ani,wmf,emf
  {
		NoMenu := True
  	Gui, +LastFound -Caption +ToolWindow
		Gui, Margin, 0, 0
		Gui, Add, Picture, , %Image%
		Gui, Show,, PicturePreviewerImageWindow
		Return
	}
	pBitmap := Gdip_CreateBitmapFromFile(Image)
	If (Ext = "gif") {
		DllCall("gdiplus\GdipImageGetFrameDimensionsCount", "UInt", pBitmap, "UInt*", Count)
		VarSetCapacity(dIDs,16,0)
		DllCall("gdiplus\GdipImageGetFrameDimensionsList", "UInt", pBitmap, "Uint", &dIDs, "UInt", Count)
		DllCall("gdiplus\GdipImageGetFrameCount", "UInt", pBitmap, "Uint", &dIDs, "UInt*", CountFrames)
		If (CountFrames > 1)
		  AniGif := True
	}

	Width  := Floor((WidthO :=Gdip_GetImageWidth( pBitmap)) * Propor)
	Height := Floor((HeightO:=Gdip_GetImageHeight(pBitmap)) * Propor)
	Gdip_DisposeImage(pBitmap)

	Gui, % (AniGif ? "" : "+E0x80000")
	If !AniGif
	  Gui, Show, % "W" Width " H" Height " Center", PicturePreviewerImageWindow
	WinID := WinExist()
	If (AniGif)
	  AniGif_LoadGifFromFile((AniGifHwnd:=AniGif_CreateControl(WinExist(""), 0, 0, Width, Height)), Image)
	Else {
	  hbm  := CreateDIBSection(Width,Height)
	  hdc  := CreateCompatibleDC()
	  obm  := SelectObject(hdc,hbm)
	  G    := Gdip_GraphicsFromHDC(hdc)
	  pPen := Gdip_CreatePen("0x" CropLineTrans CropLineColor, CropLineThickness)
	  pBitmapFile := Gdip_CreateBitmapFromFile(Image)
	  Gdip_DrawImage(G, pBitmapFile, 0, 0, Width, Height, 0, 0, WidthO, HeightO)
	  If !WinXLoc
	    WinXLoc := (A_ScreenWidth-Width)//2, WinYLoc := (A_ScreenHeight-Height)//2
		Else {
			WinXLoc := Round(WinCurX + WinCurW/2- Width/2)
			WinYLoc := Round(WinCurY + WinCurH/2-Height/2)
		}
    UpdateLayeredWindow(WinID, hdc, WinXLoc, WinYLoc, Width, Height)
	}
	If AniGif
	  Gui, Show, % "Center " (AniGif ? "H" Height " W" Width : ""), PicturePreviewerImageWindow
	Hotkey, IfWinActive, PicturePreviewerImageWindow ahk_class AutoHotkeyGUI
	If (!AniGif) {
	  Hotkey, Enter, CropIt, On
	  Hotkey, ~LButton, Cropping, On
	}
}

OnExit:
Gdip_Shutdown(gdipToken)
If (AniGif)
	AniGif_DestroyControl(AniGifHwnd)
If (hbm)
	DeleteObject(hbm)
If (hdc)
  DeleteDC(hdc)
If (pBitmapFile)
	Gdip_DisposeImage(pBitmapFile)
If (G)
	Gdip_DeleteGraphics(G)
ExitApp

Cropping:
Hotkey, Enter, CropIt, Off
Hotkey, ~LButton Up, CroppingOff, On
MouseGetPos, StartX, StartY
StartX := StartX - CropLineThickness//2 + 1
StartY := StartY - CropLineThickness//2 + 1
OnMessage(0x200, "SetRect")
Return

CroppingOff:
OnMessage(0x200, "")
Hotkey, Enter, CropIt, On
EndY := NowY - CropLineThickness//2 + 1,
EndX := NowX - CropLineThickness//2 + 1
Return


SetRect(wParam, lParam) {
  Global
  NowX := lParam & 0xFFFF, NowY := lParam >> 16
  Gui, +LastFound
  WinGetPos, WinX, WinY, , , % WinExist()
  Gdip_SetCompositingMode(G, 1)
  Gdip_FillRectangle(G, EraserBrush, 0, 0, Width, Height)
  Gdip_SetCompositingMode(G, 0)
  Gdip_DrawImage(G, pBitmapFile, 0, 0, Width, Height, 0, 0, WidthO, HeightO)
	Gdip_DrawRectangle(G, pPen, StartX > NowX ? NowX : StartX, StartY > NowY ? NowY : StartY, Abs(NowX-StartX), Abs(NowY-StartY))
  UpdateLayeredWindow(WinID, hdc, WinX, WinY, Width, Height)
  Return 0
}

CropIt:
Hotkey, ~LButton, Cropping, Off
Hotkey, Enter, CropIt, Off
Gui, -AlwaysOnTop
FileSelectFile,SaveFile,S,% SubStr(Param, 1, InStr(Param,"\","",0)-1), Please choose a location to save the cropped image:
WinSet, AlwaysOnTop, On, Please choose a location to save the cropped image:
If (ErrorLevel) {
	Hotkey, ~LButton, Cropping, On
	Hotkey, Enter, CropIt, Off
	Return
}
If (FileExist(SaveFile)) {
	MsgBox, 4, , The file`n%SaveFile%`nalready exists. Would you like to overwrite it?
	If MsgBox No
		Goto, Cropit
}
SaveExt := SubStr(SaveFile, InStr(SaveFile, ".","",0)+1)
If SaveExt not in %CropExtList%
  SaveFile .= "." (SaveExt := (Ext = "ico" ? "jpg" : Ext))
pBitmap := Gdip_CreateBitmapFromFile(CurrImage)
WidthO  := Gdip_GetImageWidth( pBitmap)
HeightO := Gdip_GetImageHeight(pBitmap)
FinalX := (StartX > EndX ? EndX : StartX)//ImgPropor
FinalY := (StartY > EndY ? EndY : StartY)//ImgPropor
FinalX := (FinalX < 0 ? 0 : FinalX), FinalY := (FinalY < 0 ? 0 : FinalY)
FinalW := Abs((EndX-StartX)//ImgPropor)
FinalH := Abs((EndY-StartY)//ImgPropor)
FinalW := (FinalX + FinalW > WidthO)  ? WidthO  - FinalX : FinalW
FinalH := (FinalH + FinalY > HeightO) ? HeightO - FinalY : FinalH

If (FinalH && FinalW && FinalX && FinalY) && !(FinalH <= 4 || FinalW <= 4)
	ImageCropped := True, pBitmapCropped := Gdip_CloneBitmapArea(pBitmap, FinalX, FinalY, FinalW, FinalH)
Gdip_SaveBitmapToFile(ImageCropped ? pBitmapCropped : pBitmap, SaveFile ".PICTUREPREVIEWERTEMPFILE." SaveExt)
Gui, Destroy
Gdip_DisposeImage(pBitmap)
Gdip_DisposeImage(pBitmapFile)
FileMove, %SaveFile%.PICTUREPREVIEWERTEMPFILE.%SaveExt%, %SaveFile%, 1
If FileExist(SaveFile)
  ExitApp
Else
  MsgBox, Sorry, some sort of error seems to have occurred.
ExitApp

GuiClose:
Esc::
ExitApp

IfIs(var, type) {    ;Taken from Titan's command functions.
	If var is %type%   ; thanks Titan!
		Return, true
}