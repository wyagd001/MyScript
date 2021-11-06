defaultSet =
	( LTrim
		动作_名称=鼠标手势退出
		动作_轨迹=右下左
		动作_提示=退出鼠标手势
		动作_条件模式=通用
		动作_生效条件=
		动作_模式=标签
		动作_命令=鼠标手势退出
		动作_启用=1
	)
SplitPath, A_ScriptFullPath,,,,SecName
MG_WriteIni(SecName, defaultSet)
return

鼠标手势退出:
ExitApp
return