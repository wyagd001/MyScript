StrAr_Add(Str,It) ;添加元素
{
	ReturnVal=%Str%|%It%
	Return ReturnVal
}

StrAr_Get(Str,witch) ;返回元素
{
	global Spliter
	
	Str:=_StrAr_Format(Str)
	Pos1:=0
	Loop %witch%
	{
		StringGetPos,Pos1,Str,|,,Pos1
		Pos1++
	}
	StringLeft,Var,Str,Pos1-1
;~ 	MsgBox %Var%
	StringGetPos,Pos2,Var,|,R
;~ 	MsgBox %Var% %Pos2%
	Dis:=Pos1-Pos2-2
;~ 	MsgBox %Pos2%-%Pos1%=%Dis%
	StringRight,Var,Var,Dis
;~ 	MsgBox [%Var%]
	Return Var	
}

StrAr_Find(Str,item) ;返回找到制定元素的次数
{
;~ 	MsgBox %Str% [%item%]
	StringReplace,Str,Str,%item%,%item%,UseErrorLevel
	Return ErrorLevel
}

StrAr_Size(Str) ;返回元素个数
{
	Str:=_StrAr_Format(Str)
;~ 	MsgBox %Str%
	Count:=0
	Pos:=1
	Loop
	{
		pos:=RegExMatch(Str,"\|",a,Pos+1)
		IfEqual,pos,0,break
		Count++		
;~ 		MsgBox %Count% %pos%
	}
;~ 	MsgBox %Count% 
	Return Count	
}
_StrAr_Format(Str)	;将字符格式化为 A|B|C| 处理的标准格式
{
;~ 	MsgBox %Str%
	V:=Str
	StringLeft,VL,Str,1		;获取左边第一个字符	
	StringRight,VR,Str,1	;获取右边第一个字符
	If(VL="|")
	{
		StringTrimLeft,V,V,1
	}
	If(VR<>"|")
	{
		V=%V%|
	}
	
	StringReplace,V,V,||,|,All
;~ 	MsgBox %V%
	Return V
}


StrAr_Delet(Str,index) ;删除
{
	Str:=_StrAr_Format(Str)
	Element:=StrAr_Get(Str,index)
	Element=%Element%|
	StringReplace,NewStr,Str,%Element%
	Return NewStr
}

StrAr_DeletElement(Str,Element,IsAll=0) ;删除元素
{
	Str:=_StrAr_Format(Str)
	If (Element="")
	{
		Return Str
	}
	Element=%Element%|
	If IsAll
	{
		StringReplace,NewStr,Str,%Element%,,All
	}
	Else
	{
		StringReplace,NewStr,Str,%Element%
	}
	Return NewStr
}

;~ b=|1|2|3|4|5|6|7|8|9

;~ MsgBox % StrAr_DeletElement(b,"")

;~ If StrAr_Find(b,"1")
;~ {
;~ 	MsgBox
;~ }

;~ a=0x110460
;~ item:=StrAr_Get(a,1)
;~ MsgBox %item%


;~ b=Alt+滚轮上|Alt+滚轮下|Ctrl+滚轮上|Ctrl+滚轮下|左键+右键|右键+左键|中键
;~ b=1232p1234p3453p4562

;~ b=|1234
;~ size:=StrAr_Size(b)


;~ b:=StrAr_Delet(b,2)
;~ b:=StrAr_Get(b,2)
;~ b:=StrAr_DeletElement(b,"Ctrl+滚轮上")
;~ MsgBox %b%


;~ b=Alt+滚轮上|Alt+滚轮下|Ctrl+滚轮上|Ctrl+滚轮下|左键+右键|右键+左键|中键
;~ StringGetPos,V,b,|
;~ MsgBox %V%
;~ aa=Cb3

;~ If aa In Cb1,Cb2
;~ {
;~ 	MsgBox
;~ }