#NoEnv
SetBatchLines -1
ListLines Off
Sys=HKLM
sys1=HKEY_LOCAL_MACHINE

Menu, Context, Add, 浏览文件位置, PlayLV

Gui, Add, Button,gLoadw,刷新列表(&R)
Gui, Add, Button, x+15 gEditVar, 编辑/创建项目(&C)
Gui, Add, Button, x+15 gDelVar, 删除该项目(&D)
Gui, Add, Button, x+15 gUser, 切换到用户/系统(&U)
Gui, Add, Button, x+15 gRegedit, 跳转到注册表(&O)
Gui, Add, Button, x+20 gAbout, 关于(&A)
Gui, Add, ListView, xm Grid w600 h400 gListView vEV Altsubmit,自定义命令|路径|浏览
Gui, +AlwaysOnTop
Gui,Show,,自定义运行命令
Gui +resize

Gui 2:Add, Text,,项目名称
Gui 2:Add, Edit,vVarname w250
Gui 2:Add, Text,, 程序路径
Gui 2:Add, Edit,vVarvalue w250
Gui 2:Add, Button,x+5  gselectfile,&.
Gui 2:Add, Button,x10 gVarsave w280,写入注册表(&S)

Gui,2:+Owner1 +ToolWindow +AlwaysOnTop


WinW = 500
XPos1 := WinW  - 100
XPos2 := XPos1 + 40
Gui 3:Font,s14,Arial
text=版本：1.0。 该Autohotkey脚本修改于env.ahk。用途：通过修改注册表，自定义“运行”命令，"运行"中输入自定义命令，快速打开程序。
Gui 3:+ToolWindow +AlwaysOnTop
Gui 3:Add, Text,vtext4 x%XPos2% y35 BackgroundTrans , %text%
Gui 3:Add, Text,x0 y5 w%winw% center, 自定义运行命令
GuiControlGet,Text4,3:Pos
Text4H+=10
Gui 3:Add, Text, vText1 w4024 h%Text4H% x-1524 y30
GuiControl,3:+0x12,Text1

Gosub,Loadw
Return

selectfile:
FileSelectFile,tt,,,选择文件
GuiControl,, Varvalue, %tt%
GuiControl,choose,dir,%tt%
Return

GuiEscape:
GuiClose:
Critical
 ExitApp
return

GuiSize:
if A_EventInfo = 1
    return
GuiControl, Move, EV, % "H" . (A_GuiHeight - 45) . "W" . (A_GuiWidth - 20)
return

Loadw:

LV_Delete()
Loop,%Sys%,SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths,0,1
{
    RegRead, value
    IfNotInString, value,.exe
    Continue
    StringGetPos,num,A_LoopRegSubKey,\,R
    num++
    StringTrimLeft,syskey,A_LoopRegSubKey,%num%
    LV_Add("",syskey,value,"浏览")
    LV_ModifyCol()
}
return

Varsave:
Gui 2:Submit
RegWrite,REG_SZ,%Sys%,SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%varname%,,%varvalue%
WinActivate,Environment Variables Editor
send,!R
Return

EditVar:
FocusedRowNumber := LV_GetNext(0, "F")
if not FocusedRowNumber
{
gui 2:show,,创建新的项目
varname=
varvalue=
}
else{
LV_GetText(varname, FocusedRowNumber, 1)
LV_GetText(varvalue, FocusedRowNumber, 2)
gui 2:show,,编辑运行命令
}
GuiControl,2:,varname,% varname
GuiControl,2:,varvalue,% varvalue
Return

DelVar:
FocusedRowNumber := LV_GetNext(0, "F")
if not FocusedRowNumber
   {
    MsgBox,,错误,未选择要删除的项目！
    Return
}
Else{
LV_GetText(varname, FocusedRowNumber, 1)
MsgBox,4129,警告,是否确认删除"%varname%"这个项目？该操作无法撤销，请慎重。
IfMsgBox,Yes
{
    RegDelete,%Sys%,SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%varname%
sleep,1000
Gosub,loadw
}
}
Return

Regedit:
RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, %Sys1%\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths
Run, regedit.exe
Return

3GuiEscape:
3GuiClose:
    AboutX = 1
Return

About:
Gui 3:Show, w%WinW% h70, 关于
XPos2 := WinW - 60
    GuiControl 3:Move, Text4, x%XPos2%
    Loop {
       GuiControl 3:Move, Text4,% "x" XPos2--
       GuiControlGet Text4, 3:Pos
       Sleep 1
       If (text4X + text4W < 0 || AboutX) {
          AboutX =
          Break
       }
    }
    Gui 3:Hide
Return

User:
if Sys=HKLM
{
Sys=HKCU
sys1=HKEY_CURRENT_USER
}
Else
{
Sys=HKLM
sys1=HKEY_LOCAL_MACHINE
}
Gosub,Loadw
Return

ListView:
if (A_GuiEvent = "RightClick")
{
	rrownum:=A_EventInfo
	Menu, Context, Show
}
else if (A_GuiEvent = "DoubleClick")
	gosub,EditVar
return

PlayLV:
LV_GetText(Mdir, rrownum, 2)
abcd=explorer.exe /select, "%Mdir%"
Transform,abcd,Deref,%abcd%
Run,%abcd%
return