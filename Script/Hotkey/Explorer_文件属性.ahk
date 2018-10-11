/*
原脚本已被修改
名称： F1键修改文件属性扩展名和文件时间(资源管理器加强)
作者： dule2859
帖子： http://forum.ahkbbs.cn/thread-979-1-1.html
*/

;#IfWinActive,ahk_group ccc
;F4::    ;;用F4修改文件属性
修改文件属性:
clipold = %Clipboard%
clipboard=
Send,^c
ClipWait, 0.5
if ErrorLevel
{
    clipboard=%clipold%
    IniRead,  failsendkey, %run_iniFile%,快捷键, 修改文件属性
    Send,{%failsendkey%}
    Return
}
files=%clipboard%
Clipboard=%clipold%
StringSplit,ary, files ,`n,`r
curpath = %ary1%
If ary0=1
{
      FileGetAttrib,attributes,%ary1%
      If ErrorLevel
      {
        MsgBox 文件不存在或没有访问权限
        Return
      }
      IfNotInString, attributes ,D
      {
        Gosub,GuiSingleFile
        Return
      }
}
  Gosub,GuiMultiFile
Return
;#IfWinActive

GuiSingleFile:
Gui,6:Default
Gui,Destroy
Gui,Submit 
gui,+AlwaysOnTop +Owner +LastFound -MinimizeBox 
WinSetTitle,,,文件属性修改
Gui,Add,CheckBox,xm vReadOnly,只读(&R)
Gui,Add,CheckBox,xp+100 yp vHidden,隐藏(&H)
Gui,Add,CheckBox,xm vSystem vSystem,系统(&S)
Gui,Add,CheckBox,xp+100 yp vArchive,存档(&A)
Gui,Add,Text,xm yp+30,文件名：
Gui,Add,Edit,xp+50  H20 W120 vname_no_ext
Gui,Add,Text,xm yp+30,扩展名：
Gui,Add,Edit,xp+50 yp H20 W120 vExt
Gui,Add,Button,xm yp+30 W80 gRegOpenFile,打开注册表
Gui,Add,Button,xp+100 yp W80 gFileChangeDate,修改日期
Gui,Add,Button,xm yp+30 W80 gSingleInit,撤销修改
Gui,Add,Button,xp+100 yp W80 gSingleApply Default,执行修改
Gosub,SingleInit
Gui,Show,W200 H180
Return

RegOpenFile:
Gui,Submit,NoHide
RegRead,var,HKCR,.%ext%
If ErrorLevel
    Return
RegWrite,REG_SZ,HKCU,Software\Microsoft\Windows\CurrentVersion\Applets\Regedit,Lastkey,HKEY_CLASSES_ROOT\.%ext%
run,regedit.exe
Return

SingleInit:
FileGetAttrib,attributes,%curpath%
IfInString, attributes, H
  GuiControl, ,Hidden,1
Else
  GuiControl, ,Hidden,0
IfInString, attributes, R
  GuiControl, ,ReadOnly,1
Else
  GuiControl, ,ReadOnly,0
IfInString, attributes, S
  GuiControl, ,System,1
Else
  GuiControl, ,System,0
IfInString, attributes, A
  GuiControl, ,Archive,1
Else
  GuiControl, ,Archive,0

/*
StringGetPos, i, curpath, \ ,R
StringLen,n,curpath
StringRight,fullname,curpath,n-i-1
StringGetPos, i, fullname, . ,R
StringLen,n,fullname
StringLeft,name,fullname,i
StringRight,ext,fullname,n-i-1
*/
SplitPath, curpath,,newpath, ext, name_no_ext

GuiControl,,name_no_ext,%name_no_ext%
GuiControl,,ext,%ext%
Return

SingleApply:
Gui,Submit
Gosub,GetAttributes
FileSetAttrib,%pattern%,%curpath%,1,1
;StringGetPos, i, curpath, \ ,R
;StringLeft,newpath,curpath,i
newpath2 =
if !ext
newpath2 = %newpath%\%name_no_ext%
newpath = %newpath%\%name_no_ext%.%ext%
If (newpath2 = curpath) or (newpath = curpath)
 {
  Gui,Destroy
  Return
 }
IfExist,%newpath%
  MsgBox,4112,错误,相同文件已经存在，重命名失败。,3
If(newpath != curpath) and !FileExist(newpath)
  FileMove,%curpath%,%newpath%,0
Gui,Destroy
Return

GetAttributes:
GuiControlGet,bool,,Hidden
If  bool
pattern =%pattern%+H
Else
pattern =%pattern%-H
GuiControlGet,bool,,ReadOnly
If  bool
pattern =%pattern%+R
Else
pattern =%pattern%-R
GuiControlGet,bool,,System
If  bool
pattern =%pattern%+S
Else
pattern =%pattern%-S
GuiControlGet,bool,,Archive
If  bool
pattern =%pattern%+A
Else
pattern =%pattern%-A
Return

FileChangeDate:
Gui,Destroy
Gui,Submit
gui, +AlwaysOnTop   +Owner +LastFound -MinimizeBox
WinSetTitle,,,文件时间修改
Gui,Add,Radio,group xm+20 checked H20 Section  vOrder gGetTime,修改时间
Gui,Add,Radio,xp+80 yp H20 gGetTime,创建时间
Gui,Add,Radio,xp+80 yp H20 gGetTime,访问时间
Gui, Add, DateTime, vMyDateTime xm+10 yp+30,'Date:' yyyy-MM-dd   'Time:' HH:mm:ss
Gui,Add,Button,xm+30 yp+30 gGetTime,撤销修改
Gui,Add,Button,xp+80 yp gCurTime,当前时间
Gui,Add,Button,xp+80 yp gFileSetTime Default,执行修改
GoSub,GetTime
Gui,Show,W300 H100
Return

GetTime:
Gui,Submit,NoHide
if order=1
    timetype=M
else if order=2
    timetype=C
else
    timetype=A
FileGetTime,temptime,%curpath%,%timetype%
GuiControl,,MyDateTime,%temptime%
Return

CurTime:
GuiControl,,MyDateTime,%A_Now%
Return

FileSetTime:
Gui,Submit
if order=1
    timetype=M
else if order=2
    timetype=C
else
    timetype=A
FileSetTime,%MyDateTime%,%curpath%,%timetype%
If recurse = 1
{
  FileGetAttrib,attributes,%curpath%
  {
    IfInString, attributes ,D
      {
         Loop,%curpath%\*.*,1,1
          {
            FileSetTime,%MyDateTime%,%A_LoopFileFullPath%,%timetype%
          }
      }
  }
}
Return

GuiMultiFile:
Gui,6:Default
Gui,Destroy
Gui,Submit 
Gui,+AlwaysOnTop   +Owner +LastFound -MinimizeBox
WinSetTitle,,,文件属性修改
Gui,Add,CheckBox,xm vReadOnly,只读(&R)
Gui,Add,CheckBox,xp+100 yp vHidden,隐藏(&H)
Gui,Add,CheckBox,xm vSystem vSystem,系统(&S)
Gui,Add,CheckBox,xp+100 yp vArchive,存档(&A)
Gui,Add,CheckBox,xm yp+25 vRecurse Checked,是否将修改应用到子文件
Gui,Add,Button,xm yp+20 W80 gShowFile,查看文件
Gui,Add,Button,xp+100 yp W80 gMultiDate,修改日期
Gui,Add,Button,xm yp+30 W80 gMultiInit,撤销修改
Gui,Add,Button,xp+100 yp W80 gMultiApply Default,执行修改
Gosub,MultiInit
Gui,Show
Return

MultiInit:
FileGetAttrib,attributes,%ary1%
IfInString, attributes, H
  GuiControl, ,Hidden,1
Else
  GuiControl, ,Hidden,0
IfInString, attributes, R
  GuiControl, ,ReadOnly,1
Else
  GuiControl, ,ReadOnly,0
IfInString, attributes, S
  GuiControl, ,System,1
Else
  GuiControl, ,System,0
IfInString, attributes, A
  GuiControl, ,Archive,1
Else
  GuiControl, ,Archive,0
Return

ShowFile:
CF_ToolTip(files,1000)
Return

MultiDate:
Gui,6:Default
Gui,Destroy
Gui,Submit 
gui,+AlwaysOnTop   +Owner +LastFound -MinimizeBox
WinSetTitle,,,文件时间修改
Gui,Add,Radio,group xm+20 checked H20 Section  vOrder gGetTime,修改时间
Gui,Add,Radio,xp+80 yp H20 gGetTime,创建时间
Gui,Add,Radio,xp+80 yp H20 gGetTime,访问时间
Gui,Add,CheckBox,xm+20  H20 vRecurse Checked,是否将修改应用到子文件
Gui, Add, DateTime, vMyDateTime xm+10 yp+30,'Date:' yyyy-MM-dd   'Time:' HH:mm:ss
Gui,Add,Button,xm+30 yp+30 gGetTime,撤销修改
Gui,Add,Button,xp+80 yp gCurTime,当前时间
Gui,Add,Button,xp+80 yp gMultiSetTime Default,执行修改
Gosub,GetTime
Gui,Show,W300 H120
Return

MultiSetTime:
Loop,%ary0%
{
  curpath := ary%A_Index%
  Gosub,FileSetTime
}
Return

MultiApply:
Gui,Submit
Gosub,GetAttributes
Loop,%ary0%
{
  curpath := ary%A_Index%
  FileSetAttrib,%pattern%,%curpath%
  If Recurse = 1
  {
    FileGetAttrib,attributes,%curpath%
    IfInString, attributes ,D
    {
      FileSetAttrib,%pattern%,%curpath%\*.*,1,1
    }
  }
}
Gui,Destroy
Return

6GuiClose:
6GuiEscape:
Gui,Destroy
Return

;资源管理器F2重命名时，原生功能按Tab跳转到下一个文件
;#IfWinActive,ahk_group ccc
;!F2::
修改文件名扩展名:
MouseGetPos,,, win
filerename:
clipold = %Clipboard%
clipboard=
Send,^c
ClipWait, 0.5
if ErrorLevel
{
    clipboard=%clipold%
    Return
}
files=%clipboard%
Clipboard=%clipold%
StringSplit,ary, files ,`n,`r
curpath = %ary1%
If ary0=1
{
      FileGetAttrib,attributes,%ary1%
      If ErrorLevel
      {
        MsgBox 文件不存在或没有访问权限
        Return
      }
      IfNotInString, attributes ,D
      {
        Gosub,FilerenameGui
        Return
      }
}
Return
;#IfWinActive

FilerenameGui:
Gui,25:Default
Gui,Destroy
Gui,Submit 
gui,+AlwaysOnTop   +Owner +LastFound -MinimizeBox
WinSetTitle,,,文件名修改
Gui,Add,Text,xm yp+10,文件名：
Gui,Add,Edit,xp+50  H20 W220 vname_no_ext
Gui,Add,Text,xm yp+30,扩展名：
Gui,Add,Edit,xp+50 yp H20 W220 vExt
Gui,Add,Button,xm yp+30 W60 gFilePrex,上一个(&P)
Gui,Add,Button,xm+70 yp W60 gFileNext,下一个(&N)
Gui,Add,Button,xm+140 yp W100 gApplyOff Default,修改`&&关闭(&S)
Gosub,SingleInit2
Gui,Show,W300 H100
Return

FilePrex:
Gosub,ApplyOff
WinActivate, ahk_id %win%
send,{Up}
Gosub,filerename
Return

FileNext:
Gosub,ApplyOff
WinActivate, ahk_id %win%
send,{Down}
Gosub,filerename
Return

SingleInit2:
SplitPath, curpath,,newpath, ext, name_no_ext

GuiControl,,name_no_ext,%name_no_ext%
GuiControl,,ext,%ext%
Return

ApplyOff:
Gui,Submit
charsToRemove =
(
\\
/
:
*
?
<
>
"
|
)

name_no_ext := RegExReplace(name_no_ext,"[" . charsToRemove . "]")
newpath2 =
if !ext
newpath2 = %newpath%\%name_no_ext%
newpath = %newpath%\%name_no_ext%.%ext%

If ((newpath = curpath) or (newpath2 = curpath))
{
Gui,Destroy
Return
}
IfExist,%newpath%
  MsgBox,4112,错误,该文件名%newpath%-%newpath%已经存在!,3
else
  FileMove,%curpath%,%newpath%,0
Gui,Destroy
Return

25GuiClose:
25GuiEscape:
Gui,Destroy
Return