defaultSet =
	( LTrim
		动作_名称=桌面关闭
		动作_轨迹=下右
		动作_提示=关闭桌面(关机)
		动作_条件模式=特定窗口
		动作_生效条件=Progman;Shell_TrayWnd
		动作_模式=标签
		动作_命令=桌面关闭
		动作_启用=1
	)
SplitPath, A_ScriptFullPath,,,,SecName
MG_WriteIni(SecName, defaultSet)
return

桌面关闭:
  WinClose ahk_class Progman
return