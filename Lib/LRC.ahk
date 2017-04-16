lrcPause(x){
	global
	Stime:=starttime
	If x=0
	SetTimer, lrcpause, Off
	Else
	SetTimer, lrcpause, 100
	Return

	lrcpause:
	passedtime:=A_TickCount-Pausetime
	starttime:=Stime+passedtime
	Return
}

lrcECHO(lrcfile,GuiTitle){
	global
	Gui, 2:+LastFound
	WinSet, TransColor, FF0F0F
	WinSet, ExStyle, +0x20
		if hidelrc=0
	Gui, 2:Show, NoActivate, %GuiTitle% - AhkPlayer  ; 不激活窗体避免改变当前激活的窗口

;读取lrc文件的内容
	n:=1
	temp:=1
	Loop, read, %lrcfile%
	{
		temp:=1
		Loop
		{
			temp:=InStr(A_LoopReadLine, "[","", temp)
			If (temp<>0)
			{
				IfInString,A_LoopReadLine,][
				{
                temp:=temp+1
				time%n%:=SubStr(A_LoopReadLine, temp, 8)
				sec%n%:=60*SubStr(time%n%, 1, 2)+SubStr(time%n%, 4, 5)
				If sec%n% is not Number
				Break
				lrc%n%:=SubStr(A_LoopReadLine, InStr(A_LoopReadLine,"]","",0)+1)
                n:=n+1
                continue
			    }
			    else
				{
				temp:=temp+1
				time%n%:=SubStr(A_LoopReadLine, temp, 8)
				sec%n%:=60*SubStr(time%n%, 1, 2)+SubStr(time%n%, 4, 5)
				If sec%n% is not Number
				Break
				lrc%n%:=SubStr(A_LoopReadLine, InStr(A_LoopReadLine,"]","",1)+1)
				lrc%n%:= RegExReplace(lrc%n%, "[\[\:0-9\.\]]")
        ;原代码从右到左查找“]”，找到后从“]”位置+1，开始复制（复制全部）
				;lrc%n%:=SubStr(A_LoopReadLine, InStr(A_LoopReadLine,"]","",0)+1)
                n:=n+1
                ;原代码 continue  ,同一行查找多次,对[xxx][xxx]xxx格式有效  对[xxx]x[xxx]x[xxx]格式无效
                ;continue
				Break

				}
			}
			Else
			Break
		}
	}

;对时间戳进行排序
	Loop
	{
		n:=1
		flag:=0
		Loop
		{
			nx:=n+1
			If(sec%n% > sec%nx%) And (sec%nx%<>"")
			{
				flag+=1
			;交换sec数据    实际可以只用一个变量做中介即可  不过 此处不影响程序执行的效率.
				tz:=sec%n%
				tx:=sec%nx%
				sec%n%:=tx
				sec%nx%:=tz
			;交换lrc数据
				tz:=lrc%n%
				tx:=lrc%nx%
				lrc%n%:=tx
				lrc%nx%:=tz
			}
			n:=n+1
			If(sec%nx%="")	;如果下一个元素为空，则退出循环
			Break
		}
		If(flag=0)
		Break
    }
/*
FileAppend %sec1% - %lrc1%`n,debugs1.txt
FileAppend %sec2% - %lrc2%`n,debugs1.txt
FileAppend %sec1% - %lrc3%`n,debugs1.txt
FileAppend %sec1% - %lrc4%`n,debugs1.txt
FileAppend %sec1% - %lrc5%`n,debugs1.txt
FileAppend %sec1% - %lrc6%`n,debugs1.txt
FileAppend %sec1% - %lrc7%`n,debugs1.txt
FileAppend %sec1% - %lrc8%`n,debugs1.txt
FileAppend %sec1% - %lrc9%`n,debugs1.txt
FileAppend %sec1% - %lrc10%`n,debugs1.txt
FileAppend %sec1% - %lrc11%`n,debugs1.txt
FileAppend %sec1% - %lrc12%`n,debugs1.txt
FileAppend %sec1% - %lrc13%`n,debugs1.txt
FileAppend %sec1% - %lrc14%`n,debugs1.txt
FileAppend %sec1% - %lrc15%`n,debugs1.txt
FileAppend %sec1% - %lrc16%`n,debugs1.txt
FileAppend %sec1% - %lrc17%`n,debugs1.txt
FileAppend %sec1% - %lrc18%`n,debugs1.txt
FileAppend %sec1% - %lrc19%`n,debugs1.txt
FileAppend %sec1% - %lrc20%`n,debugs1.txt
FileAppend %sec1% - %lrc21%`n,debugs1.txt
FileAppend %sec1% - %lrc22%`n,debugs1.txt
FileAppend %sec1% - %lrc23%`n,debugs1.txt
FileAppend %sec1% - %lrc24%`n,debugs1.txt
FileAppend %sec1% - %lrc25%`n,debugs1.txt
FileAppend %sec1% - %lrc26%`n,debugs1.txt
FileAppend %sec1% - %lrc27%`n,debugs1.txt
FileAppend %sec1% - %lrc28%`n,debugs1.txt
FileAppend %sec1% - %lrc29%`n,debugs1.txt
FileAppend %sec1% - %lrc30%`n,debugs1.txt
FileAppend %sec1% - %lrc31%`n,debugs1.txt
FileAppend %sec1% - %lrc32%`n,debugs1.txt
FileAppend %sec1% - %lrc33%`n,debugs1.txt
FileAppend %sec1% - %lrc34%`n,debugs1.txt
FileAppend %sec1% - %lrc35%`n,debugs1.txt
FileAppend %sec1% - %lrc36%`n,debugs1.txt
FileAppend %sec1% - %lrc37%`n,debugs1.txt
FileAppend %sec1% - %lrc38%`n,debugs1.txt
FileAppend %sec1% - %lrc39%`n,debugs1.txt
FileAppend %sec1% - %lrc40%`n,debugs1.txt
FileAppend %sec1% - %lrc41%`n,debugs1.txt
FileAppend %sec1% - %lrc42%`n,debugs1.txt
FileAppend %sec1% - %lrc43%`n,debugs1.txt
FileAppend %sec1% - %lrc44%`n,debugs1.txt
FileAppend %sec1% - %lrc45%`n,debugs1.txt
FileAppend %sec1% - %lrc46%`n,debugs1.txt
FileAppend %sec1% - %lrc1%`n,debugs1.txt
FileAppend %sec1% - %lrc1%`n,debugs1.txt
FileAppend %sec1% - %lrc1%`n,debugs1.txt
FileAppend %sec1% - %lrc1%`n,debugs1.txt
FileAppend %sec1% - %lrc1%`n,debugs1.txt
FileAppend %sec1% - %lrc1%`n,debugs1.txt
FileAppend %sec1% - %lrc1%`n,debugs1.txt
FileAppend %sec1% - %lrc1%`n,debugs1.txt
FileAppend %sec1% - %lrc1%`n,debugs1.txt
FileAppend %sec1% - %lrc1%`n,debugs1.txt
FileAppend %sec1% - %lrc1%`n,debugs1.txt
FileAppend %sec1% - %lrc1%`n,debugs1.txt
FileAppend %sec1% - %lrc1%`n,debugs1.txt
*/

	t:=1
	GuiControl, 2:, lrc, % lrc%t%
	starttime := A_TickCount - lrcpos
	lrcpos = 0
	maxsec:=n-1
    SetTimer, clock, 50
	Return


	clock:
	nowtime := (A_TickCount - starttime)/1000
	min := floor(nowtime/60)
	SetFormat, Float, 5.2
	sec := nowtime - min*60

	tx:=t+1
	;FileAppend %nowtime% - %t%`n,debugs1.txt
	;aaa := sec%t%
	;FileAppend %aaa%`n,debugs1.txt

	/*原版代码
	If ( (min*60+sec) >= sec%t% and (min*60+sec) <= sec%tx% )
	{
	GuiControl, 2:, lrc, % lrc%t%
		t := t+1
		If (t > n)
		t := 1
    }
*/
		If ( (min*60+sec) >= sec%t% and (min*60+sec) <= sec%tx% )
		GuiControl, 2:, lrc, % lrc%t%

	If ( (min*60+sec) >= sec%t% )
		{
		t := t+1
		If (t > n)
		t := 1
    }

    loop
	{
		If ( (min*60+sec) >= sec%maxsec%)
		break
		If ( (min*60+sec) >= sec%t%)
		t := t+1
		else
		break
		If (t > n)
		t := 1

}
Return
}

lrcClear(){
	global
	count:=1
	SetTimer, lrcpause, Off
	Loop, 99			;清空变量
	{
		min%count%:=""
		sec%count%:=""
		lrc%count%:=""
		count+=1
}
}