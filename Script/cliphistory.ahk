gui_clipHistory:
gui_History()
return

$^V::
monitor=0
if tempid
{
tempid=0
SetTimer, ctrlCheck, 50
return
}
if !ClipSaved1
return
first+=1
if first=4
first=1
if first=1
clipnum:=clipid
else if first=2
{
clipnum:=clipid-1
if clipnum=0
clipnum = 3
}
else if first=3
{
clipnum:=clipid+1
if clipnum=4
clipnum = 1
}

st1:=A_TickCount
SetTimer, ctrlCheck, 50
return

cliptip(num)
{
sleep,100
Outputtooltip=
if StrLen(ClipSaved%num%)>300
{
StringLeft, Outputtooltip1, ClipSaved%num%, 150
StringRight, Outputtooltip2, ClipSaved%num%, 150
Outputtooltip:=Outputtooltip1 "`n`n★☆★☆★☆★☆中间部分省略★☆★☆★☆★☆`n`n" Outputtooltip2
}
tooltip % "文字剪贴板之" num "`n"(Outputtooltip ? Outputtooltip : ClipSaved%num%)
return
}

ctrlCheck:
lt1:=A_TickCount
if lt1-st1>400
cliptip(clipnum)
if !GetKeyState("Ctrl")
{
SetTimer, ctrlCheck, Off
Clipboard := ClipSaved%clipnum%
ClipWait,2
tooltip
Send, ^{vk56}
sleep,400
Clipboard := ClipSaved%clipid%
first=0
monitor=1
}
return

GetClipboardFormat(type=1){		;Thanks nnnik
	Critical, On
	DllCall("OpenClipboard", "int", "")
	while c := DllCall("EnumClipboardFormats","Int",c?c:0)
		x .= "," c
	DllCall("CloseClipboard")


	if type=1
		if Instr(x, ",1") and Instr(x, ",13")
			return 1
		else If Instr(x, ",15")
			return 2
		else
			return ""
	else
		return x
}

shijianCheck:
lt:=A_TickCount
if (lt-st>8000)
{
SetTimer, shijianCheck,off
monitor=1
}
return

migrateHistory(){
; migrates History files to the database
	createHisTable()
	DB.Exec("BEGIN TRANSACTION")
	;API.showTip("Moving history files to database. This process may take some time.")
;addHistoryText("qqqqqqq", A_Now)
	DB.Exec("COMMIT TRANSACTION")
	;API.removeTip()
}

createHisTable(){
; creates the History Table if it doesnt exist
; called by the migrateHistory function
	q = 
	(
		CREATE TABLE if not exists history `(
		id	INTEGER PRIMARY KEY AUTOINCREMENT,
		data 	TEXT,
		type	INTEGER,
		fileid 	TEXT,
		time	TEXT,
		size 	INTEGER
		`)
	)
	if !DB.Exec(q)
    MsgBox, 16, SQLite错误, % "消息:`t" . DB.ErrorMsg . "`n代码:`t" . DB.ErrorCode
;msgbox % q
}

addHistoryText(data, timestamp){
; adds some text data to history
; the timestamp is in A_Now format
	timestamp := convertTimeSql( timestamp )
	q := "insert into history (data, type, time, size) values (""" 
		. escapeQuotesSql(data)
		. """, 0, """ 
		. timestamp """, "
		. fileSizeFromStr(data) ")"
	if (!DB.Exec(q))
    MsgBox, 16, SQLite错误, % "消息:`t" . DB.ErrorMsg . "`n代码:`t" . DB.ErrorCode
 ;   MsgBox % q
}

; Converts YYYYMMDDHHMMSS to YYYY-MM-DD HH:MM:SS
convertTimeSql(t=""){
	if (t == "") 
		t:= A_Now
	return SubStr(t, 1, 4) "-" SubStr(t,5,2) "-" SubStr(t,7,2) " " SubStr(t, 9, 2) ":" SubStr(t,11,2) ":" SubStr(t,13,2)
}

escapeQuotesSql(s){
	; replace quote (") in data content with double quote ("")
	; works like escaping
	StringReplace, s, s, % """", % """""", All
	return s
}

fileSizeFromStr(s){
	; in bytes
	; + 3 comes from other file constraints
	return strlen(s) + 3 
}

execSql(s, warn:=0){
	; execute sql
	if (!DB.Exec(s))
		if (warn)
			msgbox % DB.ErrorCode "`n" DB.ErrorMsg
}

gui_History(){
	global
	static x, y, how_sort := 2_sort := 3_sort := 0, what_sort := 2
	local selected_row, thisguisize
	hst_genWt := 750
	;2_3_sort are the vars storing how cols are sorted , 1 means in Sort ; 0 means SortDesc

	Gui, History:new
	Gui, Color, F6F8E1
	Gui, Margin, 7, 7
	Gui, +Resize +MinSize500x300

history_w=750
h=500

	Gui, Add, Button, h23 Section Default	 ghistory_ButtonPreview vhistory_ButtonPreview	, 预览(&P)
	Gui, Add, Button, x+6 ys h23			vhistory_ButtonDelete	ghistory_ButtonDelete, 删除(&T)
	Gui, Add, Button, x+6 ys h23 			vhistory_ButtonDeleteAll ghistory_ButtonDeleteAll, 重置(&H)
	Gui, Add, Text, x+35 ys+5 					vhistory_SearchText, 搜索过滤(&F)
	Gui, Add, Checkbox, x+10 ys+5 Checked%history_partial% vhistory_partial ghistory_SearchBox, 部分(&R)
	Gui, Add, Edit, ys  	ghistory_SearchBox	vhistory_SearchBox
	Gui, Font, s9, Courier New
	Gui, Font, s9, Consolas
	Gui, Add, ListView, % "xs+1 HWNDhistoryLV vhistoryLV LV0x4000 h430 w" (history_w ? history_w-20 : hst_genWt-25), 剪贴板内容|时间|大小(B)|其他

	Gui, Add, StatusBar
	Gui, Font
	GuiControl, Focus, history_SearchBox

	Menu, HisMenu, Add, 预览(&P), history_MenuPreview
	Menu, HisMenu, Add, 复制(&C), history_clipboard
  Menu, HisMenu, Add, 编辑(&E), history_EditClip
	Menu, HisMenu, Add, 刷新(&R), history_SearchBox
  Menu, HisMenu, Add, 删除(&D), history_ButtonDelete 
  Menu, HisMenu, Default, 预览(&P)
	historyUpdate()
	history_UpdateSTB()
	LV_ModifyCol(what_sort, how_sort ? "Sort" : "SortDesc")

	if ((h+0) == WORKINGHT)
	{
		Gui, History:Show, Maximize, 剪贴板历史
		WinMinimize, 剪贴板历史
		WinMaximize, 剪贴板历史
		GuiControl, focus, history_SearchBox
	}
	else
		Gui, History:Show,% ( x ? "x" x " y" y : "" ) " w" (history_w?history_w:hst_genWt) " h" (h?h:500), 剪贴板历史

	WinWaitActive, 剪贴板历史
	WinGetPos, x, y

	;resize the search box
	GuiControlGet, history_SearchBox, History:pos 		;extract x for later use
	WinGetPos,,, thisguisize,, 剪贴板历史
	GuiControl, Move, history_SearchBox, % "w" (thisguisize- history_Searchboxx - 21) 		;7,7 for outer border, 7 for inner border
	return
}
/**
 * updates the clipboard history window list wrt search filter
 * @param  {String}  crit    search filter
 * @param  {Boolean} create  create the gui, useful for first time
 * @param  {Boolean} partial perform partial search
 * @return {void}
 */
historyUpdate(crit="", create=true, partial=false){
	; Updates the clipboard history window list
	; works when search content is changed
	local totalSize := 0
	local result, Row

	LV_Delete()
	func := Func(partial ? "Superinstr" : "Instr") , thirdpm := partial ? 1 : 0		;The third param 0 has diff meanings in both cases

	crit := trim(crit)
	if (crit == ""){
		q := "select * from history"
	} else if partial {
		likestr := ""
		loop, parse, crit, % " `t", % " `t"
			likestr .= "data like ""%" A_loopfield "%"" and "
		likestr := Substr(likestr, 1, -4)
		q := "select * from history where " likestr
;msgbox % q "-" partial
	} else {
		q := "select * from history where data like ""%" crit "%"""
;msgbox % "二" q "-" partial
	}

	result := ""
	if !DB.GetTable(q, result)
		msgbox error
	loop % result.RowCount
	{
		result.Next(Row)
		clipdata := Row[2] ;data
		clipdate := Row[5]
		totalsize += ( clipsize := Row[6] )
		LV_Add("", clipdata, clipdate, clipsize, Row[1])
		HISTORYOBJ[Row[1]] := Row[3]
	}
;msgbox % Row[1] "`n二" Row[2] "`n三" Row[3] "`n四" Row[4] "`n五" Row[5] "`n六" Row[6]

	history_UpdateSTB("" totalSize/1024)

	if create
	{
 w2 = 155
 w3=70
		w1 := (history_w - 15 - w2 - w3)
		LV_ModifyCol(1, w1) , LV_ModifyCol(2, w2?w2:155) , Lv_ModifyCol(3, (w3?w3:70) " Integer") , Lv_ModifyCol(4, "0")
	}
}

historyGuiSize:
	if (A_EventInfo != 1)	; ignore minimising
	{
		gui_w := a_guiwidth , gui_h := a_guiheight

		SendMessage, 0x1000+29, 1,	0, SysListView321, 剪贴板历史
		w2 := ErrorLevel
		SendMessage, 0x1000+29, 2,	0, SysListView321, 剪贴板历史
		w3 := ErrorLevel

		GuiControl, Move, historyLV, % "w" (gui_w - 15) " h" (gui_h - 65)     ;+20 H in no STatus Bar
		LV_ModifyCol(1, gui_w-15-w2-w3-25) 				;gui_w - x  where   x  =  width of all cols + 25
		GuiControl, Move, history_SearchBox, % " w" (gui_w - (history_SearchBoxx ?  history_SearchBoxx : hst_genWt-300)  -7) ; 7 for innermargin
	}
	return

history_ButtonPreview:
	Gui, History:Default
	Gui, submit, nohide
	if (LV_GetNext() == "0")
		v := selected_row
	else v := LV_GetNext()
if !v
{
 CF_ToolTip("未选中行。", 1000)
return
}
	LV_GetText(clip_id, v, 4)
;msgbox % "号" "-" clip_id "-" v
		data := getFromTable("history", "data", "id=" clip_id)
		clip_data := data[1]
;msgbox % "坏" clip_data
		genHTMLforPreview(clip_data)
		gui_Clip_Preview(PREV_FILE, history_searchbox)
	return

/**
 * shows the preview of a clip
 * param path - path to the html file of the clip generated disk or path to jpg file for image
 * param searchbox - searchbox content of the history gui, same is shown in preview
 * param owner - owner of gui
 */
gui_Clip_Preview(path, searchBox="", owner="History")
{
	global prev_copybtn, prev_findtxt, prev_handle, preview_search, preview, prev_findtxtw
	static wt := A_ScreenWidth / 2.2 , ht := A_ScreenHeight / 2.5 ;, maxlines = Round(ht / 13)
	preview := {}

	preview.path := path
	preview.owner := owner

	Gui, Preview:New
	Gui, Margin, 0, 0

		try {
			Gui, Add, ActiveX, w%wt% h%ht% vprev_handle, Shell.Explorer
			ComObjConnect(prev_handle, new ActiveXEvent) 				;do this only when the previous one succeeds
		}
		try prev_handle.Navigate( preview.path )


	Gui, Font, s11
	Gui, Add, Button, % "x5 y+10 h27 gbutton_Copy_To_Clipboard Default vprev_copybtn Section", 复制到剪贴板
	; button's x till 130 , search's width will 200 p from right
	Gui, Add, Text, % "x" wt-200 " yp+2 h23 vprev_findtxt ", 查找(&D) 		; +2 to level text
	Gui, Font, norm
	Gui, Add, Edit, % "x+10 yp-2 w155 h23 vpreview_search gpreviewSearch",  	; -5 margin on right side
	Gui, Add, Text, x5 y+0 w5 			; white-space just below the button

	Gui, Preview:+Owner%owner%
	Gui, % preview.owner ":+Disabled"
	Gui, Preview: +Resize +MaximizeBox -MinimizeBox
	Gui, Preview:Show, AutoSize, 预览

	GuiControlGet, prev_findtxt, Preview:Pos
		GuiControl, , preview_search, % searchBox
	return
}

genHTMLforPreview(code){
	FileDelete, % PREV_FILE
	FileAppend, % "<meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"">`n<pre style=""word-break: break-all; word-wrap: break-word;"">" deActivateHtml(code), % PREV_FILE,cp65001
}

deactivateHtml(code){
	StringReplace, code, code, >, % "&gt;", All
	StringReplace, code, code, <, % "&lt;", All
	return code
}

getFromTable(tbl, cols, condition){
	; get from table
	; get only particular columns if necessary
	local recordSet, Row
	
	q := "select " . cols . " from " . tbl . " where " condition
	recordSet := ""
	if !DB.Query(q, recordSet)
		msgbox ERROR
	if (recordSet.RowCount == 0)
		return ""
	else {
		recordSet.Next(Row)
		return Row
	}
}

/**
 * copy previewed clip to clipboard
 */
button_Copy_to_Clipboard:
	writecliphistory=0
	Gui, Preview:Submit, nohide
		try Clipboard := prev_handle.Document.body.innerText
	sleep 500
	gosub, previewGuiClose
	return

/**
 * close preview gui
 */
previewGuiClose:
previewGuiEscape:
	Gui, % preview.owner ":-Disabled"
	Gui, Preview:Destroy
	prev_handle := ""
	prev_document := ""
	return

history_ButtonDelete:
	history_ButtonDelete()
	return

/**
 * deletes selected rows from history
 * @return {void}
 */
history_ButtonDelete(){
	Gui, History:Default

	temp_row_s := 0 , rows_selected := "" , list_clipfilepath := ""
	while (temp_row_s := Lv_GetNext(temp_row_s))
		rows_selected .= temp_row_s ","
	rows_selected := Substr(rows_selected, 1, -1)     ;get CSV row numbers

	;Get Row names
	loop, parse, rows_selected,`,
		LV_GetText(clip_id, A_LoopField, 4)
		, list_clipfilepath .= clip_id "`n" 	;Important for faster results
	;Delete Rows
	loop, parse, rows_selected,`,
		LV_Delete(A_LoopField+1-A_index)
	;Delete items
;msgbox % list_clipfilepath
	loop, parse, list_clipfilepath, `n
	{
		deleteHistoryById(A_loopfield)
	}
	
	Guicontrol, History:Focus, history_SearchBox
	history_UpdateSTB()
}

deleteHistoryById(id){
	execSql("delete from history where id=" id)
}

/**
 * button event to delete all history
 */
history_ButtonDeleteAll:
	Gui, +OwnDialogs
	MsgBox, 257, 删除重置,确定要删除剪贴板历史记录的数据库，重新开始记录吗？
	IfMsgBox, OK
	{
db.closedb()
filedelete,%DBPATH%
DB.OpenDB(DBPATH)
migrateHistory()
		; 直接删除数据库文件，最方便。减小硬盘占用
		;execSql("Truncate TABLE history")  ; 测试未能正确执行，无效果
		;execSql("drop TABLE history")   ; 磁盘占用减小，再次添加条目报错
		;execSql("delete from history")  ; 删除所有条目，磁盘占用变化不大(数据内容未删除)
		historyUpdate()
		history_UpdateSTB()
	}
	return

exit:
	routines_Exit()
	ExitApp
	return

reload:
	OnExit,
	routines_Exit()
	Reload
	return

routines_Exit() {
	if IsObject(DB){
		DB.CloseDb()
		DB := ""
	}
}

/**
 * label triggered when search box contents are changed and then updates the list
 */
history_SearchBox:
	Critical, On
	Gui, History:Default
	Gui, History:Submit, NoHide
	historyUpdate(history_SearchBox, 0, history_partial)
	LV_ModifyCol(what_sort, how_sort ? "Sort" : "SortDesc") 		;sort column correctly
	return

/*
SuperInstr()
	Returns min/max position for a | separated values of Needle(s)
	
	return_min = true  ; return minimum position
	return_max = false ; return maximum position

*/
SuperInstr(Hay, Needles, return_min=true, Case=false, Startpoint=1, Occurrence=1){
	
	pos := return_min*Strlen(Hay)
	Needles := Rtrim(Needles, " ")
	
	if return_min
	{
		loop, parse, Needles, %A_space%
			if ( pos > (var := Instr(Hay, A_LoopField, Case, startpoint, Occurrence)) )
				pos := var
	}
	else
	{
		if Needles=
			return Strlen(Hay)
		loop, parse, Needles, %A_space%
			if ( (var := Instr(Hay, A_LoopField, Case, startpoint, Occurrence)) > pos )
				pos := var
	}
	return pos
}

/**
 * search in preview gui
 * highlights the matches too
 */
previewSearch:
	Critical
	Gui, submit, nohide
	prev_document := prev_handle.Document.selection.createRange
	prev_document.ExecCommand("BackColor", 0, "White")
	preview_search := Trim(preview_search, A_space)
	if preview_search =
		return

	try {
	;highlight partial matches
	if history_partial
		loop, parse, preview_search, %A_space%, %A_space%
		{
			while prev_document.findtext(A_LoopField)
				prev_document.ExecCommand("BackColor", 0, "Aqua")        
				, prev_document.Collapse(0)
			prev_document := prev_handle.Document.body.innerText 
		}

	;highlight exact matches
	while prev_document.findtext(preview_search)
		prev_document.ExecCommand("BackColor", 0, "Yellow")        
		, prev_document.Collapse(0) 

	}
	return

/**
 * preview gui resize handler
 */
PreviewGuiSize:
	if (A_EventInfo != 1)
	{
		gui_w := A_GuiWidth , gui_h := A_GuiHeight
		GuiControl, move, preview_search, % "x" gui_w-160 " y" gui_h-30
		GuiControl, move, prev_findtxt, % "x" gui_w- (prev_findtxtw ? prev_findtxtw+167 : 210) " y" gui_h-30
		GuiControl, move, prev_copybtn, % "y" gui_h-32
			GuiControl, move, prev_handle, % "w" gui_w " h" gui_h-42
	}
	return

; by Jethrow
; Helps in copy and paste in Shell Explorer
class ActiveXEvent {
	DocumentComplete(prev_handle) {
		static doc
		ComObjConnect(doc:=prev_handle.document, new ActiveXEvent)
	}
	OnKeyPress(doc) {
		static keys := {1:"selectall", 3:"copy", 22:"paste", 24:"cut"}
		keyCode := doc.parentWindow.event.keyCode
		if keys.HasKey(keyCode)
			Doc.ExecCommand(keys[keyCode])
	}
}

/**
 * context menu history gui
 * reponsible for showing right click on clip menu
 */
historyGuiContextMenu:
	if (A_GuiControl != "historyLV") or (LV_GetNext() = 0)
		return
	selected_row := LV_GetNext()
	Menu, HisMenu, Show, %A_GuiX%, %A_GuiY%
	return

history_MenuPreview:
	Send {vk0d}
	return

history_clipboard:
  writecliphistory=0
	hhhh:=history_clipboard()
return

/**
 * transfers the selected item from listview to clipboard
 * @param  {Number} startRow row to start searching the selected clip. 0
 * @return {Number} selected clip row no
 */
history_clipboard(sTartRow=0){
	Gui, History:Default
	row_selected := LV_GetNext(sTartRow)

	if !row_selected
		return 0
	LV_GetText(clip_id, row_selected, 4)

		temp_read := getFromTable("history", "data", "id=" clip_id)[1]
		try Clipboard := temp_Read

	return row_selected
}

/**
 * method to allow editing a history clip
 */
history_EditClip: 		; label inside to call history_searchbox which uses local func variables
	Gui, History:Default
	LV_GetText(clip_id, LV_GetNext(0), 4)

		data := getFromTable("history", "data", "id=" clip_id)
		STORE.ErrorLevel := 0
		out := multInputBox("Edit Clip", "Make your changes and then click OK", 10, data[1], "History")
msgbox % STORE.ErrorLevel
		if (STORE.ErrorLevel == 1){
			execSql("update history set data=""" escapeQuotesSql(out) """ where id=" clip_id, 1)
		}

	gosub history_SearchBox
	return

multInputBox(Title, caption="", row=5, default="", owner=""){
	static theEdit
	local kw, oDone
	
	theEdit := ""
	kw := A_ScreenWidth<1200 ? 600 : 700
	Gui, mIBox:new
	Gui, Font, s10, Consolas
	Gui, Add, Text, x5 y5, % caption
	Gui, Font, norm, Consolas
	Gui, Add, Edit, xp y+30 w%kw% r%row% vtheEdit, % default
	Gui, Add, Button, x5 y+30 Default, OK
	Gui, Add, Button, x+30 yp gmIboxbuttonCancel, 取消(&C)
	if owner {
		Gui, miBox:+owner%owner%
		Gui, %owner%:+Disabled
	}
	Gui, mIbox:Show,, % Title
	while !oDone
		sleep 50
	return theEdit
mIboxbuttonOK:
	Gui, miBox:Submit, nohide
	STORE.ErrorLevel := 1
	gosub mIboxGuiClose
	return

mIboxGuiClose:
mIboxbuttonCancel:
	if owner
		Gui, %owner%:-Disabled
	Gui, mIBox:Destroy
	oDone := 1
	return
}

historyCleanup(){
;Cleans history in bunch
	local Row
	if !ini_DaysToStore                    ;Dont delete old data
		return

	q := "select id from history where (strftime('%s', date('now', '-" ini_DaysToStore " days')) - strftime('%s', time)) > 0"
	recs := ""
	if (!DB.Query(q, recs))
		msgbox % "Error history cleanup `n " DB.ErrorMsg "`n" DB.ErrorCode "`n" q

	DB.Exec("BEGIN TRANSACTION")
	while ( recs.Next(Row) > 0 )
	{
		deleteHistoryById(Row[1])
	}
	DB.Exec("COMMIT TRANSACTION")
}

/**
 * reutrns the size of history
 * @param  {String} option no idea
 * @return {number} size in kb
 */
history_GetSize(option := ""){
	If (option == ""){
    	data := getFromTable("history", "sum(size)", "id>-1")
    	R := data[1]
	} else {

	}

    return R/1024
}

/**
 * update size in status bar
 * @param  {String} size size to show
 * @return {void}
 */
history_UpdateSTB(size=""){
	; If size is passed, that size is used
	Gui, History:Default
	SB_SetText("占用硬盘 : " ( size="" ? history_GetSize() : size ) " KB")
}