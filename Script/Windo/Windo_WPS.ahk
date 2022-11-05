;q::
;gosub Windo_ET_PasteAll
;return

/*
wps  VB 宏（Alt+F8）中的选项  指定快捷键
在wps更新后，快捷键失效

同一个excel文件的方法调用：
module3/4/5在同一个excel文件。module5利用application.run调用其他module的sub/function时，如果该sub/function名在所有module里唯一，可以不加模块名(推荐全加模块名)。否则报错，需要模块名.方法名调用。
模块名和方法名都不区分大小写。

不同excel文件的方法调用：
方法1：Application.Run " ‘文件名’ “!模块名.方法名”
方法2：Application.Run " ‘路径+文件名’ “!模块名.方法名”
必须带上文件名和模块名，即使方法在该文件唯一。且文件名两边有单引号，文件名和模块名间有!。
如果被调用的工作簿是打开状态，方法1和方法2都可以。如果是关闭状态，方法2会打开路径+文件名进行调用，方法1会打开当前文件路径+文件名进行调用。
*/

Windo_WPS_RunVba:
Application := ComObjActive("ket.Application")
if !Splitted_Windy_Cmd4
try Application.run("'" Application.ActiveWorkbook.FullName "'!" Splitted_Windy_Cmd3)
else
try Application.run("'" Application.ActiveWorkbook.FullName "'!" Splitted_Windy_Cmd3, Splitted_Windy_Cmd4)
;ObjRelease(&Application)  ; 退出et需要释放，否则et不会退出，如果释放，再次调用发送错误，无效内存地址
Application:=""
;Application.ActiveWorkbook.run("!模块1.二合一函数")
;Application.ActiveSheet.run("!模块1.二合一函数")
;tooltip % "'" Application.ActiveWorkbook.FullName "'!模块1.二合一函数"
return

; 不同工作表的相同位置相同的值(公式), 适用于总表加 n 个分表的情况
; 分表具有相同的结构, 其中一个单元格要更改, 所有分表中的相同位置的单元格也随之更改
; 1. 最常见的方法是不同工作表一个一个切换一个一个粘贴(分表太多时耗时耗力)
; 2. 将所有要修改的工作表选中(表多的话可以先全选再剔除), 在其中一个工作表修改好单元格后,所有选中的工作表中的相同位置单元格都会被修改

Windo_ET_PasteAll:
Application := ComObjActive("ket.Application")
ActiveCell := Application.ActiveCell.Address
ActiveCell := StrReplace(ActiveCell, "$")
HasFormula := Application.ActiveSheet.Range(ActiveCell).HasFormula
if !HasFormula
	ActiveCellValue := Application.ActiveSheet.Range(ActiveCell).Value
else
	ActiveCellValue := Application.ActiveSheet.Range(ActiveCell).Formula

SheetsCount := Application.ActiveWorkbook.Sheets.Count
loop % SheetsCount
{
	SheetName := Application.ActiveWorkbook.Sheets(A_index).Name
	if CF_Isinteger(SheetName)   ; 工作表名为数字时进行复制
	{
		Application.Sheets(A_index).Range(ActiveCell).Value := ActiveCellValue
	}
}
Application:=""
return