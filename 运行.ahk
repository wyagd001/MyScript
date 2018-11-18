; 在一个脚本已经运行时，如果再次打开它，
; 将跳过对话框，并自动地运行（替换原来打开的脚本）。
#SingleInstance force
#NoTrayIcon
; 探测“隐藏"的窗口
DetectHiddenWindows, On
; 设置脚本的执行速度
SetBatchLines -1
ComObjError(0)
AutoTrim, On
SetWinDelay, 0
; 匹配模式 窗口标题包含有指定文字时符合匹配 。
SetTitleMatchMode 2
; 设置鼠标的坐标模式为相对于整个屏幕的坐标模式
CoordMode, Mouse, Screen

; 开机时启动脚本，等待时间设置长些，使托盘图标可以显示出来
if(A_TickCount<120000)
	sleep,40000

global run_iniFile := A_ScriptDir "\settings\setting.ini"
IfNotExist, %run_iniFile%
	FileCopy, %A_ScriptDir%\Backups\setting.ini, %run_iniFile%
global visable

IniRead, content, %run_iniFile%,功能开关
Gosub, GetAllKeys

; 在脚本最开头，利用Reload变通实现批量#Include
; 自动生成AutoIncludeAll.ahk
If Auto_Include
	Gosub, _AutoInclude

; 管理员权限
If(!A_IsAdmin)
	{
		Loop %0%
			params .= " " (InStr(%A_Index%, " ") ? """" %A_Index% """" : %A_Index%)
		uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_AhkPath, str, """" A_ScriptFullPath """" params, str, A_WorkingDir, int, 1)
		If(uacrep = 42) ; UAC Prompt confirmed, application may Run as admin
			MsgBox, 成功启用管理员权限
		Else
			MsgBox, 没有启用管理员权限
}

; 退出脚本时，执行ExitSub，关闭自动启动的脚本、恢复窗口等等操作。
OnExit, ExitSub

;========变量设置开始========
FileRead, AppVersion, %A_ScriptDir%\version.txt
AppTitle = 拖拽移动文件到目标文件夹(自动重命名)

FloderMenu_iniFile = %A_ScriptDir%\settings\FloderMenu.ini
SaveDeskIcons_inifile = %A_ScriptDir%\settings\SaveDeskIcons.ini
update_txtFile = %A_ScriptDir%\settings\tmp\CurrentVersion.txt
ScriptManager_Path=%A_ScriptDir%\脚本管理器

global Candy_ProFile_Ini := A_ScriptDir . "\settings\candy\[candy].ini"
SplitPath,Candy_ProFile_Ini,,Candy_Profile_Dir,,Candy_ProFile_Ini_NameNoext
global Windy_Profile_Ini  := A_ScriptDir . "\settings\Windy\Windy.ini"
SplitPath,Windy_Profile_Ini,,Windy_Profile_Dir,,Windy_Profile_Ini_NameNoext

;---------Alt+滚轮调节音量随机颜色---------
Random,ColorNum,0,6
; BarColor:=SubStr("0BFF3F FFFFFF 1187FFFFCD00D962FFCE55AA0FDCFF",ColorNum*6+1,6)
; BarColor:=SubStr("6BD536FFFFFFC7882DFFCD00D962FFFF55554FDCFF",ColorNum*6+1,6)
BarColor := SubStr("FFFF000CFF0C0C750CD962FFFF55554FDCFF1187FF",ColorNum*6+1,6)
StringLeft,ColorLeft,BarColor,2
StringRight,ColorRight,BarColor,2
BarColor := SubStr(BarColor,3,2)
BarColor := ColorRight . BarColor . ColorLeft

; -------------------
; START CONFIGURATION
; -------------------
; The percentage by which to raise or lower the volume each time
vol_Step = 8
; How long to display the volume level bar graphs (in milliseconds)
vol_DisplayTime = 1000
; Transparency of window (0-255)
vol_TransValue = 255
; Bar's background colour
vol_CW = EEEEEE
vol_Width = 200  ; width of bar
vol_Thick = 20   ; thickness of bar
; Bar's screen position
vol_PosX := A_ScreenWidth - vol_Width - 90
vol_PosY := A_ScreenHeight - vol_Thick - 72
; --------------------
; END OF CONFIGURATION
; --------------------
vol_BarOptionsMaster = 1:B1 ZH%vol_Thick% ZX8 ZY4 W%vol_Width% X%vol_PosX% Y%vol_PosY% CW%vol_CW%
;---------Alt+滚轮调节音量随机颜色---------

; 托盘菜单中打开帮助文件和spy时需指定路径，判断托盘图标指定进程名
; 将Autohotkey.exe的完整路径分割，贮存Autohotkey.exe所在目录的路径为"pathd"
Splitpath,A_AhkPath,Ahk_Process,pathd

; 检测系统版本
; 版本号>6  Vista7为真(1)
RegRead,Vista7, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, CurrentVersion
global Vista7 := Vista7 >= 6.0.7

;---------水平垂直最大化---------
VarSetCapacity( work_area, 16 )
DllCall( "SystemParametersInfo"
         , "uint", 0x30                                          ; SPI_GETWORKAREA
         , "uint", 0
         , "uint", &work_area    ;结构左0右8上4下12  NumGet(work_area,8)
         , "uint", 0 )

; 获取工作区域宽
work_area_w := NumGet(work_area,8)-NumGet(work_area,0)
; 获取工作区域高,不计算任务栏高度
work_area_h := NumGet(work_area,12)-NumGet(work_area,4)
;----------------------------------水平垂直最大化----------------------------

x_x2:=work_area_w- 634
y_y2:=work_area_h- 108

; 最近关闭的资源管理器窗口
global CloseWindowList := []
global ClosetextfileList := []
global folder := []
global textfile := [] 
IniRead, CloseWindowFolders, %run_iniFile% , CloseWindowList
CloseWindowList := StrSplit(CloseWindowFolders,"`n")
Array_Sort(CloseWindowList)
IniRead, Closetextfiles, %run_iniFile% , ClosetextfileList
ClosetextfileList := StrSplit(Closetextfiles,"`n")
Array_Sort(ClosetextfileList)

; Candy，Windy
	global szMenuIdx:={}      ;菜单用1
	global szMenuContent:={}      ;菜单用2
	global szMenuWhichFile:={}      ;菜单用3
;=========变量设置结束=========

;=========读取配置文件开始=========
IniRead,stableProgram,%run_iniFile%,固定的程序,stableProgram
IniRead,DefaultPlayer, %run_iniFile%,固定的程序, DefaultPlayer
IniRead,historyData, %run_iniFile%,固定的程序, historyData
IniRead,询问, %run_iniFile%,截图, 询问
IniRead,filetp, %run_iniFile%,截图, filetp
IniRead,screenshot_path, %run_iniFile%,截图,截图保存目录

IniRead,ws_MinHeight, %run_iniFile%,缩为标题栏, ws_MinHeight
IniRead,ws_Animate, %run_iniFile%,缩为标题栏, ws_Animate
IniRead,ws_RollUpSmoothness, %run_iniFile%,缩为标题栏, ws_RollUpSmoothness
IniRead,Edge_Dock_Activation_Delay, %run_iniFile%,自动显示隐藏窗口, Edge_Dock_Activation_Delay
IniRead,Edge_Dock_Border_Visible, %run_iniFile%,自动显示隐藏窗口, Edge_Dock_Border_Visible

IniRead, content, %run_iniFile%,常规
Gosub, GetAllKeys

IniRead, content, %run_iniFile%,功能模式选择
Gosub, GetAllKeys

If TargetFolder
{
	IfnotExist,%TargetFolder%
	{
	TargetFolder=
	IniWrite,%TargetFolder%,%run_iniFile%,常规,TargetFolder
	}
}
IniRead,LastClosewindow,%run_iniFile%,常规,LastClosewindow
If LastClosewindow
{
	IfnotExist,%LastClosewindow%
	{
	LastClosewindow=
	IniWrite,%LastClosewindow%,%run_iniFile%,常规,LastClosewindow
	}
}

IniRead, content, %run_iniFile%,自动激活
Gosub, GetAllKeys

IniRead, content, %run_iniFile%,时间
Gosub, GetAllKeys

;----------窗口缩略图----------
If MiniMizeOn
{
IniRead, content, %run_iniFile%,窗口缩略图
Gosub, GetAllKeys

MiniMizeNum=50
ffw:=fw-5 ;缩略图窗口里的图片宽
fx2:=A_ScreenWidth - fw
fy2:=A_ScreenHeight - fh - 35

If shuipingxia
fy :=fy2      ;水平排列时定义Y值
If shuzhiyou
fx :=fx2      ;竖直在右边排列时定义X值
iconx:=fw - 48
icony:=fh - 48
}
;----------窗口缩略图----------

Loop 8
{
    z:=A_Index
    IniRead, FF%z%, %run_iniFile%, FastFolders, Folder%z%
    IniRead, FFTitle%z%, %run_iniFile%, FastFolders, FolderTitle%z%
}

IniRead AudioPlayer,%run_iniFile%,AudioPlayer
	loop,parse,AudioPlayer,`n
{
AudioPlayer_key:=RegExReplace(A_LoopField,"=.*?$")
AudioPlayer_Val:=RegExReplace(A_LoopField,"^.*?=")
%AudioPlayer_key%=%AudioPlayer_Val%
menu,audioplayer,add,%AudioPlayer_key%,DPlayer
}

; 读取我的变量，进行环境变量设置
IniRead otherProgram,%run_iniFile%,otherProgram

	loop,parse,otherProgram,`n
	{
		MyVar_Key:=RegExReplace(A_LoopField,"=.*?$") 		; 用户自定义变量的key
		MyVar_Val:=RegExReplace(A_LoopField,"^.*?=") 		; 用户自定义变量的value
		If (MyVar_Key && MyVar_Val && not instr(MyVar_Key," ")) 		; 抛弃空变量以及含空格的变量
			%MyVar_Key%=%MyVar_Val% 		; 这样的写法不会传递环境变量。EnvSet,%MyVar_Key%,"%MyVar_Val%"
; 另一种写法，可以传递环境变量到被他启动的应用程序
	}
;=========读取配置文件结束=========

;=========托盘菜单绘制=========
;----------创建AHK脚本管理器的托盘菜单----------
Menu scripts_unopen, Add, 启动脚本,nul
Menu scripts_unopen, ToggleEnable, 启动脚本
Menu scripts_unopen, Default, 启动脚本
Menu scripts_unopen, Add
Menu scripts_unclose, Add, 关闭脚本,nul
Menu scripts_unclose, ToggleEnable, 关闭脚本
Menu scripts_unclose, Default, 关闭脚本
Menu scripts_unclose, Add
Menu scripts_edit, Add, 编辑脚本,nul
Menu scripts_edit, ToggleEnable, 编辑脚本
Menu scripts_edit, Default, 编辑脚本
Menu scripts_edit, Add
Menu scripts_reload, Add, 重载脚本,nul
Menu scripts_reload, ToggleEnable, 重载脚本
Menu scripts_reload, Default, 重载脚本
Menu scripts_reload, Add

; AHK脚本管理器初始计数值
scriptCount = 0
; 遍历"脚本管理器"目录下所有ahk文件
Loop, %ScriptManager_Path%\*.ahk
{
    StringRePlace menuName, A_LoopFileName, .ahk

    scriptCount += 1
    scripts%scriptCount%0 := A_LoopFileName

    IfWinExist %A_LoopFileName% - AutoHotkey    ; 已经打开
    {
        Menu,scripts_unclose, add, %menuName%, tsk_close
        scripts%scriptCount%1 = 1
    }
    Else
    {
        Menu,scripts_unopen, add, %menuName%, tsk_open
        scripts%scriptCount%1 = 0
    }
    Menu,scripts_edit, add, %menuName%, tsk_edit
    Menu,scripts_reload, add, %menuName%, tsk_reload
}

;打开"脚本管理器"目录中的子脚本,以"!"开头的脚本不会自动打开.
GoSub tsk_openAll
;测试启动时间
;ElapsedTime := A_TickCount - StartTime
;msgbox % ElapsedTime

;----------托盘菜单----------
; 菜单出错不提示，影响脚本中所有菜单，例如candy提取不到图标不会报错
Menu, Tray, UseErrorLevel
Menu, Tray, Icon,%A_ScriptDir%\pic\run.ico
Menu, Tray, add, 打开(&O), Open1
Menu, Tray, add, 帮助(&H), Help
Menu, Tray, add, &Windows Spy, Spy
Menu, Tray, Add
Menu, Tray, Add, Ahk 脚本管理器,nul
Menu, Tray, disable, Ahk 脚本管理器
Menu, Tray, Add
Menu, Tray, Add, 启动所有脚本(&A)`t, tsk_openAll
Menu, Tray, Add, 启动脚本(&Q)`t, :scripts_unopen
Menu, Tray, Add, 关闭所有脚本(&L)`t, tsk_closeAll
Menu, Tray, Add, 关闭脚本(&C)`t, :scripts_unclose
Menu, Tray, Add
Menu, Tray, Add, 编辑脚本(&I)`t, :scripts_edit
Menu, Tray, Add, 重载脚本(&D)`t, :scripts_reload
Menu, Tray, Add
Menu, Tray, Add, 运行 - Ahk,nul
Menu, Tray, disable, 运行 - Ahk
Menu, Tray, Add
Menu, Tray, Add, 重启脚本(&R)`tCtrl+R, 重启脚本
Menu, Tray, Add, 编辑脚本(&E), 编辑脚本
Menu, Tray, Add
Menu, Tray, add, 挂起所有热键(&S)`tAlt+Pause, 挂起所有热键
Menu, Tray, add, 暂停脚本(&P)`tPause, 暂停脚本
Menu, Tray, Add, 选项(&T)`tCtrl+P, 选项
Menu, Tray, Add, 退出(&X)`t, Menu_Tray_Exit
Menu, Tray, Add
Menu, Tray, Add, 显示/隐藏`tWin+X,show
Menu, Tray, Default, 显示/隐藏`tWin+X
Menu, Tray, Add
Menu, Tray, NoStandard
Menu, Tray, Click, 1
Menu, Tray, Tip, 运行 - Ahk(For Win_7)`n众多实用Ahk脚本的合集。
;----------托盘菜单----------
;=========托盘菜单绘制=========

;=========主界面的"绘制"=========
ComboBoxShowItems :=stableProgram . historyData

;master_mute:=VA_GetMute()
SoundGet,master_mute,,mute
If(master_mute="on")
;color = red
volimage = %A_ScriptDir%\pic\m_vol.ico
Else
;color = green
volimage = %A_ScriptDir%\pic\vol.ico

menu, audioplayer, Check,%DefaultPlayer%

Process, Exist, %DefaultPlayer%.exe
If ErrorLevel = 0
Image = %A_ScriptDir%\pic\MusicPlayer\%DefaultPlayer%.bmp
Else
Image = %A_ScriptDir%\pic\MusicPlayer\h_%DefaultPlayer%.bmp

;图形界面的"绘制"
;窗口  +无最小化按钮（任务栏无按钮）
Gui,  +HwndHGUI +ToolWindow
Gui, Add, Text, x1 y10 w90 h20 +Center, 目标/运行:
Gui, Add, ComBoBox, x90 y10 w330 h300 +HwndhComBoBox vDir,% ComBoBoxShowItems
global hComBoBox
global objListIDs:= Object() 
global del_ico:=0 ; 0= text "X", 1= icon
global single_ico:=0
fn := Func("List_Func").Bind(hComBoBox)
GuiControl, +g, % hComBoBox, % fn
Gui, Add, Button, x425 y10 gselectfile,&.
Gui, Add, Button, x445 y10 gselectfolder,选择(&S)
Gui, Add, Button, x500 y10 default gopenbutton,打开(&O)
Gui, Add, Button, x555 y10 gabout,关于(&A)
Gui, Add, Button,x445 y35  gaddfavorites,加入收藏
Gui, Add, Button,x515 y35  gshowfavorites,>
Gui, Add, Button,x555 y35 gliebiao,列表(&L)
Gui, Add, Picture, x90 y35 w16 h16 gOpenAudioPlayer vpicture, %image%
AddGraphicButton(1,"x108","y32","h21","w40","GB1", A_ScriptDir . "\pic\MusicControl\prev.bmp",A_ScriptDir . "\pic\MusicControl\h_prev.bmp" ,A_ScriptDir . "\pic\MusicControl\d_prev.bmp")
AddGraphicButton(1,"x147","y32","h21","w40","GB2", A_ScriptDir . "\pic\MusicControl\pause.bmp",A_ScriptDir . "\pic\MusicControl\h_pause.bmp" ,A_ScriptDir . "\pic\MusicControl\d_pause.bmp")
AddGraphicButton(1,"x186","y32","h21","w40","GB3", A_ScriptDir . "\pic\MusicControl\next.bmp",A_ScriptDir . "\pic\MusicControl\h_next.bmp" ,A_ScriptDir . "\pic\MusicControl\d_next.bmp")
AddGraphicButton(1,"x225","y32","h21","w40","GB4", A_ScriptDir . "\pic\MusicControl\close.bmp",A_ScriptDir . "\pic\MusicControl\h_close.bmp" ,A_ScriptDir . "\pic\MusicControl\d_close.bmp")
Gui, Add, Picture, x285 y35 w16 h16 gmute vvol, %volimage%
Gui, Add, Slider, x300 y35 w100 h20 vVSlider Range0-100 gVolumeC
Gui, Add, Text,x10 y30 cblue, 光驱
Gui, Add, Text,x10 y45 cblue, USB
Gui, Add, Text,x40 y30 cgreen vopenCD gdriver,开
Gui, Add, Text,x40 y45 cgreen g弹出U盘,弹出
Gui, Add, Text,x60 y30 cgreen gdriver,关
Gui, Add, Text,x10 y64 cgreen gchangyong,常用
Gui, Add, Text,x100 y64 cgreen gDesktoplnk,桌面
Gui, Add, Text,x200 y64 cgreen vfhc gfoo_httpcontrol_click,Foo_HttpControl
Gui, Add, Text,x340 y64 cgreen gIEfavorites,IE收藏夹

;----------音量----------
SoundGet,vol_Master
;vol_Master := VA_GetMasterVolume()
;RSound := Round(vol_Master)
Guicontrol,,VSlider,%vol_Master%

Process, Exist, %DefaultPlayer%.exe
If ErrorLevel = 0
GuiControl, Disable,fhc
Else
{
If (DefaultPlayer="Foobar2000")
          {
              If WinExist("foo_httpcontrol")
              GuiControl,Enable,fhc
          }
}

Menu,  addf, Add, 开机启动, runwithsys
Menu,  addf, Add, 智能浏览器, smartchooserbrowser
Menu,  addf, Add, 自动激活窗口(临时), _TrayEvent
Menu,  addf, Add, 启动时记忆桌面图标,AutoSaveDeskIcons
Menu,  addf, Add, 记忆桌面图标, SaveDesktopIconsPositions
Menu,  addf, Add, 恢复桌面图标, RestoreDesktopIconsPositions

if Auto_DisplayMainWindow
{
Gui, Show, x%x_x% y%y_y% w624 h78, %AppTitle%
visable = 1
}
else
{
是否检测:=0
Gui, Show, hide x%x_x% y%y_y% w624 h78, %AppTitle%
visable= 0
}
;=========图形界面的"绘制"=========

;=========图形界面的"绘制"2=========
If ( run_with_sys=1)
	{
		Menu, addf, Check, 开机启动
	}
Else
	{
		Menu, addf, UnCheck, 开机启动
}

If ( smartchooserbrowser )
	{
		Menu, addf, Check,智能浏览器
        writeahkurl()
        }
Else
	{
		Menu, addf, UnCheck, 智能浏览器
}

If (Auto_SaveDeskIcons=1)
	{
        Menu, addf, Check, 启动时记忆桌面图标
        SetTimer,SaveDesktopIconsPositionsdelay,30000
        Menu, addf, Disable,  恢复桌面图标
	}
Else
	{
		Menu, addf, UnCheck, 启动时记忆桌面图标
        IfNotExist,%SaveDeskIcons_inifile%
        Menu, addf, Disable,  恢复桌面图标
	}

;检测鼠标,图片按钮的鼠标效果
OnMessage(0x200, "MouseMove")
OnMessage(0x201, "MouseLdown")
OnMessage(0x202, "MouseLUp")
;OnMessage(0x202, "MouseLeave")
;OnMessage(0x2A3, "MouseLeave")
;检测主程序窗口右键点击弹出菜单
OnMessage(0x205, "RBUTTONUP")
;监视U盘插入
OnMessage(0x0219, "WM_DEVICECHANGE")
;监视ShellExtension.dll传递的消息
OnMessage(55555, "TriggerFromContextMenu")
DllCall("ChangeWindowMessageFilter", "UInt", 55555, "UInt", 1)

;鼠标点击，原窗口缩略图拖拽移动的代码现已不用
;OnMessage(0x201, "WM_LBUTTONDOWN")

;拖拽文件窗口执行函数
GuiDropFiles.config(HGUI, "GuiDropFiles_Begin", "GuiDropFiles_End")
;拖拽到ComboBox或Edit1控件上不复制文件
ControlGet,hComboBoxEdit,hWnd,,Edit1,ahk_id %HGUI%
;=========图形界面的"绘制"2=========

;----------不显示托盘图标则重启脚本----------
Menu, Tray, Icon
if Auto_Trayicon
{
  While (180000 - A_TickCount) > 0
   sleep,100
 Script_pid:=DllCall("GetCurrentProcessId")
 Tray_Icons := {}
 Tray_Icons := TrayIcon_GetInfo(Ahk_Process)
 for index, Icon in Tray_Icons {
  trayicons_pid .= Icon.Pid ","
 }

 If trayicons_pid not contains %Script_pid%
 {
  Menu, Tray, NoIcon
  sleep,300
  Menu, Tray, Icon
  Tray_Icons := {}
  trayicons_pid := ""
  Tray_Icons := TrayIcon_GetInfo(Ahk_Process)
  for index, Icon in Tray_Icons {
   trayicons_pid .= Icon.Pid ","
  }
 }

 If trayicons_pid not contains %Script_pid%
 {
  if Auto_Trayicon_showmsgbox
  {
   msgbox,4,错误,未检测到脚本的托盘图标，点"是"重启脚本，点"否"继续运行脚本。`n默认(超时)自动重启脚本。,6
   IfMsgBox Yes
    autoreload=1
   else IfMsgBox timeout
    autoreload=1
  }
  else
   autoreload=1

  连续重启次数:=CF_IniRead(run_iniFile,"时间","连续重启次数",0)
  if 连续重启次数 > 5
  {
   IniWrite,0,% run_iniFile,时间,连续重启次数
   IniWrite,0,% run_iniFile,功能开关,Auto_Trayicon
   Msgbox 脚本多次运行都不能检测到托盘图标，脚本下次启动将不再检测托盘图标。
  }
  else
  {
   连续重启次数 += 1
   IniWrite,% 连续重启次数,% run_iniFile,时间,连续重启次数
  }

  if(autoreload=1)
  {
   Reload
  Return
  }
 }
}
;----------不显示托盘图标则重启脚本----------

;=========窗口分组=========
;依次将桌面，显示桌面，我的电脑，资源管理器,另存为窗口加入"组" "ccc"中,应用于定位文件,复制路径,智能重命名等
GroupAdd, ccc, ahk_class CabinetWClass
GroupAdd, ccc, ahk_class ExploreWClass
GroupAdd, ccc, ahk_class Progman
GroupAdd, ccc, ahk_class WorkerW
GroupAdd, ccc, ahk_class #32770

; 主界面网址补齐、runhistory  #ifwinactive  后不能接变量
GroupAdd, AppMainWindow,%AppTitle%

GroupAdd, ExplorerGroup, ahk_class CabinetWClass
GroupAdd, ExplorerGroup, ahk_class ExploreWClass
GroupAdd, DesktopGroup, ahk_class Progman
GroupAdd, DesktopGroup, ahk_class WorkerW
GroupAdd, DesktopTaskbarGroup,ahk_class Progman
GroupAdd, DesktopTaskbarGroup,ahk_class WorkerW
GroupAdd, DesktopTaskbarGroup,ahk_class Shell_TrayWnd
GroupAdd, DesktopTaskbarGroup,ahk_class BaseBar
GroupAdd, DesktopTaskbarGroup,ahk_class DV2ControlHost

GroupAdd, GameWindows,ahk_class Warcraft III
GroupAdd, GameWindows,ahk_class Valve001
;=========窗口分组=========

;=========功能加载开始=========
;----------Folder Menu----------
f_Icons = %A_ScriptDir%\pic\foldermenu.ico

IfNotExist, %FloderMenu_iniFile%	;If config file doesn't exist
{
	f_ErrorMsg = %f_ErrorMsg%Config file not exist.`nDefault config is installed.`n
	FileCopy,%A_ScriptDir%\Backups\FloderMenu.Ini,%FloderMenu_iniFile%
}

f_ReadConfig()
f_SetConfig()

gui_hh = 0
gui_ww = 0
;----------Folder Menu----------

;----------计算文件MD5模式选择----------
If md5type=1
hModule_Md5 := DllCall("LoadLibrary", "str", A_ScriptDir "\MD5Lib.dll")
;----------计算文件MD5模式选择----------

;----------7plus右键菜单----------
FileCreateDir %A_Temp%\7plus
Gui +LastFound
hAHK := WinExist()
FileDelete, %A_Temp%\7plus\hwnd.txt
FileAppend, %hAHK%, %A_Temp%\7plus\hwnd.txt

;----------7plus右键菜单之重新打开关闭的窗口----------
IniRead,CloseWindowList_showmenu,%run_iniFile%,1007,showmenu
if CloseWindowList_showmenu
{
DllCall("RegisterShellHookWindow","uint",hAHK)
OnMessage(DllCall("RegisterWindowMessageW","str","SHELLHOOK"),"ShellWM")
}
;----------7plus右键菜单----------

;----------地址栏等ClassNN:edit1添加“粘贴并打开”的右键菜单----------
If PasteAndOpen
{
hMenu:=
hwndNow:=
;constants
MFS_ENABLED = 0
MFS_CHECKED = 8
MFS_DEFAULT = 0x1000
MFS_DISABLED = 2
MFS_GRAYED = 1
MFS_HILITE = 0x80
;监控右键菜单，并添加“粘贴并打开”菜单项目
;右键 粘贴并打开
HookProcAdr := RegisterCallback( "HookProcMenu", "F" )
hWinEventHook := SetWinEventHook( 0x4, 0x4,0, HookProcAdr, 0, 0, 0 )   ;0x4 EVENT_SYSTEM_MENUSTART
}
;----------地址栏等ClassNN:edit1添加“粘贴并打开”的右键菜单----------

;----------监视关机对话框的选择----------
;拦截关机
If ShutdownMonitor
{
ShutdownBlock := true
RegWrite ,REG_SZ,HKEY_CURRENT_USER,Control Panel\Desktop,AutoEndTasks,0
;关机时首先响应  To make a script the last process to terminate change "0x4FF" to "0x0FF".
;HKEY_CURRENT_USER,Control Panel\Desktop,AutoEndTasks,0
;Vista+关机提示结束进程
temp:=DllCall("User32.dll\ShutdownBlockReasonCreate","uint",hAHK,"wstr",A_ScriptFullPath " is still running")
if !temp
CF_ToolTip("ShutdownBlockReasonCreate 创建失败！错误码： " A_LastError,3000)
temp :=DllCall("kernel32.dll\SetProcessShutdownParameters", UInt, 0x4FF, UInt, 0)
if !temp
CF_ToolTip("SetProcessShutdownParameters 失败！",3000)
;监视关机
HookProcAdr2 := RegisterCallback( "HookProc", "F" )
hWinEventHook2 := SetWinEventHook( 0x1, 0x17,0, HookProcAdr2, 0, 0, 0 )
if !hWinEventHook2
CF_ToolTip("注册监视关机失败",3000)
OnMessage(0x11, "WM_QUERYENDSESSION")
}
;----------监视关机对话框的选择----------

Gosub, Combo_WinEvent

;----------整点报时功能----------
  If baoshionoff
{
	If baoshilx
    SetTimer, JA_VoiceCheckTime, 1000
	Else
    SetTimer, JA_JowCheckTime, 1000
}

If renwu
SetTimer, renwu, 30000

If renwu2
SetTimer, renwu2, 30000
;----------整点报时功能----------

;----------鼠标提示----------
If(mousetip=1)
SetTimer,aaa,2000
;----------鼠标提示----------

;每5秒检测foobar2000是否运行，显示不同的图标,检测系统音量，更改音量条
settimer,检测,2000
if !是否检测
settimer,检测,off
;----------开启鼠标自动激活功能----------
If(Auto_Raise=1)
SetTimer, hovercheck, 100

;当某些窗口存在时，鼠标悬停功能直接返回
Loop, parse, DisHover, `,
GroupAdd, ExistDisableHover, ahk_class %A_LoopField%

;当某些窗口激活时，鼠标悬停功能直接返回
Loop, parse, ActDisHover, `,
GroupAdd, ActiveDisableHover, ahk_class %A_LoopField%
;----------开启鼠标自动激活功能----------

;----------内存优化----------
AppList:="QQ.exe|chrome.exe|foobar2000.exe"
SetTimer,FreeAppMem,300000
;----------内存优化----------

;----------Pin2Desk----------
Gosub,cSigleMenu
;----------Pin2Desk----------
;=========功能加载结束=========

;=========热键设置=========
Hotkey, IfWinActive ; 容错
IniRead,  hotkeycontent, %run_iniFile%,快捷键
hotkeycontent:="[快捷键]" . "`n" . hotkeycontent
myhotkey := IniObj(hotkeycontent,OrderedArray()).快捷键
for k,v in myhotkey
{
IfInString,k,前缀_
continue
Else IfInString,k,特定窗口_
Hotkey, IfWinActive, %v%
Else IfInString,k,排除窗口_
Hotkey, IfWinNotActive, %v%
Else If (v && !InStr(v,"@"))
 hotkey, %v%,%k% ;,UseErrorLevel
}
Hotkey, IfWinActive
Hotkey, IfWinNotActive
If ErrorLevel
TrayTip, 发现错误,执行快捷键时发生错误，请检查配置快捷键相关部分, , 3

If MiniMizeOn=0
{
Hotkey, IfWinNotActive, ahk_group DesktopTaskbarGroup
Hotkey,% myhotkey.窗口缩略图, Off
Hotkey, IfWinNotActive
}

IniRead,  hotkeycontent, %run_iniFile%,Plugins
hotkeycontent:="[Plugins]" . "`n" . hotkeycontent
Pluginshotkey := IniObj(hotkeycontent,OrderedArray()).Plugins
for k,v in Pluginshotkey
If v
 hotkey, %v%,Plugins_Run ;,UseErrorLevel

;;;;;;;;;; 剪贴板  ;;;;;;;;;;;;

;复制时  
;复制1→复制2→复制3→复制1
;粘贴时
;1→3→2→1
;2→1→3→2
;3→2→1→3
if Auto_Clip
{
	first=0
	clipid=0
	monitor=0
	SetTimer, shijianCheck, 50
	st:=A_TickCount

	if Auto_Cliphistory
	{
		global DBPATH:= A_ScriptDir . "\Settings\cliphistory.db"
		global PREV_FILE := A_ScriptDir . "\Settings\tmp\prev.html" 
		global DB := new SQLiteDB
		STORE:={}

		if (!FileExist(DBPATH))
			isnewdb := 1
		else
			isnewdb := 0

		if (!DB.OpenDB(DBPATH))
			MsgBox, 16, SQLite错误, % "消息:`t" . DB.ErrorMsg . "`n代码:`t" . DB.ErrorCode

		sleep,300
		if (isnewdb == 1){
			migrateHistory()
		}
	}
}
else
hotkey,$^V,off
;;;;;;;;;; 剪贴板  ;;;;;;;;;;;;

;快捷键打开C,D,E,F盘...设置其快捷键，loop 15循环15次，到达字母Q
Loop 15
   HotKey % myhotkey.前缀_快速打开磁盘 Chr(A_Index+66), ExploreDrive

;----------Winpad----------
WindowPadInit:
; Exclusion examples:
GroupAdd, GatherExclude, ahk_class SideBar_AppBarWindow
; These two come in pairs for the Vista sidebar gadgets:
GroupAdd, GatherExclude, ahk_class SideBar_HTMLHostWindow   ; gadget content
GroupAdd, GatherExclude, ahk_class BasicWindow              ; gadget shadow/outline
GroupAdd, GatherExclude, ahk_class Warcraft III

; Win+Numpad      = Move active window
Prefix_Active := myhotkey.前缀_小键盘移动窗口
; Alt+Win+Numpad  = Move previously active window
Prefix_Other  := myhotkey.前缀_小键盘移动前一个窗口

; Note: Shift (+) should not be used, as +Numpad is hooked by the OS
;   to do left/right/up/down/etc. (reverse Numlock) -- at least on Vista.
; Numlock 亮时 Shift+Numpad8 等同于 Shift+Up
; Numlock 灯不亮时，小键盘数字能控制上下左右，滚轮

/*
;移除EasyKey
EasyKey = Insert    ; Insert is near Numpad on my keyboard...
;移除EasyKey
*/

; Note: Prefix_Other must not be a sub-string of Prefix_Active.
;       (If you want it to be, first edit the line "If (InStr(A_ThisHotkey, Prefix_Other))")

; Width and Height Factors for Win+Numpad5 (center key.)
CenterWidthFactor   = 1.0
CenterHeightFactor  = 1.0

Hotkey, IfWinActive ; in case this is included in another script...

;Win+ numpad 1-9   Alt+Win+Numpad 1-9 移动改变窗口位置大小
Loop, 9
{   ; Register hotkeys.
    Hotkey, %Prefix_Active%Numpad%A_Index%, DoMoveWindowInDirection
    Hotkey, %Prefix_Other%Numpad%A_Index%, DoMoveWindowInDirection
    ; OPTIONAL
/*
;移除EasyKey
    If EasyKey
        Hotkey, %EasyKey% & Numpad%A_Index%, DoMoveWindowInDirection
;移除EasyKey
*/
}

;Win+ numpad 0  最大化窗口
Hotkey, %Prefix_Active%Numpad0, DoMaximizeToggle
Hotkey, %Prefix_Other%Numpad0, DoMaximizeToggle
;NumpadDot "."
Hotkey, %Prefix_Active%NumpadDot, MoveWindowToNextScreen
Hotkey, %Prefix_Other%NumpadDot, MoveWindowToNextScreen
;NumpadDiv "/"   NumpadMult "*"
Hotkey, %Prefix_Active%NumpadDiv, GatherWindowsLeft
Hotkey, %Prefix_Active%NumpadMult, GatherWindowsRight

/*
;移除EasyKey
If (EasyKey) {
    Hotkey, %EasyKey% & Numpad0, DoMaximizeToggle
    Hotkey, %EasyKey% & NumpadDot, MoveWindowToNextScreen
    Hotkey, %EasyKey% & NumpadDiv, GatherWindowsLeft
    Hotkey, %EasyKey% & NumpadMult, GatherWindowsRight
    Hotkey, *%EasyKey%, SendEasyKey ; let EasyKey's original function work (on release)
}
;移除EasyKey
*/
;----------Winpad----------

;----------虚拟桌面----------
Loop, 4
{
Hotkey, % myhotkey.前缀_数字虚拟桌面切换 Chr(A_Index+48), ToggleVirtualDesktop

Hotkey, % myhotkey.前缀_功能键发送到虚拟桌面 "F" A_Index,SendActiveToDesktop
}
;----------虚拟桌面----------
;=========热键设置=========

;---------鼠标增强空格预览的热键-----------
if !Auto_mouseclick
	hotkey,~LButton,off
if !Auto_midmouse
	hotkey,$MButton,off
if !Auto_Spacepreview
	hotkey,$Space,off
;---------鼠标增强空格预览的热键-----------

if (Auto_JCTF or Auto_Update) and 每隔几小时结果为真(6)
{
;----------农历节日----------
if Auto_JCTF
		Gosub,JCTF
;----------农历节日----------

;---------启动检查更新-----------
If Auto_Update
{
	URL := "http://www.baidu.com"
	If InternetCheckConnection(URL)
	{
		WinHttp.URLGet("https://raw.githubusercontent.com/wyagd001/MyScript/master/version.txt",,, update_txtFile)
		FileGetSize, sizeq,%update_txtFile%
		If(sizeq<20)
		{
			FileRead, CurVer, %update_txtFile%
			If(CurVer!=AppVersion)
			{
				msgbox,4,升级通知,当前版本为:%AppVersion%`n最新版本为:%CurVer%`n是否前往主页下载?
				IfMsgBox Yes
					Run,https://github.com/wyagd001/MyScript
			}
		}
		FileDelete, %update_txtFile%
	}
}
;---------启动检查更新-----------
}

;----------网页控制电脑----------
; 127.0.0.1:8000  http://localhost:2525/  手机访问 电脑IP：2525
if Auto_AhkServer
{
StoredLogin:=CF_IniRead(run_iniFile, "serverConfig","StoredLogin", "admin")
StoredPass:=CF_IniRead(run_iniFile, "serverConfig","StoredPass", 1234)
LoginPass:=CF_IniRead(run_iniFile, "serverConfig","LoginPass", 0)
buttonSize:=CF_IniRead(run_iniFile, "serverConfig","buttonSize", "40px")
serverPort:=CF_IniRead(run_iniFile, "serverConfig","serverPort", "8000")
textFontSize:=CF_IniRead(run_iniFile, "serverConfig","textFontSize", "16px")
pagePadding:=CF_IniRead(run_iniFile, "serverConfig","pagePadding", "50px")
mp3file:=CF_IniRead(run_iniFile, "serverConfig","mp3file")
excelfile:=CF_IniRead(run_iniFile, "serverConfig","excelfile")
txtfile:=CF_IniRead(run_iniFile, "serverConfig","txtfile")
loop,5
{
stableitem%a_index%:=CF_IniRead(run_iniFile, "serverConfig","stableitem" . a_index)
}
mOn:=1
scheduleDelay:=0	;time before a standby/hibernate command is executed
SHT:=scheduleDelay//60000	;standby/hibernate timer abstracted in minutes

gosub indexInit
}
;----------网页控制电脑----------

;----------WinMouse----------
;----------按住 Capslock 使用鼠标改变窗口的大小和位置 ----------
;----------loop持续运行，放到loop后面的代码不会执行的----------
if Auto_Capslock
{
SetFormat, FLOAT, 0.0	;Round all floating operations
ScriptINI = %A_ScriptDir%\settings\WinMouse.ini ;Path to INI file

;Get monitor count and stats
SysGet, iMonitorCount, 80	;SM_CMONITORS
Loop %iMonitorCount%	;Loop through each monitor
	SysGet, Mon%A_Index%, MonitorWorkArea, %A_Index%

;Load settings
ReadINI()

;Prep GUI
Gui,4: +AlwaysOnTop -Caption +ToolWindow +LastFound
Gui,4: Color, %cShade%	;Set backcolor
WinSet, Transparent, %iTrans%	;Set transparency

;Establish timer
SetTimer, ProcessMouse, 500
SetTimer, ProcessMouse, OFF

Loop {
	;Check state
	If GetKeyState("Capslock", "P") {
		If Not bTimerOn {
			MouseGetPos, oldX, oldY, mW	;So that we don't draw unless the mouse moves after LWin is pressed
			bCaps := Not GetKeyState("Capslock", "T")
			iCurPoint := -1	;So that next time we turn it on, GUI will draw, even If in the same zone
			bTimerOn := True
			SetTimer, ProcessMouse, ON   	;Turn on timer
		}
		bRestore := GetKeyState("Space", "P") Or bRestore	;Check If we're restoring
        ;快捷键“Capslock+Space”恢复窗口

		;bQuit := GetKeyState("Tab", "P") Or bQuit ;Check If we're quitting
        ;快捷键“Capslock+Tab”退出程序
    }
    Else If bTimerOn {	;If Capslock is not pressed but the timer is running
		bTimerOn := False
		SetTimer, ProcessMouse, OFF	;Turn off timer
        /*
		If bQuit {
			SetCapsLockState, % bCaps ? "On" : "Off"	;%Restore original status
			Menu, Tray, Icon	;Show icon
			Sleep, 200			;Sleep a little for the icon to be seen
			ExitApp				;Leave script
        }
        */
		If bRestore { ;Check If we're restoring to previous size or moving
			RestoreWinMoved(CheckWinMovedArr(mW)) ;Restore previous pos.
			If Not bShowing	;Check If we have to restore Capslock status ourselves (If GUI isn't showing)
				SetCapsLockState, % bCaps ? "On" : "Off"	;%
		}
		If bShowing {
			SetCapsLockState, % bCaps ? "On" : "Off"	;%Restore original status
			DrawShade()	;hide GUI
			If Not bRestore
				Gosub, MoveWindow
		}
		bRestore := False
		;bQuit := False
	}
	Sleep 50
}
}
;----------WinMouse----------
;----------脚本启动自动加载结束----------
Return

aaa:
Gosub, GetUnderMouseInfo
If (_x >= A_ScreenWidth * 0.97 &&  _y>=A_ScreenHeight - 30)
{
CoordMode, ToolTip
tx :=A_ScreenWidth * 0.95
ty :=A_ScreenHeight - 80
ToolTip,滚轮改变音量，右下角,%tx%,%ty%
}

Else If(_x>=A_ScreenWidth * 0.999 and _y>=A_ScreenHeight - 120 and _y<=A_ScreenHeight - 30)
 {
 ToolTip,左键单击打开任务管理器
 }

Else If(ActiveWinTitle := MouseIsOverTitlebar())
{
	If (ActiveWinTitle and (_class = _aClass))
	{

		If (( _x >= _winX +0 ) And ( _x <= _winX + 80 ))
		{
         If(_class= "Progman" or _class= "WorkerW")
		Return
        Else
		ToolTip,滚轮改变窗口透明度`n恢复Win+Ctrl+Z
	}
    Else If(( _x > _winX + 80) And  (_x < _winX + _winW - 120))
   {
    If(_class= "Progman" Or _class= "WorkerW" or _class="Shell_TrayWnd")
		Return
        Else
		ToolTip,用滚轮使窗口缩为标题栏
    }
}
}
Else
ToolTip
Return

FreeAppMem:
StringSplit,App,AppList,|
LoopN:=1
Loop,%App0%
{
CtrApp:=App%LoopN%
LoopN++
Process,Exist,%CtrApp%
If (errorlevel<>0)
EmptyMem(errorlevel)
Else
Continue
}
EmptyMem()
Return

onClipboardChange:
	if !Auto_Clip
	return
	if !monitor
	return
	if !clipboard
	return
	if(clipboard = ClipSaved1) or (clipboard = ClipSaved2) or (clipboard = ClipSaved3)
	return
	ClipWait, 1, 1
	if (A_EventInfo=1)
	{
		clipid+=1
		if clipid>3
			clipid=1
		ClipSaved%clipid% := Clipboard

		if Auto_Cliphistory
		{
			if (writecliphistory=1) 
			{
				if clipid = 1
				{
					if (ClipSaved1 != ClipSaved3) &&  (ClipSaved1 != ClipSaved2)
						addHistoryText(Clipboard, A_Now)
				}
				else if clipid = 2
				{
					if (ClipSaved2 != ClipSaved1) &&  (ClipSaved2 != ClipSaved3)
						addHistoryText(Clipboard, A_Now)
				}
				else if clipid = 3
				{
					if (ClipSaved3 != ClipSaved2) &&  (ClipSaved3 != ClipSaved1)
						addHistoryText(Clipboard, A_Now)
				}
			}
			else
				writecliphistory=1
			CF_ToolTip("剪贴板" clipid " 复制完毕.",700)
		}
	}
	else
	{
		tempid=1
	}
return

EmptyMem(PID="AHK Rocks"){
    pid:=(pid="AHK Rocks") ? DllCall("GetCurrentProcessId") : pid
    h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
    DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
    DllCall("CloseHandle", "Int", h)
}

selectfile:
FileSelectFile,tt,,,选择文件
GuiControl,, Dir, %tt%
GuiControl,choose,dir,%tt%
GuiControl, -default,&.
GuiControl, +default,打开(&O)
Return

selectfolder:
	FileSelectFolder,tmpDir,,,选择目录
	;设置选择目录的路径为下拉列表的一个项目
	GuiControl,, Dir, %tmpDir%
	;选中下拉列表中的条目
	GuiControl,choose,dir,%tmpDir%
	;事件没有提交 dir为空 所以TargetFolder := Dir无效
	If tmpDir
	{
	TargetFolder := tmpDir
	IniWrite,%TargetFolder%, %run_iniFile%,常规, TargetFolder
	TrayTip,移动文件,目标文件夹设置为 %TargetFolder% 。
	}
	GuiControl, -default,选择(&S)
	GuiControl, +default,打开(&O)
Return

选项:
IfWinExist,ahk_class AutoHotkeyGUI,选项
WinActivate,ahk_class AutoHotkeyGUI,选项
Else
Gosub,option
Return

about:
IfWinExist,ahk_class AutoHotkeyGUI,选项
{
WinActivate,ahk_class AutoHotkeyGUI,选项
guicontrol,99: ChooseString, systabcontrol321, 关于
}
Else{
Gosub,option
WinWait,ahk_class AutoHotkeyGUI,选项
guicontrol,99: ChooseString, systabcontrol321, 关于
}
Return

Gui_Context_Menu:
winget,Gui_wid,id,a
; Dock to Screen Edge entries
Menu, Gui_Dock_Windows, Add, Left, Gui_Dock_Windows
Menu, Gui_Dock_Windows, Add, Right, Gui_Dock_Windows
Menu, Gui_Dock_Windows, Add, Top, Gui_Dock_Windows
Menu, Gui_Dock_Windows, Add, Bottom, Gui_Dock_Windows
Menu, Gui_Dock_Windows, Add
Menu, Gui_Dock_Windows, Add, Corner - Top Left, Gui_Dock_Windows
Menu, Gui_Dock_Windows, Add, Corner - Top Right, Gui_Dock_Windows
Menu, Gui_Dock_Windows, Add, Corner - Bottom Left, Gui_Dock_Windows
Menu, Gui_Dock_Windows, Add, Corner - Bottom Right, Gui_Dock_Windows
Menu, Gui_Dock_Windows, Add
Menu, Gui_Dock_Windows, Add, Un-Dock, Gui_Un_Dock_Window
  IfNotInString, Gui_Dock_Windows_List,%Gui_wid%
    Menu, Gui_Dock_Windows, Disable, Un-Dock
  Else
    {
    Menu, Gui_Dock_Windows, Disable, Left
    Menu, Gui_Dock_Windows, Disable, Right
    Menu, Gui_Dock_Windows, Disable, Top
    Menu, Gui_Dock_Windows, Disable, Bottom
    Menu, Gui_Dock_Windows, Disable, Corner - Top Left
    Menu, Gui_Dock_Windows, Disable, Corner - Top Right
    Menu, Gui_Dock_Windows, Disable, Corner - Bottom Left
    Menu, Gui_Dock_Windows, Disable, Corner - Bottom Right
    If (Edge_Dock_Position_%Gui_wid% !="") ; produces error If doesn't exist
      Menu, Gui_Dock_Windows, Check, % Edge_Dock_Position_%Gui_wid%
    }

Menu, ConfigMenu1, Add, &Dock to Edge, :Gui_Dock_Windows
Menu, ConfigMenu1, Add
Menu, ConfigMenu1, Add, 附加功能, :addf
Menu, ConfigMenu1, Add, 检查更新(&U)`t, Update
Menu, ConfigMenu1, Add, 选项(&O)`t, 选项
Menu, ConfigMenu1, Add
Menu, ConfigMenu1, Add, 重启脚本(&R)`t, 重启脚本
Menu, ConfigMenu1, Add, 退出(&X)`t, Menu_Tray_Exit
Menu, ConfigMenu1, Show
Menu, Gui_Dock_Windows,deleteall
Menu, ConfigMenu1,deleteall
Return

Open1:
ListVars
Return

Help:
Run, %Pathd%\AutoHotkeyLCN.chm
Return

spy:
Run, %Pathd%\AU3_Spy.exe
Return

重启脚本:
reload
Return

编辑脚本:
	Edit
Return

nul:
Return

;!Pause::
挂起所有热键:
Suspend, Permit
If ( !A_IsSuspended )
{Suspend, On
Menu, Tray, ToggleCheck, 挂起所有热键(&S)`tAlt+Pause
}
Else
{
Suspend, Off
Menu, Tray, ToggleCheck, 挂起所有热键(&S)`tAlt+Pause
}
Return

;Pause::
暂停脚本:
Menu, Tray, ToggleCheck, 暂停脚本(&P)`tPause
Pause,Toggle,1
Return

GuiClose:
settimer,检测,off
Gui,hide
visable=0
Return

show:
If !visable
{
Gui,Show
settimer,检测,on
visable=1
}
Else
{
Gui,hide
settimer,检测,off
visable=0
}
Return

;If ( DllCall( "IsWindowVisible", "uint", AppTitle ) )
显示主窗口:
If !visable
{
Gui, Show
visable=1
}
Else
{
IfWinNotActive,%AppTitle%
WinActivate,%AppTitle%
Else
{
Gui,hide
visable=0
}
}
Return

GuiEscape:
if Gui_Esc=隐藏
{
Gui,hide
visable=0
}
else if Gui_Esc=退出
gosub,Menu_Tray_Exit
Return

Menu_Tray_Exit:
FadeOut(AppTitle,50)
 ExitApp
Return

ExitSub:
FileDelete, %A_Temp%\7plus\hwnd.txt

UnhookWinEvent(hWinEventHook3, HookProcAdr3)

; 释放监视关机的资源
if ShutdownMonitor
{
DllCall("ShutdownBlockReasonDestroy", UInt, hAHK)
UnhookWinEvent(hWinEventHook2, HookProcAdr2)
;msgbox,0
}

if CloseWindowList_showmenu
{
DllCall("DeregisterShellHookWindow","uint",hAHK)
;msgbox,1
}

If !smartchooserbrowser
{
delahkurl()
;msgbox,2
}

;还原缩为缩略图的窗口
If miniMizeOn
{
	WinGet, id, list,ahk_class AutoHotkeyGUI

	Loop,%id%
	{
		this_id := id%A_Index%
		WinGetTitle, this_title, ahk_id %this_id%
		;FileAppend,%this_title%`n,%A_Desktop%\123.txt
		StringSplit, data, this_title,*
		Title2MiniMize:=data1
		Winshow, ahk_id %Title2MiniMize%
	}
;msgbox,3
}

; 还原pin2desk钉住的窗口
If ToggleList
{
	Loop, parse,ToggleList,`|
	{
		WinShow,ahk_id %A_LoopField%
		DllCall("SetParent", "UInt", A_LoopField, "UInt", 0)
		;WinSet, Style, +0xC00000, ahk_id %A_LoopField%
		WinSet,Region,,ahk_id %A_LoopField%
		ToggleList:=StrAr_DeletElement(ToggleList,A_LoopField,1)
}
;msgbox,4
}

;还原虚拟桌面隐藏的窗口
DetectHiddenWindows Off
Loop, %numDesktops%
   ShowHideWindows(A_Index, true)
;msgbox,5

;是否隐藏了桌面图标，是的话还原
If hidedektopicon
{
ControlGet, HWND, Hwnd,, SysListView321, ahk_class Progman
   If HWND =
      {
	  DetectHiddenWindows Off
      ControlGet, HWND, Hwnd,, SysListView321, ahk_class WorkerW
      WinShow, ahk_id %HWND%
}
;msgbox,6
}

DetectHiddenWindows On
;退出子脚本
    Loop, %scriptCount%
    {
        thisScript := scripts%A_index%0
        If scripts%A_index%1 = 1  ; 已打开
        {
            WinClose %thisScript% - AutoHotkey
            scripts%A_index%1 = 0

            StringRePlace menuName, thisScript, .ahk
        }
}
;msgbox,7

If md5type=1
{
  DllCall("FreeLibrary", "Ptr", hModule_Md5)
;msgbox,8
}

; 释放粘贴并打开的资源
If PasteAndOpen
{
WinShow,ahk_class Shell_TrayWnd
WinShow,开始 ahk_class Button
WinActivate,ahk_class Shell_TrayWnd
;msgbox,6   ;退出有时出现异常(概率非常高，直接退出，托盘图标残留)
UnhookWinEvent(hWinEventHook, HookProcAdr)
;msgbox,9
}

if prewpToken
{
Gdip_ShutDown(prewpToken)
;msgbox,10
}

SoundPlay ,%A_ScriptDir%\Sound\Windows Error.wav
sleep,300
 ExitApp
Return

;退出动画
FadeOut(WinTitle,SleepTime)
{
    ST := SleepTime
    Window := WinTitle
    Alpha = 255
    Loop 52
      {
        WinSet,Transparent,%Alpha%,%Window%
        EnvSub,Alpha,5
        If ST != 0
          {
            Sleep %ST%
          }
      }
}

;右击主程序界面的动作
RBUTTONUP()
{
  global AppTitle
  MouseGetPos,,,,c
    IfEqual,c,Edit1
    {
       Send,{RButton Up}
       Return
    }
  IfEqual,c,Static2
    {
       IfWinActive,%AppTitle%
       menu,audioplayer,show
       Return
    }
  Else
    {
       IfWinActive,%AppTitle%
       gosub Gui_Context_Menu
     }
}

cSigleMenu:
Menu,AllWinMenu,Add,

Menu,SigleMenu,Add,虚拟桌面 1,ActDesk
Menu,SigleMenu,Add,虚拟桌面 2,ActDesk
Menu,SigleMenu,Add,虚拟桌面 3,ActDesk
Menu,SigleMenu,Add,虚拟桌面 4,ActDesk
;----------------------------------------------------------------------------
Menu,SigleMenu,Add,

Menu,DeskAdd,Add,虚拟桌面 [1],DeskAdd
Menu,DeskAdd,Add,虚拟桌面 [2],DeskAdd
Menu,DeskAdd,Add,虚拟桌面 [3],DeskAdd
Menu,DeskAdd,Add,虚拟桌面 [4],DeskAdd
;----------------------------------------------------------------------------
Menu,SigleMenu,Add,加入到,:DeskAdd
Menu,SigleMenu,Add,所有窗口,:AllWinMenu
Menu,SigleMenu,Add,还原本窗口,Disa
Menu,SigleMenu,Check,虚拟桌面 1

#initial:
ActDeskNum:=1
numDesktops := 4   ; maximum number of desktops
curDesktop := 1      ; index number of current desktop

ToggleList:=""
DeskGroup_1:=""
DeskGroup_2:=""
DeskGroup_3:=""
DeskGroup_4:=""

ClassTpye:="CabinetWClass,ExploreWClass,Notepad2,Notepad,IEFrame,ACDViewer,Afx_,ShImgVw_,#32?770,"
Ctrl_CabinetWClass:="DirectUIHWND3"
Ctrl_ExploreWClass:="SysListView321"
Ctrl_Notepad2:="Scintilla1"
Ctrl_Notepad:="Edit1"
Ctrl_IEFrame:="Internet Explorer_Server1"
Ctrl_ACDViewer:="ImageViewWndClass1"
Ctrl_Afx_:="SysListView321"
Ctrl_ShImgVw_:="ShImgVw:CZoomWnd1"
Ctrl_#32770:="SysListView321"
Return

GetAllKeys:
  Loop, Parse, content, `n
  {
    StringSplit, data, A_LoopField, =
    %data1%:=data2
  }
return

_AutoInclude:
	f = %A_ScriptDir%\Script\AutoInclude.ahk
	FileRead, fs, %f%

; 批量#Include，要包含所有脚本的目录
AutoInclude_Path = %A_ScriptDir%\Script\Cando
s=
Loop, %AutoInclude_Path%\*.ahk
    s.="#Include *i %A_ScriptDir%\Script\Cando\" A_LoopFileName "`n"
AutoInclude_Path = %A_ScriptDir%\Script\Windo
Loop, %AutoInclude_Path%\*.ahk
    s.="#Include *i %A_ScriptDir%\Script\Windo\" A_LoopFileName "`n"
AutoInclude_Path = %A_ScriptDir%\Script\Hotkey
Loop, %AutoInclude_Path%\*.ahk
    s.="#Include *i %A_ScriptDir%\Script\Hotkey\" A_LoopFileName "`n"
AutoInclude_Path = %A_ScriptDir%\Script\7plus右键菜单
Loop, %AutoInclude_Path%\*.ahk
    s.="#Include *i %A_ScriptDir%\Script\7plus右键菜单\" A_LoopFileName "`n"
if RegExReplace(fs,"\s+") != RegExReplace(s,"\s+")
{
  FileDelete, %f%
  FileAppend, %s%, %f%
  msgbox,,脚本重启,自动 Include 的文件发生了变化，点击"确定"后重启脚本，应用更新。
IfMsgBox OK
{
fs:=s:=AutoInclude_Path:=f:=""
Reload
Return
}
fs:=s:=AutoInclude_Path:=f:=""
}
;---------------------------------
Return

Combo_WinEvent:
;EVENT_OBJECT_REORDER:= 0x8004, EVENT_OBJECT_FOCUS:= 0x8005, EVENT_OBJECT_SELECTION:= 0x8006
	CtrlHwnd:=hComBoBox
	VarSetCapacity(CB_info, 40 + (3 * A_PtrSize), 0)
	NumPut(40 + (3 * A_PtrSize), CB_info, 0, "UInt")
	DllCall("User32.dll\GetComboBoxInfo", "Ptr", CtrlHwnd, "Ptr", &CB_info)
	CB_EditID := NumGet(CB_info, 40 + A_PtrSize, "Ptr") ;48/44
	CB_ListID := NumGet(CB_info, 40 + (2 * A_PtrSize), "Ptr") ; 56/48
	
	CB_EditID:=Format("0x{1:x}",CB_EditID) , CB_ListID:=Format("0x{1:x}",CB_ListID) 

	GuiHwnd_:=CB_ListID
	ThreadId := DllCall("GetWindowThreadProcessId", "Int", GuiHwnd_, "UInt*", PID)	; LPDWORD
	HookProcAdr3:=RegisterCallback("WinProcCallback")
	hWinEventHook3:=SetWinEventHook(0x8006, 0x8006, 0, HookProcAdr3, PID, ThreadId, 0)
	objListIDs[CB_ListID]:=hComBoBox
return

Plugins_Run:
tmphotkey := A_ThisHotkey
IniRead,  hotkeycontent, %run_iniFile%,Plugins
hotkeycontent:="[Plugins]" . "`n" . hotkeycontent
Pluginshotkey := IniObj(hotkeycontent,OrderedArray()).Plugins
for k,v in Pluginshotkey
{
If(v=tmphotkey)
{
Run,"%A_AhkPath%" "%A_ScriptDir%\Plugins\%k%.ahk"
break
}
}
return

; 来源帮助文件中的示例
RunScript(script, WaitResult:="false")
{
	static test_ahk := A_AhkPath,
	shell := ComObjCreate("WScript.Shell")
	tempworkdir:= A_WorkingDir
	SetWorkingDir %A_ScriptDir%
	exec := shell.Exec(chr(34) test_ahk chr(34) " /ErrorStdOut *")
	exec.StdIn.Write(script)
	exec.StdIn.Close()
	SetWorkingDir %tempworkdir%
	if WaitResult
		return exec.StdOut.ReadAll()
	else 
return
}

#include %A_ScriptDir%\Script\脚本管理器.ahk
#include %A_ScriptDir%\Script\配置.ahk
#include %A_ScriptDir%\Script\FolderMenu.ahk
#include %A_ScriptDir%\Script\主窗口\OpenButton.ahk
#include %A_ScriptDir%\Script\主窗口\runhistory.ahk
#include %A_ScriptDir%\Script\主窗口\检查更新.ahk
#include %A_ScriptDir%\Script\主窗口\网址补齐.ahk
#include %A_ScriptDir%\Script\主窗口\IE收藏夹.ahk
#include %A_ScriptDir%\Script\主窗口\收藏夹.ahk
#include %A_ScriptDir%\Script\主窗口\桌面快捷方式.ahk
#include %A_ScriptDir%\Script\主窗口\图片按钮.ahk
#include %A_ScriptDir%\Script\主窗口\常用.ahk
#include %A_ScriptDir%\Script\主窗口\列表.ahk
#include %A_ScriptDir%\Script\主窗口\附加功能.ahk
#include %A_ScriptDir%\Script\主窗口\拖拽移动文件.ahk
#include %A_ScriptDir%\Script\主窗口\切换编辑下拉列表.ahk
#include %A_ScriptDir%\Script\主窗口\播放器和音量控制.ahk
#include %A_ScriptDir%\Script\主窗口\combo删除按钮.ahk
#include %A_ScriptDir%\Script\网页远程控制.ahk
#include %A_ScriptDir%\Script\USB.ahk
#include %A_ScriptDir%\Script\光驱.ahk
#include %A_ScriptDir%\Script\鼠标中键.ahk
#include %A_ScriptDir%\Script\鼠标左键.ahk
#include %A_ScriptDir%\Script\WinMouse.ahk
#include %A_ScriptDir%\Script\winpad.ahk
#include %A_ScriptDir%\Script\Explorer_DeskIcons.ahk
#include %A_ScriptDir%\Script\Explorer_7plus右键菜单.ahk
#include %A_ScriptDir%\Script\Explorer_显示隐藏文件.ahk
#include %A_ScriptDir%\Script\Explorer_重新打开关闭的窗口.ahk
#include %A_ScriptDir%\Script\鼠标自动激活窗口.ahk
#include %A_ScriptDir%\Script\时间_报时和定时任务.ahk
#include %A_ScriptDir%\Script\时间_判断农历节日.ahk
#include %A_ScriptDir%\Script\Candy.ahk
#include %A_ScriptDir%\Script\Windy.ahk
#include %A_ScriptDir%\Script\Dock To Edge.ahk
#include %A_ScriptDir%\Script\地址栏粘贴并打开.ahk
#include %A_ScriptDir%\Script\关机对话框.ahk
#include %A_ScriptDir%\Script\cliphistory.ahk
#include %A_ScriptDir%\Lib\Explorer.ahk
#include %A_ScriptDir%\Lib\Menu.ahk
#include %A_ScriptDir%\Lib\Window.ahk
#include %A_ScriptDir%\Lib\WinEventHook.ahk
#include %A_ScriptDir%\Lib\ActiveScript.ahk
#include %A_ScriptDir%\Lib\_GuiDropFiles.ahk
#include %A_ScriptDir%\Lib\Class_SQLiteDB.ahk
#include %A_ScriptDir%\Lib\Class_JSON.ahk
#include %A_ScriptDir%\Lib\Class_WinHttp.ahk
#Include *i %A_ScriptDir%\Lib\进制转换.ahk
#Include *i %A_ScriptDir%\Lib\string.ahk
#include, %A_ScriptDir%\lib\AHKhttp.ahk
#include <AHKsock>
#include *i %A_ScriptDir%\Script\AutoInclude.ahk