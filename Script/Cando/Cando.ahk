;Cando 脚本中的界面统一使用编号66
66GuiClose:
66Guiescape:
	Gui,66:Destroy
Return

Cando_保存到桌面:
	FileAppend,%CandySel%,%A_Desktop%\%A_Now%.txt
return

Cando_保存并运行:
	FileDelete,%A_Desktop%\temp.ahk
	FileAppend,%CandySel%`r`n,%A_Desktop%\temp.ahk
	Run,%A_Desktop%\temp.ahk,%A_Desktop%
Return

Cando_10秒A版U版主程序交换:
FileMove,D:\Program Files\AutoHotkey\AutoHotkey_La.exe,D:\Program Files\AutoHotkey\AutoHotkey-La.exe
sleep,500
FileMove,D:\Program Files\AutoHotkey\AutoHotkey_Lu.exe,D:\Program Files\AutoHotkey\AutoHotkey_La.exe
tooltipnum=10
loop,10{
toolTip,%tooltipnum%s
tooltipnum--
sleep,1000
toolTip
}
tooltipnum=
FileMove,D:\Program Files\AutoHotkey\AutoHotkey_La.exe,D:\Program Files\AutoHotkey\AutoHotkey_Lu.exe
sleep,500
FileMove,D:\Program Files\AutoHotkey\AutoHotkey-La.exe,D:\Program Files\AutoHotkey\AutoHotkey_La.exe
return

Cando_10秒A版Basic版主程序交换:
FileMove,D:\Program Files\AutoHotkey\AutoHotkey_La.exe,D:\Program Files\AutoHotkey\AutoHotkey-La.exe
sleep,800
FileMove,D:\Program Files\AutoHotkey\AutoHotkey.exe,D:\Program Files\AutoHotkey\AutoHotkey_La.exe
tooltipnum=10
loop,10{
toolTip,%tooltipnum%s
tooltipnum--
sleep,1000
toolTip
}
tooltipnum=
FileMove,D:\Program Files\AutoHotkey\AutoHotkey_La.exe,D:\Program Files\AutoHotkey\AutoHotkey.exe
sleep,800
FileMove,D:\Program Files\AutoHotkey\AutoHotkey-La.exe,D:\Program Files\AutoHotkey\AutoHotkey_La.exe
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

Cando_查看Dll内函数:
msgbox,,Dll文件内函数列表, % DllListExports(CandySel)
return
