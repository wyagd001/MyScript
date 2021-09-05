defaultSet =
	( LTrim
		动作_名称=窗口移到左半屏幕
		动作_轨迹=左
		动作_提示=窗口移到左半屏幕
		动作_条件模式=非特定窗口
		动作_生效条件=Progman;Shell_TrayWnd
		动作_模式=标签
		动作_命令=窗口移到左半屏幕
		动作_启用=1
	)
SplitPath, A_ScriptFullPath,,,,SecName
MG_WriteIni(SecName, defaultSet)
return

窗口移到左半屏幕:
  WinGet, state, MinMax, ahk_id %h_id%
  if (state = 1)
    WinRestore, ahk_id %h_id%
  WinMove, ahk_id %h_id%,, 0, 0, WMAwidth / 2, WMAHeight
return