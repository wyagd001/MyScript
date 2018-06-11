addfavorites:
Loop, parse, A_GuiEvent, `n, `r
{
   Gui, Submit, NoHide
   myfav = %A_ScriptDir%\favorites
   ifNotExist, %Dir%
   {
   msgbox,没有选择文件或文件夹。
   return
   }

   SplitPath,Dir, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
   InputBox,shortName,,请输入快捷方式的名称?,,,,,,,,%OutNameNoExt%
   if ErrorLevel{
   return
   }
   else
   {
   IfExist,%myfav%\%shortName%.lnk
   {
   msgbox,4,,同名的快捷方式已经存在，是否替换?
   IfMsgBox No
   return
   else{
   FileCreateShortcut,%dir%,%myfav%\%shortName%.lnk
   return
   }
   }
   FileCreateShortcut,%dir%,%myfav%\%shortName%.lnk
   return
}
return
}
return

showfavorites:
   myfav = %A_ScriptDir%\favorites
   kShortcutExt = lnk
; 变量 menushowicon  控制菜单是否显示图标
; 快捷方式文件太多菜单如果显示图标的话，菜单弹出速度变慢
menushowicon=0  

FileCount := 0
Loop, %myfav%\*.%kShortcutExt%,,   ; for each shortcut in the directory, add a menu item for it
{
   FileCount++
   SplitPath,A_LoopFilePath, , , , menuName2
   Menu, mymenu2, Add, %menuName2%, RunThisMenuItem
    SplitPath, A_LoopFilePath, , , , menuName,      ; remove extension
    Menu, mymenu2, Add, %menuName%, RunThisMenuItem
    FileGetShortcut, %A_LoopFilePath%, OutItem, , , , OutIcon, OutIconNum
			try{
				if(OutIcon){
					Menu,mymenu2,Icon,%menuName%,%OutIcon%,%OutIconNum%
				}else{
					Menu,mymenu2,Icon,%menuName%,%OutItem%
				}
			} catch e {
				Menu,mymenu2,Icon,%menuName%,shell32.dll,1
			}
}

if(FileCount != 0)
Menu, mymenu2, Add

FileCount := 0
Loop, %myfav%\*, 2    ;获取文件夹
{
fname:=A_LoopFileName
FileList =
   Loop, %myfav%\%fname%\*.lnk  ;不排序默认顺序  ntfs 字母   fat32  按创建时间排序
    FileList = %FileList%%A_LoopFileName%`n
      Sort, FileList     ;排序  ntfs 字母   fat32  按创建时间排序
      Loop, parse, FileList, `n
      {
      if A_LoopField =  ; Ignore the blank item at the end of the list.
      continue
      FileCount++
      SplitPath,A_LoopField, , , , pos
      Menu, %fname%, add, %pos%, MenuHandler   ; 创建子菜单项。
if menushowicon  
{
    FileGetShortcut, %myfav%\%fname%\%A_LoopField%, OutItem, , , , OutIcon, OutIconNum
			try{
				if(OutIcon){
					Menu,%fname%,Icon,%pos%,%OutIcon%,%OutIconNum%
				}else{
          if InStr(FileExist(OutItem), "D")
					Menu,%fname%,Icon,%pos%,%a_scriptdir%\pic\candy\extension\folder.ico
					else
					Menu,%fname%,Icon,%pos%,%OutItem%
				}
			} catch e {
				Menu,%fname%,Icon,%pos%,shell32.dll,1
			}
}
       }
if(FileCount != 0)                          ;忽略空的子文件夹，否则出错
Menu,mymenu2, add, %fname%, :%fname%  ; 创建父菜单项。
}
 Menu, mymenu2, Add
 Menu, mymenu2, Add,管理收藏,o
Menu,mymenu2,show
Menu,mymenu2,deleteall
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
run %myfav%
return

RunThisMenuItem:
; Runs the shortcut corresponding to the last selected tray meny item
    Run %myfav%\%A_ThisMenuItem%.%kShortcutExt%
        if ErrorLevel
        MsgBox,,,系统找不到指定的文件。,3
    return

MenuHandler:   ;运行程序
RunFileName = %myfav%\%A_ThisMenu%\%A_ThisMenuItem%.lnk
run, %RunFileName%,,UseErrorLevel
        if ErrorLevel
        MsgBox,,,系统找不到指定的文件。,3
Return    ;重载