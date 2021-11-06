LV_Color_Initiate(Gui_Number=1, Control="")  ; initiate listview color change procedure 
{ 
	global hw_LV_ColorChange, Line_Text_Color, Line_Back_Color, hw_LV_ColorChange_Header
	Line_Text_Color := [], Line_Back_Color := []
	If Control =
	{
		Control = SysListView321
		Gui,%Gui_Number%:+Lastfound 
		Gui_ID := WinExist() 
		ControlGet,hw_LV_ColorChange,HWND,,%Control%,ahk_id %Gui_ID%
	}
	else
	hw_LV_ColorChange := Control
	SendMessage, 0x101F, 0, 0, , % "ahk_id " . hw_LV_ColorChange ; LVM_GETHEADER
	hw_LV_ColorChange_Header := ErrorLevel
	OnMessage(0x4E,"WM_NOTIFY") 
}

LV_Color_unload()
{
	LV_Color_Change()
	OnMessage(0x4E, "WM_NOTIFY", 0)
}

LV_Color_Change(Index="", TextColor="", BackColor="") ; change specific line's color or reset all lines
{ 
	global hw_LV_ColorChange, Line_Text_Color, Line_Back_Color
	If !Index
	{
		Loop,% LV_GetCount() 
			LV_Color_Change(A_Index) 
	}
	else
	{
		Line_Text_Color[Index] := TextColor
		Line_Back_Color[Index] := BackColor
		;tooltip % Index " _ " TextColor " _ " Line_Text_Color[Index]
		WinSet,Redraw,,ahk_id %hw_LV_ColorChange%
	}
}

/* struct NMHDR { 
    HWND            hwndFrom;       uint4       0 
    UINT            idFrom;         uint4       4 
    UINT            code;           uint4       8 
}                                               12 
*/ 

/* struct NMCUSTOMDRAW { 
    NMHDR           hdr;            12          0 
    DWORD           dwDrawStage;    uint4       12 
    HDC             hdc;            uint4       16 
    RECT            rc;             16          20 
    DWORD_PTR       dwItemSpec;     uint4       36 
    UINT            uItemState;     uint4       40 
    LPARAM          lItemlParam;    int4        44 
}                                               48 
*/ 

/* struct NMLVCUSTOMDRAW { 
    NMCUSTOMDRAW    nmcd;           48          0 
    COLORREF        clrText;        uint4       48 
    COLORREF        clrTextBk;      uint4       52 

    #if (_WIN32_IE >= 0x0400) 
        int         iSubItem;       int4        56 
    #endif 

    #if (_WIN32_IE >= 0x560) 
        DWORD       dwItemType;     uint4       60 
        COLORREF    clrFace;        uint4       64 
        int         iIconEffect;    int4        68 
        int         iIconPhase;     int4        72 
        int         iPartId;        int4        76 
        int         iStateId:       int4        80 
        RECT        rcText;         16          84 
        UINT        uAlign;         uint4       100 
    #endif 
}                                               104 
*/

; 禁止调整列表中列的宽度，行文字变色
WM_NOTIFY(p_w, p_l, p_m, p_h)
{
	local draw_stage,Current_Line,Index
	Critical
	Static HDN_BEGINTRACKA = -306,HDN_BEGINTRACKW = -326,HDN_DIVIDERDBLCLICK = -320

	HCTL := NumGet(p_l+0, 0, "Uint")
	if (HCTL = hw_LV_ColorChange_Header)
	{
		Code := NumGet(p_l + 0, 2 * A_PtrSize, "Int")
		If ((Code = HDN_BEGINTRACKA) || (Code = HDN_BEGINTRACKW)) ; && (Code = HDN_DIVIDERDBLCLICK)  ; 禁止拖拽改变列宽, 点击题头排序
		Return True
	}
	Else If (HCTL = hw_LV_ColorChange){
    ;tooltip % dec2hex(NumGet( p_l+0,0,"Uint")) " - " hw_LV_ColorChange
		If ( Code = -12 ) {                            ; NM_CUSTOMDRAW 
			draw_stage := NumGet(p_l+0, A_PtrSize * 3,"Uint") 
;fileappend, % h_SG_hotkeyLv " - " h_SG_PluginsLv " - " h_SG_7plusLv "`r`n", %A_Desktop%\123.txt
;fileappend, % dec2hex(NumGet( p_l+0,0,"Uint")) " - " hw_LV_ColorChange "`r`n", %A_Desktop%\123.txt
			If (draw_stage = 1)                                                 ; CDDS_PREPAINT
				Return,0x20                                                      ; CDRF_NOTIFYITEMDRAW
			Else If (draw_stage = 0x10000|1){                                   ; CDDS_ITEM 
				Current_Line := NumGet( p_l+0, A_PtrSize * 5+16, "Uint")+1
				;tooltip % Current_Line " _ " Line_Text_Color[Current_Line] " _ " BGR(Line_Text_Color[Current_Line])
;LV_GetText(Index,Current_Line,4)          ; 多个lv时，未指定LV_GetText 得到的是当前lv中的值
;fileappend, % Index " - " Line_Color_%Index%_Text "`r`n", %A_Desktop%\123.txt
				If (Line_Text_Color[Current_Line] != ""){
;fileappend, % Index " - " Line_Color_%Index%_Text "`r`n", %A_Desktop%\123.txt
					NumPut(BGR(Line_Text_Color[Current_Line]), p_l+0, A_PtrSize * 8+16, "Uint")   ; foreground 
					NumPut(BGR(Line_Back_Color[Current_Line]), p_l+0, A_PtrSize * 8+16+4, "Uint")   ; background 
				}
			}
		}
	}
}

BGR(i) {
   Return, (i & 0xff) << 16 | (i & 0xffff) >> 8 << 8 | i >> 16
}

LV_SortArrow(h, c, d="")	; by Solar (http://www.autohotkey.com/forum/viewtopic.php?t=69642)
; Shows a chevron in a sorted listview column pointing in the direction of sort (like in Explorer)
; h = ListView handle (use +hwnd option to store the handle in a variable)
; c = 1 based index of the column
; d = Optional direction to set the arrow. "asc" or "up". "desc" or "down".
{
	static ptr, ptrSize, lvColumn, LVM_GETCOLUMN, LVM_SETCOLUMN
	if (!ptr)
		ptr := A_PtrSize ? ("ptr", ptrSize := A_PtrSize) : ("uint", ptrSize := 4)
		,LVM_GETCOLUMN := A_IsUnicode ? (4191, LVM_SETCOLUMN := 4192) : (4121, LVM_SETCOLUMN := 4122)
		,VarSetCapacity(lvColumn, ptrSize + 4), NumPut(1, lvColumn, "uint")
	c -= 1, DllCall("SendMessage", ptr, h, "uint", LVM_GETCOLUMN, "uint", c, ptr, &lvColumn)
	if ((fmt := NumGet(lvColumn, 4, "int")) & 1024) {
		if (d && d = "asc" || d = "up")
			return
		NumPut(fmt & ~1024 | 512, lvColumn, 4, "int")
	} else if (fmt & 512) {
		if (d && d = "desc" || d = "down")
			return
		NumPut(fmt & ~512 | 1024, lvColumn, 4, "int")
	} else {
		Loop % DllCall("SendMessage", ptr, DllCall("SendMessage", ptr, h, "uint", 4127), "uint", 4608)
			if ((i := A_Index - 1) != c)
				DllCall("SendMessage", ptr, h, "uint", LVM_GETCOLUMN, "uint", i, ptr, &lvColumn)
				,NumPut(NumGet(lvColumn, 4, "int") & ~1536, lvColumn, 4, "int")
				,DllCall("SendMessage", ptr, h, "uint", LVM_SETCOLUMN, "uint", i, ptr, &lvColumn)
		NumPut(fmt | (d && d = "desc" || d = "down" ? 512 : 1024), lvColumn, 4, "int")
	}
	return DllCall("SendMessage", ptr, h, "uint", LVM_SETCOLUMN, "uint", c, ptr, &lvColumn)
}