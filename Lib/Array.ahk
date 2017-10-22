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

;String Things by tidbit
;https://autohotkey.com/boards/viewtopic.php?f=6&t=53&sid=5c401643235e7a2e73d769f1e5deac0f
Array_ToString(array, depth=5, indentLevel="")
{
   for k,v in Array
   {
      list.= indentLevel "[" k "]"
      if (IsObject(v) && depth>1)
         list.="`n" Array_ToString(v, depth-1, indentLevel . "    ")
      Else
         list.=" => " v
      list.="`n"
   }
   return rtrim(list)
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

;SortArray function from https://sites.google.com/site/ahkref/custom-functions/sortarray
Array_Sort(Array, Order="R") {
    ;Order A: Ascending, D: Descending, R: Reverse
    MaxIndex := ObjMaxIndex(Array)
    If (Order = "R") {
        count := 0
        Loop, % MaxIndex 
            ObjInsert(Array, ObjRemove(Array, MaxIndex - count++))
        Return
    }
    Partitions := "|" ObjMinIndex(Array) "," MaxIndex
    Loop {
        comma := InStr(this_partition := SubStr(Partitions, InStr(Partitions, "|", False, 0)+1), ",")
        spos := pivot := SubStr(this_partition, 1, comma-1) , epos := SubStr(this_partition, comma+1)    
        if (Order = "A") {    
            Loop, % epos - spos {
                if (Array[pivot] > Array[A_Index+spos])
                    ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))    
            }
        } else {
            Loop, % epos - spos {
                if (Array[pivot] < Array[A_Index+spos])
                    ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))    
            }
        }
        Partitions := SubStr(Partitions, 1, InStr(Partitions, "|", False, 0)-1)
        if (pivot - spos) > 1    ;if more than one elements
            Partitions .= "|" spos "," pivot-1        ;the left partition
        if (epos - pivot) > 1    ;if more than one elements
            Partitions .= "|" pivot+1 "," epos        ;the right partition
    } Until !Partitions
}
