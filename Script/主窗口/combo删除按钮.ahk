;来源网址: https://autohotkey.com/boards/viewtopic.php?f=6&t=56542
List_Func(hwnd)
{
	CbAutoComplete()
	ComboDel(hwnd)
return
}

ComboDel(hwnd)
{
	global stableProgram
	global ComboBoxShowItems
	VarSetCapacity(POINT,8,0)
	DllCall("GetCursorPos","Ptr",&POINT)
	DllCall("ScreenToClient","Ptr",hwnd,"Ptr",&POINT)
	x:=NumGet(POINT,0,"Int")

	GuiControlGet, Pos, Pos, %hwnd%
; 获取行文本
	GuiControlGet, item_,,	%hwnd%
	SendMessage,0x0146,0,0, ,% "ahk_id " hwnd ;CB_GETCOUNT:= 0x0146
	len:=ErrorLevel
	rlen:= len<24?20:30
	if(PosW-x<rlen)
	{
		Loop, Parse, stableProgram, |
		{
			If (A_LoopField = item_) ; not case-sensitive
		Return
		}
		;GuiControl, +AltSubmit, %hwnd%
;   获取行号
		;GuiControlGet, line_,, %hwnd%
		;Control, Delete, %line_%,, ahk_id %hwnd%
		;GuiControl, -AltSubmit, %hwnd%  
		Loop, Parse, ComboBoxShowItems, |
		{
			If !A_LoopField Or (A_LoopField = item_) ; not case-sensitive
				Continue
			Else
				Tempitems .= A_LoopField . "|"
		}
		StringTrimRight, Tempitems, Tempitems, 1   ; remove last |
		ComboBoxShowItems := Tempitems
		GuiControl, , Dir, |%ComboBoxShowItems%
		sLength := StrLen(stableProgram)
		StringTrimLeft, historyData, ComboBoxShowItems, %sLength%
		IniWrite,%historyData%,%run_iniFile%,固定的程序,historyData
	return
	}
return
}

WinProcCallback(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime)
{
	Critical  
	if !hwnd
		return
	event:=Format("0x{1:x}",event) ; decimal to hexadecimal
	hwnd:=Format("0x{1:x}",hwnd)

	;EVENT_OBJECT_REORDER:= 0x8004, EVENT_OBJECT_FOCUS:= 0x8005, EVENT_OBJECT_SELECTION:= 0x8006
	if(event=0x8006)
	{ ;EVENT_OBJECT_SELECTION
		del_icons(hwnd,del_ico)
	return
	}
}

del_icons(CB_ListID,del_ico:=0)
{
	List_id:=objListIDs[CB_ListID]
	SendMessage,0x0146,0,0, ,% "ahk_id " List_id ;CB_GETCOUNT:= 0x0146
	len:=ErrorLevel

	;WinGetPos, ,,, CB_height, ahk_id %CB_ListID% 
	;row_height2:=CB_height/len

	SendMessage,0x0154,1,0, ,% "ahk_id " List_id ;CB_GETITEMHEIGHT:= 0x0154
	row_height:= ErrorLevel

	if(del_ico)
		iconOnWin(CB_ListID,len,row_height)
	else
		textOnWin(CB_ListID,len,row_height,"X")
}

textOnWin(hwnd, len, row_h, text_:="X")
{  ;% Chr(215) × "X"
	hDC := DllCall("User32.dll\GetDC", "Ptr", hwnd)
	WinGetPos, x, y, W, H, ahk_id %hwnd%
	x:=len<24?W-12:W-30
	y:=0, heightF:=12, weight:=400, fontName:="Arial"  ;"Segoe Print"
	widthF:=6
	hFont:=DllCall("CreateFont", "Int", heightF, "Int", widthF, "Int",  0, "Int", 0, "Int", weight, "Uint", 0,"Uint", 0,"uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", fontName)
	DllCall("SelectObject", "UPtr", hDC, "UPtr", hFont, "UPtr")

	VarSetCapacity(POINT,8,0)
	DllCall("GetCursorPos","Ptr",&POINT)
	DllCall("ScreenToClient","Ptr",hwnd,"Ptr",&POINT)
	PosX:=NumGet(POINT,0,"Int"), PosY:=NumGet(POINT,4,"Int") 
	colorG:=0xAFAFAF
	colorR:=0x0000EE  ;BGR
	m:=2
	y:=m
	Loop, % len 
	{
		if(PosY>=y-m && PosY<y+row_h-m)
		{
			DllCall("SetTextColor", "UPtr", hDC, "UInt",colorR )
			DllCall("SetBkMode","Ptr",hDC,"Int",1) ;TRANSPARENT := 1
			DllCall("TextOut", "uint",hDC, "int",x, "int",y, "str",text_, "int",StrLen(text_)) 		
		}
		else
		{
			if(!single_ico && !del_ico)
			{
				DllCall("SetTextColor", "UPtr", hDC, "UInt",colorG )
				DllCall("SetBkMode","Ptr",hDC,"Int",1) ;TRANSPARENT := 1
				DllCall("TextOut", "uint",hDC, "int",x, "int",y, "str",text_, "int",StrLen(text_)) 
			}
		}
		y+=row_h
	}
	DllCall("DeleteObject", "UPtr", hFont)
	DllCall("ReleaseDC", "Uint", hwnd, "Uint", hDC)
}

;==============================================
iconOnWin(hwnd,len,row_h)
{
	;hIcon:=LoadPicture("C:\AutoHotkey Scripts\icons\test\Close_16x16.ico","",ImageType)
	;hIcon:=LoadPicture("shell32.dll","Icon132 w16 h-1" ,ImageType) ; 
	hIcon:=LoadPicture("imageres.dll","Icon162 w16 h-1" ,ImageType) ; Win7,8
	hDC := DllCall("User32.dll\GetDC", "Ptr", hwnd)
	
	WinGetPos, x, y, W, H, ahk_id %hwnd% 
	x:=len<24?W-18:W-30
	y:=0
	VarSetCapacity(POINT,8,0)
	DllCall("GetCursorPos","Ptr",&POINT)
	DllCall("ScreenToClient","Ptr",hwnd,"Ptr",&POINT)
	PosX:=NumGet(POINT,0,"Int"), PosY:=NumGet(POINT,4,"Int")

	cxWidth:=cyWidth:=0
	m:=0
	y:=m
	Loop, % len 
	{
		if(PosY>=y-m && PosY<y+row_h-m)
		{
			RC:=DllCall("DrawIconEx","Ptr",hDC,"Int",x ,"Int",y ,"Ptr",hIcon ,"Int",cxWidth ,"Int",cyWidth ,"UInt",0 ,"Ptr",0,"UInt",0x3)
		}
		y+=row_h
	}
	DllCall("ReleaseDC", "Uint", CtrlHwnd, "Uint", hDC)	
}
;====================================================