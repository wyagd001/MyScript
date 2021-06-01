Class TTLib {
Static TTLibdll := A_ScriptDir . (A_PtrSize=8 ? "\TTLib64.dll" : "\TTLib32.dll")

get_Init()
{
return this._Init
}

Init()
{
	static dll_mem
	if !dll_mem
	{
		dll_mem := DllCall("LoadLibrary", "Str", this.TTLibdll, "Ptr")
		if !dll_mem
		return 0
	}

	if !this._Init
	{
		if (DllCall(this.TTLibdll "\TTLib_Init") = 0)
		{
			this._Init := 1
		return 1
		}
		else
		{
			this._Init := 0
		return 0
		}
	}
}

Uninit()
{
this._Init := 0
DllCall(this.TTLibdll "\TTLib_Uninit")
}

LoadIntoExplorer()
{
	; 0 表示成功, 1 没有初始化, 2 已经装载, 106 无法获得模块句柄(已经装载)
	if !This._LoadInto
  {
		tmp_val := DllCall(this.TTLibdll "\TTLib_LoadIntoExplorer")
		if (tmp_val = 0)
		{
			This._LoadInto := 1
		return 1
		}
		else
		{
			;fileappend % "tmp_val: " tmp_val "`n", %A_desktop%\log.txt
			This.UnloadFromExplorer()
		return 0
		}
	}
}

UnloadFromExplorer()
{
This._LoadInto := 0
DllCall(this.TTLibdll "\TTLib_UnloadFromExplorer")
}

GetTrackedButtonWindow()
{
	if !this._Init
	{
		this.Init()
    ;fileappend % "_Init: " this._Init "`n",%A_desktop%\log.txt
		if !this._Init
		return 0
	}
	if !This._LoadInto
	{
		this.LoadIntoExplorer()
    ;fileappend % "_LoadInto: " this._LoadInto "`n",%A_desktop%\log.txt
		if !this._LoadInto
	return 0
	}
  Critical
	; 返回 1 表示成功
	tmp_val := DllCall(this.TTLibdll "\TTLib_ManipulationStart")
	if (tmp_val!=1)
	{
    ;fileappend % "tmp_val: " tmp_val "`n",%A_desktop%\log.txt
    DllCall(this.TTLibdll "\TTLib_ManipulationEnd")
		this.UnloadFromExplorer()
	return 0
	}
	hTaskbar := DllCall(this.TTLibdll "\TTLib_GetMainTaskbar")
	;fileappend % "hTaskbar: " hTaskbar "`n",%A_desktop%\log.txt
	if !hTaskbar
	{
		DllCall(this.TTLibdll "\TTLib_ManipulationEnd")
	return 0
	}
	hTrackedButton:=DllCall(this.TTLibdll "\TTLib_GetTrackedButton", "uint", hTaskbar)
	;fileappend % "hTrackedButton: " hTrackedButton "`n", %A_desktop%\log.txt
	if !hTrackedButton
	{
		DllCall(this.TTLibdll "\TTLib_ManipulationEnd")
	return 0
	}
	h_id := DllCall(this.TTLibdll "\TTLib_GetButtonWindow", "uint", hTrackedButton)
	;fileappend % "h_id: " h_id "`n",%A_desktop%\log.txt
	DllCall(this.TTLibdll "\TTLib_ManipulationEnd")
	;DllCall(this.TTLibdll "\TTLib_UnloadFromExplorer")
	return h_id
}

GetActiveButtonWindow()
{
	if !this._Init
	{
		this.Init()
		if !this._Init
		return 0
	}
	if !This._LoadInto
	{
		this.LoadIntoExplorer()
		if !this._LoadInto
	return 0
	}

	; 返回 1 表示成功
	tmp_val := DllCall(this.TTLibdll "\TTLib_ManipulationStart")
	;fileappend % "tmp_val: " tmp_val "`n",%A_desktop%\log.txt
	if (tmp_val!=1)
	{
    DllCall(this.TTLibdll "\TTLib_ManipulationEnd")
		this.UnloadFromExplorer()
	return 0
	}
	hTaskbar := DllCall(this.TTLibdll "\TTLib_GetMainTaskbar")
	;fileappend % "hTaskbar: " hTaskbar "`n",%A_desktop%\log.txt
	if !hTaskbar
	{
		DllCall(this.TTLibdll "\TTLib_ManipulationEnd")
	return 0
	}
	; 
	hActiveButton:=DllCall(this.TTLibdll "\TTLib_GetActiveButton", "uint", hTaskbar)
	;fileappend % "hActiveButton: " hActiveButton "`n",%A_desktop%\log.txt
	if !hActiveButton
	{
		DllCall(this.TTLibdll "\TTLib_ManipulationEnd")
	return 0
	}
	h_id := DllCall(this.TTLibdll "\TTLib_GetButtonWindow", "uint", hActiveButton)
	;fileappend % "h_id: " h_id "`n",%A_desktop%\log.txt
	DllCall(this.TTLibdll "\TTLib_ManipulationEnd")
	;DllCall(this.TTLibdll "\TTLib_UnloadFromExplorer")
	return h_id
}

GetActiveButtonGroupAppid()
{
	if !this._Init
	{
		this.Init()
		if !this._Init
		return 0
	}
	if !This._LoadInto
	{
		this.LoadIntoExplorer()
		if !this._LoadInto
	return 0
	}

	; 返回 1 表示成功
	tmp_val := DllCall(this.TTLibdll "\TTLib_ManipulationStart")
	if (tmp_val!=1)
	{
    DllCall(this.TTLibdll "\TTLib_ManipulationEnd")
		this.UnloadFromExplorer()
	return 0
	}
	hTaskbar := DllCall(this.TTLibdll "\TTLib_GetMainTaskbar")
	if !hTaskbar
	{
    DllCall(this.TTLibdll "\TTLib_ManipulationEnd")
	return 0
	}
	hActiveButtonGroup := DllCall(this.TTLibdll "\TTLib_GetActiveButtonGroup", "Uint", hTaskbar)
  if !hActiveButtonGroup
	{
		DllCall(this.TTLibdll "\TTLib_ManipulationEnd")
	return 0
	}
	varsetcapacity(hButtonGroupAppid, 256)
	size := DllCall(this.TTLibdll "\TTLib_GetButtonGroupAppId", "Uint", hActiveButtonGroup, "Str", hButtonGroupAppid, "Uint", 256)
	DllCall(this.TTLibdll "\TTLib_ManipulationEnd")
 return hButtonGroupAppid
}

/*
List
0 按钮文本
1 按钮分组
2 显示锁定的按钮
3 按钮合并

ListValue
0 
1 系统默认
*/
AddAppIdToList(iList, iAppId, iListValue)
{
	if !this._Init
	{
		this.Init()
		if !this._Init
		return 0
	}
	if !This._LoadInto
	{
		this.LoadIntoExplorer()
		if !this._LoadInto
	return 0
	}
	return DllCall(this.TTLibdll "\TTLib_AddAppIdToList", "int", iList, "Str", iAppId, "int", iListValue, "int")
}
}