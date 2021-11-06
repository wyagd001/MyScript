defaultSet =
	( LTrim
		动作_名称=发送按键
		动作_轨迹=右下
		动作_提示=发送Shift
		动作_条件模式=通用
		动作_生效条件=
		动作_模式=函数
		动作_命令=MGA_SendKey|{Shift}
		动作_启用=1
	)
SplitPath, A_ScriptFullPath,,,,SecName
MG_WriteIni(SecName, defaultSet)
return

MGA_SendKey(Key)
{
if !WinActive("ahk_id" h_id)
	WinActivate ahk_id %h_id%
send %Key%
return
}