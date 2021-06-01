OnTrayIcon(uid, Event)
{
	if event not in R,L
	return

	if (Event = "L")
	{
		FuncsIcon_ClickRun(uid,"L")
		return
	}
	if (Event = "R")
	{
		FuncsIcon_ClickRun(uid,"R")
		return
	}
}

FuncsIcon_ClickRun(uid,Event)
{
global Candy_Cmd,candysel
ClickRun:=(Event="l")?"leftClick":(Event="r")?"rightClick":""
IniRead, Candy_Cmd, %run_iniFile%, % uid, Ti_%uid%_%ClickRun%

candysel:="托盘图标*" uid
	If !(RegExMatch(Candy_Cmd,"i)^Menu\|"))
	{
		Gosub Label_Candy_RunCommand            ; 如果不是menu指令，直接跳转到运行应用程序
	}
	else
		Gosub Label_Candy_DrawMenu
return
}

removeTi:
sleep 500
TrayIcon_Remove(hGui, uid)
return