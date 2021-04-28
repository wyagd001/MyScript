;来源网址: https://www.autoahk.com/archives/18627
SplitPath A_AhkPath,, AhkDir
If (A_PtrSize = 8 || !A_IsUnicode) {
    U32 := AhkDir . "AutoHotkeyU32.exe"
    If (FileExist(U32)) {
        Run % U32 . " """ . A_LineFile . ""
        ExitApp
    } Else {
        MsgBox 0x40010, AutoGUI, AutoHotkey 32-bit Unicode not found.
        ExitApp
    }
}

file := A_Args[1]

;Thinkai@2015-11-05
Gui, Add, Tab, x0 y0 w800 h500 vtab
Gui, Show, , % File " - 文件预览"
;FileSelectFile, file, , , 选择一个表格, Excel文件(*.xls;*.xlsx)
IfNotExist % file
    ExitApp
conn := ComObjCreate("ADODB.connection") ;初始化COM
;不区分后缀名尝试用03、07格式
/*
try
	conn.Open("Provider=Microsoft.Jet.OLEDB.4.0;Extended Properties='Excel 8.0;HDR=Yes';Data Source=" file) ;打开连接 2003方式
catch e03
{
	try
		conn.Open("Provider=Microsoft.Ace.OLEDB.12.0;Extended Properties=Excel 12.0;Data Source=" file) ;打开连接
	catch e07
		MsgBox, 4112, 出错, % "尝试用office 2003方式打开出错：`n" e03.Message "`n尝试用office 2007方式打开出错：`n" e07.Message "`n请检查！"
}
*/
if RegExMatch(file,".xlsx$")
{
	try
		conn.Open("Provider=Microsoft.Ace.OLEDB.12.0;Extended Properties=Excel 12.0;Data Source=" file) ;打开连接
	catch e07
		MsgBox, 4112, 出错, % "尝试用office 2007方式打开出错：`n" e07.Message "`n请检查！"
}
else
{
	try
		conn.Open("Provider=Microsoft.Jet.OLEDB.4.0;Extended Properties='Excel 8.0;HDR=Yes';Data Source=" file) ;打开连接 2003方式
	catch e03
		MsgBox, 4112, 出错, % "尝试用office 2003方式打开出错：`n" e03.Message "`n请检查！"
}
 
;通过OpenSchema方法获取表信息
rs := conn.OpenSchema(20) ;SchemaEnum 参考 http://www.w3school.com.cn/ado/app_schemaenum.asp
table_info := []
table_name := []
rs.MoveFirst()
while !rs.EOF ;有效Sheet
{
;fileappend, % rs.("TABLE_NAME").value "`n",%A_desktop%\123.txt
	t_name := RegExReplace(rs.("TABLE_NAME").value,"^'*(.*)\$'*$","$1")
;fileappend, % t_name "`n",%A_desktop%\123.txt
	t_name := Trim(t_name, "$")
;fileappend, % t_name "`n`n",%A_desktop%\123.txt

	if InStr(t_name, "_")   ; 表名中带有"_"字符，则跳过
{
	rs.MoveNext()
		continue
}
	table_name[t_name] := rs.("TABLE_NAME").value
	q := conn.Execute("select top 1 * from [" t_name "$]")
 
	if (q.Fields(0).Name="F1" && q.Fields.Count=1) ;排除空表格!!!!!!!!!
	{
		rs.MoveNext()
		continue
	}
	
 
	table_info[t_name] := []
	for field in q.Fields  ;获取按顺序排列的字段
		table_info[t_name].insert(field.Name)
	q.close()
	rs.MoveNext()
}
;生成Listview
for t,c in table_info
{
	;创建tab及listview
	GuiControl, , tab, % t
	Gui, Tab, % A_index
	cols =
	for k,v in c
		cols .= cols ? "|" v : v
	Gui, Add, ListView, % "x10 y50 w780 h460 vlv" A_Index, % cols
	Gui, ListView, % "lv" A_Index
 
	;获取表格数据
	data := GetTable("select * from [" table_name[t] "]")
	for k,v in data
		LV_Add("",v*)
 
	LV_ModifyCol() ;自动调整列宽
}
rs.close()
conn.close()
return

$Space::
GuiClose:
ExitApp
 
GetTable(sql){ ;Adodb通用的获取数据数组的函数
    global conn
    t := []
	try
	{
		query := conn.Execute(sql)
		fetchedArray := query.GetRows() ;取出数据（二维数组）
	}
	catch e
	{
		MsgBox, 4112, 出错, % e03.Message "`n请检查！"
		return []
	}
    colSize := fetchedArray.MaxIndex(1) + 1 ;列最大值 tips：从0开始 所以要+1
    rowSize := fetchedArray.MaxIndex(2) + 1 ;行最大值 tips：从0开始 所以要+1
    loop, % rowSize
    {
        i := (y := A_index) - 1
        t[y] := []
        loop, % colSize
        {
            j := (x := A_index) - 1
            t[y][x] := fetchedArray[j,i] ;取出二维数组内值
        }
    }
	query.close()
    return t
}
