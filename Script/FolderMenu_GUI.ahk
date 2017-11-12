f_OptionsGUI:
Gui,88:Default
Gui, +LastFoundExist
IfWinExist
{
	Gui, Show, , Folder Menu 选项
	return
}
Gui, Margin, 12,12
gui_W := 306 + gui_ww
gui_H := 336 + gui_hh
gui_hh+= (gui_hh = 0) ? 0 : 18
Gui, Add, Tab, +Theme vgui_Tab w%gui_W% h%gui_H% w306, Favorites|应用程序|快捷键|图标|菜单|其它|关于

;--------- Favorites ---------
Gui, Tab, Favorites

gui_FavImageList := IL_Create()
gui_W := 276 + gui_ww
gui_H := 218 + gui_hh
Gui, Add, TreeView, w%gui_W% h%gui_H% vgui_FavTree +ReadOnly ImageList%gui_FavImageList%
Gui, Add, Text, y+12 Section, 名称
Gui, Add, Text, y+13         , 路径
gui_W := 170 + gui_ww
Gui, Add, Edit,   w%gui_W% r1 xs+30 ys-4 Section vgui_FavEditName gf_FavEditName
Gui, Add, Edit,   w%gui_W% r1 y+5  vgui_FavEditPath gf_FavEditPath
Gui, Add, Button, w20 h20 gf_FavBtnPath   x+5 ys+25 vgui_FavBtnPath, ...
Gui, Add, Button, w20 h20 gf_FavTreeAdd   x+5 ys    , +
Gui, Add, Button, w20 h20 gf_FavTreeDel   y+5       , -
Gui, Add, Button, w20 h20 gf_FavTreeUp    x+5 ys    , ^
Gui, Add, Button, w20 h20 gf_FavTreeDown  y+5       , v
setTip("...", "浏览文件或文件夹",88)
setTip("+", "Ins`n按住 Shift 点击会添加一个子菜单",88)
setTip("-", "Del`n按住 Shift 点击会删除一个子菜单",88)
setTip("^", "Shift+Up",88)
setTip("v", "Shift+Down",88)

Menu, FavPathSp , Add
Menu, FavPathSp , DeleteAll
Menu, FavPathSp , Add, 我的电脑   	, f_FavPathSpecial
Menu, FavPathSp , Add
Menu, FavPathSp , Add, 添加到Favorite  	, f_FavPathSpecial
Menu, FavPathSp , Add, 添加 Favorite 到此, f_FavPathSpecial
Menu, FavPathSp , Add, 重启        	, f_FavPathSpecial
Menu, FavPathSp , Add, Folder Menu 选项       	, f_FavPathSpecial
Menu, FavPathSp , Add, 编辑配置文件          	, f_FavPathSpecial
Menu, FavPathSp , Add, 退出          	, f_FavPathSpecial
Menu, FavPathSp , Add, 切换隐藏文件 	, f_FavPathSpecial
Menu, FavPathSp , Add, 切换文件扩展名, f_FavPathSpecial
Menu, FavPathSp , Add, 我最近的文档 	, f_FavPathSpecial
Menu, FavPathSp , Add, 资源管理器列表 	, f_FavPathSpecial
Menu, FavPathSp , Add, 盘符列表  	, f_FavPathSpecial
Menu, FavPathSp , Add
Menu, FavPathSp , Add, 工具菜单     	, f_FavPathSpecial
Menu, FavPathSp , Add, 最近使用的项目   	, f_FavPathSpecial
Menu, FavPathSp , Add, SVS 菜单     	, f_FavPathSpecial
Menu, FavPathSp , Add
Menu, FavPathSp , Add, 分隔符     	, f_FavPathSpecial
Menu, FavBtnPath, Add, 浏览文件夹(&B)	, f_FavBrowseFolder
Menu, FavBtnPath, Add, 浏览文件 (&R) 	, f_FavBrowseFile
Menu, FavBtnPath, Add, 特殊项目(&S)	, :FavPathSp
f_SetMenuIcon("FavPathSp" , "我的电脑"   , f_GetIcon("Computer"))
f_SetMenuIcon("FavPathSp" , "添加到Favorite"  , f_Icons . ",-301")
f_SetMenuIcon("FavPathSp" , "添加 Favorite 到此",f_Icons . ",-301")
f_SetMenuIcon("FavPathSp" , "重启"        , f_Icons . ",-302")
f_SetMenuIcon("FavPathSp" , "Folder Menu 选项"       , f_Icons . ",-303")
f_SetMenuIcon("FavPathSp" , "编辑配置文件"          , f_Icons . ",-304")
f_SetMenuIcon("FavPathSp" , "退出"          , f_Icons . ",-305")
f_SetMenuIcon("FavPathSp" , "切换隐藏文件" , f_Icons . ",-302")
f_SetMenuIcon("FavPathSp" , "切换文件扩展名",f_Icons . ",-302")
f_SetMenuIcon("FavPathSp" , "我最近的文档" , f_GetIcon("Recent"))
f_SetMenuIcon("FavPathSp" , "资源管理器列表" , f_GetIcon("Explorer"))
f_SetMenuIcon("FavPathSp" , "盘符列表"    , f_GetIcon("Computer"))
f_SetMenuIcon("FavPathSp" , "工具菜单"     , f_Icons)
f_SetMenuIcon("FavPathSp" , "最近使用的项目"   , f_Icons . ",-307")
f_SetMenuIcon("FavPathSp" , "SVS 菜单"      , f_Icons . ",-311")
f_SetMenuIcon("FavBtnPath", "浏览文件夹(&B)", f_GetIcon(WinDir))
f_SetMenuIcon("FavBtnPath", "浏览文件 (&R)"  , f_GetIcon(""))
f_SetMenuIcon("FavBtnPath", "特殊项目(&S)", f_Icons)

IL_Add(gui_FavImageList, f_Icons, 0)
gui_FavTreeTVIDRoot := TV_Add("Menu", "", "Bold Expand Icon1")
gui_FavTreePath%gui_FavTreeTVIDRoot% =
gui_FavTreeIcon%gui_FavTreeTVIDRoot% = 1 ; icon index in IL
;ToolTip, Loading...
Loop, % s_FavoritesCount
	f_FavTreeCreateItem(gui_FavTreeTVIDRoot, "Root", s_Favorites%A_Index%)
;ToolTip

Loop, Parse, gui_FavTreeParentList, `n
	if A_LoopField !=
		gui_FavTreeID%A_LoopField% =

TVX("gui_FavTree", "f_FavTreeHandler", "HasRoot", "gui_FavTreePath", "gui_FavTreeIcon")

;--------- Applications ---------
Gui, Tab, 应用程序

Gui, Add, Text, BackgroundTrans, 选择你需要应用Folder Menu的应用程序
Gui, Add, CheckBox, h20 vs_Apps_Explorer Section, Explorer
Gui, Add, CheckBox, h20 vs_Apps_Dialog           , Open/Save Dialog
Gui, Add, CheckBox, h20 vs_Apps_Command          , Command Prompt
Gui, Add, CheckBox, h20 vs_Apps_Desktop          , Desktop
Gui, Add, CheckBox, h20 vs_Apps_7z               , 7-Zip File Manager
Gui, Add, CheckBox, h20 vs_Apps_Fz3              , FileZilla 3
Gui, Add, CheckBox, h20 vs_Apps_TC               , Total Commander
Gui, Add, CheckBox, h20 vs_Apps_FC               , FreeCommander
Gui, Add, CheckBox, h20 vs_Apps_Emacs Section ys, Emacs
Gui, Add, CheckBox, h20 vs_Apps_rxvt             , rxvt

StringReplace, gui_AppsListBox, s_Apps_OthersList, `,, |, A ; | seperated for ListBox
Gui, Add, CheckBox, h20 vs_Apps_Others    xs, 其它应用程序
Gui, Add, ListBox,  r9 vgui_AppsListBox     , %gui_AppsListBox%
Gui, Add, Edit, wp-65 r1 vgui_AppsAddName Section
Gui, Add, Button, w20 h20 gf_AddOtherApps ys, +
Gui, Add, Button, w20 h20 gf_DelOtherApps ys, -

GuiControl, 88: , s_Apps_Explorer      , %s_Apps_Explorer%
GuiControl, 88: , s_Apps_Dialog        , %s_Apps_Dialog%
GuiControl, 88: , s_Apps_Command       , %s_Apps_Command%
GuiControl, 88: , s_Apps_7z            , %s_Apps_7z%
GuiControl, 88: , s_Apps_Fz3           , %s_Apps_Fz3%
GuiControl, 88: , s_Apps_TC            , %s_Apps_TC%
GuiControl, 88: , s_Apps_FC            , %s_Apps_FC%
GuiControl, 88: , s_Apps_Emacs         , %s_Apps_Emacs%
GuiControl, 88: , s_Apps_rxvt          , %s_Apps_rxvt%
GuiControl, 88: , s_Apps_Desktop       , %s_Apps_Desktop%
GuiControl, 88: , s_Apps_Others        , %s_Apps_Others%

;--------- Hotkeys ---------
Gui, Tab, 快捷键

Gui, Add, Text, Section BackgroundTrans, 显示菜单 1
Gui, Add, Edit, y+4  w100 r1 vs_Hotkey1, %s_Hotkey1%
Gui, Add, Button, x+5 yp w20 h20 gf_HotkeySet1
Gui, Add, Text, xs BackgroundTrans, 显示菜单 1.5
Gui, Add, Edit, y+4  w100 r1 vs_Hotkey15,%s_Hotkey15%
Gui, Add, Button, x+5 yp w20 h20 gf_HotkeySet15
Gui, Add, Text, xs BackgroundTrans, 显示菜单 2
Gui, Add, Edit, y+4  w100 r1 vs_Hotkey2, %s_Hotkey2%
Gui, Add, Button, x+5 yp w20 h20 gf_HotkeySet2
Gui, Add, Text, xs BackgroundTrans, 打开选中的文字
Gui, Add, Edit, y+4  w100 r1 vs_HotkeyJ, %s_HotkeyJ%
Gui, Add, Button, x+5 yp w20 h20 gf_HotkeySetJ
Gui, Add, Text, xs BackgroundTrans, 添加应用程序
Gui, Add, Edit, y+4  w100 r1 vs_HotkeyG, %s_HotkeyG%
Gui, Add, Button, x+5 yp w20 h20 gf_HotkeySetG

Gui, Add, Button, xs gf_HotkeyHelp, 如何设置快捷键?

Gui, Add, Text, xs+150 ys Section BackgroundTrans, 添加到 Favorite
Gui, Add, Edit, y+4  w100 r1 vs_HotkeyA, %s_HotkeyA%
Gui, Add, Button, x+5 yp w20 h20 gf_HotkeySetA
Gui, Add, Text, xs BackgroundTrans, 重启
Gui, Add, Edit, y+4  w100 r1 vs_HotkeyR, %s_HotkeyR%
Gui, Add, Button, x+5 yp w20 h20 gf_HotkeySetR
Gui, Add, Text, xs BackgroundTrans, Folder Menu 选项
Gui, Add, Edit, y+4  w100 r1 vs_HotkeyO, %s_HotkeyO%
Gui, Add, Button, x+5 yp w20 h20 gf_HotkeySetO
Gui, Add, Text, xs BackgroundTrans, 编辑配置文件
Gui, Add, Edit, y+4  w100 r1 vs_HotkeyE, %s_HotkeyE%
Gui, Add, Button, x+5 yp w20 h20 gf_HotkeySetE
Gui, Add, Text, xs BackgroundTrans, 退出
Gui, Add, Edit, y+4  w100 r1 vs_HotkeyX, %s_HotkeyX%
Gui, Add, Button, x+5 yp w20 h20 gf_HotkeySetX

setTip("Edit4", "在支持的窗口中才能显示菜单`n在当前窗口打开菜单项目",88)
setTip("Edit5", "菜单总是显示`n用支持的程序的当前窗口打开菜单项目",88)
setTip("Edit6", "菜单总是显示`n用新的窗口打开菜单项目",88)

;--------- Icons ---------
Gui, Tab, 图标

Gui, Add, CheckBox, h20 vs_NoMenuIcon gf_NoMenuIcon Section, 不使用菜单图标
GuiControl, 88: , s_NoMenuIcon, %s_NoMenuIcon%

Gui, Add, Text, ys+4, 图标尺寸
Gui, Add, Edit, ys w40 r1 vs_IconSize Number, %s_IconSize%
setTip("Edit14", "尺寸设为0表示最大`n留空为默认大小",88)

f_ReadIcons()

gui_W := 276 + gui_ww
gui_H := 200 + gui_hh
Gui, Add, ListView, xs h%gui_H% w%gui_W% gf_IconLV vgui_IconLV AltSubmit -Multi, 图标|扩展名|图标位置
gui_IconImageList := IL_Create()
LV_SetImageList(gui_IconImageList)
Loop, % s_IconsCount
{
	if s_Icons%A_Index%Index > 0 ; dont change negative index
		IL_Add(gui_IconImageList, s_Icons%A_Index%Path, s_Icons%A_Index%Index+1)
	else
		IL_Add(gui_IconImageList, s_Icons%A_Index%Path, s_Icons%A_Index%Index)
	LV_Add("Icon" . A_Index, "", s_Icons%A_Index%Ext, s_Icons%A_Index%Path . "," . s_Icons%A_Index%Index)
}
LV_ModifyCol(2, "AutoHdr")
LV_ModifyCol(3, "AutoHdr")

Gui, Add, Text, y+16 Section, 扩展名
Gui, Add, Edit,   w60 ys-4 Section vgui_IconAdd, IconAdd
Gui, Add, Button, w20 h20 ys gf_IconAdd , +
Gui, Add, Button, w20 h20 ys gf_IconDel , -
Gui, Add, Button, w40 h20 ys gf_IconEdit, Edit
setTip("IconAdd", "扩展名有以下默认项目：`nUnknown   	未知文件格式`nComputer  	我的电脑`nDrive        	硬盘`nFolder      	文件夹`nFolderS      	文件夹带子文件夹`nMenu       	菜单`nRecent      	系统最近使用的项目`nExplorer      	资源管理器",88)
GuiControl, 88: , gui_IconAdd

;--------- Menu ---------
Gui, Tab, 菜单

Gui, Add, Text, Section, 菜单显示位置:
Gui, Add, Text, xs+10 Section, X
Gui, Add, Edit, ys-4 w40 r1 vs_MenuPositionX Number
Gui, Add, Text, ys, Y
Gui, Add, Edit, ys-4 w40 r1 vs_MenuPositionY Number
Gui, Add, DropDownList, w120 ys-4 vs_MenuPosition AltSubmit, 相对于屏幕||相对于窗口
GuiControl,, s_MenuPositionX, %s_MenuPositionX%
GuiControl,, s_MenuPositionY, %s_MenuPositionY%
GuiControl, Choose, s_MenuPosition, %s_MenuPosition%
setTip("Edit16", "留空表示跟随鼠标位置",88)
setTip("Edit17", "留空表示跟随鼠标位置",88)

Gui, Add, Text, xs-10 y+15, 最近的项目:
Gui, Add, Text, xs Section BackgroundTrans, 最近的项目个数
Gui, Add, Edit, xs+110 ys-4 r1 Number            , %s_RecentSize%
Gui, Add, UpDown, Range1-36 vs_RecentSize         , %s_RecentSize%
Gui, Add, CheckBox, ys-4 h20 vs_RecentOnlyFolder ,只记录文件夹

Gui, Add, Text, xs Section BackgroundTrans,  系统最近的项目个数
Gui, Add, Edit, xs+110 ys-4 r1 Number           , %s_RecentSizeS%
Gui, Add, UpDown, Range1-36 vs_RecentSizeS       , %s_RecentSizeS%
Gui, Add, CheckBox, ys-4 h20 vs_RecentOnlyFolderS, 只记录文件夹

Gui, Add, CheckBox, xs h20 vs_RecentShowIndex, 显示序号

GuiControl, ,s_RecentOnlyFolder , %s_RecentOnlyFolder%
GuiControl, ,s_RecentOnlyFolderS, %s_RecentOnlyFolderS%
GuiControl, ,s_RecentShowIndex  , %s_RecentShowIndex%

Gui, Add, Button, x+12 yp-2 gf_ClearRecent, 清除最近的项目(&C)

Gui, Add, Text, xs-10 y+15, "Ctrl-Click" 子文件夹菜单:
Gui, Add, CheckBox, xs h20 vs_TempShowAll Section, 显示文件(&F)
Gui, Add, Edit, ys w80 r1 vs_ShowFileExt, %s_ShowFileExt%
Gui, Add, CheckBox, xs h20 vs_AltFolderIcon, 以不同的图标标明有子文件夹的文件夹菜单

setTip("Edit20", "在菜单中显示扩展名",88)
GuiControl,, s_TempShowAll  , %s_TempShowAll%
GuiControl,, s_AltFolderIcon, %s_AltFolderIcon%

Gui, Add, Text, xs-10 y+15 Section, 自动创建的子菜单的最大深度:
Gui, Add, Edit, ys-4 w40 r1 vs_MaxDepth, %s_MaxDepth%
setTip("Edit21", "0位不限制",88)

;--------- Others ---------
Gui, Tab, 其它

Gui, Add, CheckBox, h20 vs_DontKillReg          , 不重启已经存在的注册表编辑器(&R)
Gui, Add, CheckBox, h20 vs_BrowseMode           , Capslock关闭时使用浏览模式
Gui, Add, CheckBox, h20 vs_HideExt      Section,  项目中隐藏扩展名
Gui, Add, CheckBox, h20 vs_CheckItmePath      ys, 检查重复的路径
Gui, Add, Text, xs y+16, 托盘菜单的显示类型
Gui, Add, DropDownList, w100 vs_TrayIconClick x+12 yp-4 AltSubmit, Show Menu 1||Show Menu 1.5|Show Menu 2
Gui, Add, Text, xs, 添加到 Favorite:
Gui, Add, CheckBox, h20 vs_AddFavBottom  xp+10 y+12 Section, 添加于菜单最后面
Gui, Add, CheckBox, h20 vs_AddFavSkipGUI      ys, 跳过选项界面直接添加
Gui, Add, CheckBox, h20 vs_AddFavReplace      xs, 项目存在时直接替换

GuiControl, 88: , s_DontKillReg  , %s_DontKillReg%
GuiControl, 88: , s_BrowseMode   , %s_BrowseMode%
GuiControl, 88: , s_HideExt      , %s_HideExt%
GuiControl, 88: , s_CheckItmePath, %s_CheckItmePath%
GuiControl, 88: Choose, s_TrayIconClick, %s_TrayIconClick%
GuiControl, 88: , s_AddFavBottom , %s_AddFavBottom%
GuiControl, 88: , s_AddFavSkipGUI, %s_AddFavSkipGUI%
GuiControl, 88: , s_AddFavReplace, %s_AddFavReplace%

;--------- About ---------
Gui, Tab, 关于
gui_X := 40 + gui_ww/2
gui_Y := 64 + gui_hh/2
Gui, Add, Picture, Icon w32 h32 x+%gui_X% y+%gui_Y% Section,%f_Icons%
Gui, Font, s16, Verdana
Gui, Add, Text, ys+4 Section BackgroundTrans, Folder Menu
Gui, Font
Gui, Add, Text, ys+11 BackgroundTrans, v1.34
Gui, Add, Text, xs BackgroundTrans, Copyright (c) 2006-2009 rexx
Gui, Add, Text, xs-45 BackgroundTrans, 该脚本已被修改，请到作者主页获得原始的版本。
Gui, Add, Button, xs+85 y+32 Section gf_GoWebsite, 访问软件主页

Gui, Tab
gui_X := 30 + gui_ww
Gui, Add, Button, xm      w60 Section gf_EditConfig  ,编辑(&E)
Gui, Add, Button, x+%gui_X% ys w60 Default gf_OptionOK    , 确定
Gui, Add, Button, x+5  ys w60          gf_OptionCancel, 取消
Gui, Add, Button, x+5  ys w60          gf_OptionApply , 应用(&A)
setTip("编辑(&E)", "编辑 Foldermenu.ini",88)

if gui_hh = 0
{
	Gui, Add, Button, x+5  ys w20 gf_ExpandGui, >
	setTip(">", "显示大一些的界面",88)
}
else
{
	Gui, Add, Button, x+5  ys w20 gf_ExpandGui, <
	setTip("<", "显示一个小一些的界面",88)
}

GuiControl, ChooseString, gui_Tab, %gui_Tab% ; choose last used tab
gui_hh-= (gui_hh = 0) ? 0 : 18
Gui, Show, , Folder Menu 选项
return

f_EditConfig:
MsgBox, 36, Folder Menu 选项, 是否保存更改?
IfMsgBox Yes
	Gosub, f_OptionOK
else
	Gosub, f_OptionCancel
MsgBox, 64, Folder Menu 选项,编辑配置文件后必须重启脚本才能使新的配置生效.
Run, %FloderMenu_iniFile%
return

f_OptionOK:
StringReplace, s_Apps_OthersList, gui_AppsListBox,  |, `,, A ; update other apps list
Gui, Submit
StringReplace, gui_AppsListBox, s_Apps_OthersList, `,, |, A ; | seperated for ListBox
f_SetConfig()
f_WriteConfig()
f_ReadFavorites()
Gui, Destroy
Gui, 77:Destroy
return

f_OptionCancel:
88GuiClose:
88GuiEscape:
Gui, 77:Destroy
Gui, Destroy
return

f_OptionApply:
StringReplace, s_Apps_OthersList, gui_AppsListBox,  |, `,, A ; update other apps list
Gui, Submit, NoHide
StringReplace, gui_AppsListBox, s_Apps_OthersList, `,, |, A ; | seperated for ListBox
f_SetConfig()
f_WriteConfig()
f_ReadFavorites()
return

f_ExpandGui:
GuiControlGet, gui_Tab
MsgBox, 36, Folder Menu 选项, 是否保存更改?
IfMsgBox Yes
	Gosub, f_OptionOK
else
	Gosub, f_OptionCancel
gui_hh := (gui_hh = 0) ? A_ScreenHeight-500 : 0
gui_hh := (gui_hh > 0) ? gui_hh : 0
gui_ww := (gui_ww = 0) ? 100 : 0
;gui_ww := (gui_ww > 0) ? gui_ww : 0
Sleep, 100
Gosub, f_OptionsGUI
return

f_GoWebsite:
Run, http://www.autohotkey.net/~rexx/FolderMenu/index.en.htm
return

;==================== Add Favorite ====================;
f_AddFavoriteHere:
gui_AddFavPath := f_GetPath(w_WinID, w_Class)
StringTrimLeft, f_ThisMenu, A_ThisMenu, 9 ; trim "MainMenu@"
StringSplit, f_ThisMenu, f_ThisMenu, @
if s_CheckItmePath
{
	gui_AddFavName := f_ItemPathExist(gui_AddFavPath)
	if gui_AddFavName
		MsgBox, 48, 警告, 路径已经存在.`n`n(%gui_AddFavName%)
}
gui_AddFavName := f_GetName(gui_AddFavPath)
if gui_AddFavName =
	gui_AddFavName = New Item
if s_AddFavSkipGUI && gui_AddFavPath != "" ; skip gui only if path is not blank
{
	if InStr(A_ThisMenu, "@")
	{
		gui_AddFavName =
		Loop, %f_ThisMenu0%
		{
			f_ThisMenu := f_ThisMenu%A_Index%
			gui_AddFavName .= ":" . f_Menu_%f_ThisMenu% . "|"
		}
		gui_AddFavName .= f_GetName(gui_AddFavPath)
	}
	if !s_AddFavReplace ; check for existing item and ask for what to do
	{
		IniRead, gui_AddFavNameExist, %FloderMenu_iniFile%, Favorites, %gui_AddFavName%
		if gui_AddFavNameExist != ERROR
			MsgBox, 36, 添加到 Favorite, [%gui_AddFavName%] 已经存在.`n`n(%gui_AddFavNameExist%)`n`n是否替换?
		IfMsgBox No
			return	; dont replace it.
	}
	IniWrite, %gui_AddFavPath%, %FloderMenu_iniFile%, Favorites, %gui_AddFavName%	; Write to ini
	gui_AddFavName := f_GetName(gui_AddFavPath)
	TrayTip, Add Favorite , [%gui_AddFavName%] added., , 1
	f_ReadFavorites()
	return
}
;gui_hh = 0
;gui_ww = 0
gui_Tab = Favorites
Gosub, f_OptionsGUI
Sleep, 100
GuiControl, ChooseString, gui_Tab, %gui_Tab%
GuiControl, Focus, gui_FavTree
if InStr(A_ThisMenu, "@")
{
	Send, {Home}{Left}{Right}
	Loop, %f_ThisMenu0%
	{
		f_ThisMenu := f_ThisMenu%A_Index%
		Send, % f_Menu_%f_ThisMenu%
		Send, {Right}
	}
}
else
	Send, {Home}
TVX_Insert(0, s_AddFavBottom)
gui_FavTreeSelected := TV_GetSelection()
TV_Modify(gui_FavTreeSelected, "", gui_AddFavName)
gui_FavTreePath%gui_FavTreeSelected% := gui_AddFavPath
return

f_AddFavorite:
gui_AddFavPath := f_GetPath(w_WinID, w_Class)
if s_CheckItmePath
{
	gui_AddFavName := f_ItemPathExist(gui_AddFavPath)
	if gui_AddFavName
		MsgBox, 48, 警告, 路径已经存在.`n`n(%gui_AddFavName%)
}
gui_AddFavName := f_GetName(gui_AddFavPath)
if gui_AddFavName =
	gui_AddFavName = New Item
if s_AddFavSkipGUI && gui_AddFavPath != "" ; skip gui only if path is not blank
{
	if !s_AddFavReplace ; check for existing item and ask for what to do
	{
		IniRead, gui_AddFavNameExist, %FloderMenu_iniFile%, Favorites, %gui_AddFavName%
		if gui_AddFavNameExist != ERROR
			MsgBox, 36, 添加到 Favorite, [%gui_AddFavName%] 已经存在.`n`n(%gui_AddFavNameExist%)`n`n是否替换?
		IfMsgBox No
			return	; dont replace it.
	}
	IniWrite, %gui_AddFavPath%, %FloderMenu_iniFile%, Favorites, %gui_AddFavName%	; Write to ini
	TrayTip, 添加到 Favorite , [%gui_AddFavName%] 添加成功., , 1
	f_ReadFavorites()
	return
}
;gui_hh = 0
;gui_ww = 0
gui_Tab = Favorites
Gosub, f_OptionsGUI
GuiControl, ChooseString, gui_Tab, %gui_Tab%
Sleep, 100

TVX_Insert(0, s_AddFavBottom)
gui_FavTreeSelected := TV_GetSelection()
TV_Modify(gui_FavTreeSelected, "", gui_AddFavName)
gui_FavTreePath%gui_FavTreeSelected% := gui_AddFavPath
return

88GuiDropFiles:
GuiControlGet, gui_Tab
if gui_Tab = Favorites
{
	if A_GuiControl in gui_FavTree,gui_FavEditName,gui_FavEditPath
	{
		Loop, Parse, A_GuiEvent, `n
		{
			gui_AddFavPath = %A_LoopField%
			gui_AddFavName := f_GetName(gui_AddFavPath)
			if gui_AddFavName =
				gui_AddFavName = New Item
			if A_GuiControl = gui_FavTree
			{
				TVX_Insert()
				gui_FavTreeSelected := TV_GetSelection()
				TV_Modify(gui_FavTreeSelected, "", gui_AddFavName)
				gui_FavTreePath%gui_FavTreeSelected% := gui_AddFavPath
			}
			else
			{
				if !TV_GetParent(gui_FavTreeSelected) ; drop a file to root's path field, do nothing
					return
				GuiControl, 88: , gui_FavEditName, %gui_AddFavName%
				GuiControl, 88: , gui_FavEditPath, %gui_AddFavPath%
			}
			f_Split2(f_GetIcon(gui_AddFavPath), ",", gui_FavEditIconPath, gui_FavEditIconIndex)
			if gui_FavEditIconPath = This
				gui_FavEditIconPath := gui_AddFavPath
			if gui_FavEditIconIndex > 0 ; dont change negative index
				gui_FavEditIconIndex++
			gui_FavTreeIcon%gui_FavTreeSelected% := IL_Add(gui_FavImageList, gui_FavEditIconPath, gui_FavEditIconIndex)
			TV_Modify(gui_FavTreeSelected, "Icon" . gui_FavTreeIcon%gui_FavTreeSelected%)
		}
	}
}
return

;==================== Favorites TreeView ====================;
f_FavTreeAdd:
TVX_Insert(GetKeyState("Shift", "P"))
GuiControl, 88: Focus, gui_FavEditName
return

f_FavTreeDel:
TVX_Delete(GetKeyState("Shift", "P"))
return

f_FavTreeUp:
ControlSend, SysTreeView321, {Shift Down}
ControlSend, SysTreeView321, {Up}
Sleep, 50
ControlSend, SysTreeView321, {Shift Up}
return

f_FavTreeDown:
ControlSend, SysTreeView321, {Shift Down}
ControlSend, SysTreeView321, {Down}
Sleep, 50
ControlSend, SysTreeView321, {Shift Up}
return

f_FavTreeHandler:
if A_GuiEvent = S
{
	gui_FavTreeSelected := TV_GetSelection()
	TV_GetText(gui_FavEditName,gui_FavTreeSelected)
	gui_FavEditPath := gui_FavTreePath%gui_FavTreeSelected%
	GuiControl, 88: , gui_FavEditName, %gui_FavEditName%
	GuiControl, 88: , gui_FavEditPath, %gui_FavEditPath%
	if TV_GetParent(gui_FavTreeSelected) ; it's not root
		GuiControl, 88: Enable, gui_FavEditName
	else
		GuiControl, 88: Disable, gui_FavEditName
	if TV_GetChild(gui_FavTreeSelected) or gui_FavEditName = "-" ; it's menu or separator
	{
		GuiControl, 88: Disable, gui_FavEditPath
		GuiControl, 88:  Disable, gui_FavBtnPath
	}
	else
	{
		GuiControl, 88:  Enable, gui_FavEditPath
		GuiControl, 88:  Enable, gui_FavBtnPath
	}
}
return

f_FavEditName:
GuiControlGet, gui_FavEditName
TV_Modify(gui_FavTreeSelected, "", gui_FavEditName)
return

f_FavEditPath:
GuiControlGet, gui_FavEditPath
gui_FavTreePath%gui_FavTreeSelected% = %gui_FavEditPath%

return

f_FavTreeCreateItem(ParentID, ParentVarName, Item)
{
	Global
	if ParentID =
		return "empty"
	if ParentVarName =
		return "empty"
	if Item =
		return "empty"
	Local ItemName, ItemPath, ItemVarName, ItemID, ItemIconPath, ItemIconIndex, ItemIconID
;	Tooltip, Loading... Menu %ParentVarName%`, Item %Item%
	if SubStr(Item, 1, 1) = ":" ; submenu
	{
		if InStr(Item, "|")
		{
			StringTrimLeft, Item, Item, 1	; trim ':'
			f_Split2(Item, "|", ItemName, ItemPath)
			ItemName = %ItemName%
			ItemPath = %ItemPath%
			ItemVarName := ParentVarName . "@" . f_TrimVarName(ItemName) ; name used in var
			if gui_FavTreeID%ItemVarName% = ; this submenu not exist
			{
				f_Split2(f_GetIcon("Menu"), ",", ItemIconPath, ItemIconIndex)
				if ItemIconIndex > 0 ; dont change negative index
					ItemIconIndex++
				ItemIconID := IL_Add(gui_FavImageList, ItemIconPath, ItemIconIndex)
				ItemID := TV_Add(ItemName, ParentID, "Icon" . ItemIconID)
				gui_FavTreeID%ItemVarName% := ItemID ; this group id
				gui_FavTreePath%ItemID% := "" ; blank path for group item
				gui_FavTreeIcon%ItemID% := ItemIconID ; this group icon id
				gui_FavTreeParentList = %gui_FavTreeParentList%%ItemVarName%`n
			}
			f_FavTreeCreateItem(gui_FavTreeID%ItemVarName%, ItemVarName, ItemPath)
		}
		else
		{
			f_Split2(Item, "=", ItemName, ItemPath)
			ItemName = %ItemName%
			ItemPath = %ItemPath%
			ItemIconPath := f_GetIcon(ItemPath)
			f_Split2(ItemIconPath, ",", ItemIconPath, ItemIconIndex)
			if ItemIconPath = This
				ItemIconPath = %ItemPath%
			if ItemIconIndex > 0 ; dont change negative index
				ItemIconIndex++
			SetWorkingDir %ItemPath%
			ItemIconID := IL_Add(gui_FavImageList, ItemIconPath, ItemIconIndex)
			SetWorkingDir %A_ScriptDir%
			ItemID := TV_Add(ItemName, ParentID, "Icon" . ItemIconID)
			gui_FavTreePath%ItemID% := ItemPath
			gui_FavTreeIcon%ItemID% := ItemIconID
		}
	}
	else if Item = -	; separator
	{
		ItemID := TV_Add("-", ParentID, "Icon1000")
		gui_FavTreePath%ItemID% := ""
		gui_FavTreeIcon%ItemID% := "1000"
	}
	else	; a favorite item
	{
		f_Split2(Item, "=", ItemName, ItemPath)

		ItemName = %ItemName%
		ItemPath = %ItemPath%

		if SubStr(ItemPath, 1, 1) = "_" ; special items
		{
			if ItemPath = _ToolAdd
				ItemIconPath = %f_Icons%,-301
			else if ItemPath = _ToolAddHere
				ItemIconPath = %f_Icons%,-301
			else if ItemPath = _ToolReload
				ItemIconPath = %f_Icons%,-302
			else if ItemPath = _ToolOptions
				ItemIconPath = %f_Icons%,-303
			else if ItemPath = _ToolEdit
				ItemIconPath = %f_Icons%,-304
			else if ItemPath = _ToolExit
				ItemIconPath = %f_Icons%,-305
			else if ItemPath = _ToolToggleHidden
				ItemIconPath = %f_Icons%,-302
			else if ItemPath = _ToolToggleFileExt
				ItemIconPath = %f_Icons%,-302
			else if ItemPath = _SystemRecent
				ItemIconPath := f_GetIcon("Recent")
			else if ItemPath = _ExplorerList
				ItemIconPath := f_GetIcon("Explorer")
			else if ItemPath = _DriveList
				ItemIconPath := f_GetIcon("Computer")
			else if ItemPath = _ToolMenu
				ItemIconPath = %f_Icons%
			else if ItemPath = _RecentMenu
				ItemIconPath = %f_Icons%,-307
			else if ItemPath = _SVSMenu
				ItemIconPath = %f_Icons%,-311
			else if ItemPath = _DebugMenu
				ItemIconPath = %f_Icons%,-306
		}
		else
		{
			ItemIconPath := f_GetIcon(ItemPath)
		}
		f_Split2(ItemIconPath, ",", ItemIconPath, ItemIconIndex)
		if ItemIconPath = This
			ItemIconPath = %ItemPath%
		if ItemIconIndex > 0 ; dont change negative index
			ItemIconIndex++
		SetWorkingDir %ItemPath%
		ItemIconID := IL_Add(gui_FavImageList, ItemIconPath, ItemIconIndex)
		SetWorkingDir %A_ScriptDir%
		ItemID := TV_Add(ItemName, ParentID, "Icon" . ItemIconID)
		gui_FavTreePath%ItemID% := ItemPath
		gui_FavTreeIcon%ItemID% := ItemIconID
	}
	return
}

f_WriteFavorites()
{
	Global
	IniDelete, %FloderMenu_iniFile%, Favorites
	FileAppend, [Favorites]`n, %FloderMenu_iniFile%
	TVX_Walk(0, "f_FavTreeSaveH", gui_FavTreeEvent, gui_FavTreeEventItem)
	return
}

f_FavTreeSaveH:
f_FavTreeSave(gui_FavTreeEvent, gui_FavTreeEventItem)
return

f_FavTreeSave(Event, Item)
{
	Global
	Local ItemName, ItemPath
	TV_GetText(ItemName, Item)
	if Event = + ; start
	{
	}
	if Event = M ; enter group
	{
		gui_FavTreeEventMenu = %gui_FavTreeEventMenu%:%ItemName%|
		if gui_FavTreeEventMenu = :Menu|
			gui_FavTreeEventMenu =
	}
	if Event = I ; item
	{
		s_FavoritesCount++
		if ItemName = -
		{
			FileAppend, %gui_FavTreeEventMenu%-`n, %FloderMenu_iniFile%
		}
		else
		{
			ItemPath := gui_FavTreePath%Item%
			FileAppend, %gui_FavTreeEventMenu%%ItemName% = %ItemPath%`n, %FloderMenu_iniFile%

		}
	}
	if Event = E ; exit group
	{
		StringTrimRight, gui_FavTreeEventMenu, gui_FavTreeEventMenu, % StrLen(ItemName)+2
	}
	if Event = - ; end
	{
		gui_FavTreeEventMenu =
	}
	return
}

f_FavBrowseFolder:
GuiControlGet, gui_FavEditPath
gui_FavEditPath := f_DerefPath(gui_FavEditPath)
FileSelectFolder, gui_FavEditPath, *%gui_FavEditPath%, , Select Folder
if gui_FavEditPath !=
{
	GuiControl, 88:  , gui_FavEditPath, %gui_FavEditPath%
	gui_FavEditName := f_GetName(gui_FavEditPath)
	GuiControl, 88:  , gui_FavEditName, %gui_FavEditName%
	f_Split2(f_GetIcon(gui_FavEditPath), ",", gui_FavEditIconPath, gui_FavEditIconIndex)
	if gui_FavEditIconPath = This
		gui_FavEditIconPath := gui_FavEditPath
	if gui_FavEditIconIndex > 0 ; dont change negative index
		gui_FavEditIconIndex++
	gui_FavTreeIcon%gui_FavTreeSelected% := IL_Add(gui_FavImageList, gui_FavEditIconPath, gui_FavEditIconIndex)
	TV_Modify(gui_FavTreeSelected, "Icon" . gui_FavTreeIcon%gui_FavTreeSelected%)
}
return

f_FavBrowseFile:
GuiControlGet, gui_FavEditPath
gui_FavEditPath := f_DerefPath(gui_FavEditPath)
FileSelectFile, gui_FavEditPath, , %gui_FavEditPath%, Select File
if gui_FavEditPath !=
{
	GuiControl, 88:  , gui_FavEditPath, %gui_FavEditPath%
	gui_FavEditName := f_GetName(gui_FavEditPath)
	GuiControl, 88:  , gui_FavEditName, %gui_FavEditName%
	f_Split2(f_GetIcon(gui_FavEditPath), ",", gui_FavEditIconPath, gui_FavEditIconIndex)
	if gui_FavEditIconPath = This
		gui_FavEditIconPath := gui_FavEditPath
	if gui_FavEditIconIndex > 0 ; dont change negative index
		gui_FavEditIconIndex++
	gui_FavTreeIcon%gui_FavTreeSelected% := IL_Add(gui_FavImageList, gui_FavEditIconPath, gui_FavEditIconIndex)
	TV_Modify(gui_FavTreeSelected, "Icon" . gui_FavTreeIcon%gui_FavTreeSelected%)
}
return

f_FavBtnPath:
Menu, FavBtnPath, Show
return

f_FavPathSpecial:
GuiControl, 88:  , gui_FavEditName, %A_ThisMenuItem%
if A_ThisMenuItem = 我的电脑
{
	GuiControl, 88:  , gui_FavEditPath, Computer
	gui_FavEditIconPath := f_GetIcon("Computer")
}
else if A_ThisMenuItem = 添加到Favorite
{
	GuiControl, 88:  , gui_FavEditPath, _ToolAdd
	gui_FavEditIconPath = %f_Icons%,-301
}
else if A_ThisMenuItem = 添加 Favorite 到此
{
	GuiControl, 88:  , gui_FavEditPath, _ToolAddHere
	gui_FavEditIconPath = %f_Icons%,-301
}
else if A_ThisMenuItem = 重启
{
	GuiControl, 88:  , gui_FavEditPath, _ToolReload
	gui_FavEditIconPath = %f_Icons%,-302
}
else if A_ThisMenuItem = Folder Menu 选项
{
	GuiControl, 88:  , gui_FavEditPath, _ToolOptions
	gui_FavEditIconPath = %f_Icons%,-303
}
else if A_ThisMenuItem = 编辑配置文件
{
	GuiControl, 88:  , gui_FavEditPath, _ToolEdit
	gui_FavEditIconPath = %f_Icons%,-304
}
else if A_ThisMenuItem = 退出
{
	GuiControl, 88:  , gui_FavEditPath, _ToolExit
	gui_FavEditIconPath = %f_Icons%,-305
}
else if A_ThisMenuItem = 切换隐藏文件
{
	GuiControl, 88:  , gui_FavEditPath, _ToolToggleHidden
	gui_FavEditIconPath = %f_Icons%,-302
}
else if A_ThisMenuItem = 切换文件扩展名
{
	GuiControl, 88:  , gui_FavEditPath, _ToolToggleFileExt
	gui_FavEditIconPath = %f_Icons%,-302
}
else if A_ThisMenuItem = 我最近的文档
{
	GuiControl, 88:  , gui_FavEditPath, _SystemRecent
	gui_FavEditIconPath := f_GetIcon("Recent")
}
else if A_ThisMenuItem = 资源管理器列表
{
	GuiControl, 88:  , gui_FavEditPath, _ExplorerList
	gui_FavEditIconPath := f_GetIcon("Explorer")
}
else if A_ThisMenuItem = 盘符列表
{
	GuiControl, 88:  , gui_FavEditPath, _DriveList
	gui_FavEditIconPath := f_GetIcon("Computer")
}
else if A_ThisMenuItem = 工具菜单
{
	GuiControl, 88:  , gui_FavEditPath, _ToolMenu
	gui_FavEditIconPath = %f_Icons%
}
else if A_ThisMenuItem = 最近使用的项目
{
	GuiControl, 88:  , gui_FavEditPath, _RecentMenu
	gui_FavEditIconPath = %f_Icons%,-307
}
else if A_ThisMenuItem = SVS 菜单
{
	GuiControl, 88:  , gui_FavEditPath, _SVSMenu
	gui_FavEditIconPath = %f_Icons%,-311
}
else if A_ThisMenuItem = 分隔符
{
	GuiControl, 88:  , gui_FavEditName, -
	GuiControl, 88:  , gui_FavEditPath
	gui_FavTreeIcon%gui_FavTreeSelected% := 1000
	TV_Modify(gui_FavTreeSelected, "Icon1000")
	return
}
f_Split2(gui_FavEditIconPath, ",", gui_FavEditIconPath, gui_FavEditIconIndex)
if gui_FavEditIconIndex > 0 ; dont change negative index
	gui_FavEditIconIndex++
gui_FavTreeIcon%gui_FavTreeSelected% := IL_Add(gui_FavImageList, gui_FavEditIconPath, gui_FavEditIconIndex)
TV_Modify(gui_FavTreeSelected, "Icon" . gui_FavTreeIcon%gui_FavTreeSelected%)
return

;==================== Apps List ====================;
f_AddOtherApps:
GuiControlGet, gui_AppsAddName
Loop, Parse, gui_AppsAddName, `,
{
	gui_AppsListBox = |%gui_AppsListBox%|
	if InStr(gui_AppsListBox, "|" . A_LoopField . "|") ; already exist
	{
		StringTrimLeft, gui_AppsListBox, gui_AppsListBox, 1
		StringTrimRight, gui_AppsListBox, gui_AppsListBox, 1
	}
	else ; not exist
	{
		StringTrimLeft, gui_AppsListBox, gui_AppsListBox, 1
		StringTrimRight, gui_AppsListBox, gui_AppsListBox, 1
		if gui_AppsListBox !=
			gui_AppsListBox = %A_LoopField%|%gui_AppsListBox%
		else
			gui_AppsListBox = %A_LoopField%
	}
}
GuiControl, 88:  , gui_AppsListBox, |%gui_AppsListBox%
GuiControl, 88:  , gui_AppsAddName
GuiControl, 88:  Focus, gui_AppsAddName
return

f_DelOtherApps:
GuiControlGet, gui_AppsDelName, , gui_AppsListBox
gui_AppsListBox = |%gui_AppsListBox%|
StringReplace, gui_AppsListBox, gui_AppsListBox, |%gui_AppsDelName%|, |
StringTrimLeft, gui_AppsListBox, gui_AppsListBox, 1
StringTrimRight, gui_AppsListBox, gui_AppsListBox, 1
GuiControl, 88:  , gui_AppsListBox, |%gui_AppsListBox%
GuiControl, 88:  Choose, gui_AppsListBox, 1
GuiControl, 88:  Focus, gui_AppsListBox
return



;==================== Icons ListView ====================;
f_NoMenuIcon:
GuiControlGet, s_NoMenuIcon
GuiControl, 88:  , gui_IconAdd
LV_Modify(LV_GetNext(), "-Select -Focus")
GuiControl, 88:  Disable%s_NoMenuIcon%, s_IconSize
GuiControl, 88:  Disable%s_NoMenuIcon%, gui_IconLV
GuiControl, 88:  Disable%s_NoMenuIcon%, gui_IconAdd
return

f_IconAdd:
GuiControlGet, gui_IconAdd
if gui_IconAdd =
	return
Loop, % s_IconsCount
{
	LV_GetText(gui_IconLV, A_Index, 2)
	if gui_IconLV = %gui_IconAdd% ; exist, select and return
	{
		LV_Modify(A_Index, "Select Focus")
		GuiControl, 88:  , gui_IconAdd
		GuiControl, 88:  Focus, gui_IconLV
		return
	}
}
s_IconsCount++ ; not exist, add it
GuiControlGet, s_Icons%s_IconsCount%Ext, , gui_IconAdd
f_PickIconDlg(s_Icons%s_IconsCount%Path, s_Icons%s_IconsCount%Index)
LV_Add("Icon" . IL_Add(gui_IconImageList, s_Icons%s_IconsCount%Path, s_Icons%s_IconsCount%Index+1), "", s_Icons%s_IconsCount%Ext, s_Icons%s_IconsCount%Path . "," . s_Icons%s_IconsCount%Index)
GuiControl, 88:  , gui_IconAdd
GuiControl, 88:  Focus, gui_IconAdd
return

f_IconDel:
gui_IconSelected := LV_GetNext()
if gui_IconSelected = 0
	return
LV_Delete(gui_IconSelected)
f_IconListDelete(gui_IconSelected)
if gui_IconSelected > %s_IconsCount%
	gui_IconSelected = %s_IconsCount%
LV_Modify(gui_IconSelected, "Select Focus")
GuiControl, 88:  Focus, gui_IconLV
return

f_IconListDelete(index)
{
	Global
	Local Extension = s_Icons%index%Ext
	s_IconsDeleteList = %s_IconsDeleteList%%Extension%`n
	Loop, % s_IconsCount-index+1
	{
		Local index1 := index+1
		s_Icons%index%Ext := s_Icons%index1%Ext
		s_Icons%index%Path := s_Icons%index1%Path
		s_Icons%index%Index := s_Icons%index1%Index
		index++
	}
	s_IconsCount--
	return
}

f_IconLV:
if A_GuiEvent = A
	Gosub, f_IconEdit
else if A_GuiEvent = K
{
	if A_EventInfo = 45 ; ins key
		Gosub, f_IconAdd
	if A_EventInfo = 46 ; del key
		Gosub, f_IconDel
}
return

f_IconEdit:
gui_IconSelected := LV_GetNext()
if gui_IconSelected = 0
	return
f_PickIconDlg(s_Icons%gui_IconSelected%Path, s_Icons%gui_IconSelected%Index)
LV_Modify(gui_IconSelected, "Col3", s_Icons%gui_IconSelected%Path . "," . s_Icons%gui_IconSelected%Index)
if s_Icons%gui_IconSelected%Index > 0
	LV_Modify(gui_IconSelected, "Col1 Icon" . IL_Add(gui_IconImageList, s_Icons%gui_IconSelected%Path, s_Icons%gui_IconSelected%Index+1))
else
	LV_Modify(gui_IconSelected, "Col1 Icon" . IL_Add(gui_IconImageList, s_Icons%gui_IconSelected%Path, s_Icons%gui_IconSelected%Index))
return

f_PickIconDlg(ByRef IconPath, ByRef IconIndex)
{
	if IconPath =
		IconPath = shell32.dll
	VarSetCapacity(wIconPath, 260 * 2)
	DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "str", IconPath, "int", -1, "str", wIconPath, "int", 260)
	DllCall("shell32\PickIconDlg", "Uint", 0, "str", wIconPath, "Uint", 260, "intP", IconIndex)
	VarSetCapacity(IconPath, 260)
	DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", wIconPath, "int", -1, "str", IconPath, "int", 260, "Uint", 0, "Uint", 0)
	IconPath := f_DerefPath(IconPath)
	return
}

f_ReadIcons()
{
	Global
	s_IconsCount = 0
	Local InSection = 0	; check if in the Icons section
	Local A_LoopReadLineFirstChar
	Local IconPath
	Loop, Read, %FloderMenu_iniFile%
	{
		if A_LoopReadLine =	; skip blank lines
			continue
		StringLeft, A_LoopReadLineFirstChar, A_LoopReadLine, 1
		if A_LoopReadLineFirstChar = `;	; skip comments
			continue
		if InSection = 0
		{
			IfInString, A_LoopReadLine, [Icons]	; Icons section start
				InSection = 1
			else
				continue	; Start a new loop iteration.
		}
		else if InSection = 1
		{
			if A_LoopReadLineFirstChar = [	; Another section start
				Break
			else
			{
				IfInString, A_LoopReadLine, NoMenuIcon
					continue
				IfInString, A_LoopReadLine, IconSize
					continue
				s_IconsCount++
				f_Split2(A_LoopReadLine, "=", s_Icons%s_IconsCount%Ext, IconPath)
				IconPath := f_DerefPath(IconPath)
				f_Split2(IconPath, ",", s_Icons%s_IconsCount%Path, s_Icons%s_IconsCount%Index)
			}
		}
	}
	return
}

f_HotkeyHelp:
MsgBox, 68, 快捷键说明, # = Win  ! = Alt  ^ = Ctrl  + = Shift`n`n快捷键前面添加DB表示击键两次`n`n查看更详细的帮助文件?
IfMsgBox Yes
	Run, http://www.autohotkey.com/docs/Hotkeys.htm#Symbols
return

f_HotkeySet1:
gui_HotkeyID = 1
Gosub, f_HotkeySet
return
f_HotkeySet15:
gui_HotkeyID = 15
Gosub, f_HotkeySet
return
f_HotkeySet2:
gui_HotkeyID = 2
Gosub, f_HotkeySet
return
f_HotkeySetJ:
gui_HotkeyID = J
Gosub, f_HotkeySet
return
f_HotkeySetG:
gui_HotkeyID = G
Gosub, f_HotkeySet
return
f_HotkeySetA:
gui_HotkeyID = A
Gosub, f_HotkeySet
return
f_HotkeySetR:
gui_HotkeyID = R
Gosub, f_HotkeySet
return
f_HotkeySetO:
gui_HotkeyID = O
Gosub, f_HotkeySet
return
f_HotkeySetE:
gui_HotkeyID = E
Gosub, f_HotkeySet
return
f_HotkeySetX:
gui_HotkeyID = X
Gosub, f_HotkeySet
return

f_HotkeySet:
Gui, 77:Destroy
if gui_HotkeyDDL =
{
	gui_HotkeyDDL := "A||B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|"
	gui_HotkeyDDL .= "0|1|2|3|4|5|6|7|8|9|0|``|-|=|[|]|`\|;|'|,|.|/|"
	gui_HotkeyDDL .= "F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|F13|F14|F15|F16|F17|F18|F19|F20|F21|F22|F23|F24|"
	gui_HotkeyDDL .= "Space|Tab|Enter|Escape|Backspace|Delete|Insert|Home|End|PgUp|PgDn|Up|Down|Left|Right|"
	gui_HotkeyDDL .= "ScrollLock|CapsLock|NumLock|PrintScreen|CtrlBreak|Pause|Break|"
	gui_HotkeyDDL .= "Numpad0|Numpad1|Numpad2|Numpad3|Numpad4|Numpad5|Numpad6|Numpad7|Numpad8|Numpad9|"
	gui_HotkeyDDL .= "NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub|NumpadEnter|"
	gui_HotkeyDDL .= "LButton|RButton|MButton|WheelDown|WheelUp|WheelLeft|WheelRight|XButton1|XButton2|"
	gui_HotkeyDDL .= "Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|"
	gui_HotkeyDDL .= "Volume_Mute|Volume_Down|Volume_Up|"
	gui_HotkeyDDL .= "Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|"
	gui_HotkeyDDL .= "Launch_Mail|Launch_Media|Launch_App1|Launch_App2|"
}
GuiControlGet, gui_HotkeyText, , s_Hotkey%gui_HotkeyID%
Gui, 77:Default
Gui, Add, Text, Section, % "快捷键: "
Gui, Add, Text, x+5 yp w120 vgui_HotkeyText, %gui_HotkeyText%
Gui, Add, CheckBox, h20 vgui_HotkeyW gf_HotkeyText xs Section, Win
Gui, Add, CheckBox, h20 vgui_HotkeyA gf_HotkeyText, Alt
Gui, Add, CheckBox, h20 vgui_HotkeyC gf_HotkeyText, Ctrl
Gui, Add, CheckBox, h20 vgui_HotkeyS gf_HotkeyText, Shift
Gui, Add, CheckBox, h20 vgui_HotkeyD gf_HotkeyText ys, 双击
Gui, Add, CheckBox, h20 vgui_HotkeyN gf_HotkeyText , 保留原有功能
Gui, Add, DropDownList, w130 vgui_Hotkey gf_HotkeyText, %gui_HotkeyDDL%
Gui, Add, Button, w60 Section Default gf_HotkeyOK, 确定
Gui, Add, Button, w60 ys                gf_HotkeyCancel, 取消
Gui, +AlwaysOnTop -Caption +Border +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
if InStr(gui_HotkeyText, "~")
	GuiControl, 77:,gui_HotkeyN, 1
if InStr(gui_HotkeyText, "#")
	GuiControl, 77:,gui_HotkeyW, 1
if InStr(gui_HotkeyText, "!")
	GuiControl, 77:,gui_HotkeyA, 1
if InStr(gui_HotkeyText, "^")
	GuiControl, 77:, gui_HotkeyC, 1
if InStr(gui_HotkeyText, "+")
	GuiControl, 77:,gui_HotkeyS, 1
if InStr(gui_HotkeyText, "DB")
	GuiControl, 77:,gui_HotkeyD, 1
StringReplace, gui_HotkeyText, gui_HotkeyText, ~, , All
StringReplace, gui_HotkeyText, gui_HotkeyText, #, , All
StringReplace, gui_HotkeyText, gui_HotkeyText, !, , All
StringReplace, gui_HotkeyText, gui_HotkeyText, ^, , All
StringReplace, gui_HotkeyText, gui_HotkeyText, +, , All
StringReplace, gui_HotkeyText, gui_HotkeyText, DB, , All
GuiControl, 77:ChooseString, gui_Hotkey, %gui_HotkeyText%
Gui, Show
return

f_HotkeyText:
Gui, 77:Submit, NoHide
gui_HotkeyText := gui_Hotkey
if gui_HotkeyN
	gui_HotkeyText := "~" . gui_HotkeyText
if gui_HotkeyW
	gui_HotkeyText := "#" . gui_HotkeyText
if gui_HotkeyA
	gui_HotkeyText := "!" . gui_HotkeyText
if gui_HotkeyC
	gui_HotkeyText := "^" . gui_HotkeyText
if gui_HotkeyS
	gui_HotkeyText := "+" . gui_HotkeyText
if gui_HotkeyD
	gui_HotkeyText := "DB" . gui_HotkeyText
GuiControl, , gui_HotkeyText, %gui_HotkeyText%
return

f_HotkeyOK:
Gosub, f_HotkeyText
s_Hotkey%gui_HotkeyID% := gui_HotkeyText
GuiControl,88:, s_Hotkey%gui_HotkeyID%, %gui_HotkeyText%
Gui, 77:Destroy
return

f_HotkeyCancel:
77GuiEscape:
Gui, 77:Destroy
return