option:
IniRead,询问,%run_iniFile%,截图,询问
IniRead,filetp,%run_iniFile%,截图,filetp

IniRead,Auto_Update,%run_iniFile%,功能开关,Auto_Update
IniRead,run_with_sys,%run_iniFile%,功能开关,run_with_sys
IniRead,mousetip,%run_iniFile%,功能开关,mousetip
IniRead,x_x,%run_iniFile%,常规,x_x
IniRead,y_y,%run_iniFile%,常规,y_y
IniRead,txt,%run_iniFile%,常规,txt
IniRead,TextEditor,%run_iniFile%,常规,TextEditor
IniRead,ImageEditor,%run_iniFile%,常规,ImageEditor

IniRead,Auto_Raise,%run_iniFile%,功能开关,Auto_Raise
IniRead,hover_task_buttons,%run_iniFile%,自动激活,hover_task_buttons
IniRead,hover_task_group,%run_iniFile%,自动激活,hover_task_group
IniRead,hover_task_min_info,%run_iniFile%,自动激活,hover_task_min_info
IniRead,hover_start_button,%run_iniFile%,自动激活,hover_start_button
IniRead,hover_min_max,%run_iniFile%,自动激活,hover_min_max
IniRead,hover_any_window,%run_iniFile%,自动激活,hover_any_window
IniRead,scrollundermouse,%run_iniFile%,自动激活,scrollundermouse
IniRead,hover_keep_zorder,%run_iniFile%,自动激活,hover_keep_zorder
IniRead,hover_delay,%run_iniFile%,自动激活,hover_delay

IniRead,num,%run_iniFile%,ContextMenu,num

Loop 8
{
	z:=A_Index-1
	IniRead,FF%z%,%run_iniFile%,FastFolders,Folder%z%
	IniRead,FFTitle%z%,%run_iniFile%,FastFolders,FolderTitle%z%
}

IniRead,baoshionoff,%run_iniFile%,时间,baoshionoff
IniRead,baoshilx,%run_iniFile%,时间,baoshilx
IniRead,renwu,%run_iniFile%,时间,renwu
IniRead,renwu2,%run_iniFile%,时间,renwu2
IniRead,rh,%run_iniFile%,时间,rh
IniRead,rm,%run_iniFile%,时间,rm
IniRead,renwucx,%run_iniFile%,时间,renwucx

IniRead,LoginPass,%run_iniFile%,serverConfig,LoginPass
IniRead,foobar2000,%run_iniFile%,AudioPlayer,foobar2000
IniRead,iTunes,%run_iniFile%,AudioPlayer,iTunes
IniRead,wmplayer,%run_iniFile%,AudioPlayer,wmplayer
IniRead,TTPlayer,%run_iniFile%,AudioPlayer,TTPlayer
IniRead,winamp,%run_iniFile%,AudioPlayer,winamp

Gui,99:Default
Gui,+LastFound
Gui,Destroy
Gui,Add,Button,x370 y335 w70 h30 gwk,确定
Gui,Add,Button,x450 y335 w70 h30 g99GuiClose Default,取消
Gui,Add,Tab,x-4 y1 w640 h330 ,快捷键|Plugins|常规|自动激活|7Plus菜单|整点报时|播放器|运行|其他|关于

Gui,Tab,快捷键
Gui,Add,text,x10 y30 w550,注意:#表示Win,!表示Alt,+表示Shift,^表示Ctrl,Space表示空格键,Up表示向上箭头,~表示按键原功能不会被屏蔽，*表示有其它键同时按下时快捷键仍然生效

Gui,Add,ListView,x6 y60 w570 h245 vhotkeysListview ghotkeysListview checked Grid -Multi +NoSortHdr -LV0x10 +LV0x4000 +AltSubmit,快捷键标签|快捷键|适用窗口|序号
Gui,listview,hotkeysListview 
LV_Delete()
IniRead,hotkeycontent,%run_iniFile%,快捷键
hotkeycontent:="[快捷键]" . "`n" . hotkeycontent
for k,v in IniObj(hotkeycontent,OrderedArray()).快捷键
{
	col3_tmp=
	if A_index=1
		col3_tmp:=";全局热键"
	If k contains 特定窗口_,排除窗口_
		col3_tmp:=";" k
	LV_Add(InStr(v,"@")?"" : "check",k,v,col3_tmp?col3_tmp:";",A_index)
}
LV_ModifyCol()
LV_ModifyCol(4,40)
LV_Modify(1,"Select")
LV_Modify(1,"Focus")
LV_Modify(1,"Vis")

LV_ColorInitiate(99)
sleep,500
Gui,Tab,Plugins
Gui,Add,ListView,x6 y30 w570 h245 vPluginsListview ghotkeysListview Grid -Multi -LV0x10 +LV0x4000 +AltSubmit,名称|快捷键|其他调用方法|序号
Gosub, Load_PluginsList
Gui,Add,Button,x10 y280 w80 h30 gEdit_PluginsHotkey,编辑菜单(&E)
Gui,Add,Button,x90 y280 w80 h30 gLoad_PluginsList,刷新菜单(&R)
Gui,Add,Button,x450 y280 w70 h30 gRun_Plugin,运行插件

Gui,Tab,常规
Gui,Add,CheckBox,Checked%询问% x26 y41 w70 h20 vask,截图询问

Gui,Add,Text ,x136 y45,保存类型
Gui,Add,Radio,x206 y41 w40 h20 vtp1 gche,png
Gui,Add,Radio,x256 y41 w40 h20 vtp2 gche,jpg
Gui,Add,Radio,x306 y41 w40 h20 vtp3 gche,bmp
Gui,Add,Radio,x356 y41 w40 h20 vtp4 gche,gif
If(filetp="png"){
	GuiControl,,tp1,1
}
Else If(filetp="jpg"){
	GuiControl,,tp2,1
}
Else If(filetp="bmp"){
	GuiControl,,tp3,1
}
Else If(filetp="gif"){
	GuiControl,,tp4,1
}

Gui,Add,CheckBox,Checked%Auto_Update% x26 y61 w100 h20 vupdate,启动时检测更新
Gui,Font,Cred
Gui,Add,Text,x136 y66 ,对脚本的启动速度有影响
Gui,Font

Gui,Add,CheckBox,Checked%run_with_sys% x26 y81 w100 h20 vautorun,开机启动

Gui,Add,CheckBox,Checked%mousetip% x26 y100 w100 h20 vmtp,鼠标提示

Gui,Add,Text,x26 y130 w100 h20,显示位置
Gui,Add,Radio,x85 y127 w80 h20 vdef1 gxy1,左上角
Gui,Add,Radio,x170 y127 w80 h20 vdef2 gxy2,右上角
Gui,Add,Radio,x85 y147 w80 h20 vdef3 gxy3,左下角
Gui,Add,Radio,x170 y147 w80 h20 vdef4 gxy4,右下角
If(x_x=0 && y_y=0){
	GuiControl,,def1,1
}
If(x_x=x_x2 && y_y=0){
	GuiControl,,def2,1
}
If(x_x=0 && y_y=y_y2){
	GuiControl,,def3,1
}
If(x_x=x_x2 && y_y=y_y2){
	GuiControl,,def4,1
}
Gui,Add,text,x285 y127 w15 h20,X=
Gui,Add,Edit,x300 y124 w50 h20 vx1,%x_x%
Gui,Add,text,x285 y157 w15 h20,Y=
Gui,Add,Edit,x300 y154 w50 h20 vy1,%y_y%

Gui,Add,Button,x26 y185 w144 gf_OptionsGUI,Folder Menu 选项
Gui,Font,Cred
Gui,Add,Text,x26 y220,直接编辑配置文件(慎用)
Gui,Font
Gui,Add,Button,x26 y240 w70 goo,编辑配置
Gui,Add,Button,x100 y240 w70 ginieditor_click,编辑器编辑
Gui,Add,Button,x26 y265 w144 gooo,编辑 Folder Menu 配置

Gui,Add,text,x240 y190 w120 h20,新建文本文档类型：
Gui,Add,Edit,x350 y187 w50 h20 vtxt,%txt%
Gui,Add,text,x240 y220 w100 h20,文本编辑器路径：
Gui,Add,Edit,x350 y217 w150 h20 vTextEditor,%TextEditor%
Gui,Add,Button,x500 y217 w30 h20 gTextBrowse,...
Gui,Add,text,x240 y250 w100 h20,图片编辑器路径：
Gui,Add,Edit,x350 y247 w150 h20 vImageEditor,%ImageEditor%
Gui,Add,Button,x500 y247 w30 h20 gImageBrowse,...

Gui,Tab,自动激活
Gui,Add,CheckBox,x26 y41 w200 h20 vAuto_Raise gAutoRaise,开启鼠标自动激活(点击)功能
Gui,Add,CheckBox,x26 y61 w500 h20 vhover_task_buttons,任务栏按钮自动点击功能（鼠标悬停在任务栏按钮上时自动点击）
Gui,Add,CheckBox,x44 y81 w250 h20 vhover_task_group,开启任务栏分组按钮自动点击功能(未测试)
Gui,Add,CheckBox,x44 y101 w410 h20 vhover_task_min_info,任务栏最小化窗口只显示悬浮信息（最小化的窗口不自动点击,Win7无效）
Gui,Add,CheckBox,x26 y121 w410 h20 vhover_start_button,开始菜单自动点击功能（鼠标悬停在开始菜单位置时自动点击开始菜单）
Gui,Add,CheckBox,x26 y141 w410 h20 vhover_min_max,标题栏按钮自动点击（鼠标悬停在最小化，最大化/还原按钮时自动点击）
Gui,Add,Text,x26 y165 w180 h20 vtext1,鼠标悬停所在窗口时的动作：
Gui,Add,CheckBox,x26 y185 w115 h20 vhover_any_window gundermouse,窗口自动激活
Gui,Add,CheckBox,x44 y205 w200 h20 vhover_keep_zorder,激活时不更改窗口顺序(效果一般)
Gui,Add,Text,x26 y235 w150 h20 vtext,悬停延迟响应时间（毫秒）：
Gui,Add,Edit,x170 y230 w50 h20 vhover_delay,%hover_delay%
Gui,Add,CheckBox,x26 y255 w300 h20 vscrollundermouse gundermouse,在不激活窗口情况下使滚轮生效(窗口有滚动条时)

 GuiControl,,hover_task_buttons,%hover_task_buttons%
 GuiControl,,hover_task_group,%hover_task_group%
 GuiControl,,hover_task_min_info,%hover_task_min_info%
 GuiControl,,hover_start_button,%hover_start_button%
 GuiControl,,hover_min_max,%hover_min_max%
 GuiControl,,noundereffect,1
 GuiControl,,hover_any_window,%hover_any_window%
 GuiControl,,scrollundermouse,%scrollundermouse%
 GuiControl,,hover_keep_zorder,%hover_keep_zorder%

GuiControl,Disable,hover_task_buttons
GuiControl,Disable,hover_task_group
GuiControl,Disable,hover_task_min_info
GuiControl,Disable,hover_start_button
GuiControl,Disable,hover_min_max
GuiControl,Disable,hover_any_window
GuiControl,Disable,hover_keep_zorder
GuiControl,Disable,text
GuiControl,Disable,hover_delay

If(Auto_Raise=1){
	GuiControl,,Auto_Raise,1
	GuiControl,Enable,hover_task_buttons
	GuiControl,Enable,hover_task_group
	GuiControl,Enable,hover_task_min_info
	GuiControl,Enable,hover_start_button
	GuiControl,Enable,hover_min_max
	GuiControl,Enable,hover_any_window
	GuiControl,Enable,hover_keep_zorder
	GuiControl,Enable,text
	GuiControl,Enable,hover_delay
}

Gui,Tab,7Plus菜单
Gui,Add,ListView,r12 w570 h245 v7pluslistview Grid -Multi +NoSortHdr Checked AltSubmit -LV0x10 g7plusListView,激活|ID  |菜单名称
;如果窗口含有多个 ListView 控件,默认情况下函数操作于最近添加的那个. 要改变这种情况,请指定 Gui,ListView,ListViewName
Gosub, Load_List
Gui,Add,Button,x10 y280 w80 h30 gButtun_Edit,编辑菜单(&E)
Gui,Add,Button,x90 y280 w80 h30 gLoad_List,刷新菜单(&R)
Gui,Add,Button,x170 y280 w120 h30 gsavetoreg,应用菜单到系统(&S)
Gui,Add,Button,x370 y280 w70 h30 gregsvr32dll,注册Dll
Gui,Add,Button,x450 y280 w70 h30 gunregsvr32dll,卸载Dll

Gui,Tab,整点报时
Gui, Add, GroupBox, x20 y30 w200 h90 vgbbs,整点报时(已开启)
Gui,Add,Text,x26 y65 vbaoshi1,选择报时类型:
Gui,Add,Radio,x26 y85 w80 h20 vbaoshilx1 glx,语音报时
Gui,Add,Radio,x106 y85 w80 h20 vbaoshilx2 glx,整点敲钟

Gui, Add, GroupBox, x230 y30 w200 h95,
Gui,Add,CheckBox,Checked%Auto_JCTF% x236 y40 w180 h20 vAuto_JCTF,传统节日五天前提醒
Gui,Add,CheckBox,x236 y60 w180 h20 vbaoshionoff gbaoshi,开启整点报时
Gui,Add,CheckBox,x236 y80 w180 h20 vrenwu gdingshi,开启定时任务
Gui,Add,CheckBox,Checked%renwu2% x236 y100 w180 h20 vrenwu2 gupdategbnz,开启闹钟

Gui, Add, GroupBox, x20 y125 w530 h90 vgbds,定时任务(已开启)
Gui,Add,Text,x26 y150 vdingshi1,指定时间:
Gui,Add,Edit,x85 y148 w30 h20 vrh,%rh%
Gui,Add,Text,x118 y150 vdingshi2,时
Gui,Add,Edit,x135 y148 w30 h20 vrm,%rm%
Gui,Add,Text,x167 y150 vdingshi3,分
Gui,Add,Text,x26 y180 vdingshi4,指定执行的程序:
Gui,Add,Edit,x120 y178 w350 h20 vrenwucx,%renwucx%
Gui,Add,Button,x475 y175 w30 h25 vdingshi5 grenwusl,...
Gui,Add,Button,x505 y175 w35 h25 vdingshi6 grenwucs,测试

Gui, Add, GroupBox, x20 y215 w530 h100 vgbnz,闹钟(已开启)
Gui,Add,Text,x26 y237 w60 h20 ,时间序列：
Gui, Add, Radio, x85 y237 w27 Checked vMyRadiorh gupdaterh,
Gui, Add, Radio, x172 y237 w27 gupdaterh,
Gui, Add, Radio, x257 y237 w27 gupdaterh,
Gui, Add, Radio, x344 y237 w27 gupdaterh,
Gui, Add, Radio, x431 y237 w27 gupdaterh,
Gui,Add,Edit,x112 y235 w55 h20 vrh1 grrh ,%rh1%
Gui,Add,Edit,x197 y235 w55 h20 vrh2 grrh,%rh2%
Gui,Add,Edit,x284 y235 w55 h20 vrh3 grrh,%rh3%
Gui,Add,Edit,x371 y235 w55 h20 vrh4 grrh,%rh4%
Gui,Add,Edit,x458 y235 w55 h20 vrh5 grrh,%rh5%

Gui,Add,CheckBox,x26 y265 w60 h20 vcxq1 grxq,星期一
Gui,Add,CheckBox,x90 y265 w60 h20 vcxq2 grxq,星期二
Gui,Add,CheckBox,x154 y265 w60 h20 vcxq3 grxq,星期三
Gui,Add,CheckBox,x218 y265 w60 h20 vcxq4 grxq,星期四
Gui,Add,CheckBox,x282 y265 w60 h20 vcxq5 grxq,星期五
Gui,Add,CheckBox,x346 y265 w60 h20 vcxq6 grxq,星期六
Gui,Add,CheckBox,x410 y265 w60 h20 vcxq7 grxq,星期日
Gui,Add,CheckBox,x474 y265 w60 h20 vcxq8 gexq,每天

Gui,Add,Text,x26 y292 w60 h20,提示消息
Gui,Add,Edit,x85 y290 w400 h20 vmsgtp grmsgtp,

GuiControl,,baoshionoff,%baoshionoff%
If baoshilx
GuiControl,,baoshilx1,1
Else
GuiControl,,baoshilx2,1
If(baoshionoff = 0)
{
	GuiControl,Disable,baoshi1
	GuiControl,Disable,baoshilx1
	GuiControl,Disable,baoshilx2
	GuiControl,,gbbs,整点报时(已关闭)
}
GuiControl,,renwu,%renwu%
If(renwu = 0)
{
	GuiControl,Disable,dingshi1
	GuiControl,Disable,rh
	GuiControl,Disable,dingshi2
	GuiControl,Disable,rm
	GuiControl,Disable,dingshi3
	GuiControl,Disable,dingshi4
	GuiControl,Disable,renwucx
	GuiControl,Disable,dingshi5
GuiControl,,gbds,定时任务(已关闭)
}
if(renwu2=0)
GuiControl,,gbnz,闹钟(已关闭)
gosub updaterh

Gui,Tab,播放器
Gui,Add,Text,x26 y43,Foobar2000:
Gui,Add,Edit,x96 y41 w350 h20 vap1,%foobar2000%
Gui,Add,Button,x450 y41 w30 h20 gsl,...
Gui,Add,Text,x26 y65,iTunes:
Gui,Add,Edit,x96 y63 w350 h20 vap2,%iTunes%
Gui,Add,Button,x450 y63 w30 h20 gsl,...
Gui,Add,Text,x26 y87,Wmplayer:
Gui,Add,Edit,x96 y85 w350 h20 vap3,%wmplayer%
Gui,Add,Button,x450 y85 w30 h20 gsl,...
Gui,Add,Text,x26 y109,千千静听:
Gui,Add,Edit,x96 y107 w350 h20 vap4,%TTPlayer%
Gui,Add,Button,x450 y107 w30 h20 gsl,...
Gui,Add,Text,x26 y131,Winamp:
Gui,Add,Edit,x96 y129 w350 h20 vap5,%winamp%
Gui,Add,Button,x450 y129 w30 h20 gsl,...
Gui,Add,Text,x26 y165,默认播放器
Gui,Add,Radio,x26 y185 w80 h20 vdap1 gdaps,Foobar2000
Gui,Add,Radio,x116 y185 w70 h20 vdap2 gdaps,iTunes
Gui,Add,Radio,x190 y185 w80 h20 vdap3 gdaps,Wmplayer
Gui,Add,Radio,x270 y185 w80 h20 vdap4 gdaps,千千静听
Gui,Add,Radio,x350 y185 w80 h20 vdap5 gdaps,Winamp
Gui,Add,Radio,x430 y185 w80 h20 vdap6 gdaps,AhkPlayer
If(DefaultPlayer="foobar2000"){
	GuiControl,,dap1,1
}
Else If(DefaultPlayer="iTunes"){
	GuiControl,,dap2,1
}
Else If(DefaultPlayer="Wmplayer"){
	GuiControl,,dap3,1
}
Else If(DefaultPlayer="TTPlayer"){
	GuiControl,,dap4,1
}
Else If(DefaultPlayer="Winamp"){
	GuiControl,,dap5,1
}
Else If(DefaultPlayer="AhkPlayer"){
	GuiControl,,dap6,1
}

Gui,Tab,运行
Gui,Add,Text,x26 y41,运行输入框下拉列表中固定的项目(各项目间用“|”分开):
Gui,Add,Edit,x26 y61 w530 r4 vsp,%stableProgram%
Gui,Add,Text,x26 y135,运行输入框中自定义短语(一行一个,例如“c = c:\”，只对本程序有效):
Gui,Add,Edit,x26 y155 w530 r8 vop,%otherProgram%
Gui,Add,Text,x26 y290,系统注册表中已注册的命令对本程序同样有效
Gui,Add,Button,x490 y285 g自定义运行命令_click,查看修改

Gui,Tab,其他
Gui,Add,CheckBox,x26 y41 w210 h20 vvAuto_DisplayMainWindow Checked%Auto_DisplayMainWindow%,启动时显示主窗口
Gui,Add,CheckBox,x26 y61 w210 h20 vvAuto_Trayicon Checked%Auto_Trayicon%,启动时检测托盘图标
Gui,Add,CheckBox,x44 y81 w200 h20 vvAuto_Trayicon_showmsgbox Checked%Auto_Trayicon_showmsgbox%,没有托盘图标显示重启脚本对话框
Gui,Add,CheckBox,x26 y101 w210 h20 vvShutdownMonitor Checked%ShutdownMonitor%,监视关机出现关机对话框
Gui,Add,CheckBox,x26 y121 w210 h20 vvPasteAndOpen Checked%PasteAndOpen%,粘贴并打开
Gui,Add,CheckBox,x26 y141 w210 h20 vvAuto_Clip Checked%Auto_Clip%,三重剪贴板(复制文字时生效)
Gui,Add,CheckBox,x44 y161 w130 h20 vvAuto_Cliphistory Checked%Auto_Cliphistory%,剪贴板历史(文字)
Gui,Font,cgreen
Gui,Add,text,x190 y164 w60 h20 ggui_clipHistory,查看
Gui,Font
Gui,Add,CheckBox,x26 y181 w210 h20 vvAuto_Capslock Checked%Auto_Capslock%, 按住 Capslock 改变窗口大小位置
Gui,Add,CheckBox,x26 y201 w210 h20 vvAuto_mouseclick Checked%Auto_mouseclick%, 鼠标左键增强(热键)
Gui,Add,CheckBox,x26 y221 w210 h20 vvAuto_midmouse Checked%Auto_midmouse%, 鼠标中键增强(热键)
Gui,Add,CheckBox,x26 y241 w210 h20 vvAuto_Spacepreview Checked%Auto_Spacepreview%, Space 预览文件(热键)
Gui,Add,CheckBox,x26 y261 w210 h20 vvAuto_AhkServer Checked%Auto_AhkServer%, ahk 网页控制
Gui,Add,CheckBox,x46 y281 w210 h20 vvLoginPass Checked%LoginPass%, 启动默认已登录状态

Gui,Tab,关于
Gui,Add,Text,x26 y40,名称：运行 - Ahk
Gui,Add,Text,x26 y60,作者：桂林小廖
Gui,Add,Text,x26 y80,主页：
Gui,Font,CBlue
;Gui,Font,CBlue Underline
Gui,Add,Text,x+ gg vURL,https://github.com/wyagd001/MyScript
Gui,Font
Gui,Add,Text,x26 y100,% "版本："AppVersion
Gui,Add,Text,x26 y120,适配 Autohotkey：1.1.28.00(Unicode) 系统：Win7 SP1 32bit 中文版
Gui,Add,Text,x26 y140,% "当前 Autohotkey：" A_AhkVersion "(" (A_IsUnicode?"Unicode":"ansi") ") 系统：" A_OSVersion " " (A_Is64bitOS?64:32) "bit"
Gui,Add,Button,x26 y165 gUpdate,检查更新

;Gui & Hyperlink - AGermanUser
;http://www.autohotkey.com/forum/viewtopic.php?p=107703

; Retrieve scripts PID
Process,Exist
pid_this := ErrorLevel

; Retrieve unique ID number (HWND/handle)
WinGet,hw_gui,ID,ahk_class AutoHotkeyGUI ahk_pid %pid_this%

; Call "HanGGGGGGVdleMessage" when script receives WM_SETCURSOR message
WM_SETCURSOR = 0x20
OnMessage(WM_SETCURSOR,"HandleMessage")

; Call "HandleMessage" when script receives WM_MOUSEMOVE message
WM_MOUSEMOVE = 0x200
OnMessageEx(0x200,"HandleMessage")

Gui,Show,xCenter yCenter w590 h370,选项
Return

autoraise:
If(Auto_Raise := !Auto_Raise){
	GuiControl,Enable,hover_task_buttons
	GuiControl,Enable,hover_task_group
	GuiControl,Enable,hover_task_min_info
	GuiControl,Enable,hover_start_button
	GuiControl,Enable,hover_min_max
	GuiControl,Enable,hover_any_window
	GuiControl,Enable,hover_keep_zorder
	GuiControl,Enable,text
	GuiControl,Enable,hover_delay
}
Else
{
	GuiControl,Disable,hover_task_buttons
	GuiControl,Disable,hover_task_group
	GuiControl,Disable,hover_task_min_info
	GuiControl,Disable,hover_start_button
	GuiControl,Disable,hover_min_max
	GuiControl,Disable,hover_any_window
	GuiControl,Disable,hover_keep_zorder
	GuiControl,Disable,text
	GuiControl,Disable,hover_delay
}
Return

undermouse:
;Gui,Submit,NoHide
If (hover_any_window := !hover_any_window)
{
GuiControlGet, hover_any_window
if hover_any_window
GuiControl,,scrollundermouse,0
}
If (scrollundermouse := !scrollundermouse)
{
GuiControlGet, scrollundermouse
if scrollundermouse
GuiControl,,hover_any_window,0
}
Return

baoshi:
If(baoshionoff := !baoshionoff)
{
	GuiControl,Enable,baoshi1
	GuiControl,Enable,baoshilx1
	GuiControl,Enable,baoshilx2
GuiControl,,gbbs,整点报时(已开启)
}
Else
{
	GuiControl,Disable,baoshi1
	GuiControl,Disable,baoshilx1
	GuiControl,Disable,baoshilx2
GuiControl,,gbbs,整点报时(已关闭)
}
Return

lx:
Gui,Submit,NoHide
If baoshilx1
	baoshilx=1
If baoshilx2
	baoshilx=0
Return

dingshi:
If(renwu := !renwu)
{
	GuiControl,Enable,dingshi1
	GuiControl,Enable,rh
	GuiControl,Enable,dingshi2
	GuiControl,Enable,rm
	GuiControl,Enable,dingshi3
	GuiControl,Enable,dingshi4
	GuiControl,Enable,renwucx
	GuiControl,Enable,dingshi5
GuiControl,,gbds,定时任务(已开启)
}
Else
{
	GuiControl,Disable,dingshi1
	GuiControl,Disable,rh
	GuiControl,Disable,dingshi2
	GuiControl,Disable,rm
	GuiControl,Disable,dingshi3
	GuiControl,Disable,dingshi4
	GuiControl,Disable,renwucx
	GuiControl,Disable,dingshi5
GuiControl,,gbds,定时任务(已关闭)
}
Return

TextBrowse:
FileSelectFile,textpath ,3,,选择文本编辑器的路径,程序文件(*.exe)
If !ErrorLevel
	GuiControl,,TextEditor,%textpath%
Return

ImageBrowse:
FileSelectFile,imagepath ,3,,选择图片编辑器的路径,程序文件(*.exe)
If !ErrorLevel
	GuiControl,,imageEditor,%imagepath%
Return

renwusl:
FileSelectFile,tt,,,选择要打开的程序或文件
GuiControl,,renwucx,%tt%
Return

renwucs:
run %renwucx%,,UseErrorLevel
If ErrorLevel
	MsgBox,,定时任务,定时任务运行失败，请检查命令是否正确。
Return

sl:
FileSelectFile,tt,,,选择音频播放程序,程序文件(*.exe)
If ErrorLevel=0
{
	If tt contains foobar2000
		GuiControl,,ap1,%tt%
	If tt contains iTunes
		GuiControl,,ap2,%tt%
	If tt contains wmplayer
		GuiControl,,ap3,%tt%
	If tt contains TTPlayer
		GuiControl,,ap4,%tt%
	If tt contains winamp
		GuiControl,,ap5,%tt%
}
Return

oo:
Run,notepad.exe %run_iniFile%,,UseErrorLevel
Return

inieditor_click:
Run,"%A_AhkPath%" "%A_ScriptDir%\Plugins\inieditor.ahk" "%run_iniFile%"
Return

ooo:
Run,%FloderMenu_iniFile%
Return

自定义运行命令_click:
run,"%A_AhkPath%" "%A_ScriptDir%\Plugins\自定义运行命令.ahk"
Return

g:
Run,https://github.com/wyagd001/MyScript
Gui,Destroy
Return

;######## Function #############################################################
HandleMessage(p_w,p_l,p_m,p_hw)
{
	global WM_SETCURSOR,WM_MOUSEMOVE
	static URL_hover,h_cursor_hand,h_old_cursor,CtrlIsURL,LastCtrl

	If (p_m = WM_SETCURSOR)
	{
		If URL_hover
		Return,true
	}
	Else If (p_m = WM_MOUSEMOVE)
	{
		; Mouse cursor hovers URL text control
		StringLeft,CtrlIsURL,A_GuiControl,3
		If (CtrlIsURL = "URL")
		{
			If URL_hover=
			{
				Gui,Font,cBlue underline
				GuiControl,Font,%A_GuiControl%
				LastCtrl = %A_GuiControl%
				h_cursor_hand := DllCall("LoadCursor","uint",0,"uint",32649)
				URL_hover := true
			}
			h_old_cursor := DllCall("SetCursor","uint",h_cursor_hand)
		}
		; Mouse cursor doesn't hover URL text control
		Else
		{
			If URL_hover
			{
			Gui,Font,norm cBlue
			GuiControl,Font,%LastCtrl%
			DllCall("SetCursor","uint",h_old_cursor)
			URL_hover=
			}
		}
	}
}
;######## End Of Functions #####################################################

xy1:
;ControlSetText,Edit1,0
;ControlSetText,Edit2,0
GuiControl,,x1,0
GuiControl,,y1,0
Return

xy2:
GuiControl,,x1,%x_x2%
GuiControl,,y1,0
Return

xy3:
GuiControl,,x1,0
GuiControl,,y1,%y_y2%
Return

xy4:
GuiControl,,x1,%x_x2%
GuiControl,,y1,%y_y2%
Return

che:
Gui,Submit,NoHide
If tp1=1
	filetp=png
Else If tp2=1
	filetp=jpg
Else If tp3=1
	filetp=bmp
Else
	filetp=gif
Return

hotkeysListview:
If(A_GuiControl="hotkeysListview")
{
tmpstr=hotkeys
Gui,99:ListView,hotkeysListview
}
If(A_GuiControl="PluginsListview")
{
tmpstr=Plugins
Gui,99:ListView,PluginsListview
}
If(A_GuiEvent = "I")
{
	If (ErrorLevel == "C")
	{
LV_GetText(tmphotkey,A_EventInfo,2)
if instr(tmphotkey,"@")
{
StringReplace, tmphotkey, tmphotkey,@
LV_Modify(A_EventInfo, , , tmphotkey)
}
	}
	If (ErrorLevel == "c")
	{
LV_GetText(tmphotkey,A_EventInfo,2)
if (!tmphotkey or InStr(tmphotkey,"ahk"))
return
tmphotkey:="@" tmphotkey
LV_Modify(A_EventInfo, , , tmphotkey)
	}
}
If A_GuiEvent = DoubleClick     ;Double-clicking a row opens the Edit Row dialogue window.
	gosub,Edithotkey
Return

Edithotkey:
Gui,99:Default
Gui,99:+Disabled
Gui,EditRow:+Owner99
FocusedRowNumber:=0
FocusedRowNumber := LV_GetNext(0,"F")
LV_GetText(Col1Text,FocusedRowNumber,1) 
LV_GetText(Col2Text,FocusedRowNumber,2)
If(tmpstr="hotkeys")
Gui,EditRow:Add,Text,x6 y9,标 签: %Col1Text%
If(tmpstr="Plugins")
Gui,EditRow:Add,Text,x6 y9,插 件: %Col1Text%

Gui,EditRow:Add,Text,x6 y37,快捷键:
Gui,EditRow:Add,Edit,xp+45 yp-3 w230 vEditRowEditCol2,%Col2Text%
Gui,EditRow:Add,Button,x145 yp+30 w70 h30 vEditRowButtonOK gEditRowButtonOK ,确定
Gui,EditRow:Add,Button,xp+81 yp w70 h30 vEditRowButtonCancel gEditRowButtonCancel Default ,取消
Gui,EditRow: -MaximizeBox -MinimizeBox
Gui,EditRow:Show,w320 h100,编辑快捷键
Return

EditRowButtonOK:        ;Same as the AddRowButtonOK label above except for the LV_Modify instead of LV_Insert.
Gui,EditRow:Submit,NoHide
gosub,CloseChildGui

If(tmpstr="hotkeys")
{
Gui,99:ListView,hotkeysListview
LV_Modify(FocusedRowNumber,"",Col1Text,EditRowEditCol2)
hotkeys:=[]
eqaulhotkey:=0
LV_ColorChange()
ControlGet,AA,List,col2,SysListView321,ahk_class AutoHotkeyGUI,选项
loop,parse,AA,`n,`r
	hotkeys[A_Index]:=A_LoopField
for k,v in hotkeys 
{
	If (v=EditRowEditCol2)
	eqaulhotkey+=1
}
If eqaulhotkey=2
{
	; RGB系颜色
	LV_ColorChange(FocusedRowNumber,"0xFF0000","0xFFFFFF") 
	LV_Modify(FocusedRowNumber,"-Select")
	LV_Modify(FocusedRowNumber+1,"Select")
	traytip,错误,相同快捷键已经存在,5
	FlashTrayIcon(500,5)
}
}
If(tmpstr="Plugins")
{
Gui,99:ListView,PluginsListview
LV_Modify(FocusedRowNumber,"",Col1Text,EditRowEditCol2)
}
Return

7plusListView:
Gui,99:ListView,7pluslistview
If(A_GuiEvent = "I")
{
	If (ErrorLevel == "C")
	{
		LV_GetText(ContextMenuId,A_EventInfo,2)
		IniWrite,1,%run_iniFile%,%ContextMenuId%,showmenu
	}
	If (ErrorLevel == "c")
	{
		LV_GetText(ContextMenuId,A_EventInfo,2)
		IniWrite,0,%run_iniFile%,%ContextMenuId%,showmenu
	}
}
Else If(A_GuiEvent="DoubleClick")
{
	LV_GetText(ContextMenuId,A_EventInfo,2)
	gosub ReadContextMenuIni
	gosub GUI_EventsList_Edit
}
Return

GUI_EventsList_Edit:
Gui,98:Destroy
Gui,98:Default
Gui,98:+Owner99
Gui,99:+Disabled
Gui,Add,Text,x42 y30 w50 h20 ,ID号：
Gui,Add,CheckBox,x42 y180 w250 h20 vDirectory,选中文件夹右键弹出菜单中显示
Gui,Add,CheckBox,x42 y200 w250 h20 vDirectoryBackground,文件夹目录右键菜单中显示
Gui,Add,CheckBox,x42 y220 w250 h20 vDesktop,在桌面菜单里显示
Gui,Add,CheckBox,x42 y240 w250 h20 vSingleFileOnly,选中多个文件时对第一个文件生效
Gui,Add,Text,x42 y60 w60 h20 ,菜单名：
Gui,Add,Text,x42 y90 w60 h20 ,描述：
Gui,Add,Text,x42 y120 w60 h20 ,子菜单于：
Gui,Add,Text,x42 y150 w60 h20 ,扩展名：
Gui,Add,Edit,x122 y30 w230 h20 readonly vContextMenuId,%ContextMenuId%
Gui,Add,Edit,x122 y60 w230 h20 vName,%Name%
Gui,Add,Edit,x122 y90 w230 h20 vDescription,%Description%
Gui,Add,Edit,x122 y120 w230 h20 vSubMenu,%SubMenu%
Gui,Add,Edit,x122 y150 w230 h20 vFileTypes,%FileTypes%
Gui,Add,Button,x272 y280 w70 h30 gContextMenuok,确定
Gui,Add,Button,x352 y280 w70 h30 g98GuiEscape Default,取消
GuiControl,,Directory,%Directory%
GuiControl,,DirectoryBackground,%DirectoryBackground%
GuiControl,,Desktop,%Desktop%
GuiControl,,SingleFileOnly,%SingleFileOnly%
Gui,Show,,系统右键菜单之7Plus菜单编辑
Return

Edit_PluginsHotkey:
Gui,99:ListView,Pluginslistview
FocusedRowNumber:=0
FocusedRowNumber := LV_GetNext(0,"F")
If not FocusedRowNumber
{
	CF_ToolTip("未选中编辑行!",3000)
	Return
}
else{
tmpstr=Plugins
gosub, Edithotkey
}
Return

updaterh:
Gui Submit,nohide
Iniread,xq%MyRadiorh%,%run_iniFile%,时间,xq%MyRadiorh%
if (xq%MyRadiorh%=1234567)
{
GuiControl,,cxq8,1
}
else
GuiControl,,cxq8,0

xqdsArray:=""
xqdsArray := StrSplit(xq%MyRadiorh%)
loop 7
GuiControl,,cxq%A_index%,0
for k,v in xqdsArray
{
 GuiControl,,cxq%v%,% (v=0)?0:1
}
Iniread,msgtp,%run_iniFile%,时间,msgtp%MyRadiorh%
GuiControl,,msgtp,% msgtp
return

rxq:
Gui Submit,nohide
xqtemp:=(cxq1=0?0:1)*10**6+(cxq2=0?0:2)*10**5+(cxq3=0?0:3)*10**4+(cxq4=0?0:4)*10**3+(cxq5=0?0:5)*10**2+(cxq6=0?0:6)*10+(cxq7=0?0:7)
IniWrite,%xqtemp%,%run_iniFile%,时间,xq%MyRadiorh%
Iniread,xq%MyRadiorh%,%run_iniFile%,时间,xq%MyRadiorh%
if (xq%MyRadiorh%=1234567)
{
GuiControl,,cxq8,1
}
else
GuiControl,,cxq8,0
return

rrh:
Gui Submit,nohide
rhnum:=SubStr(A_GuiControl,0)
if %A_GuiControl% =
{
IniWrite,0,%run_iniFile%,时间,xq%rhnum%
gosub updaterh
}
return

rmsgtp:
Gui Submit,nohide
IniWrite,%msgtp%,%run_iniFile%,时间,msgtp%MyRadiorh%
return

exq:
Gui Submit,nohide
if (cxq8=1)
{
IniWrite,1234567,%run_iniFile%,时间,xq%MyRadiorh%
gosub updaterh
}
return

updategbnz:
if(renwu2:=!renwu2)
guicontrol,,gbnz,闹钟(已开启)
else
guicontrol,,gbnz,闹钟(已关闭)
return

Load_PluginsList:
Gui,99:ListView,Pluginslistview
LV_Delete()
PluginsList =
SetFormat, float ,2.0
Loop, %A_ScriptDir%\Plugins\*.ahk
  PluginsList = %PluginsList%%A_LoopFileName%`n
Sort, PluginsList
Loop, parse, PluginsList, `n
{
    if A_LoopField =  ; 忽略列表末尾的空项.
        continue
StringTrimRight, Plugins%A_index%, A_LoopField, 4
IniRead,Pluginhotkey%A_index%,%run_iniFile%,Plugins,% Plugins%A_index%, %A_Space%
If IsLabel(Plugins%A_index%) 
LV_Add("",Plugins%A_index%,Pluginhotkey%A_index%, "; 快捷键设置中可带参数运行", A_index+0.0)
Else If IsLabel(Plugins%A_index% . "_click") 
LV_Add("",Plugins%A_index%,Pluginhotkey%A_index%, ";窗口界面点击", A_index+0.0)
else
LV_Add("",Plugins%A_index%,Pluginhotkey%A_index%, ";", A_index+0.0)
}
LV_ModifyCol()
LV_ModifyCol(4,40)
Return

Run_Plugin:
Gui,99:ListView,Pluginslistview
FocusedRowNumber:=0
FocusedRowNumber := LV_GetNext(0,"F")
If not FocusedRowNumber
{
	CF_ToolTip("未选中编辑行!",3000)
	Return
}
else
{
LV_GetText(Col1Text,FocusedRowNumber,1) 
Run,"%A_AhkPath%" "%A_ScriptDir%\Plugins\%Col1Text%.ahk"
}
Return

Buttun_Edit:
Gui,99:ListView,7pluslistview
FocusedRowNumber := LV_GetNext(0,"F")
;MsgBox % FocusedRowNumber
If not FocusedRowNumber
{
	CF_ToolTip("未选中!",3000)
	Return
}
Else
	LV_GetText(ContextMenuId,FocusedRowNumber,2)
gosub ReadContextMenuIni
gosub GUI_EventsList_Edit
Return

ReadContextMenuIni:
IniRead,Description,%run_iniFile%,%ContextMenuId%,Description
IniRead,Name,%run_iniFile%,%ContextMenuId%,Name
IniRead,Directory,%run_iniFile%,%ContextMenuId%,Directory
IniRead,DirectoryBackground,%run_iniFile%,%ContextMenuId%,DirectoryBackground
IniRead,Desktop,%run_iniFile%,%ContextMenuId%,Desktop
IniRead,SubMenu,%run_iniFile%,%ContextMenuId%,SubMenu
IniRead,SingleFileOnly,%run_iniFile%,%ContextMenuId%,SingleFileOnly
IniRead,FileTypes,%run_iniFile%,%ContextMenuId%,FileTypes
Return

ContextMenuok:
gui,98:Submit,NoHide
IniWrite,%Description%,%run_iniFile%,%ContextMenuId%,Description
IniWrite,%Name%,%run_iniFile%,%ContextMenuId%,Name
IniWrite,%Directory%,%run_iniFile%,%ContextMenuId%,Directory
IniWrite,%DirectoryBackground%,%run_iniFile%,%ContextMenuId%,DirectoryBackground
IniWrite,%Desktop%,%run_iniFile%,%ContextMenuId%,Desktop
IniWrite,%SubMenu%,%run_iniFile%,%ContextMenuId%,SubMenu
IniWrite,%SingleFileOnly%,%run_iniFile%,%ContextMenuId%,SingleFileOnly
IniWrite,%FileTypes%,%run_iniFile%,%ContextMenuId%,FileTypes
Gui,98:Destroy
Gui,99:-Disabled 
WinActivate,选项 ahk_class AutoHotkeyGUI
send,!R
Return

Load_List:
Gui,99:ListView,7pluslistview
LV_Delete()
loop,%num%
{
	ContextMenuId:= A_Index+1000
	IniRead,name_%A_Index%,%run_iniFile%,%ContextMenuId%,name
	IniRead,showmenu_%A_Index%,%run_iniFile%,%ContextMenuId%,showmenu
	LV_Add(showmenu_%A_Index% = 1 ? "Check" : "","",ContextMenuId,name_%A_Index%)
}
Return

daps:
Gui,Submit,NoHide
If dap1=1
	DefaultPlayer=foobar2000
Else If dap2=1
	DefaultPlayer=iTunes
Else If dap3=1
	DefaultPlayer=Wmplayer
Else If dap4=1
	DefaultPlayer=TTPlayer
Else If dap5=1
	DefaultPlayer=Winamp
Else If dap6=1
	DefaultPlayer=AhkPlayer
Return

wk:
Gui,Submit,NoHide

ControlGet,AA,List,,SysListView321,ahk_class AutoHotkeyGUI,选项
StringReplace, AA, AA, `t;, `n;, all
StringReplace, AA, AA, `t, =, all
hotkeycontent:="[快捷键]" . "`n" . AA
for k,v in IniObj(hotkeycontent,OrderedArray()).快捷键
	IniWrite,%v%,%run_iniFile%,快捷键,%k%

IniDelete, %run_iniFile%, Plugins
ControlGet,AA,List,,SysListView322,ahk_class AutoHotkeyGUI,选项
StringReplace, AA, AA, `t;, `n;, all
StringReplace, AA, AA, `t, =, all
hotkeycontent:="[Plugins]" . "`n" . AA
for k,v in IniObj(hotkeycontent,OrderedArray()).Plugins
	IniWrite,%v%,%run_iniFile%,Plugins,%k%

IniWrite,%ask%,%run_iniFile%,截图,询问
IniWrite,%filetp%,%run_iniFile%,截图,filetp
IniWrite,%update%,%run_iniFile%,功能开关,Auto_Update
IniWrite,%autorun%,%run_iniFile%,功能开关,run_with_sys
IniWrite,%mtp%,%run_iniFile%,功能开关,mousetip
IniWrite,% vAuto_DisplayMainWindow,%run_iniFile%,功能模式选择,Auto_DisplayMainWindow
IniWrite,% vAuto_Trayicon,%run_iniFile%,功能开关,Auto_Trayicon
IniWrite,% vAuto_Trayicon_showmsgbox,%run_iniFile%,功能模式选择,Auto_Trayicon_showmsgbox
IniWrite,% vShutdownMonitor,%run_iniFile%,功能开关,ShutdownMonitor
IniWrite,% vPasteAndOpen,%run_iniFile%,功能开关,PasteAndOpen
IniWrite,% vAuto_Clip,%run_iniFile%,功能开关,Auto_Clip
IniWrite,% vAuto_Cliphistory,%run_iniFile%,功能开关,Auto_Cliphistory
IniWrite,% vAuto_Capslock,%run_iniFile%,功能开关,Auto_Capslock
IniWrite,% vAuto_mouseclick,%run_iniFile%,功能开关,Auto_mouseclick
IniWrite,% vAuto_midmouse,%run_iniFile%,功能开关,Auto_midmouse
IniWrite,% vAuto_Spacepreview,%run_iniFile%,功能开关,Auto_Spacepreview
IniWrite,% vAuto_AhkServer,%run_iniFile%,功能开关,Auto_AhkServer
IniWrite,% vLoginPass,%run_iniFile%,serverConfig,LoginPass

IniWrite,%txt%,%run_iniFile%,常规,txt
IniWrite,%TextEditor%,%run_iniFile%,常规,TextEditor
IniWrite,%ImageEditor%,%run_iniFile%,常规,ImageEditor

If(autorun=1){
	RegWrite,REG_SZ,HKEY_LOCAL_MACHINE,SOFTWARE\Microsoft\Windows\CurrentVersion\Run,Run - Ahk,%A_ScriptFullPath%
}
Else
	RegWrite,REG_SZ,HKEY_LOCAL_MACHINE,SOFTWARE\Microsoft\Windows\CurrentVersion\Run,Run - Ahk,%A_Space%
IniWrite,%x1%,%run_iniFile%,常规,x_x
IniWrite,%y1%,%run_iniFile%,常规,y_y

IniWrite,%Auto_Raise%,%run_iniFile%,功能开关,Auto_Raise
IniWrite,%hover_task_buttons%,%run_iniFile%,自动激活,hover_task_buttons
IniWrite,%hover_task_group%,%run_iniFile%,自动激活,hover_task_group
IniWrite,%hover_task_min_info%,%run_iniFile%,自动激活,hover_task_min_info
IniWrite,%hover_start_button%,%run_iniFile%,自动激活,hover_start_button
IniWrite,%hover_min_max%,%run_iniFile%,自动激活,hover_min_max
IniWrite,%hover_any_window%,%run_iniFile%,自动激活,hover_any_window
IniWrite,%scrollundermouse%,%run_iniFile%,自动激活,scrollundermouse
IniWrite,%hover_keep_zorder%,%run_iniFile%,自动激活,hover_keep_zorder
IniWrite,%hover_delay%,%run_iniFile%,自动激活,hover_delay

IniWrite,%baoshionoff%,%run_iniFile%,时间,baoshionoff
IniWrite,%baoshilx%,%run_iniFile%,时间,baoshilx
IniWrite,%renwu%,%run_iniFile%,时间,renwu
IniWrite,%rh%,%run_iniFile%,时间,rh
IniWrite,%rm%,%run_iniFile%,时间,rm
IniWrite,%renwucx%,%run_iniFile%,时间,renwucx
IniWrite,%rh1%,%run_iniFile%,时间,rh1
IniWrite,%rh2%,%run_iniFile%,时间,rh2
IniWrite,%rh3%,%run_iniFile%,时间,rh3
IniWrite,%rh4%,%run_iniFile%,时间,rh4
IniWrite,%rh5%,%run_iniFile%,时间,rh5
IniWrite,%renwu2%,%run_iniFile%,时间,renwu2
IniWrite,%Auto_JCTF%,%run_iniFile%,功能开关,Auto_JCTF

IniWrite,%ap1%,%run_iniFile%,AudioPlayer,Foobar2000
IniWrite,%ap2%,%run_iniFile%,AudioPlayer,iTunes
IniWrite,%ap3%,%run_iniFile%,AudioPlayer,Wmplayer
IniWrite,%ap4%,%run_iniFile%,AudioPlayer,TTPlayer
IniWrite,%ap5%,%run_iniFile%,AudioPlayer,Winamp
IniWrite,%DefaultPlayer%,%run_iniFile%,固定的程序,DefaultPlayer
IniWrite,%sp%,%run_iniFile%,固定的程序,stableProgram

IniDelete,%run_iniFile%,otherProgram
;FileAppend, `n`r, %run_iniFile%
Loop,Parse,op,`n`r
{
	otp2:=A_LoopField
	If otp2 contains [
	{
		continue
	}
	Else
	{
		If(NOT InStr(A_LoopField,"="))
			continue
		StringSplit,op2_,otp2,=
		othp2:=op2_1
		%othp2%:=op2_2
		IniWrite,%op2_2%,%run_iniFile%,otherProgram,%othp2%
	}
}
Sleep,10
Gui,Destroy
Reload

98GuiEscape:
98GuiClose:
CloseChildGui:
EditRowButtonCancel:
EditRowGuiClose:
EditRowGuiEscape:
Gui,99:-Disabled
Gui,Destroy
Gui,99:Default
Return

99GuiClose:
99GuiEscape:
LV_ColorChange()
Gui,Destroy
Return

LV_ColorInitiate(Gui_Number=1,Control="") ; initiate listview color change procedure 
{ 
	global hw_LV_ColorChange 
	If Control =
		Control = SysListView321
	Gui,%Gui_Number%:+Lastfound 
	Gui_ID := WinExist() 
	ControlGet,hw_LV_ColorChange,HWND,,%Control%,ahk_id %Gui_ID% 
	OnMessage( 0x4E,"WM_NOTIFY" ) 
} 

LV_ColorChange(Index="",TextColor="",BackColor="") ; change specific line's color or reset all lines
{ 
	global 
	If Index = 
		Loop,% LV_GetCount() 
			LV_ColorChange(A_Index) 
	Else
	{ 
		Line_Color_%Index%_Text := TextColor 
		Line_Color_%Index%_Back := BackColor 
		WinSet,Redraw,,ahk_id %hw_LV_ColorChange% 
	} 
}

; 禁止调整列表中列的宽度，行文字变色
WM_NOTIFY( p_w,p_l,p_m )
{ 
	local draw_stage,Current_Line,Index
	Critical

	Static HDN_BEGINTRACKA = -306,HDN_BEGINTRACKW = -326,HDN_DIVIDERDBLCLICK = -320
	;Code := -(~NumGet(p_l+0,8))-1
	Code :=NumGet(p_l + 8,0,"Int")
	If (Code = HDN_BEGINTRACKA) || (Code = HDN_BEGINTRACKW)|| (Code = HDN_BEGINTRACKW)
		Return True
	If ( NumGet( p_l+0,0,"Uint") = hw_LV_ColorChange ){ 
		If ( NumGet(p_l+0,8,"int" ) = -12 ) {                            ; NM_CUSTOMDRAW 
			draw_stage := NumGet(p_l+0,12,"Uint") 
			If ( draw_stage = 1 )                                                 ; CDDS_PREPAINT 
				Return,0x20                                                      ; CDRF_NOTIFYITEMDRAW 
			Else If ( draw_stage = 0x10000|1 ){                                   ; CDDS_ITEM 
				Current_Line := NumGet( p_l+0,36,"Uint")+1 
				LV_GetText(Index,Current_Line,4) 
				If (Line_Color_%Index%_Text != ""){
					NumPut( BGR(Line_Color_%Index%_Text),p_l+0,48,"Uint")   ; foreground 
					NumPut( BGR(Line_Color_%Index%_Back),p_l+0,52,"Uint")   ; background 
				}
			}
		}
	}
}

BGR(i) {
   Return, (i & 0xff) << 16 | (i & 0xffff) >> 8 << 8 | i >> 16
}