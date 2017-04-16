;Ctrl+Enter×Ô¶¯²¹ÆëÍøÖ·
#IfWinActive,ahk_Group AppMainWindow
^Enter::
Gui, Submit, NoHide
if dir
run http://www.%Dir%.com/
Return
#IfWinActive
