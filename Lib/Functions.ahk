IsStingFunc(str:="")
{
	strfunc:=StrSplit(str,"(")
	If IsFunc(strfunc[1])
	return 1
	else
	return 0
}

RunStingFunc(str:="")
{
	strfunc:=StrSplit(str, "(", ")")
	tempfunc:=strfunc[1]
	params:=StrSplit(strfunc[2], ",")
	if (params.MaxIndex() = "")
	{
		%tempfunc%()
	return
	}
	else if (params.MaxIndex() = 1)
	{
		%tempfunc%(params[1])
	return
	}
	else if (params.MaxIndex() = 2)
	{
		%tempfunc%(params[1],params[2])
	return
	}
	else if (params.MaxIndex() = 3)
	{
		%tempfunc%(params[1],params[2],params[3])
	return
	}
	else (params.MaxIndex() = 4)
	{
		%tempfunc%(params[1],params[2],params[3],params[4])
	return
	}
}