UrlDownloadToVar(URL,Charset="",URLCodePage="",Proxy="",ProxyBypassList="",Cookie="",Referer="",UserAgent="",EnableRedirects="",Timeout=-1)
  {
	ComObjError(0)  
    WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    If (URLCodePage<>"")    
        WebRequest.Option(2):=URLCodePage
    If (EnableRedirects<>"")
        WebRequest.Option(6):=EnableRedirects
    If (Proxy<>"")  
        WebRequest.SetProxy(2,Proxy,ProxyBypassList)
    WebRequest.Open("GET", URL, true)
    If (Cookie<>"")
      {
        WebRequest.SetRequestHeader("Cookie","tuzi")   
        WebRequest.SetRequestHeader("Cookie",Cookie)
      }
    If (Referer<>"") 
        WebRequest.SetRequestHeader("Referer",Referer)
    If (UserAgent<>"")  
        WebRequest.SetRequestHeader("User-Agent",UserAgent)
    WebRequest.Send()
    WebRequest.WaitForResponse(Timeout) 
    If (Charset="")
        Return,WebRequest.ResponseText()
    Else
      {
        ADO:=ComObjCreate("adodb.stream")  
        ADO.Type:=1 
        ADO.Mode:=3
        ADO.Open() 
        ADO.Write(WebRequest.ResponseBody())  
        ADO.Position:=0
        ADO.Type:=2 
        ADO.Charset:=Charset    
        Return,ADO.ReadText()   
      }
  }