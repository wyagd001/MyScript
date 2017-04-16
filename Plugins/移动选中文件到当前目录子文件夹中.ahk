/*
功能：快速移动选中文件到当前目录下的某个文件夹中
实现方法：按下快捷键，弹出一个包含当前目录下所有文件夹的列表，输入几个字母就可以快速定位特定文件夹。
用途：下载控整理下载文件夹，或者有很多文献、电子书需要归类整理，甚至于整理桌面都可以用得到。
代码：
*/
; Script function: move file(s) to a folder under current dir
  ;      the destination folder can be located with a few keystroks by real-time filtering
  ; AutoHotkey Version: 1.0.48.05
  ; Language:       English
  ; Platform:       Win8.1 64 bit
  ; Author:         Valuex
  ; Note:this script is a modification version of YONKEN's work:
  ; 根据输入实时更新过滤文件列表
  ; http://www.cnblogs.com/yonken/archive/2010/05/10/Smart_Open_Files_Update_File_List_On_Pattern_Changed.html
  ; Use at your own risk.
  ;

  #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
  SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
  SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
  SetBatchLines, -1   ; Never sleep

  WM_NOTIFY               := 0x004E
  LVN_FIRST               := -100

  LVN_GETDISPINFOA        := (LVN_FIRST-50)   ; For ANSI version
  LVN_GETDISPINFOW        := (LVN_FIRST-77)   ; For unicode version
  LVN_GETDISPINFO         := LVN_GETDISPINFOW

  LVM_FIRST               := 0x1000
  LVM_SETITEMCOUNT        := (LVM_FIRST + 47)
  LVM_REDRAWITEMS         := (LVM_FIRST + 21)

  LVS_OWNERDATA           := 0x1000

  LPSTR_TEXTCALLBACKA     := -1

  sizeofNMHDR             := A_Ptrsize * 3
  ;sizeofLVITEM            := 40

  LVSICF_NOINVALIDATEALL  := 0x00000001

  LVIF_TEXT               := 0x0001
  LVIF_IMAGE              := 0x0002
  LVIF_STATE              := 0x0008

  CP_ACP                  := 0           ; default to ANSI code page

  g_strAppName            := "Smart Open File"
  g_strVersion            := "2010.5.10"
  g_strTitle              := g_strAppName A_Space g_strVersion
  g_hMainWnd              := 0

  g_nFilesCount           := 0
  g_nMatchCount           := 0
  g_MatchIndices          = -1

  ColNum                  :=5
  ; Allow the user to maximize or drag-resize the window:
  Gui +Resize +Owner  ; +Owner avoids a taskbar button.

  ; Create some buttons:
  ;Gui, Add, Button, Default vBtnLoadFolder gButtonLoadFolder, &Load a folder

  ; Create the ListView with two columns, Name and Size:
  Gui, Add, ListView, Grid xm r20 w700 vMyListView Hwndg_hMyListView +%LVS_OWNERDATA%, Name|In Folder|Modified|Size (KB)|Type

  ; Create an ImageList so that the ListView can display some icons:
  ImageListID1 := IL_Create(10)
  ImageListID2 := IL_Create(10, 10, true)  ; A list of large icons to go with the small ones.

  ; Attach the ImageLists to the ListView so that it can later display the icons:
  LV_SetImageList(ImageListID1)
  LV_SetImageList(ImageListID2)

  ListView_SetItemCount(g_hMyListView, g_nMatchCount)
    Gui, Add, Button, Hidden Default, OK
  Gui, Add, Text,vSourceFile , SourceFile:

  Gui, Add, Edit, vEditSearchString gOnChangeSearchString

  F1::
  Gosub, lblGetSourcePath
  MsgBox,, ,OK,0.01
  Gosub, ButtonLoadFolder
  LV_ModifyCol(1,250)
  LV_ModifyCol(2,250)
  LV_ModifyCol(3,50)
  LV_ModifyCol(4,50)
  LV_ModifyCol(5,50)
  GuiControl, text, SourceFile ,% GetFileNameByPath(SourceFileArr1)
  Gui, Show, , %g_strTitle% [0 of 0]

  OnMessage(WM_NOTIFY, "OnNotify")

  Gui, +LastFound
  WinSet, ReDraw      ; Invalidate the list-view

  g_hMainWnd := WinExist()

  return

  GuiEscape:
      ;GuiClose:  ; Indicate that the script should exit automatically when the window is closed.
      Reload
  Return

  GuiSize:  ; Expand or shrink the ListView in response to the user's resizing of the window.
      if A_EventInfo = 1  ; The window has been minimized.  No action needed.
          return
      ; Otherwise, the window has been resized or maximized. Resize the ListView to match.
      GuiControl, Move, MyListView, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - 70)
      GuiControl, Move, SourceFile, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - 40)
      GuiControl, Move, EditSearchString, % "W" . (A_GuiWidth - 20) . " Y" . (A_GuiHeight - 30)
  return

  ButtonOK:
    Gosub, lblGetListViewInfo
    IfExist, %FileDestDir%
      Gosub, lblMoveFile
    Reload
  return
  lblGetListViewInfo:
    ;get dest dir by combining cell1 and cell2 in focused row
    GuiControlGet, FocusedControl, FocusV
    ;get content of cell 1 and cell 2
    if FocusedControl <> MyListView
    {
        LV_GetText(RowText11, 1,1)
        LV_GetText(RowText12, 1,2)
      }
    Else
    {
      FocusRow:=LV_GetNext(0, "Focused")
      LV_GetText(RowText11, FocusRow,1)
      LV_GetText(RowText12, FocusRow,2)
    }
    FileDestDir:=RowText12 . "\" . RowText11
  Return

  lblGetSourcePath:
  ; get path of current dir by copying under-cursor file(s)
    Clipboard=
    Send, ^c
    ClipWait, 2
    If(ErrorLevel)
    {
      MsgBox, , Alert, clip fail, 1
      Reload
    }
    SourceFilePath=%Clipboard%
    IfInString, SourceFilePath, `n  ;selectec more than one file
    {
      StringSplit, SourceFileArr, SourceFilePath , `n, `r
      SourceFileNum:=SourceFileArr0
    }
    Else
    {
      SourceFileNum:=1
      SourceFileArr1:=SourceFilePath
    }
    SourceFileDir:=GetFileDirByPath(SourceFileArr1)
  Return
  GetFileDirByPath(FileFullPath)
  {
    StringGetPos, LastSlashPos, FileFullPath, \ ,R
    StringLeft, FileDir, FileFullPath, LastSlashPos
    return,FileDir
  }
  Return
  GetFileNameByPath(FileFullPath)
  {
    StringGetPos, LastSlashPos, FileFullPath, \ ,R
    StringRight, FileName, FileFullPath, strLen(FileFullPath)-LastSlashPos-1
    return,FileName
  }
  Return
  lblMoveFile:
    loop, %SourceFileNum%
    {
      SourceFilePath:=SourceFileArr%A_Index%
      FileMove, %SourceFilePath%, %FileDestDir%, 1
    }
  Return
  lblGetActive_TC_Path:
    ControlGetText, TC_Path_R, TPathPanel2, ahk_class TTOTAL_CMD
    ControlGetText, TC_Path_L, TPathPanel1, ahk_class TTOTAL_CMD
  Return

  ButtonLoadFolder:
      Folder:=SourceFileDir

      g_nMatchCount := 0
      WinSetTitle, , , %g_strTitle% [%g_nMatchCount% of %g_nFilesCount%]

      GuiControl, Disable, BtnLoadFolder
      SetTimer, FileLoadProgressTimer, 100

      g_arrResult := ; Free the memory
      g_nFilesCount := GenList(Folder, "g_arrResult")

      Gosub, OnChangeSearchString

      Gui +LastFound
      GuiControl, Enable, BtnLoadFolder
      SetTimer, FileLoadProgressTimer, Off
  return

  OnChangeSearchString:
      GuiControl, -Redraw, MyListView  ; Improve performance by disabling redrawing during load.
      nMatchCount := g_nFilesCount
      bNeedSetFocus := false
      If (g_nFilesCount > 0)
    {
          GuiControlGet, strSearchPattern, , EditSearchString

          strSearchPattern := RegExReplace(strSearchPattern, "S)[\s]+", "|")  ; Replace multiple whitespaces with a single character
          if(strSearchPattern = "" || strSearchPattern = "|")
        {
              ; Nothing is entered, select the first one
              g_MatchIndices = -1
              bNeedSetFocus := true
          }
          Else
        {
              If ( SubStr(strSearchPattern, StrLen(strSearchPattern)) == "|")
                  strSearchPattern := SubStr(strSearchPattern, 1, StrLen(strSearchPattern)-1)
              StringSplit, arrSearchPatterns, strSearchPattern, |

              g_MatchIndices =
              VarSetCapacity(g_MatchIndices, g_nFilesCount * 4)

              nMatchCount := 0

              Loop, %g_nFilesCount%
            {
                  strName := g_arrResult%A_Index%_1
                  bMatch := true
                  Loop %arrSearchPatterns0%
                {
                      if ( !IsMatch(strName,  arrSearchPatterns%A_Index%) )
                    {
                          bMatch := false
                          Break
                      }
                  }
                  if (bMatch)
                {
                      NumPut(A_Index, g_MatchIndices, nMatchCount * 4)
                      ++nMatchCount
                  }
              }
          }
      }
      Else
    {
          g_MatchIndices = -1
      }
      g_nMatchCount := nMatchCount
      ListView_SetItemCount(g_hMyListView, g_nMatchCount)
      ListView_RedrawItems(g_hMyListView, 0, -1)
      ;ToolTip, Done searching %strSearchPattern%

      LV_ModifyCol()  ; Auto-size each column to fit its contents.
      GuiControl, +Redraw, MyListView  ; Re-enable redrawing (it was disabled above).

      If (bNeedSetFocus)
    {
          GuiControl, Focus, SysListView321,
          Send, {Home}
          GuiControl, Focus, EditSearchString,
      }

      WinSetTitle, , , %g_strTitle% [%g_nMatchCount% of %g_nFilesCount%]
  Return

  IsMatch(ByRef strFileName, strSubPattern)
{
      chChar1         := SubStr(strSubPattern, 1, 1)
      chChar2         := SubStr(strSubPattern, 2, 1)
      bIsExclude      := chChar1 == "-" || chChar2 == "-"

      strSubPattern := RegExReplace(strSubPattern, "S)^[-\\]+")
      If (strSubPattern = "")
          return true

      bMatch          := InStr(strFileName, strSubPattern)
      if (bIsExclude)
          bMatch := !bMatch

      return bMatch
  }

  FileLoadProgressTimer:
      Gui +LastFound
      WinSetTitle, , , %g_strTitle% [%g_nMatchCount% of %g_nFilesCount%]
  Return

/*
  typedef struct tagNMHDR
  {
      HWND  hwndFrom;
      UINT  idFrom;
      UINT  code;         // NM_ code
  }   NMHDR;

   NMHDR *pnm
  */
 OnNotify(idCtrl, pnmh)
{
   Static HDN_BEGINTRACKA     := -306 ; (HDN_FIRST - 6)
   Static HDN_BEGINTRACKW     := -326 ; (HDN_FIRST - 26)
          M := NumGet(pnmh + 8, 0, "Int")
          If (M = HDN_BEGINTRACKA) || (M = HDN_BEGINTRACKW)
         Return True ; prevent sizing   各列禁止改变尺寸

	global g_hMyListView, LVN_GETDISPINFO
   Critical, 300
	hwndFrom := NumGet(pnmh + 0, "UPtr")
	if ( hwndFrom == g_hMyListView )
	{
		idFrom := NumGet(pnmh + A_PtrSize, "UPtr" )
		ncode := NumGet(pnmh + A_PtrSize, A_PtrSize, "Int")
		if ( nCode == LVN_GETDISPINFO )
		{
			OnGetDispInfo(pnmh)
		}
    }
}

/*
  NMLVDISPINFO* pnmv

  typedef struct tagNMLVDISPINFO {
      NMHDR hdr;
      LVITEM item;
  } NMLVDISPINFO;

  typedef struct _LVITEM {
      UINT mask;     0
      int iItem;     4
      int iSubItem;  8
      UINT state;    12
      UINT stateMask; 16
      LPTSTR pszText; 20
      int cchTextMax; 24
      int iImage;     28
      LPARAM lParam;
  #if (_WIN32_IE >= 0x0300)
      int iIndent;
  #endif
  #if (_WIN32_WINNT >= 0x560)
      int iGroupId;
      UINT cColumns; // tile view columns
      PUINT puColumns;
  #endif
  #if (_WIN32_WINNT >= 0x0600)
      int* piColFmt;
      int iGroup;
  #endif
  } LVITEM, *LPLVITEM;

  */
  OnGetDispInfo(pnmv)
{
	global
	iItemOffset		:= sizeofNMHDR + 4
	iItem			:= NumGet(pnmv + 0, iItemOffset, "UInt")

	if (iItem < 0 || iItem > g_nMatchCount)
		return	; requesting invalid item

	maskOffset		:= sizeofNMHDR + 0
	mask			:= NumGet(pnmv + maskOffset, "UInt")

	if (mask & LVIF_TEXT)
	{
		iSubItemOffset	:= sizeofNMHDR + 8
		iSubItem		:= NumGet(pnmv + iSubItemOffset, "UInt")

		pszTextOffset	:= sizeofNMHDR + 20 + A_PtrSize - 4
		pszText			:= NumGet(pnmv + pszTextOffset, "UInt")

		If (g_MatchIndices = -1)
			nIndex := iItem + 1
		else
			nIndex := NumGet(g_MatchIndices, iItem * 4, "UInt")

		pstrText := 0
		if (0 == iSubItem)
			pstrText := &g_arrResult%nIndex%_Name
		Else if (1 == iSubItem)
			pstrText := &g_arrResult%nIndex%_Folder
		Else if (2 == iSubItem)
			pstrText := &g_arrResult%nIndex%_Modified
		Else if (3 == iSubItem)
			pstrText := &g_arrResult%nIndex%_SizeKB
		Else if (4 == iSubItem)
			pstrText := &g_arrResult%nIndex%_Ext
		NumPut(pstrText, pnmv + pszTextOffset, "Ptr")
	}
	if (mask & LVIF_STATE)
	{
		stateOffset := sizeofNMHDR + 12
		NumPut(0, pnmv + stateOffset, "UInt")
	}
	if (mask & LVIF_IMAGE)
	{
		iImageOffset := sizeofNMHDR + 24 + A_PtrSize + A_PtrSize - 4
		NumPut(-1, pnmv + iImageOffset, "Int")
	}
}
  GenList(ByRef strFolder, arrResultName, ByRef strExtInclude = "", ByRef strExtExclude = "", bRecursive = true)
{
      global  ; This is important for creating/accessing array
      nTotalFiles := 0
      nIndex := g_nFilesCount+1

      ; Check if the last character of the folder name is a backslash, which happens for root
      ; directories such as C:\. If it is, remove it to prevent a double-backslash later on.
      StringRight, LastChar, strFolder, 1
      if LastChar = \
          StringTrimRight, strFolder, strFolder, 1  ; Remove the trailing backslash.

      ; Ensure the variable has enough capacity to hold the longest file path. This is done
      ; because ExtractAssociatedIconA() needs to be able to store a new filename in it.
      ;VarSetCapacity(Filename, 260)
      sfi_size = 352
      VarSetCapacity(sfi, sfi_size)

      ; Gather a list of file names from the folder
      ;Loop %strFolder%\*.*, 0, %bRecursive%
      Loop, %strFolder%\*.*, 2  ; %bRecursive%
    {
          ; Name|In Folder|Modified|Size (KB)|Type
          FormatTime, FileTimeModified, %A_LoopFileTimeModified% LSys R D1    ;, MM/dd/yyyy HH:mm

		StrPutVar(A_LoopFileName, %arrResultName%%nIndex%_Name, "UTF-16")
		StrPutVar(A_LoopFileExt, %arrResultName%%nIndex%_Ext, "UTF-16")
		StrPutVar(A_LoopFileDir, %arrResultName%%nIndex%_Folder, "UTF-16")
		StrPutVar(FileTimeModified, %arrResultName%%nIndex%_Modified, "UTF-16")
		StrPutVar(A_LoopFileSizeKB, %arrResultName%%nIndex%_SizeKB, "UTF-16")

          ; We need this for pattern matching
          %arrResultName%%nIndex%_1 := A_LoopFileName

          ++nIndex
          ++nTotalFiles
          ++g_nFilesCount
      }
      return nTotalFiles
  }

  #IfWinActive ahk_class AutoHotkeyGUI
  ~Up::
  ~+Up::
      IfWinNotActive, ahk_id %g_hMainWnd%,
    {
          Send, {Up}
          Return
      }

      GuiControl, Focus, SysListView321,
      ;ControlSend, SysListView321, {Up}, %g_hMainWnd%
  Return

  ~Down::
  ~+Down::
      IfWinNotActive, ahk_id %g_hMainWnd%,
    {
          Send, {Down}
          Return
      }

      GuiControl, Focus, SysListView321,
      ;ControlSend, SysListView321, {Down}, %g_hMainWnd%
  Return
  #IfWinActive

  ;;;;;;;;;;;;;;;;;;; Helper Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ListView_RedrawItems(hwndLV, iFirst, iLast)
{
      global LVM_REDRAWITEMS
      SendMessage, LVM_REDRAWITEMS, iFirst, iLast, , ahk_id %hwndLV%
      return %ErrorLevel%
  }

  ListView_SetItemCount(hwndLV, cItems)
{
      global LVM_SETITEMCOUNT, LVSICF_NOINVALIDATEALL
      SendMessage, LVM_SETITEMCOUNT, cItems, LVSICF_NOINVALIDATEALL, , ahk_id %hwndLV%
      return %ErrorLevel%
  }

  StrPutVar(string, ByRef var, encoding)
{
    ; Ensure capacity.
    VarSetCapacity( var, StrPut(string, encoding)
        ; StrPut returns char count, but VarSetCapacity needs bytes.
        * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    ; Copy or convert the string.
    return StrPut(string, &var, encoding)
}
