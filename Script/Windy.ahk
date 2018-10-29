;来源 Ahk QQ群
Windy:
Label_Windy_Start_Inside:   ;内部调用入口，让Windy可以在“#if”模式下运行。
	Sksub_Clear_WindyVar()                ;每次启动的时候，首先清除本次Windy可能用到的变量
	MouseGetPos,  Windy_X,Windy_Y,Windy_CurWin_id,Windy_CurWin_ClassNN,                 ;当前鼠标下的窗口
	WinGet,        Windy_CurWin_Pid,PID,Ahk_ID %Windy_CurWin_id%                                ;当前窗口的Pid
	WinGet,        Windy_CurWin_Fullpath,ProcessPath,Ahk_ID %Windy_CurWin_id%           ;当前窗口的进程路径
	SplitPath,     Windy_CurWin_Fullpath,,Windy_CurWin_ParentPath,,Windy_CurWin_ProcName            ;当前窗口的进程名称，不带后缀
	if (Windy_CurWin_ProcName="explorer")
		Windy_CurWin_FolderPath:=GetCurrentFolder()
	WinGetClass,  Windy_CurWin_Class, Ahk_ID %Windy_CurWin_id%                                ;当前窗口的Class
	WinGetTitle,  Windy_CurWin_Title, Ahk_ID %Windy_CurWin_id%                                  ;当前窗口的title

;[············································································································]
;
; ③地理位置，判定类型
;
;[············································································································]
Label_Windy_Set_Pos_or_WinArea:
	;Gosub Label_Windy_The_Position        ;划分固定的位置区

	If ( Windy_The_Position!="")  ;如果是固定区域
	{
		IniRead,Windy_Cmd,%Windy_Profile_Ini%,位置区,%Windy_The_Position%
		If(Windy_Cmd="Error") ; 如果没有定义，则看看AnyWindow的定义
		{
			IfExist,%Windy_Profile_Dir%\位置区\%Windy_The_Position%.ini
			{
				Windy_Cmd:="menu|位置区|" Windy_The_Position
			}
			Else
				Return
		}
	}
	Else    ;对标题栏，对话框，主窗体 这三大件       ;用进程名进行划分定义
	{
		;Windy_Window_Area:= Is_Title="Caption" ? "标题栏" : ( SkSub_IsDialog( Windy_CurWin_id ) ?  "对话框" : "主窗体")
		Windy_Window_Area:="主窗体"

		IniRead,Windy_Disabled_Win,%Windy_Profile_Ini%,%Windy_Window_Area%,Windy_Disabled
		IfInString,Windy_Disabled_Win,%Windy_CurWin_ProcName%
		{
			MouseClick, Middle
			Return
		}
		Else
		{
			;首先在Windy.ini中[主窗体]下查找进程名对应的配置
			Windy_Cmd:=SkSub_Regex_IniRead(Windy_Profile_Ini, Windy_Window_Area , "i)(^|\|)\Q" Windy_CurWin_ProcName "\E($|\|)")
			If(Windy_Cmd="Error") 
			{
				;如果没有定义，则看看Any的定义
				IniRead,Windy_Cmd,%Windy_Profile_Ini%,%Windy_Window_Area%,Any
				If(Windy_Cmd="Error") ;如果Any没有定义，则查找“主窗体”文件夹下的文件
				{
					IfExist,%Windy_Profile_Dir%\%Windy_Window_Area%\%Windy_CurWin_ProcName%.ini
					{
						Windy_Cmd:="menu|" Windy_CurWin_ProcName "|menu"
					}
					Else IfExist,%Windy_Profile_Dir%\%Windy_Window_Area%\Any.ini
					{
						Windy_Cmd:="menu|any|menu"
					}
					Else
						Return
				}
			}
		}
	}
	If !(RegExMatch(Windy_Cmd,"i)^Menu\|"))
	{
		Goto Label_Windy_RunCommand            ;如果不是menu指令，直接运行应用程序
	}

;[············································································································]
;
; ⑤制作菜单
;
;[············································································································]
Label_Windy_DrawMenu:
	Menu,Windymenubywannianshuyao,add
	Menu,Windymenubywannianshuyao,DeleteAll

	IniRead,Windy_IconDir,%Windy_Profile_Ini%,Windy_Settings,icons_path                           ;图标文件夹位置
	If Windy_The_Position!=      ;有固定的第一行，则用固定的第一行，比如“左上部”之类
	{
		; 加第一行菜单，缩略显示选中的内容，该菜单让你拷贝其内容
		Menu Windymenubywannianshuyao,Add,【%Windy_The_Position%】,Label_Windy_Editconfig
		Menu Windymenubywannianshuyao,Icon,【%Windy_The_Position%】,%Windy_IconDir%\Windy位置区\%Windy_The_Position%.ico,,%MenuIconSizeGlobal%
		Menu Windymenubywannianshuyao,Add
	}
	Else If Windy_CurWin_ProcName!=          ;如果选中了某个窗口，则把该窗口名称加到第一行
	{
		; 加第一行菜单，缩略显示选中的内容，该菜单让你拷贝其内容
		Menu Windymenubywannianshuyao,Add,【%Windy_CurWin_ProcName%】,Label_Copy_WinPath_Windy
		Menu Windymenubywannianshuyao,icon,【%Windy_CurWin_ProcName%】,%Windy_CurWin_Fullpath%,,%MenuIconSizeGlobal%
		Menu Windymenubywannianshuyao,Add
	}

	StringSplit,WindyMenuFrom,Windy_Cmd,|    ; menu的定义方法为 menu|文件名|段名
	WindyMenu_ini:= WindyMenuFrom2="" ? Windy_Profile_Ini_NameNoext : WindyMenuFrom2
	WindyMenu_sec:= WindyMenuFrom3="" ? "Menu" : WindyMenuFrom3

	szMenuIdx:={}
	szMenuContent:={}
	szMenuWhichFile:={} 
	_GetMenuItem(Windy_Profile_Dir "\" Windy_Window_Area,WindyMenu_ini,WindyMenu_sec,"Windymenubywannianshuyao","")
	_DeleteSubMenus("Windymenubywannianshuyao")

	For,k,v in szMenuIdx
	{
		_CreateMenu(v,"Windymenubywannianshuyao","Label_Windy_HandleMenu")
	}
	MouseGetPos,WindyMenu_X, WindyMenu_Y
	MouseMove,WindyMenu_X,WindyMenu_Y,0
	MouseMove,WindyMenu_X,WindyMenu_Y,0
	Menu,Windymenubywannianshuyao,show
Return

;================菜单处理================================
Label_Windy_HandleMenu:
	If GetKeyState("Ctrl")			    ;[按住Ctrl则是进入配置]
	{
		Windy_ctrl_ini_fullpath:=Windy_Profile_Dir . "\" . Windy_Window_Area . "\" . szMenuWhichFile[ A_thisMenu "/" A_ThisMenuItem] . ".ini"
		Windy_Ctrl_Regex:="=\s*\Q" szMenuContent[ A_thisMenu "/" A_ThisMenuItem] "\E\s*$"
		SkSub_EditConfig(Windy_ctrl_ini_fullpath,Windy_Ctrl_Regex)
	}
	else
	{
		Windy_Cmd := szMenuContent[ A_thisMenu "/" A_ThisMenuItem]
		WindyError_From_Menu:=1
		Goto Label_Windy_RunCommand
	}
return

Label_Copy_WinPath_Windy:
	If GetKeyState("Ctrl")    ; [按住Ctrl则是进入配置]
		Goto Label_Windy_Editconfig
	Else
		Clipboard:=Windy_CurWin_Fullpath
Return

;[············································································································]
;
; ⑥变量替换
;
;[············································································································]
Label_Windy_RunCommand:
	;If(RegExMatch(Windy_Cmd,"i)^(clip\|)")) ;clip|开头，这个太特殊了，不能参与下面的“活动”
	;{
		;Goto Windo_Send_Clip
		;Return
	;}
	Windy_Cmd:=Sksub_EnvTrans(Windy_Cmd) ; 替换自变量以及系统变量,Ini里面用~%表示一个%,当然了用~~%，表示一个原义的~%
	; 当前窗口的相关信息
	StringReplace,Windy_Cmd,Windy_Cmd,{Win:class}            ,%Windy_CurWin_class%,All
	StringReplace,Windy_Cmd,Windy_Cmd,{Win:FolderPath}            ,%Windy_CurWin_FolderPath%,All
	StringReplace,Windy_Cmd,Windy_Cmd,{Win:pid}              ,%Windy_CurWin_pids%,All
	StringReplace,Windy_Cmd,Windy_Cmd,{Win:id}                ,%Windy_CurWin_ids%,All
	StringReplace,Windy_Cmd,Windy_Cmd,{Win:title}             ,%Windy_CurWin_title%,All
	StringReplace,Windy_Cmd,Windy_Cmd,{Win:Windy_hide_winid} ,%Windy_CurWin_Windy_hide_winid%
	StringReplace,Windy_Cmd,Windy_Cmd,{Win:Processname} ,%Windy_CurWin_ProcName%,All
	StringReplace,Windy_Cmd,Windy_Cmd,{Win:Fullpath}         ,%Windy_CurWin_Fullpath%
	StringReplace,Windy_Cmd,Windy_Cmd,{Win:parentpath}     ,%Windy_CurWin_ParentPath%
	If RegexMatch(Windy_Cmd, "i)\{date\:.*\}")    ;时间参数定义方法为:{date:yyyy_MM_dd} 冒号:后面的部分可以随意定义
	{
		Windy_Time_Mode:=RegExReplace(Windy_Cmd,"i).*\{date\:(.*?)\}.*","$1")
		FormatTime,Windy_Time_Formated,%A_now%,%Windy_Time_Mode%
		Windy_Cmd:=RegExReplace(Windy_Cmd,"i)\{date\:(.*?)\}",Windy_Time_Formated)
	}
;-----------------------------------------------------------------------------------------------------------------------------
	; 特别的参数:带有prompt提示文字的input 例：{Input:请输入延迟时间，以ms为单位},支持多个input输入
	; 如果要输入密码，请写成{input:提示文字:hide}
	If RegexMatch(Windy_Cmd, "i)\{Input\:.*\}")
	{
		Windy_input_pos=1
		Windy_input_list:=
		While	Windy_input_pos :=	RegexMatch(Windy_Cmd, "i)\{input\:(.*?)\}", Windy_Input_m, Windy_input_pos+strlen(Windy_Input_m))
			Windy_input_list .=	(!Windy_input_list ? "" : chr(3)) Windy_Input_m
		Loop, parse, Windy_input_list, % chr(3)
		{
			Windy_Input_Prompt_and_type:= RegExReplace(A_LoopField,"i).*\{input\:(.*?)\}.*","$1")
			Windy_Is_Password:= Regexmatch(Windy_Input_Prompt_and_type,"i)\:hide$") ? "hide":""
			Windy_Input_Prompt:=Regexmatch(Windy_Input_Prompt_and_type,"i)\:hide$") ? RegExReplace(Windy_Input_Prompt_and_type,"i)\:hide$"):Windy_Input_Prompt_and_type
			Gui +LastFound +OwnDialogs +AlwaysOnTop
			InputBox, f_Input,Windy InputBox,`n%Windy_Input_Prompt% ,%Windy_Is_Password%, 285, 175,,,,,
			If ErrorLevel
				Return
			Else
				StringReplace,Windy_Cmd,Windy_Cmd,%A_LoopField%,%f_Input%
		}
	}
	;IfInString,Windy_Cmd,{Win:goodpath}
	;{
		;f_GoodPath:=SkSub_GoodPath(Windy_CurWin_id,Windy_CurWin_class,Windy_CurWin_title,Windy_CurWin_Pid,Windy_CurWin_ParentPath,Windy_CurWin_ProcName)
		;StringReplace,Windy_Cmd,Windy_Cmd,{Win:goodpath}    ,%f_GoodPath%
	;}

;[············································································································]
;
; ⑦终极运行
;
;[············································································································]
	Windy_Cmd:=RegExReplace(Windy_Cmd,"~\|",Chr(3)) ;注意指令里面的原义|。用~|进行转义
	StringSplit,Splitted_Windy_Cmd,Windy_Cmd,|  ,%A_Space%%A_Tab%  ;对指令进行|分割，分割出的第一个是指令
	Splitted_Windy_Cmd1:=RegExReplace(Splitted_Windy_Cmd1,Chr(3),"|")
	Splitted_Windy_Cmd2:=RegExReplace(Splitted_Windy_Cmd2,Chr(3),"|")
	Splitted_Windy_Cmd3:=RegExReplace(Splitted_Windy_Cmd3,Chr(3),"|")


	If(RegExMatch(Windy_Cmd,"i)^(Config\|)")) ;如果是以Config|开头，则是编辑配置文件
	{
		for k,v in szMenuWhichfile
			Config_files .= v "`n"
		Sort, Config_files, U
		Loop ,parse, Config_files,`n
			SkSub_EditConfig(Windy_Profile_Dir . "\" . Windy_Window_Area . "\" . A_LoopField  . ".ini","")
		Windy_Ctrl_Regex:="i)(^\s*|\|)" Windy_CurWin_ProcName "(\||\s*)[^=]*="
		SkSub_EditConfig(Windy_Profile_Ini,Windy_Ctrl_Regex)
		return
	}
	Else If (RegExMatch(Windy_Cmd,"i)^(Windo\|)")) ;如果是以windo|开头，则是运行内置标签
	{
		
		If IsLabel("Windo_" . Splitted_Windy_Cmd2)                  ; Windo_开头的标签
			Goto % "Windo_" . Splitted_Windy_Cmd2
		else If IsLabel(Splitted_Windy_Cmd2)                       ; 标签
			Goto % Splitted_Windy_Cmd2
		Else
			Goto Label_Windy_ErrorHandle
	}
	Else If (RegExMatch(Windy_Cmd,"i)^(Winfunc\|)")) ;如果是以winfunc|开头，则是运行函数
	{
		if IsStingFunc(Splitted_Windy_Cmd2)
		{
			RunStingFunc(Splitted_Windy_Cmd2)
		return
		}
		else
			Goto Label_Windy_ErrorHandle
	}
	Else If (RegExMatch(Windy_Cmd,"i)^Wingo\|")) ;如果是以Wingo|开头，则是运行一些外部ahk程序，方便与你的其它脚本进行挂接
	{
		IfExist,%Splitted_Windy_Cmd2%
		{
			Run %ahk% "%Splitted_Windy_Cmd2% %Splitted_Windy_Cmd3%" ;外部的ahk代码段，你的ahk可以带参数
			Return
		}
		Else
			Goto Label_Windy_ErrorHandle
	}
	Else If (RegExMatch(Windy_Cmd,"i)^Keys\|"))  ;如果是以keys|开头，则是发送热键
	{
		;SendInput {ctrl up}{shift up}{alt up}
		SendInput % RegExReplace(Windy_Cmd,"i)^keys\|\s?")
		return
	}
	Else If (RegExMatch(Windy_Cmd,"i)^SetClipBoard\|"))
	;纯粹的置粘贴板动作，这个与前面的{setclipboard:pure}{setclipboard:rich}不一样，这个是指令
	{
		Clipboard:=RegExReplace(Windy_Cmd,"i)^SetClipBoard\|\s?")
		return
	}
	Else If(RegExMatch(Windy_Cmd,"i)^(AlwaysOnTop\|)")) ;如果是以AlwaysOnTop|开头，则是置顶当前窗体
	{
		WinSet,AlwaysOnTop,,Ahk_ID %Windy_CurWin_id%
		return
	}
	Else If(RegExMatch(Windy_Cmd,"i)^(bottom\|)")) ;如果是以bottom|开头，则是最底部
	{
		WinSet,Bottom,,Ahk_ID %Windy_CurWin_id%
		return
	}
	Else If(RegExMatch(Windy_Cmd,"i)^(Send\|)")) ;如果是以send|开头，则是发送字串
	{
		SendStr(Splitted_Windy_Cmd2)
		return
	}
	Else If (RegExMatch(Windy_Cmd,"i)^MsgBox\|"))  ;如果是以MsgBox|开头，则是发一个提示框
	{
		Gui +LastFound +OwnDialogs +AlwaysOnTop
		MsgBox %Splitted_Windy_Cmd2%
		return
	}
	Else If(RegExMatch(Windy_Cmd,"i)^(mute\|)")) ;如果是以mute|开头，则静音
	{
		Send {Volume_Mute}
		return
	}
	Else If(RegExMatch(Windy_Cmd,"i)^(open\|)")) ;如果是以open|开头，则是用当前程序打开目标文档
	{
		Run % Windy_CurWin_Fullpath " " RegExReplace(Windy_Cmd,"i)^open\|")
		return
	}
	;Else If(RegExMatch(Windy_Cmd,"i)^(Cd\|)")) ;cd,则是进行路径跳转
	;{
		;IfNotExist,%Splitted_Windy_Cmd2%
			;Return
		;SkSub_FolderJump(Splitted_Windy_Cmd2,Windy_CurWin_class,Windy_CurWin_id,Windy_CurWin_ProcName,Windy_CurWin_Fullpath)
	;}
	Else If(RegExMatch(Windy_Cmd,"i)^(tcmd\|)")) ;如果是以tcmd开头,则是
	{
		PostMessage 1075, %Splitted_Windy_Cmd2%, 0, , ahk_class TTOTAL_CMD
		return
	}
	;Else If(RegExMatch(Windy_Cmd,"i)^(hide\|)")) ;如果是以hide|开头，则是隐藏当前窗口
	;{
		;Goto Windo_HideWin
	;}
	;Else If(RegExMatch(Windy_Cmd,"i)^(unhide\|)")) ;如果是以UnHide|开头，则是显示被隐藏的窗口
	;{
		;Goto Windo_UnHideWin
	;}
	;Else If(RegExMatch(Windy_Cmd,"i)^(unhideAll\|)")) ;如果是以UnHideAll|开头，则是用当前程序打开目标文档
	;{
		;Goto Windo_UnHideWinAll
	;}
	Else If(RegExMatch(Windy_Cmd,"i)^(Close\|)")) ;如果是以Close|开头，则是用当前程序打开目标文档
	{
		Windy_win_closed:=Windy_CurWin_cmdline
		WinClose Ahk_ID %Windy_CurWin_id%
		Return
	}
	Else If(RegExMatch(Windy_Cmd,"i)^(UnClose\|)")) ;如果是以Close|开头，则是用当前程序打开目标文档
	{
		Run %Windy_win_closed%
		Return
	}
	Else If(RegExMatch(Windy_Cmd,"i)^(CloseAll\|)")) ;如果是以CloseAll|开头，
	{
		GroupAdd,classgroup,Ahk_Class %Windy_CurWin_class%
		GroupClose,classgroup,a
		Return
	}
	Else If(RegExMatch(Windy_Cmd,"i)^(kill\|)")) ;如果是以kill|开头
	{
		PostMessage, 0x12, 0, 0, , ahk_id %Windy_CurWin_id%
		;Run,taskkill /f /pid %Windy_CurWin_pid%,,UseErrorLevel Hide
		Return
	}
	Else If(RegExMatch(Windy_Cmd,"i)^(exit\|)")) ;如果是以exit|开头，则是退出当前程序
	{
		ExitApp
	}
	Else If(RegExMatch(Windy_Cmd,"i)^((roc|RunOrClose)\|)")) ;如果是以Run Or Close 开头,则是运行或者关闭
	{
		SplitPath,Splitted_Windy_Cmd2,prcvName,,
		Process,exist,%prcvName%
		If ErrorLevel
		{
			Process,Close,%prcvName%
			return
		}
		Else
		{
			Run,%Splitted_Windy_Cmd2%,%Splitted_Windy_Cmd3%,%Splitted_Windy_Cmd4% UseErrorLevel,Windy_app_Pid
			WinWait, Ahk_PID %Windy_Pid_TempA%,,3
			WinActivate,Ahk_PID %Windy_Pid_TempA%
			return
		}
	}
	Else If(RegExMatch(Windy_Cmd,"i)^((roa|RunOrActivate)\|)")) ;如果是以Run Or activate 开头,则是运行或者激活
	{
		SplitPath,Splitted_Windy_Cmd2,prcvName,,
		Process,exist,%prcvName%
		If ErrorLevel
		{
			WinActivate,Ahk_PID %ErrorLevel%
			return
		}
		Else
		{
			Run,%Splitted_Windy_Cmd2%,%Splitted_Windy_Cmd3%,%Splitted_Windy_Cmd4% UseErrorLevel,Windy_app_Pid
			WinWait, Ahk_PID %Windy_Pid_TempA%,,3
			WinActivate,Ahk_PID %Windy_Pid_TempA%
			return
		}
	}
	Else If(RegExMatch(Windy_Cmd,"i)^((rot|RunOntop)\|)")) ;如果是以run开头,则是运行且置顶
	{
		SplitPath,Splitted_Windy_Cmd2,prcvName,,
		Run,%Splitted_Windy_Cmd2%,%Splitted_Windy_Cmd3%,%Splitted_Windy_Cmd4% UseErrorLevel,Windy_app_Pid
		If (ErrorLevel = "Error")               ;如果运行出错的话
			Goto Label_Windy_ErrorHandle
		WinWait, Ahk_PID %Windy_app_Pid%,,3
		WinSet, AlwaysOnTop
		return
	}
	Else If(RegExMatch(Windy_Cmd,"i)^(run\|)"))
	{
		Run,%Splitted_Windy_Cmd2%,%Splitted_Windy_Cmd3%,%Splitted_Windy_Cmd4% UseErrorLevel,Windy_Pid_TempB
		If (ErrorLevel = "Error")               ;如果运行出错的话
			Goto Label_Windy_ErrorHandle
		WinWait, Ahk_PID %Windy_Pid_TempB%,,3
		WinActivate,Ahk_PID %Windy_Pid_TempB%
		return
	}
	Else
	{
		Run,%Splitted_Windy_Cmd1%,%Splitted_Windy_Cmd2%,%Splitted_Windy_Cmd3% UseErrorLevel,Windy_Pid_TempB
		If (ErrorLevel = "Error")               ;如果运行出错的话
			Goto Label_Windy_ErrorHandle
		WinWait, Ahk_PID %Windy_Pid_TempB%,,3
		WinActivate,Ahk_PID %Windy_Pid_TempB%
	}
Return

_CreateMenu(Item,ParentMenuName,label)    ;条目，它所处的父菜单名，菜单处理的目标标签
{  ;送进来的Item已经经过了“去空格处理”，放心使用
;提取不到图标会报错，添加下面一行防止报错
    Menu, tray,UseErrorLevel
    arrS:=StrSplit(Item,"/"," `t")
    _s:=arrS[1]
    if arrS.Maxindex()= 1      ;如果里面没有 /，就是最终的”菜单项“。添加到”它的父菜单”上。
    {
        If InStr(_s,"-") = 1       ;-分割线
        Menu, %ParentMenuName%, Add
        Else If InStr(_s,"*") = 1       ;* 灰菜单
        {
            _s:=Ltrim(_s,"*")
            Menu, %ParentMenuName%, Add,       %_s%,%Label%
            Menu, %ParentMenuName%, Disable,  %_s%
        }
        Else
        {
            y:=szMenuContent[ ParentMenuName "/" Item]
            Menu, %ParentMenuName%, Add,  %_s%,%Label%
        }
    }
    Else     ;如果有/，说明还不是最终的菜单项，还得一层一层分拨出来。
    {
        _Sub_ParentName=%ParentMenuName%/%_s%
        StringTrimLeft,_subItem,Item,strlen(_s)+1
        _CreateMenu(_subItem,_Sub_ParentName,label)
        Menu,%ParentMenuName%,add,%_s%,:%_Sub_ParentName%
    }
}

_GetMenuItem(IniDir,IniNameNoExt,Sec,TopRootMenuName,Parent="")   ;从一个ini的某个段获取条目，用于生成菜单。
{
    Items:=CF_IniRead_Section(IniDir "\" IniNameNoExt ".ini",sec)         ;本次菜单的发起地
    StringReplace,Items,Items,△,`t,all
    Loop,parse,Items,`n
    {
        Left:=RegExReplace(A_LoopField,"(?<=\/)\s+|\s+(?=\/)|^\s+|(|\s+)=[^!]*[^>]*")
        Right:=RegExReplace(A_LoopField,"^.*?\=\s*(.*)\s*$","$1")
        If (RegExMatch(left,"^/|//|/$|^$")) ;如果最右端是/，或者最左端是/，或者存在//，则是一个错误的定义，抛弃
            Continue
        If RegExMatch(Left,"i)(^|/)\+$")   ;如果左边的最末端是仅仅一个"独立的" + 号
        {
            m_Parent := InStr(Left,"/") > 0 ? RegExReplace(Left,"/[^/]*$") "/" : ""  ;如果+号前面有存在上级菜单,则有上级菜单，否则没有
            Right:=RegExReplace(Right,"~\|",Chr(3))
            arrRight:=StrSplit(Right,"|"," `t")
            rr1:=arrRight[1]
            rr2:=RegExReplace(arrRight[2],Chr(3),"|")
            rr3:=RegExReplace(arrRight[3],Chr(3),"|")
            rr4:=RegExReplace(arrRight[4],Chr(3),"|")
            If (rr1="Menu")   ;如果后面是“插入（子）菜单”的命令 ，则极有可能菜单里面还有“嵌套的下级菜单”。。
            {
                m_ini:= (rr2="") ? IniNameNoExt :  rr2
                m_sec:= (rr3="") ? "Menu" : rr3
				m_Parent:=Parent "" m_Parent
                this:=_GetMenuItem(IniDir,m_ini,m_sec,TopRootMenuName,m_Parent)      ;嵌套，循环使用此函数，以便处理“其他文件里的，插入的菜单”
            }
;             用+的方法，可以让你快速扩展自己定义的子菜单，否则直接可以写在左侧了。
        }
        Else
        {
            szMenuIdx.Push( Parent ""  Left )
            szMenuContent[ TopRootMenuName "/" Parent "" Left] := Right
            szMenuWhichFile[ TopRootMenuName "/" Parent "" Left] :=IniNameNoExt
        }
    }
}

_DeleteSubMenus(TopRootMenuName)
{
    For i,v in szMenuIdx
    {
        If instr(v,"/")>0
        {
            Item:=RegExReplace(v, "(.*)/.*", "$1")
            Menu,%TopRootMenuName%/%Item%,add
            Menu,%TopRootMenuName%/%Item%,DeleteAll
        }
    }
}

Sksub_Clear_WindyVar()
{
Windy_X:=Windy_Y:=Windy_CurWin_id:=Windy_CurWin_ClassNN:=Windy_CurWin_Pid:=Config_files:=
WindyError_From_Menu:=0
}

Label_Windy_Editconfig:
        Windy_Ctrl_Regex:="i)(^\s*|\|)" Windy_CurWin_ProcName "(\||\s*)[^=]*="
        SkSub_EditConfig(Windy_Profile_Ini,Windy_Ctrl_Regex)
return

Label_Windy_ErrorHandle:
		Gui +LastFound +OwnDialogs +AlwaysOnTop
        MsgBox, 4116,, 下述命令行定义出错： `n---------------------`n%Windy_Cmd%`n---------------------`n进程名: %Windy_CurWin_ProcName%`n`n立即配置相应ini？
		IfMsgBox Yes
		{
            if (WindyError_From_Menu=1)
            {
                Windy_This_ini:=szMenuWhichFile[ A_thisMenu "/" A_ThisMenuItem]
                Windy_ctrl_ini_fullpath:=Windy_Profile_Dir . "\" . Windy_Window_Area . "\" . Windy_This_ini . ".ini"
                Windy_Ctrl_Regex:= "=\s*\Q" szMenuContent[ A_thisMenu "/" A_ThisMenuItem] "\E\s*$"
                SkSub_EditConfig(Windy_ctrl_ini_fullpath,Windy_Ctrl_Regex)
            }
            else
            {
                Windy_Ctrl_Regex:="i)(^\s*|\|)" Windy_CurWin_ProcName "(\||\s*)[^=]*="
                SkSub_EditConfig(Windy_Profile_Ini,Windy_Ctrl_Regex)
            }
		}
	Return