;date=20170101
;MsgBox,% Date_GetDate(date)
;MsgBox,% Date_GetDate(date,1) ;闰5月
;MsgBox,% Date_GetLunarDate(20180215)
;MsgBox,% Date_GetLunarDate(A_Now)
;MsgBox,% Date_GetLunarDate(A_Now-1*1000000)  

JCTF:
	today:=SubStr(A_Now, 1, 8)
	Lunar_Year:=Date_GetLunarDate(today,1)
	TX =
	CTFSC:=[]
	IniRead, CTFData, %run_iniFile%, 农历节日
	If(CTFData="")
	{
		CTFArray := {"新年": "0101", "元宵节": "0115", "民歌节": "0303", "端午节": "0505", "七夕节": "0707", "中元节": "0715", "中秋节": "0815", "重阳节": "0909", "小年": "1223","第二年新年": "0101"}
		; ,"自定义节日一": "0601","自定义节日二": "0709","自定义节日三": "0827", "自定义节日四": "0924"
	}
	else
	{
		temp_array := StrSplit(Trim(CTFData), ["=", "`n"])
		CTFArray := {}, i := 0
		Loop % temp_array.length()/2
		{
			currentLoopIterationIniKeyName := temp_array[++i]
			CTFArray[currentLoopIterationIniKeyName] := temp_array[++i]
		}
		temp_array :=CTFData :=""
	}

	for k,v in CTFArray
	{
		if(k="第二年新年")
			CTFSC[k]:=Date_GetDate(Lunar_Year+1 . v)
		else
			CTFSC[k]:=Date_GetDate(Lunar_Year . v)
	}

	for k,v in CTFSC
	{
		Leafdays:=v
		Leafdays -=today,days
		if (Leafdays<=5 and Leafdays>=0)
		{
			settimer,MCTF,30000
			if ( Leafdays=0 )
				TX .="今天是" k " " Date_GetLunarDate(today) " `n"
			else
			{
				if(k="第二年新年")
				{
					if(Leafdays=1)
						TX .="今天是除夕`n"
					else
						TX .= "距离除夕还有" Leafdays-1 "天`n"
					TX .= "距离新年还有" Leafdays "天`n"
				}
				else
					TX .= "距离" k "还有" Leafdays "天`n"
			}
		}
		if (Leafdays=6)
			settimer,MCTF,30000
	}
	if tx
		msgbox % tx
return

MCTF:
	if (A_Hour=0 && A_Min=30)
	{
		gosub,JCTF
		settimer,MCTF,off
	}
return

/*
<参数>
Gregorian:
公历日期 格式 YYYYMMDD

<返回值>
农历日期 中文 天干地支属相 
*/
Date_GetLunarDate(Gregorian,onlyyear=False)
{
    ;1899年~2100年农历数据
    ;前三位，Hex，转Bin，表示当年月份，1为大月，0为小月
    ;第四位，Dec，表示闰月天数，1为大月30天，0为小月29天
    ;第五位，Hex，转Dec，表示是否闰月，0为不闰，否则为闰月月份
    ;后两位，Hex，转Dec，表示当年新年公历日期，格式MMDD
    LunarData=
    (LTrim Join
    AB500D2,4BD0883,
    4AE00DB,A5700D0,54D0581,D2600D8,D9500CC,655147D,56A00D5,9AD00CA,55D027A,4AE00D2,
    A5B0682,A4D00DA,D2500CE,D25157E,B5500D6,56A00CC,ADA027B,95B00D3,49717C9,49B00DC,
    A4B00D0,B4B0580,6A500D8,6D400CD,AB5147C,2B600D5,95700CA,52F027B,49700D2,6560682,
    D4A00D9,EA500CE,6A9157E,5AD00D6,2B600CC,86E137C,92E00D3,C8D1783,C9500DB,D4A00D0,
    D8A167F,B5500D7,56A00CD,A5B147D,25D00D5,92D00CA,D2B027A,A9500D2,B550781,6CA00D9,
    B5500CE,535157F,4DA00D6,A5B00CB,457037C,52B00D4,A9A0883,E9500DA,6AA00D0,AEA0680,
    AB500D7,4B600CD,AAE047D,A5700D5,52600CA,F260379,D9500D1,5B50782,56A00D9,96D00CE,
    4DD057F,4AD00D7,A4D00CB,D4D047B,D2500D3,D550883,B5400DA,B6A00CF,95A1680,95B00D8,
    49B00CD,A97047D,A4B00D5,B270ACA,6A500DC,6D400D1,AF40681,AB600D9,93700CE,4AF057F,
    49700D7,64B00CC,74A037B,EA500D2,6B50883,5AC00DB,AB600CF,96D0580,92E00D8,C9600CD,
    D95047C,D4A00D4,DA500C9,755027A,56A00D1,ABB0781,25D00DA,92D00CF,CAB057E,A9500D6,
    B4A00CB,BAA047B,AD500D2,55D0983,4BA00DB,A5B00D0,5171680,52B00D8,A9300CD,795047D,
    6AA00D4,AD500C9,5B5027A,4B600D2,96E0681,A4E00D9,D2600CE,EA6057E,D5300D5,5AA00CB,
    76A037B,96D00D3,4AB0B83,4AD00DB,A4D00D0,D0B1680,D2500D7,D5200CC,DD4057C,B5A00D4,
    56D00C9,55B027A,49B00D2,A570782,A4B00D9,AA500CE,B25157E,6D200D6,ADA00CA,4B6137B,
    93700D3,49F08C9,49700DB,64B00D0,68A1680,EA500D7,6AA00CC,A6C147C,AAE00D4,92E00CA,
    D2E0379,C9600D1,D550781,D4A00D9,DA400CD,5D5057E,56A00D6,A6C00CB,55D047B,52D00D3,
    A9B0883,A9500DB,B4A00CF,B6A067F,AD500D7,55A00CD,ABA047C,A5A00D4,52B00CA,B27037A,
    69300D1,7330781,6AA00D9,AD500CE,4B5157E,4B600D6,A5700CB,54E047C,D1600D2,E960882,
    D5200DA,DAA00CF,6AA167F,56D00D7,4AE00CD,A9D047D,A2D00D4,D1500C9,F250279,D5200D1
    )

    ;分解公历年月日
    StringLeft,Year,Gregorian,4
    StringMid,Month,Gregorian,5,2
    StringMid,Day,Gregorian,7,2
    if (Year>2100 Or Year<1900)
    {
        errorinfo=无效日期
        return,errorinfo
    }

    ;获取两年内的农历数据
    Pos:=(Year-1900)*8+1
    StringMid,Data0,LunarData,%Pos%,7
    Pos+=8
    StringMid,Data1,LunarData,%Pos%,7

    ;判断农历年份
    Analyze(Data1,MonthInfo,LeapInfo,Leap,Newyear)
    Date1=%Year%%Newyear%
    Date2:=Gregorian
    EnvSub,Date2,%Date1%,Days
    If Date2<0                    ;和当年农历新年相差的天数
    {
        Analyze(Data0,MonthInfo,LeapInfo,Leap,Newyear)
        Year-=1
        Date1=%Year%%Newyear%
        Date2:=Gregorian
        EnvSub,Date2,%Date1%,Days
    }
if onlyyear
Return Year
    ;计算农历日期
    Date2+=1
    LYear:=Year        ;农历年份，就是上面计算后的值
    if Leap            ;有闰月
    {
        StringLeft,p1,MonthInfo,%Leap%
        StringTrimLeft,p2,MonthInfo,%Leap%
        thisMonthInfo:=p1 . LeapInfo . p2
    }
    Else
        thisMonthInfo:=MonthInfo
    loop,13
    {
        StringMid,thisMonth,thisMonthInfo,%A_index%,1
        thisDays:=29+thisMonth
        if Date2>%thisDays%
            Date2:=Date2-thisDays
        Else
        {
            if leap
            {
                If leap>%a_index%
                    LMonth:=A_index
                Else
                    LMonth:=A_index-1
            }
            Else
                LMonth:=A_index
            LDay:=Date2
            Break
        }
    }
    LDate=%LYear%年%LMonth%月%LDay%        ;完成
;~     MsgBox,% LDate
    ;转换成习惯性叫法
    Tiangan=甲,乙,丙,丁,戊,已,庚,辛,壬,癸
    Dizhi=子,丑,寅,卯,辰,巳,午,未,申,酉,戌,亥
    Shengxiao=鼠,牛,虎,兔,龙,蛇,马,羊,猴,鸡,狗,猪
    loop,Parse,Tiangan,`,
        Tiangan%a_index%:=A_LoopField
    loop,Parse,Dizhi,`,
        Dizhi%a_index%:=A_LoopField
    loop,Parse,Shengxiao,`,
        Shengxiao%a_index%:=A_LoopField
    Order1:=Mod((LYear-4),10)+1
    Order2:=Mod((LYear-4),12)+1
    LYear:=Tiangan%Order1% . Dizhi%Order2% . "(" . Shengxiao%Order2% . ")"

    yuefen=正,二,三,四,五,六,七,八,九,十,十一,腊
    loop,Parse,yuefen,`,
        yuefen%A_index%:=A_LoopField
    LMonth:=yuefen%LMonth%

    rizi=初一,初二,初三,初四,初五,初六,初七,初八,初九,初十,十一,十二,十三,十四,十五,十六,十七,十八,十九,二十,廿一,廿二,廿三,廿?四,廿五,廿六,廿七,廿八,廿九,三十
    loop,Parse,rizi,`,
        rizi%A_index%:=A_LoopField
    LDay:=rizi%LDay%

    LDate=%LYear%年%LMonth%月%LDay%
    Return,LDate
}

/*
<参数>
Lunar:
农历日期
IsLeap:
是否闰月
如，某年闰7月，第一个7月不是闰月，第二个7月是闰月，IsLeap=1
当年没有闰月这个参数无效

<返回值>
公历日期(YYYYDDMM)
*/
Date_GetDate(Lunar,IsLeap=0)
{
    ;分解农历年月日
    StringLeft,Year,Lunar,4
    StringMid,Month,Lunar,5,2
    StringRight,Day,Lunar,2
    if substr(Month,1,1)=0
        StringTrimLeft,month,month,1
    if (Year>2100 Or Year<1900 or Month>12 or Month<1 or Day>30 or Day<1)
    {
        errorinfo=无效日期
        return,errorinfo
    }

    ;1899年~2100年农历数据
    ;前三位，Hex，转Bin，表示当年月份，1为大月，0为小月
    ;第四位，Dec，表示闰月天数，1为大月30天，0为小月29天
    ;第五位，Hex，转Dec，表示是否闰月，0为不闰，否则为闰月月份
    ;后两位，Hex，转Dec，表示当年新年公历日期，格式MMDD
    LunarData=
    (LTrim Join
    AB500D2,4BD0883,
    4AE00DB,A5700D0,54D0581,D2600D8,D9500CC,655147D,56A00D5,9AD00CA,55D027A,4AE00D2,
    A5B0682,A4D00DA,D2500CE,D25157E,B5500D6,56A00CC,ADA027B,95B00D3,49717C9,49B00DC,
    A4B00D0,B4B0580,6A500D8,6D400CD,AB5147C,2B600D5,95700CA,52F027B,49700D2,6560682,
    D4A00D9,EA500CE,6A9157E,5AD00D6,2B600CC,86E137C,92E00D3,C8D1783,C9500DB,D4A00D0,
    D8A167F,B5500D7,56A00CD,A5B147D,25D00D5,92D00CA,D2B027A,A9500D2,B550781,6CA00D9,
    B5500CE,535157F,4DA00D6,A5B00CB,457037C,52B00D4,A9A0883,E9500DA,6AA00D0,AEA0680,
    AB500D7,4B600CD,AAE047D,A5700D5,52600CA,F260379,D9500D1,5B50782,56A00D9,96D00CE,
    4DD057F,4AD00D7,A4D00CB,D4D047B,D2500D3,D550883,B5400DA,B6A00CF,95A1680,95B00D8,
    49B00CD,A97047D,A4B00D5,B270ACA,6A500DC,6D400D1,AF40681,AB600D9,93700CE,4AF057F,
    49700D7,64B00CC,74A037B,EA500D2,6B50883,5AC00DB,AB600CF,96D0580,92E00D8,C9600CD,
    D95047C,D4A00D4,DA500C9,755027A,56A00D1,ABB0781,25D00DA,92D00CF,CAB057E,A9500D6,
    B4A00CB,BAA047B,AD500D2,55D0983,4BA00DB,A5B00D0,5171680,52B00D8,A9300CD,795047D,
    6AA00D4,AD500C9,5B5027A,4B600D2,96E0681,A4E00D9,D2600CE,EA6057E,D5300D5,5AA00CB,
    76A037B,96D00D3,4AB0B83,4AD00DB,A4D00D0,D0B1680,D2500D7,D5200CC,DD4057C,B5A00D4,
    56D00C9,55B027A,49B00D2,A570782,A4B00D9,AA500CE,B25157E,6D200D6,ADA00CA,4B6137B,
    93700D3,49F08C9,49700DB,64B00D0,68A1680,EA500D7,6AA00CC,A6C147C,AAE00D4,92E00CA,
    D2E0379,C9600D1,D550781,D4A00D9,DA400CD,5D5057E,56A00D6,A6C00CB,55D047B,52D00D3,
    A9B0883,A9500DB,B4A00CF,B6A067F,AD500D7,55A00CD,ABA047C,A5A00D4,52B00CA,B27037A,
    69300D1,7330781,6AA00D9,AD500CE,4B5157E,4B600D6,A5700CB,54E047C,D1600D2,E960882,
    D5200DA,DAA00CF,6AA167F,56D00D7,4AE00CD,A9D047D,A2D00D4,D1500C9,F250279,D5200D1
    )

    ;获取当年农历数据
    Pos:=(Year-1899)*8+1
    StringMid,Data,LunarData,%Pos%,7

    ;判断公历日期
    Analyze(Data,MonthInfo,LeapInfo,Leap,Newyear)
    ;计算到当天到当年农历新年的天数
    Sum=0
    if Leap            ;有闰月
    {
        StringLeft,p1,MonthInfo,%Leap%
        StringTrimLeft,p2,MonthInfo,%Leap%
        thisMonthInfo:=p1 . LeapInfo . p2
        if (Leap!=Month and IsLeap=1)
        {
            errorinfo=该月不是闰月
            return,errorinfo
        }
        if (Month<=Leap and IsLeap=0)
        {
            loop,% Month-1
            {
                StringMid,thisMonth,thisMonthInfo,%A_index%,1
                Sum:=Sum+29+thisMonth
            }
        }
        Else
        {
            loop,% Month
            {
                StringMid,thisMonth,thisMonthInfo,%A_index%,1
                Sum:=Sum+29+thisMonth
            }
        }
    }
    Else
    {
        loop,% Month-1
        {
            thisMonthInfo:=MonthInfo
            StringMid,thisMonth,thisMonthInfo,%A_index%,1
            Sum:=Sum+29+thisMonth
        }
    }
    Sum:=Sum+Day-1

    GDate=%Year%%NewYear%
    GDate+=%Sum%,days
    StringTrimRight,Gdate,Gdate,6
    return,Gdate
}

;分析农历数据的函数 按上面所示规则分析
;4个回参分别对应四项
Analyze(Data,ByRef rtn1,ByRef rtn2,ByRef rtn3,ByRef rtn4)
{
    ;rtn1
    StringLeft,Month,Data,3
    rtn1:=System("0x" . Month,"H","B")
    if Strlen(rtn1)<12
        rtn1:="0" . rtn1

    ;rtn2
    StringMid,rtn2,Data,4,1

    ;rtn3
    StringMid,leap,Data,5,1
    rtn3:=System("0x" . leap,"H","D")

    ;rtn4
    StringRight,Newyear,Data,2
    rtn4:=System("0x" . newyear,"H","D")
    if strlen(rtn4)=3
        rtn4:="0" . rtn4
}