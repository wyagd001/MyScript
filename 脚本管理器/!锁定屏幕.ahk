;原作者：逍遥猪葛亮
;来源：小众软件·http://www.appinn.com
SetWorkingDir %A_ScriptDir%
#Persistent
#SingleInstance Force

W = %A_ScreenWidth%
fx := W//2-150

H = %A_ScreenHeight%
fy := H//2-20

ifexist, Lock.ico
	Menu, tray, icon, Lock.ico
ifnotexist, 锁定屏幕.ini
{
	inputbox, key, 请设置密码,请设置锁定屏幕后的解锁密码
	IniWrite, %key%, 锁定屏幕.ini, setting, key
}
IniRead, key, 锁定屏幕.ini, setting, key
if key=""
{
	inputbox, key, 请设置密码,请设置锁定屏幕后的解锁密码
	IniWrite, %key%, 锁定屏幕.ini, setting, key
}
gosub, makemenu
; 优化内存
EmptyMem()
return

set:
        inputbox, key, 请设置密码,请设置锁定屏幕后的解锁密码
        if ErrorLevel
           return
	IniWrite, %key%, 锁定屏幕.ini, setting, key
	menu, tray, Rename, %menukey%, 密码：%key%
	menukey=密码：%key%
Return

#L::
start:
	blockinput, MouseMove
	Gui, +AlwaysOnTop +Disabled -SysMenu +Owner -Caption +ToolWindow
        gui, font, s28
	gui, add, text,x%fx% y%fy% cred , 你已经锁定了键盘与鼠标`n请输入正确的密码以解锁
	CustomColor = 000000
	Gui, Color, %CustomColor%
	gui, show,X0 Y0 W%A_ScreenWidth% H%A_ScreenHeight%,锁定屏幕
        WinSet,Transparent,150,锁定屏幕
	hotkey, Lbutton, stop
	hotkey, Rbutton, stop
	hotkey, Mbutton, stop
	hotkey, LWin, stop
	hotkey, Rwin, stop
	hotkey, LAlt, stop
	hotkey, RAlt, stop
	hotkey, Ctrl, Stop
	hotkey, esc, stop
	hotkey, del, stop
	hotkey, f1, stop
	hotkey, f4, stop
	hotkey, tab, stop
	i:=1
	Loop
	{
		input, a, L1
		StringLeft, temp, key, %i%
		stringright, temp, temp, 1
		if a=%temp%
		{
			i++
		}else{
			i:=1
		}
		if (i=(strlen(key)+1))
		{
			blockinput, mousemoveoff
			gui, Destroy
			Gui, +AlwaysOnTop +Disabled -SysMenu +Owner -Caption +ToolWindow
			gui, add, text, , 已解锁，程序即将退出
			CustomColor = 999A9B
			Gui, Color, %CustomColsor%
			gui, show
			sleep, 500
			gui, destroy
			Reload
		}
	}
Return

stop:
return

makemenu:
	menu, tray, NoStandard
	Menu, Tray, DeleteAll
	menu, tray, add, 锁定屏幕 Win+L, start
	menu, tray, default, 锁定屏幕 Win+L
		menukey=密码：%key%
	menu, tray, add, %menukey%, stop
	menu, tray, disable, %menukey%
	menu, tray, add, 关于..., about
	menu, tray, add
	menu, tray, add, 设置密码, set
	menu, tray, add
	menu, tray, add, 退出, exitit
Return

about:
	traytip, , by 逍遥猪葛亮`n小众软件·http://www.appinn.com
Return

exitit:
	ExitApp
Return

EmptyMem(PID="AHK Rocks"){
    pid:=(pid="AHK Rocks") ? DllCall("GetCurrentProcessId") : pid
    h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
    DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
    DllCall("CloseHandle", "Int", h)
}