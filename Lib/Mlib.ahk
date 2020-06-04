migrateHistory(){
; migrates History files to the database
	createHisTable()
	DB.Exec("BEGIN TRANSACTION")
	;API.showTip("Moving history files to database. This process may take some time.")
	DB.Exec("COMMIT TRANSACTION")
	;API.removeTip()
}

mLiblistview()
{
	;TickCount_Start := A_TickCount 
	xuhao = 0
	result := ""
	GuiControl, -Redraw, ListView
	if !DB.GetTable("select * from Mlib", result)
	return false
	no:=StrLen(result.RowCount)
	if !no
	return false
	loop % result.RowCount
	{
		xuhao++
		result.Next(Row)
		LV_Add("", Format("{:0" no "}", xuhao), Row[2], Row[3], Row[4], Row[5], Row[6], Row[7], Row[8])
	}
	LV_ModifyCol()
	LV_ModifyCol(2,250)
	LV_ModifyCol(4,250)
	LV_ModifyCol(5,150)
	LV_ModifyCol(6,150)
	GuiControl, +Redraw, ListView
	;MsgBox, % "耗时: " (A_TickCount-TickCount_Start)/1000 " 秒"
return true
}

createHisTable(){
; creates the History Table if it doesnt exist
; called by the migrateHistory function
	q = 
	(
		CREATE TABLE if not exists Mlib `(
		id	INTEGER PRIMARY KEY AUTOINCREMENT,
		name	TEXT,
		type 	TEXT,
		mp3 	TEXT,
		createtime	TEXT,
		lastplayedtime	TEXT,
		size 	NUMBER,
		plcount 	NUMBER
		`)
	)
	if !DB.Exec(q)
    MsgBox, 16, SQLite错误, % "消息:`t" . DB.ErrorMsg . "`n代码:`t" . DB.ErrorCode
}

addmusicfile(file){
; adds some text data to history
; the timestamp is in A_Now format
	SplitPath, file,,,type, name
	createtime := convertTimeSql( CF_FileGetTime(file) )
	q := "insert into Mlib (name, type, mp3, createtime, lastplayedtime, size, plcount) values (""" 
		. name
		. """, """ . type . """, """ . file . """, """
		. createtime """, 0, "
		. Round(CF_FileGetSize(file)/1024, 1) "," 0 ")"
	if (!DB.Exec(q))
    MsgBox, 16, SQLite 错误, % "消息:`t" . DB.ErrorMsg . "`n代码:`t" . DB.ErrorCode
}

updateMlib()
{
global AhkMediaLib
global filelistarray

mp3listarray:={}
db.Query("Select mp3 from Mlib", result)
while result.Next(Row) !=-1
mp3listarray.Push(Row[1])

deletefilelistarray:=[]
for k,v in mp3listarray
{
if !filelistarray.Delete(v)
deletefilelistarray.Push(v)
}

if filelistarray.Count()
PLaddmusicfile(filelistarray)

;fileappend, % Array_ToString(filelistarray), %A_ScriptDir%\aaa.txt

if deletefilelistarray.length()
PLdeletemusicfile(deletefilelistarray)

return
}

PLaddmusicfile(aArray){
; adds some text data to history
; the timestamp is in A_Now format
q:=""
for k,v in aArray
{
	SplitPath, k,,,type, name
	createtime := convertTimeSql( CF_FileGetTime(k) )
	p :=  "(""" 
		. name
		. """, """ . type . """, """ . k . """, """
		. createtime """, 0, "
		. Round(CF_FileGetSize(k)/1024, 1) "," 0 ")"
  q:= q p ","
}
q:= Trim(q, ",") 
if !q
return
q:= "insert into Mlib (name, type, mp3, createtime, lastplayedtime, size, plcount) values " q

;fileappend, % q, %A_ScriptDir%\ddd.txt

	if (!DB.Exec(q))
    MsgBox, 16, SQLite 错误, % "消息:`t" . DB.ErrorMsg . "`n代码:`t" . DB.ErrorCode
q:=""
return
}

updatemusicfile(file){
  q:="select * from Mlib where mp3 =""" file """"
  	if !DB.Query(q, recordSet)
		msgbox ERROR
  	if (recordSet.RowCount == 0)
		return 
		else {
		recordSet.Next(Row)
	}
	plcount:=Row[8]+1

	SplitPath, file,,,type, name
	lastplayedtime := convertTimeSql( A_now )
	q := "Update Mlib Set lastplayedtime=""" lastplayedtime """, plcount=""" plcount """ Where mp3=""" file """"

	if (!DB.Exec(q))
    MsgBox, 16, SQLite 错误, % "消息:`t" . DB.ErrorMsg . "`n代码:`t" . DB.ErrorCode
return
}

PLdeletemusicfile(aArray){
q:=""
for k,v in aArray
{
p:= """" v """"
q:= q p ","
}
q:= Trim(q, ",")
if !q
return

q := "delete from Mlib where mp3 in (" q ")"
execSql(q)
q:=""
return
}

deletemusicfile(file){
q := "delete from Mlib where mp3 =""" file """"
execSql(q)
return
}

execSql(s, warn:=0){
	; execute sql
	if (!DB.Exec(s))
		if (warn)
			msgbox % DB.ErrorCode "`n" DB.ErrorMsg
}

; Converts YYYYMMDDHHMMSS to YYYY-MM-DD HH:MM:SS
convertTimeSql(t=""){
	if (t == "") 
		t:= A_Now
	return SubStr(t, 1, 4) "-" SubStr(t,5,2) "-" SubStr(t,7,2) " " SubStr(t, 9, 2) ":" SubStr(t,11,2) ":" SubStr(t,13,2)
}

CF_FileGetTime(file)
{
FileGetTime, OutputVar, % file, C
return OutputVar
}

CF_FileGetSize(file)
{
FileGetSize, OutputVar, % file, K
return OutputVar
}