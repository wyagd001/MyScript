; http://thinkai.net/p/11

Time_unix2human(time)
{
	human=19700101000000
	time-=((A_NowUTC-A_Now)//10000)*3600     ; Ê±²î
	human+=%time%,Seconds
	return human
}

Time_human2unix(time)
{
	time-=19700101000000,Seconds
	time+=((A_NowUTC-A_Now)//10000)*3600     ; Ê±²î
	return time
}
 