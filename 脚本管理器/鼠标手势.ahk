; 来源网址: https://www.autohotkey.com/boards/viewtopic.php?f=28&t=82466
;------------------------------------
;  简单可视化鼠标手势 v1.5  By FeiYue
;------------------------------------

#NoEnv
#NoTrayIcon
#SingleInstance, force
; 输入级别设置为 2，不响应下面的自身发送的右键(SendLevel 1)。能影响其他脚本中 SendLevel 为 0 的热键(右键)。
#InputLevel 2
MG_settingFile := A_ScriptDir  "\鼠标手势.ini"
global h_id
鼠标手势设置对象 := Ini2Obj(MG_settingFile)

File_AutoInclude :=  A_ScriptDir  . "\AutoInclude.txt"
FileRead, FileR_TFC, % file_AutoInclude
Tmp_Str := ""
Loop, %A_ScriptDir%\鼠标手势动作\*.ahk
	Tmp_Str .= "#Include *i %A_ScriptDir%\鼠标手势动作\" A_LoopFileName "`n"
if RegExReplace(FileR_TFC, "\s+") != RegExReplace(Tmp_Str, "\s+")
{
	for k in 鼠标手势设置对象
	{
		if (鼠标手势设置对象[k].动作_模式 = "标签")
		{
			if IsLabel(鼠标手势设置对象[k].动作_命令)
				Continue
			else
				IniDelete, % MG_settingFile, % k
		}
		if (鼠标手势设置对象[k].动作_模式 = "函数")
		{
			MG_AC:=StrSplit(鼠标手势设置对象[k].动作_命令,"|")
			if IsFunc(MG_AC[1])
				Continue
			else
				IniDelete, % MG_settingFile, % k
		}
	}
	Loop, %A_ScriptDir%\鼠标手势动作\*.ahk
	{
		if Instr(FileR_TFC, A_LoopFileName)
			Continue
		else
			run %A_AhkPath% "%A_LoopFileFullPath%"
	}

	FileDelete, %File_AutoInclude%
	FileAppend, %Tmp_Str%, %File_AutoInclude%, UTF-8
	msgbox,,脚本重启,自动 Include 的文件发生了变化，点击"确定"后重启脚本，应用更新。
	IfMsgBox OK
		Reload
}
FileR_TFC := Tmp_Str := File_AutoInclude := ""

Menu, Tray, Icon, shell32.dll, 15
SysGet, MWA, MonitorWorkArea
WMAwidth := MWARight - MWALeft
WMAHeight := MWABottom - MWATop

start_01() {
  static init:=start_01()
  GroupAdd, MyBrowser, ahk_class IEFrame
  GroupAdd, MyBrowser, ahk_class 360se5_Frame
  GroupAdd, MyBrowser, ahk_class 360se6_Frame
  ;GroupAdd, MyBrowser, ahk_class Chrome_WidgetWin_1
  GroupAdd, MyBrowser, ahk_class ShockwaveFlashFullScreen
  GroupAdd, MyBrowser, ahk_class QQBrowser_WidgetWin_1
  GroupAdd, MyBrowser, ahk_class MozillaWindowClass
}

SetWinDelay -1
SetBatchLines, -1
CoordMode, Mouse
CoordMode, ToolTip
生成画板()
return

#If !WinActive("ahk_group MyBrowser")
RButton::
显示画板(), 轨迹:=方向:=上次方向:=A_Action:=LastAction:=SecondAction:=FirstAction:=tipC:=上次轨迹:="", arr:=MGG:=EWC:=[]
MouseGetPos, x1, y1, h_id
WinGetClass, h_class, ahk_id %h_id%
While GetKeyState("RButton", "P")
{
	Sleep, 10
	MouseGetPos, x2, y2
	Loop, % (i:=arr.MaxIndex())>10 ? 10 : i
	if ((dx:=x2-arr[i].3)*0+(dy:=y2-arr[i--].4)*0+Abs(dx)>5 or Abs(dy)>5)
	{
		r:=(dx=0) ? 90 : Round(ATan(Abs(dy/dx))/(ATan(1)/45), 1)
		r:=(dx>=0) ? (dy<=0 ? r:360-r) : (dy<=0 ? 180-r:180+r)
		方向:=(r>=360-30 || r<=30) ? "右"
			: (r>=90-30 && r<=90+30) ? "上"
			: (r>=180-30 && r<=180+30) ? "左"
			: (r>=270-30 && r<=270+30) ? "下" : 方向
		Break
	}
	if (方向!=上次方向)
		轨迹.=方向, 上次方向:=方向
	if (x1!=x2 or y1!=y2)
	{
		arr.Push([x1,y1,x2,y2]), x1:=x2, y1:=y2
		if 轨迹
		{
			if (轨迹!=上次轨迹)
			{
				LastAction:=SecondAction:=FirstAction:=tipC:="", MGG:=EWC:=[]
				for k in 鼠标手势设置对象
				{
					;msgbox % 鼠标手势设置对象[k].动作_轨迹
					MGG:=StrSplit(鼠标手势设置对象[k].动作_轨迹,";")
					if (MGG[1]=轨迹) or  (MGG[2]=轨迹) or  (MGG[3]=轨迹)
					{
						上次轨迹:=轨迹
						;fileappend, % "1. |" 轨迹 "| - MCG1: " MGG[1] " -  MCG2: " MGG[2] " -  MCG3: " MGG[3] "`r`n" , %A_Desktop%\log.txt
						if (鼠标手势设置对象[k].动作_条件模式="通用")
						{
							LastAction := k
							if !SecondAction
								tipC := 鼠标手势设置对象[k].动作_提示 "[通用]"
							Continue
						}
						EWC:=StrSplit(鼠标手势设置对象[k].动作_生效条件,";")
						if (鼠标手势设置对象[k].动作_条件模式="非特定窗口")
						{
							if (h_class!=EWC[1]) And  (h_class!=EWC[2]) And (h_class!=EWC[3]) And  (h_class!=EWC[4]) and  (h_class!=EWC[5])
							{
								SecondAction := k
								tipC := 鼠标手势设置对象[k].动作_提示 "[非特定]"
								Continue
							}
						}
						else ;If (鼠标手势设置对象[k].动作_条件模式="特定窗口")
						{
							if (h_class=EWC[1]) or  (h_class=EWC[2]) or  (h_class=EWC[3]) or  (h_class=EWC[4]) or  (h_class=EWC[5])
							{
								FirstAction := k
								tipC := 鼠标手势设置对象[k].动作_提示 "[特定]"
								break
							}
						}
					}
					;fileappend, % "2. " 轨迹 " - k: " k " - " LastAction " - " SecondAction " - " FirstAction "`r`n" , %A_Desktop%\log.txt
				}
			}
			ToolTip, % 轨迹 " > " (tipC ? tipC : "没有设置动作")
		}
	}
	color:=A_MSec<500 ? 0xFF9050 : 0x5090FF
	For k,v in arr
		划线(v.1, v.2, v.3, v.4, color)
	更新()
}
ToolTip
清空(), 更新(), 隐藏画板()
if (轨迹="")
{
	SendLevel 1
	Click, R
	return
}

if StartMGHZ
{
	Gui,2: Default
	GuiControl, , MGA_GJ, % 轨迹
	StartMGHZ:=0
	GuiControl,, StartMGHZ, 开始绘制
	return
}

A_Action := FirstAction ? FirstAction : (SecondAction ? SecondAction : (LastAction ? LastAction : ""))
if A_Action
{
	if (鼠标手势设置对象[A_Action].动作_模式 = "标签")
	{
		if IsLabel(鼠标手势设置对象[A_Action].动作_命令)
		{
			;ToolTip, % 轨迹 " > " (鼠标手势设置对象[A_Action].动作_提示) " - "  h_class " - " 鼠标手势设置对象[A_Action].动作_条件模式 " - 1"
			gosub % 鼠标手势设置对象[A_Action].动作_命令
			;msgbox % 鼠标手势设置对象[A_Action].动作_命令
		}
	}
	if (鼠标手势设置对象[A_Action].动作_模式 = "函数")
	{
		MG_AC:=StrSplit(鼠标手势设置对象[A_Action].动作_命令,"|")
		;msgbox % MG_AC[1] " - " MG_AC[2]
		if IsFunc(MG_AC[1])
		{
			;ToolTip, % 轨迹 " > " (鼠标手势设置对象[A_Action].动作_提示) " - "  h_class " - " 鼠标手势设置对象[A_Action].动作_条件模式 " - 1"
			if (MG_AC.MaxIndex() >= 4)
				msgbox 传入参数过多
			else if (MG_AC.MaxIndex() =3)
				MG_AC[1](MG_AC[2], MG_AC[3])
			else if (MG_AC.MaxIndex() = 2)
				MG_AC[1](MG_AC[2])
			else   ;if MG_AC.MaxIndex=1
				MG_AC[1]()
			;msgbox % 鼠标手势设置对象[k].动作_命令
		}
	}
}

;if IsLabel(轨迹)
;  Goto, %轨迹%
;else
;  Tooltip, % 轨迹 " > 没有设置动作", 1
return
#If


;========== 下面是函数 ==========


生成画板()
{
  global my_gdi
  Gui, My_DrawingBoard: New
  Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow
    +E0x80000 +OwnDialogs +Hwndmy_id +E0x20
  ; 下面两行结合Bitblt更新与UpdateLayeredWindow更新互斥
  ; Gui, Color, 0x000000
  ; WinSet, TransColor, 0x000000
  w:=A_ScreenWidth, h:=A_ScreenHeight
  Gui, Show, Hide x0 y0 w%w% h%h%, 画板
  my_gdi := new GDI(my_id, w, h), 清空()
  return
}

显示画板()
{
  Gui, My_DrawingBoard: Show, NA
}

隐藏画板()
{
  Gui, My_DrawingBoard: Hide
}

划线(x,y,x2,y2,color=0xFF0000)
{
  global my_gdi
  my_gdi.DrawLine(x, y, x2, y2, Color, 4)
}

更新(color=0x000000)
{
  global my_gdi
  ; my_gdi.Bitblt()
  my_gdi.UpdateLayeredWindow(0, 0, 0, 0, color)
}

清空(color=0x000000)
{
  global my_gdi
  my_gdi.FillRectangle(0, 0, my_gdi.CliWidth, my_gdi.CliHeight, color)
}

class GDI ; thanks dwitter, RUNIE, FeiYue
{
  __New(hWnd, CliWidth=0, CliHeight=0)
  {
    if !(CliWidth && CliHeight)
    {
      VarSetCapacity(Rect, 16, 0)
      DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &Rect)
      CliWidth := NumGet(Rect, 8, "Int")
      CliHeight := NumGet(Rect, 12, "Int")
    }
    this.hWnd := hWnd
    this.CliWidth := CliWidth
    this.CliHeight := CliHeight
    this.hDC := DllCall("GetDC", "UPtr", this.hWnd, "UPtr")
    this.hMemDC := DllCall("CreateCompatibleDC", "UPtr", this.hDC, "UPtr")
    this.hBitmap := DllCall("CreateCompatibleBitmap", "UPtr", this.hDC, "Int", CliWidth, "Int", CliHeight, "UPtr")
    this.hOriginalBitmap := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", this.hBitmap)
    DllCall("ReleaseDC", "UPtr", this.hWnd, "UPtr", this.hDC)
  }

  __Delete() {
    DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", this.hOriginalBitmap)
    DllCall("DeleteObject", "UPtr", this.hBitmap)
    DllCall("DeleteObject", "UPtr", this.hMemDC)
  }

  Resize(w, h)
  {
    this.CliWidth := w
    this.CliHeight := h
    this.hDC := DllCall("GetDC", "UPtr", this.hWnd, "UPtr")
    this.hBitmap := DllCall("CreateCompatibleBitmap", "UPtr", this.hDC, "Int", w, "Int", h, "UPtr")
    hPrevBitmap := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", this.hBitmap)
    DllCall("DeleteObject", "UPtr", hPrevBitmap)
    DllCall("ReleaseDC", "UPtr", this.hWnd, "UPtr", this.hDC)
  }

  BitBlt(x=0, y=0, w=0, h=0)
  {
    w := w ? w : this.CliWidth
    h := h ? h : this.CliHeight
    this.hDC := DllCall("GetDC", "UPtr", this.hWnd, "UPtr")
    DllCall("BitBlt", "UPtr", this.hDC, "Int", x, "Int", y
    , "Int", w, "Int", h, "UPtr", this.hMemDC, "Int", 0, "Int", 0, "UInt", 0xCC0020) ;SRCCOPY
    DllCall("ReleaseDC", "UPtr", this.hWnd, "UPtr", this.hDC)
  }

  UpdateLayeredWindow(x=0, y=0, w=0, h=0, color=0, Alpha=255)
  {
    w := w ? w : this.CliWidth
    h := h ? h : this.CliHeight
    DllCall("UpdateLayeredWindow", "UPtr", this.hWnd, "UPtr", 0
    , "Int64*", x|y<<32, "Int64*", w|h<<32
    , "UPtr", this.hMemDC, "Int64*", 0, "UInt", color
    , "UInt*", Alpha<<16|1<<24, "UInt", 1)
  }

  DrawLine(x, y, x2, y2, Color, Width=1)
  {
    Pen := new GDI.Pen(Color, Width)
    DllCall("MoveToEx", "UPtr", this.hMemDC, "Int", this.TranslateX(x), "Int", this.TranslateY(y), "UPtr", 0)
    hOriginalPen := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", Pen.Handle, "UPtr")
    DllCall("LineTo", "UPtr", this.hMemDC, "Int", this.TranslateX(x2), "Int", this.TranslateY(y2))
    DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", hOriginalPen, "UPtr")
  }

  SetPixel(x, y, Color)
  {
    x := this.TranslateX(x)
    y := this.TranslateY(y, this.Invert) ; Move up 1 px if inverted (drawing "up" instead of down)
    DllCall("SetPixelV", "UPtr", this.hMemDC, "Int", x, "Int", y, "UInt", Color)
  }

  FillRectangle(x, y, w, h, Color, BorderColor=-1)
  {
    if (w == 1 && h == 1)
      return this.SetPixel(x, y, Color)

    Pen := new this.Pen(BorderColor < 0 ? Color : BorderColor)
    Brush := new this.Brush(Color)

    ; Replace the original pen and brush with our own
    hOriginalPen := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", Pen.Handle, "UPtr")
    hOriginalBrush := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", Brush.Handle, "UPtr")

    x1 := this.TranslateX(x)
    y1 := this.TranslateY(y)
    x2 := this.TranslateX(x+w)
    y2 := this.TranslateY(y+h)

    DllCall("Rectangle", "UPtr", this.hMemDC
    , "Int", x1, "Int", y1
    , "Int", x2, "Int", y2)

    ; Reselect the original pen and brush
    DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", hOriginalPen, "UPtr")
    DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", hOriginalBrush, "UPtr")
  }

  FillEllipse(x, y, w, h, Color, BorderColor=-1)
  {
    Pen := new this.Pen(BorderColor < 0 ? Color : BorderColor)
    Brush := new this.Brush(Color)

    ; Replace the original pen and brush with our own
    hOriginalPen := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", Pen.Handle, "UPtr")
    hOriginalBrush := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", Brush.Handle, "UPtr")

    x1 := this.TranslateX(x)
    y1 := this.TranslateY(y)
    x2 := this.TranslateX(x+w)
    y2 := this.TranslateY(y+h)

    DllCall("Ellipse", "UPtr", this.hMemDC
    , "Int", x1, "Int", y1
    , "Int", x2, "Int", y2)

    ; Reselect the original pen and brush
    DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", hOriginalPen, "UPtr")
    DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", hOriginalBrush, "UPtr")
  }

  TranslateX(X)
  {
    return Floor(X)
  }

  TranslateY(Y, Offset=0)
  {
    if this.Invert
      return this.CliHeight - Floor(Y) - Offset
    return Floor(Y)
  }

  class Pen
  {
    __New(Color, Width=1, Style=0)
    {
      this.Handle := DllCall("CreatePen", "Int", Style, "Int", Width, "UInt", Color, "UPtr")
    }

    __Delete()
    {
      DllCall("DeleteObject", "UPtr", this.Handle)
    }
  }

  class Brush
  {
    __New(Color)
    {
      this.Handle := DllCall("CreateSolidBrush", "UInt", Color, "UPtr")
    }

    __Delete()
    {
      DllCall("DeleteObject", "UPtr", this.Handle)
    }
  }
}

; https://www.autoahk.com/archives/24332
ini2obj(file){
iniobj := {}
FileRead, filecontent, %file% ;加载文件到变量
StringReplace, filecontent, filecontent, `r, , All
StringSplit, line, filecontent, `n, , ;用函数分割变量为伪数组
Loop ;循环
{
if A_Index > %line0%
	Break
content = % line%A_Index% ;赋值当前行
FSection := RegExMatch(content, "\[.*\]") ;正则表达式匹配section
if FSection = 1 ;如果找到
	{
	TSection := RegExReplace(content, "\[(.*)\]", "$1") ;正则替换并赋值临时section $为向后引用
	iniobj[TSection] := {}
	}
Else
	{
	FKey := RegExMatch(content, "^.*=.*") ;正则表达式匹配key
	if FKey = 1
		{
		TKey := RegExReplace(content, "^(.*)=.*", "$1") ;正则替换并赋值临时key
		StringReplace, TKey, TKey, ., _, All
		TValue := RegExReplace(content, "^.*=(.*)", "$1") ;正则替换并赋值临时value
		iniobj[TSection][TKey] := TValue
		}
	}
}
Return iniobj
}

obj2ini(obj,file,sec:=""){
if (!isobject(obj) or !file)
	Return 0
for k,v in obj
{
	if !sec or (k=sec)
{
	for key,value in v
	{
		IniWrite, %value%, %file%, %k%, %key%
	}
}

}
Return 1
}
 
show_obj(obj,menu_name:=""){
if menu_name =
    {
    main = 1
    Random, rand, 100000000, 999999999
    menu_name = %A_Now%%rand%
    }
Menu, % menu_name, add,
Menu, % menu_name, DeleteAll
for k,v in obj
{
if (IsObject(v))
	{
    Random, rand, 100000000, 999999999
	submenu_name = %A_Now%%rand%
    Menu, % submenu_name, add,
    Menu, % submenu_name, DeleteAll
	Menu, % menu_name, add, % k ? "【" k "】[obj]" : "", :%submenu_name%
    show_obj(v,submenu_name)
	}
Else
	{
	Menu, % menu_name, add, % k ? "【" k "】" v: "", MenuHandler
	}
}
if main = 1
    menu,% menu_name, show
}

#include %A_ScriptDir%\鼠标手势动作\Lib\MG_WriteIni.ahk
#include *i %A_ScriptDir%\AutoInclude.txt