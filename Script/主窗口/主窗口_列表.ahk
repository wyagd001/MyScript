;目标文件夹的文件列表
liebiao:
if !TargetFolder or !FileExist(TargetFolder)
{
TargetFolder=
IniWrite,%TargetFolder%, %run_iniFile%,常规, TargetFolder
msgbox,没有设置目标文件夹，请拖拽文件夹到窗口或选择一个文件夹。
return
}

rootdir := TargetFolder       ;快捷方式目录
updatealways =1      ;1自动刷新，0禁止自动刷新
SetTimer,ini,500
TrayTip,目录菜单,初始化进行中
if updatealways = 1
   gosub createdatabase
else
{
ifnotexist %A_ScriptDir%\settings\tmp\folderlist.txt
   gosub, createdatabase
}

if !C_error
{
Menu,DirMenu,add,%rootdir%,godir
Menu,DirMenu,disable,%rootdir%
Menu,DirMenu,add,-`:`:打开 目录`:`:-,godir
goto createmenu
}
C_error=0
return

CreateMenu:
Loop, Read, %A_ScriptDir%\settings\tmp\folderlist.txt
{

   isfile = 0
   StringReplace,Line,A_LoopReadLine,%rootdir%\,
   ifinstring Line,.
      isfile = 1

   if isfile = 0
   {
      StringGetPos,pos,Line,\,R
      StringLeft,pardir,Line,%pos%
      StringReplace,dir,Line,%pardir%,
      StringReplace,dir,dir,\
      Menu,%Line%,add,-`:`:打开 目录`:`:-,godir

      if pardir =
         pardir = DirMenu
      Menu,%pardir%,add,%dir%,:%Line%
   }
   else
   {
      StringGetPos,pos,Line,\,R
      StringLeft,pardir,Line,%pos%
      StringReplace,file,Line,%pardir%,
      StringReplace,file,file,\
      if pardir =
         pardir = DirMenu
      Menu,%pardir%,add,%file%,go
   }
}
SetTimer,ini,off
TrayTip
Menu,DirMenu,show
Menu,DirMenu,Deleteall
return

go:
   if A_ThisMenu = DirMenu
      run %rootdir%\%A_ThisMenuItem%
   else
      run %rootdir%\%A_ThisMenu%\%A_ThisMenuItem%
return

godir:
if A_ThisMenu = DirMenu
      run %rootdir%
   else
      run %rootdir%\%A_ThisMenu%
return

createdatabase:
settimer,kill_process1,-6000
   runwait, %comspec% /c dir /s /b /os /a:d "%rootdir%" > "%A_ScriptDir%\settings\tmp\folderlist.txt",,hide,cpid1
   runwait, %comspec% /c dir /s /b /os /a:-d "%rootdir%" >> "%A_ScriptDir%\settings\tmp\folderlist.txt",,hide,cpid2
return

ini:
   TrayTip,目录菜单,初始化进行中,30
return

kill_process1:
Process,Exist,%cpid1%
settimer,kill_process2,-1000
if ErrorLevel 
{
Process,Close,%cpid1%
SetTimer,ini,off
}
return

kill_process2:
Process,Exist,%cpid2%
if ErrorLevel 
{
SetTimer,ini,off
TrayTip,目录菜单创建失败, 选定文件夹内文件过多`n无法创建目录文件列表，线程超时退出。
Process,Close,%cpid2%
FileRecycle, %A_ScriptDir%\settings\tmp\folderlist.txt
C_error=1
}
return