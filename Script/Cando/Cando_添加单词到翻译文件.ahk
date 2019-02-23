Cando_添加单词到翻译文件:
	Gui,66:Default
	Gui,Destroy
	Gui, add, text,x5 ,英文单词:
	Gui, Add, edit, x+10 Veword  w250,%CandySel%
	Gui, add, text,x5 ,中文翻译:
	Gui, Add, edit, x+10 Vctrans  w250,% json(YouDaoApi(CandySel), "basic.explains")
	Gui, Add, Button,x250  w65 h20 -Multi Default gwtranslist,确认写入
	Gui, Show, ,单词翻译写入文件
return

wtranslist:
	Gui,Submit,NoHide
	if ctrans
		IniWrite,% ctrans,%A_ScriptDir%\settings\translist.ini,翻译,% eword
	Gui,Destroy
return