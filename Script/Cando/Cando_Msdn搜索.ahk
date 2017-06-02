Cando_msdn搜索:
	funct_string=https://www.bing.com/search?q=%candysel%+msdn
	a := URLDownloadToVar(funct_string,"utf-8")
	; 匹配搜索结果的正则    绝大多数能匹配到
	RegExmatch(a,"m)(*ANYCRLF).*?href\=""(https://msdn.*?\(v=vs.85\).aspx)"".*?",m)
	dizhi:= m1
	If dizhi=
	{
		Run https://social.msdn.microsoft.com/search/en-us/windows?query=%candysel%&Refinement=183
		Return
	}
	Else
		Run %dizhi%
Return