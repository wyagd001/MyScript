;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 
;<<<<启动，获取对象>>>>        用拷贝的方法提取内容
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Candy:
SkSub_Clear_CandyVar()
	MouseGetPos,,,Candy_CurWin_id         ;当前鼠标下的进程ID
	WinGet, Candy_CurWin_Fullpath,ProcessPath,Ahk_ID %Candy_CurWin_id%    ;当前进程的路径
	WinGetTitle, Candy_Title,Ahk_ID %Candy_CurWin_id%    ;当前进程的标题

	Candy_Saved_ClipBoard := ClipboardAll    ;备份剪贴板
	Clipboard =                   ; 清空剪贴板
	Send, ^c
	ClipWait,1
	If ErrorLevel                              ;如果粘贴板里面没有内容，则有窗口定义
	{
		Clipboard := Candy_Saved_ClipBoard    
		Candy_Saved_ClipBoard =
		Return
	}
	Candy_isFile := DllCall("IsClipboardFormatAvailable", "UInt", 15)   ;是否是文件类型
	Candy_isHtml := DllCall("RegisterClipboardFormat", "str", "HTML Format")  ;是否Html类型
	CandySel :=Clipboard
	CandySel_Rich:=ClipboardAll
	Clipboard := Candy_Saved_ClipBoard  ;还原粘贴板
	Candy_Saved_ClipBoard =
	Transform,Candy_ProFile_Ini,Deref,%Candy_ProFile_Ini%

	IfNotExist %Candy_ProFile_Ini%         ;如果配置文件不存在，则发出警告，且终止
	{
		MsgBox 对热键%A_thishotkey% 定义的配置文件不存在! `n--------`n请检查%Candy_ProFile_Ini%
		Return
	}
 /*
╔══════════════════════════════════════╗
<<<<选中内容的后缀定义>>>>                                  ║
╚══════════════════════════════════════╝
*/
	If(Fileexist(CandySel) && RegExMatch(CandySel,"^(\\\\|.:\\)")) ;文件或者文件夹,不再支持相对路径的文件路径,但容许“文字模式的全路径”
	{
		Candy_isFile:=1     ;如果是“文字型”的有效路径，强制认定为文件
		SplitPath,CandySel,CandySel_FileNameWithExt,CandySel_ParentPath,CandySel_Ext,CandySel_FileNameNoExt,CandySel_Drive
		SplitPath,CandySel_ParentPath,CandySel_ParentName,,,, ;用这个提取“所在文件夹名”
		If InStr(FileExist(CandySel), "D")  ;区分是否文件夹,Attrib= D ,则是文件夹
		{
			CandySel_FileNameNoExt:=CandySel_FileNameWithExt
			CandySel_Ext:=RegExMatch(CandySel,"^.:\\$") ? "Driver":"Folder"            ;细分：盘符或者文件夹
		}
		Else  If (CandySel_Ext="")       ;若不是文件夹，且无后缀，则定义为NoExt
		{
			CandySel_Ext:="NoExt"
		}
		if (CandySel_ParentName="")
			CandySel_ParentName:=RTrim(CandySel_Drive,":")
	}
	Else if(instr(CandySel,"`n") And  Candy_isFile=1)  ;如果包含多行，且粘贴板性质为文件，则是“多文件”
	{
		CandySel_Ext:="MultiFiles" ;多文件的后缀=MultiFiles
		CandySel_FirstFile:=RegExReplace(CandySel,"(.*)\r.*","$1")  ;取第一行
		SplitPath ,CandySel_FirstFile,,CandySel_ParentPath,,  ;以第一行的父目录为“多文件的父目录”
		If RegExMatch(CandySel_ParentPath,"\:(|\\)$")  ;如果父目录是磁盘根目录,用盘符做父目录名。
			CandySel_ParentName:= RTrim(CandySel_ParentPath,":")
		else  ;否则，提取父目录名
			CandySel_ParentName:= RegExReplace(CandySel_ParentPath, ".*\\(.*)$", "$1")
	}
	Else     ;文本类型
	{
		;-----------特殊文字串辨析-------------------
		IniRead Candy_User_defined_TextType,%Candy_ProFile_Ini%,user_defined_TextType  ;是否符合用户正则定义的文本类型，有优先顺序的，排在前面的优先
		loop,parse,Candy_User_defined_TextType,`n
		{
			If(RegExMatch(CandySel,RegExReplace(A_LoopField,"^.*?=")))     ;根据ini里面用户自定义段，逐条查看，右侧是正则规则
			{
				CandySel_Ext:=RegExReplace(A_LoopField,"=.*?$")   ;左边是“文本某类型”
				Candy_Cmd:=SkSub_Regex_IniRead(Candy_ProFile_Ini, "TextType", "i)(^|\|)" CandySel_Ext "($|\|)") ;获取该类型的”操作设定“
				If(Candy_Cmd!="Error")            ;如果有相应后缀组的定义，则跳出去运行。
				{
					Goto Label_Candy_Read_Value
					Break
				}
			}
		}
		IniRead,Candy_ShortText_Length,%Candy_ProFile_Ini%,Candy_Settings,ShortText_Length,80   ;没有定义，则根据所选文本的长短，设定为长文本或者短文本
		CandySel_Ext:=StrLen(CandySel) < Candy_ShortText_Length ? "ShortText" : "LongText" ;区分长短文本
	} 

 /*
╔══════════════════════════════════════╗
<<<<查找定义>>>>                                                  ║
╚══════════════════════════════════════╝
*/

Label_Candy_Read_Value:
	Candy_Type          :=Candy_isFile> 0 ? "FileType":"TextType"         ;根据Candy_isFile判断类型，在相应的INI段里面查找定义
	Candy_Type_Any   :=Candy_isFile> 0 ? "AnyFile":"AnyText"         ;根据Candy_isFile判断类型，对应的Any的名称
	Candy_Cmd:=SkSub_Regex_IniRead(Candy_ProFile_Ini, Candy_Type, "i)(^|\|)" CandySel_Ext "($|\|)")  ;查找后缀群定义
	If(Candy_Cmd="Error")            ;如果没有相应后缀组的定义；下面这些啰嗦的写法是为了各种容错
	{
		IfExist,%Candy_Profile_Dir%\%CandySel_Ext%.ini   ;看是否有 后缀.ini 的配置文件存在
		{
			Candy_Cmd:="menu|" CandySel_Ext   ;同时，转化为Menu|命令行写法
		}
		Else
		{
			IniRead,Candy_Cmd, %Candy_ProFile_Ini%,%Candy_Type%,%Candy_Type_Any%   ;如果没有则看看 Any在ini的定义有没有
			If(Candy_Cmd="Error")   ;没有对AnyFile（或AnyText）的定义，则看是否有 AnyFile.ini或AnyText.ini配置存在
			{
				IfExist,%Candy_Profile_Dir%\%Candy_Type%.ini   ;有，则以此为准
				{
					Candy_Cmd:="menu|" Candy_Type   ;同时，转化为Menu|命令行写法
				}
				Else
				{
					Run,%CandySel%, ,UseErrorLevel  ;层层把关都没有么，好失望的说，就直接运行吧
					Return
				}
			}
		}
	}
	If !(RegExMatch(Candy_Cmd,"i)^Menu\|"))
	{
		Goto Label_Candy_RunCommand            ;如果不是menu指令，直接运行应用程序
	}

;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 
;<<<<制作菜单>>>>  
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Label_Candy_DrawMenu:
	Menu,CandyTopLevelMenu,add
    Menu,CandyTopLevelMenu,DeleteAll
    CandyMenu_IconSize:=CF_IniRead(Candy_ProFile_Ini, "General_Settings", "MenuIconSize",16)
    CandyMenu_IconDir:=CF_IniRead(Candy_ProFile_Ini, "General_Settings", "MenuIconDir")  ;菜单图标位置
   Transform,CandyMenu_IconDir,Deref,%CandyMenu_IconDir%

 ;加第一行菜单，缩略显示选中的内容，该菜单让你拷贝其内容
    CandyMenu_FirstItem:=Strlen(CdSel_NoSpace:=Trim(CandySel)) >20 ? SubStr0(CdSel_NoSpace,1,10) . "..." . SubStr0(CdSel_NoSpace,-10) : CdSel_NoSpace
    Menu CandyTopLevelMenu,Add,%CandyMenu_FirstItem%,Label_Candy_CopyFullpath
    Candy_Firstline_Icon:=SkSub_Get_Firstline_Icon(CandySel_Ext,CandySel,CandyMenu_IconDir "\Extension")
    Menu CandyTopLevelMenu,icon,%CandyMenu_FirstItem%,%Candy_Firstline_Icon%,,%CandyMenu_IconSize%
    Menu CandyTopLevelMenu,Add

    arrCandyMenuFrom:=StrSplit( Candy_Cmd,"|")
    CandyMenu_ini:= arrCandyMenuFrom[2]="" ? Candy_ProFile_Ini_NameNoext : arrCandyMenuFrom[2]

    CandyMenu_sec:= arrCandyMenuFrom[3]="" ? "Menu" : arrCandyMenuFrom[3]

    szMenuIdx:={}
    szMenuContent:={}
    szMenuWhichFile:={}
    SkSub_GetMenuItem(Candy_Profile_Dir,CandyMenu_ini,CandyMenu_sec,"CandyTopLevelMenu","")
    SkSub_DeleteSubMenus("CandyTopLevelMenu")

    For,k,v in szMenuIdx
    {
        SkSub_CreateMenu(v,"CandyTopLevelMenu","Label_Candy_HandleMenu",CandyMenu_IconDir,CandyMenu_IconSize)
    }
    MouseGetPos,CandyMenu_X, CandyMenu_Y
    MouseMove,CandyMenu_X,CandyMenu_Y,0
    MouseMove,CandyMenu_X,CandyMenu_Y,0
;     ToolTip,% A_TickCount-CandyStartTick,200,0     ;若要评估出menu时间，这里需打开 ,共三处，2/3
    Menu,CandyTopLevelMenu,show
;     ToolTip ;若要评估出menu时间，这里需打开 ,共三处，3/3
    Return

;================菜单处理================================
Label_Candy_HandleMenu:
    If GetKeyState("Ctrl")			    ;[按住Ctrl则是进入配置]
    {
        Candy_ctrl_ini_fullpath:=Candy_Profile_Dir . "\" . szMenuWhichFile[ A_thisMenu "/" A_ThisMenuItem] . ".ini"
        Candy_Ctrl_Regex:= "=\s*\Q" szMenuContent[ A_thisMenu "/" A_ThisMenuItem] "\E\s*$"
        SkSub_EditConfig(Candy_ctrl_ini_fullpath,Candy_Ctrl_Regex)
    }
    else
    {
        Candy_Cmd := szMenuContent[ A_thisMenu "/" A_ThisMenuItem]
        CandyError_From_Menu:=1
        Goto Label_Candy_RunCommand
    }
    return

Label_Candy_CopyFullpath:
    If GetKeyState("Ctrl")			    ;[按住Ctrl则是进入主配置]
    {
        Candy_Ctrl_Regex:="i)(^\s*|\|)" CandySel_Ext "(\||\s*)[^=]*="
        SkSub_EditConfig(Candy_Profile_ini,Candy_Ctrl_Regex)
    }
    Else
        Clipboard:=CandySel
    Return

 /*
╔══════════════════════════════════════╗
<<<<变量替换>>>>                                                  ║
╚══════════════════════════════════════╝
*/
Label_Candy_RunCommand:
   Candy_Cmd:=SkSub_EnvTrans(Candy_Cmd)  ;替换自变量以及系统变量,Ini里面用~%表示一个%,当然要用~~%，表示一个原义的~%
    Candy_Cmd=%Candy_Cmd%
    If (instr(Candy_Cmd,"{SetClipBoard:pure}")+instr(Candy_Cmd,"{SetClipBoard:rich}") )       ;这个开关指令会修改系统粘贴板，不会对命令行本身产生作用。所以先要从命令行替换掉。
    {
        Clipboard:=InStr(Candy_Cmd,"{SetClipBoard:pure}") ? CandySel : CandySel_Rich
        Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{SetClipBoard\:.*\}")
    }
    If (instr(Candy_Cmd,"{icon:")) ;icon图标
    {
        Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{icon\:.*\}")
    }
    If Candy_Cmd=   ;如果只想进行以上两步操作，如果运行的指令为空，则直接退出
        Return
    If instr(Candy_Cmd,"{date:")     ; 时间参数！定义方法为:{date:yyyy_MM_dd} 冒号:后面的部分可以随意定义
    {
        Candy_Time_Mode:=RegExReplace(Candy_Cmd,"i).*\{date\:(.*?)\}.*","$1")
        FormatTime,Candy_Time_Formated,%A_nOW%,%Candy_Time_Mode%
        Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{date\:(.*?)\}",Candy_Time_Formated)
    }
    If instr(Candy_Cmd,"{in:")    ; in：多文件的后缀包含
    {
        Candy_in_M:="i`am)^.*\.(" RegExReplace(Candy_Cmd,"i).*\{in\:(.*?)\}.*","$1") ")$"
        Grep(CandySel, Candy_in_M, CandySel, 1, 0, "`n")
        Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{in\:.*\}")
        If  (CandySel="")
            Return
        Else
            StringReplace,CandySel,CandySel,`n,`r`n,all
    }
    If instr(Candy_Cmd,"{ex:")    ; ex：多文件的后缀排除
    {
        Candy_ex_M:="i`am)^.*\.(" RegExReplace(Candy_Cmd,"i).*\{ex\:(.*?)\}.*","$1") ")$\R?"    ;可用，只是多了一个”后空白问题“
        CandySel:=RegExReplace(CandySel,Candy_ex_M)
        CandySel:=RegExReplace(CandySel,"\s*$","")         ;清除后空白 CandySel:=trim(CandySel,"`r`n")         ;清除后空白
                Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{ex\:.*\}")
        Clipboard:=CandySel
        If  (CandySel="")
            Return
    }
    If instr(Candy_Cmd,"{input:")   ;特别的参数:带有prompt提示文字的input 例：{Input:请输入延迟时间，以ms为单位},支持多个input输入
    {    ;如果要输入密码，请写成{input:提示文字:hide}
        CdInput_P=1
        Candy_Cmd_tmp:=Candy_Cmd
        While	CdInput_P :=	RegExMatch(Candy_Cmd_tmp, "i)\{input\:(.*?)\}", CdInput_M, CdInput_P+strlen(CdInput_M))
        {
            CdInput_Prompt:= RegExReplace(CdInput_M,"i).*\{input\:(.*?)(:hide)?}.*","$1")
            CdInput_Hide:= RegExMatch(CdInput_M,"i)\{input:.*?:hide}") ? "hide":""
            Gui +LastFound +OWnDialogs +AlwaysOnTop
            InputBox, CdInput_txt,Candy InputBox,`n%CdInput_Prompt% ,%CdInput_Hide%, 285, 175,,,,,
            If ErrorLevel
                Return
            Else
                StringReplace,Candy_Cmd,Candy_Cmd,%CdInput_M%,%CdInput_txt%
        }
    }
    If instr(Candy_Cmd,"{box:Filebrowser}")
    {
        FileSelectFile, f_File ,,, 请选择文件
        If ErrorLevel
            return
        StringReplace,Candy_Cmd,Candy_Cmd,{box:Filebrowser},%f_File%,All
    }
    If instr(Candy_Cmd,"{box:mFilebrowser}")
    {
        FileSelectFile, f_File ,M, , 请选择文件
        If ErrorLevel
            return
        CdMfile_suffix  := RegExReplace(Candy_Cmd,"i).*\{box:mFilebrowser:.*LastFile(.*?)\}.*","$1")
        CdMfile_prefix  := RegExReplace(Candy_Cmd,"i).*\{box:mFilebrowser:(.*?)FirstFile.*","$1")
        CdMfile_midfix := RegExReplace(Candy_Cmd,"i).*\{box:mFilebrowser:.*FirstFile(.*?)LastFile.*\}.*","$1")
        Firstline:=RegExReplace(f_File,"\n.*")
        no_Firstline:=RegExReplace(f_File,"^.*?\n","$1")
        StringReplace  ,CandySel_list,no_Firstline,`n,%CdMfile_midfix%%Firstline%/,all
        CandySel_list=%CdMfile_prefix%%Firstline%\%CandySel_list%%CdMfile_suffix%
        Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{.*FirstFile.*LastFile.*\}",CandySel_list)
    }
    If instr(Candy_Cmd,"{box:folderbrowser}")
    {
        FileSelectFolder, f_Folder , , , 请选择文件夹
        If f_Folder <>
            StringReplace,Candy_Cmd,Candy_Cmd,{box:folderbrowser},%f_Folder%,All
        Else
            Return
    }
    Candy_Cmd:=RegExReplace(Candy_Cmd,"(?<=\s|^)\{File:fullpath\}(?=\s|$|\|)","""{File:fullpath}""")     ;强制把前后有空字符或者顶端的全路径，套上引号
    If instr(Candy_Cmd,"{File:linktarget}")
    {
        FileGetShortcut,%CandySel%,CandySel_LinkTarget
        StringReplace,Candy_Cmd,Candy_Cmd,{File:linktarget} ,%CandySel_LinkTarget%,All                      ;lnk的目标
    }
    CandyCmd_RepStr :=Object( "{File:ext}"                ,CandySel_Ext
                                                ,"{File:name}"            ,CandySel_FileNameNoExt
                                                ,"{File:parentpath}"   ,CandySel_ParentPath
                                                ,"{File:parentname}"  ,CandySel_ParentName
                                                ,"{File:Drive}"             ,CandySel_Drive
                                                ,"{File:Fullpath}"         ,CandySel
                                                ,"{Text}"                     ,CandySel)
    For k, v in CandyCmd_RepStr
        StringReplace  ,Candy_Cmd,Candy_Cmd,%k%,%v%,All
    If RegExMatch(Candy_Cmd,"i)\{.*FirstFile.*LastFile.*\}")  ;如果是文件列表，需要先整理成需要的模式
    {   ;ini里面文件列表定义：   {FirstFile LastFile}   FirstFile代表非最后一个文件，LastFile代表最后一个文件。
        CdMfile_prefix  := RegExReplace(Candy_Cmd,"i).*\{(.*?)FirstFile.*\}.*","$1")
        CdMfile_suffix  := RegExReplace(Candy_Cmd,"i).*\{.*LastFile(.*?)\}.*","$1")
        CdMfile_midfix := RegExReplace(Candy_Cmd,"i).*\{.*FirstFile(.*?)LastFile.*\}.*","$1")
 ;           MsgBox,%CdMfile_midfix% - %CdMfile_prefix% - %suffix%
   ;         MsgBox,%CandySel%
        StringReplace ,CandySel_list,CandySel,`r`n,%CdMfile_midfix%,all
   ;     MsgBox % CandySel_list
        CandySel_list=%CdMfile_prefix%%CandySel_list%%CdMfile_suffix%
   ;     MsgBox % CandySel_list
        Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{.*FirstFile.*LastFile.*\}",CandySel_list)
    }
    If instr(Candy_Cmd,"{file:name:")
    {
        Candy_FileName_Coded:=
        Candy_FileName_CodeType:= RegExReplace(Candy_Cmd,"i).*\{File\:name\:(.*?)\}.*","$1")
        Candy_FileName_Coded:=SkSub_UrlEncode(CandySel_FileNameNoExt,Candy_FileName_CodeType)
        Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{File\:name\:(.*?)\}",Candy_FileName_Coded)
    }
    If instr(Candy_Cmd,"{text:")  ;如果是需要格式化的文本，那先格式化再替换
    {
        Candy_Text_Coded:=
        Candy_Text_CodeType:= RegExReplace(Candy_Cmd,"i).*\{Text\:(.*?)\}.*","$1")
        Candy_Text_Coded:=SkSub_UrlEncode(CandySel,Candy_Text_CodeType)
        Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{Text\:(.*?)\}",Candy_Text_Coded)
    }
    If instr(Candy_Cmd,"{mfile:")  ;多文件中，带有序号的文件
    {
        Loop,parse,CandySel,`n
            StringReplace,Candy_Cmd,Candy_Cmd,{mfile:%A_Index%},%A_loopfield%,All
    }

/*
╔══════════════════════════════════════╗
<<<<终极运行>>>>                                                  ║
╚══════════════════════════════════════╝
*/
        Candy_All_Cmd:="web|keys|cando|cango|run|openwith|SetClipBoard|msgbox|config|openwith|ow|rund|runp|ExeAhk"
    If Not RegExMatch(Candy_Cmd,"i)^\s*(" Candy_All_Cmd ")\s*\|")
        Candy_Cmd=OpenWith|%Candy_Cmd% ;如果没有,则人为补一个OpenWith
    Candy_Cmd:=RegExReplace(Candy_Cmd,"~\|",Chr(3))
    arrCandy_Cmd_Str:=StrSplit(Candy_Cmd,"|"," `t")
    Candy_Cmd_Str1:=arrCandy_Cmd_Str[1]
    Candy_Cmd_Str2:=RegExReplace(arrCandy_Cmd_Str[2],Chr(3),"|")
    Candy_Cmd_Str3:=RegExReplace(arrCandy_Cmd_Str[3],Chr(3),"|")
    If (Candy_Cmd_Str1="web")
    {
        SkSub_WebSearch(Candy_CurWin_Fullpath,RegExReplace(Candy_Cmd,"i)^web\|(\s+|)|\s+"))
    }
    Else If (Candy_Cmd_Str1="Keys")  ;如果是以keys|开头，则是发热键
    {
       Send %Candy_Cmd_Str2%
    }
    Else If (Candy_Cmd_Str1="MsgBox")  ;如果是以MsgBox|开头，则是发一个提示框
    {
        Gui +LastFound +OWnDialogs +AlwaysOnTop
        MsgBox %Candy_Cmd_Str2%
    }
    Else If (Candy_Cmd_Str1="Config")
    {
        for k,v in szMenuWhichfile
            Config_files .= v "`n"
        Sort, Config_files, U
        Loop ,parse, Config_files,`n
            SkSub_EditConfig(Candy_Profile_Dir . "\" A_LoopField ".ini","")
        Candy_Ctrl_Regex:="i)(^\s*|\|)" CandySel_Ext "(\||\s*)[^=]*="
            SkSub_EditConfig(Candy_Profile_ini,Candy_Ctrl_Regex)
    }
    Else If (Candy_Cmd_Str1="SetClipBoard")   ;之前的开关，只能把选中的内容放进粘贴板，而这个指令，则可以把后面跟随的内容放进粘贴板。（更丰富）
    {
        Clipboard := Candy_Cmd_Str2
    }
    Else If (Candy_Cmd_Str1="Cando")  ;如果是以Cando|开头，则是运行一些内部程序，方便与你的其它脚本进行挂接
    {
        CandySelected:=CandySel    ;兼容以前的cando变量写法
        If IsLabel("Cando_" . Candy_Cmd_Str2)                       ;程序内置的别名
            Goto % "Cando_" . Candy_Cmd_Str2
        Else
            Goto Label_Candy_ErrorHandle
    }
    Else If (Candy_Cmd_Str1="Canfunc")  ;如果是以Canfunc|开头，则是运行函数，方便与你的其它脚本进行挂接
    {
        CandySelected:=CandySel    ;兼容以前的cando变量写法
        If IsStingFunc(Candy_Cmd_Str2)
			{
          RunStingFunc(Candy_Cmd_Str2)
			return
			}
        Else
            Goto Label_Candy_ErrorHandle
    }
    Else If (Candy_Cmd_Str1="Cango")   ;如果是以Cango|开头，则是运行一些外部ahk程序，方便与你的其它脚本进行挂接
    {
        IfExist,%Candy_Cmd_Str2%
            Run %ahk% "%Candy_Cmd_Str2% %Candy_Cmd_Str3%" ;外部的ahk代码段，你的ahk可以带参数
        Else
            Goto Label_Candy_ErrorHandle
    }
    Else If (Candy_Cmd_Str1="OpenWith" or Candy_Cmd_Str1="OW")     ;OpenWith|指定用某程序打开选定的内容，这时候，应用程序后面不能带任何命令行，（严格的说是目标参数是且仅是“被选内容“，只是被省略了）
    {
        Run ,%Candy_Cmd_Str2% "%CandySel%",%Candy_Cmd_Str3%,%Candy_Cmd_Str4% UseErrorLevel             ;1:程序  2:工作目录 3:状态
        If (ErrorLevel = "Error")               ;如果运行出错的话
            Goto Label_Candy_ErrorHandle
    }
    Else If (Candy_Cmd_Str1="Run")     ;其后面要带命令行，即使操作对象是被选中的文件，也不能省略
    {
        Run,%Candy_Cmd_Str2% ,%Candy_Cmd_Str3%,%Candy_Cmd_Str4% UseErrorLevel             ;1:程序  2:工作目录 3:状态
        If (ErrorLevel = "Error")               ;如果运行出错的话
            Goto Label_Candy_ErrorHandle
    }
    Else If (Candy_Cmd_Str1="RunD")     ;格式为RunD|应用程序|应用程序的标题|x|y|等待时间
    {       ;没发现这个x，y起作用的情况，暂时放着
        Run,%Candy_Cmd_Str2%,, UseErrorLevel
        If (ErrorLevel = "Error")               ;如果运行出错的话
            Goto Label_Candy_ErrorHandle
        else
        {
            Sleep,% (Candy_Cmd_Str4="") ? 1000 : arrCandy_Cmd_Str[6]
            WinWaitActive, %Candy_Cmd_Str3% ,,5
            WinActivate, %Candy_Cmd_Str3%
            Candy_RunD_x:=arrCandy_Cmd_Str[4] ? arrCandy_Cmd_Str[4] : 100
            Candy_RunD_y:=arrCandy_Cmd_Str[5] ? arrCandy_Cmd_Str[5] : 100
            PostMessage, 0x233, HDrop( CandySel,Candy_RunD_x,Candy_RunD_y), 0,, %Candy_Cmd_Str3%
        }
    }
    Else If (Candy_Cmd_Str1="RunP")     ;格式为RunP|应用程序|应用程序的标题|等待时间；；
    {
        Clipboard := CandySel_Rich
        Run,%Candy_Cmd_Str2%,, UseErrorLevel
        If (ErrorLevel = "Error")               ;如果运行出错的话
            Goto Label_Candy_ErrorHandle
        else
        {
            Sleep,% (Candy_Cmd_Str4="") ? 1000 : Candy_Cmd_Str4
            WinWaitActive, %Candy_Cmd_Str3% ,,5
            WinActivate, %Candy_Cmd_Str3%
            Send ^v
        }
    }
    Else If (Candy_Cmd_Str1="ExeAhk")
		{      
      ;msgbox % Candy_Cmd_Str2
			RunScript(Candy_Cmd_Str2,Candy_Cmd_Str3)
		}
    Return

/*
╔══════════════════════════════════════╗
<<<<出错处理>>>>                                                  ║
╚══════════════════════════════════════╝
*/

Label_Candy_ErrorHandle:
		If (CF_IniRead(Candy_ProFile_Ini,"Candy_Settings","ShowError", 0)=1 )     ;看看出错提示开关打开了没有，打开了的话，就显示出错信息
	{
		Gui +LastFound +OwnDialogs +AlwaysOnTop
        MsgBox, 4116,, 下述命令行定义出错： `n---------------------`n%Candy_Cmd%`n---------------------`n后缀名: %CandySel_Ext%`n`n立即配置相应ini？
		IfMsgBox Yes
		{
            if (CandyError_From_Menu=1)
            {
                Candy_This_ini:=szMenuWhichFile[ A_thisMenu "/" A_ThisMenuItem]
                Candy_ctrl_ini_fullpath:=Candy_Profile_Dir . "\" . Candy_This_ini . ".ini"
                Candy_Ctrl_Regex:= "=\s*\Q" szMenuContent[ A_thisMenu "/" A_ThisMenuItem] "\E\s*$"
                SkSub_EditConfig(Candy_ctrl_ini_fullpath,Candy_Ctrl_Regex)
            }
            else
            {
                Candy_Ctrl_Regex:="i)(^\s*|\|)" CandySel_Ext "(\||\s*)[^=]*="
                SkSub_EditConfig(Candy_Profile_ini,Candy_Ctrl_Regex)
            }
		}
	}
	Return
 /*
╔══════════════════════════════════════╗
<<<<Fuctions所用到的函数>>>>                                  ║
╚══════════════════════════════════════╝
*/
SkSub_GetMenuItem(IniDir,IniNameNoExt,Sec,TopRootMenuName,Parent="")   ;从一个ini的某个段获取条目，用于生成菜单。
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
                this:=SkSub_GetMenuItem(IniDir,m_ini,m_sec,TopRootMenuName,m_Parent)      ;嵌套，循环使用此函数，以便处理“其他文件里的，插入的菜单”
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

SkSub_DeleteSubMenus(TopRootMenuName)
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

SkSub_CreateMenu(Item,ParentMenuName,label,IconDir,IconSize)    ;条目，它所处的父菜单名，菜单处理的目标标签
{  ;送进来的Item已经经过了“去空格处理”，放心使用
;提取不到图标会报错，添加下面一行防止报错
    Menu, tray,UseErrorLevel
    arrS:=StrSplit(Item,"/"," `t")
    _s:=arrS[1]
    if arrS.Maxindex()= 1      ;如果里面没有 /，就是最终的”菜单项“。添加到”它的父菜单”上。
    {
        If InStr(_s,"-") = 1       ;—————————— 分割线
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
            z:=SkSub_Get_MenuItem_Icon( y ,IconDir)
            Menu, %ParentMenuName%, Add,  %_s%,%Label%
            Menu, %ParentMenuName%, icon,  %_s%,%z%,,%IconSize%
        }
    }
    Else     ;如果有 /，说明还不是最终的菜单项，还得一层一层分拨出来。
    {
        _Sub_ParentName=%ParentMenuName%/%_s%
        StringTrimLeft,_subItem,Item,strlen(_s)+1
        SkSub_CreateMenu(_subItem,_Sub_ParentName,label,IconDir,IconSize)
        Menu,%ParentMenuName%,add,%_s%,:%_Sub_ParentName%
    }
}

SkSub_EnvTrans(v)
{
    v:=RegExReplace(v,"~%",Chr(3))
    Transform,v,Deref,%v% ;解决Sala的ini中支持%A_desktop%或%windir%等ahk变量或系统环境变量的解释问题，@sunwind @小古
    v:=RegExReplace(v,Chr(3),"%")
    Return v
}

SkSub_Get_Firstline_Icon(ext,fullpath,iconpath)
{
 ; dll文件提取不到图标会报错
 Menu, tray,UseErrorLevel
	IfExist,%iconpath%\%ext%.ico             ;如果固定的文件夹里面存在该类型的图标
		x := iconpath "\" ext ".ico"
	Else If ext in  bmp,gif,png,jpg,ico,icl,exe,dll
		x := fullpath
	Else
		x:=AssocQueryApp(Ext)
	Return %x%
}

SkSub_Get_MenuItem_Icon(item,iconpath)   ; item=需要获取图标的条目，iconpath=你定义的图标库文件夹
{
	cmd:=RegExReplace(item,"^\s+|(|\s+)\|[^!]*[^>]*")
    If instr(item,"{icon:")     ; 有图标硬定义
    {
        Path_Icon:=RegExReplace(item,"i).*\{icon\:(.*?)\}.*","$1")
        If(Fileexist(Path_Icon))         ;若有全路径的图标存在
			return Path_Icon
		If(Fileexist(iconpath "\MyIcon\" Path_Icon))       ;若在MyIcon文件夹里面
			return iconpath "\MyIcon\" Path_Icon
    }
	Else if FileExist(iconpath "\Command\" cmd ".ico")      ;若存在 "命令名.ico" 文件
	{
		Return  iconpath "\Command\" cmd ".ico"
	}
	item:=SkSub_envtrans(item)
	if RegExMatch(item,"i)^(ow|openwith|rot|run|roa|runp|rund|exeahk)\|") ;运行命令类
	{
   		cmd_removed:=RegExReplace(item,"^.*?\|")      ;里面纯粹的 应用程序 路径
		x:=RegExReplace(cmd_removed,"i)\.exe[^!]*[^>]*", ".exe")
   if(Fileexist(x))
    Return %x%  ;原脚本只有这一句
   else if(Fileexist(A_WinDir "\system32\" x))
    Return %x%
/*
      ;原版提取不到图标，菜单创建不会出错, 自己的脚本出错
      ;Menu, Tray, UseErrorLevel  ;菜单出错不提示
*/
	}
	Else if instr(item,".exe") ;省略了指令的openwith|
	{
		x:=RegExReplace(item,"i)\.exe[^!]*[^>]*", ".exe")
    if(Fileexist(x))
		Return %x%
   else if(Fileexist(A_WinDir "\system32\" x))
    Return %x%
	}
	Else
	{
		t:=RegExReplace(item,"\s*\|.*?$")       ;去除运行参数，只保留第一个|最前面的部分
		x:=AssocQueryApp(t)
		Return %x%
	}
}

AssocQueryApp(sExt)
{    ;http://www.autohotkey.com/board/topic/54927-regread-associated-program-for-a-file-extension/
    sExt =.%sExt%  ;ASSOCSTR_EXECUTABLE
    DllCall("shlwapi.dll\AssocQueryString", "uint", 0, "uint", 2, "uint", &sExt, "uint", 0, "uint", 0, "uint*", iLength)
    VarSetCapacity(sApp, 2*iLength, 0)
    DllCall("shlwapi.dll\AssocQueryString", "uint", 0, "uint", 2, "uint", &sExt, "uint", 0, "str", sApp, "uint*", iLength)
    Return sApp
}

SkSub_Regex_IniRead(ini,sec,reg)      ;正则方式的读取，等号左侧符合正则条件
{  ;在ini的某个段内，查找符合某正则规则的字符串，如果找到返回value值。找不到，则返回 Error
	IniRead,keylist,%ini%,%sec%,
	Loop,Parse,keylist,`n
	{
		t:=RegExReplace(A_LoopField,"=.*?$")
		If(RegExMatch(t, reg))
		{
			Return % RegExReplace(A_LoopField,"^.*?=")
			Break
		}
	}
	Return "Error"
}

grep(h, n, ByRef v, s = 1, e = 0, d = "")   ; ;by polythene
{
	v =
	StringReplace, h, h, %d%, , All
	Loop
		If s := RegExMatch(h, n, c, s)
			p .= d . s, s += StrLen(c), v .= d . (e ? c%e% : c)
		Else Return, SubStr(p, 2), v := SubStr(v, 2)
}

SkSub_WebSearch(Win_Full_Path,Http)
{
	all_browser:=CF_IniRead(Candy_ProFile_Ini, "General_Settings", "InUse_Browser")
	DefaultBrowser:=SkSub_EnvTrans(CF_IniRead(Candy_ProFile_Ini, "General_Settings", "Default_Browser"))
	;第①步，看当前当前激活窗口 是否 浏览器
	If Win_Full_Path Contains %All_Browser%
	{
		Browser:=Win_Full_Path
	}
	;第②步，看进程里面有没有浏览器，若有，看能被提取出来（防止虚拟桌面的隔离，妖自己的需求）
	Else Loop,Parse,All_Browser,`,   ;看所有定义的浏览器，
	{
		Useful_FullPath:=SkSub_process_exist_and_useful(A_LoopField)
		If (  Useful_FullPath!= 0  and Useful_FullPath!= 1 )
		{
			Browser:=Useful_FullPath
			Break
		}
	}
	; 第③步	，都没有么，看ini默认浏览器是否符合条件
	If ( Browser="")  ;看ini默认浏览器，a。看进程中是否有，并且能被提取出来（防止虚拟桌面的隔离，妖自己的需求）。b。或者进程里面没有。
	{
		DefaultBrowser_去除参数:= RegExReplace(DefaultBrowser, "exe[^!]*[^>]*", "exe")
		SplitPath ,DefaultBrowser_去除参数,DefaultBrowser_name
		Useful_FullPath:=SkSub_process_exist_and_useful(DefaultBrowser_name)
		If (  Useful_FullPath!= 0  And FileExist(DefaultBrowser_去除参数))
		{
			Browser:=DefaultBrowser
		}
	}
	; 第④部，最终运行
	If Browser ;如果取到了浏览器
	{
		SplitPath,browser,,,,browser_namenoext
        Browser_Args:=CF_IniRead(Candy_ProFile_Ini, "WebBrowser's_CommandLIne", browser_namenoext)
		If (Browser_Args!="Error")  ;有些浏览器，必须带参数,比如config或者单进程限制等待，所以在ini里面提供了一个定义的地方。
		{
			Browser := Browser " " Browser_Args
		}
		Run,% Browser . " """ . Http . """"
		IfInString Browser,firefox.exe
			WinActivate,Mozilla Firefox Ahk_Class MozillaWindowClass
		Else
			WinActivate Ahk_PID %ErrorLevel%
	}
	Else ;没有浏览器么
	{  ;看注册表 是否有默认的浏览器
		RegRead, RegDefaultBrowser, HKEY_CLASSES_ROOT, http\shell\open\command
		StringReplace, RegDefaultBrowser, RegDefaultBrowser,"
		SplitPath, RegDefaultBrowser,,RDB_Dir,,RDB_NameNoExt,
		Run,% RDB_Dir . "\" . RDB_NameNoExt . ".exe" . " """ . Http . """",,UseErrorLevel
		If errorlevel
		{
			Run,% "iexplore.exe " . site . """"	  ;internet explorer
		}
	}
}
;============================================================================================================
SkSub_process_exist_and_useful(Process_name)        ;判断某个进程是否存在且能有效运行，如果不用desktops，这段代码可以清除掉。
{
	Process,exist,%Process_name%
	WinGet, Process_Fullpath,ProcessPath,Ahk_PID %ErrorLevel%
	If (ErrorLevel!=0 And  Process_Fullpath!="")
		Return %Process_Fullpath%
	Else if ErrorLevel=0
		Return 1
	Else
		Return 0
}

HDrop(fnames,x=0,y=0)    ;http://www.autohotkey.com/board/topic/41467-make-ahk-drop-files-into-other-applications/page-2
{
	characterSize := A_IsUnicode ? 2 : 1
	fns:=RegExReplace(fnames,"\n$")
	fns:=RegExReplace(fns,"^\n")
	hDrop:=DllCall("GlobalAlloc","UInt",0x42,"UInt",20+(StrLen(fns)*characterSize)+characterSize*2)
	p:=DllCall("GlobalLock","UInt",hDrop)
	NumPut(20, p+0)  ;offset
	NumPut(x,  p+4)  ;pt.x
	NumPut(y,  p+8)  ;pt.y
	NumPut(0,  p+12) ;fNC
	NumPut(A_IsUnicode ? 1 : 0,  p+16) ;fWide
	p2:=p+20
	Loop,Parse,fns,`n,`r
	{
		DllCall("RtlMoveMemory","UInt",p2,"Str",A_LoopField,"UInt",StrLen(A_LoopField)*characterSize)
		p2+=StrLen(A_LoopField)*characterSize + characterSize
	}
	DllCall("GlobalUnlock","UInt",hDrop)
	Return hDrop
}

SkSub_EditConfig(inifile,regex="") ;编辑配置文件！
{
	if not fileExist(inifile)      ;动态菜单未必有ini文件存在
		return
	if (regex<>"")  ;如果送了正则表达式进来
	{
		Loop
		{
			FileReadLine, L, %inifile%, %A_Index%
			if ErrorLevel
				break
			if regexmatch(L,regex)
			{
				LineNo:=a_index
				break
			}
		}
	}
Default_TextEditor := CF_IniRead(Candy_ProFile_Ini, "General_Settings", "Default_TextEditor")
	Default_TextEditor:=SkSub_EnvTrans(Default_TextEditor)  ;默认文本编辑器
	TextEditor:=FileExist(Default_TextEditor) ? Default_TextEditor:"notepad.exe"       ;文本编辑器
	SplitPath,TextEditor,,,,namenoext
	LineJumpArgs:=CF_IniRead(Candy_ProFile_Ini, "TextEditor's_CommandLine", namenoext)
	if  (LineJumpArgs="Error" or LineNo="" )
		cmd :=TextEditor " " inifile
	else
	{
		cmd :=TextEditor " " LineJumpArgs
		StringReplace,cmd,cmd,$(FILEPATH),%inifile%
		StringReplace,cmd,cmd,$(LINENUM),%LineNo%
	}
	Run,%cmd%,,UseErrorLevel,TextEditor_PID
	WinActivate ahk_pid %TextEditor_PID%
	return
}

SkSub_Clear_CandyVar()
{
	Global
    CandySel:= CandySel_LinkTarget:= CandySel_Ext:=CandySel_FileNamenoExt:=CandySel_ParentPath:=CandySel_ParentName:=CandySel_Drive:=Config_files:=""
	CandyError_From_Menu:=0
}