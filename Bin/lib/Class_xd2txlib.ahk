; http://ebstudio.info/home/xdoc2txt.html
Class xd2txlib {
Static xd2txlibdll := A_ScriptDir . "\..\Dll\" . (A_PtrSize=8 ? "xd2txlib_x64.dll" : "xd2txlib_x32.dll")

get_Init()
{
return this._Init
}

Init()
{
	static dll_mem
	if !dll_mem
	{
		dll_mem := DllCall("LoadLibrary", "Str", this.xd2txlibdll, "Ptr")
		if !dll_mem
    {
      this._Init := 0
      return 0
    }
    else
    {
      this.hModule := dll_mem
      this._Init := 1
      return 1
    }
	}
}

Uninit()
{
this._Init := 0
DllCall("FreeLibrary", "Ptr", this.hModule)
}

ExtractText(file)
{
	if !this._Init
	{
		this.Init()
		if !this._Init
		return 0
	}

  fileText:=""
  i:=DllCall(this.xd2txlibdll "\ExtractText", "Str", file, "int", 0, "int*", fileText)
  return StrGet( fileText, i / 2 )
}
}