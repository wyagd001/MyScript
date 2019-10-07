; https://github.com/oblitum/Interception/
; cmd 命令行管理员权限运行安装驱动 Bin文件夹中 install-interception.exe /install
; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=26306

Class Interception {
	static _Init := Interception.Init()
	static _InitDelFunc := OnExit( ObjBindMethod(Interception, "UnloadDll") )

	Init() {
		; win7 系统下没有使用，主要用于 win10 关机, 结束任务页面
		if SubStr(A_OSVersion,1,3) != "10."
		return
		this.Ensure_Admin()

		this.dll := (A_PtrSize = 8) ? A_ScriptDir "\interception_x64.dll" : A_ScriptDir "\interception_x32.dll"
		this.hModule := DllCall("LoadLibrary", "Str", this.dll, "Ptr")
		this.context := DllCall(this.dll . "\interception_create_context")
		Return True
	}

	Ensure_Admin() {
		full_command_line := DllCall("GetCommandLine", "str")

		if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
		{
			try
			{
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
			}
		}
}

	; device 设备号  键盘 (1-10) 鼠标 (11-20)
	send(key, nstroke, device:=""){
		if !devivce
		{
			loop 3
			{
				if this.get_hardware_id(A_index)
				{
					device := A_index
					Break
				}
			}
		}

		hkey := key2dec(key)
		VarSetCapacity(stroke, 4)
		NumPut(hkey, stroke, 0, "Ushort")

		res:=DllCall(this.dll . "\interception_send", "Ptr", this.context, "int", device, "ptr", &stroke, "int", nstroke, "Cdecl Int")
	return res
}

	UnloadDll() {
		if this.hModule {
			DllCall(this.dll . "\interception_destroy_context", "Ptr", this.context)
			DllCall("FreeLibrary", "Ptr", this.hModule)
		}
		ExitApp
	}

	get_hardware_id(device:=1)
	{
		Critical
		VarSetCapacity(buffer,500)

		if (a_ptrsize > 4)
			DllCall(this.dll . "\interception_get_hardware_id", "Ptr", this.context, "int", device, "str", buffer, "Uint", 500, "Cdecl Int")
		else
			DllCall(this.dll . "\interception_get_hardware_id", "Ptr", this.context, "int", device, "ptr", &buffer, "Uint", 500, "Cdecl Int")

		return a_ptrsize > 4 ? buffer : StrGet(&buffer, "UTF-16")
	}

	GetDeviceListStr()
	{
		devlist := ""
		this.Set_Filter(this.context, "keyboard","KEY_NONE")
		Loop 20
			devlist .= A_Index " """ this.Get_Hardware_ID(A_Index) """`n"
	Return devlist
	}

set_filter(filter,keys){
Static keyboard:="interception_is_keyboard"
,mouse:="interception_is_mouse"
,KEY_DOWN           		= 0x00
,KEY_UP             		= 0x01
,KEY_NONE             	= 0x0000
,KEY_ALL              	= 0xFFFF
,KEY_E0              		= 0x02 ;Delete Key
,KEY_E1              		= 0x04
,KEY_TERMSRV_SET_LED 		= 0x08
,KEY_TERMSRV_SHADOW  		= 0x10
,KEY_TERMSRV_VKPACKET 	= 0x20
,FILTER_KEY_NONE             = 0x0000
,FILTER_KEY_ALL              = 0xFFFF
,FILTER_KEY_DOWN             := KEY_UP
,FILTER_KEY_UP               := KEY_UP << 1
,FILTER_KEY_E0               := KEY_E0 << 1
,FILTER_KEY_E1               := KEY_E1 << 1
,FILTER_KEY_TERMSRV_SET_LED  := KEY_TERMSRV_SET_LED << 1
,FILTER_KEY_TERMSRV_SHADOW   := KEY_TERMSRV_SHADOW << 1
,FILTER_KEY_TERMSRV_VKPACKET := KEY_TERMSRV_VKPACKET << 1
,MOUSE_NONE              = 0x0000
,MOUSE_ALL               = 0xFFFF
,MOUSE_LEFT_BUTTON_DOWN  = 0x001
,MOUSE_LEFT_BUTTON_UP    = 0x002
,MOUSE_RIGHT_BUTTON_DOWN = 0x004
,MOUSE_RIGHT_BUTTON_UP   = 0x008
,MOUSE_MIDDLE_BUTTON_DOWN= 0x010
,MOUSE_MIDDLE_BUTTON_UP  = 0x020
,MOUSE_BUTTON_1_DOWN     := MOUSE_LEFT_BUTTON_DOWN
,MOUSE_BUTTON_1_UP       := MOUSE_LEFT_BUTTON_UP
,MOUSE_BUTTON_2_DOWN     := MOUSE_RIGHT_BUTTON_DOWN
,MOUSE_BUTTON_2_UP       := MOUSE_RIGHT_BUTTON_UP
,MOUSE_BUTTON_3_DOWN     := MOUSE_MIDDLE_BUTTON_DOWN
,MOUSE_BUTTON_3_UP       := MOUSE_MIDDLE_BUTTON_UP
,MOUSE_BUTTON_4_DOWN     = 0x040
,MOUSE_BUTTON_4_UP       = 0x080
,MOUSE_BUTTON_5_DOWN     = 0x100
,MOUSE_BUTTON_5_UP       = 0x200
,MOUSE_WHEEL             = 0x400
,MOUSE_HWHEEL            = 0x800
,MOUSE_MOVE              = 0x1000
,MOUSE_MOVE_RELATIVE      = 0x000
,MOUSE_MOVE_ABSOLUTE      = 0x001
,MOUSE_VIRTUAL_DESKTOP    = 0x002
,MOUSE_ATTRIBUTES_CHANGED = 0x004
,MOUSE_MOVE_NOCOALESCE    = 0x008
,MOUSE_TERMSRV_SRC_SHADOW = 0x100

	if Instr(keys,"|")
	{
		loop,parse,keys,|
		{
			key:=%a_loopfield%
			if a_index=1
				keys2:=key
			else
				keys2:=keys2|key
		}
		keys:=keys2
	}
	else
		keys:=%keys%

	f:=this.get_pointer(%filter%)
	DllCall(this.dll . "\interception_set_filter", "ptr", this.context, "ptr", f, "int", keys, "Cdecl Int")
}

get_pointer(func){
	return DllCall("GetProcAddress", ptr, this.hModule, "astr", func, ptr)
}
}

key2dec(name){
hex:=GetKeySC(name)
return dec2hex(hex)
}
