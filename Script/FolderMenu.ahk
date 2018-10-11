f_ReadConfig()
{
	Global
	; applications
	IniRead, s_Apps_Explorer  , %FloderMenu_iniFile%, Applications, Explorer      , 1 ; all enabled by default
	IniRead, s_Apps_Dialog    , %FloderMenu_iniFile%, Applications, Dialog        , 1
	IniRead, s_Apps_Command   , %FloderMenu_iniFile%, Applications, Command       , 1
	IniRead, s_Apps_7z        , %FloderMenu_iniFile%, Applications, 7Zip          , 1
	IniRead, s_Apps_Fz3       , %FloderMenu_iniFile%, Applications, FileZilla3    , 1
	IniRead, s_Apps_TC        , %FloderMenu_iniFile%, Applications, TotalCommander, 1
	IniRead, s_Apps_FC        , %FloderMenu_iniFile%, Applications, FreeCommander , 1
	IniRead, s_Apps_Emacs     , %FloderMenu_iniFile%, Applications, Emacs         , 1
	IniRead, s_Apps_rxvt      , %FloderMenu_iniFile%, Applications, rxvt          , 1
	IniRead, s_Apps_Desktop   , %FloderMenu_iniFile%, Applications, Desktop       , 1
	IniRead, s_Apps_Others    , %FloderMenu_iniFile%, Applications, OtherApps     , 1
	IniRead, s_Apps_OthersList, %FloderMenu_iniFile%, Applications, OtherAppsList , %A_Space%

	; icons
	IniRead, s_NoMenuIcon, %FloderMenu_iniFile%, Icons, NoMenuIcon, 0
	IniRead, s_IconSize  , %FloderMenu_iniFile%, Icons, IconSize  , %A_Space%

	; others
	IniRead, s_MaxDepth     , %FloderMenu_iniFile%, Others, MaxDepth     , 2
	IniRead, s_DontKillReg  , %FloderMenu_iniFile%, Others, DontKillReg  , 0
	IniRead, s_BrowseMode   , %FloderMenu_iniFile%, Others, BrowseMode   , 0
	IniRead, s_HideExt      , %FloderMenu_iniFile%, Others, HideExt      , 0
	IniRead, s_CheckItmePath, %FloderMenu_iniFile%, Others, CheckItmePath, 0
	IniRead, s_TrayIconClick, %FloderMenu_iniFile%, Others, TrayIconClick, 2 ; show menu 1.5
	IniRead, s_AddFavBottom , %FloderMenu_iniFile%, Others, AddFavBottom , 0
	IniRead, s_AddFavSkipGUI, %FloderMenu_iniFile%, Others, AddFavSkipGUI, 0
	IniRead, s_AddFavReplace, %FloderMenu_iniFile%, Others, AddFavReplace, 0
	IniRead, s_TempShowAll  , %FloderMenu_iniFile%, Others, TempShowAll  , 0
	IniRead, s_ShowFileExt  , %FloderMenu_iniFile%, Others, ShowFileExt  , *
	IniRead, s_AltFolderIcon, %FloderMenu_iniFile%, Others, AltFolderIcon, 1
	IniRead, s_MenuPosition , %FloderMenu_iniFile%, Others, MenuPosition , 1 ; relative to screen
	IniRead, s_MenuPositionX, %FloderMenu_iniFile%, Others, MenuPositionX, %A_Space%
	IniRead, s_MenuPositionY, %FloderMenu_iniFile%, Others, MenuPositionY, %A_Space%

	; rececnts
	IniRead, s_RecentSize       , %FloderMenu_iniFile%, Recents, RecentSize       , 10
	IniRead, s_RecentSizeS      , %FloderMenu_iniFile%, Recents, RecentSizeS      , 10
	IniRead, s_RecentOnlyFolder , %FloderMenu_iniFile%, Recents, RecentOnlyFolder , 0
	IniRead, s_RecentOnlyFolderS, %FloderMenu_iniFile%, Recents, RecentOnlyFolderS, 0
    IniRead, s_RecentShowIndex  , %FloderMenu_iniFile%, Recents,  RecentShowIndex  , 1

	; hotkeys
	IniRead, s_Hotkey1, %FloderMenu_iniFile%, Hotkeys, Hotkey1 ,%A_Space%
	IniRead, s_Hotkey15,%FloderMenu_iniFile%, Hotkeys, Hotkey15,%A_Space%
	IniRead, s_Hotkey2, %FloderMenu_iniFile%, Hotkeys, Hotkey2 ,%A_Space%
	IniRead, s_HotkeyJ, %FloderMenu_iniFile%, Hotkeys, OpenSel ,%A_Space%
	IniRead, s_HotkeyG, %FloderMenu_iniFile%, Hotkeys, AddApp ,%A_Space%
	IniRead, s_HotkeyA, %FloderMenu_iniFile%, Hotkeys, AddFav ,%A_Space%
	IniRead, s_HotkeyR, %FloderMenu_iniFile%, Hotkeys, Reload ,%A_Space%
	IniRead, s_HotkeyO, %FloderMenu_iniFile%, Hotkeys, Options ,%A_Space%
	IniRead, s_HotkeyE, %FloderMenu_iniFile%, Hotkeys, Edit ,%A_Space%
	IniRead, s_HotkeyX, %FloderMenu_iniFile%, Hotkeys, Exit ,%A_Space%

;	StartTime := A_TickCount
	f_ReadFavorites()
;	ElapsedTime := A_TickCount - StartTime
;	MsgBox,  %ElapsedTime% milliseconds have elapsed.
	return
}

f_SetConfig()
{
	Global

	; Class name in
	f_SupportApps =
	if s_Apps_Explorer
		f_SupportApps = %f_SupportApps%,CabinetWClass,ExploreWClass
	if s_Apps_Dialog
		f_SupportApps = %f_SupportApps%,#32770
	if s_Apps_Command
		f_SupportApps = %f_SupportApps%,ConsoleWindowClass
	if s_Apps_7z
		f_SupportApps = %f_SupportApps%,FM
	if s_Apps_Fz3
		f_SupportApps = %f_SupportApps%,wxWindowClassNR
	if s_Apps_TC
		f_SupportApps = %f_SupportApps%,TTOTAL_CMD
	if s_Apps_FC
		f_SupportApps = %f_SupportApps%,TfcForm
	if s_Apps_Emacs
		f_SupportApps = %f_SupportApps%,Emacs
	if s_Apps_Desktop
		f_SupportApps = %f_SupportApps%,Progman,WorkerW
	if s_Apps_Others
		f_SupportApps = %f_SupportApps%,%s_Apps_OthersList%
	if SubStr(f_SupportApps, 1, 1) = ","
		StringTrimLeft, f_SupportApps, f_SupportApps, 1
	; Class name contains
	f_SupportAppsC =
	if s_Apps_Dialog
		f_SupportAppsC = %f_SupportAppsC%,bosa_sdm_
	if s_Apps_rxvt
		f_SupportAppsC = %f_SupportAppsC%,rxvt
	if SubStr(f_SupportAppsC, 1, 1) = ","
		StringTrimLeft, f_SupportAppsC, f_SupportAppsC, 1

	; disable old hotkeys
	Hotkey, %f_Hotkey1%, Off, UseErrorLevel
	Hotkey, %f_Hotkey15%,Off, UseErrorLevel
	Hotkey, %f_Hotkey2%, Off, UseErrorLevel
	Hotkey, %f_HotkeyJ%, Off, UseErrorLevel
	Hotkey, %f_HotkeyG%, Off, UseErrorLevel
	Hotkey, %f_HotkeyA%, Off, UseErrorLevel
	Hotkey, %f_HotkeyR%, Off, UseErrorLevel
	Hotkey, %f_HotkeyO%, Off, UseErrorLevel
	Hotkey, %f_HotkeyE%, Off, UseErrorLevel
	Hotkey, %f_HotkeyX%, Off, UseErrorLevel

	f_Hotkey1 := s_Hotkey1
	f_Hotkey15:= s_Hotkey15
	f_Hotkey2 := s_Hotkey2
	f_HotkeyJ := s_HotkeyJ
	f_HotkeyG := s_HotkeyG
	f_HotkeyA := s_HotkeyA
	f_HotkeyR := s_HotkeyR
	f_HotkeyO := s_HotkeyO
	f_HotkeyE := s_HotkeyE
	f_HotkeyX := s_HotkeyX

	f_SetHotkey("Show Menu 1"       , f_Hotkey1, "f_DisplayMenu1" )
	f_SetHotkey("Show Menu 1.5"     , f_Hotkey15,"f_DisplayMenu15")
	f_SetHotkey("Show Menu 2"       , f_Hotkey2, "f_DisplayMenu2" )
	f_SetHotkey("Open Selected Text", f_HotkeyJ, "f_OpenSel"      )
	f_SetHotkey("Add Application"   , f_HotkeyG, "f_AddApp"       )
	f_SetHotkey("Add Favorite"      , f_HotkeyA, "f_AddFavoriteK" )
	f_SetHotkey("Reload"            , f_HotkeyR, "f_ToolReload"   )
	f_SetHotkey("Options"           , f_HotkeyO, "f_ToolOptions"  )
	f_SetHotkey("Edit"              , f_HotkeyE, "f_ToolEdit"     )
	f_SetHotkey("Exit"              , f_HotkeyX, "f_ToolExit"     )

	; enable hotkeys that doesn't change
	Hotkey, %f_Hotkey1%, On, UseErrorLevel
	Hotkey, %f_Hotkey15%,On, UseErrorLevel
	Hotkey, %f_Hotkey2%, On, UseErrorLevel
	Hotkey, %f_HotkeyJ%, On, UseErrorLevel
	Hotkey, %f_HotkeyG%, On, UseErrorLevel
	Hotkey, %f_HotkeyA%, On, UseErrorLevel
	Hotkey, %f_HotkeyR%, On, UseErrorLevel
	Hotkey, %f_HotkeyO%, On, UseErrorLevel
	Hotkey, %f_HotkeyE%, On, UseErrorLevel
	Hotkey, %f_HotkeyX%, On, UseErrorLevel

	if s_TrayIconClick = 1
		Hotkey, #!+^x, f_DisplayMenu1, UseErrorLevel
	else if s_TrayIconClick = 2
		Hotkey, #!+^x, f_DisplayMenu15, UseErrorLevel
	else if s_TrayIconClick = 3
		Hotkey, #!+^x, f_DisplayMenu2, UseErrorLevel

	if s_TrayIconClick = 1
		Menu, Tray, Add, &Folder Menu, f_DisplayMenu1
	else if s_TrayIconClick = 2
		Menu, Tray, Add, &Folder Menu, f_DisplayMenu15
	else if s_TrayIconClick = 3
		Menu, Tray, Add, &Folder Menu, f_DisplayMenu2

	TrayTip ; remove old one
	if f_ErrorMsg !=
	{
		TrayTip, !, %f_ErrorMsg%, , 1
		f_ErrorMsg =
	}

	return
}

f_SetHotkey(Name, ByRef Hotkey, Label)
{
	Global
	if Hotkey !=
	{
		if SubStr(Hotkey, 1, 2) = "DB"
		{
			StringTrimLeft, Hotkey, Hotkey, 2
			Hotkey, %Hotkey%, %Label%DB, UseErrorLevel
		}
		else
		{
			Hotkey, %Hotkey%, %Label%, UseErrorLevel
		}
		if ErrorLevel in 2,3,4
			f_ErrorMsg = %f_ErrorMsg%Hotkey [%Name%] error. (%ErrorLevel%)`n
	}
	return
}

f_ReadFavorites()
{
	Global
;	ToolTip, Loading...
	Menu, MainMenu, Add
	Menu, MainMenu, DeleteAll
	i_MainMenuItemPos = 1
	s_FavoritesCount = 0
	Local InFavSection = 0	; check if in the favorites section
	Local A_LoopReadLineFirstChar
	Loop, Read, %FloderMenu_iniFile%
	{
		if A_LoopReadLine =	; skip blank lines
			continue
		StringLeft, A_LoopReadLineFirstChar, A_LoopReadLine, 1
		if A_LoopReadLineFirstChar = `;	; skip comments
			continue
		if InFavSection = 0
		{
			IfInString, A_LoopReadLine, [Favorites]	; Favorites section start
				InFavSection = 1
			else
				continue	; Start a new loop iteration.
		}
		else if InFavSection = 1
		{
			if A_LoopReadLineFirstChar = [	; Another section start
				Break
			else
			{
;				Tooltip, Loading... Item %A_Index%

				Local ThisName, ThisPath, ThisItem
				f_Split2(A_LoopReadLine, "=", ThisName, ThisPath)
				ThisPath = %ThisPath%
				if s_CheckItmePath
				{
					ThisItem := f_ItemPathExist(ThisPath)
					if ThisItem
						MsgBox, 48, 警告, 菜单 [%ThisName%] 的路径重复.`n`n(%ThisItem%)
				}

				s_FavoritesCount++
				s_Favorites%s_FavoritesCount% = %A_LoopReadLine%
				f_CreateMenuItem("MainMenu", A_LoopReadLine)
			}
		}
	}
;	ToolTip
	return
}

f_WriteConfig()
{
	Global
	; applications
	IniWrite, %s_Apps_Explorer%   , %FloderMenu_iniFile%, Applications, Explorer
	IniWrite, %s_Apps_Dialog%     , %FloderMenu_iniFile%, Applications, Dialog
	IniWrite, %s_Apps_Command%    , %FloderMenu_iniFile%, Applications, Command
	IniWrite, %s_Apps_7z%         , %FloderMenu_iniFile%, Applications, 7Zip
	IniWrite, %s_Apps_Fz3%        , %FloderMenu_iniFile%, Applications, FileZilla3
	IniWrite, %s_Apps_TC%         , %FloderMenu_iniFile%, Applications, TotalCommander
	IniWrite, %s_Apps_FC%         , %FloderMenu_iniFile%, Applications, FreeCommander
	IniWrite, %s_Apps_Emacs%      , %FloderMenu_iniFile%, Applications, Emacs
	IniWrite, %s_Apps_rxvt%       , %FloderMenu_iniFile%, Applications, rxvt
	IniWrite, %s_Apps_Desktop%    , %FloderMenu_iniFile%, Applications, Desktop
	IniWrite, %s_Apps_Others%     , %FloderMenu_iniFile%, Applications, OtherApps
	IniWrite, %s_Apps_OthersList% , %FloderMenu_iniFile%, Applications, OtherAppsList
	; icons
	IniWrite, %s_NoMenuIcon%      , %FloderMenu_iniFile%, Icons       , NoMenuIcon
	IniWrite, %s_IconSize%        , %FloderMenu_iniFile%, Icons       , IconSize
	f_WriteIcons()
	; others
	IniWrite, %s_DontKillReg%     , %FloderMenu_iniFile%, Others      , DontKillReg
	IniWrite, %s_BrowseMode%      , %FloderMenu_iniFile%, Others      , BrowseMode
	IniWrite, %s_HideExt%         , %FloderMenu_iniFile%, Others      , HideExt
	IniWrite, %s_CheckItmePath%   , %FloderMenu_iniFile%, Others      , CheckItmePath
	IniWrite, %s_TrayIconClick%   , %FloderMenu_iniFile%, Others      , TrayIconClick
	IniWrite, %s_AddFavBottom%    , %FloderMenu_iniFile%, Others      , AddFavBottom
	IniWrite, %s_AddFavSkipGUI%   , %FloderMenu_iniFile%, Others      , AddFavSkipGUI
	IniWrite, %s_AddFavReplace%   , %FloderMenu_iniFile%, Others      , AddFavReplace
	IniWrite, %s_TempShowAll%     , %FloderMenu_iniFile%, Others      , TempShowAll
	IniWrite, %s_ShowFileExt%     , %FloderMenu_iniFile%, Others      , ShowFileExt
	IniWrite, %s_AltFolderIcon%   , %FloderMenu_iniFile%, Others      , AltFolderIcon
	IniWrite, %s_MaxDepth%        , %FloderMenu_iniFile%, Others      , MaxDepth
	IniWrite, %s_MenuPosition%    , %FloderMenu_iniFile%, Others      , MenuPosition
	IniWrite, %s_MenuPositionX%   , %FloderMenu_iniFile%, Others      , MenuPositionX
	IniWrite, %s_MenuPositionY%   , %FloderMenu_iniFile%, Others      , MenuPositionY
	; recent
	IniWrite, %s_RecentSize%       , %FloderMenu_iniFile%, Recents     , RecentSize
	IniWrite, %s_RecentSizeS%      , %FloderMenu_iniFile%, Recents     , RecentSizeS
	IniWrite, %s_RecentOnlyFolder% , %FloderMenu_iniFile%, Recents     , RecentOnlyFolder
	IniWrite, %s_RecentOnlyFolderS%, %FloderMenu_iniFile%, Recents     , RecentOnlyFolderS
	IniWrite, %s_RecentShowIndex%  , %FloderMenu_iniFile%, Recents     , RecentShowIndex

	; hotkeys
	IniWrite, %s_Hotkey1%        , %FloderMenu_iniFile%, Hotkeys     , Hotkey1
	IniWrite, %s_Hotkey15%       , %FloderMenu_iniFile%, Hotkeys     , Hotkey15
	IniWrite, %s_Hotkey2%        , %FloderMenu_iniFile%, Hotkeys     , Hotkey2
	IniWrite, %s_HotkeyJ%        , %FloderMenu_iniFile%, Hotkeys     , OpenSel
	IniWrite, %s_HotkeyG%        , %FloderMenu_iniFile%, Hotkeys     , AddApp
	IniWrite, %s_HotkeyA%        , %FloderMenu_iniFile%, Hotkeys     , AddFav
	IniWrite, %s_HotkeyR%        , %FloderMenu_iniFile%, Hotkeys     , Reload
	IniWrite, %s_HotkeyO%        , %FloderMenu_iniFile%, Hotkeys     , Options
	IniWrite, %s_HotkeyE%        , %FloderMenu_iniFile%, Hotkeys     , Edit
	IniWrite, %s_HotkeyX%        , %FloderMenu_iniFile%, Hotkeys     , Exit
	; favorites
	f_WriteFavorites()
	return
}

f_WriteIcons()
{
	Global
	Loop, Parse, s_IconsDeleteList, `n
	{
		IniDelete, %FloderMenu_iniFile%, Icons, %A_LoopField%
		f_Icons_%A_LoopField% := ""
	}
	s_IconsDeleteList =
	Local Extension, IconPath
	Loop, % s_IconsCount
	{
		Extension := s_Icons%A_Index%Ext
		IconPath := s_Icons%A_Index%Path . "," . s_Icons%A_Index%Index
		IniWrite, %IconPath%, %FloderMenu_iniFile%, Icons, %Extension%
		f_Icons_%Extension% := IconPath
	}
	return
}



;==================== Display The Menu ====================;

f_DisplayMenu1:
f_Hotkey1_Always = 0
Gosub, f_DisplayMenu
return

f_DisplayMenu15:
f_Hotkey1_Always = 1
Gosub, f_DisplayMenu
return

f_DisplayMenu2:	; Always show menu
; Clear the w_Edit1Pos to do the default action
w_WinID =
w_Class =
w_Edit1Pos =
f_ShowMenu("MainMenu")
return

f_DisplayMenu:
; These first few variables are set here and used by f_OpenFavorite:
WinGet, w_WinID, ID, A
WinGet, w_WinMin, MinMax, ahk_id %w_WinID%
if w_WinMin = -1	; Only detect windows not Minimized.
	return
WinGetClass, w_Class, ahk_id %w_WinID%

; by MILK
; This code checks for the known "dockable" applications/windows so that
; when the user clicks on the icon (instead of pressing the hotkey), the
; app will detect the previous activate window, get its ID and class
; and let it be the FolderMenu target.
if !w_Class ; Windows 7/AHK problem: doesnt return active window
	w_Class = ***

; This is the list of windows classes for the applications that are supposed
; to run FolderMenu.exe from its icons. If any of these classes are detected
; than I know I have to get the previously active window so that the context
; menu works. We can add classes, maybe make it an option in the ini, futurely.
; Currently, it works with Taskbar Tray Icon, Windows QuickLauch,
; Windows 7 Superbar, Windows 7 Notification Icons, ObjectDock Docklet and
; RocketDock. They have all been tested successfully.
f_DockableApps = ***,DockItemClass,DockItemTitleWindow,DockCatcher,DockBackgroundClass,ODIndicator,RocketDock,Shell_TrayWnd,NotifyIconOverflowWindow
if w_Class in %f_DockableApps%
{
	; here we check to see if it is a top level window
	WS_OVERLAPPEDWINDOW := 0x0cf0000
	WS_POPUPWINDOW := 0x80880000
	WinGet, w_WinIDs, List
	Loop, %w_WinIDs%
	{
		w_WinID := w_WinIDs%A_Index%
		WinGet, w_Style, Style, ahk_id %w_WinID%
		WinGet, w_ExStyle, ExStyle, ahk_id %w_WinID%
		; for the window to be considered a valid target we discard non-toplevel windows
		; AND topmost (always on top) windows. We skip the topmost because they are the
		; first to come in the list. Also, topmost windows don't usually have context
		; meaning such as TaskManager, Sidebar, System Monitors, etc.
		if ((w_Style & WS_OVERLAPPEDWINDOW) || (w_Style & WS_POPUPWINDOW)) && !(w_ExStyle & 0x8)
		{
			WinGet, w_WinMin, MinMax, ahk_id %w_WinID%
			if w_WinMin != -1
			{
				WinGetClass, w_Class, ahk_id %w_WinID%
				if w_Class not in %f_DockableApps%
				{
					WinActivate ahk_id %w_WinID%
					break
				}
			}
		}
	}
}

w_Edit1Pos =

; return if not supported
if w_Class not in %f_SupportApps%
	if w_Class not contains %f_SupportAppsC%
	{
		if f_Hotkey1_Always
		{
			w_WinID =
			w_Class =
			w_Edit1Pos =
			f_ShowMenu("MainMenu")
		}
		else
			return
	}

; Vista Explorer
if w_Class = CabinetWClass
{
	ControlGetPos, w_Edit1Pos,,,, Edit1, ahk_id %w_WinID%
	if Vista7	; For new addresbar in Vista or 7
	{
		if w_Edit1Pos =
		{
			Send, !d ; Set focus on addressbar to enable Edit1
			ControlGetPos, w_Edit1Pos,,,, Edit1, ahk_id %w_WinID%
		}
	}
	if w_Edit1Pos !=
		f_ShowMenu("MainMenu")
	return
}
; Dialog, Explorer, Total Commander, Others, FileZilla 3
if w_Class in #32770,ExploreWClass,TTOTAL_CMD,FM,wxWindowClassNR,%s_Apps_OthersList%	; no spaces around ','
{
	ControlGetPos, w_Edit1Pos,,,, Edit1, ahk_id %w_WinID%
	if w_Edit1Pos !=
		f_ShowMenu("MainMenu")
	return
}
; Microsoft Office application
if w_Class contains bosa_sdm_
{
	ControlGetPos, w_Edit1Pos,,,, RichEdit20W2, ahk_id %w_WinID%
	if w_Edit1Pos !=
		f_ShowMenu("MainMenu")
	return
}
; Rxvt command prompt
if w_Class contains rxvt
{
	w_Edit1Pos = 1
	f_ShowMenu("MainMenu")
	return
}
; Command Prompt, Emacs, FreeCommander, Console2
if w_Class in ConsoleWindowClass,Emacs,TfcForm ;,Console_2_Main
{
	w_Edit1Pos = 1
	f_ShowMenu("MainMenu")
	return
}
; Desktop
if w_Class in Progman,WorkerW
{
	w_WinID =
	w_Class =
	w_Edit1Pos =
	f_ShowMenu("MainMenu")
	return
}
; Else don't display menu
return

f_ShowMenu(Menu)
{
	Global
	Local X, Y, W, H
	CoordMode, Mouse , Screen
	if s_MenuPosition = 1 ; relative to screen
	{
		if s_MenuPositionX =
			MouseGetPos, X
		else
			X = %s_MenuPositionX%
		if s_MenuPositionY =
			MouseGetPos, , Y
		else
			Y = %s_MenuPositionY%
	}
	else if s_MenuPosition = 2 ; relative to window
	{
		WinGetPos, X, Y, W, H, A
		if s_MenuPositionX = ; blank, use current mouse position
			MouseGetPos, X
		else if s_MenuPositionX < %W% ; < window width, inside window
			X := X + s_MenuPositionX
		else ; out of window, use window edge
			X := X + W
		if s_MenuPositionY =
			MouseGetPos, , Y
		else if s_MenuPositionY < %H%
			Y := Y + s_MenuPositionY
		else
			Y := Y + H
	}
	CoordMode, Menu , Screen
	Menu, %Menu%, Show, %X%, %Y%
	return
}

;==================== Open Favorite Item ====================;

f_OpenFavorite:
; Fetch the array element that corresponds to the selected menu item:
f_OpenFavPath := i_%A_ThisMenu%Path%A_ThisMenuItemPos%
if f_OpenFavPath =
{
	TrayTip, 错误, 不能打开`n`"%A_ThisMenuItem%`"`n路径为空., , 3
	return
}

if InStr(f_OpenFavPath, "%F_CurrentDir%")
	StringReplace, f_OpenFavPath, f_OpenFavPath, `%F_CurrentDir`%, % f_GetPath(w_WinID, w_Class) . "\", All

if f_OpenFavPath = Computer
	f_OpenFavPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
if (f_OpenFavPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}")
	f_OpenFavPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"

if SubStr(f_OpenFavPath, 1, 1) = "*" ; file filter
{
	; Dialog
	if w_Class = #32770
	{
		WinActivate ahk_id %w_WinID%
		ControlGetText, w_Edit1Text, Edit1, ahk_id %w_WinID%
		ControlClick, Edit1, ahk_id %w_WinID%
		ControlSetText, Edit1, %f_OpenFavPath%, ahk_id %w_WinID%
		ControlSend, Edit1, {Enter}, ahk_id %w_WinID%
		Sleep, 100	; It needs extra time on some dialogs or in some cases.
		ControlSetText, Edit1, %w_Edit1Text%, ahk_id %w_WinID%
	}
	; Microsoft Office application
	else if w_Class contains bosa_sdm_
	{
		WinActivate ahk_id %w_WinID%
		ControlGetText, w_Edit1Text, RichEdit20W2, ahk_id %w_WinID%
		ControlClick, RichEdit20W2, ahk_id %w_WinID%
		ControlSetText, RichEdit20W2, %f_OpenFavPath%, ahk_id %w_WinID%
		ControlSend, RichEdit20W2, {Enter}, ahk_id %w_WinID%
		Sleep, 100
		ControlSetText, RichEdit20W2, %w_Edit1Text%, ahk_id %w_WinID%
	}
	; Command Prompt (thanks to Mr. Milk)
	else if w_Class = ConsoleWindowClass
	{
		StringReplace, f_OpenFavPath, f_OpenFavPath, `;, %A_Space%, All
		f_OpenFavPath := "for /R %a in (" . f_OpenFavPath . ") do @echo %~aa %~ta %~za`t%~Fa"
		WinActivate, ahk_id %w_WinID% ; Because sometimes the mclick deactivates it.
		SetKeyDelay, 0 ; This will be in effect only for the duration of this thread.
		f_SendBig5("cmd.exe /F:OFF")
		Send, {Enter}
		f_SendBig5(f_OpenFavPath)
		Send, {Enter}exit{Enter}
	}
	; Vista Explorer (thanks to Mr. Milk)
	else if Vista7
	{
		if f_OpenFavPath != *.*
		{
			StringReplace, f_OpenFavPath, f_OpenFavPath, *., ext:, All
			StringReplace, f_OpenFavPath, f_OpenFavPath, `;, %A_Space%OR%A_Space%, All
		}
		if w_Class in CabinetWClass
			Send, ^e ; Set focus on searchbox to enable Edit2
		else
		{
			Send, #f ; Open vista search
			WinWaitActive, ahk_class CabinetWClass, , 5
			WinGet, w_WinID, ID
			Sleep, 100
		}
;		ControlSetText, Edit2, %f_OpenFavPath%, ahk_id %w_WinID%
		Send, %f_OpenFavPath%
		WinActivate ahk_id %w_WinID%
	}
	return
}

if InStr(f_OpenFavPath, "svscmd.exe")
{
	if SubStr(f_OpenFavPath, -1) = " D"
		SplashTextOn,,,Deactivating SVS Layer...
	else
		SplashTextOn,,,Activating SVS Layer...
	RunWait, %ThisPath%, , Hide UseErrorLevel
	SplashTextOff
	f_CreateSVSMenu()
	return
}

; if CapsLock is on, use browse mode
if (!s_BrowseMode && GetKeyState("CapsLock", "T")) || (s_BrowseMode && !GetKeyState("CapsLock", "T"))
{
	if (A_ThisMenuItemPos = 2 && A_ThisMenu = "TempMenu") ; current folder item
	{
		f_OpenPath(f_OpenFavPath)
		return
	}
	if (A_ThisMenuItemPos = 1 && A_ThisMenu = "TempMenu" && A_ThisMenuItem != "..\") ; computer item
	{
		f_OpenPath(f_OpenFavPath)
		return
	}
	if InStr(FileExist(f_OpenFavPath), "D") or f_OpenFavPath = """::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"""
	{
		if GetKeyState("Shift")
		{
			if GetKeyState("Ctrl")
				f_OpenTempMenu(f_OpenFavPath, 1)
			else
				f_OpenPath(f_OpenFavPath)
		}
		else if GetKeyState("Ctrl")
			f_OpenPath(f_OpenFavPath)
		else if GetKeyState("RButton")
			f_OpenPath(f_OpenFavPath)
		else
			f_OpenTempMenu(f_OpenFavPath, s_TempShowAll)
		return
	}
}
; Holding ctrl (or shift) (or right mouse button)
; Holding both ctrl and shift for files and folders
if (GetKeyState("Shift") && GetKeyState("Ctrl"))
{
	if f_IsFolder(f_OpenFavPath)
		f_OpenTempMenu(f_OpenFavPath, 1)
	else
		ShellContextMenu(f_OpenFavPath)
}
else if (GetKeyState("Shift") || GetKeyState("Ctrl") || GetKeyState("RButton"))
{
	if f_IsFolder(f_OpenFavPath)
		f_OpenTempMenu(f_OpenFavPath, s_TempShowAll)
	else
		ShellContextMenu(f_OpenFavPath)
}
else
	f_OpenPath(f_OpenFavPath)
return

f_OpenPath(ThisPath)
{
	Global
	if !f_IsFolder(ThisPath) && !FileExist(ThisPath) ; not a folder, file not exist, run it
	{
		if !f_RunPath(ThisPath) ; if no error
			if f_RecentEnabled = 1
				if !s_RecentOnlyFolder ; if recent not only record folders
					f_AddRecent(ThisPath)
		return
	}

	if w_Edit1Pos =
	{
		Run, explore %ThisPath%, , UseErrorLevel	; Might work on more systems without double quotes.
		if ErrorLevel
        f_RunPath(ThisPath)
	}
	else
	{
		; Dialog
		if w_Class = #32770
		{
			; Activate the window so that if the user is middle-clicking
			; outside the dialog, subsequent clicks will also work:
			WinActivate ahk_id %w_WinID%
			; Retrieve any filename that might already be in the field so
			; that it can be restored after the switch to the new folder:
			ControlGetText, w_Edit1Text, Edit1, ahk_id %w_WinID%
			ControlClick, Edit1, ahk_id %w_WinID%
			ControlSetText, Edit1, %ThisPath%, ahk_id %w_WinID%
			ControlSend, Edit1, {Enter}, ahk_id %w_WinID%
			Sleep, 100	; It needs extra time on some dialogs or in some cases.
			ControlSetText, Edit1, %w_Edit1Text%, ahk_id %w_WinID%
		}
		; Explorer
		else if w_Class in CabinetWClass,ExploreWClass
		{
			;ControlClick, Edit1, ahk_id %w_WinID%
			Local PathEdit := f_GetPathEdit(w_WinID)
			ControlSetText, %PathEdit%, %ThisPath%, ahk_id %w_WinID%
			; Tekl reported the following: "If I want to change to Folder L:\folder
			; then the addressbar shows http://www.L:\folder.com. To solve this,
			; I added a {right} before {Enter}":
			ControlSend, %PathEdit%, {Right}{Enter}, ahk_id %w_WinID%
			WinActivate ahk_id %w_WinID%
		}
		; 7-Zip File Manager
		else if w_Class = FM
		{
			MouseGetPos, , , , w_Control
			if w_Control = SysListView322 ; second panel
			{
				ControlSetText, Edit2, %ThisPath%, ahk_id %w_WinID%
				ControlSend, Edit2, {Enter}, ahk_id %w_WinID%
			}
			else
			{
				ControlSetText, Edit1, %ThisPath%, ahk_id %w_WinID%
				ControlSend, Edit1, {Enter}, ahk_id %w_WinID%
			}
		}
		; FileZilla 3
		else if w_Class = wxWindowClassNR
		{
			if InStr(FileExist(ThisPath), "D")
			{
			ControlGetPos, w_Edit1Pos,,,, Edit5, ahk_id %w_WinID%
			if w_Edit1Pos != ; it has quick connect bar, addressbar is edit5
			{
				ControlSetText, Edit5, %ThisPath%, ahk_id %w_WinID%
				ControlSend, Edit5, {Enter}, ahk_id %w_WinID%
			}
			else
			{
				ControlSetText, Edit1, %ThisPath%, ahk_id %w_WinID%
				ControlSend, Edit1, {Enter}, ahk_id %w_WinID%
			}
			ControlFocus, SysListView321, ahk_id %w_WinID% ; Set focus to file list
	        }
	else
				f_RunPath(ThisPath)
	}
		; Microsoft Office application
		else if w_Class contains bosa_sdm_
		{
			WinActivate ahk_id %w_WinID%
			ControlGetText, w_Edit1Text, RichEdit20W2, ahk_id %w_WinID%
			ControlClick, RichEdit20W2, ahk_id %w_WinID%	;<----------important!!!
			ControlSetText, RichEdit20W2, %ThisPath%, ahk_id %w_WinID%
			ControlSend, RichEdit20W2, {Enter}, ahk_id %w_WinID%
			Sleep, 100
			ControlSetText, RichEdit20W2, %w_Edit1Text%, ahk_id %w_WinID%
		}
		; Total Commander (thanks to FatZgrED)
		else if w_Class = TTOTAL_CMD
		{
			;Total Commander has Edit1 control but you need to cd to location
            if InStr(FileExist(ThisPath), "D")
			{
				ControlSetText, Edit1, cd %ThisPath%, ahk_id %w_WinID%
				ControlSend, Edit1, {Enter}, ahk_id %w_WinID%
			}
			else
				f_RunPath(ThisPath)
		}
		; FreeCommander (thanks to catweazle (John))
		else if w_Class = TfcForm
		{
			Send, !g
			ControlClick, TfcPathEdit1, ahk_id %w_WinID%
			ControlSetText, TfcPathEdit1, %ThisPath%, ahk_id %w_WinID%
			ControlSend, TfcPathEdit1, {Enter}, ahk_id %w_WinID%
		}
		; Command Prompt
		else if w_Class = ConsoleWindowClass
    {
		if InStr(FileExist(ThisPath), "D")
		{
			WinActivate, ahk_id %w_WinID%	; Because sometimes the mclick deactivates it.
			SetKeyDelay, 0	; This will be in effect only for the duration of this thread.
			f_SendBig5("cd /d " . ThisPath . "\") ; (thanks to tireless for the /d switch)
			Send, {Enter}
		}
			else
				f_RunPath(ThisPath)
	}
		; Emacs (thanks to catweazle (John))
		else if w_Class = Emacs
		{
			WinActivate, ahk_id %w_WinID%
			SetKeyDelay, 0
			Send, !xfind-file{Enter}
			Send, %ThisPath%{Tab}
		}
		; Rxvt command prompt (thanks to catweazle (John))
		else if w_Class contains rxvt
		{
			if InStr(FileExist(ThisPath), "D")
			{
				WinActivate, ahk_id %w_WinID%
				SetKeyDelay, 0
				Send, cd `'%ThisPath%`'{Enter}
				Send, ls{Enter}
			}
			else
				f_RunPath(ThisPath)
		}
	    ; Others
		else if w_Class in %s_Apps_OthersList%
		{
			if InStr(FileExist(ThisPath), "D")
			{
				ControlSetText, Edit1, %ThisPath%, ahk_id %w_WinID%
				ControlSend, Edit1, {Right}{Enter}, ahk_id %w_WinID%
			}
			else
				f_RunPath(ThisPath)
		}
    }

	if f_RecentEnabled = 1
	{
		if f_IsFolder(ThisPath) ; it's a folder
			f_AddRecent(ThisPath)
		else ; it's file
			if !s_RecentOnlyFolder ; if recent not only record folders
				f_AddRecent(ThisPath)
	}
	return
}

f_RunPath(ThisPath)
{
	Run, %ThisPath%, , UseErrorLevel ; run a file or url
	if ErrorLevel
	{
		if f_OpenReg(ThisPath) ; open reg
		{
			TrayTip, 错误, 不能打开`n`"%ThisPath%`", , 3
			return 1
		}
	}
	return 0
}

f_IsFolder(ThisPath)
{
	if InStr(FileExist(ThisPath), "D")
	|| (ThisPath = """::{20D04FE0-3AEA-1069-A2D8-08002B30309D}""")
	|| SubStr(ThisPath, 1, 2) = "\\"
		return 1
	else
		return 0
}

f_GetPathEdit(ThisID) ; get the classnn of the addressbar, thanks to F1reW1re
{
	WinGetClass, ThisClass, ahk_id %ThisID%
	if ThisClass not in ExploreWClass,CabinetWClass
		return
	ControlGetText, ComboBoxEx321_Content, ComboBoxEx321, ahk_id %ThisID%
	WinGet, ActiveControlList, ControlList, ahk_id %ThisID%
	Loop, Parse, ActiveControlList, `n
	{
		StringLeft, WhichControl, A_LoopField, 4
		if WhichControl = Edit
		{
			ControlGetText, Edit_Content, %A_LoopField%, ahk_id %ThisID%
			if ComboBoxEx321_Content = %Edit_Content%
			{
				return % A_LoopField
			}
		}
	}
	return
}



;==================== Add Favorite ====================;

f_AddFavoriteK:
; use addfav hotkey, get informations from active window
WinGet, w_WinID, ID, A
WinGet, w_WinMin, MinMax, ahk_id %w_WinID%
if w_WinMin = -1	; Only detect windows not Minimized.
	return
WinGetClass, w_Class, ahk_id %w_WinID%
Gosub, f_AddFavorite
return

f_GetPath(WindowID, Class)
{
	Global s_Apps_OthersList
	if Class in #32770
	{
		if Vista7
		{
			ControlGetPos, ToolbarPos,,,, ToolbarWindow322, ahk_id %WindowID%
			if ToolbarPos !=
			{
				Send, !d ; Set focus on addressbar to enable Edit2
				Sleep, 100
				ControlGetText, ThisPath, Edit2, ahk_id %WindowID%
			}
		}
		if ThisPath = ; nothing retrieved, maybe it's an old open/save dialog
		{
			ControlGetText, ThisFolder, ComboBox1, ahk_id %WindowID% ; current folder name
			ControlGet, List, List,, ComboBox1, ahk_id %WindowID% ; list of folders on the path
			Loop, Parse, List, `n ; create array and get position of this folder
			{
				List%A_Index% = %A_LoopField%
				if A_LoopField = %ThisFolder%
					ThisIndex = %A_Index%
			}
			Loop, % ThisIndex ; add path til root
			{
				Index0 := ThisIndex - A_Index + 1 ; ThisIndex ~ 1
				IfInString, List%Index0%, : ; drive root
				{
					ThisPath := SubStr(List%Index0%, InStr(List%Index0%, ":")-1, 2) . "\" . ThisPath
					break
				}
				ThisPath := List%Index0% . "\" . ThisPath
			}
		}
	}
	else if Class in CabinetWClass,ExploreWClass
	{
		if Vista7
		{
			ControlGetPos, ToolbarPos,,,, ToolbarWindow322, ahk_id %WindowID%
			if ToolbarPos !=
			{
				Send, !d ; Set focus on addressbar to enable Edit2
				Sleep, 100
				ControlGetText, ThisPath, ComboBoxEx321, ahk_id %WindowID%
;				ControlGetText, ThisPath, Edit1, ahk_id %WindowID%
			}
		}
		else
			ControlGetText, ThisPath, ComboBoxEx321, ahk_id %WindowID%
;			ControlGetText, ThisPath, Edit1, ahk_id %WindowID%
	}

	else if Class = FM
	{
		MouseGetPos, , , , w_Control
		if w_Control = SysListView322 ; second panel
			ControlGetText, ThisPath, Edit2, ahk_id %WindowID%
		else
			ControlGetText, ThisPath, Edit1, ahk_id %WindowID%
	}
	else if Class = wxWindowClassNR
	{
		ControlGetPos, Edit1Pos,,,, Edit5, ahk_id %WindowsID%
		if Edit1Pos != ; it has quick connect bar, addressbar is edit5
			ControlGetText, ThisPath, Edit5, ahk_id %WindowID%
		else
			ControlGetText, ThisPath, Edit1, ahk_id %WindowID%
	}
	else if Class = TfcForm
	{
		Send, !g
		ControlGetText, ThisPath, TfcPathEdit1, ahk_id %WindowID%
	}
	else if Class = ConsoleWindowClass
	{
		SetKeyDelay, 0	; This will be in effect only for the duration of this thread.
		Send, cd > %Temp%\f_cdtmp{Enter}
		Sleep, 100
		FileReadLine, ThisPath, %Temp%\f_cdtmp, 1
		FileDelete, %Temp%\f_cdtmp
   }
	else if Class in %s_Apps_OthersList%
	{
		ControlGetText, ThisPath, Edit1, ahk_id %WindowID%
    }

	; Remove the trailing backslash.
	if ThisPath !=
		if f_LastIsBackslash(ThisPath)
			StringTrimRight, ThisPath, ThisPath, 1
	return ThisPath
}

f_GetName(ThisPath)
{
	if ThisPath !=
		f_SplitPath(ThisPath, ThisName, a)
	Global s_HideExt
	if s_HideExt
		SplitPath, ThisName, , , , ThisName
	if ThisName =	; if empty, use whole path as name.
		ThisName = %ThisPath%
	return ThisName
}



;==================== Get Win Class Hotkey ====================;

f_AddApp:
WinGet, w_WinID, ID, A
WinGet, w_WinMin, MinMax, ahk_id %w_WinID%
if w_WinMin = -1	; Only detect windows not Minimized.
	return
WinGetTitle, w_Title, ahk_id %w_WinID%
WinGetClass, w_Class, ahk_id %w_WinID%

if f_AddAppEdit1(w_WinID) ; edit1 exist
{
	MsgBox,36,添加应用程序, 标题:`t[%w_Title%]`nClass:`t[%w_Class%]`n`nEdit1 存在!请确认Edit1为该应用程序的地址栏?`n`n是否将该应用程序添加到Folder Menu?
	IfMsgBox Yes
	{
		MsgBox, 36, 添加应用程序, 是否将该应用程序添加到Folder Menu?
		IfMsgBox Yes
			Gosub, f_AddApplication
	}
}
else
{
	MsgBox, 308, 添加应用程序, 标题:`t[%w_Title%]`nClass:`t[%w_Class%]`n`nEdit1 不存在!`n`n是否仍将该应用程序添加到Folder Menu?
	IfMsgBox Yes
		Gosub, f_AddApplication
}
Gui,7:Destroy
return

f_AddAppEdit1(WinID)
{
	WinGetPos, wx, wy, , , ahk_id %WinID%
	ControlGetPos, x, y, w, h, Edit1, ahk_id %WinID%	; Get edit1
	if x = ; edit1 not found
		return 0
	x := wx + x
	y := wy + y
	Gui 7:+LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	Gui,7:Color, FFBBBB
	WinSet, Transparent, 128
	Gui,7:Show, x%x% y%y% w%w% h%h% NoActivate  ; NoActivate avoids deactivating the currently active window.
	return 1
}

f_AddApplication:
;gui_hh = 0
;gui_ww = 0
gui_Tab = 应用程序
Gosub, f_OptionsGUI
GuiControl, ChooseString, gui_Tab, %gui_Tab%
GuiControl, , gui_AppsAddName, %w_Class%
Gosub, f_AddOtherApps
GuiControl, Choose, gui_AppsListBox, 1
GuiControl, Focus, gui_AppsListBox
return



;==================== Open Selected Path Hotkey ====================;

f_OpenSel:
f_ClipSaved := ClipboardAll
Send, ^c
Clipwait
f_OpenSelected(Clipboard)
Clipboard := f_ClipSaved
f_ClipSaved = ; Free the memory in case the clipboard was very large.
return

f_OpenSelected(SelectedPath)
{
	SelectedPath := f_DerefPath(SelectedPath)
	StringReplace, SelectedPath, SelectedPath, , \, All
	; Remove the trailing backslash.
	if f_LastIsBackslash(SelectedPath)
		StringTrimRight, SelectedPath, SelectedPath, 1
	if SelectedPath !=
	{
		Run, explore %SelectedPath%, , UseErrorLevel
		if ErrorLevel
            if f_RunPath(SelectedPath)
			{
				TrayTip, 错误, 不能打开 "%Clipboard%" ., , 3
				return ; don't keep error item
			}
		if f_IsFolder(SelectedPath) ; it's a folder
			f_AddRecent(SelectedPath)
		else
			if !s_RecentOnlyFolder ; if recent not only record folders
				f_AddRecent(SelectedPath)
	}
	return
}



;==================== Functions ====================;

f_Split2(String, Seperator, ByRef LeftStr, ByRef RightStr)
{
	SplitPos := InStr(String, Seperator)
	if SplitPos = 0 ; Seperator not found, L = Str, R = ""
	{
		LeftStr := String
		RightStr:= ""
	}
	else
	{
		SplitPos--
		StringLeft, LeftStr, String, %SplitPos%
		SplitPos++
		StringTrimLeft, RightStr, String, %SplitPos%
	}
	return
}

f_OpenReg(RegPath)
{
	StringLeft, RegPathFirst4, RegPath, 4
	if RegPathFirst4 = HKCR
		StringReplace, RegPath, RegPath, HKCR, HKEY_CLASSES_ROOT
	if RegPathFirst4 = HKCU
		StringReplace, RegPath, RegPath, HKCU, HKEY_CURRENT_USER
	if RegPathFirst4 = HKLM
		StringReplace, RegPath, RegPath, HKLM, HKEY_LOCAL_MACHINE

	StringLeft, RegPathFirst4, RegPath, 4
	if RegPathFirst4 = HKEY
	{
		RegRead, MyComputer, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey
		f_Split2(MyComputer, "\", MyComputer, aaa)
		Global s_DontKillReg
		if !s_DontKillReg
			RunWait, % "cmd.exe /c taskkill /IM regedit.exe", , Hide
		RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, %MyComputer%\%RegPath%
		Run regedit
		return 0
	}
	else
		return 1
}

f_SendBig5(xx) ; Thanks to Lumania @ Ptt
{
	i := StrLen(xx)
	if i=0
		return
	Loop
	{
		tmp1 := NumGet(xx, 0, "UChar")
		if tmp1<128
		{
			i--
			StringTrimLeft, xx, xx, 1
		}
		else
		{
			tmp1 := (tmp1<<8) | NumGet(xx, 1, "UChar")
			i -= 2
			StringTrimLeft, xx, xx, 2
		}
		Send, {ASC %tmp1%}
		if i = 0
			break
	}
}

f_SetMenuIcon(Menu, Item, IconPath, Size="") ; Index start from 0, index included in IconPath
{
	Global s_NoMenuIcon, s_IconSize
	StringReplace, IconPath, IconPath, `", , All
	IconPath := f_DerefPath(IconPath)
	if Size = ; if size not specified, look iconpath for size
	{
		f_Split2(IconPath, "`n", IconPath, Size)
		if Size = ; if still not specified, use default
			Size := s_IconSize
	}
	if !s_NoMenuIcon
	{
		Menu, Tray, UseErrorLevel
		f_Split2(IconPath, ",", IconPath, Index)
		if Index > 0 ; dont change negative index
			Index++ ; index start from 1 for ahk
		Menu, %Menu%, Icon, %Item%, %IconPath%, %Index%, %Size%
;		if ErrorLevel
;			MsgBox, Menu, %Menu%, Icon, %Item%, %IconPath%, %Index%, %Size%
		Menu, Tray, UseErrorLevel, OFF
	}
	return
}

f_DerefPath(ThisPath)
{
	StringReplace, ThisPath, ThisPath, ``, ````, All
;	StringReplace, ThisPath, ThisPath, `%, ```%, All
	StringReplace, ThisPath, ThisPath, `%F_CurrentDir`%, ```%F_CurrentDir```%, All
	Transform, ThisPath, deref, %ThisPath%
	return ThisPath
}

f_GetIcon(ThisPath)
{
	Global
	StringReplace, ThisPath, ThisPath, `", , All
	ThisPath := f_DerefPath(ThisPath)
	if f_LastIsBackslash(ThisPath)
		StringTrimRight, ThisPath, ThisPath, 1
   if SubStr(ThisPath, 1, 2) = "\\" ; UNC
	{
		if f_Icons_Share =
		{
      IniRead, f_Icons_Share, %FloderMenu_iniFile%, Icons, Share, %A_Space%
     if f_Icons_Share =
			    f_Icons_Share = %f_Icons%,-311 ; built-in icon
			f_Icons_Share := f_DerefPath(f_Icons_Share)
		}
		return f_Icons_Share
	}
	else if SubStr(ThisPath, 0) = ":" ; Drive
	{
		if f_Icons_Drive =
		{
			IniRead, f_Icons_Drive, %FloderMenu_iniFile%, Icons, Drive, %A_Space%
			if f_Icons_Drive =
				f_Icons_Drive = %f_Icons%,-309 ; built-in icon
			f_Icons_Drive := f_DerefPath(f_Icons_Drive)
		}
		return f_Icons_Drive
	}
	else if InStr(FileExist(ThisPath), "D") ; Folder
	{
		; read from desktop.ini first
		Local IconPath, IconFile, IconIndex
		IniRead, IconPath, %ThisPath%\Desktop.ini, `.ShellClassInfo, IconResource, %A_Space%
		if IconPath =
		{
			IniRead, IconFile , %ThisPath%\Desktop.ini, `.ShellClassInfo, IconFile , %A_Space%
			IniRead, IconIndex, %ThisPath%\Desktop.ini, `.ShellClassInfo, IconIndex, %A_Space%
			if IconFile !=
				IconPath = %IconFile%,%IconIndex%
		}
		if IconPath !=
		{
			IconPath := f_DerefPath(IconPath)
			return IconPath
		}
		if f_Icons_Folder =
		{
			IniRead, f_Icons_Folder, %FloderMenu_iniFile%, Icons, Folder, %A_Space%
			if f_Icons_Folder =
				f_Icons_Folder = %f_Icons%,-308 ; built-in icon
			f_Icons_Folder := f_DerefPath(f_Icons_Folder)
		}
		return f_Icons_Folder
	}
	else if ThisPath = FolderS ; Folder with subfolders
	{
		if f_Icons_FolderS =
		{
			IniRead, f_Icons_FolderS, %FloderMenu_iniFile%, Icons, FolderS, %A_Space%
			if f_Icons_FolderS =
				f_Icons_FolderS = %f_Icons%,-1 ; built-in icon
			f_Icons_FolderS := f_DerefPath(f_Icons_FolderS)
		}
		return f_Icons_FolderS
	}
	else if ThisPath in Computer,"::{20D04FE0-3AEA-1069-A2D8-08002B30309D}",::{20D04FE0-3AEA-1069-A2D8-08002B30309D}  ; Computer
	{
		if f_Icons_Computer =
		{
			IniRead, f_Icons_Computer, %FloderMenu_iniFile%, Icons, Computer, %A_Space%
			if f_Icons_Computer =
				f_Icons_Computer = %f_Icons%,-310 ; built-in icon
			f_Icons_Computer := f_DerefPath(f_Icons_Computer)
		}
		return f_Icons_Computer
	}
	else if ThisPath = Recent ; Recent
	{
		if f_Icons_Recent =
		{
			IniRead, f_Icons_Recent, %FloderMenu_iniFile%, Icons, Recent, %A_Space%
			if f_Icons_Recent =
			{
				if Vista7
					f_Icons_Recent := "imageres.dll,-117"
				else
					f_Icons_Recent := "shell32.dll,-21"
			}
			f_Icons_Recent := f_DerefPath(f_Icons_Recent)
		}
		return f_Icons_Recent
	}
	else if ThisPath = Menu ; Menu
	{
		if f_Icons_Menu =
		{
			IniRead, f_Icons_Menu, %FloderMenu_iniFile%, Icons, Menu, %A_Space%
			if f_Icons_Menu =
				f_Icons_Menu = %f_Icons%,0
			f_Icons_Menu := f_DerefPath(f_Icons_Menu)
		}
		return f_Icons_Menu
	}
	else if ThisPath = Explorer ; Explorer
	{
		if f_Icons_Explorer =
		{
			IniRead, f_Icons_Explorer, %FloderMenu_iniFile%, Icons, Explorer, %A_Space%
			if f_Icons_Explorer =
				f_Icons_Explorer := "explorer.exe,1"
			f_Icons_Explorer := f_DerefPath(f_Icons_Explorer)
		}
		return f_Icons_Explorer
	}
	else ; a file, use its icon
	{
		Local ThisExtension ; get file extension
		SplitPath, ThisPath, , , ThisExtension
		; URL
		if InStr(ThisPath, "http://") or InStr(ThisPath, "https://")
			ThisExtension = url
		; Registry key
		if SubStr(ThisPath, 1, 2) = "HK"
			ThisExtension = reg
		; Link file
		if ThisExtension = lnk
		{
			Local TargetPath, IconPath, IconIndex
			FileGetShortcut, %ThisPath%, TargetPath, , , , IconPath, IconIndex
			if IconPath !=
				return IconPath . "," . IconIndex-1
			else
				return f_GetIcon(TargetPath)
		}
		; Unknown
		if ThisExtension =
			ThisExtension = Unknown
		if ThisExtension contains !, ,&,',(,),*,+,-,.,/,:,<,=,>,\,^,{,|,},~,``,`,,`",`%,`;
			ThisExtension = Unknown
		; Normal file
		; first check variables
		if f_Icons_%ThisExtension% =
		{
			; second read ini for custom icon
			IniRead, IconPath, %FloderMenu_iniFile%, Icons, %ThisExtension%, %A_Space%
			if IconPath =
			{
				; third read registry for system default icon
				if ThisExtension = Unknown
					RegRead, IconPath, HKEY_CLASSES_ROOT, Unknown\DefaultIcon
				else
				{
					Local FileType
					RegRead, FileType, HKEY_CLASSES_ROOT, .%ThisExtension%
					RegRead, IconPath, HKEY_CLASSES_ROOT, %FileType%\DefaultIcon
					if IconPath = ; check CLSID
					{
						Local CLSID
						RegRead, CLSID, HKEY_CLASSES_ROOT, %FileType%\CLSID
						RegRead, IconPath, HKEY_CLASSES_ROOT, CLSID\%CLSID%\DefaultIcon
					}
					if InStr(IconPath, "%1") ; the file icon is itself (%1 or "%1")
					{
						RegRead, CLSID, HKEY_CLASSES_ROOT, %FileType%\CLSID
						RegRead, IconPath, HKEY_CLASSES_ROOT, CLSID\%CLSID%\DefaultIcon
						if IconPath =
							IconPath = This
					}
					if IconPath =
						IconPath := f_GetIcon("") ; get unknown icon
					if FileType =
						IconPath := f_GetIcon("") ; get unknown icon
				}
			}
			f_Icons_%ThisExtension% := f_DerefPath(IconPath)
		}
		return f_Icons_%ThisExtension%
	}
}

f_MenuItemExist(Menu, Item)
{
	Menu, %Menu%, UseErrorLevel
	Menu, %Menu%, Enable, %Item%
	if ErrorLevel	; Not exist
	{
		Menu, %Menu%, UseErrorLevel, OFF
		return 0
	}
	else	; Exist
	{
		Menu, %Menu%, UseErrorLevel, OFF
		return 1
	}
}

f_ItemPathExist(ThisPath)
{
	Global
	if ThisPath =
		return
	Local ItemName, ItemPath
	Loop, % s_FavoritesCount
	{
		f_Split2(s_Favorites%A_Index%, "=", ItemName, ItemPath)
		ItemPath = %ItemPath% ; trim blanks
		if ItemPath = %ThisPath%
			return s_Favorites%A_Index%
	}
	return
}

f_TrimVarName(ThisMenu){
	Local Temp := ThisMenu
	StringReplace, ThisMenu, ThisMenu, @, _, All
	StringReplace, ThisMenu, ThisMenu, !, _, All
	StringReplace, ThisMenu, ThisMenu, &, _, All
	StringReplace, ThisMenu, ThisMenu, ', _, All
	StringReplace, ThisMenu, ThisMenu, (, _, All
	StringReplace, ThisMenu, ThisMenu, ), _, All
	StringReplace, ThisMenu, ThisMenu, *, _, All
	StringReplace, ThisMenu, ThisMenu, +, _, All
	StringReplace, ThisMenu, ThisMenu, -, _, All
	StringReplace, ThisMenu, ThisMenu, ., _, All
	StringReplace, ThisMenu, ThisMenu, /, _, All
	StringReplace, ThisMenu, ThisMenu, :, _, All
	StringReplace, ThisMenu, ThisMenu, <, _, All
	StringReplace, ThisMenu, ThisMenu, =, _, All
	StringReplace, ThisMenu, ThisMenu, >, _, All
	StringReplace, ThisMenu, ThisMenu, \, _, All
	StringReplace, ThisMenu, ThisMenu, ^, _, All
	StringReplace, ThisMenu, ThisMenu, {, _, All
	StringReplace, ThisMenu, ThisMenu, |, _, All
	StringReplace, ThisMenu, ThisMenu, }, _, All
	StringReplace, ThisMenu, ThisMenu, ~, _, All
	StringReplace, ThisMenu, ThisMenu, ``, _, All
	StringReplace, ThisMenu, ThisMenu, `,, _, All
	StringReplace, ThisMenu, ThisMenu, `", _, All
	StringReplace, ThisMenu, ThisMenu, `%, _, All
	StringReplace, ThisMenu, ThisMenu, `;, _, All
	StringReplace, ThisMenu, ThisMenu, % "	", _, All
	StringReplace, ThisMenu, ThisMenu, %A_Space%, _, All
	f_Menu_%ThisMenu% := Temp
	return ThisMenu
}

f_LastIsBackslash(ThisPath)
{
	if SubStr(ThisPath, 0) = "\" ; if last is \
	{
		StringTrimRight, ThisPath, ThisPath, 1 ; trim last \
		Loop ; prevent 砛籠 problem
		{
			if ThisPath =
				return Mod(A_Index, 2)
			if Asc(SubStr(ThisPath, 0)) < 128 ; if last char is not lead byte
				return Mod(A_Index, 2) ; if 1, last char is \
			else
				StringTrimRight, ThisPath, ThisPath, 1 ; trim last, go to next char
		}
	}
	else
		return 0
}

f_SplitPath(ThisPath, ByRef FileName, ByRef Dir)
{
	Temp = %ThisPath%
	Loop
	{
		if f_LastIsBackslash(Temp)
		{
			FileNameLength := A_Index-1
			break
		}
		else
			StringTrimRight, Temp, Temp, 1 ; trim last, go to next char
	}
	StringRight, FileName, ThisPath, FileNameLength
	StringTrimRight, Dir, ThisPath, FileNameLength+1
	return
}

f_CreateMenuItem(ThisMenu, ThisItem, Quiet=0)
{
	Global
	if ThisMenu =
		return "empty"
	if ThisItem =
		return "empty"
	Local ThisItemName, ThisItemPath
	if SubStr(ThisItem, 1, 1) = ":" ; start with ':' indicates a submenu
	{
		Local ThisItemVarName
		StringTrimLeft, ThisItem, ThisItem, 1	; trim ':'
		if InStr(ThisItem, "|") ; a submenu
		{
			f_Split2(ThisItem, "|", ThisItemName, ThisItemPath)
			ThisItemName = %ThisItemName%	; Trim leading and trailing spaces.
			ThisItemPath = %ThisItemPath%	; Trim leading and trailing spaces.
			; use the full path as submenu name to avoid same submenu name in different level
			; trim all illegal characters in the display name
			ThisItemVarName := ThisMenu . "@" . f_TrimVarName(ThisItemName)
			if !f_MenuItemExist(ThisMenu, ThisItemName)	; first time to create this submenu
			{
				i_%ThisItemVarName%ItemPos = 1	; this submenu initial
				i_%ThisMenu%ItemPos++	; parent menu +1
				Menu, %ThisItemVarName%, Add
				Menu, %ThisItemVarName%, DeleteAll
			}
			f_CreateMenuItem(ThisItemVarName, ThisItemPath)
			Menu, %ThisMenu%, Add, %ThisItemName%, :%ThisItemVarName%
			f_SetMenuIcon(ThisMenu, ThisItemName, f_GetIcon("Menu"))
		}
		else ; a itemmenu
		{
			f_Split2(ThisItem, "=", ThisItemName, ThisItemPath)
			ThisItemName = %ThisItemName%	; Trim leading and trailing spaces.
			ThisItemPath = %ThisItemPath%	; Trim leading and trailing spaces.
			if f_MenuItemExist(ThisMenu, ThisItemName)
			{
				if !Quiet
					MsgBox, 16, 错误, 菜单名称 [%ThisItemName%] 存在重复.`n`n请检查您的设置文件.
				Loop
				{
					if !f_MenuItemExist(ThisMenu, ThisItemName . "	" . A_Index+1)
					{
						ThisItemName := ThisItemName . "	" . A_Index+1
						break
					}
;					return "duplicate"
				}
			}
			ThisItemVarName := ThisMenu . "@" . f_TrimVarName(ThisItemName)
			Local ItemPos
			ItemPos := i_%ThisMenu%ItemPos
			; Resolve any references to variables within either field
			i_%ThisMenu%Path%ItemPos% := f_DerefPath(ThisItemPath)
			f_CreateItemMenu(i_%ThisMenu%Path%ItemPos%, ThisItemVarName, s_MaxDepth)
			Menu, %ThisMenu%, Add, %ThisItemName%, :%ThisItemVarName%
			if !s_NoMenuIcon
			{
				Local ThisIcon := f_GetIcon(i_%ThisMenu%Path%ItemPos%)
				if ThisIcon = This ; default icon is %1
					ThisIcon := i_%ThisMenu%Path%ItemPos%
				tempworkdir:=A_WorkingDir
				SetWorkingDir % i_%ThisMenu%Path%ItemPos%
				f_SetMenuIcon(ThisMenu, ThisItemName, ThisIcon)
				SetWorkingDir %tempworkdir%
			}
			i_%ThisMenu%ItemPos++
		}
	}
	else if ThisItem = -	; '-' indicates a separator
	{
		Menu, %ThisMenu%, Add
		i_%ThisMenu%ItemPos++
	}
	else	; a favorite item
	{
		f_Split2(ThisItem, "=", ThisItemName, ThisItemPath)
		ThisItemName = %ThisItemName%	; Trim leading and trailing spaces.
		ThisItemPath = %ThisItemPath%	; Trim leading and trailing spaces.
		if f_MenuItemExist(ThisMenu, ThisItemName)
		{
			if !Quiet
				MsgBox, 16, 错误, 菜单名称 [%ThisItemName%] 存在重复.`n`n请检查您的设置文件.
			Loop
			{
				if !f_MenuItemExist(ThisMenu, ThisItemName . "	" . A_Index+1)
				{
					ThisItemName := ThisItemName . "	" . A_Index+1
					break
				}
;				return "duplicate"
			}
		}

		if SubStr(ThisItemPath, 1, 1) = "_" ; special items
		{
			if ThisItemPath = _ToolAdd
			{
				Menu, %ThisMenu%, Add, %ThisItemName%, f_AddFavorite
				f_SetMenuIcon(ThisMenu, ThisItemName, f_Icons . ",-301")
			}
			else if ThisItemPath = _ToolAddHere
			{
				Menu, %ThisMenu%, Add, %ThisItemName%, f_AddFavoriteHere
				f_SetMenuIcon(ThisMenu, ThisItemName, f_Icons . ",-301")
			}
			else if ThisItemPath = _ToolReload
			{
				Menu, %ThisMenu%, Add, %ThisItemName%, f_ToolReload
				f_SetMenuIcon(ThisMenu, ThisItemName, f_Icons . ",-302")
			}
			else if ThisItemPath = _ToolToggleHidden
			{
				Menu, %ThisMenu%, Add, %ThisItemName%, f_ToolToggleHidden
				f_SetMenuIcon(ThisMenu, ThisItemName, f_Icons . ",-302")
			}
			else if ThisItemPath = _ToolToggleFileExt
			{
				Menu, %ThisMenu%, Add, %ThisItemName%, f_ToolToggleFileExt
				f_SetMenuIcon(ThisMenu, ThisItemName, f_Icons . ",-302")
			}
			else if ThisItemPath = _ToolOptions
			{
				Menu, %ThisMenu%, Add, %ThisItemName%, f_ToolOptions
				f_SetMenuIcon(ThisMenu, ThisItemName, f_Icons . ",-303")
			}
			else if ThisItemPath = _ToolEdit
			{
				Menu, %ThisMenu%, Add, %ThisItemName%, f_ToolEdit
				f_SetMenuIcon(ThisMenu, ThisItemName, f_Icons . ",-304")
			}
			else if ThisItemPath = _ToolExit
			{
				Menu, %ThisMenu%, Add, %ThisItemName%, f_ToolExit
				f_SetMenuIcon(ThisMenu, ThisItemName, f_Icons . ",-305")
			}
			else if ThisItemPath = _SystemRecent
			{
				Menu, %ThisMenu%, Add, %ThisItemName%, f_SystemRecent
				f_SetMenuIcon(ThisMenu, ThisItemName, f_GetIcon("Recent"))
			}
			else if ThisItemPath = _ExplorerList
			{
				Menu, %ThisMenu%, Add, %ThisItemName%, f_ExplorerList
				f_SetMenuIcon(ThisMenu, ThisItemName, f_GetIcon("Explorer"))
			}
			else if ThisItemPath = _DriveList
			{
				Menu, %ThisMenu%, Add, %ThisItemName%, f_DriveList
				f_SetMenuIcon(ThisMenu, ThisItemName, f_GetIcon("Computer"))
			}
			else if ThisItemPath = _ToolMenu
			{
				f_CreateToolMenu()
				Menu, %ThisMenu%, Add, %ThisItemName%, :ToolMenu
				f_SetMenuIcon(ThisMenu, ThisItemName, f_Icons)
			}
			else if ThisItemPath = _RecentMenu
			{
				f_RecentEnabled = 1
				f_ReadRecent()
				Menu, %ThisMenu%, Add, %ThisItemName%, :RecentMenu
				f_SetMenuIcon(ThisMenu, ThisItemName, f_Icons . ",-307")
			}
			else if ThisItemPath = _DebugMenu
			{
				f_CreateDebugMenu()
				Menu, %ThisMenu%, Add, %ThisItemName%, :DebugMenu
				f_SetMenuIcon(ThisMenu, ThisItemName, f_Icons . ",-306")
			}
			else if ThisItemPath = _SVSMenu
			{
				f_CreateSVSMenu()
				Menu, %ThisMenu%, Add, %ThisItemName%, :SVSMenu
				f_SetMenuIcon(ThisMenu, ThisItemName, f_Icons . ",-311")
			}
			else
				f_ErrorMsg = %f_ErrorMsg%`"%ThisItemPath%`" is not a valid special item.`n
		}
		else ; a normal item
		{
			Local ItemPos
			ItemPos := i_%ThisMenu%ItemPos
			; Resolve any references to variables within either field
			i_%ThisMenu%Path%ItemPos% := f_DerefPath(ThisItemPath)
			Menu, %ThisMenu%, Add, %ThisItemName%, f_OpenFavorite

			if !s_NoMenuIcon && !InStr(ThisItemPath, "svscmd.exe")
			{
				Local ThisIcon := f_GetIcon(i_%ThisMenu%Path%ItemPos%)
				if ThisIcon = This ; default icon is %1
					ThisIcon := i_%ThisMenu%Path%ItemPos%

				; show different icon for folders which has subfolder
				if s_AltFolderIcon
					if ThisMenu = TempMenu
						if SubStr(ThisItemPath, 0) != ":" && SubStr(ThisItemName, 0) != "\" && ThisItemName != "..\"
							Loop, %ThisItemPath%\*, 2
							{
								ThisIcon := f_GetIcon("FolderS")
								break
							}
                tempworkdir:=A_WorkingDir
				SetWorkingDir % i_%ThisMenu%Path%ItemPos%
				f_SetMenuIcon(ThisMenu, ThisItemName, ThisIcon)
				SetWorkingDir %tempworkdir%
			}
		}
		i_%ThisMenu%ItemPos++
	}
	return
}

f_CreateItemMenu(ThisFolderPath, MenuName, MaxDepth, Depth=1)
{
	Global
	Local ItemCount, FolderList, FileList
	Menu, %MenuName%, Add
	Menu, %MenuName%, DeleteAll	; delete old menu
	i_%MenuName%ItemPos = 1
	f_CreateMenuItem(MenuName, "[Open]=" . ThisFolderPath)
	f_CreateMenuItem(MenuName, "-")

	; Remove the trailing backslash
	if f_LastIsBackslash(ThisFolderPath)
		StringTrimRight, ThisFolderPath, ThisFolderPath, 1

	if MaxDepth =
		MaxDepth = 2

	if ThisFolderPath in Computer,"::{20D04FE0-3AEA-1069-A2D8-08002B30309D}",::{20D04FE0-3AEA-1069-A2D8-08002B30309D} ; Computer, list HDDs
	{
		ItemCount++
		Local DriveList, DriveSpace, FreeSpace, DriveName
		DriveGet, DriveList, List, FIXED
		Loop, Parse, DriveList
		{
			DriveGet, DriveSpace, Capacity, %A_LoopField%:\
			DriveSpaceFree, FreeSpace, %A_LoopField%:\
			DriveName := A_LoopField . ":\	" . Round(FreeSpace/1024,1) . "GB/" . Round(DriveSpace/1024,1) . "GB    " . 100*FreeSpace//DriveSpace . "% Free"
			if (Depth < MaxDepth || MaxDepth = 0)
			{
				Local ItemName, ItemVarName, ItemIcon
				ItemName := DriveName
				ItemVarName := MenuName . "@" . f_TrimVarName(ItemName)
				ItemIcon := f_GetIcon("C:")
				f_CreateItemMenu(A_LoopField . ":\", ItemVarName, MaxDepth, Depth+1)
				Menu, %MenuName%, Add, %ItemName%, :%ItemVarName%
				f_SetMenuIcon(MenuName, ItemName, ItemIcon)
				i_%MenuName%ItemPos++
			}
			else
				FolderList = %FolderList%%DriveName%=%A_LoopField%:`n
		}
	}

	Loop, %ThisFolderPath%\*, 2
	{
		ItemCount++
		if (Depth < MaxDepth || MaxDepth = 0)
		{
			Local ItemName, ItemVarName, ItemIcon
			ItemName := A_LoopFileName
			ItemVarName := MenuName . "@" . f_TrimVarName(ItemName)
			ItemIcon := f_GetIcon(A_LoopFileFullPath)
			f_CreateItemMenu(A_LoopFileFullPath, ItemVarName, MaxDepth, Depth+1)
			Menu, %MenuName%, Add, %ItemName%, :%ItemVarName%
			tempworkdir:=A_WorkingDir
			SetWorkingDir % A_LoopFileFullPath
			f_SetMenuIcon(MenuName, ItemName, ItemIcon)
			SetWorkingDir %tempworkdir%
			i_%MenuName%ItemPos++
		}
		else
			FolderList = %FolderList%%A_LoopFileName%`=%A_LoopFileFullPath%`n
	}
	Loop, Parse, s_ShowFileExt, `,
	{
		Loop, %ThisFolderPath%\*.%A_LoopField%, 0
		{
			ItemCount++
			Local Name := A_LoopFileName
			if s_HideExt
				SplitPath, Name, , , , Name
			FileList = %FileList%%Name%`=%A_LoopFileFullPath%`n
		}
	}
	; sort and merge list
	Sort, FolderList
	Sort, FileList, U
	FileList = %FolderList%%FileList%

	; Create items
    ;ToolTip, Loading Item Menu...
	Loop, parse, FileList, `n
	{
;		ToolTip, Loading Item Menu... `nItem %A_Index%
		if A_Index = 500
		{
			MsgBox, 308, 警告, 已经存在超过500个菜单条目 (%ItemCount% 菜单)`n`n确认是否继续?
			IfMsgBox No
				break
		}
		if A_LoopField !=
			f_CreateMenuItem(MenuName, A_LoopField, 1)
	}
;	ToolTip
	if i_%MenuName%ItemPos = 3
	{
		f_CreateMenuItem(MenuName, "Empty = nothing")
		Menu, %MenuName%, Disable, Empty
	}
	return
}

f_CreateToolMenu()
{
	Global
	Menu, ToolMenu, Add
	Menu, ToolMenu, DeleteAll	; delete old menu
	Menu, ToolMenu, Add, 添加到Favorite(&A), f_AddFavorite
	Menu, ToolMenu, Add,
	Menu, ToolMenu, Add, 重启(&R), f_ToolReload
	Menu, ToolMenu, Add, Folder Menu 选项(&O), f_ToolOptions
	Menu, ToolMenu, Add, 编辑配置文件(&E), f_ToolEdit
	Menu, ToolMenu, Add
	Menu, ToolMenu, Add, 退出(&X), f_ToolExit
	f_SetMenuIcon("ToolMenu", "添加到Favorite(&A)", f_Icons . ",-301")
	f_SetMenuIcon("ToolMenu", "重启(&R)"      , f_Icons . ",-302")
	f_SetMenuIcon("ToolMenu", "Folder Menu 选项(&O)"     , f_Icons . ",-303")
	f_SetMenuIcon("ToolMenu", "编辑配置文件(&E)"        , f_Icons . ",-304")
	f_SetMenuIcon("ToolMenu", "退出(&X)"        , f_Icons . ",-305")
	return
}

f_CreateDebugMenu()
{
	Global
	Menu, DebugMenu, Add
	Menu, DebugMenu, DeleteAll	; delete old menu
	Menu, DebugMenu, Add, List&Lines, f_ListLines
	Menu, DebugMenu, Add, List&Vars, f_ListVars
	Menu, DebugMenu, Add, List&Hotkeys, f_ListHotkeys
	Menu, DebugMenu, Add, &KeyHistory, f_KeyHistory
	f_SetMenuIcon("DebugMenu", "List&Lines"  , f_Icons . ",1")
	f_SetMenuIcon("DebugMenu", "List&Vars"   , f_Icons . ",1")
	f_SetMenuIcon("DebugMenu", "List&Hotkeys", f_Icons . ",1")
	f_SetMenuIcon("DebugMenu", "&KeyHistory" , f_Icons . ",1")
	return
}

f_RecentMenu:
f_CreateRecentMenu()
f_ShowMenu("RecentMenu")
return

f_CreateRecentMenu()
{
	Global
	Menu, RecentMenu, Add
	Menu, RecentMenu, DeleteAll	; delete old menu
	i_RecentMenuItemPos = 1

	if f_RecentList0 != ; if the list is not empty, create recent menu
	{
		Local Index0, Indexa
		Loop, % s_RecentSize
		{
			Index0 := A_Index-1 ; 0 ~ 9 (s_RecentSize-1)
			if A_Index < 11
				Indexa := A_Index-1
			else
				Indexa := Chr(86+A_Index)
			if f_RecentList%Index0% != ; it's not blank
			{
				Local ThisName, ThisDir, ThisNameNoExt
				ThisName := f_RecentList%Index0%
				if s_HideExt
				{
					SplitPath, ThisName, , ThisDir, , ThisNameNoExt
					ThisName = %ThisDir%\%ThisNameNoExt%
				}
				if s_RecentShowIndex
				f_CreateMenuItem("RecentMenu", "&" . Indexa . "    " . ThisName . "=" . f_RecentList%Index0%)
			else
				f_CreateMenuItem("RecentMenu", ThisName . "=" . f_RecentList%Index0%)
			}
		}
		Menu, RecentMenu, Add
		Menu, RecentMenu, Add, 清理(&R), f_ClearRecent
		f_SetMenuIcon("RecentMenu", "清理(&R)", f_Icons . ",-305")
		Menu, RecentMenu, Add
	}
	Menu, RecentMenu, Add, 系统最近的项目(&S), f_SystemRecent
	f_SetMenuIcon("RecentMenu", "系统最近的项目(&S)", f_GetIcon("Recent"))

	Loop, % s_RecentSize
	{
		Index0 := A_Index-1 ; 0 ~ 9 (s_RecentSize-1)
		Local RecentItem := f_RecentList%Index0%
		IniWrite, %RecentItem%, %FloderMenu_iniFile%, Recents, Recent%Index0%
	}
	return
}

f_ReadRecent()
{
	Global
	Local Index0
	Loop, % s_RecentSize
	{
		Index0 := A_Index-1 ; 0 ~ 9 (s_RecentSize-1)
		IniRead, f_RecentList%Index0%, %FloderMenu_iniFile%, Recents, Recent%Index0%, %A_Space%
	}
	f_CreateRecentMenu()
	return
}

f_AddRecent(Path)
{
	Global
	Local Index0, Index1, ThisIndex
	Loop, % s_RecentSize ; find if the item already exists
	{
		Index0 := A_Index-1 ; 0 ~ 9 (s_RecentSize-1)
		if f_RecentList%Index0% = %Path%
			ThisIndex := Index0
	}
	if ThisIndex = ; not found
		ThisIndex := s_RecentSize-1 ; move all
	Loop, % ThisIndex ; move only items above this item
	{
		Index0 := ThisIndex - A_Index ; ThisIndex-1 ~ 0
		Index1 := Index0 + 1           ; ThisIndex   ~ 1
		f_RecentList%Index1% := f_RecentList%Index0%
	}
	f_RecentList0 = %Path%
	f_CreateRecentMenu()
	return
}

f_ClearRecent:
f_RecentList0 =
Loop, % s_RecentSize-1
	f_RecentList%A_Index% =
f_CreateRecentMenu()
return

f_SystemRecent:
f_CreateSystemRecentMenu()
f_ShowMenu("SystemRecentMenu")
return

f_CreateSystemRecentMenu()
{
	Menu, SystemRecentMenu, Add
	Menu, SystemRecentMenu, Delete	; delete old menu

	if Vista7
		RecentPath = %AppData%\Microsoft\Windows\Recent ; For Vista / 7
	else
		RecentPath = %UserProfile%\Recent ; For XP

	ToolTip, 加载最近的项目...
	Loop, %RecentPath%\*.lnk
	{
    ; ToolTip, Loading Recent Items...`nItem %A_Index%
		FileGetTime, ItemTime
		FormatTime, ItemTime, %ItemTime%, yyyy/MM/dd HH:mm:ss
		FileGetShortcut, %A_LoopFileLongPath%, ThisFolderPath
		Global s_RecentOnlyFolderS
		if !s_RecentOnlyFolderS ; not only folder, add all
		{
			if FileExist(ThisFolderPath)
			{
				ThisFolderName = %ThisFolderPath%
				Global s_HideExt
				if s_HideExt
				{
					SplitPath, ThisFolderPath, , ThisDir, , ThisNameNoExt
					ThisFolderName = %ThisDir%\%ThisNameNoExt%
				}
				RecentFolderList = %RecentFolderList%`n%ItemTime% %ThisFolderName%`=%ThisFolderPath%
			}
		}
		else ; add only folders
		{
			if InStr(FileExist(ThisFolderPath), "D")
				RecentFolderList = %RecentFolderList%`n%ItemTime% %ThisFolderPath%`=%ThisFolderPath%
		}
	}
	ToolTip
	if RecentFolderList =
	{
		f_CreateMenuItem("SystemRecentMenu", "Empty = nothing")
		Menu, SystemRecentMenu, Disable, Empty
	}
	else
	{
		; Sort and create items
		Sort, RecentFolderList, R ; latest first
		Global i_SystemRecentMenuItemPos = 1
		Loop, parse, RecentFolderList, `n
		{
			Global s_RecentSizeS
			if A_Index > %s_RecentSizeS%
				break
			if A_LoopField !=
			{
				if A_Index < 11
					Indexa := A_Index-1
				else
					Indexa := Chr(86+A_Index)
				Global s_RecentShowIndex
				if s_RecentShowIndex
					f_CreateMenuItem("SystemRecentMenu", "&" . indexa . "    " . A_LoopField)
				else
					f_CreateMenuItem("SystemRecentMenu", A_LoopField)
			}
		}
	}
	return
}

f_DriveList:
f_OpenTempMenu("""::{20D04FE0-3AEA-1069-A2D8-08002B30309D}""")
return

f_OpenTempMenu(ThisFolderPath, ShowAll=0)
{
	Global
	; fix temp menu position
	; by MILK
	CoordMode, Mouse, Screen
	Local X, Y, sX, sY
	MouseGetPos, X, Y
	sX := s_MenuPositionX
	sY := s_MenuPositionY
	; -65 and -35 aligns current folder item with the mouse position
	s_MenuPositionX := X - 65
	s_MenuPositionY := Y - 35
	if f_CreateTempMenu(ThisFolderPath, ShowAll) ; has subfolders
	{
		f_ShowMenu("TempMenu")
		s_MenuPositionX := sX
		s_MenuPositionY := sY
		return 1
	}
	else ; no subfolder
	{
		f_ShowMenu("TempMenu")
		s_MenuPositionX := sX
		s_MenuPositionY := sY
		return 0
	}
}

f_CreateTempMenu(ThisFolderPath, ShowAll)
{
	Menu, TempMenu, Add
	Menu, TempMenu, Delete	; delete old menu

	; Remove the trailing backslash
	if f_LastIsBackslash(ThisFolderPath)
		StringTrimRight, ThisFolderPath, ThisFolderPath, 1

	; Get subfolders list
	if ThisFolderPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" ; Computer, list HDDs
	{
		DriveGet, DriveList, List, FIXED
		Loop, Parse, DriveList
		{
			DriveGet, DriveSpace, Capacity, %A_LoopField%:\
			DriveSpaceFree, FreeSpace, %A_LoopField%:\
			DriveName := A_LoopField . ":\	" . Round(FreeSpace/1024,1) . "GB/" . Round(DriveSpace/1024,1) . "GB    " . 100*FreeSpace//DriveSpace . "% Free"
			SubFolderList = %SubFolderList%%DriveName%=%A_LoopField%:`n
		}
	}
	else
	{
		Global s_ShowFileExt
		if ShowAll
			Loop, Parse, s_ShowFileExt, `,
			{
				Loop, %ThisFolderPath%\*.%A_LoopField%, 0
				{
					FileCount++
					Name := A_LoopFileName
					Global s_HideExt
					if s_HideExt
						SplitPath, Name, , , , Name
					SubFileList = %SubFileList%%Name%`=%A_LoopFileFullPath%`n
				}
			}
		Loop, %ThisFolderPath%\*, 2
		{
			FileCount++
			SubFolderList = %SubFolderList%%A_LoopFileName%`=%A_LoopFileFullPath%`n
		}
		; sort and merge list
		Sort, SubFileList, U
		Sort, SubFolderList
		SubFolderList = %SubFolderList%%SubFileList%
	}

	Global i_TempMenuItemPos = 1

	if ThisFolderPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" ; Computer
	{
		ThisFolderName = Computer
	}
	else if SubStr(ThisFolderPath, 0) = ":" ; it's root, use path as name
	{
		ThisFolderName = %ThisFolderPath%\
		f_CreateMenuItem("TempMenu", "..\=""::{20D04FE0-3AEA-1069-A2D8-08002B30309D}""")
	}
	else ; it's not root, add parent folder item ..\
	{
		f_SplitPath(ThisFolderPath, ThisFolderName, ParentFolderPath)
		ThisFolderName = %ThisFolderName%\
		f_CreateMenuItem("TempMenu", "..\=" . ParentFolderPath)
	}

	f_CreateMenuItem("TempMenu", ThisFolderName "=" . ThisFolderPath)
	f_CreateMenuItem("TempMenu", "-")

	if SubFolderList =	; if no subfolder
	{
		f_CreateMenuItem("TempMenu", "Empty = nothing")
		Menu, TempMenu, Disable, Empty
		return 0
	}
	else
	{
		; Create items
		ToolTip, 加载项目...
 		Loop, parse, SubFolderList, `n
		{
;	 ToolTip, Loading Items...`nItem %A_Index%
			if A_Index = 500
			{
				MsgBox, 308, 警告, 已经存在超过500个菜单条目 (%FileCount% 菜单)`n`n是否继续?
				IfMsgBox No
					break
			}
			if A_LoopField !=
				f_CreateMenuItem("TempMenu", A_LoopField, 1)
		}
		ToolTip
		return 1
	}
}

f_CreateExplorerMenu()
{
	Global
	Local AllExplorerPaths := f_GetExplorerList()
	Menu, ExplorerMenu, Add
	Menu, ExplorerMenu, DeleteAll
	Local ItemPos = 1
	Local Name
	Loop, Parse, AllExplorerPaths, `n
	{
		if A_LoopField =
			continue
		f_Split2(A_LoopField, "=", i_ExplorerMenuID%ItemPos%, Name)
		Menu, ExplorerMenu, Add, %Name%, f_ActivateWindow
		f_SetMenuIcon("ExplorerMenu", Name, f_GetIcon("Explorer"))
		ItemPos++
	}
	if ItemPos = 1
	{
		Menu, ExplorerMenu, Add, Empty, f_ActivateWindow
		Menu, ExplorerMenu, Disable, Empty
	}
	return
}

f_ExplorerList:
f_CreateExplorerMenu()
f_ShowMenu("ExplorerMenu")
return

f_ActivateWindow:
f_OpenFavPath := i_%A_ThisMenu%ID%A_ThisMenuItemPos%
WinActivate, ahk_id %f_OpenFavPath%
return

f_GetExplorerList() ; Thanks to F1reW1re
{
	WinGet, IDList, list, , , Program Manager
	Loop, %IDList%
	{
		ThisID := IDList%A_Index%
		WinGetClass, ThisClass, ahk_id %ThisID%
		if ThisClass in ExploreWClass,CabinetWClass
		{
			if Vista7
				ControlGetText, ThisPath, ToolbarWindow322, ahk_id %ThisID%
			else
				ControlGetText, ThisPath, ComboBoxEx321, ahk_id %ThisID%
			if ThisPath = ; if cannot get path, use title instead
				WinGetTitle, ThisPath, ahk_id %ThisID%
			PathList = %PathList%%ThisID%=%ThisPath%`n
		}
	}
	return PathList
}

f_ToggleFileExt()
{
	RootKey = HKEY_CURRENT_USER
	SubKey  = Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
	RegRead, HideFileExt    , % RootKey, % SubKey, HideFileExt
	if HideFileExt = 1
		RegWrite, REG_DWORD, % RootKey, % SubKey, HideFileExt, 0
	else
		RegWrite, REG_DWORD, % RootKey, % SubKey, HideFileExt, 1
	f_RefreshExplorer()
	return
}

f_ToggleHidden() ; thanks to Mr. Milk
{
	RootKey = HKEY_CURRENT_USER
	SubKey  = Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
	RegRead, HiddenFiles_Status, % RootKey, % SubKey, Hidden
	if HiddenFiles_Status = 2
	{
		RegWrite, REG_DWORD, % RootKey, % SubKey, Hidden, 1
		RegWrite, REG_DWORD, % RootKey, % SubKey, ShowSuperHidden, 1
	}
	else
	{
		RegWrite, REG_DWORD, % RootKey, % SubKey, Hidden, 2
		RegWrite, REG_DWORD, % RootKey, % SubKey, ShowSuperHidden, 0
	}
	f_RefreshExplorer()
	return
}

f_RefreshExplorer()
{
	WinGet, w_WinID, ID, ahk_class Progman
	if Vista7
		SendMessage, 0x111, 0x1A220,,, ahk_id %w_WinID%
	else
		SendMessage, 0x111, 0x7103,,, ahk_id %w_WinID%
	WinGet, w_WinIDs, List, ahk_class CabinetWClass
	Loop, %w_WinIDs%
	{
		w_WinID := w_WinIDs%A_Index%
		if Vista7
			SendMessage, 0x111, 0x1A220,,, ahk_id %w_WinID%
		else
			SendMessage, 0x111, 0x7103,,, ahk_id %w_WinID%
	}
	WinGet, w_WinIDs, List, ahk_class ExploreWClass
	Loop, %w_WinIDs%
	{
		w_WinID := w_WinIDs%A_Index%
		if Vista7
			SendMessage, 0x111, 0x1A220,,, ahk_id %w_WinID%
		else
			SendMessage, 0x111, 0x7103,,, ahk_id %w_WinID%
	}
	WinGet, w_WinIDs, List, ahk_class #32770
	Loop, %w_WinIDs%
	{
		w_WinID := w_WinIDs%A_Index%
		ControlGet, w_CtrID, Hwnd,, SHELLDLL_DefView1, ahk_id %w_WinID%
		if w_CtrID !=
			SendMessage, 0x111, 0x7103,,, ahk_id %w_CtrID%
	}
	return
}

f_CreateSVSMenu() ; thanks to Mr. Milk
{
	Global
	i_SVSMenuItemPos = 1
	Menu, SVSMenu, Add
	Menu, SVSMenu, DeleteAll	; delete old menu

	Local LayerName, SVSCommand, LayerStatus, LayerList

	SVSCommand := "cmd.exe /c svscmd.exe enum -v > " . Temp . "\svsstatus.cfg"
	RunWait, %SVSCommand%, %A_ScriptDir%, Hide UseErrorLevel
	if ErrorLevel
		return

	Loop, Read, %Temp%\svsstatus.cfg
	{
		if SubStr(A_LoopReadLine, 1, 11) != "Layer name:" && SubStr(A_LoopReadLine, 1, 7) != "Active:"
			continue

		if SubStr(A_LoopReadLine, 1, 11) = "Layer name:"
		{
			StringTrimLeft, LayerName, A_LoopReadLine, 11
			LayerName = %LayerName%
			continue
		}
		if SubStr(A_LoopReadLine, 1, 7) = "Active:"
		{
			StringTrimLeft, LayerStatus, A_LoopReadLine, 7
			LayerStatus = %LayerStatus%
			if LayerStatus = No
				LayerStatus := "A"
			else
				LayerStatus := "D"
			SVSCommand := LayerName . "=" . "svscmd.exe -W " . """" . LayerName . """" . " " . LayerStatus
			LayerList = %LayerList%%SVSCommand%`n
		}
	}
	Sort, LayerList
	Loop, Parse, LayerList, `n
	{
		f_CreateMenuItem("SVSMenu", A_LoopField)
		if SubStr(A_LoopField, -1) = " D"
		{
			LayerName := SubStr(A_LoopField, 1, InStr(A_LoopField, "=")-1)
			Menu, SVSMenu, Check, %LayerName%
		}
	}
	if LayerList !=
		Menu, SVSMenu, Add
	Menu, SVSMenu, Add, Run SVS Admin, f_SVSAdmin
	f_SetMenuIcon("SVSMenu", "Run SVS Admin", f_Icons . ",-311")
	return
}



;==================== Labels ====================;
;f_RButton:
;Thread, Priority, 1
;MouseGetPos, , , w_WinID
;WinGetClass, w_Class, ahk_id %w_WinID%
;if w_Class = #32768
;{
;	WinGet, w_ProcessName, ProcessName, ahk_id %w_WinID%
;	msgbox, % w_ProcessName
;	f_RightClick = 1
;	Click
;}
;return
f_DisplayMenu1DB:
if (A_PriorHotkey = A_ThisHotKey && A_TimeSincePriorHotkey < 500)
{
	if A_ThisHotKey contains LButton
	{
		ControlGet, f_SelectedFile, List, Selected, SysListView321, A
		if f_SelectedFile !=
			return
	}
	Gosub, f_DisplayMenu1
}
return
f_DisplayMenu15DB:
if (A_PriorHotkey = A_ThisHotKey && A_TimeSincePriorHotkey < 500)
{
	if A_ThisHotKey contains LButton
	{
		ControlGet, f_SelectedFile, List, Selected, SysListView321, A
		if f_SelectedFile !=
			return
	}
	Gosub, f_DisplayMenu15
}
return
f_DisplayMenu2DB:
if (A_PriorHotkey = A_ThisHotKey && A_TimeSincePriorHotkey < 500)
{
	if A_ThisHotKey contains LButton
	{
		ControlGet, f_SelectedFile, List, Selected, SysListView321, A
		if f_SelectedFile !=
			return
	}
	Gosub, f_DisplayMenu2
}
return
f_OpenSelDB:
if (A_PriorHotkey = A_ThisHotKey && A_TimeSincePriorHotkey < 500)
	Gosub, f_OpenSel
return
f_AddAppDB:
if (A_PriorHotkey = A_ThisHotKey && A_TimeSincePriorHotkey < 500)
	Gosub, f_AddApp
return
f_AddFavoriteKDB:
if (A_PriorHotkey = A_ThisHotKey && A_TimeSincePriorHotkey < 500)
	Gosub, f_AddFavoriteK
return
f_ToolReloadDB:
if (A_PriorHotkey = A_ThisHotKey && A_TimeSincePriorHotkey < 500)
	Gosub, f_ToolReload
return
f_ToolOptionsDB:
if (A_PriorHotkey = A_ThisHotKey && A_TimeSincePriorHotkey < 500)
	Gosub, f_ToolOptions
return
f_ToolEditDB:
if (A_PriorHotkey = A_ThisHotKey && A_TimeSincePriorHotkey < 500)
	Gosub, f_ToolEdit
return
f_ToolExitDB:
if (A_PriorHotkey = A_ThisHotKey && A_TimeSincePriorHotkey < 500)
	Gosub, f_ToolExit
return
f_ToolReload:
Reload
return
f_ToolOptions:
;gui_hh = 0
;gui_ww = 0
gui_Tab =
Gosub, f_OptionsGUI
return
f_ToolEdit:
Run, %FloderMenu_iniFile%
return
f_ToolExit:
Exitapp
return
f_ListLines:
ListLines
return
f_ListVars:
ListVars
return
f_ListHotkeys:
ListHotkeys
return
f_KeyHistory:
KeyHistory
return
f_ToolToggleHidden:
f_ToggleHidden()
return
f_ToolToggleFileExt:
f_ToggleFileExt()
return
f_SVSAdmin:
f_CreateSVSMenu()
Run, "svsadmin.exe"
return

;GUI.ahk包含了Folder Menu 的GUI设置部分的代码
#Include %A_ScriptDir%\Script\FolderMenu_GUI.ahk
;Lib.ahk为共用函数库,已拆分为以下几个文件
;#Include %A_ScriptDir%\Script\Lib.ahk
#Include %A_ScriptDir%\Lib\TVX.ahk
#Include %A_ScriptDir%\Lib\Tooltip.ahk
;#Include %A_ScriptDir%\Lib\ShellContextMenu.ahk
;合并到Lib\Explorer.ahk中
;#Include %A_ScriptDir%\Lib\string.ahk