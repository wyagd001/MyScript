/*
JowAlert.ahk  V1.1     作者：wz520
http://ahk.5d6d.com/viewthread.php?tid=830
http://ahk.5d6d.com/thread-898-1-1.html
http://ahk8.com/thread-629.html
*/
实时报时:
  SoundPlay, %A_ScriptDir%\Sound\domisodo.wav, Wait
  JA_VoiceAlert()
  return

renwu:
If  (A_Hour = rh && A_Min= rm)
{
SetTimer, renwu, Off
IniWrite,0,%run_iniFile%,时间,renwu
run %renwucx%,,UseErrorLevel
if ErrorLevel
  MsgBox,,定时任务,定时任务运行失败，请检查设置。
}
Return

renwu2:
loop 5
{
If  (A_Hour A_Min = rh%A_index% )
{
	xqArray := {"星期一": 1, "星期二": 2,  "星期三": 3,  "星期四": 4,  "星期五": 5,  "星期六": 6,  "星期日": 7}
xqdsArray := StrSplit(xq%A_index%)
msgtptemp:=msgtp%A_index%
for v in xqdsArray
{
if(v = xqArray[A_DDDD])
  MsgBox,,提示,% msgtptemp
}
xqdsArray:=""
}
}
Return

JA_VoiceCheckTime:
  If !((A_Min = 59 || A_Min = 29) && (A_Sec = 57 || A_Sec = 58)) ;因为提示音是“滴滴滴嘟”，到“嘟”才是0秒。所以检查是否还差3秒就整点或半点，不是就返回。不过由于某些原因，比如游戏时可能计时器会有延迟，所以设定成在57秒或58秒都放。
    return
  SoundPlay, %A_ScriptDir%\Sound\didididu.wav, Wait
  JA_VoiceAlert()
  return

JA_JowCheckTime:
  If !((A_Min = 0 || A_Min = 30) && (A_Sec = 0 || A_Sec = 1)) ;检查是否是整点或半点，不是就返回。
    return
  JA_JowAlert()
  return

  JA_AMPM()
{
  If (A_Hour>=0 && A_Hour<=5) ;0点到5点
    return "AM0.wav" ;凌晨
  Else If (A_Hour>=6 && A_Hour<=11) ;6点到11点
    return "AM1.wav" ;上午
  Else If (A_Hour>=12 && A_Hour<=17) ;12点到17点
    return "PM.wav" ;下午
  Else ;其他
    return "EM.wav" ;晚上
}

JA_HourWav()
{
  FormatTime, CurrHour, , hh
  If (CurrHour=1 || CurrHour=2)
    FormatTime, CurrHour, , h
  CurrHour = T%CurrHour%.wav
  return CurrHour
}

JA_MinWav(ByRef Min1, ByRef Min2)
{
  If (A_Min>=1 && A_Min<=9)
  {
    Min1=00
    MIn2=%A_Min%
  }
  If (A_Min=0 || (A_Min>=10 && A_Min<=12)) ;0, 10, 11, 12由于只要播放一个文件，Min2就为空
  {
    Min1=%A_Min%
  }
  Else If (A_Min>=13 && A_Min<=19)
  {
    Min1=10
    Min2 := "0" . A_Min-10
  }
  Else If (A_Min>=20 && A_Min<=29)
  {
    Min1=20
    Min2 := "0" . A_Min-20
    If Min2=0
      Min2=
  }
  Else If (A_Min>=30 && A_Min<=39)
  {
    Min1=30
    Min2 := "0" . A_Min-30
    If Min2=0
      Min2=
  }
  Else If (A_Min>=40 && A_Min<=49)
  {
    Min1=40
    Min2 := "0" . A_Min-40
    If Min2=0
      Min2=
  }
  Else If (A_Min>=50 && A_Min<=59)
  {
    Min1=50
    Min2 := "0" . A_Min-50
    If Min2=0
      Min2=
  }
  Min1=T%Min1%.wav
  If Min2!=
    Min2=T%Min2%.wav
}

JA_VoiceAlert(){
  global JA_WavPath
  AMPM:=JA_AMPM() ;根据现在是凌晨/上午/下午/晚上，返回wav文件名
  HourWav:=JA_HourWav() ;查询现在的时，返回wav文件名
  Min1=
  Min2=
  JA_MinWav(Min1, Min2) ;查询现在的分，返回wav文件名（两个，十位和个位）
  SoundPlay, %A_ScriptDir%\Sound\TIMENOW.wav,wait  ;“现在时间是”
  SoundPlay, %A_ScriptDir%\Sound\%AMPM%, Wait ;“凌晨/上午/下午/晚上”
  SoundPlay, %A_ScriptDir%\Sound\%HourWav%, Wait ;时
  SoundPlay, %A_ScriptDir%\Sound\POINT.wav, Wait ;“点”
  SoundPlay, %A_ScriptDir%\Sound\%Min1%, Wait ;分（十位）
  If Min2!=
    SoundPlay, %A_ScriptDir%\Sound\%Min2%, Wait ;分（个位）
  SoundPlay, %A_ScriptDir%\Sound\MIN.wav, Wait ;“分”
}

JA_JowAlert(){
  global JA_WavPath
  FormatTime, CurrHour, , h ;得到12小时制的时，决定敲几下钟
  If CurrHour = 0 ;如果是0点
    CurrHour := 12 ;敲12下
  If A_Min = 30 ;如果是半点
    CurrHour := 1 ;敲1下
  if A_Min = 0
    soundplay, %A_ScriptDir%\Sound\dofasodo.wav, Wait ;整点时播放哆发嗦哆，哆嗦拉发。半点不播放。
  loop, %CurrHour%
    soundplay, %A_ScriptDir%\Sound\dong.wav, Wait ;敲钟
}
