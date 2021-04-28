; 测试用的，win8以下的系统一些API只对调用它的进程有效
;Gui, Add, Edit, r9 vMyEdit w135, Text to appear 
;gui,show
;return

IME_Switch_QQPinYin()
{
static i:=0
if !i   ; 激活已安装的QQ拼音输入法
{
RegWrite,REG_DWORD, HKCU, Software\Microsoft\CTF\TIP\{AE51F1C0-807F-4A64-AC55-F2ADF92E2603}\LanguageProfile\0x00000804\{96EC4774-55A1-498B-827F-E95D5445B6C1}, Enable,1
i:=1
}
else   ; 从系统中删除（不显示）QQ拼音输入法
{
RegWrite,REG_DWORD, HKCU, Software\Microsoft\CTF\TIP\{AE51F1C0-807F-4A64-AC55-F2ADF92E2603}\LanguageProfile\0x00000804\{96EC4774-55A1-498B-827F-E95D5445B6C1}, Enable,0
i:=0
}
;DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, "regsvr32", str, """" A_WinDir (A_PtrSize=8 ? "QQPinyinTsf_x64.dll" : "\system32\ime\QQPinyinTSF\QQPinyinTsf.dll") """", str, A_ScriptDir, int, 1)
return
}

IME_IsENG()
{
if !IME_Get()
return true

Tmp_Val:=IME_GetConvMode(_mhwnd())
;msgbox % Tmp_Val
if Tmp_Val=0
return true
else if (Tmp_Val=1024)
return true
else 
return false
}

/*
; win10 测试 未安装其他输入法系统自带的微软拼音  08040804
q::
msgbox % IME_GetKeyboardLayoutList()
return
*/

IME_GetKeyboardLayoutList()
{
	if count := DllCall("GetKeyboardLayoutList", "UInt", 0, "Ptr", 0)
		VarSetCapacity(hklbuf, count*A_PtrSize, 0)
	DllCall("GetKeyboardLayoutList", "UInt", count, "UPtr", &hklbuf)
	Loop, %count%
	{
		HKL := NumGet(hklbuf, A_PtrSize*(A_Index-1), "UPtr")   ;  原脚本为 Ptr  改为 UPtr
		HKL := Hex2Str(HKL, 8, true)
		HKLList .= A_Index ": " HKL "`n"
	}
return HKLList
}

IME_SwitchToEng()
{
    ; 下方代码可只保留一个, win 10 下下面两行代码都是切换到英语输入, 无法切换到微软拼音
    IME_Switch(0x04090409) ; 英语(美国) 美式键盘
    IME_Switch(0x08040804) ; 中文(中国) 简体中文-美式键盘
}

IME_Switch(dwLayout)
{
    HKL := DllCall("LoadKeyboardLayout", Str, dwLayout, UInt, 1)
    ControlGetFocus, ctl, A
    SendMessage, 0x50, 0, HKL, %ctl%, A
}

/*
q::
IME_SetLayout("E01F0804")
return
*/
; dwLayout 参数为字符串 例如 "E01F0804"
IME_SetLayout(dwLayout,WinTitle="A"){
ControlGet,hwnd,HWND,,,%WinTitle%
    DllCall("SendMessage", "UInt", hwnd, "UInt", "80", "UInt", "1", "UInt", (DllCall("LoadKeyboardLayout", "Str", dwLayout, "UInt", "257")))
}

; Win 10中可以在英文409409和微软拼音804804间切换
/*
q::
msgbox % DllCall("ActivateKeyboardLayout", UInt, 1, UInt, 256)
return

w::
IME_SwitchLayout()
return
*/

IME_SwitchLayout(WinTitle="A")
{
ControlGet,hwnd,HWND,,,%WinTitle%
DllCall("SendMessage", UInt, HWND, UInt, 80, UInt, 1, UInt, DllCall("ActivateKeyboardLayout", UInt, 1, UInt, 256))
return
}

/*
q::
;IME_UnloadLayout(0xE01F0804)
;IME_UnloadLayout(0x08040804)
IME_UnloadLayout(0x04090409)
return
*/

; dwLayout 参数为数字 例如 0xE01F0804
IME_UnloadLayout(dwLayout)
{
DllCall("UnloadKeyboardLayout", "uint",dwLayout)
return
}

_mhwnd()
{
	;background test
	;MouseGetPos,x,,hwnd
	Hwnd := WinActive("A")
Return "ahk_id " . hwnd
}

	; ===============================================================================================================================
; Function......: GetKeyboardLayout
; DLL...........: User32.dll
; Library.......: User32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms646296.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms646296.aspx
; ===============================================================================================================================

/* C++ ==========================================================================================================================
HKL WINAPI GetKeyboardLayout(               // Ptr
    _In_  DWORD idThread                   // UInt
);
============================================================================================================================== 
*/
/*
q::
msgbox % IME_GetKeyboardLayout()
return
*/
;                          Ptr       UPtr
; 英语美国 美式键盘    0x4090409    0x4090409
; 中文简体 美式键盘    0x8040804    0x8040804
; 智能ABC             -0x1FE0F7FC   0xE01F0804
; 搜狗拼音            -0x1FDDF7FC   0xE0220804
IME_GetKeyboardLayout(WinTitle="A")
{
	ControlGet,hwnd,HWND,,,%WinTitle%
	ThreadID := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0 )
	; ThreadID 指定线程id，0 表示本进程
	HKL := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UPtr") ; UPtr 改为 Ptr 得到不一样的值
	HKL := dec2hex(HKL)

Return HKL
}


/*
q::
msgbox % Get_ime_file("E0220804")
return
*/

Get_ime_file(dwLayout){
    ;; ImmGetIMEFileName 函数
    ;; http://msdn.microsoft.com/ja-jp/library/cc448001.aspx
    SubKey := Get_reg_Keyboard_Layouts(dwLayout)
    RegRead, ime_file_name, HKEY_LOCAL_MACHINE, %SubKey%, Ime File
    return ime_file_name
}

/*
q::
msgbox % Get_Layout_Text("E01F0804")
return
*/

Get_Layout_Text(dwLayout){
    SubKey := Get_reg_Keyboard_Layouts(dwLayout)
    RegRead, layout_text, HKEY_LOCAL_MACHINE, %SubKey%, Layout Text
    return layout_text
}

Get_reg_Keyboard_Layouts(dwLayout){
    hKL := RegExReplace(dwLayout, "0x", "")
    return "System\CurrentControlSet\control\keyboard layouts\" . hKL ;"
}

/*
w::
tooltip % IME_GetKeyboardLayoutName()
return
*/

; win8之前只对调用调用线程或当前进程有效，
; 即只对本脚本有效 例如脚本的Gui界面的edit输入控件中切换，对其他程序无效。
; win7 测试 搜狗 E0220804 智能ABC E01F0804
IME_GetKeyboardLayoutName()
{
	VarSetCapacity(Str, 16)
	 DllCall("GetKeyboardLayoutName", "Str", Str)
Return Str
}

/*
q::
yy:=DllCall("LoadKeyboardLayout","Str","E01F0804","uint",1, "Int")
IME_ActivateKeyboardLayout(yy)
;DllCall("SystemParametersInfo", "UInt", 0x005A, "UInt", 0, "UPtr", yy, "UInt", 2)
return
*/

; 为调用线程或当前进程设置输入区域设置标识符(以前称为键盘布局句柄)。
; win8之前只对调用调用线程或当前进程有效，即只对本脚本有效（gui），对其他程序无效。
; 输入区域设置标识符指定区域设置以及键盘的物理布局。
IME_ActivateKeyboardLayout(HKL)   
{
	; 函数成功，返回值是之前的输入区域设置标识符 HKL
	T := DllCall("ActivateKeyboardLayout", "Int", HKL, "UInt", 0x100, "UInt")
tooltip % T
	If (!T)
	{
		MsgBox, Error.
	}
}

/******************************************************************************
  Name:       IME.ahk
  Language:   Japanease
  Author:     eamat.
  URL:        http://www6.atwiki.jp/eamat/

原版注释为日文，网页翻译成中文
完整脚本到作者主页或github上搜索下载
*****************************************************************************
历史
    2008.07.11 v1.0.47或更高版本中重命名函数库脚本
    2008.12.10 注释修正
    2009.07.03 添加 IME_GetConverting()  （本脚本中已删除该函数）
               修复了Last Found Window未启用等问题。
    2009.12.03
      IME 状态检查使用GUIThreadInfo版本
       （IE和秀丸8βIME状态也可以改变）
        http://blechmusik.xrea.jp/resources/keyboard_layout/DvorakJ/inc/IME.ahk
      谷歌日语输入β调整
        似乎无法取得输入模式和转换模式
        IME_GET/SET() 和 IME_GetConverting()有效

    2012.11.10 x64 & Unicode兼容
      执行环境是AHK_L U64 (保持与Basic和A32,U32版的兼容性)
      LongPtr解决方案：指针大小由A_PtrSize决定

                ;==================================
                ;  GUIThreadInfo 
                ;=================================
                ; 构造体 GUITreadInfo
            ;typedef struct tagGUITHREADINFO {(x86) (x64)
                ;	DWORD   cbSize;               0     0
                ;	DWORD   flags;                4     4   ※
                ;	HWND	hwndActive;             8     8
                ;	HWND	hwndFocus;             12    16  ※
                ;	HWND	hwndCapture;           16    24
                ;	HWND	hwndMenuOwner;         20    32
                ;	HWND	hwndMoveSize;          24    40
                ;	HWND	hwndCaret;             28    48
                ;	RECT	rcCaret;               32    56
                ;} GUITHREADINFO, *PGUITHREADINFO;

      修正了WinTitle参数实际上毫无意义的问题
        仅当目标是活动窗口时才使用GetGUIThreadInfo
        否则使用Control句柄
        我把它放回去，以便我可以获得后台IME信息
        (除了浏览器之外，通过将获取句柄从Window更改为Control来实现
        该应用程序现在在后台正确获取值
        ※即使在浏览器系统中，如果只使用活动窗口也没有问题，也许)
*****************************************************************************
*/
;---------------------------------------------------------------------------
;  通用函数 (大多数IME都能使用)


;win7 32
;智能ABC,微软拼音  1
;中文简体- 美式键盘  0.
/*
w::
tooltip % IME_Get()
return
*/

;-----------------------------------------------------------
; IME状态的获取
;  WinTitle="A"    対象Window
;  返回值          1:ON / 0:OFF
;-----------------------------------------------------------
IME_GET(WinTitle="A")  {
    hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
    return DllCall("SendMessage"
          , Ptr, DllCall("imm32\ImmGetDefaultIMEWnd", Ptr,hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          , UPtr, 0x0005  ;wParam  : IMC_GETOPENSTATUS
          ,  Ptr, 0)      ;lParam  : 0
}

;-----------------------------------------------------------
; IME状态的设置
;   SetSts          1:ON / 0:OFF
;   WinTitle="A"    対象Window
;   返回值          0:成功 / 0以外:失败
;-----------------------------------------------------------
IME_SET(SetSts, WinTitle="A")    {
    hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
    return DllCall("SendMessage"
          , Ptr, DllCall("imm32\ImmGetDefaultIMEWnd", Ptr, hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          , UPtr, 0x006   ;wParam  : IMC_SETOPENSTATUS
          ,  Ptr, SetSts) ;lParam  : 0 or 1
}

;===========================================================================
;    0000xxxx    假名输入
;    0001xxxx    罗马字输入方式
;    xxxx0xxx    半角
;    xxxx1xxx    全角
;    xxxxx000    英数
;    xxxxx001    平假名
;    xxxxx011    片假名

; IME输入模式(所有IME共有)
;   DEC  HEX    BIN
;     0 (0x00  0000 0000)  假名   半英数
;     3 (0x03  0000 0011)         半假名
;     8 (0x08  0000 1000)         全英数
;     9 (0x09  0000 1001)         全字母数字
;    11 (0x0B  0000 1011)         全片假名
;    16 (0x10  0001 0000)   罗马字半英数
;    19 (0x13  0001 0011)         半假名
;    24 (0x18  0001 1000)         全英数
;    25 (0x19  0001 1001)         平假名
;    27 (0x1B  0001 1011)         全片假名

;  ※ 区域和语言选项 - [详细信息] - 高级设置
;     - 将高级文字服务支持应用于所有程序
;    当打开时似乎无法获取该值
;    (谷歌日语输入β必须在此打开，所以无法获得值)

;-------------------------------------------------------
; 获取IME输入模式
;   WinTitle="A"    対象Window
;   返回值          输入模式
;--------------------------------------------------------

; 测试时 win10 x64 自带输入法 中文返回 1, 英文返回 0.
; win7 x32
; 中文简体 美式键盘  返回 0。
; 
;               QQ拼音输入法中文输入模式   QQ拼音英文输入模式     搜狗输入法中文      搜狗输入法英文
; 半角+中文标点        1025                                        268436481(1025)
; 半角+英文标点           1　                    1024              268435457(1)        268435456(0)
; 全角+中文标点        1033                                        268436489(1033)
; 全角+英文标点           9                      1032              268435465(9)        268435464(8)

;                智能ABC中文输入标准模式    智能ABC中文输入双打模式    智能ABC英文标准   智能ABC英文双打
; 半角+中文标点        1025                   -2147482623(1025)          1024               -2147482624
; 半角+英文标点           1                   -2147483647(1)                0               -2147483648
; 全角+中文标点        1033                   -2147482615(1033)          1032               -2147482616
; 全角+英文标点           9                   -2147483639(9)                8               -2147483640


;win7 32
;智能ABC,微软拼音  1
;中文简体- 美式键盘  1

/*
q::
tooltip % IME_GetConvMode()
return
*/

IME_GetConvMode(WinTitle="A")   {
    hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
    return DllCall("SendMessage"
          , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
          , "UInt", 0x0283  ;Message : WM_IME_CONTROL
          ,  "Int", 0x001   ;wParam  : IMC_GETCONVERSIONMODE
          ,  "Int", 0) & 0xffff     ;lParam  : 0 ， & 0xffff 表示只取低16位
}

/*
; 测试时 搜狗的全半角切换快捷键关闭时,不能切换到搜狗的全角
w::
tooltip % IME_SetConvMode(0)
return
*/

;-------------------------------------------------------
; IME输入模式设置
;   ConvMode        输入模式
;   WinTitle="A"    対象Window
;   返回值          0:成功 / 0以外:失败
;--------------------------------------------------------
IME_SetConvMode(ConvMode, WinTitle="A")   {
    hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
    return DllCall("SendMessage"
          , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
          , "UInt", 0x0283      ;Message : WM_IME_CONTROL
          , "UPtr", 0x002       ;wParam  : IMC_SETCONVERSIONMODE
          ,  "Ptr", ConvMode)   ;lParam  : CONVERSIONMODE
}

/*
q::
tooltip % IME_GetSentenceMode()
return
*/

;===========================================================================
; IME 转换模式(ATOK由ver.16测试，可能会略有不同，具体取决于版本)

;   MS-IME  0:无转换 / 1:人名/地名                    / 8:通用    /16:口语
;   ATOK系  0:固定   / 1:复合词              / 4:自动 / 8:联文
;   WXG              / 1:复合词  / 2:无变换  / 4:自动 / 8:联文
;   SKK系            / 1:正常(不存在其他模式?)
;   Googleβ                                          / 8:正常
;------------------------------------------------------------------
; IME 转换模式获取
;   WinTitle="A"    対象Window
;   返回值 MS-IME  0:无转换 1:人名/地名               8:一般    16:口语
;          ATOK系  0:固定   1:复合词           4:自动 8:联文
;          WXG4             1:复合词  2:无转换 4:自动 8:联文
;------------------------------------------------------------------
; 此消息由应用程序发送到输入法编辑器(IME)窗口，以获得当前句子模式。
; 返回IME语句模式值的组合。
; 测试时，WIN7 下切换到 搜狗拼音/智能ABC/QQ拼音 时返回值都为0，英文键盘返回值为8
IME_GetSentenceMode(WinTitle="A")   {
    hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
    return DllCall("SendMessage"
          , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
          , "UInt", 0x0283  ;Message : WM_IME_CONTROL
          , "UPtr", 0x003   ;wParam  : IMC_GETSENTENCEMODE
          ,  "Ptr", 0)      ;lParam  : 0
}

;----------------------------------------------------------------
; IME 转换模式设置
;   SentenceMode
;       MS-IME  0:無変換 1:人名/地名               8:一般    16:話し言葉
;       ATOK系  0:固定   1:複合語           4:自動 8:連文節
;       WXG              1:複合語  2:無変換 4:自動 8:連文節
;   WinTitle="A"    対象Window
;   返回值          0:成功 / 0以外:失败
;-----------------------------------------------------------------
IME_SetSentenceMode(SentenceMode,WinTitle="A")  {
    hwnd :=GetGUIThreadInfo_hwndActive(WinTitle)
    return DllCall("SendMessage"
          , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
          , "UInt", 0x0283          ;Message : WM_IME_CONTROL
          , "UPtr", 0x004           ;wParam  : IMC_SETSENTENCEMODE
          ,  "Ptr", SentenceMode)   ;lParam  : SentenceMode
}

GetGUIThreadInfo_hwndActive(WinTitle="A")
{
	ControlGet,hwnd,HWND,,,%WinTitle%
	if	(WinActive(WinTitle))	{
	  ptrSize := !A_PtrSize ? 4 : A_PtrSize
	  VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
	  NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
	return  hwnd := DllCall("GetGUIThreadInfo", "Uint", 0, "Ptr", &stGTI)
	             ? NumGet(stGTI, 8+PtrSize, "Ptr") : hwnd
  }
  else
  return  hwnd
}

#include *i %A_ScriptDir%\Lib\进制转换.ahk
#include *i 进制转换.ahk