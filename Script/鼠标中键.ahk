;鼠标中键增强
$MButton::
	;s := A_TickCount
	MouseGetPos, lastx, lasty
	MouseGetPos,,,UID,ClassNN ; 获取指针下窗口的 UID 和 ClassNN
	WinGetClass,窗口Class,ahk_id %UID% ; 根据 UID 获得窗口类名
	CoordMode, Mouse, Relative
	If(Auto_Raise=1)
		stophovering(2)
  settimer, jkMbutton, -3000
	; 魔兽争霸自动加血
	IfWinActive,Warcraft III
	{
		MouseGetPos, xpos, ypos
		Send, {F1}{Numpad7}  ;{Click 400, 760}
		MouseMove %xpos%, %ypos%
	return
	}

	; 主窗口自动隐藏
	IfWinActive, %AppTitle%
	{
		WinGetPos,,oldy,,,%AppTitle%
		MouseGetPos,,, win

		IfWinNotActive,ahk_id %win%
		{
			Send, {MButton}
		return
		}
		Loop, Parse, winlist,|
		IfEqual,A_LoopField,%win%
		{
			StringReplace, winlist, winlist,|%win%
		return
		}
		winlist=%winlist%|%win%
		SetTimer, WatchCursor2, 500
	return
	}

; 资源管理器新窗口打开文件夹
; 使用 QtTabBar时, 会造成 QtTabBar 打开新窗口时会有些许卡顿, 移动鼠标还可能导致打开当前鼠标下面指向的文件夹,而不是中键点击的文件夹
; 可能原因为Autohotkey 拦截了中键,导致 QtTabBar 缓存了中键, 暂无很好的解决办法
	if(WinActive("ahk_group ExplorerGroup") && IsMouseOverFileList())
	{
		;if QtTabBar   ; 尝试解决卡顿问题无效, QtTabBar 和 Autohotkey 中键新窗口打开文件夹只能二选一
		;{
			;Sleep 20
			;new_s:=A_TickCount
			;tooltip % new_s - s
			;return
		;}
		selected := GetSelectedFiles(0)
		;tooltip % selected "111"
		SendEvent {LButton}
		Sleep 500
		undermouse := GetSelectedFiles()
		if undermouse
		{
			if CF_IsFolder(undermouse)
				Isdir :=true
			else
				Isdir :=false
			if(undermouse!=selected)
				SelectFiles(selected)
			;tooltip % selected " - " undermouse
			if(Isdir)
				run explorer.exe  %undermouse%  ; 安装使用 qttabbar 后为打开新窗口
			;run %undermouse% ; 安装使用 qttabbar 后为打开新标签
			return
		}
	}

	; 任务栏自动关闭窗口
	If (窗口Class = "Shell_TrayWnd") ; 指针是否在任务栏上
	{
		KeyIsDown := GetKeyState("Capslock" , "T")
		if KeyIsDown
		{
			Send {MButton}
		Return
		}
		else
		{
			If (ClassNN = "ToolbarWindow321") ; 指针是否在托盘图标上
			{
				SendEvent,{click,Right}
				SendEvent,{Up}{enter} ; 如果是在托盘区上，为关闭选择的程序
			return
			}
			Else ; 指针在任务栏窗口按钮上
			{
				;SendEvent,{Click,Right}
				;WinWait,ahk_class DV2ControlHost
				;Sleep,200 ;中文输入法状态下，有延迟才能成功
				;SendEvent,{Up}{enter};如果是任务栏上，为关闭选择的程序

        if !(h_id := TTLib.GetTrackedButtonWindow())
        {
          ;SendEvent,{Click}
          CoordMode, Mouse, Screen
          mousegetpos, Tmp_X, Tmp_Y
          sleep 32
          ;Send {Blind}{vkFF}
          mousemove, % Tmp_X + 2, % Tmp_Y - 2
          sleep 32
          mousemove, % Tmp_X, % Tmp_Y
          sleep 200
        }
				if (h_id := TTLib.GetTrackedButtonWindow())
        {
					;tooltip TTLib 成功, 500,500
          PostMessage, 0x112, 0xF060,,, ahk_id %h_id%
          CoordMode, Mouse, Screen
          mousegetpos, Tmp_X, Tmp_Y
          sleep 32
          ;Send {Blind}{vkFF}
          mousemove, % Tmp_X + 2, % Tmp_Y - 2
          sleep 32
          mousemove, % Tmp_X, % Tmp_Y
        }
				else
				{
					;tooltip TTLib 失败,500,500
					Send {Shift down}
					click right
					If(!IsContextMenuActive())
						sleep 50
					Send {Shift up}
					sleep,30
					SendEvent {c}
					sleep,100
				}
			return
			}
		}
	}

	; 隐藏桌面图标
	; 一行脚本实现切换
	; PostMessage, 0x111, 29698, , SHELLDLL_DefView1, ahk_class Progman
	If (窗口Class = "Progman" || 窗口Class = "WorkerW")
	{
		/*  1
		var := (flag=0) ? "Show" : "Hide"
		flag := !flag
		Control,%var%,, SysListView321, ahk_class Progman
		Control,%var%,, SysListView321, ahk_class WorkerW
	Return
		*/
		/*  2
		ControlGet,Vis,Visible,,SysListView321,ahk_class Progman
		ControlGet,Selected,List,Selected,SysListView321,ahk_class Progman
		IfEqual,cHwnd,,ControlGet, chwnd, Hwnd,, SysListView321,ahk_class Progman
		DllCall( "ShowWindow", UInt,cHwnd, UInt, Vis ? 0 : 5 )
	Return
		*/
		/*  3
		ControlGet, vCtlStyle, Style, , SysListView321, ahk_class Progman
		if !(vCtlStyle & 0x10000000) ; WS_VISIBLE := 0x10000000
			PostMessage, 0x111, 29698, , SHELLDLL_DefView1, ahk_class Progman ; show desktop icons (toggle)
*/
		DetectHiddenWindows Off
		ControlGet, HWND, Hwnd,, SysListView321, ahk_class WorkerW
		If HWND =
		{
			DetectHiddenWindows On
			ControlGet, HWND, Hwnd,, SysListView321, ahk_class Progman
			DetectHiddenWindows Off
		}
		If DllCall("IsWindowVisible", UInt, HWND)
		{
			WinHide, ahk_id %HWND%
			hidedektopicon = 1
		}
		Else
		{
			WinShow, ahk_id %HWND%
			hidedektopicon = 0
		}
	Return

		/*  3
		ControlGet,id1,hwnd,,SHELLDLL_DefView1,ahk_class Progman
		ControlGet,DID,hwnd,,SysListView321,ahk_id %id1%
		If DllCall("IsWindowVisible", UInt, DID)
			WinHide, ahk_id %DID%
		Else
			WinShow, ahk_id %DID%
		Return
		*/
	}

	; 浏览器窗口
	If (窗口Class = "OperaWindowClass" || 窗口Class = "MozillaWindowClass" || 窗口Class = "MozillaUIWindowClass"|| 窗口Class = "Chrome_WidgetWin_1" || 窗口Class = "360se6_Frame")
	{
		WinGetPos , , , Width,,A
		MouseGetPos, 窗口x坐标, 窗口y坐标
		; 指针是否在窗口标题栏按坐标来判断
		If (窗口y坐标 <= 30) && (窗口y坐标 >= -1) && (窗口x坐标 >= -1) && (窗口x坐标 <= Width)
		{
			; Chrome浏览器窗口点击
			if(窗口Class = "Chrome_WidgetWin_1")
			{
				Acc := Acc_ObjectFromPoint(ChildId)
				AccRole :=Acc_GetRoleText(Acc.accRole(ChildId))
				if(AccRole != "选项卡列表")
				{
					Send, {MButton}  ; 关闭便签页
				return
				}
				else
				{
					PostMessage,0x112,0xF060,,,A ; 关闭窗口
				return
				}
			}
			if(窗口Class = "OperaWindowClass")
			{
				Send, {MButton}
			Return
			}
			PostMessage,0x112,0xF060,,,A ; 其他浏览器窗口，为关闭窗口，不管这个窗口是在顶层还是底层
		return
		}
		else
			Send, {MButton}  ; 浏览器窗口其他位置发送中键
	Return
	}

	; 未激活窗口先点击激活
	send {click}
	WinGetPos , , , Width,, A
	MouseGetPos, 窗口x坐标, 窗口y坐标
	If (窗口y坐标 <= 28) && (窗口y坐标 >= -1) && (窗口x坐标 >= -1) && (窗口x坐标 <= Width) ; 指针是否在窗口标题栏
	{
		; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
		PostMessage,0x112,0xF060,,,A ; 如果是在窗口标题栏上，为关闭窗口，不管这个窗口是在顶层还是底层
	return
	}
	else
	{
		Send, {MButton}
		;tooltip 中键点击最后一步
	}
	CoordMode, Mouse, Screen
return

jkMbutton:
Send {Mbutton up}
return

WatchCursor2:
	;ToolTip,%winlist%
	CoordMode, Mouse , Screen ; 加上这一句为检测鼠标在屏幕的位置，不加为检测鼠标在各个窗口的位置
	MouseGetPos,xpos,ypos
	If (ypos < oldy-5) or (ypos > oldy+125)
	{
		Loop,Parse, winlist,|
		{
			IfNotEqual,id,%A_LoopField%
			WinHide,ahk_id %A_LoopField%,,,
		}
	}
	else
	{
		Loop,Parse, winlist,|
		{
			WinShow,ahk_id %A_LoopField%
			WinActivate,ahk_id %A_LoopField%
			IfWinActive, %AppTitle%
			{
				WinGetPos,,newy,,,%AppTitle%
				;tooltip,%newy%-%oldy%
				if (newy !="") and (newy != oldy)
				oldy := newy
			}
		}
	}
return

Alt & WheelDown::
	Gosub, GetUnderMouseInfo
	WinGetPos,trayX,trayY,trayW,trayH, ahk_class Shell_TrayWnd
	hh = %trayY%
	hh += %trayH%

	if (_x >= A_ScreenWidth * 0.96)
	{
		if (_y>=A_ScreenHeight - 30)
		{
			Gosub, vol_MasterDown
		Return
		}
	}

	ActiveWinTitle := MouseIsOverTitlebar()
	If (ActiveWinTitle and (_class = _aClass))
	{
		If (( _x >= _winX +0 ) And ( _x <= _winX + 80 ))
		{
			If(_class= "Progman" or _class= "WorkerW")
			Return
			Else
			{
				_Transparent = 0
				Gosub, ChangeTransparency1
			Return
			}
		}
		Else
		{
			WinGet, ws_ID, ID, A
			Loop, Parse, ws_IDList, |
			{
				IfEqual, A_LoopField, %ws_ID%
				{
					; Match found, so this window should be restored (unrolled):
					StringTrimRight, ws_Height, ws_Window%ws_ID%, 0
					WinMove, ahk_id %ws_ID%,,,,, %ws_Height%
					StringReplace, ws_IDList, ws_IDList, |%ws_ID%
				return
				}
			}
		}
	}

	if (ScrollUnderMouse)
	{
		;wheelcount=1
		;SendMessage, 0x20A , ((-120)*wheelcount)<<16 , (_y<<16) | _x , ,ahk_id %_control%
		;hw_m_target := DllCall( "WindowFromPoint", "int", _x, "int", _y )
		PerformWheel(false, A_EventInfo)
	}
	Else
		Send, {WheelDown}
Return

Alt & WheelUp::
	Gosub, GetUnderMouseInfo
	CoordMode, Mouse, Screen
	WinGetPos,trayX,trayY,trayW,trayH, ahk_class Shell_TrayWnd

	hh = %trayY%
	hh += %trayH%

	if (_x >= A_ScreenWidth * 0.96)
	{
		if (_y>=A_ScreenHeight - 30)
		{
			Gosub, vol_MasterUp
		Return
		}
	}

	ActiveWinTitle := MouseIsOverTitlebar()
	If (ActiveWinTitle and (_class = _aClass))
	{
		If (( _x >= _winX + 0 ) And ( _x <= _winX + 80 ))
		{
			If(_class= "Progman" or _class= "WorkerW")
			Return
			Else
			{
				_Transparent = 1
				Gosub, ChangeTransparency1
			Return
			}
		}
		Else
		{
			WinGet, ws_ID, ID, A
			WinGetPos,,,, ws_Height, A
			if ws_Height = %Title_Bar_Height%
			Return
			ws_Window%ws_ID% = %ws_Height%
			ws_IDList = %ws_IDList%|%ws_ID%
			WinMove, ahk_id %ws_ID%,,,,, %ws_MinHeight%
			WinGetPos,,,, Title_Bar_Height, A
		return
		}
	}

	if (ScrollUnderMouse)
	{
		;wheelcount=1
		;SendMessage, 0x20A , (120*wheelcount)<<16 , (_y<<16) | _x , ,ahk_id %_control%
		;hw_m_target := DllCall( "WindowFromPoint", "int", _x, "int", _y )
		PerformWheel(True, 1)
	}
	Else
		Send, {WheelUp}
Return

GetUnderMouseInfo:
	CoordMode,Mouse,Screen
	MouseGetPos, _x, _y, _id, _control,3
	WinGetTitle, _title, ahk_id %_id%
	WinGetClass, _class, ahk_id %_id%
	WinGetPos, _winX, _winY, _winW, _winH, ahk_id %_id%
	WinGetActiveStats, _aT, _aW, _aH, _aX, _aY
	WinGet, _aId, ID, A
	WinGetClass, _aClass, A
Return

; http://www.ahkcn.net/thread-2503.html
PerformWheel(bUp, wheelcount)
{
	MouseGetPos, _x, _y, _id, _control,2
	WinGetClass, _class, ahk_id %_id%
	;ToolTip ,%bUp% - %_control% - %_id% - %_class%
	if (_class != "TXGuiFoundation")    ; QQ
	{
		if (_control = "")
		{
			SendMessage, 0x20A ; WM_MOUSEWHEEL
					, bUp ? (120*wheelcount)<<16 : ((-120)*wheelcount)<<16 ;DELTA
					, (_y<<16) | _x ;Mouse Coord
					, ,ahk_id %_id%
		}
		else
		{
			SendMessage, 0x20A ;WM_MOUSEWHEEL
					, bUp ? (120*wheelcount)<<16 : ((-120)*wheelcount)<<16 ;DELTA
					, (_y<<16) | _x ;Mouse Coord
					, ,ahk_id %_control%
		}
	}
	else
	{
		qqqq:= bUp ? "{WheelUp}" : "{WheelDown}"
		Send, %qqqq%
	Return
	}
Return
}

isSpecialWin()
{
	ok = 0
	IfInString,_class,bbIconBox
		ok = 1
	IfInString,_class,BlackboxClass
		ok = 1
	IfInString,_class,Opwindow
		ok = 1
	IfInString,TaskBar,_class
		ok = 1
	IfInString,Maxthon,_class
		ok = 1
	if(instr(class,"atl") or class="Shell_TrayWnd" or class="Progman" or class="kfwindow" or class="Button" or class="pluginhost" or class="_gd_sidebar")
		ok = 1
Return ok
}

ChangeTransparency1:
	Gosub, _CheckWinIDs
	SetWinDelay, -1
	IfWinActive, A
	{
		WinGet, _WinID, ID
		If ( !_WinID )
		Return

		IfNotInString, _WinIDs, |%_WinID%
			_WinIDs = %_WinIDs%|%_WinID%
		_WinAlpha := _WinAlpha%_WinID%
		_PixelColor := _PixelColor%_WinID%
		_WinAlphaStep := 255 * 0.1
		If ( _WinAlpha = "" )
			_WinAlpha = 255
		If (_Transparent = 0)
		{
			_WinAlpha -= _WinAlphaStep
			If( _WinAlpha < 1 )
				_WinAlpha=1
		}
		Else
			_WinAlpha += _WinAlphaStep
		If ( _WinAlpha > 255 )
			_WinAlpha = 255


		_WinAlpha%_WinID% = %_WinAlpha%
		If ( _PixelColor )
			WinSet, TransColor, %_PixelColor% %_WinAlpha%, ahk_id %_WinID%
		Else
			WinSet, Transparent, %_WinAlpha%, ahk_id %_WinID%
		_ToolTipAlpha := _WinAlpha * 100 / 255
		Transform, _ToolTipAlpha, Round, %_ToolTipAlpha%
	}
Return

vol_MasterUp:
	SoundSet +%vol_Step%
	Gosub, vol_ShowBars
Return

vol_MasterDown:
	SoundSet -%vol_Step%
	Gosub, vol_ShowBars
Return

vol_ShowBars:
	SoundGet,vol_Master
	if vol_Master = 0
	{
		vol_Colour = Red
		vol_Text = 音量 (已静音)
	}
	else
	{
		vol_Colour := BarColor
		vol_Text = 音量
	}
	; To prevent the "flashing" effect, only create the bar window if it doesn't already exist:
	IfWinNotExist, VolumeOSDxyz
	{
		Progress, %vol_BarOptionsMaster% CB%vol_Colour% CT%vol_Colour%, , %vol_Text%, VolumeOSDxyz
		WinSet, Transparent, %vol_TransValue%, VolumeOSDxyz
	}
	Progress, 1:%vol_Master%, , %vol_Text%
	SetTimer, vol_BarOff, %vol_DisplayTime%
Return

vol_BarOff:
	SetTimer, vol_BarOff, off
	Progress, 1:Off
Return

_CheckWinIDs:
	DetectHiddenWindows, On
	Loop, Parse, _WinIDs, |
		If ( A_LoopField )
			IfWinNotExist, ahk_id %A_LoopField%
			{
				StringReplace, _WinIDs, _WinIDs, |%A_LoopField%, , All
				_WinAlpha%A_LoopField% =
				_PixelColor%A_LoopField% =
			}
Return

恢复窗口:
_TransparencyAllOff:
	Gosub, _CheckWinIDs
	Loop, Parse, _WinIDs, |
		If ( A_LoopField )
		{
			_WinID = %A_LoopField%
			Gosub, _TransparencyOff
		}
Return

_TransparencyOff:
	Gosub, _CheckWinIDs
	SetWinDelay, -1
	If ( !_WinID )
		Return
	IfNotInString, _WinIDs, |%_WinID%
		Return
	StringReplace, _WinIDs, _WinIDs, |%_WinID%, , All
	_WinAlpha%_WinID% =
	_PixelColor%_WinID% =

	WinSet, Transparent, 255, ahk_id %_WinID%
	WinSet, TransColor, OFF, ahk_id %_WinID%
	WinSet, Transparent, OFF, ahk_id %_WinID%
	WinSet, Redraw, , ahk_id %_WinID%
Return