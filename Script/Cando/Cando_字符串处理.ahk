Cando_变大写:
	clipmonitor := 0
	Clipboard =
	StringUpper Clipboard, CandySel
	Send ^v
	Clipboard := CandySel_Rich
	clipmonitor := 1
Return

Cando_变小写:
	clipmonitor := 0
	Clipboard =
	StringLower Clipboard, CandySel
	Send ^v
	Clipboard := CandySel_Rich
	clipmonitor := 1
Return

Cando_首字大写:
	clipmonitor := 0
	;StringUpper Clipboard, CandySel, T
	Clipboard =
	Loop, Parse, CandySel, %A_Space%_`,|;-！`.  
	{  
		; 计算分隔符的位置.  
		Position += StrLen(A_LoopField) + 1
		; 获取解析循环中找到的分隔符.  
		Delimiter := SubStr(CandySel, Position, 1)
		str1 := Format("{:T}", A_LoopField)
		out := out . str1 . Delimiter 
	}  
	Clipboard := out  
	Send, ^v
	Clipboard := CandySel_Rich
	out := Position := ""
	clipmonitor := 1
Return

Cando_括起来:
	clipmonitor := 0
	StringSplit, kql_Arr, A_ThisMenuItem, %A_Space%
	Clipboard := CandySel
	send {del}{%kql_Arr1%}
	Send,^v
	send {%kql_Arr2%}
	Clipboard := CandySel_Rich
	clipmonitor := 1
Return

Cando_等号对齐:
	clipmonitor := 0
	LimitMax:=30     ;左侧超过该长度时，该行不参与对齐，该数字可自行修改
	MaxLen:=0
	StrSpace:=" "
	Loop,% LimitMax+1
		StrSpace .=" "
	Aligned:=
	loop, parse, CandySel, `n,`r                   ;首先求得左边最长的长度，以便向它看齐
	{
		IfNotInString,A_loopfield,=              ;本行没有等号，过
			Continue
		ItemLeft :=RegExReplace(A_LoopField,"\s*(.*?)\s*=.*$","$1")        ;本条目的 等号 左侧部分
		;ThisLen:=StrLen(regexreplace(ItemLeft,"[^\x00-\xff]","11"))       ;本条左侧的长度
		ThisLen:=DllCall("MSVCRT.DLL\strlen", "AStr", ItemLeft)       ;本条左侧的长度
		MaxLen:=( ThisLen > MaxLen And ThisLen <= LimitMax) ? ThisLen : MaxLen       ;得到小于LimitMax内的最大的长度，这个是最终长度
	}
	loop, parse, CandySel, `n,`r
	{
		IfNotInString,A_loopfield,=
		{
			Aligned .= A_loopfield "`r`n"
			Continue
		}
		ItemLeft:=trim(RegExReplace(A_LoopField,"\s*=.*?$") )        ;本条目的 等号 左侧部分
		Itemright:=trim(RegExReplace(A_LoopField,"^.*?=")  )          ;本条目的 等号 右侧部分
		ThisLen:=StrLen(regexreplace(ItemLeft,"[^\x00-\xff]","11"))   ;本条左侧的长度
		if ( ThisLen> MaxLen )       ;如果本条左侧大于最大长度，注意是最大长度，而不是LimitMax，则不参与对齐
		{
			Aligned .= ItemLeft  "= " Itemright "`r`n"
			Continue
		}
		Else
		{
			Aligned .= ItemLeft . SubStr( StrSpace, 1, MaxLen+2-ThisLen ) "= " Itemright "`r`n"        ;该处给右侧等号后添加了一个空格，根据需求可删
		}
	}
	Aligned:=RegExReplace(Aligned,"\s*$","")   ;顺便删除最后的空白行，可根据需求注释掉
	clipboard := Aligned
	Send ^v
	Aligned:=""
	clipmonitor := 1
Return