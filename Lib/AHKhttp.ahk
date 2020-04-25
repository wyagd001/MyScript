; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4890
; https://www.autohotkey.com/boards/viewtopic.php?p=277982
; https://github.com/zhamlin/AHKhttp

; Modified by GeekDude from http://goo.gl/0a0iJq
Class Uri
{
	Encode(Url) { ; keep ":/;?@,&=+$#."
		return this.UriEncode(Url, "[0-9a-zA-Z:/;?@,&=+$#.]")
	}
	Decode(url) {
		return this.UriDecode(url)
	}
	
	UriEncode(Uri, RE="[0-9A-Za-z]") {
		VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0), StrPut(Uri, &Var, "UTF-8")
		While Code := NumGet(Var, A_Index - 1, "UChar")
			Res .= (Chr:=Chr(Code)) ~= RE ? Chr : Format("%{:02X}", Code)
		Return, Res
	}

	UriDecode(Uri) {
		Pos := 1
		While Pos := RegExMatch(Uri, "i)(%[\da-f]{2})+", Code, Pos)
		{
			VarSetCapacity(Var, StrLen(Code) // 3, 0), Code := SubStr(Code,2)
			Loop, Parse, Code, `%
				NumPut("0x" A_LoopField, Var, A_Index-1, "UChar")
			Decoded := StrGet(&Var, "UTF-8")
			Uri := SubStr(Uri, 1, Pos-1) . Decoded . SubStr(Uri, Pos+StrLen(Code)+1)
			Pos += StrLen(Decoded)+1
		}
		Return, Uri
	}
}

Class HttpServer
{
    static servers := {}

    LoadMimes(file) {
        if (!FileExist(file))
            return false

        FileRead, data, % file
        types := StrSplit(data, "`r`n")
        this.mimes := {}
        for i, data in types {
            info := StrSplit(data, " ")
            type := info.Remove(1)
            ; Seperates type of content and file types
            info := StrSplit(LTrim(SubStr(data, StrLen(type) + 1)), " ")

            for i, ext in info {
                this.mimes[ext] := type
            }
        }
        return true
    }

    GetMimeType(file) {
        default := "text/plain"
        if (!this.mimes)
            return default

        SplitPath, file,,, ext
        type := this.mimes[ext]
        if (!type)
            return default
        return type
    }

    ServeFile(ByRef response, file) {
        f := FileOpen(file, "r")
        length := f.RawRead(data, f.Length)
        f.Close()

        response.SetBody(data, length)
        response.headers["Content-Type"] := this.GetMimeType(file)
    }

    SetPaths(paths) {
        this.paths := paths
    }

    Handle(ByRef request) {
        response := new HttpResponse()
        if (!this.paths[request.path]) {
            func := this.paths["404"]
            response.status := 404
            if (func)
                func.(request, response, this)
            return response
        } else {
            this.paths[request.path].(request, response, this)
        }
        return response
    }

    Serve(port) {
        this.port := port
        HttpServer.servers[port] := this

        AHKsock_Listen(port, "HttpHandler")
    }
}

HttpHandler(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, bDataLength = 0) {
    static sockets := {}
    static Stime,Discard_data

    if (!sockets[iSocket]) {
        sockets[iSocket] := new Socket(iSocket)
        AHKsock_SockOpt(iSocket, "SO_KEEPALIVE", true)
    }
    socket := sockets[iSocket]

    if (sEvent == "DISCONNECTED") {
        socket.request := false
        sockets[iSocket] := false
    } else if (sEvent == "SEND") {
        if (socket.TrySend()) {
            socket.Close()
        }

    } else if (sEvent == "RECEIVED") {
        server := HttpServer.servers[sPort]
;Static bindex:=1
        text := StrGet(&bData, "UTF-8")

        ; New request or old?
        if (socket.request) {
            if (A_TickCount-Stime)/1000>socket.request.timeout {
                socket.request.done := true
                Discard_data:=0
                socket.request.filename:=socket.request.timeout:=Stime:=""
                request := socket.request
            }

            RegExMatch(text, "m)filename=""(.*)""", SubPat) 
            hpos:=InStr(text, "`r`n",,,4)

            if SubPat1 {
                DriveSpaceFree, OutputVar, % A_ScriptDir
                if (socket.request.headers["Content-Length"]>OutputVar*1024*1024) {
                    SubPat1:=""
                    socket.request.revsize := bDataLength
                    Discard_data:=1
                }
                else {
;hcap:=VarSetCapacity(bData)
;file := FileOpen(fileexist(A_ScriptDir "\1.txt")?(fileexist(A_ScriptDir "\2.txt")?(fileexist(A_ScriptDir "\3.txt")?A_ScriptDir "\4.txt":A_ScriptDir "\3.txt"):A_ScriptDir "\2.txt"):A_ScriptDir "\1.txt", 3)
                    nSize := DllCall("WideCharToMultiByte", "Uint", 65001, "Uint", 0, "Uint", &SubPat1, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
                    socket.request.filename := SubPat1
                    socket.request.filepath := A_ScriptDir "\upload\" SubPat1
                    socket.request.filesize := socket.request.headers["Content-Length"]-hpos+strlen(SubPat1)-nSize+1-1-46
                    socket.request.timeout := socket.request.filesize / 1000000
                    socket.request.revsize := bDataLength
                    Stime := A_TickCount
                    request := socket.request
                    file := FileOpen(A_ScriptDir "\upload\" SubPat1, 3)
                    if bDataLength-hpos+strlen(SubPat1)-nSize-46>=socket.request.filesize {
                        File.RawWrite(&bData+hpos-strlen(SubPat1)+nSize-1+1, bDataLength-hpos-nSize+strlen(SubPat1)-46)
                        File.Close()
                        socket.request.done := true
                        socket.request.filename:=""
                        request := socket.request
                    }
                    else {
                        File.RawWrite(&bData+hpos-strlen(SubPat1)+nSize-1+1, bDataLength-hpos-nSize+strlen(SubPat1))
                        File.Close()
;fileappend,% A_now "`r`nrevsize: " socket.request.revsize "`r`n",%A_ScriptDir%\aaaa.txt
;fileappend,% A_now "`r`nnSize: " nSize  "`r`nContent-Length: " socket.request.headers["Content-Length"] "`r`nbDataLength: " bDataLength "`r`nfilename: " socket.request.filename "`r`nfilesize: " socket.request.filesize "`r`n",%A_ScriptDir%\aaaa.txt
                    }
                }
            }
            else if socket.request.filename {
;file := FileOpen(A_ScriptDir "\upload\" bindex,3)
                file := FileOpen(socket.request.filepath,3)
                File.Seek(File.Length)
;fileappend,% A_now "`r`nfileLength+bDataLength: " bDataLength+File.Length-46 "`r`n",%A_ScriptDir%\aaaa.txt
                if (bDataLength+File.Length-46>=socket.request.filesize) {
                    File.RawWrite(&bData, bDataLength-46)
;fileappend,% A_now "`r`nafterwritefileLength: " File.Length "`r`n",%A_ScriptDir%\aaaa.txt
                    File.Close()
;socket.request.revsize += bDataLength
;fileappend,% A_now "`r`nrevsize: " socket.request.revsize "`r`n",%A_ScriptDir%\aaaa.txt
                    socket.request.done := true
                    socket.request.filename:=socket.request.timeout:=Stime:=""
                    request := socket.request
                }
                else {
                    File.RawWrite(&bData, bDataLength)
                    File.Close()
;socket.request.revsize += bDataLength
;fileappend,% A_now "`r`nrevsize: " socket.request.revsize "`r`n",%A_ScriptDir%\aaaa.txt
                }

;fileappend,% A_now "`r`nfilename: " socket.request.filename "`r`nbDataLength: " bDataLength "`r`n",%A_ScriptDir%\aaaa.txt
            }
            else {
                if Discard_data {
                    socket.request.revsize += bDataLength
;fileappend,% A_now "`r`nrevsize: " socket.request.revsize "`r`n",%A_ScriptDir%\aaaa.txt
                    if (socket.request.revsize>=socket.request.headers["Content-Length"]) {
                        socket.request.done := true
                        Discard_data:=0
                        request := socket.request
                    }
                }
                else {
                    ; Get data and append it to the existing request body
                    socket.request.bytesLeft -= StrLen(text)
                    socket.request.body := socket.request.body . text
                    request := socket.request
                }
            }
        }
        else {
            ; Parse new request
            request := new HttpRequest(text)

            length := request.headers["Content-Length"]
            request.bytesLeft := length + 0

            if (request.body) {
                request.bytesLeft -= StrLen(request.body)
            }
        }

        if (request.bytesLeft <= 0) {
            request.done := true
        } else {
            socket.request := request
        }

        if (request.done) {
;        if (request.done || request.IsMultipart()) {
            response := server.Handle(request)
            if (response.status) {
                socket.SetData(response.Generate())
            }
        }
        if (socket.TrySend()) {
            if (!request.IsMultipart() || request.done) {
                socket.Close()
            }
        }
    }
}

class HttpRequest
{
    __New(data = "") {
        if (data)
            this.Parse(data)
    }

    GetPathInfo(top) {
        results := []
        while (pos := InStr(top, " ")) {
            results.Insert(SubStr(top, 1, pos - 1))
            top := SubStr(top, pos + 1)
        }
        this.method := results[1]
        this.path := Uri.Decode(results[2])
        this.protocol := top
    }

    GetQuery() {
        pos := InStr(this.path, "?")
        query := StrSplit(SubStr(this.path, pos + 1), "&")
        if (pos)
            this.path := SubStr(this.path, 1, pos - 1)

        this.queries := {}
        for i, value in query {
            pos := InStr(value, "=")
            key := SubStr(value, 1, pos - 1)
            val := SubStr(value, pos + 1)
            this.queries[key] := val
        }
    }

    Parse(data) {
        this.raw := data
        data := StrSplit(data, "`n`r")
        headers := StrSplit(data[1], "`n")
        this.body := LTrim(data[2], "`n")

        this.GetPathInfo(headers.Remove(1))
        this.GetQuery()
        this.headers := {}

        for i, line in headers {
            pos := InStr(line, ":")
            key := SubStr(line, 1, pos - 1)
            val := Trim(SubStr(line, pos + 1), "`n`r ")
            this.headers[key] := val
        }
    }

    IsMultipart() {
        length := this.headers["Content-Length"]
        ;expect := this.headers["Expect"]
        
        ;if (expect = "100-continue" && length > 0)
				ContentType := this.headers["Content-Type"]
        if ContentType  && (length > 0)  
            return true
        return false
    }
}

class HttpResponse
{
    __New() {
        this.headers := {}
        this.status := 0
        this.protocol := "HTTP/1.1"
        this.buffer:=""
        this.SetBodyText("")
    }
	__Delete(){
		this.buffer:=""
	}
    
    Generate() {
        FormatTime, date,, ddd, d MMM yyyy HH:mm:ss
        this.headers["Date"] := date

        headers := this.protocol . " " . this.status . "`r`n"
        for key, value in this.headers {
            headers := headers . key . ": " . value . "`r`n"
        }
        headers := headers . "`r`n"
        length := this.headers["Content-Length"]

        this.buffer := new Buffer((StrLen(headers) * 2) + length)
        this.buffer.WriteStr(headers)

        this.buffer.Append(this.body)
        this.buffer.Done()

        return this.buffer
    }

    SetBody(ByRef body, length) {
        this.body := new Buffer(length)
        this.body.Write(&body, length)
        this.headers["Content-Length"] := length
    }

    SetBodyText(text) {
        this.body := Buffer.FromString(text)
        this.headers["Content-Length"] := this.body.length
    }
}

class Socket
{
    __New(socket) {
        this.socket := socket
    }

    Close(timeout = 5000) {
        AHKsock_Close(this.socket, timeout)
    }

    SetData(data) {
        this.data := data
    }

    TrySend() {
        if (!this.data || this.data == "")
            return false

        p := this.data.GetPointer()
        length := this.data.length

        this.dataSent := 0
        loop {
            if ((i := AHKsock_Send(this.socket, p, length - this.dataSent)) < 0) {
                if (i == -2) {
                    return
                } else {
                    ; Failed to send
                    return
                }
            }

            if (i < length - this.dataSent) {
                this.dataSent += i
            } else {
                break
            }
        }
        this.dataSent := 0
        this.data := ""

        return true
    }
}

class Buffer
{
    __New(len) {
        this.SetCapacity("buffer", len)
        this.length := 0
    }
	__Delete(){
		this.buffer:=""
	}

    FromString(str, encoding = "UTF-8") {
        length := Buffer.GetStrSize(str, encoding)
        this.buffer := new Buffer(length)
        this.buffer.WriteStr(str)
        return this.buffer
    }

    GetStrSize(str, encoding = "UTF-8") {
        encodingSize := ((encoding="utf-16" || encoding="cp1200") ? 2 : 1)
        ; length of string, minus null char
        return StrPut(str, encoding) * encodingSize - encodingSize
    }

    WriteStr(str, encoding = "UTF-8") {
        length := this.GetStrSize(str, encoding)
        VarSetCapacity(text, length)
        StrPut(str, &text, encoding)

        this.Write(&text, length)
        return length
    }

    ; data is a pointer to the data
    Write(data, length) {
        p := this.GetPointer()
        DllCall("RtlMoveMemory", "uint", p + this.length, "uint", data, "uint", length)
        this.length += length
    }

    Append(ByRef buffer) {
        destP := this.GetPointer()
        sourceP := buffer.GetPointer()

        DllCall("RtlMoveMemory", "uint", destP + this.length, "uint", sourceP, "uint", buffer.length)
        this.length += buffer.length
    }

    GetPointer() {
        return this.GetAddress("buffer")
    }

    Done() {
        this.SetCapacity("buffer", this.length)
    }
}