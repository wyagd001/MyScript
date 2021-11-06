defaultSet =
	( LTrim
		动作_名称=窗口最小化
		动作_轨迹=下
		动作_提示=窗口最小化
		动作_条件模式=非特定窗口
		动作_生效条件=Progman;Shell_TrayWnd
		动作_模式=标签
		动作_命令=窗口最小化
		动作_启用=1
	)
SplitPath, A_ScriptFullPath,,,,SecName
MG_WriteIni(SecName, defaultSet)
return

窗口最小化:
  WinMinimize, ahk_id %h_id%
return