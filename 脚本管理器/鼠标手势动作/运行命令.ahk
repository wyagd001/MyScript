defaultSet =
	( LTrim
		动作_名称=记事本
		动作_轨迹=上下
		动作_提示=打开记事本
		动作_条件模式=通用
		动作_生效条件=
		动作_模式=函数
		动作_命令=MGA_Run|notepad
		动作_启用=1
	)
SplitPath, A_ScriptFullPath,,,,SecName
MG_WriteIni(SecName, defaultSet)
return

MGA_Run(file)
{
run %file%
return
}