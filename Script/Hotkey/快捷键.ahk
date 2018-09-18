;Explorer .. View mode--------------By a_h_k & ..:: Free Radical ::..
;http://www.autohotkey.com/forum/topic57686.html


窗口置顶:
;^Up::
WinSet,AlwaysOnTop,,A
return

暂时隐藏窗口:
;#Space::
WinGet, active_id, ID, A
WinHide, ahk_id %active_id%
Sleep, 4000
WinShow, ahk_id %active_id%
return

关闭显示器并锁定电脑:
;#s::
KeyWait LWin    ;等待LWin键松开后，才继续
KeyWait S
BlockInput On   ;锁定键盘，鼠标
SendMessage, 0x112, 0xF170, 2,, Program Manager ;关闭显示器
DllCall("LockWorkStation")                      ;锁定电脑，相当于Win+L
BlockInput Off  ;解锁锁键盘，鼠标
return

禁止关闭按钮:
;#8::
;DisableCloseButton(WinExist("A"))
;DisableMenuButtons(WinExist("A"))
;DisableMinimizeButton(WinExist("A"))
WinSet, Style, -0x80000, A    ;隐藏标题栏图标，按钮，标题栏菜单
return

恢复关闭按钮:
;#9::
;RedrawSysmenu(WinExist("A"))
WinSet, Style, +0x80000, A
return
;
;-1 is Close, -2 is the seperator, -3 is Maximize,
;-4 is Minimize, -5 is Size, -6 is Move and -7 is Restore
;

DisableMenuButtons(hWnd="") {
 hWnd := (!hWnd) ? WinExist("A") : hWnd
 hSysMenu:=DllCall("GetSystemMenu","Int",hWnd,"Int",FALSE)
 nCnt:=DllCall("GetMenuItemCount","Int",hSysMenu)
 Loop, %nCnt%
   DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-A_Index,"Uint","0x400")
}

DisableMinimizeButton(hWnd="") {
 If hWnd=
    hWnd:=WinExist("A")
 hSysMenu:=DllCall("GetSystemMenu","Int",hWnd,"Int",FALSE)
 nCnt:=DllCall("GetMenuItemCount","Int",hSysMenu)
 DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-4,"Uint","0x400")
 ;DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-5,"Uint","0x400")
 DllCall("DrawMenuBar","Int",hWnd)
Return ""
}


RedrawSysMenu(hWnd="") {
 If hWnd=
    hWnd:=WinExist("A")
 hSysMenu:=DllCall("GetSystemMenu","Int",hWnd,"Int",TRUE)
 DllCall("DrawMenuBar","Int",hWnd)
Return ""
}

DisableCloseButton(hWnd="") {
 If hWnd=
    hWnd:=WinExist("A")
 hSysMenu:=DllCall("GetSystemMenu","Int",hWnd,"Int",FALSE)
 nCnt:=DllCall("GetMenuItemCount","Int",hSysMenu)
 DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-1,"Uint","0x400")
 DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-2,"Uint","0x400")
 DllCall("DrawMenuBar","Int",hWnd)
Return ""
}

隐藏任务栏:
;#6::
winhide, ahk_class Shell_TrayWnd
Return

恢复任务栏:
;#7::
winshow, ahk_class Shell_TrayWnd
Return

ExploreDrive:
   StringRight Drv,A_THISHOTKEY,1
   ifExist %Drv%:\
      Run %Drv%:\
   else
      TrayTip,错误,%Drv%盘不存在!,10,3
Return

缩为标题栏:
;#z::
; Change this line to pick a different hotkey.
; Below this point, no changes should be made unless you want to
; alter the script's basic functionality.
; Uncomment this next line if this subroutine is to be converted
; into a custom menu item rather than a hotkey.  The delay allows
; the active window that was deactivated by the displayed menu to
; become active again:
;Sleep, 200
WinGet, ws_ID, ID, A
Loop, Parse, ws_IDList, |
{
   IfEqual, A_LoopField, %ws_ID%
   {
      ; Match found, so this window should be restored (unrolled):
      StringTrimRight, ws_Height, ws_Window%ws_ID%, 0
        if ws_Animate = 1
        {
            ws_RollHeight = %ws_MinHeight%
            Loop
            {
                If ws_RollHeight >= %ws_Height%
                    Break
                ws_RollHeight += %ws_RollUpSmoothness%
                WinMove, ahk_id %ws_ID%,,,,, %ws_RollHeight%
            }
        }
       WinMove, ahk_id %ws_ID%,,,,, %ws_Height%
      StringReplace, ws_IDList, ws_IDList, |%ws_ID%
      return
   }
}
WinGetPos,,,, ws_Height, A
ws_Window%ws_ID% = %ws_Height%
ws_IDList = %ws_IDList%|%ws_ID%
ws_RollHeight = %ws_Height%
if ws_Animate = 1
{
    Loop
    {
        If ws_RollHeight <= %ws_MinHeight%
            Break
        ws_RollHeight -= %ws_RollUpSmoothness%
        WinMove, ahk_id %ws_ID%,,,,, %ws_RollHeight%
    }
}
WinMove, ahk_id %ws_ID%,,,,, %ws_MinHeight%
return

;#IfWinActive ahk_group ExplorerGroup
;^d::InvertSelection()
;#IfWinActive

资源管理器反选:
ControlGet, hCtl, Hwnd, , SHELLDLL_DefView1, A
PostMessage, 0x111, 28706, 0, , ahk_id %hCtl%		;编辑, 反向选择
; 弹出菜单然后选择菜单的方式
; InvertSelection()
return

InvertSelection()
{
;弹出窗口菜单栏，选择相应菜单回车
	PostMessage,0x112,0xf100,0,,A
	SendInput {Right}{Down}{Up}{Enter}
	return
}

;Win_7中自带的快捷键“^+滚轮” 为放大图标和切换视图
;适用于资源管理器和对话框
切换视图:
MouseGetPos,x,y,winid,ctrlid,2
Sleep,0
WM_COMMAND=0x111

;查看方式  XP兼容
ODM_VIEW_ICONS =0x7029			;28713		图标
ODM_VIEW_LIST  =0x702b				;28715		列表
ODM_VIEW_DETAIL=0x702c			;28716		详细信息
ODM_VIEW_THUMBS=0x702d	;28717		缩略图
ODM_VIEW_TILES =0x702e				;28718		平铺

/*
;分组依据
ODM_VIEW_ICONS =0x7602
ODM_VIEW_LIST  =0x7603
ODM_VIEW_DETAIL=0x7604
ODM_VIEW_THUMBS=0x7605
ODM_VIEW_TILES =0x7606
*/
views=%ODM_VIEW_ICONS%,%ODM_VIEW_LIST%,%ODM_VIEW_DETAIL%,%ODM_VIEW_THUMBS%,%ODM_VIEW_TILES%
StringSplit,view_,views,`,
view+=1
If view>5
  view=1
changeview:=view_%view%
ControlGet,listview,Hwnd,,,ahk_id %ctrlid%
parent:=listview
Loop
{
  parent:=DllCall("GetParent","UInt",parent)
  If parent=0
    Break
  SendMessage,%WM_COMMAND%,%changeview%,0,,ahk_id %parent%
}
return


;#V::
代码保存并运行:
	clipboard =
	Send, ^c
	ClipWait,3
CF_HTML := DllCall("RegisterClipboardFormat", "str", "HTML Format")
bin := ClipboardAll
n := 0
while format := NumGet(bin, n, "uint")
{
    size := NumGet(bin, n + 4, "uint")
    if (format = CF_HTML)
    {
        html := StrGet(&bin + n + 8, size, "UTF-8")
        RegExMatch(html, "(*ANYCRLF)SourceURL:\K.*", sourceURL)
        break
    }
    n += 8 + size
}
Clipboard := sourceURL ? (";来源网址: " sourceURL "`r`n" Clipboard) : Clipboard

if clipboard 
{
	clipboard = %clipboard%
	File:=  A_Desktop "\" . A_Now  ".ahk"
	FileAppend,%clipboard%`r`n,%File%
	run,%File%,%A_Desktop%
}
return

;!F1::
有道网络翻译:
原值:=Clipboard
	clipboard =
	Send, ^c
	ClipWait,2
	If ErrorLevel                          ;如果粘贴板里面没有内容，则判断是否有窗口定义
		Return

	Youdao_keyword=%Clipboard%
	Youdao_译文:=YouDaoApi(Youdao_keyword)
	Youdao_基本释义:= json(Youdao_译文, "basic.explains")
	Youdao_网络释义:= json(Youdao_译文, "web.value")
	If Youdao_基本释义<>
	{
		ToolTip,%Youdao_keyword%:`n基本释义:%Youdao_基本释义%`n网络释义:%Youdao_网络释义%
		gosub,soundpaly
		ToolTip
	}
else
MsgBox,,有道网络翻译,网络错误或查询不到该单词的翻译。
Clipboard:=原值
return


/*
#F::
ClipboardCode(1)
return


ClipboardCode( RunInScite=0 ) {
   Send, ^c
   If !ClipboardGet_HTML(clip)
      return ""
   If !RegExMatch(clip,"is)<!--StartFragment-->(.*)<!--EndFragment-->",html)
      return ""
   doc := COM_CreateObject("HTMLfile")
   COM_Invoke(doc,"write","<html><head></head><body>" html1 "</body></html>")
   td := COM_Invoke(doc,"getElementsByTagname","td")
   loop % COM_Invoke(td,"length")
      if (COM_Invoke(COM_Invoke(td,"Item",A_Index-1),"className") = "code") && (code := COM_Invoke(COM_Invoke(td,"Item",A_Index-1),"innerText"))
         break
   if ( r := RegExReplace(code,"\xc2","") )
      Clipboard := r
   else
      return
      */

Runz:
IfWinExist, %A_ScriptDir%\RunZ.ahk ahk_class AutoHotkey
send % RunZ
else
Run,%A_AhkPath% "%A_ScriptDir%\RunZ.ahk" --show
return