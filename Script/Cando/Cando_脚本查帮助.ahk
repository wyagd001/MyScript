/*
说明：如果是有独立的页面，则直接指向独立页面
否则，就是搜索
*/
Cando_脚本文字_查帮助:

;自定义部分
	Ahkl帮助路径=D:\Program Files\AutoHotkey\AutoHotkeyLCN.chm
	Ahk帮助标题=AutoHotkey 中文帮助
	Ahk关键字表=Block;BlockInput;Break;Catch;Click;ClipWait;ComObjActive;ComObjArray;ComObjConnect;ComObjCreate;ComObjError;ComObjFlags;ComObjGet;ComObjQuery;ComObjType;ComObjValue;Continue;Control;ControlClick;ControlFocus;ControlGet;ControlGetFocus;ControlGetPos;ControlGetText;ControlMove;ControlSend;ControlSetText;CoordMode;Critical;DetectHiddenText;DetectHiddenWindows;DllCall;Drive;DriveGet;DriveSpaceFree;Edit;Else;EnvAdd;EnvDiv;EnvGet;EnvMult;EnvSet;EnvSub;EnvUpdate;Exit;ExitApp;FileAppend;FileCopy;FileCopyDir;FileCreateDir;FileCreateShortcut;FileDelete;FileEncoding;FileGetAttrib;FileGetShortcut;FileGetSize;FileGetTime;FileGetVersion;FileInstall;FileMove;FileMoveDir;FileOpen;FileRead;FileReadLine;FileRecycle;FileRecycleEmpty;FileRemoveDir;FileSelectFile;FileSelectFolder;FileSetAttrib;FileSetTime;For;FormatTime;GetKeyState;Gosub;Goto;GroupActivate;GroupAdd;GroupClose;GroupDeactivate;Gui;GuiControl;GuiControlGet;GuiControls;Hotkey;IfBetween;IfEqual;IfExist;IfExpression;IfIn;IfInString;IfIs;IfMsgBox;IfWinActive;IfWinExist;ImageSearch;index;IniDelete;IniRead;IniWrite;Input;InputBox;KeyHistory;KeyWait;ListHotkeys;ListLines;ListVars;ListView;Loop;LoopFile;LoopParse;LoopReadFile;LoopReg;Menu;MouseClick;MouseClickDrag;MouseGetPos;MouseMove;MsgBox;ObjAddRef;OnExit;OnMessage;OutputDebug;Pause;PixelGetColor;PixelSearch;PostMessage;Process;Progress;Random;RegDelete;RegExMatch;RegExReplace;RegisterCallback;RegRead;RegWrite;Reload;Return;Run;RunAs;Send;SendLevel;SendMode;SetBatchLines;SetControlDelay;SetDefaultMouseSpeed;SetEnv;SetExpression;SetFormat;SetKeyDelay;SetMouseDelay;SetNumScrollCapsLockState;SetRegView;SetStoreCapslockMode;SetTimer;SetTitleMatchMode;SetWinDelay;SetWorkingDir;Shutdown;Sleep;Sort;SoundBeep;SoundGet;SoundGetWaveVolume;SoundPlay;SoundSet;SoundSetWaveVolume;SplashTextOn;SplitPath;StatusBarGetText;StatusBarWait;StringCaseSense;StringGetPos;StringLeft;StringLen;StringLower;StringMid;StringReplace;StringSplit;StringTrimLeft;StrPutGet;Suspend;SysGet;Thread;Throw;ToolTip;Transform;TrayTip;TreeView;Trim;Try;Until;URLDownloadToFile;VarSetCapacity;While;WinActivate;WinActivateBottom;WinClose;WinGet;WinGetActiveStats;WinGetActiveTitle;WinGetClass;WinGetPos;WinGetText;WinGetTitle;WinHide;WinKill;WinMaximize;WinMenuSelectItem;WinMinimize;WinMinimizeAll;WinMove;WinRestore;WinSet;WinSetTitle;WinShow;WinWait;WinWaitActive;WinWaitClose;#AllowSameLineComments;#ClipboardTimeout;#CommentFlag;#ErrorStdOut;#EscapeChar;#HotkeyInterval;#HotkeyModifierTimeout;#Hotstring;#If;#IfTimeout;#IfWinActive;#Include;#InputLevel;#InstallKeybdHook;#InstallMouseHook;#KeyHistory;#MaxHotkeysPerInterval;#MaxMem;#MaxThreads;#MaxThreadsBuffer;#MaxThreadsPerHotkey;#MenuMaskKey;#NoEnv;#NoTrayIcon;#Persistent;#SingleInstance;#UseHook;#Warn;#WinActivateForce
	Ahk被查关键字=i)(^|;)%CandySel%($|;)

;是否已经运行
	IfWinNotExist,%Ahk帮助标题%
	{
		Run, %Ahkl帮助路径%
		WinWait,%Ahk帮助标题%,,4
	}
	WinActivate,%Ahk帮助标题%

;有doc可打开
	if RegExMatch(Ahk关键字表,Ahk被查关键字)
	{
		ProperClick("SysTabControl321")
		SendMessage 0x130C,0,, SysTabControl321,%Ahk帮助标题%
		ProperClick("SysTabControl321")
		Sleep,100
		StringReplace,直接打开,CandySel,#,_
		Ahk跳转的地址=/docs/commands/%直接打开%.htm
		Send !gu
		Loop 3
			IfWinNotActive Ahk_Class #32770  ; Is it still searching?
				Sleep 3000
		IfWinActive Ahk_Class #32770  ; Error dialog
		{
			ControlSetText,edit1,%Ahk跳转的地址%
			sleep,10
			send,{enter}
		}
	}
;没有则搜索
	Else
	{
		SendMessage 0x130C, 2,, SysTabControl321,%Ahk帮助标题%
		ControlSetText,edit1,%CandySel%,%Ahk帮助标题%
		ProperClick("SysTabControl321")
		Sleep,100
		SendMessage 0x130B,,, SysTabControl321  ; 0x130B = TCM_GETCURSEL. Which tabpage Is Selected? Answer Is ErrorLevel
		ProperClick("Button2")  ; Start searching
		Sleep 100  ; Waiting to finish searching
		Loop 3
			IfWinActive Ahk_Class #32770  ; Is it still searching?
				Sleep 100
		IfWinActive Ahk_Class #32770  ; Error dialog
			WinClose  ; Close dialog, it Is an Error
		Else
			ProperClick("Button3")  ; Show First page In the List
	}
	Return
	
Cando_查新版帮助:
	Ahkl新版帮助路径=D:\Program Files\AutoHotkey\AutoHotkeyLCN_New.chm
	Ahk帮助标题=AutoHotkey 中文帮助
	Ahk关键字表=Block;BlockInput;Break;Catch;Click;ClipWait;ComObjActive;ComObjArray;ComObjConnect;ComObjCreate;ComObjError;ComObjFlags;ComObjGet;ComObjQuery;ComObjType;ComObjValue;Continue;Control;ControlClick;ControlFocus;ControlGet;ControlGetFocus;ControlGetPos;ControlGetText;ControlMove;ControlSend;ControlSetText;CoordMode;Critical;DetectHiddenText;DetectHiddenWindows;DllCall;Drive;DriveGet;DriveSpaceFree;Edit;Else;EnvAdd;EnvDiv;EnvGet;EnvMult;EnvSet;EnvSub;EnvUpdate;Exit;ExitApp;FileAppend;FileCopy;FileCopyDir;FileCreateDir;FileCreateShortcut;FileDelete;FileEncoding;FileGetAttrib;FileGetShortcut;FileGetSize;FileGetTime;FileGetVersion;FileInstall;FileMove;FileMoveDir;FileOpen;FileRead;FileReadLine;FileRecycle;FileRecycleEmpty;FileRemoveDir;FileSelectFile;FileSelectFolder;FileSetAttrib;FileSetTime;For;FormatTime;GetKeyState;Gosub;Goto;GroupActivate;GroupAdd;GroupClose;GroupDeactivate;Gui;GuiControl;GuiControlGet;GuiControls;Hotkey;IfBetween;IfEqual;IfExist;IfExpression;IfIn;IfInString;IfIs;IfMsgBox;IfWinActive;IfWinExist;ImageSearch;index;IniDelete;IniRead;IniWrite;Input;InputBox;KeyHistory;KeyWait;ListHotkeys;ListLines;ListVars;ListView;Loop;LoopFile;LoopParse;LoopReadFile;LoopReg;Menu;MouseClick;MouseClickDrag;MouseGetPos;MouseMove;MsgBox;ObjAddRef;OnExit;OnMessage;OutputDebug;Pause;PixelGetColor;PixelSearch;PostMessage;Process;Progress;Random;RegDelete;RegExMatch;RegExReplace;RegisterCallback;RegRead;RegWrite;Reload;Return;Run;RunAs;Send;SendLevel;SendMode;SetBatchLines;SetControlDelay;SetDefaultMouseSpeed;SetEnv;SetExpression;SetFormat;SetKeyDelay;SetMouseDelay;SetNumScrollCapsLockState;SetRegView;SetStoreCapslockMode;SetTimer;SetTitleMatchMode;SetWinDelay;SetWorkingDir;Shutdown;Sleep;Sort;SoundBeep;SoundGet;SoundGetWaveVolume;SoundPlay;SoundSet;SoundSetWaveVolume;SplashTextOn;SplitPath;StatusBarGetText;StatusBarWait;StringCaseSense;StringGetPos;StringLeft;StringLen;StringLower;StringMid;StringReplace;StringSplit;StringTrimLeft;StrPutGet;Suspend;SysGet;Thread;Throw;ToolTip;Transform;TrayTip;TreeView;Trim;Try;Until;URLDownloadToFile;VarSetCapacity;While;WinActivate;WinActivateBottom;WinClose;WinGet;WinGetActiveStats;WinGetActiveTitle;WinGetClass;WinGetPos;WinGetText;WinGetTitle;WinHide;WinKill;WinMaximize;WinMenuSelectItem;WinMinimize;WinMinimizeAll;WinMove;WinRestore;WinSet;WinSetTitle;WinShow;WinWait;WinWaitActive;WinWaitClose;#AllowSameLineComments;#ClipboardTimeout;#CommentFlag;#ErrorStdOut;#EscapeChar;#HotkeyInterval;#HotkeyModifierTimeout;#Hotstring;#If;#IfTimeout;#IfWinActive;#Include;#InputLevel;#InstallKeybdHook;#InstallMouseHook;#KeyHistory;#MaxHotkeysPerInterval;#MaxMem;#MaxThreads;#MaxThreadsBuffer;#MaxThreadsPerHotkey;#MenuMaskKey;#NoEnv;#NoTrayIcon;#Persistent;#SingleInstance;#UseHook;#Warn;#WinActivateForce
	Ahk被查关键字=i)(^|;)%CandySel%($|;)

;有doc可打开
	if RegExMatch(Ahk关键字表,Ahk被查关键字)
	{
		IfWinNotExist,%Ahk帮助标题%
		{
			VarSetCapacity(ak, ak_size := 8+5*A_PtrSize+4, 0) ; HH_AKLINK struct
			NumPut(ak_size, ak, 0, "UInt")
			NumPut(&CandySel, ak, 8)
			if !DllCall("HHCtrl.ocx\HtmlHelp", "Ptr", hAHK, "str", Ahkl新版帮助路径, "UInt", 0x000D, "ptr", &ak)
			{
				Run, %Ahkl新版帮助路径%
				WinWait,%Ahk帮助标题%,,5
				WinActivate,%Ahk帮助标题%
				sleep,2000
				wb := WBGet("ahk_class HH Parent")
				StringReplace,直接打开,CandySel,#,_
				Ahk跳转的地址=/docs/commands/%直接打开%.htm
				myURL =mk:@MSITStore:%Ahkl新版帮助路径%::%Ahk跳转的地址%
				wb.Navigate(myURL)
			}
		Return
		}
		IfWinExist,%Ahk帮助标题%
		{
			WinActivate,%Ahk帮助标题%
			send !N
			gosub monishuru
		}
	}
;没有则搜索
	Else
	{
;是否已经运行
		IfWinNotExist,%Ahk帮助标题%
		{
			Run, %Ahkl新版帮助路径%
			WinWait,%Ahk帮助标题%,,5
		}
		WinActivate,%Ahk帮助标题%
		send !s
		gosub monishuru2
	}
Return

monishuru:
sleep,500
WinActivate,%Ahk帮助标题%
wb := WBGet("ahk_class HH Parent")
sleep,300
wb.document.getElementsByTagName("input")[0].value := CandySel
wb.document.getElementsByTagName("input")[0].focus()

sleep,100
ControlSend,Internet Explorer_Server1,{enter},%Ahk帮助标题%
sleep,100
ControlSend,Internet Explorer_Server1,{enter},%Ahk帮助标题%
return

monishuru2:
sleep,500
wb := WBGet("ahk_class HH Parent")
sleep,300
wb.document.getElementsByTagName("input")[1].value := CandySel
wb.document.getElementsByTagName("input")[1].focus()

sleep,100
ControlSend,Internet Explorer_Server1,{enter},%Ahk帮助标题%
sleep,100
ControlSend,Internet Explorer_Server1,{enter},%Ahk帮助标题%
return

;-----------------------------------------------------------------------------------------------------------------
	ProperClick(ControlName)
	{
		BlockInput MouseMove  ; Disable Mouse movement to prevent user interaction
		ControlClick %ControlName%, Ahk_Class HH Parent, , , , NA  ; Perform the Click (NA Is required!)
		BlockInput MouseMoveOff  ; Enable Mouse movement
	}

cando_ahk帮助:
;-------------------------------------------------------------------------------
;#SingleInstance Force
SetTitleMatchMode RegEx
;_______________________________________________________________________________
;你帮助文件的路径
;ahk中文帮助 := "D:\Program Files\AutoHotkey\AutoHotkeyCN.chm"
BaseURL_AHK  := "mk:@MSITStore:%ahk中文帮助%::/docs/commands/%function%.htm"
;_______________________________________________________________________________
Lang := "ahk"
sleep 500
  ; Trim spaces and launch the CHM
  Function = %CandySel%
 ; tooltip %Function%
  ShowFunction( Function, Lang )
Return

ShowFunction( function, lang="ahk" ) {
  Local ThisUrl
    ;function := RegexReplace( function, "\W", "_" ) ; For other helps
  Transform ThisUrl, DeRef, % BaseURL_%lang%
  Run hh.exe %ThisUrl%

  	CF_ToolTip("您刚刚查询了：" function,2500)
}