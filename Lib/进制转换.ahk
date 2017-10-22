hex2dec(h)
{
	oldfrmt := A_FormatInteger
	SetFormat, integer, dec
	d :=h+0
	SetFormat, IntegerFast, %oldfrmt% 
return d
} 

dec2hex(d)
{
	oldfrmt := A_FormatInteger
	SetFormat, integer, H
	h :=d+0
	SetFormat, IntegerFast, %oldfrmt%
return h
}

system(x,InPutType="D",OutPutType="H")
{
	if InputType=B
	{
		IF OutPutType=D
		r:=bin2Dec(x)
		Else IF OutPutType=H
		{
			x:=bin2Dec(x)
			r:=dec2hex(x)
		}
	}
	Else If InputType=D
	{
		IF OutPutType=B
		r:=dec2Bin(x)
		Else If OutPutType=H
		r:=dec2hex(x)
	}
	Else If InputType=H
	{
		IF OutPutType=B
		{
			x:=hex2dec(x)
			r:=dec2Bin(x)
		}
		Else If OutPutType=D
		r:=hex2dec(x)
	}
	Return,r
}

dec2Bin(x)
{                ;dec-bin
	while x
	r:=1&x r,x>>=1
	return r
}

bin2Dec(x)
{                ;bin-dec
	b:=StrLen(x),r:=0
	loop,parse,x
	r|=A_LoopField<<--b
	return r
}

toHex( ByRef V, ByRef H, dataSz:=0 )
{ ; http://goo.gl/b2Az0W (by SKAN)
	P := ( &V-1 ), VarSetCapacity( H,(dataSz*2) ), Hex := "123456789ABCDEF0"
	Loop, % dataSz ? dataSz : VarSetCapacity( V )
		H  .=  SubStr(Hex, (*++P >> 4), 1) . SubStr(Hex, (*P & 15), 1)
}