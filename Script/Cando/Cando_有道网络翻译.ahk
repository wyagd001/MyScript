Cando_有道网络翻译:
	Gui,66:Default
	Gui,Destroy
	Youdao_keyword=%CandySel%
	Youdao_译文:=YouDaoApi(Youdao_keyword)
	Youdao_基本释义:= json(Youdao_译文, "basic.explains")
	Youdao_网络释义:= json(Youdao_译文, "web.value")
	If Youdao_基本释义<>
	{
		Gui,add,Edit,x10 y10 w260 h80 readonly,%Youdao_keyword%
		Gui,add,button,x270 y10 w40 h80 gsoundpaly,播放
		Gui,add,Edit,x10 y100 w300 h80,%Youdao_基本释义%
		Gui,add,Edit,x10 y190 w300 h80,%Youdao_网络释义%
		Gui,show,,有道网络翻译
	}
	else
		MsgBox,,有道网络翻译,网络错误或查询不到该单词的翻译。
Return

soundpaly:
	spovice:=ComObjCreate("sapi.spvoice")
	spovice.Speak(Youdao_keyword)
Return

YouDaoApi(KeyWord)
{
	url:="http://fanyi.youdao.com/fanyiapi.do?keyfrom=xxxxxxxx&key=1360116736&type=data&doctype=json&version=1.1&q=" . SkSub_UrlEncode(KeyWord,"utf-8")
    Return WinHttp.URLGet(url)
}