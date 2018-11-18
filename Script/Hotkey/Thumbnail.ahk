; 动态显示窗口缩略图，窗口最小化后无实时效果
;^#T::
动态缩略图:
WinGetActiveStats, ThumbTitle, ThumbWide, ThumbHigh, X, Y
ZoomNao:= ZoomNao="" ? 0.25 : ZoomNao
NuWide := ThumbWide * ZoomNao
NuHigh := (ThumbHigh - 25) * ZoomNao
WinGet,source,Id,A
Gui, 68:Default
Gui, +AlwaysOnTop
Gui,Show,w%NuWide% h%NuHigh%, %ThumbTitle%
Gui,+LastFound
WinGet,target,Id,A
Goto ThumbMake
Return

;#]::
放大动态缩略图:
Gui,68: destroy
sleep,1000
ZoomNao += .05
Goto 动态缩略图
Return

;#[::
缩小动态缩略图:
Gui,68: destroy
sleep,1000
ZoomNao -= .05
Goto 动态缩略图
Return

;^#w::
动态缩略图到指定Gui:
watchWindow:

   WinGetClass, class, A    ; get ahk_id of foreground window
   targetName = ahk_class %class%  ; get target window id
   WinGetPos, , , Rwidth, Rheight, A
   start_x := 0
   start_y := 0
   sleep, 500

   ThumbWidth := 400
   ThumbHeight := 400
   thumbID := mainCode(targetName,ThumbWidth,ThumbHeight,start_x,start_y,Rwidth,Rheight)

return

;^#LButton::
鼠标选定区域到缩略图:
start_defining_region:

      Gui,65: Destroy
      Thumbnail_Destroy(thumbID)

   CoordMode, Mouse, Relative                ; relative to window not screen
   MouseGetPos, start_x, start_y             ; start position of mouse
   SetTimer end_defining_region, 200                        ; check every 50ms for mouseup
Return

end_defining_region:
  WinGetPos, win_x, win_y, , , A
  CoordMode, Mouse, Relative  
   ; get the region dimensions
   MouseGetPos, current_x, current_y

   Rheight := abs(current_y - start_y)
   Rwidth := abs(current_x - start_x)

   P_x := start_x + win_x
   P_y := start_y + win_y

   if (current_x < start_x)
       P_x := current_x + win_x

   if (current_y < start_y)
       P_y := current_y + win_y

   ; draw a box to show what is being defined
   Progress, B1 CWffdddd CTff5555 ZH0 fs13 W%Rwidth% H%Rheight% x%P_x% y%P_y%, , ,getMyRegion
   WinSet, Transparent, 110, getMyRegion

  ; if mouse not released then loop through above code...
   If GetKeyState("LButton", "P")
      Return

   ;...otherwise, stop defining region, and start thumbnail ------------------------------->
   SetTimer end_defining_region, OFF

   Progress, off

   MouseGetPos, end_x, end_y
   if (end_x < start_x)
       start_x := end_x

   if (end_y < start_y)
       start_y := end_y

   WinGetClass, class, A    ; get ahk_id of foreground window
   targetName = ahk_class %class%  ; get target window id
   sleep, 500
   ThumbWidth := Rwidth
   ThumbHeight := Rheight
   ;msgbox % ThumbWidth "-" Rheight "-" start_x "-" start_y
   thumbID := mainCode(targetName,ThumbWidth,ThumbHeight,start_x,start_y,Rwidth,Rheight)
  CoordMode, Mouse, screen
return

mainCode(targetName,windowWidth,windowHeight,RegionX,RegionY,RegionW,RegionH){
DetectHiddenWindows,off
Gui, 65:Default
; get the handles:
Gui +LastFound
hDestination := WinExist() ; ... to our GUI...
   hSource := WinExist(targetName) ;

; creating the thumbnail:
hThumb := Thumbnail_Create(hDestination, hSource) ; you must get the return value here!

; getting the source window dimensions:
Thumbnail_GetSourceSize(hThumb, width, height)

  ;-- make sure ratio is correct
  CorrectRatio := RegionW / RegionH
  testWidth := windowHeight * CorrectRatio
  if (windowWidth <  testWidth)
  {
     windowHeight := windowWidth / CorrectRatio
  }
;  else
;  {
;     windowWidth := testWidth
;  }

; then setting its region:
Thumbnail_SetRegion(hThumb, 0, 0 , windowWidth, windowHeight, RegionX , RegionY ,RegionW, RegionH)

; now some GUI stuff:
Gui +AlwaysOnTop +ToolWindow +Resize

; Now we can show it:
Thumbnail_Show(hThumb) ; but it is not visible now...
Gui Show, w%windowWidth% h%windowHeight%, Live Thumbnail ; ... until we show the GUI
OnMessageEx(0x201, "WM_LBUTTONDOWN")
DetectHiddenWindows,on
return hThumb
}

65GuiSize:
  ;if ErrorLevel = 1  ; The window has been minimized.  No action needed.
  ;  return

 Thumbnail_Destroy(thumbID)
  ThumbWidth := A_GuiWidth
  ThumbHeight := A_GuiHeight
 thumbID := mainCode(targetName,ThumbWidth,ThumbHeight,start_x,start_y,Rwidth,Rheight)
return

;----------------------------------------------------------------------

65GuiClose: ; in case the GUI is closed:
   Thumbnail_Destroy(thumbID) ; free the resources
   gui, Destroy
return

WM_LBUTTONDOWN(wParam, lParam)
{
If (A_Gui =65)  ;  未定义清楚，多Gui界面窗口时易发生错误
 {
DetectHiddenWindows,Off
    mX := lParam & 0xFFFF
    mY := lParam >> 16
    SendClickThrough(mX,mY)
 DetectHiddenWindows,On

    PostMessage, 0xA1, 2   ;PostMessage, 0xA1, 2, , , Ahk_Id %Win_ID%    窗口 hwnd  非控件的hwnd  否则控件就乱“跑”了
}
}

SendClickThrough(mX,mY)
{
  global

  convertedX := Round((mX / ThumbWidth)*Rwidth + start_x)
  convertedY := Round((mY / ThumbHeight)*Rheight + start_y)
  ;msgBox, x%convertedX% y%convertedY%, %targetName%
  ControlClick, x%convertedX% y%convertedY%, %targetName%,,,, NA
 ;sleep, 250
 ;ControlClick, x%convertedX% y%convertedY%, %targetName%,,,, NA u
}



ThumbMake:
VarSetCapacity(thumbnail,4,0)
hr1:=DllCall("dwmapi.dll\DwmRegisterThumbnail","UInt",target,"UInt",source,"UInt",&thumbnail)
thumbnail:=NumGet(thumbnail)

/*
DWM_TNP_RECTDESTINATION (0x00000001)
Indicates a value for rcDestination has been specified.
DWM_TNP_RECTSOURCE (0x00000002)
Indicates a value for rcSource has been specified.
DWM_TNP_OPACITY (0x00000004)
Indicates a value for opacity has been specified.
DWM_TNP_VISIBLE (0x00000008)
Indicates a value for fVisible has been specified.
DWM_TNP_SOURCECLIENTAREAONLY (0x00000010)
Indicates a value for fSourceClientAreaOnly has been specified.
*/

dwFlags:=0X1 | 0x2 | 0x10
opacity:=150
fVisible:=1
fSourceClientAreaOnly:=1

WinGetPos,wwx,wwy,www,wwh,ahk_id %target%

VarSetCapacity(dskThumbProps,45,0)
;struct _DWM_THUMBNAIL_PROPERTIES
NumPut(dwFlags,dskThumbProps,0,"UInt")
NumPut(0,dskThumbProps,4,"Int")
NumPut(0,dskThumbProps,8,"Int")
NumPut(www,dskThumbProps,12,"Int")
NumPut(wwh,dskThumbProps,16,"Int")
NumPut(0,dskThumbProps,20,"Int")
NumPut(0,dskThumbProps,24,"Int")
NumPut(www/zoom,dskThumbProps,28,"Int")
NumPut(wwh/zoom,dskThumbProps,32,"Int")
NumPut(opacity,dskThumbProps,36,"UChar")
NumPut(fVisible,dskThumbProps,37,"Int")
NumPut(fSourceClientAreaOnly,dskThumbProps,41,"Int")
hr2:=DllCall("dwmapi.dll\DwmUpdateThumbnailProperties","UInt",thumbnail,"UInt",&dskThumbProps)
Return



/*
title: Thumbnail library
wrapped by maul.esel
Credits:
	- skrommel for example how to show a thumbnail (http://www.autohotkey.com/forum/topic34318.html)
	- RaptorOne & IsNull for correcting some mistakes in the code
Requirements:
	OS - Windows Vista or Windows7 (tested on Windows 7)
	AutoHotkey - AHK classic or AHK_L
To make this work on 64bit you should use AHK_L.
Quick-Tutorial:
To add a thumbnail to a gui, you must know the following:
	- the HWND / id of your gui
	- the HWND / id of the window to show
	- the coordinates where to show the thumbnail
	- the coordinates of the area to be shown
1. Create a thumbnail with <Thumbnail_Create()>
2. Set its regions with <Thumbnail_SetRegion()>, optionally query for the source windows width and height before with <Thumbnail_GetSourceSize()>.
3. optionally set the opacity with <Thumbnail_SetOpacity()>
4. show the thumbnail with <Thumbnail_Show()>
*/


/*
Function: Thumbnail_Create()
creates a thumbnail relationship between two windows
Parameters::
	HWND hDestination - the window that will show the thumbnail
	HWND hSource - the window whose thumbnail will be shown
Returns:
	HANDLE hThumb - thumbnail id on success, false on failure
Remarks:
	To get the HWNDs, you could use WinExist().
*/
Thumbnail_Create(hDestination, hSource)
{
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(thumbnail,	4,	0)
	if DllCall("dwmapi.dll\DwmRegisterThumbnail", _ptr, hDestination, _ptr, hSource, _ptr, &thumbnail)
		return false
	return NumGet(thumbnail, _ptr)
}

/*
Function: Thumbnail_SetRegion()
defines dimensions of a previously created thumbnail
Parameters::
	HANDLE hThumb - the thumbnail id returned by <Thumbnail_Create()>
	INT xDest - the x-coordinate of the rendered thumbnail inside the destination window
	INT yDest - the y-coordinate of the rendered thumbnail inside the destination window
	INT wDest - the width of the rendered thumbnail inside the destination window
	INT hDest - the height of the rendered thumbnail inside the destination window
	INT xSource - the x-coordinate of the area that will be shown inside the thumbnail
	INT ySource - the y-coordinate of the area that will be shown inside the thumbnail
	INT wSource - the width of the area that will be shown inside the thumbnail
	INT hSource - the height of the area that will be shown inside the thumbnail
Returns:
	BOOL success - true on success, false on failure
*/
Thumbnail_SetRegion(hThumb, xDest, yDest, wDest, hDest, xSource, ySource, wSource, hSource)
{
	dwFlags := 0x00000001 | 0x00000002
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(dskThumbProps, 45, 0)

	NumPut(dwFlags,			dskThumbProps,	00,	"UInt")
	NumPut(xDest,			dskThumbProps,	04,	"Int")
	NumPut(yDest,			dskThumbProps,	08,	"Int")
	NumPut(wDest+xDest,		dskThumbProps,	12,	"Int")
	NumPut(hDest+yDest,		dskThumbProps,	16,	"Int")

	NumPut(xSource,			dskThumbProps,	20,	"Int")
	NumPut(ySource,			dskThumbProps,	24,	"Int")
	NumPut(wSource-xSource,	dskThumbProps,	28,	"Int")
	NumPut(hSource-ySource,	dskThumbProps,	32,	"Int")

	return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", _ptr, hThumb, _ptr, &dskThumbProps) >= 0x00
}


/*
Function: Thumbnail_Show()
shows a previously created and sized thumbnail
Parameters::
	HANDLE hThumb - the thumbnail id returned by <Thumbnail_Create()>
Returns:
	BOOL success - true on success, false on failure
*/
Thumbnail_Show(hThumb)
{
	static dwFlags := 0x00000008, fVisible := 1
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(dskThumbProps, 45, 0)
	NumPut(dwFlags,		dskThumbProps,	00,	"UInt")
	NumPut(fVisible,	dskThumbProps,	37,	"Int")

	return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", _ptr, hThumb, _ptr, &dskThumbProps) >= 0x00
}


/*
Function: Thumbnail_Hide()
hides a thumbnail. It can be shown again without recreating
Parameters::
	HANDLE hThumb - the thumbnail id returned by <Thumbnail_Create()>
Returns:
	BOOL success - true on success, false on failure
*/
Thumbnail_Hide(hThumb)
{
	static dwFlags := 0x00000008, fVisible := 0
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(dskThumbProps, 45, 0)

	NumPut(dwFlags,		dskThumbProps,	00,	"Uint")
	NumPut(fVisible,	dskThumbProps,	37,	"Int")

	return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", _ptr, hThumb, _ptr, &dskThumbProps) >= 0x00
}


/*
Function: Thumbnail_Destroy()
destroys a thumbnail relationship
Parameters::
	HANDLE hThumb - the thumbnail id returned by <Thumbnail_Create()>
Returns:
	BOOL success - true on success, false on failure
*/
Thumbnail_Destroy(hThumb)
{
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("dwmapi.dll\DwmUnregisterThumbnail", _ptr, hThumb) >= 0x00
}


/*
Function: Thumbnail_GetSourceSize()
gets the width and height of the source window - can be used with <Thumbnail_SetRegion()>
Parameters::
	HANDLE hThumb - the thumbnail id returned by <Thumbnail_Create()>
	ByRef INT width - receives the width of the window
	ByRef INT height - receives the height of the window
Returns:
	BOOL success - true on success, false on failure
*/
Thumbnail_GetSourceSize(hThumb, ByRef width, ByRef height)
{
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(Size, 8, 0)
	if DllCall("dwmapi.dll\DwmQueryThumbnailSourceSize", _ptr, hThumb, _ptr, &Size)
		return false
	width := NumGet(&Size + 0, 0, "int")
	height := NumGet(&Size + 0, 4, "int")
	return true
}


/*
Function: Thumbnail_SetOpacity()
sets the current opacity level
Parameters::
	HANDLE hThumb - the thumbnail id returned by <Thumbnail_Create()>
	INT opacity - the opacity level from 0 to 255 (will wrap to the other end if invalid)
Returns:
	BOOL success - true on success, false on failure
*/
Thumbnail_SetOpacity(hThumb, opacity)
{
	static dwFlags := 0x00000004
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(dskThumbProps, 45, 0)

	NumPut(dwFlags,		dskThumbProps,	00,	"UInt")
	NumPut(opacity,		dskThumbProps,	36,	"UChar")

	return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", _ptr, hThumb, _ptr, &dskThumbProps) >= 0x00
}

/*
Function: Thumbnail_SetIncludeNC()
sets whether the source's non-client area should be included. The default value is true.
Parameters:
	HANDLE hThumb - the thumbnail id returned by <Thumbnail_Create()>
	BOOL include - true to include the non-client area, false to exclude it
Returns:
	BOOL success - true on success, false on failure
*/
Thumbnail_SetIncludeNC(hThumb, include)
{
	static dwFlags := 0x00000010
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(dskThumbProps, 45, 0)

	NumPut(dwFlags,		dskThumbProps,	00,	"UInt")
	NumPut(!include,	dskThumbProps,	42, "UInt")

	return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", _ptr, hThumb, _ptr, &dskThumbProps) >= 0x00
}

/**************************************************************************************************************
section: example
This example sctript shows a thumbnail of your desktop in a GUI
(start code)
; initializing the script:
#SingleInstance force
#NoEnv
#KeyHistory 0
SetWorkingDir %A_ScriptDir%
#include Thumbnail.ahk

; get the handles:
Gui +LastFound
hDestination := WinExist() ; ... to our GUI...
hSource := WinExist("ahk_class Progman") ; ... and to the desktop

; creating the thumbnail:
hThumb := Thumbnail_Create(hDestination, hSource) ; you must get the return value here!

; getting the source window dimensions:
Thumbnail_GetSourceSize(hThumb, width, height)

; then setting its region:
Thumbnail_SetRegion(hThumb, 25, 25 ; x and y in the GUI
, 400, 350 ; display dimensions
, 0, 0 ; source area coordinates
, width, height) ; the values from Thumbnail_GetSourceSize()

; now some GUI stuff:
Gui +AlwaysOnTop +ToolWindow
Gui Add, Button, gHideShow x0 y0, Hide / Show

; Now we can show it:
Thumbnail_Show(hThumb) ; but it is not visible now...
Gui Show, w450 h400 ; ... until we show the GUI

; even now we can set the transparency:
Thumbnail_SetOpacity(hThumb, 200)

return

GuiClose: ; in case the GUI is closed:
Thumbnail_Destroy(hThumb) ; free the resources
ExitApp

HideShow: ; in case the button is clicked:
if hidden
Thumbnail_Show(hThumb)
else
Thumbnail_Hide(hThumb)

hidden := !hidden
return
(end)
***************************************************************************************************************
*/