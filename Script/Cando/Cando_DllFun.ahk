Cando_DllFun:

Gui,66:Destroy
Gui,66:Default
Gui, add, Edit, x10 y10 w300 h300 readonly, % DllListExports(CandySel)
Gui, Show,, dll内函数查看 
return

