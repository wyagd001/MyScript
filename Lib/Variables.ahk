f_DerefPath(ThisPath)
{
	StringReplace, ThisPath, ThisPath, ``, ````, All
	StringReplace, ThisPath, ThisPath, `%F_CurrentDir`%, ```%F_CurrentDir```%, All
	Transform, ThisPath, deref, %ThisPath%
	return ThisPath
}

; 解析用户、系统环境变量
; ppath 为 不带引号的文本或百分号包围的文本
ExpandEnvVars(ppath)
{
	VarSetCapacity(dest, 2000)
	DllCall("ExpandEnvironmentStrings", "str", ppath, "str", dest, int, 1999, "Cdecl int")
	Return dest
}