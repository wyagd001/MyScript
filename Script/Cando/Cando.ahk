;Cando 脚本中的界面统一使用编号66
66GuiClose:
66Guiescape:
	Gui,66:Destroy
	if deltts
	{
		SoundPlay, none
		FileDelete, %A_SCRIPTDIR%\Settings\tmp\tts.mp3
		dletts=0
	}
Return

Cando_保存到桌面:
	FileAppend,%CandySel%,%A_Desktop%\%A_Now%.txt
return

Cando_保存并运行:
	FileDelete,%A_Desktop%\temp.ahk
	FileAppend,%CandySel%`r`n,%A_Desktop%\temp.ahk
	Run,%A_Desktop%\temp.ahk,%A_Desktop%
Return

Cando_10秒U版A版主程序交换:
FileMove,% ahklu,% ahklu ".bak"
sleep,500
FileMove,% ahkla,% ahklu
tooltipnum=10
loop,10{
toolTip,%tooltipnum%s
tooltipnum--
sleep,1000
}
toolTip
tooltipnum=
FileMove,% ahklu,% ahkla
sleep,500
FileMove,% ahklu ".bak",% ahklu
return

Cando_10秒U版Basic版主程序交换:
FileMove,% ahklu,% ahklu ".bak"
sleep,800
FileMove,% ahk,% ahklu
tooltipnum=10
loop,10{
toolTip,%tooltipnum%s
tooltipnum--
sleep,1000
}
toolTip
tooltipnum=
FileMove,% ahklu,% ahk
sleep,800
FileMove,% ahklu ".bak",% ahklu
return

cando_迅雷下载:
StringGetPos,zpos,CandySel,/,R
zpos++
StringTrimLeft,sFile,CandySel,%zpos%
try {
	thunder := ComObjCreate("ThunderAgent.Agent")
	thunder.AddTask( CandySel ;下载地址
			       , sFile  ;另存文件名
			       , "N:\"  ;保存目录
			       , sFile  ;任务注释
			       , ""  ;引用地址
			       , 1 ;开始模式
			       , true  ;只从原始地址下载
			       , 10 )  ;从原始地址下载线程数
	thunder.CommitTasks()
}
Return

Cando_发送路径到对话框:
ControlSetText , edit1, %CandySel%, ahk_class #32770
return