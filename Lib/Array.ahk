Array_removeDuplicates(InputArray)
{
	for i, ival in InputArray
	{
		for r, rval in InputArray
		{
			if (r > i && ival = rval)
				InputArray.Remove(i)
		}
	}
}

Array_ToString(array) {
	for i, key in array
		outstr .= key . "`n"
	return outstr
}

Array_writeToINI(InputArray,sectionINI, fileName, removeDupes:=false)
{
	if removeDupes = 1
	{
		Array_removeDuplicates(InputArray)  ; start at position 13 to avoid date & time stamp
	}
	IniDelete, %fileName%, %sectionINI%
	sleep 10
	Loop % InputArray.MaxIndex()
	{
		k := InputArray[A_Index]
		IniWrite, %k%, %fileName%, %sectionINI%
	}
}