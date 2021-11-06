defaultSet =
	( LTrim
		动作_名称=鼠标手势重启
		动作_轨迹=右下左上;右下左上右
		动作_提示=重启鼠标手势
		动作_条件模式=通用
		动作_生效条件=
		动作_模式=标签
		动作_命令=鼠标手势重启
		动作_启用=1
	)
SplitPath, A_ScriptFullPath,,,,SecName
MG_WriteIni(SecName, defaultSet)
return

鼠标手势重启:
reload
return