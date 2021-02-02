Cando_EditTi:
IniRead, Candy_Cmd, %run_iniFile%, % uid, Ti_%uid%_leftClick
IniRead, TiTooltip, %run_iniFile%, % uid, Ti_%uid%_tooltip
IniRead, IconfileAndNum, %run_iniFile%, % uid, Ti_%uid%_Icon
Array := StrSplit(Candy_Cmd, "|")
Gui,66:Default
Gui,Destroy
Gui, Add, Text, x10 y10 w200 h20 , 托盘图标文件（格式为 路径:编号）
gui, add, picture, vicon x210 y1,% Ti_%uid%_icon
Gui, Add, Edit, x10 y30 w400 h20 vIconfileAndNum gload, % IconfileAndNum
Gui, Add, Text, x10 y60 w200 h20 , 托盘提示文字
Gui, Add, Edit, x10 y80 w400 h20 vTiTooltip, % TiTooltip

Gui, Add, Text, x10 y110 w80 h20 , 左键动作选择
Gui, Add, DropDownList, x10 y130 w100 h100 vinterface gupdate_cmd, Cando|Keys|Menu|Run|RunCanfunc
Gui, Add, Text, x10 y160 w120 h20 , 参数/文件/命令/标签
Gui, Add, Edit, x10 y180 w400 h20 vvars gupdate_cmd,% Array[2] Array[3] 
Gui, Add, Text, x10 y210 w120 h20, 配置
Gui, Add, Edit, x10 y230 w400 h40 vcmd ReadOnly

Gui, Add, Button, x300 y280 w60 h30 gwriteini,确认
Gui, Add, Button, x360 y280 w60 h30 g66GuiClose,取消

Gui Show, ,%uid% 图标左键动作编辑
GuiControl, ChooseString, interface, % Array[1]
gosub load
gosub update_cmd
Return

update_cmd:
	gui, submit, nohide
	cmd := ""
	cmd := interface "|" vars
	guicontrol,, cmd, % cmd
Return

load:
gui, submit, nohide
StringGetPos, Num, IconfileAndNum, :, R1
if (Num=1) or  (Num=-1)
tmpstr := "*icon1 " IconfileAndNum
else
{
Iconfile:=SubStr(IconfileAndNum, 1, Num)
IconNum:=SubStr(IconfileAndNum, Num+2) + 1
tmpstr := "*icon" IconNum " " Iconfile
}
;tooltip % Num "`n" tmpstr
guicontrol,, icon, % tmpstr
guicontrol, show, icon
return

writeini:
gui, submit, nohide
IniWrite, %IconfileAndNum%, %run_iniFile%, %uid%, Ti_%uid%_icon
IniWrite, %TiTooltip%, %run_iniFile%, %uid%, Ti_%uid%_tooltip
IniWrite, %cmd%, %run_iniFile%, %uid%, Ti_%uid%_leftClick
hIcon := TrayIcon_loadIcon(IconfileAndNum, 32)
TrayIcon_Set(HGui, uid, hIcon, , , TiTooltip)
Gui,Destroy
return