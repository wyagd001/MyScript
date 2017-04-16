addfavorites:
Loop, parse, A_GuiEvent, `n, `r
{
   Gui, Submit, NoHide
   tempworkdir:=A_WorkingDir

   w = %A_ScriptDir%\favorites
   SetWorkingDir, %w%
   ifNotExist, %Dir%
   {
   msgbox,没有选择文件或文件夹。
   SetWorkingDir,%tempworkdir%
   ;tooltip, % A_WorkingDir
   return
   }

   SplitPath,Dir, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
   InputBox,shortName,,请输入快捷方式的名称?,,,,,,,,%OutNameNoExt%
   if ErrorLevel{
   SetWorkingDir,%tempworkdir%
   ;tooltip, % A_WorkingDir
   return
   }
   else
   {
   IfExist,%w%\%shortName%.lnk
   {
   msgbox,4,,同名的快捷方式已经存在，是否替换?
   IfMsgBox No
   {
   SetWorkingDir,%tempworkdir%
   ;tooltip, % A_WorkingDir
   return
   }
   else{
   FileCreateShortcut,%dir%,%shortName%.lnk,%w%
   return
   }
   }
   FileCreateShortcut,%dir%,%shortName%.lnk,%w%
   SetWorkingDir,%tempworkdir%
   ;tooltip, % A_WorkingDir
   return
}
return
}
return

showfavorites:
   tempworkdir:=A_WorkingDir
   w2 = %A_ScriptDir%\favorites
   SetWorkingDir, %w2%
   kShortcutExt = lnk

FileCount := 0
Loop, %A_WorkingDir%\*.%kShortcutExt%,,   ; for each shortcut in the directory, add a menu item for it
{
   FileCount++
   SplitPath,A_LoopFileName, , , , menuName2
   Menu, mymenu2, Add, %menuName2%, RunThisMenuItem
}

if(FileCount != 0)
Menu, mymenu2, Add

FileCount := 0
Loop, %A_ScriptDir%\Favorites\*, 2    ;获取文件夹
{
FileCount := 0
Filename_%FileCount%:=A_LoopFileName
fname:=Filename_%FileCount%

FileList =
   Loop, %A_ScriptDir%\Favorites\%fname%\*.lnk  ;不排序默认顺序  ntfs 字母   fat32  按创建时间排序
    FileList = %FileList%%A_LoopFileName%`n
      Sort, FileList     ;排序  ntfs 字母   fat32  按创建时间排序
      Loop, parse, FileList, `n
      {
      if A_LoopField =  ; Ignore the blank item at the end of the list.
      continue
      FileCount++
      SplitPath,A_LoopField, , , , pos
      Menu, %fname%, add, %pos%, MenuHandler   ; 创建子菜单项。
       }
if(FileCount != 0)                          ;忽略空的子文件夹，否则出错
Menu,mymenu2, add, %fname%, :%fname%  ; 创建父菜单项。
}
 Menu, mymenu2, Add
 Menu, mymenu2, Add,管理收藏,o
Menu,mymenu2,show
Menu,mymenu2,deleteall
SetWorkingDir,%tempworkdir%
;tooltip, % A_WorkingDir
/*
Loop, %w2%\*.*, 2, 0
{
    FileCount := 0
     Foldname := A_LoopFileName
     Loop, %w2%\%Foldname%\*.lnk, 0, 0
     {
        FileCount++
     }
     if(FileCount != 0)
     Menu,%Foldname%,Deleteall
}
*/
return

o:
run %A_ScriptDir%\favorites
return

RunThisMenuItem:
; Runs the shortcut corresponding to the last selected tray meny item
    Run %A_ThisMenuItem%.%kShortcutExt%
    return

MenuHandler:   ;运行程序
RunFileName = %A_ScriptDir%\favorites\%A_ThisMenu%\%A_ThisMenuItem%.lnk
run, %RunFileName%,,UseErrorLevel
        if ErrorLevel
        MsgBox,,,系统找不到指定的文件。,3
Return    ;重载