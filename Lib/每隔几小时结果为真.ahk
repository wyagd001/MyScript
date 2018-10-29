每隔几小时结果为真(period:=7){
 lasttime:=CF_IniRead(run_iniFile,"时间","上次运行日期")
 if (lasttime="") or (lasttime="error")
  lasttime:=10001001
 FormatTime,time1,% lasttime,yyyyMMdd
 FormatTime,time2,A_now,yyyyMMdd
 if (time1<>time2)
 {
  IniWrite,% time2,% run_iniFile,时间,上次运行日期
  FormatTime,time3,A_now,HH
  IniWrite,% time3,% run_iniFile,时间,上次运行时间
 return true
 }
 else
 {
  time3:=CF_IniRead(run_iniFile,"时间","上次运行时间")
  if time3=
   time3=0
  FormatTime,time4,A_now,HH
  if (Abs(time4 - time3) < period)
   return false
  else
  {
   IniWrite,% time4,% run_iniFile,时间,上次运行时间
  return true
  }
 }
}