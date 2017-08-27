;https://autohotkey.com/boards/viewtopic.php?f=10&t=1946
#SingleInstance
; #include GDIP.ahk ;remove comment, if GDIP is not in the standard library
OnExit, Exit
CoordMode, Mouse, Screen
pToken := Gdip_Startup()
run_iniFile = %A_ScriptDir%\..\settings\setting.ini
IniRead,filetp, %run_iniFile%,½ØÍ¼, filetp
IniRead,½ØÍ¼±£´æÄ¿Â¼, %run_iniFile%,½ØÍ¼, ½ØÍ¼±£´æÄ¿Â¼
IfnotExist,%½ØÍ¼±£´æÄ¿Â¼%
  IniRead, ½ØÍ¼±£´æÄ¿Â¼, %run_iniFile%, Â·¾¶ÉèÖÃ, ½ØÍ¼±£´æÄ¿Â¼

SystemLanguage := SubStr(A_Language,3,2)=04?"CN":"EN"

;Menu, Tray, Icon,icon.ico,, 1
Menu, tray, NoStandard
Menu, tray, add, % SystemLanguage="CN"?"ÔÝÍ£":"Disable"
Menu, tray, add, % SystemLanguage="CN"?"ÍË³ö":"Exit"

LControl & RControl::
RControl & LControl::
	if CrossHair {
		SetTimer, CrossHair, off
		Gui, CrossHair:destroy
		Gdip_DeletePen(pPen)
		CrossHair := false
		return
	}
	CrossHair := true
	Gui, CrossHair: -Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
	Gui, CrossHair: Show, NA
	hwnd1 := WinExist()	
	pPen := Gdip_CreatePen(0x88888888,1)	
	SetTimer, CrossHair, 20
return

Disable:
ÔÝÍ£:
	;Menu, Tray, Icon,icon_disabled.ico,, 1
	Menu, tray, add, % SystemLanguage="CN"?"¼¤»î":"Enable"
	Menu, tray, delete, % SystemLanguage="CN"?"ÔÝÍ£":"Disable"
	Suspend, On
return

Enable:
¼¤»î:
	;Menu, Tray, Icon,icon.ico,, 1
	Menu, tray, add, % SystemLanguage="CN"?"ÔÝÍ£":"Disable"
	Menu, tray, delete, % SystemLanguage="CN"?"¼¤»î":"Enable"
	Suspend, Off
return

CrossHair:
	hdc := CreateCompatibleDC()
	hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
	obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc)
	Gdip_SetSmoothingMode(G, 4)
	MouseGetPos, xPos, yPos	
	Gdip_Drawline(G, pPen, xPos, 1, xPos, A_ScreenHeight) ; ver. line
	Gdip_Drawline(G, pPen, 1, yPos, A_ScreenWidth, yPos) ; hor. line
	if StartPosX {
		UpperLeftX := xPos>StartPosX?StartPosX:xPos
		UpperLeftY := yPos>StartPosY?StartPosY:yPos
		LowerRightX := xPos>StartPosX?xPos:StartPosX
		LowerRightY := yPos>StartPosY?yPos:StartPosY
		FillFrame := Gdip_BrushCreateSolid(0x30888888)
		Gdip_FillRectangle(G, FillFrame, 1 , 1 , UpperLeftX , A_ScreenHeight) ;block left
		Gdip_FillRectangle(G, FillFrame, LowerRightX , 1 , A_ScreenWidth - LowerRightX , A_ScreenHeight) ;block right
		Gdip_FillRectangle(G, FillFrame, UpperLeftX , 1 , LowerRightX - UpperLeftX , UpperLeftY) ;block top
		Gdip_FillRectangle(G, FillFrame, UpperLeftX , LowerRightY , LowerRightX - UpperLeftX , A_ScreenHeight - UpperLeftY) ;block bottom
	}
	UpdateLayeredWindow(hwnd1, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
	SelectObject(hdc, obm)
	DeleteObject(hbm)
	DeleteDC(hdc)
	Gdip_DeleteGraphics(G)
Return

#if CrossHair
LButton::
	MouseGetPos, xPos, yPos
	StartPosX := xPos
	StartPosY := yPos
	SetTimer, EndPos, 20 ; Wait for EndPos...
return 
#if

EndPos:
	if !GetKeyState("LButton","P") { ;LButton is up, also show the area
		SetTimer, EndPos, off	
		Width := xPos>StartPosX?xPos-StartPosX:StartPosX-xPos
		Height := yPos>StartPosY?yPos-StartPosY:StartPosY-yPos
		StartPosX := StartPosX>xPos?xPos:StartPosX
		StartPosY := StartPosY>yPos?yPos:StartPosY
		pBitmap := Gdip_BitmapFromScreen(StartPosX "|" StartPosY "|" width "|" height)  ;xPos|yPos|Width|Height
		hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
		StartPosX := "" , StartPosY := ""
		SetTimer, CrossHair, off
		Gui, CrossHair:destroy
		Gdip_DeletePen(pPen)
		CrossHair := false
		Gui, Preview:destroy
		OnMessage(0x201, "WM_LBUTTONDOWN")
		Gui, Preview:Color, 008080
		Gui, Preview:+AlwaysOnTop -Caption border
		zomu := A_ScreenDPI / 96
		x := width/zomu<155?10:Width/zomu-145
		Gui, Preview:Add, Picture, x%x% y10 w30 h30 gClipboard, Clipboard.png
		Gui, Preview:Add, Picture, x+10 y10 w30 h30 gSave, Save.png
		Gui, Preview:Add, Picture, x+10 w30 h30 gPrint, Print.png
		Gui, Preview:Add, Picture, x+15 w30 h30 gClose, Close.png
		x := width/zomu<155?87-(width/2)/zomu:10
		Gui, Preview:Add, Picture, x%x% y+15 w%width% h%height% 0xE border hwndScreenShot
		PutImage(ScreenShot)
		DeleteObject(hBitmap)
		GuiWidth := width/zomu<155?"w175":"w" Width/zomu+20*zomu
		GuiHeight := "h" Height/zomu + 30*zomu +35
		x := A_ScreenWidth/zomu>(Width/zomu+20*zomu)?"xCenter":"x-20"
		y := A_ScreenHeight/zomu>(Height/zomu + 30*zomu +35)?"yCenter":"y0"
		Gui, Preview:Show, %GuiWidth% %GuiHeight% %x% %y%
	}
return

PutImage(hwnd)
{
	global hBitmap
	SendMessage, 0x172, 0x0, hBitmap, , ahk_id %hwnd%
}

Clipboard:
	Gdip_SetBitmapToClipboard(pBitmap)
	TrayTip,, % SystemLanguage="CN"?"½ØÍ¼ÒÑ±£´æµ½¼ôÌù°å£¡":"Successful put in clipboard!"
return

Save:
	Gui Preview:+OwnDialogs 
	FileSelectFile, FullFileName, S8, %½ØÍ¼±£´æÄ¿Â¼%\ÇøÓò½ØÍ¼_%A_now%.%filetp%, ÎÄ¼þ±£´æÎª, Bitmap (*.bmp; *.gif; *.jpg; *.png; *.tiff)
	if !FullFileName
		return
	SplitPath, FullFileName,name,,ext
	if !ext
		FullFileName .= ".jpg"
	else if (ext != "bmp") && (ext != "gif") && (ext != "jpg") && (ext != "png") && (ext != "tiff") {
		MsgBox % SystemLanguage="CN"?"´íÎóµÄÀ©Õ¹Ãû!":"Wrong extension!"
	return
	}
	Gdip_SaveBitmapToFile(pBitmap, FullFileName, 100)
	TrayTip,, % SystemLanguage="CN"?"½ØÍ¼±£´æ³É¹¦!":"Successful saved!"
return

Print:
	Gui Preview:+OwnDialogs 
	Gui, Preview:-AlwaysOnTop
	Gdip_SaveBitmapToFile(pBitmap, "print.jpg", 100)
	RunWait, print "print.jpg"
	ID := WinWaitCreated()
	WinGetTitle, title, ahk_id %id%
	WinWaitClose, %title%
	Gui, Preview:+AlwaysOnTop
	FileDelete, print.jpg
return

ESC::
GuiClose:
Close:
	Gdip_DisposeImage(pBitmap)
	SetTimer, CrossHair, off
	SetTimer, EndPos, off
	Gui, CrossHair:destroy
	CrossHair := false
	Gui, Preview:destroy
return

Exit:
ÍË³ö:
	Gdip_DeletePen(pPen)
	Gdip_Shutdown(pToken)
ExitApp

WinWaitCreated( WinTitle:="", WinText:="", Seconds:=0, ExcludeTitle:="", ExcludeText:="" ) {
	; by HotKeyIt (edited by trismarck)
    static Found := 0
    , _WinTitle, _WinText, _ExcludeTitle, _ExcludeText
   
    ,init := DllCall( "RegisterShellHookWindow"
        , "Ptr", A_ScriptHwnd )
   
    ,MsgNum := DllCall( "RegisterWindowMessage", "Str","SHELLHOOK" )
   
    ,cleanup:= {base: {__Delete: Func(A_ThisFunc) } }

    ; Destructor:
    if IsObject(WinTitle)   ; cleanup
        return DllCall("DeregisterShellHookWindow","Ptr",A_ScriptHwnd)
   
    ; OnMessage: HSHELL_WINDOWCREATED, our window
    else If ( WinTitle = 1   ; window crated, check if it is our window
     && WinExist( _WinTitle " ahk_id " WinText,_WinText,_ExcludeTitle,_ExcludeText)
     && Seconds = MsgNum
     && ExcludeTitle = A_ScriptHwnd)
    {
        ;Sleep % A_WinDelay, Found := WinText
            ; this of course will assign new value to 'found' too soon
        Sleep % A_WinDelay
        return, "", Found := WinText
            ; not sure if the return value is interpreted by
            ; The Shell, but in case it is, it's better not
            ; to return anything?
            ;
    }
   
    ; OnMessage: other message from the Shell:
    else if( ( (WinTitle >= 1 and WinTitle <= 14) or WinTitle = 0x8004)
     && WinText > 0
     && Seconds = MsgNum
     && ExcludeTitle = A_ScriptHwnd)
    {
        return "" ; skip that message
    }
   
    ; User called the function: (all other cases)
    else
    {
        Start := A_TickCount
            , _WinTitle := WinTitle, _WinText := WinText
            ,_ExcludeTitle := ExcludeTitle, _ExcludeText := ExcludeText

        ,OnMessage( MsgNum, A_ThisFunc ),  Found := 0
       
        While ( !Found
         && ( !Seconds || Seconds * 1000 < A_TickCount - Start ) )
            Sleep, 16
       
        SetFormat, IntegerFast, hex
        Found += 0, Found .= ""
        SetFormat, IntegerFast, dec
       
        Return Found, OnMessage( MsgNum, "" )
    }
}

WM_LBUTTONDOWN() {
	PostMessage, 0xA1, 2, 0 ; sehr sehr alter Trick von SKAN: 0xA1 = WM_NCLBUTTONDOWN
}
